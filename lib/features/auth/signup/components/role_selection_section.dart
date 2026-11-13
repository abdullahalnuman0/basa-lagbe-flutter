import 'package:flutter/material.dart';

import '../../../../core/config.dart';
import '../../../../core/presentation/components/section_card.dart';
import '../../../../core/presentation/widgets/page_header.dart';
import '../../../../domain/enums/user_role.dart';
import '../../../../ui/theme/theme.dart';

class RoleSelectionSection extends StatelessWidget {
  const RoleSelectionSection({super.key, required this.userRole, required this.onRoleSelected});

  final UserRole? userRole;
  final ValueChanged<UserRole> onRoleSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 4),
          const PageHeader(
            title: 'What are you looking tor?',
            subtitle:
                'Choose how you want to user ${AppConfig.appName} to get the best experience.',
          ),
          const SizedBox(height: 24),
          for (final role in UserRole.values) ...[
            _RoleSelectableCard(
              role: role,
              isSelected: userRole == role,
              onClick: () => onRoleSelected(role),
            ),
            const SizedBox(height: 16),
          ],
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _RoleSelectableCard extends StatelessWidget {
  const _RoleSelectableCard({required this.role, required this.isSelected, required this.onClick});

  final UserRole role;
  final bool isSelected;
  final VoidCallback onClick;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typos = context.typos;
    const duration = Duration(milliseconds: 200);

    return TweenAnimationBuilder<double>(
      tween: Tween(end: isSelected ? 1 : 0),
      duration: duration,
      builder: (context, t, child) => SectionCard(
        contentPadding: EdgeInsets.zero,
        border: BorderSide(
          width: isSelected ? 2 : 1,
          color: Color.lerp(context.appColors.cardBorder, colors.primary, t)!,
        ),
        onClick: onClick,
        children: [child!],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isSelected ? colors.primaryContainer : context.appColors.background,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    role.icon,
                    size: 24,
                    semanticLabel: role.title,
                    color: isSelected ? colors.primary : colors.secondary,
                  ),
                ),
                if (isSelected)
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: colors.primary),
                    child: const Icon(
                      Icons.check,
                      size: 16,
                      color: Colors.white,
                      semanticLabel: 'Selected',
                    ),
                  )
                else
                  const SizedBox.square(dimension: 24),
              ],
            ),
            const SizedBox(height: 16),
            AnimatedOpacity(
              opacity: isSelected ? 1 : 0.5,
              duration: duration,
              child: Text(
                role.subTitle.toUpperCase(),
                style: typos.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  fontSize: 11,
                  color: isSelected ? colors.primary : colors.onSurface,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              role.title,
              style: typos.titleLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const SizedBox(height: 6),
            AnimatedOpacity(
              opacity: isSelected ? 1 : 0.5,
              duration: duration,
              child: Text(
                role.desc,
                style: typos.bodyMedium?.copyWith(fontSize: 14, height: 20 / 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
