import 'dart:async';

import 'package:dating_app/features/auth/application/phone_auth_controller.dart';
import 'package:dating_app/features/auth/presentation/widgets/otp_input.dart';
import 'package:dating_app/shared/extensions/build_context_x.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// OTP entry: 6-digit boxed input, a resend countdown, and verification state.
class OtpVerificationScreen extends ConsumerStatefulWidget {
  const OtpVerificationScreen({super.key});

  @override
  ConsumerState<OtpVerificationScreen> createState() =>
      _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen> {
  static const int _resendSeconds = 60;
  Timer? _timer;
  int _secondsLeft = _resendSeconds;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    _timer?.cancel();
    setState(() => _secondsLeft = _resendSeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      if (_secondsLeft <= 1) {
        t.cancel();
        setState(() => _secondsLeft = 0);
      } else {
        setState(() => _secondsLeft -= 1);
      }
    });
  }

  void _resend() {
    ref.read(phoneAuthControllerProvider.notifier).resendCode();
    _startCountdown();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<PhoneAuthState>(phoneAuthControllerProvider, (previous, next) {
      if (next.hasError && next.failure != null) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(next.failure!.message)));
      }
    });

    final state = ref.watch(phoneAuthControllerProvider);
    final phone = state.phoneNumber ?? 'your number';

    return Scaffold(
      appBar: AppBar(title: const Text('Verify')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text('Enter the code', style: context.textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(
                'We sent a 6-digit code to $phone.',
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 32),
              OtpInput(
                enabled: !state.isVerifying,
                onChanged: (_) {},
                onCompleted: (String code) => ref
                    .read(phoneAuthControllerProvider.notifier)
                    .verifyCode(code),
              ),
              const SizedBox(height: 24),
              if (state.isVerifying)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    ),
                    const SizedBox(width: 12),
                    Text('Verifying…', style: context.textTheme.bodyMedium),
                  ],
                ),
              const SizedBox(height: 8),
              Center(
                child: _secondsLeft > 0
                    ? Text(
                        'Resend code in ${_secondsLeft}s',
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                      )
                    : TextButton(
                        onPressed: state.isBusy ? null : _resend,
                        child: const Text('Resend code'),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
