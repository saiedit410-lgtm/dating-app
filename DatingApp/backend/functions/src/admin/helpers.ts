/**
 * Spark admin — privileged-mutation callables (Phase 2.4).
 *
 * Every callable in this directory verifies `context.auth.token.admin === true`
 * before touching Firestore. All mutations are function-only — the rules
 * deny client writes to the trust/status fields. Every privileged action
 * also writes an `adminActions/{auto}` doc so the audit log is append-only
 * and tamper-evident (only the Admin SDK writes it; rules deny client writes).
 */
import {
  onCall,
  HttpsError,
  type CallableRequest,
} from "firebase-functions/v2/https";
import {getFirestore, FieldValue} from "firebase-admin/firestore";
import {logger} from "firebase-functions/v2";

const db = getFirestore();

/* -------------------------------------------------------------------------- *
 * Authz
 * -------------------------------------------------------------------------- */

function requireAdmin(req: CallableRequest<unknown>): asserts req is CallableRequest<unknown> & {
  auth: {uid: string; token: {admin?: boolean}};
} {
  const admin = req.auth?.token?.admin === true;
  if (!admin) {
    logger.warn(
      `admin call denied: uid=${req.auth?.uid ?? "<anon>"} has no admin claim`,
    );
    throw new HttpsError("permission-denied", "admin claim required");
  }
}

/* -------------------------------------------------------------------------- *
 * Audit
 * -------------------------------------------------------------------------- */

type AdminActionWire =
  | "verification.approve"
  | "verification.reject"
  | "report.resolve"
  | "user.setStatus";

type AdminActionTarget = "user" | "report" | "verificationRequest";

interface AuditArgs {
  adminUid: string;
  action: AdminActionWire;
  targetType: AdminActionTarget;
  targetUid: string;
  payload?: Record<string, unknown>;
  note?: string;
}

/** Write a single `adminActions/{auto}` row. Returns the new doc id. */
async function writeAudit(a: AuditArgs): Promise<string> {
  const ref = await db.collection("adminActions").add({
    adminUid: a.adminUid,
    action: a.action,
    targetType: a.targetType,
    targetUid: a.targetUid,
    payload: a.payload ?? {},
    note: a.note ?? "",
    createdAt: FieldValue.serverTimestamp(),
  });
  logger.info(
    `admin action ${a.action} on ${a.targetType}:${a.targetUid} by ${a.adminUid}`,
  );
  return ref.id;
}

/* -------------------------------------------------------------------------- *
 * 1. approveVerification(uid)
 * -------------------------------------------------------------------------- */

export const approveVerification = onCall<{uid: string}>(async (req) => {
  requireAdmin(req);
  const {uid} = req.data;
  if (typeof uid !== "string" || uid.length === 0) {
    throw new HttpsError("invalid-argument", "uid is required");
  }
  const adminUid = req.auth!.uid;

  const reqRef = db.collection("verificationRequests").doc(uid);
  const userRef = db.collection("users").doc(uid);
  const snap = await reqRef.get();
  if (!snap.exists) {
    throw new HttpsError("not-found", "no verification request for that uid");
  }
  if (snap.data()?.status !== "pending") {
    throw new HttpsError(
      "failed-precondition",
      `verification is not pending (current: ${snap.data()?.status})`,
    );
  }

  const batch = db.batch();
  batch.update(reqRef, {
    status: "approved",
    reviewedAt: FieldValue.serverTimestamp(),
    reviewedBy: adminUid,
    rejectionReason: null,
  });
  batch.set(
    userRef,
    {
      isVerified: true,
      verificationStatus: "approved",
      verifiedAt: FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
    },
    {merge: true},
  );
  await batch.commit();

  const actionId = await writeAudit({
    adminUid,
    action: "verification.approve",
    targetType: "verificationRequest",
    targetUid: uid,
    payload: {status: "approved"},
  });
  return {ok: true, actionId};
});

/* -------------------------------------------------------------------------- *
 * 2. rejectVerification(uid, reason)
 * -------------------------------------------------------------------------- */

export const rejectVerification = onCall<{uid: string; reason: string}>(
  async (req) => {
    requireAdmin(req);
    const {uid, reason} = req.data;
    if (typeof uid !== "string" || uid.length === 0) {
      throw new HttpsError("invalid-argument", "uid is required");
    }
    if (typeof reason !== "string" || reason.trim().length === 0) {
      throw new HttpsError(
        "invalid-argument",
        "reason is required and must be non-empty",
      );
    }
    const adminUid = req.auth!.uid;
    const trimmed = reason.trim().slice(0, 500);

    const reqRef = db.collection("verificationRequests").doc(uid);
    const userRef = db.collection("users").doc(uid);
    const snap = await reqRef.get();
    if (!snap.exists) {
      throw new HttpsError(
        "not-found",
        "no verification request for that uid",
      );
    }
    if (snap.data()?.status !== "pending") {
      throw new HttpsError(
        "failed-precondition",
        `verification is not pending (current: ${snap.data()?.status})`,
      );
    }

    const batch = db.batch();
    batch.update(reqRef, {
      status: "rejected",
      reviewedAt: FieldValue.serverTimestamp(),
      reviewedBy: adminUid,
      rejectionReason: trimmed,
    });
    batch.set(
      userRef,
      {
        verificationStatus: "rejected",
        updatedAt: FieldValue.serverTimestamp(),
      },
      {merge: true},
    );
    await batch.commit();

    const actionId = await writeAudit({
      adminUid,
      action: "verification.reject",
      targetType: "verificationRequest",
      targetUid: uid,
      payload: {status: "rejected", reason: trimmed},
    });
    return {ok: true, actionId};
  },
);

