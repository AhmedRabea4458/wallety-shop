import 'package:flutter/material.dart';
import 'package:smart_expense/core/theme/app_colors.dart';
import 'package:smart_expense/core/theme/app_radius.dart';
import 'package:smart_expense/core/theme/app_spacing.dart';
import 'package:smart_expense/core/theme/app_text_styles.dart';

class OnboardingButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;

  const OnboardingButton({
    super.key,
    required this.text,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          child: Container(
            padding: const EdgeInsets.symmetric(
              vertical: AppSpacing.space4,
            ),
            decoration: BoxDecoration(
              gradient: AppColors.ctaGradientLinear,
              borderRadius: BorderRadius.circular(AppRadius.xl),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.fabGlow,
                  blurRadius: 20,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Center(
              child: Text(
                text,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.primaryForeground,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
