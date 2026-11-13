import 'package:flutter/material.dart';

import '../../../../ui/theme/theme.dart';

class NearByLabel extends StatelessWidget {
  const NearByLabel({super.key, required this.onSearch});

  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: Text('Nearby rooms', style: context.typos.headlineMedium)),
        TextButton(
          onPressed: onSearch,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'See all',
                style: context.typos.labelMedium?.copyWith(color: context.colors.primary),
              ),
              const Icon(Icons.arrow_right_alt, size: 20, semanticLabel: 'See all'),
            ],
          ),
        ),
      ],
    );
  }
}
