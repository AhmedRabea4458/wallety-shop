import 'package:flutter/material.dart';
import 'package:smart_expense/core/theme/app_colors.dart';
import 'package:smart_expense/core/theme/app_spacing.dart';

class OnboardingIndicator extends StatelessWidget {
  final int currentIndex;
  final int totalPages;

  const OnboardingIndicator({
    super.key,
    required this.currentIndex,
    required this.totalPages,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        totalPages,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(
            horizontal: AppSpacing.space1,
          ),
          width: index == currentIndex ? 32 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: index == currentIndex
                ? AppColors.primary
                : AppColors.withAlpha(AppColors.mutedForeground, 0.3),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}
