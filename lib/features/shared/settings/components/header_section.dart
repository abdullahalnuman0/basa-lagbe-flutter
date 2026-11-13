import 'package:flutter/material.dart';

import '../../../../core/config.dart';
import '../../../../ui/theme/theme.dart';

class HeaderSection extends StatelessWidget {
  const HeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppConfig.appName.toUpperCase(),
            style: context.typos.labelMedium?.copyWith(color: context.colors.onSurfaceVariant),
          ),
          Text('Settings', style: context.typos.headlineLarge),
        ],
      ),
    );
  }
}