/* -------------------------------------------------------------------------- *
 * 3. resolveReport(reportId, resolution, note?)
 *    resolution ∈ { warn, suspend, ban, dismiss }
 *    'suspend' / 'ban' cascade to setUserStatus on the reported uid.
 * -------------------------------------------------------------------------- */

type ReportResolution = "warn" | "suspend" | "ban" | "dismiss";

export const resolveReport = onCall<{
  reportId: string;
  resolution: ReportResolution;
  note?: string;
}>(async (req) => {
  requireAdmin(req);
  const {reportId, resolution, note} = req.data;
  if (typeof reportId !== "string" || reportId.length === 0) {
    throw new HttpsError("invalid-argument", "reportId is required");
  }
  if (
    resolution !== "warn" &&
    resolution !== "suspend" &&
    resolution !== "ban" &&
    resolution !== "dismiss"
  ) {
    throw new HttpsError(
      "invalid-argument",
      "resolution must be one of warn|suspend|ban|dismiss",
    );
  }
  const adminUid = req.auth!.uid;
  const trimmedNote =
    typeof note === "string" && note.trim().length > 0
      ? note.trim().slice(0, 500)
      : "";

  const reportRef = db.collection("reports").doc(reportId);
  const reportSnap = await reportRef.get();
  if (!reportSnap.exists) {
    throw new HttpsError("not-found", "no such report");
  }
  const reportedUid = reportSnap.data()?.reportedUid as string | undefined;
  if (!reportedUid) {
    throw new HttpsError("internal", "report is missing reportedUid");
  }

  await reportRef.update({
    status: "resolved",
    resolution,
    resolutionNote: trimmedNote,
    reviewedAt: FieldValue.serverTimestamp(),
    reviewedBy: adminUid,
  });

  const reportActionId = await writeAudit({
    adminUid,
    action: "report.resolve",
    targetType: "report",
    targetUid: reportId,
    payload: {resolution, reportedUid},
    note: trimmedNote,
  });

  // Cascade: suspend / ban also update the target user's accountStatus.
  let cascadeActionId: string | null = null;
  if (resolution === "suspend" || resolution === "ban") {
    const newStatus = resolution === "suspend" ? "suspended" : "banned";
    await db
      .collection("users")
      .doc(reportedUid)
      .set(
        {
          accountStatus: newStatus,
          lastReviewedBy: adminUid,
          lastReviewedAt: FieldValue.serverTimestamp(),
          updatedAt: FieldValue.serverTimestamp(),
        },
        {merge: true},
      );
    cascadeActionId = await writeAudit({
      adminUid,
      action: "user.setStatus",
      targetType: "user",
      targetUid: reportedUid,
      payload: {accountStatus: newStatus, from: "report.resolve"},
      note: trimmedNote,
    });
  }

  return {ok: true, actionId: reportActionId, cascadeActionId};
});

/* -------------------------------------------------------------------------- *
 * 4. setUserStatus(uid, status, note?)
 *    status ∈ { active, suspended, banned }
 *    Mirrors the suspend/ban cascade from resolveReport. The UI also
 *    uses this for plain Suspend / Restore from the user detail screen.
 * -------------------------------------------------------------------------- */

type AccountStatus = "active" | "suspended" | "banned";

export const setUserStatus = onCall<{
  uid: string;
  status: AccountStatus;
  note?: string;
}>(async (req) => {
  requireAdmin(req);
  const {uid, status, note} = req.data;
  if (typeof uid !== "string" || uid.length === 0) {
    throw new HttpsError("invalid-argument", "uid is required");
  }
  if (
    status !== "active" &&
    status !== "suspended" &&
    status !== "banned"
  ) {
    throw new HttpsError(
      "invalid-argument",
      "status must be one of active|suspended|banned",
    );
  }
  const adminUid = req.auth!.uid;
  const trimmedNote =
    typeof note === "string" && note.trim().length > 0
      ? note.trim().slice(0, 500)
      : "";

  const userRef = db.collection("users").doc(uid);
  const snap = await userRef.get();
  if (!snap.exists) {
    throw new HttpsError("not-found", "no such user");
  }

  await userRef.set(
    {
      accountStatus: status,
      lastReviewedBy: adminUid,
      lastReviewedAt: FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
    },
    {merge: true},
  );

  const actionId = await writeAudit({
    adminUid,
    action: "user.setStatus",
    targetType: "user",
    targetUid: uid,
    payload: {accountStatus: status},
    note: trimmedNote,
  });
  return {ok: true, actionId};
});
