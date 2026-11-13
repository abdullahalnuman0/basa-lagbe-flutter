import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../../../core/presentation/components/app_icons.dart';
import '../../../../core/presentation/components/auth_input_text_field.dart';
import '../../../../core/presentation/components/messages.dart';
import '../../../../core/presentation/widgets/page_header.dart';
import '../../../../ui/theme/theme.dart';
import '../password_requirements.dart';
import '../password_strength.dart';
import '../signup_ui_state.dart';

class SecuritySection extends StatelessWidget {
  const SecuritySection({
    super.key,
    required this.state,
    required this.onPasswordChange,
    required this.onConfirmPassChange,
    required this.onTermsToggle,
  });

  final SignupUiState state;
  final ValueChanged<String> onPasswordChange;
  final ValueChanged<String> onConfirmPassChange;
  final ValueChanged<bool> onTermsToggle;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 4),
          const PageHeader(
            title: 'Secure your account',
            subtitle: 'Create a strong password to protect yur account and data.',
          ),
          const SizedBox(height: 24),
          AuthInputTextField(
            value: state.password,
            error: state.passwordError,
            onValueChange: onPasswordChange,
            label: 'Password',
            placeholder: 'Create a password',
            isPassword: true,
            icon: const SvgIcon(AppIcons.lockKeyhole),
            keyboardType: TextInputType.visiblePassword,
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
          const SizedBox(height: 16),
          AuthInputTextField(
            value: state.confirmPassword,
            error: state.confirmPasswordError,
            onValueChange: onConfirmPassChange,
            label: 'Confirm Password',
            placeholder: 'Confirm your password',
            isPassword: true,
            icon: const SvgIcon(AppIcons.lockKeyhole),
            keyboardType: TextInputType.visiblePassword,
            textInputAction: TextInputAction.done,
          ),
          const SizedBox(height: 16),
          _TermsConditionOption(
            checked: state.isAcceptTermsAndCondition,
            error: state.termsError,
            onCheckedChange: onTermsToggle,
          ),
        ],
      ),
    );
  }
}

class _TermsConditionOption extends StatelessWidget {
  const _TermsConditionOption({
    required this.checked,
    required this.error,
    required this.onCheckedChange,
  });

  final bool checked;
  final String? error;
  final ValueChanged<bool> onCheckedChange;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Checkbox(value: checked, onChanged: (value) => onCheckedChange(value ?? false)),
            Expanded(
              child: PolicyLinkText(
                text: 'I accept the Terms & Conditions and Privacy Policy.',
                links: const [
                  PolicyLink('Terms & Conditions', 'terms'),
                  PolicyLink('Privacy Policy', 'privacy'),
                ],
                onOpen: (_) {},
                style: context.typos.bodySmall,
              ),
            ),
          ],
        ),
        InlineMessage(message: error, isError: true),
      ],
    );
  }
}

class PolicyLink {
  const PolicyLink(this.text, this.slug);

  final String text;
  final String slug;
}

/// Renders [text] with each [links] phrase underlined and tappable.
class PolicyLinkText extends StatefulWidget {
  const PolicyLinkText({
    super.key,
    required this.text,
    required this.links,
    required this.onOpen,
    this.style,
  });

  final String text;
  final List<PolicyLink> links;
  final ValueChanged<String> onOpen;
  final TextStyle? style;

  @override
  State<PolicyLinkText> createState() => _PolicyLinkTextState();
}

class _PolicyLinkTextState extends State<PolicyLinkText> {
  final _recognizers = <TapGestureRecognizer>[];

  @override
  void dispose() {
    _disposeRecognizers();
    super.dispose();
  }

  void _disposeRecognizers() {
    for (final r in _recognizers) {
      r.dispose();
    }
    _recognizers.clear();
  }

