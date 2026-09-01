import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';

class AppWizardStepper extends StatelessWidget {
  const AppWizardStepper({
    super.key,
    required this.currentStep,
    required this.steps,
  });

  final int currentStep;
  final List<String> steps;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        border: Border(
          bottom: BorderSide(color: colorScheme.outline),
        ),
      ),
      child: Row(
        children: [
          for (int i = 0; i < steps.length; i++) ...[
            if (i > 0)
              Expanded(
                child: Container(
                  height: 2,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  color: colorScheme.outline,
                ),
              ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: i == currentStep
                          ? const Color(0xFFC2680A) // safetyAmber
                          : colorScheme.surface,
                      border: i == currentStep
                          ? null
                          : Border.all(
                              color: colorScheme.outline,
                              width: 2,
                            ),
                    ),
                    child: Center(
                      child: Text(
                        '${i + 1}',
                        style: textTheme.titleMedium?.copyWith(
                          color: i == currentStep
                              ? colorScheme.onPrimary
                              : colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  if (i == currentStep) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      steps[i],
                      style: textTheme.labelMedium?.copyWith(
                        color: const Color(0xFFC2680A),
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
