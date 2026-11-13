import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/di/locator.dart';
import '../../../core/presentation/components/snackbar.dart';
import '../../../core/presentation/components/step_animated_content.dart';
import '../../../core/presentation/widgets/step_bottom_action_bar.dart';
import '../../../navigation/routes.dart';
import '../../../ui/theme/theme.dart';
import '../auth_event.dart';
import 'components/about_you_section.dart';
import 'components/basic_info_section.dart';
import 'components/location_section.dart';
import 'components/role_selection_section.dart';
import 'components/security_section.dart';
import 'components/signup_top_bar.dart';
import 'signup_step.dart';
import 'signup_view_model.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SignupViewModel(locator()),
      child: const _SignupView(),
    );
  }
}

class _SignupView extends StatefulWidget {
  const _SignupView();

  @override
  State<_SignupView> createState() => _SignupViewState();
}

class _SignupViewState extends State<_SignupView> {
  late final StreamSubscription<AuthEvent> _events;

  @override
  void initState() {
    super.initState();
    _events = context.read<SignupViewModel>().events.listen(_onEvent);
  }

  @override
  void dispose() {
    _events.cancel();
    super.dispose();
  }

  void _onEvent(AuthEvent event) {
    if (!mounted) return;
    switch (event) {
      case GoVerify(:final email):
        context.pushReplacement(Routes.otp, extra: OtpArgs(email));
      case Toast(:final message):
        AppSnackbar.showWithAction(message);
      default:
        context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SignupViewModel>();
    final state = vm.state;
    final step = state.currentStep;

    return PopScope(
      canPop: step == SignupStep.roleSelection,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) vm.onGoBack();
      },
      child: Scaffold(
        backgroundColor: context.appColors.background,
        bottomNavigationBar: SafeArea(
          top: false,
          child: StepBottomActionBar(
            primaryBtnText: step == SignupStep.security ? 'Create Account' : 'Continue',
            enabled: state.selectedRole != null,
            isLoading: state.isLoading,
            showSuggestBtnHint: step == SignupStep.roleSelection,
            showBackButton: step != SignupStep.roleSelection,
            onPrimaryBtnClick: vm.onGoNext,
            onBackClick: vm.onGoBack,
            onSuggestBtnClick: () => context.pop(),
          ),
        ),
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: SignupTopBar(
                  currentStep: step,
                  userRole: state.selectedRole,
                  onBackClick: vm.onGoBack,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: StepAnimatedContent(
                    targetState: step,
                    forward: state.isNavigatingForward,
                    builder: (context, step) => switch (step) {
                      SignupStep.roleSelection => RoleSelectionSection(
                        userRole: state.selectedRole,
                        onRoleSelected: vm.onRoleSelected,
                      ),
                      SignupStep.basicInfo => BasicInfoSection(
                        state: state,
                        onFullNameChange: vm.onFullNameChange,
                        onEmailChange: vm.onEmailChange,
                        onPhoneChange: vm.onPhoneChange,
                      ),
                      SignupStep.aboutYou => AboutYouSection(
                        state: state,
                        onGenderSelected: vm.onGenderSelected,
                        onInstitutionChange: vm.onInstitutionChange,
                        onInstitutionNotListedToggle: vm.onInstitutionNotListedToggle,
                      ),
                      SignupStep.location => LocationSection(
                        state: state,
                        onDivisionSelected: vm.onDivisionSelected,
                        onDistrictSelected: vm.onDistrictSelected,
                        onAreaSelected: vm.onAreaSelected,
                      ),
                      SignupStep.security => SecuritySection(
                        state: state,
                        onPasswordChange: vm.onPasswordChange,
                        onConfirmPassChange: vm.onConfirmPassChange,
                        onTermsToggle: vm.onTermsToggle,
                      ),
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