  List<InlineSpan> _buildSpans(TextStyle linkStyle) {
    _disposeRecognizers();
    final text = widget.text;
    final spans = <InlineSpan>[];
    var cursor = 0;

    // walk the sentence, emitting plain runs and linked phrases in order
    while (cursor < text.length) {
      (int, PolicyLink)? next;
      for (final link in widget.links) {
        final at = text.indexOf(link.text, cursor);
        if (at >= 0 && (next == null || at < next.$1)) next = (at, link);
      }

      if (next == null) {
        spans.add(TextSpan(text: text.substring(cursor)));
        break;
      }

      final (at, link) = next;
      if (at > cursor) spans.add(TextSpan(text: text.substring(cursor, at)));
      final recognizer = TapGestureRecognizer()..onTap = () => widget.onOpen(link.slug);
      _recognizers.add(recognizer);
      spans.add(TextSpan(text: link.text, style: linkStyle, recognizer: recognizer));
      cursor = at + link.text.length;
    }
    return spans;
  }

  @override
  Widget build(BuildContext context) {
    final linkStyle = TextStyle(
      color: context.colors.primary,
      fontWeight: FontWeight.w600,
      decoration: TextDecoration.underline,
    );
    return Text.rich(TextSpan(children: _buildSpans(linkStyle)), style: widget.style);
  }
}

class PasswordStrengthCard extends StatelessWidget {
  const PasswordStrengthCard({super.key, required this.strength});

  final PasswordStrength strength;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typos = context.typos;

    return TweenAnimationBuilder<double>(
      tween: Tween(end: strength.score),
      duration: const Duration(milliseconds: 250),
      builder: (context, progress, _) {
        final barColor = strength == PasswordStrength.empty
            ? colors.onSurface
            : Color.lerp(colors.error, colors.primary, progress)!;

        return Column(
          children: [
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Strength',
                  style: typos.labelSmall?.copyWith(color: colors.onSurface.withValues(alpha: 0.7)),
                ),
                Text(
                  strength.label,
                  style: typos.labelSmall?.copyWith(fontWeight: FontWeight.bold, color: barColor),
                ),
              ],
            ),
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: Container(
                height: 4,
                color: colors.onSurface.withValues(alpha: 0.15),
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: progress.clamp(0.0, 1.0),
                  child: Container(color: barColor),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class PasswordRequirementCard extends StatelessWidget {
  const PasswordRequirementCard({super.key, required this.passwordRequirements});

  final PasswordRequirements passwordRequirements;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: colors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8,
          children: [
            Text(
              'Password requirements:',
              style: context.typos.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colors.onSurface.withValues(alpha: 0.7),
              ),
            ),
            _RequirementItem(
              label: 'At least 8 characters',
              isMet: passwordRequirements.hasMinLength,
            ),
            _RequirementItem(
              label: 'One uppercase letter',
              isMet: passwordRequirements.hasUppercase,
            ),
            _RequirementItem(label: 'One number', isMet: passwordRequirements.hasNumber),
            _RequirementItem(
              label: 'One spacial charter',
              isMet: passwordRequirements.hasSpacialChar,
            ),
          ],
        ),
      ),
    );
  }
}

class _RequirementItem extends StatelessWidget {
  const _RequirementItem({required this.label, required this.isMet});

  final String label;
  final bool isMet;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    const duration = Duration(milliseconds: 200);
    final idle = colors.onSurface.withValues(alpha: 0.5);

    return Row(
      children: [
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isMet ? colors.primary.withValues(alpha: 0.15) : Colors.transparent,
          ),
          child: TweenAnimationBuilder<Color?>(
            tween: ColorTween(end: isMet ? colors.primary : idle),
            duration: duration,
            builder: (context, color, _) => Icon(
              isMet ? Icons.check : Icons.radio_button_unchecked_outlined,
              size: 14,
              color: color,
            ),
          ),
        ),
        const SizedBox(width: 8),
        AnimatedDefaultTextStyle(
          duration: duration,
          style: context.typos.bodySmall!.copyWith(
            fontWeight: isMet ? FontWeight.w600 : FontWeight.normal,
            color: isMet ? colors.onSurface : idle,
          ),
          child: Text(label),
        ),
      ],
    );
  }
}
