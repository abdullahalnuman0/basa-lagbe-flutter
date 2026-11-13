import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/di/locator.dart';
import '../../../core/presentation/components/snackbar.dart';
import '../../../core/presentation/components/step_animated_content.dart';
import '../../../core/presentation/widgets/step_bottom_action_bar.dart';
import '../../../ui/theme/theme.dart';
import '../auth_event.dart';
import '../signup/components/signup_top_bar.dart';
import 'components/email_section.dart';
import 'components/pwd_section.dart';
import 'forget_pwd_step.dart';
import 'forget_pwd_view_model.dart';

class ForgetPwdScreen extends StatelessWidget {
  const ForgetPwdScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ForgetPwdViewModel(locator()),
      child: const _ForgetPwdView(),
    );
  }
}

class _ForgetPwdView extends StatefulWidget {
  const _ForgetPwdView();

  @override
  State<_ForgetPwdView> createState() => _ForgetPwdViewState();
}

class _ForgetPwdViewState extends State<_ForgetPwdView> {
  late final StreamSubscription<AuthEvent> _events;

  @override
  void initState() {
    super.initState();
    _events = context.read<ForgetPwdViewModel>().events.listen((event) {
      if (!mounted) return;
      switch (event) {
        case GoLogin():
          context.pop();
        case Toast(:final message):
          AppSnackbar.show(message, withDismissAction: true);
        default:
          break;
      }
    });
  }

  @override
  void dispose() {
    _events.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ForgetPwdViewModel>();
    final state = vm.state;
    final onEmailStep = state.currentStep == ForgetPwdStep.email;

    return PopScope(
      canPop: onEmailStep,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) vm.onGoBack();
      },
      child: Scaffold(
        backgroundColor: context.appColors.background,
        bottomNavigationBar: SafeArea(
          top: false,
          child: StepBottomActionBar(
            primaryBtnText: onEmailStep ? 'Send Verification Code' : 'Reset Password',
            isLoading: state.isLoading,
            enabled: state.email.isNotEmpty,
            suggestBtnHintText: 'Remember your password? ',
            showSuggestBtnHint: onEmailStep,
            showBackButton: !onEmailStep,
            onPrimaryBtnClick: vm.onGoNext,
            onBackClick: vm.onGoBack,
            onSuggestBtnClick: () => context.pop(),
          ),
        ),
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              const Padding(padding: EdgeInsets.fromLTRB(16, 0, 16, 8), child: SignupTopBar()),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: StepAnimatedContent(
                    targetState: state.currentStep,
                    forward: state.isNavForward,
                    builder: (context, step) => switch (step) {
                      ForgetPwdStep.email => EmailSection(
                        state: state,
                        onEmailChange: vm.onEmailChange,
                      ),
                      ForgetPwdStep.password => PwdSection(
                        state: state,
                        onChangeEmail: vm.changeEmail,
                        onOtpChange: vm.onOtpChange,
                        onPasswordChange: vm.onPasswordChange,
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
