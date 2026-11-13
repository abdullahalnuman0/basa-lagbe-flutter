import 'package:flutter/material.dart';

import '../../../ui/theme/space.dart';
import '../../../ui/theme/theme.dart';

Future<void> showDeleteConfirmationDialog(
  BuildContext context, {
  String title = 'Delete Item?',
  String subtitle = 'Are you sure you want to delete this item? This action cannot be undone.',
  String confirmBtn = 'Delete',
  required VoidCallback onConfirm,
  VoidCallback? onDismiss,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) {
      final colors = context.colors;
      return AlertDialog(
        title: Text(title),
        content: Text(subtitle),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          OutlinedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: OutlinedButton.styleFrom(
              foregroundColor: colors.error,
              side: BorderSide(color: colors.error),
            ),
            child: Text(confirmBtn),
          ),
        ],
      );
    },
  );
  if (confirmed == true) {
    onConfirm();
  } else {
    onDismiss?.call();
  }
}

class ErrorBoxMessage extends StatelessWidget {
  const ErrorBoxMessage({super.key, required this.error});

  final String? error;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AnimatedSize(
      duration: const Duration(milliseconds: 200),
      alignment: Alignment.topCenter,
      child: error == null
          ? const SizedBox(width: double.infinity)
          : Container(
              width: double.infinity,
              padding: const EdgeInsets.all(Space.md),
              decoration: BoxDecoration(
                color: colors.errorContainer.withValues(alpha: 0.1),
                border: Border.all(color: colors.error, width: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, size: 16, color: colors.error),
                  const SizedBox(width: Space.md),
                  Expanded(
                    child: Text(
                      error!,
                      style: context.typos.labelMedium?.copyWith(color: colors.error),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class InlineMessage extends StatelessWidget {
  const InlineMessage({super.key, required this.message, this.isError, this.color});

  final String? message;
  final bool? isError;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textColor =
        color ??
        switch (isError) {
          null => colors.onSurface,
          true => colors.error,
          false => colors.primary,
        };
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 150),
      child: message == null
          ? const SizedBox.shrink()
          : Padding(
              key: ValueKey(message),
              padding: const EdgeInsets.only(left: 4, top: 4),
              child: Text(
                message!,
                style: context.typos.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              ),
            ),
    );
  }
}
