/**
 * Spark Cloud Functions — push notifications via FCM.
 *
 * Triggers:
 *   onFriendRequestCreated  -> notify the recipient ("New friend request")
 *   onFriendRequestAccepted -> notify the sender   ("Request accepted")
 *   onMessageCreated        -> notify the other participant ("New message")
 *
 * Recipient device tokens live in `users/{uid}/deviceTokens/{token}` (doc id ==
 * token). Invalid tokens are pruned after a failed send.
 *
 * Phase 2.4 also exports the admin callables (privileged mutations on
 * verificationRequests / reports / users). The admin seams live in
 * `admin/helpers.ts`; the function bundle is one.
 */
import {initializeApp} from "firebase-admin/app";
import {getFirestore} from "firebase-admin/firestore";
import {getMessaging, MulticastMessage} from "firebase-admin/messaging";
import {onDocumentCreated, onDocumentUpdated} from "firebase-functions/v2/firestore";
import {logger} from "firebase-functions/v2";

initializeApp();
const db = getFirestore();

/** Reads the recipient's device tokens (the doc ids). */
async function tokensFor(uid: string): Promise<string[]> {
  const snap = await db.collection("users").doc(uid).collection("deviceTokens").get();
  return snap.docs.map((d) => d.id);
}

/** Sends a notification to all of [uid]'s devices and prunes dead tokens. */
async function notify(
  uid: string,
  notification: {title: string; body: string},
  data: Record<string, string>,
): Promise<void> {
  const tokens = await tokensFor(uid);
  if (tokens.length === 0) {
    logger.info(`No device tokens for ${uid}; skipping push.`);
    return;
  }

  const message: MulticastMessage = {
    tokens,
    notification,
    data,
    android: {priority: "high"},
  };

  const response = await getMessaging().sendEachForMulticast(message);

  const stale: Promise<unknown>[] = [];
  response.responses.forEach((result, index) => {
    if (result.success) return;
    const code = result.error?.code ?? "";
    if (
      code === "messaging/registration-token-not-registered" ||
      code === "messaging/invalid-registration-token" ||
      code === "messaging/invalid-argument"
    ) {
      stale.push(
        db
          .collection("users")
          .doc(uid)
          .collection("deviceTokens")
          .doc(tokens[index])
          .delete(),
      );
    }
  });
  await Promise.all(stale);
}

export const onFriendRequestCreated = onDocumentCreated(
  "friendRequests/{requestId}",
  async (event) => {
    const data = event.data?.data();
    if (!data || data.status !== "pending") return;
    await notify(
      data.toUid as string,
      {title: "New friend request", body: "Someone wants to connect with you."},
      {type: "friend_request", fromUid: (data.fromUid as string) ?? ""},
    );
  },
);

export const onFriendRequestAccepted = onDocumentUpdated(
  "friendRequests/{requestId}",
  async (event) => {
    const before = event.data?.before.data();
    const after = event.data?.after.data();
    if (!before || !after) return;
    if (before.status !== "accepted" && after.status === "accepted") {
      await notify(
        after.fromUid as string,
        {title: "Request accepted", body: "You have a new connection."},
        {type: "request_accepted", byUid: (after.toUid as string) ?? ""},
      );
    }
  },
);

export const onMessageCreated = onDocumentCreated(
  "conversations/{conversationId}/messages/{messageId}",
  async (event) => {
    const message = event.data?.data();
    if (!message) return;
    const conversationId = event.params.conversationId;

    const conversation = await db
      .collection("conversations")
      .doc(conversationId)
      .get();
    const participants = (conversation.data()?.participants as string[]) ?? [];
    const senderId = (message.senderId as string) ?? "";
    const recipient = participants.find((uid) => uid !== senderId);
    if (!recipient) return;

    const text = (message.text as string) ?? "";
    await notify(
      recipient,
      {
        title: "New message",
        body: text.length > 100 ? `${text.slice(0, 100)}…` : text || "Sent you a message",
      },
      {type: "message", conversationId, senderId},
    );
  },
);

// Phase 2.4 — admin callables (privileged mutations, all gated on the
// `admin: true` custom claim). Re-exported so the function bundle is one.
export {
  approveVerification,
  rejectVerification,
  resolveReport,
  setUserStatus,
} from "./admin/helpers";

