import 'package:dating_app/features/verification/application/verification_controller.dart';
import 'package:dating_app/features/verification/application/verification_providers.dart';
import 'package:dating_app/features/verification/domain/verification_request.dart';
import 'package:dating_app/shared/extensions/build_context_x.dart';
import 'package:dating_app/shared/widgets/verified_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Profile verification: shows the current status and lets the user submit /
/// resubmit a selfie. Approval is performed by admins (not here).
class VerificationScreen extends ConsumerWidget {
  const VerificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<VerificationSubmitState>(verificationControllerProvider, (
      VerificationSubmitState? previous,
      VerificationSubmitState next,
    ) {
      if (next.error != null) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(next.error!)));
      }
    });

    final AsyncValue<VerificationRequest?> requestAsync = ref.watch(
      myVerificationRequestProvider,
    );
    final VerificationSubmitState submit = ref.watch(
      verificationControllerProvider,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Get verified')),
      body: requestAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object e, StackTrace _) =>
            const Center(child: Text('Could not load verification status.')),
        data: (VerificationRequest? request) =>
            _content(context, ref, request, submit),
      ),
    );
  }

  Widget _content(
    BuildContext context,
    WidgetRef ref,
    VerificationRequest? request,
    VerificationSubmitState submit,
  ) {
    final bool canSubmit =
        (request == null || request.isRejected) && !submit.isSubmitting;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text('Verify your profile', style: context.textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            "Upload a clear selfie so we can confirm it's really you. Verified "
            'profiles earn a blue badge and more trust.',
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          if (request != null) _statusCard(context, request),
          if (request != null) const SizedBox(height: 24),
          if (request == null || request.isRejected)
            FilledButton.icon(
              onPressed: canSubmit
                  ? () => ref
                        .read(verificationControllerProvider.notifier)
                        .pickAndSubmit()
                  : null,
              icon: submit.isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    )
                  : const Icon(Icons.verified_user_outlined),
              label: Text(
                request == null ? 'Upload selfie & submit' : 'Resubmit',
              ),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
              ),
            ),
        ],
      ),
    );
  }

  Widget _statusCard(BuildContext context, VerificationRequest request) {
    final (IconData icon, String title, String subtitle) info = switch (request
        .status) {
      VerificationStatus.pending => (
        Icons.hourglass_top,
        'Under review',
        "We're reviewing your selfie — this usually takes up to 24 hours.",
      ),
      VerificationStatus.approved => (
        Icons.verified,
        "You're verified",
        'Your blue badge now appears across the app.',
      ),
      VerificationStatus.rejected => (
        Icons.error_outline,
        'Not approved',
        request.rejectionReason?.trim().isNotEmpty ?? false
            ? 'Reason: ${request.rejectionReason!.trim()}'
            : 'Your last submission was not approved. You can try again.',
      ),
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (request.isApproved)
              const VerifiedBadge(size: 28)
            else
              Icon(
                info.$1,
                size: 28,
                color: context.colorScheme.onSurfaceVariant,
              ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(info.$2, style: context.textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(
                    info.$3,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
