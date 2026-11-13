import 'package:flutter/material.dart';

import '../../../../core/presentation/components/app_icons.dart';
import '../../../../core/presentation/components/auth_input_text_field.dart';
import '../../../../core/presentation/widgets/page_header.dart';
import '../signup_ui_state.dart';

class BasicInfoSection extends StatelessWidget {
  const BasicInfoSection({
    super.key,
    required this.state,
    required this.onFullNameChange,
    required this.onEmailChange,
    required this.onPhoneChange,
  });

  final SignupUiState state;
  final ValueChanged<String> onFullNameChange;
  final ValueChanged<String> onEmailChange;
  final ValueChanged<String> onPhoneChange;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 4),
          const PageHeader(
            title: "Let's get started",
            subtitle: 'Tell us a little about yourself to create your account.',
          ),
          const SizedBox(height: 24),
          AuthInputTextField(
            value: state.fullName,
            error: state.fullNameError,
            onValueChange: onFullNameChange,
            label: 'Full Name',
            placeholder: 'Enter your full name',
            icon: const SvgIcon(AppIcons.user),
            keyboardType: TextInputType.name,
          ),
          const SizedBox(height: 16),
          AuthInputTextField(
            value: state.email,
            error: state.emailError,
            onValueChange: onEmailChange,
            label: 'Email Address',
            placeholder: 'Enter your email address',
            icon: const SvgIcon(AppIcons.email),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          AuthInputTextField(
            value: state.phone,
            error: state.phoneError,
            onValueChange: onPhoneChange,
            label: 'Phone Number',
            placeholder: '01XXXXXXXXX',
            icon: const SvgIcon(AppIcons.phone),
            isPhone: true,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.done,
          ),
        ],
      ),
    );
  }
}
