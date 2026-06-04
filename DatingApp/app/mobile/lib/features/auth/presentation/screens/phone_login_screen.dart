import 'package:dating_app/core/routing/app_routes.dart';
import 'package:dating_app/features/auth/application/phone_auth_controller.dart';
import 'package:dating_app/features/auth/domain/country.dart';
import 'package:dating_app/shared/extensions/build_context_x.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Phone-number entry: country dial code + national number, validation, and a
/// "Send code" action that triggers OTP delivery.
class PhoneLoginScreen extends ConsumerStatefulWidget {
  const PhoneLoginScreen({super.key});

  @override
  ConsumerState<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends ConsumerState<PhoneLoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  Country _country = kDefaultCountry;
  String? _validationError;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  /// National digits only, with any leading zeros removed.
  String get _nationalDigits =>
      _phoneController.text.replaceAll(RegExp(r'\D'), '').replaceFirst(RegExp(r'^0+'), '');

  String get _e164 => '${_country.dialCode}$_nationalDigits';

  String? _validate() {
    final digits = _nationalDigits;
    if (digits.isEmpty) return 'Please enter your phone number.';
    if (_country.dialCode == '+91' && digits.length != 10) {
      return 'Indian numbers must be 10 digits.';
    }
    if (digits.length < 6 || digits.length > 14) {
      return 'That phone number looks invalid.';
    }
    return null;
  }

  void _submit() {
    final error = _validate();
    setState(() => _validationError = error);
    if (error != null) return;
    FocusScope.of(context).unfocus();
    ref.read(phoneAuthControllerProvider.notifier).sendCode(_e164);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<PhoneAuthState>(phoneAuthControllerProvider, (previous, next) {
      final onLogin =
          GoRouterState.of(context).matchedLocation == AppRoute.login.path;
      if (next.status == PhoneAuthStatus.codeSent && onLogin) {
        context.pushNamed(AppRoute.otp.routeName);
      } else if (next.hasError && next.failure != null) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(next.failure!.message)));
      }
    });

    final state = ref.watch(phoneAuthControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Sign in')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text('Enter your phone number', style: context.textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(
                "We'll text you a 6-digit code to verify it's you.",
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _CountryDropdown(
                    value: _country,
                    onChanged: (Country? c) {
                      if (c != null) setState(() => _country = c);
                    },
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      enabled: !state.isBusy,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(14),
                      ],
                      decoration: InputDecoration(
                        labelText: 'Phone number',
                        border: const OutlineInputBorder(),
                        errorText: _validationError,
                      ),
                      onSubmitted: (_) => _submit(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: state.isSendingCode ? null : _submit,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                ),
                child: state.isSendingCode
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.5),
                      )
                    : const Text('Send code'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CountryDropdown extends StatelessWidget {
  const _CountryDropdown({required this.value, required this.onChanged});

  final Country value;
  final ValueChanged<Country?> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      child: DropdownButtonHideUnderline(
        child: InputDecorator(
          decoration: const InputDecoration(border: OutlineInputBorder()),
          child: DropdownButton<Country>(
            value: value,
            isExpanded: true,
            onChanged: onChanged,
            items: kSupportedCountries
                .map(
                  (Country c) => DropdownMenuItem<Country>(
                    value: c,
                    child: Text('${c.flag} ${c.dialCode}'),
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }
}
