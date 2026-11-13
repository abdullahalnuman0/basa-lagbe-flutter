import 'package:flutter/material.dart';

import '../../../../core/config.dart';
import '../../../../core/presentation/components/app_icons.dart';
import '../../../../core/presentation/widgets/step_progress_indicator.dart';
import '../../../../domain/enums/user_role.dart';
import '../../../../ui/theme/theme.dart';
import '../signup_step.dart';

class SignupTopBar extends StatelessWidget {
  const SignupTopBar({
    super.key,
    this.currentStep = SignupStep.roleSelection,
    this.userRole,
    this.onBackClick,
  });

  final SignupStep currentStep;
  final UserRole? userRole;
  final VoidCallback? onBackClick;

  @override
  Widget build(BuildContext context) {
    final showProgress = SignupStep.progressSteps.contains(currentStep);
    const duration = Duration(milliseconds: 250);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AnimatedSwitcher(
              duration: duration,
              child: currentStep == SignupStep.roleSelection
                  ? const _AppBrand(key: ValueKey('brand'))
                  : SizedBox.square(
                      key: const ValueKey('back'),
                      dimension: 42,
                      child: IconButton(
                        onPressed: onBackClick,
                        tooltip: 'Back',
                        iconSize: 20,
                        icon: const Icon(Icons.arrow_back),
                      ),
                    ),
            ),
            AnimatedSwitcher(
              duration: duration,
              child: userRole != null && showProgress
                  ? _RoleContextPill(role: userRole!)
                  : const SizedBox.shrink(),
            ),
          ],
        ),
        AnimatedSize(
          duration: duration,
          alignment: Alignment.topCenter,
          child: showProgress
              ? Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: StepProgressIndicator(
                    currentStep: currentStep,
                    steps: SignupStep.progressSteps,
                    hiddenStepCount: 1,
                  ),
                )
              : const SizedBox(width: double.infinity),
        ),
      ],
    );
  }
}

class _AppBrand extends StatelessWidget {
  const _AppBrand({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 8,
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colors.primary,
              borderRadius: BorderRadius.circular(12),
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
              fontWeight: FontWeight.bold,
              letterSpacing: -0.3,
              fontSize: 21,
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleContextPill extends StatelessWidget {
  const _RoleContextPill({required this.role});

  final UserRole role;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final (icon, text) = role == UserRole.OWNER
        ? (Icons.storefront_outlined, 'Owner / Manager')
        : (Icons.person_outline, 'Tenant / Mess');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.primary.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 4,
        children: [
          Icon(icon, size: 14, color: colors.primary, semanticLabel: role.title),
          Text(
            text,
            style: context.typos.labelSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colors.primary,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
