import 'package:flutter/material.dart';

import '../../../ui/theme/theme.dart';

class PageHeader extends StatelessWidget {
  const PageHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.titleStyle,
    this.subtitleStyle,
    this.textAlign,
  });

  final String title;
  final String subtitle;
  final TextStyle? titleStyle;
  final TextStyle? subtitleStyle;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    final typos = context.typos;
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: switch (textAlign) {
          TextAlign.center => CrossAxisAlignment.center,
          TextAlign.end || TextAlign.right => CrossAxisAlignment.end,
          _ => CrossAxisAlignment.start,
        },
        children: [
          Text(
            title,
            textAlign: textAlign,
            style:
                titleStyle ??
                typos.headlineLarge?.copyWith(fontWeight: FontWeight.w800, height: 36 / 30),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: textAlign,
            style: subtitleStyle ?? typos.bodyMedium?.copyWith(fontSize: 15, height: 22 / 15),
          ),
        ],
      ),
    );
  }
}
