import 'package:flutter/material.dart';

import '../../../ui/theme/theme.dart';

class SectionCard extends StatelessWidget {
  const SectionCard({
    super.key,
    this.contentPadding = const EdgeInsets.all(20),
    this.border,
    this.onClick,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    required this.children,
  });

  final EdgeInsetsGeometry contentPadding;
  final BorderSide? border;
  final VoidCallback? onClick;
  final CrossAxisAlignment crossAxisAlignment;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: border ?? BorderSide(color: context.appColors.cardBorder),
    );
    final body = Padding(
      padding: contentPadding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: crossAxisAlignment,
        children: children,
      ),
    );
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: context.colors.surface,
        shape: shape,
        clipBehavior: Clip.antiAlias,
        child: onClick == null ? body : InkWell(onTap: onClick, child: body),
      ),
    );
  }
}

class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key, this.action});

  final String text;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Expanded(
            child: Semantics(
              header: true,
              child: Text(
                text,
                style: context.typos.titleMedium?.copyWith(color: context.colors.onSurface),
              ),
            ),
          ),
          ?action,
        ],
      ),
    );
  }
}
