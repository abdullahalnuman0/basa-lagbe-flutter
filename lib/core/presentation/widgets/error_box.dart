import 'package:flutter/material.dart';

import '../../../ui/theme/space.dart';
import '../../../ui/theme/theme.dart';

class ErrorBox extends StatelessWidget {
  const ErrorBox({super.key, required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Space.xxxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(color: colors.errorContainer, shape: BoxShape.circle),
              child: Icon(Icons.cloud_off_outlined, size: 32, color: colors.onErrorContainer),
            ),
            const SizedBox(height: Space.lg),
            Text('Something went wrong', style: context.typos.titleMedium),
            const SizedBox(height: Space.xs),
            Text(
              message,
              style: context.typos.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: Space.xl),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_outlined, size: 18),
                label: const Text('Try again'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
