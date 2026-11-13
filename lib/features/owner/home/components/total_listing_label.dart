import 'package:flutter/material.dart';

import '../../../../ui/theme/theme.dart';

class TotalListingLabel extends StatelessWidget {
  const TotalListingLabel({super.key, required this.total});

  final int total;

  @override
  Widget build(BuildContext context) {
    final typos = context.typos;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Your Rooms', style: typos.headlineSmall?.copyWith(fontWeight: FontWeight.normal)),
        Text(
          '$total total',
          style: typos.bodyLarge?.copyWith(color: context.colors.onSurface.withValues(alpha: 0.5)),
        ),
      ],
    );
  }
}
