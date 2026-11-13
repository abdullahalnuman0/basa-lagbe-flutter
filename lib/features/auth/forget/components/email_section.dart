import 'package:flutter/material.dart';

import '../../../../core/presentation/components/app_icons.dart';
import '../../../../core/presentation/components/auth_input_text_field.dart';
import '../../../../core/presentation/widgets/page_header.dart';
import '../forget_pwd_ui_state.dart';

class EmailSection extends StatelessWidget {
  const EmailSection({super.key, required this.state, required this.onEmailChange});

  final ForgetPwdUiState state;
  final ValueChanged<String> onEmailChange;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 48),
          const PageHeader(
            title: 'Forget Password',
            subtitle:
                "Enter the email address linked to yur account and we'll send you a "
                'verification code',
          ),
          const SizedBox(height: 24),
          AuthInputTextField(
            value: state.email,
            error: state.emailError,
            onValueChange: onEmailChange,
            label: 'Email Address',
            placeholder: 'Enter your email address',
            icon: const SvgIcon(AppIcons.email),
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
          ),
        ],
      ),
    );
  }
}
