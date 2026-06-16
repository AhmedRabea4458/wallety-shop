import 'package:flutter/material.dart';
import 'package:smart_expense/core/theme/app_colors.dart';
import 'package:smart_expense/core/theme/app_radius.dart';
import 'package:smart_expense/core/theme/app_spacing.dart';

class OnboardingIllustration extends StatelessWidget {
  final int pageNumber;
  final IconData icon;

  const OnboardingIllustration({
    super.key,
    required this.pageNumber,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          gradient: AppColors.ctaGradientLinear,
          borderRadius: BorderRadius.circular(AppRadius.xxxl),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // ── Number badge (top-left) ──
            Positioned(
              top: AppSpacing.space6,
              left: AppSpacing.space6,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.withAlpha(AppColors.background, 0.3),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    pageNumber.toString(),
                    style: const TextStyle(
                      color: AppColors.primaryForeground,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
            // ── Center icon ──
            Center(
              child: Icon(
                icon,
                size: 80,
                color: AppColors.primaryForeground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
