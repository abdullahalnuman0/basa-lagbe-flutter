import 'package:flutter/material.dart';

import '../../../ui/theme/space.dart';
import '../../../ui/theme/theme.dart';
import '../components/app_icons.dart';

class AppTopBar extends StatelessWidget {
  const AppTopBar({
    super.key,
    required this.title,
    this.subTitle,
    this.appIcon = false,
    this.onBack,
    this.actions = const [],
    this.content,
  });

  final String title;
  final String? subTitle;
  final bool appIcon;
  final VoidCallback? onBack;
  final List<Widget> actions;
  final Widget? content;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final background = context.appColors.background;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [background, Color.lerp(background, colors.surface, 0.7)!],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.only(
              left: onBack != null ? Space.xs : Space.screen,
              right: Space.sm,
              top: Space.sm,
              bottom: Space.md,
            ),
            child: Row(
              children: [
                if (onBack != null)
                  IconButton(onPressed: onBack, tooltip: 'Back', icon: const Icon(Icons.arrow_back))
                else if (appIcon)
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    width: 32,
                    height: 32,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: colors.primary,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: colors.primary.withValues(alpha: 0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: SvgIcon(AppIcons.logo, size: 20, color: colors.onPrimary),
                  ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: context.typos.titleLarge,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (subTitle != null)
                        Text(
                          subTitle!,
                          style: context.typos.bodySmall?.copyWith(color: colors.onSurfaceVariant),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                for (var i = 0; i < actions.length; i++) ...[
                  if (i > 0) const SizedBox(width: Space.xs),
                  actions[i],
                ],
              ],
            ),
          ),
          ?content,
          Divider(height: 1, thickness: 1, color: Colors.grey.withValues(alpha: 0.2)),
        ],
      ),
    );
  }
}
