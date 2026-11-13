import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/di/locator.dart';
import '../../../core/presentation/components/app_icons.dart';
import '../../../core/presentation/components/auth_input_text_field.dart';
import '../../../core/presentation/components/section_card.dart';
import '../../../core/presentation/widgets/page_header.dart';
import '../../../navigation/routes.dart';
import '../../../ui/theme/theme.dart';
import '../auth_event.dart';
import '../otp/otp_screen.dart';
import 'signing_view_model.dart';

class SigningScreen extends StatelessWidget {
  const SigningScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SigningViewModel(locator()),
      child: const _SigningView(),
    );
  }
}

class _SigningView extends StatefulWidget {
  const _SigningView();

  @override
  State<_SigningView> createState() => _SigningViewState();
}

class _SigningViewState extends State<_SigningView> {
  late final StreamSubscription<AuthEvent> _events;

  @override
  void initState() {
    super.initState();
    _events = context.read<SigningViewModel>().events.listen((event) {
      if (event is GoVerify && mounted) context.push(Routes.otp, extra: OtpArgs(event.email));
    });
  }

  @override
  void dispose() {
    _events.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SigningViewModel>();
    final state = vm.state;
    final colors = context.colors;
    final typos = context.typos;

    return Scaffold(
      backgroundColor: context.appColors.background,
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Don't have an account?", style: typos.bodySmall),
              InkWell(
                onTap: () => context.push(Routes.signup),
                borderRadius: BorderRadius.circular(4),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Text(
                    'Sign Up',
                    style: typos.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colors.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            spacing: 16,
            children: [
              const SizedBox(height: 48),
              const HeaderLogo(),
              const PageHeader(
                title: 'Welcome Back',
                subtitle: 'Login to find or rent your perfect home or mess',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              SectionCard(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  AnimatedSize(
                    duration: const Duration(milliseconds: 200),
                    child: state.error == null
                        ? const SizedBox(width: double.infinity)
                        : Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: colors.error,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              state.error ?? 'Something went wrong!!',
                              style: typos.labelMedium?.copyWith(color: colors.onError),
                            ),
                          ),
                  ),
                  AuthInputTextField(
                    value: state.email,
                    onValueChange: vm.onEmailChange,
                    label: 'Email Address',
                    placeholder: 'Enter your email address',
                    icon: const SvgIcon(AppIcons.email),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  AuthInputTextField(
                    value: state.password,
                    onValueChange: vm.onPwdChange,
                    label: 'Password',
                    placeholder: 'Enter your password',
                    isPassword: true,
                    icon: const SvgIcon(AppIcons.lockKeyhole),
                    keyboardType: TextInputType.visiblePassword,
                    textInputAction: TextInputAction.done,
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: InkWell(
                      onTap: () => context.push(Routes.forgetPassword),
                      borderRadius: BorderRadius.circular(4),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        child: Text(
                          'Forget Password?',
                          style: typos.labelLarge?.copyWith(color: colors.primary),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed:
                          !state.isLoading && state.email.isNotEmpty && state.password.isNotEmpty
                          ? vm.login
                          : null,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: Row(
                          key: ValueKey(state.isLoading),
                          mainAxisSize: MainAxisSize.min,
                          spacing: 8,
                          children: [
                            Text(state.isLoading ? 'Logging...' : 'Login'),
                            if (state.isLoading)
                              const SizedBox.square(
                                dimension: 24,
                                child: CircularProgressIndicator(),
                              )
                            else
                              const Icon(Icons.arrow_right_alt, semanticLabel: 'Login'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
