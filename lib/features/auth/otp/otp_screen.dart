import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/config.dart';
import '../../../core/di/locator.dart';
import '../../../core/presentation/components/app_icons.dart';
import '../../../core/presentation/components/snackbar.dart';
import '../../../ui/theme/theme.dart';
import '../auth_event.dart';
import 'otp_view_model.dart';

class OtpScreen extends StatelessWidget {
  const OtpScreen({super.key, required this.email, required this.recover});

  final String email;
  final bool recover;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => OtpViewModel(locator()),
      child: _OtpView(email: email, recover: recover),
    );
  }
}

class _OtpView extends StatefulWidget {
  const _OtpView({required this.email, required this.recover});

  final String email;
  final bool recover;

  @override
  State<_OtpView> createState() => _OtpViewState();
}

class _OtpViewState extends State<_OtpView> {
  late final OtpViewModel _viewModel = context.read<OtpViewModel>();
  late final StreamSubscription<AuthEvent> _events;

  @override
  void initState() {
    super.initState();
    _events = _viewModel.events.listen((event) {
      if (event is Toast) AppSnackbar.showWithAction(event.message);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _viewModel.state.resendCount < 1) {
        _viewModel.resend(widget.email, widget.recover);
      }
    });
  }

  @override
  void dispose() {
    _events.cancel();
    super.dispose();
  }

  String get _maskedEmail {
    final email = widget.email;
    final start = email.length < 2 ? email : email.substring(0, 2);
    final at = email.indexOf('@');
    final domain = at == -1 ? email : email.substring(at + 1);
    return '$start...@$domain';
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<OtpViewModel>();
    final state = vm.state;
    final colors = context.colors;
    final typos = context.typos;
    final cooldown = state.resendCooldown;

    return Scaffold(
      backgroundColor: context.appColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight - 48),
              child: Center(
                child: Card(
                  margin: EdgeInsets.zero,
                  elevation: 1,
                  color: colors.surface,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      spacing: 16,
                      children: [
                        const HeaderLogo(),
                        HeaderText(
                          title: widget.recover ? 'Restore your account' : 'Verify your account',
                          subTitle:
                              'Enter the 6-diggit code sent to ($_maskedEmail). '
                              'Please check your inbox or spam folder.',
                        ),
                        OtpInputField(onOtpChange: vm.onOtpChange),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: state.otp.length == 6 && !state.isLoading
                                ? () {
                                    FocusScope.of(context).unfocus();
                                    vm.verifyOtp(widget.email, widget.recover);
                                  }
                                : null,
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 250),
                              child: Row(
                                key: ValueKey(state.isLoading),
                                mainAxisSize: MainAxisSize.min,
                                spacing: 8,
                                children: [
                                  Text(
                                    state.isLoading
                                        ? (state.isSending ? 'Sending...' : 'Verifying...')
                                        : (widget.recover ? 'Restore account' : 'Verify OTP'),
                                  ),
                                  if (state.isLoading)
                                    const SizedBox.square(
                                      dimension: 24,
                                      child: CircularProgressIndicator(),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          spacing: 4,
                          children: [
                            Text("Don't receive code?", style: typos.labelMedium),
                            InkWell(
                              onTap: state.isResendCount || state.isLoading
                                  ? null
                                  : () => vm.resend(widget.email, widget.recover),
                              child: Text(
                                state.isResendCount
                                    ? 'Resend in ${cooldown ~/ 60}:'
                                          '${(cooldown % 60).toString().padLeft(2, '0')}'
                                    : 'Resend OTP',
                                style: typos.labelMedium?.copyWith(
                                  fontWeight: state.isResendCount
                                      ? FontWeight.normal
                                      : FontWeight.bold,
                                  color: state.isResendCount ? null : colors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class OtpInputField extends StatefulWidget {
  const OtpInputField({super.key, required this.onOtpChange, this.length = 6});

  final ValueChanged<String> onOtpChange;
  final int length;

  @override
  State<OtpInputField> createState() => _OtpInputFieldState();
}

class _OtpInputFieldState extends State<OtpInputField> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() => setState(() {}));
    _controller.addListener(_keepCursorAtEnd);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _keepCursorAtEnd() {
    final end = _controller.text.length;
    final selection = _controller.selection;
    if (!selection.isCollapsed || selection.baseOffset != end) {
      _controller.selection = TextSelection.collapsed(offset: end);
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = _controller.text;
    final active = _focusNode.hasFocus ? text.length.clamp(0, widget.length - 1) : -1;

    return SizedBox(
      height: 56,
      child: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0,
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                keyboardType: TextInputType.number,
                autofillHints: const [AutofillHints.oneTimeCode],
                showCursor: false,
                enableInteractiveSelection: false,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(widget.length),
                ],
                decoration: const InputDecoration(border: InputBorder.none, counterText: ''),
                onChanged: (value) {
                  setState(() {});
                  widget.onOtpChange(value);
                },
              ),
            ),
          ),
          IgnorePointer(
            child: Row(
              spacing: 8,
              children: [
                for (var i = 0; i < widget.length; i++)
                  Expanded(
                    child: _OtpDigit(digit: i < text.length ? text[i] : '', focused: i == active),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OtpDigit extends StatelessWidget {
  const _OtpDigit({required this.digit, required this.focused});

  final String digit;
  final bool focused;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      height: 56,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          width: focused ? 2 : 1,
          color: focused ? colors.primary : colors.onSurface.withValues(alpha: 0.5),
        ),
      ),
      child: Text(
        digit,
        style: context.typos.bodyLarge?.copyWith(
          fontSize: 21,
          color: focused ? colors.primary : colors.onSurface.withValues(alpha: 0.7),
        ),
      ),
    );
  }
}

class HeaderText extends StatelessWidget {
  const HeaderText({super.key, required this.title, required this.subTitle});

  final String title;
  final String subTitle;

  @override
  Widget build(BuildContext context) {
    final typos = context.typos;
    return SizedBox(
      width: double.infinity,
      child: Column(
        children: [
          Text(title, style: typos.headlineLarge, textAlign: TextAlign.center),
          const SizedBox(height: 4),
          Opacity(
            opacity: 0.5,
            child: Text(subTitle, style: typos.labelMedium, textAlign: TextAlign.center),
          ),
        ],
      ),
    );
  }
}

class HeaderLogo extends StatelessWidget {
  const HeaderLogo({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 4,
      children: [
        Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colors.primary,
            boxShadow: [BoxShadow(color: colors.primary.withValues(alpha: 0.3), blurRadius: 4)],
          ),
          child: SvgIcon(
            AppIcons.logo,
            size: 24,
            color: colors.onPrimary,
            semanticLabel: '${AppConfig.appName} Logo',
          ),
        ),
        Text(
          AppConfig.appName,
          style: context.typos.titleLarge?.copyWith(
            fontWeight: FontWeight.w500,
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }
}
