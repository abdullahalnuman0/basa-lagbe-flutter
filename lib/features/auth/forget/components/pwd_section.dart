import 'package:flutter/material.dart';

import '../../../../core/presentation/components/app_icons.dart';
import '../../../../core/presentation/components/auth_input_text_field.dart';
import '../../../../core/presentation/widgets/page_header.dart';
import '../../../../ui/theme/theme.dart';
import '../../otp/otp_screen.dart';
import '../../signup/components/security_section.dart';
import '../forget_pwd_ui_state.dart';

class PwdSection extends StatelessWidget {
  const PwdSection({
    super.key,
    required this.state,
    required this.onChangeEmail,
    required this.onOtpChange,
    required this.onPasswordChange,
  });

  final ForgetPwdUiState state;
  final VoidCallback onChangeEmail;
  final ValueChanged<String> onOtpChange;
  final ValueChanged<String> onPasswordChange;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 48),
          const PageHeader(
            title: 'Verify & Set Your Password',
            subtitle:
                'Enter the 6-digit code sent to your email and create a strong password for '
                'your account.',
          ),
          const SizedBox(height: 24),
          _EmailCard(email: state.email, onChangeEmail: onChangeEmail),
          const SizedBox(height: 24),
          Text(
            'Enter you OTP',
            style: context.typos.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: OtpInputField(onOtpChange: onOtpChange),
          ),
          const SizedBox(height: 16),
          AuthInputTextField(
            value: state.password,
            error: state.passwordError,
            onValueChange: onPasswordChange,
            label: 'Password',
            placeholder: 'Create a password',
            isPassword: true,
            icon: const SvgIcon(AppIcons.lockKeyhole),
            keyboardType: TextInputType.visiblePassword,
            textInputAction: TextInputAction.done,
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            alignment: Alignment.topCenter,
            child: state.password.isNotEmpty
                ? PasswordStrengthCard(strength: state.strength)
                : const SizedBox(width: double.infinity),
          ),
          const SizedBox(height: 12),
          PasswordRequirementCard(passwordRequirements: state.passwordRequirements),
        ],
      ),
    );
  }
}

class _EmailCard extends StatelessWidget {
  const _EmailCard({required this.email, required this.onChangeEmail});

  final String email;
  final VoidCallback onChangeEmail;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typos = context.typos;
    final at = email.indexOf('@');
    final domain = at == -1 ? email : email.substring(at + 1);

    Widget dot() => Container(
      width: 4,
      height: 4,
      decoration: BoxDecoration(color: colors.onSurface, shape: BoxShape.circle),
    );

    return Card(
      margin: EdgeInsets.zero,
      elevation: 1,
      color: Color.lerp(colors.surface, colors.primary, 0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Flexible(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgIcon(
                    AppIcons.email,
                    size: 24,
                    color: colors.onSurface,
                    semanticLabel: 'Email',
                  ),
                  const SizedBox(width: 4),
                  Text(email.isEmpty ? '' : email[0], style: typos.labelLarge),
                  for (var i = 0; i < 5; i++) ...[dot(), const SizedBox(width: 2)],
                  Flexible(
                    child: Text(
                      '@$domain',
                      style: typos.labelLarge,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            dot(),
            InkWell(
              onTap: onChangeEmail,
              borderRadius: BorderRadius.circular(4),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Text(
                  'Change email',
                  style: typos.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colors.primary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
