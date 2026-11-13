import 'package:flutter/material.dart';

import '../../../ui/theme/theme.dart';

class StepBottomActionBar extends StatelessWidget {
  const StepBottomActionBar({
    super.key,
    required this.primaryBtnText,
    required this.isLoading,
    required this.onPrimaryBtnClick,
    this.suggestBtnHintText = 'Already have an account? ',
    this.suggestBtnText = 'Login',
    this.enabled = true,
    this.showSuggestBtnHint = false,
    this.showBackButton = true,
    this.onBackClick,
    this.onSuggestBtnClick,
  });

  final String primaryBtnText;
  final String suggestBtnHintText;
  final String suggestBtnText;
  final bool enabled;
  final bool showSuggestBtnHint;
  final bool showBackButton;
  final bool isLoading;
  final VoidCallback onPrimaryBtnClick;
  final VoidCallback? onBackClick;
  final VoidCallback? onSuggestBtnClick;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typos = context.typos;
    final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(16));

    return Container(
      width: double.infinity,
      color: context.appColors.background,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              if (showBackButton) ...[
                Expanded(
                  flex: 35,
                  child: SizedBox(
                    height: 56,
                    child: OutlinedButton(
                      onPressed: onBackClick,
                      style: OutlinedButton.styleFrom(shape: shape),
                      child: Text(
                        'Back',
                        style: typos.labelLarge?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                flex: showBackButton ? 65 : 100,
                child: SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: enabled ? onPrimaryBtnClick : null,
                    style: ElevatedButton.styleFrom(
                      shape: shape,
                      backgroundColor: colors.primary,
                      foregroundColor: colors.onPrimary,
                      elevation: 4,
                    ),
                    child: isLoading
                        ? SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(color: colors.onSurface),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(
                                child: Text(
                                  primaryBtnText,
                                  overflow: TextOverflow.ellipsis,
                                  style: typos.labelLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: enabled ? colors.onPrimary : null,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(Icons.arrow_forward, size: 18),
                            ],
                          ),
                  ),
                ),
              ),
            ],
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            child: showSuggestBtnHint
                ? Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(suggestBtnHintText, style: typos.bodySmall),
                        InkWell(
                          onTap: onSuggestBtnClick,
                          borderRadius: BorderRadius.circular(4),
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: Text(
                              suggestBtnText,
                              style: typos.bodySmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colors.primary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}
