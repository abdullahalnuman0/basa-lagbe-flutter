import 'package:flutter/material.dart';

import '../../../ui/theme/theme.dart';

abstract interface class ProgressStep {
  String get label;
}

class StepProgressIndicator<T extends ProgressStep> extends StatelessWidget {
  const StepProgressIndicator({
    super.key,
    required this.currentStep,
    required this.steps,
    this.hiddenStepCount = 0,
  });

  final T currentStep;
  final List<T> steps;
  final int hiddenStepCount;

  @override
  Widget build(BuildContext context) {
    final currentIndex = steps.indexOf(currentStep);
    final totalSteps = steps.length + hiddenStepCount;
    if (currentIndex == -1 || totalSteps == 0) return const SizedBox.shrink();

    final colors = context.colors;
    final typos = context.typos;
    final currentStepNumber = currentIndex + 1 + hiddenStepCount;
    final idle = colors.onSurface.withValues(alpha: 0.5);
    const duration = Duration(milliseconds: 300);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Step $currentStepNumber of $totalSteps',
              style: typos.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colors.primary,
              ),
            ),
            if (currentStep.label.isNotEmpty)
              Text(
                currentStep.label,
                style: typos.labelSmall?.copyWith(
                  color: idle,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.4,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        // --- progress nodes ---
        Row(
          children: [
            for (var i = 0; i < steps.length; i++) ...[
              AnimatedContainer(
                duration: duration,
                width: i == currentIndex ? 12 : 8,
                height: i == currentIndex ? 12 : 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i <= currentIndex ? colors.primary : idle,
                  border: i == currentIndex
                      ? Border.all(color: colors.primaryContainer, width: 2)
                      : null,
                ),
              ),
              if (i < steps.length - 1)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: Container(
                        height: 3,
                        color: idle,
                        alignment: Alignment.centerLeft,
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(end: i < currentIndex ? 1 : 0),
                          duration: duration,
                          builder: (context, value, _) => FractionallySizedBox(
                            widthFactor: value,
                            child: Container(height: 3, color: colors.primary),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ],
        ),
      ],
    );
  }
}
