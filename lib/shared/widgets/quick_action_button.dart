import 'package:flutter/material.dart';
import 'package:smart_expense/core/theme/app_radius.dart';
import 'package:smart_expense/core/theme/app_spacing.dart';
import 'package:smart_expense/core/theme/app_text_styles.dart';

class QuickActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color? backgroundColor;
  final Gradient? gradient;
  final Color textColor;
  final Color iconColor;
  final VoidCallback? onTap;

  const QuickActionButton({
    super.key,
    required this.label,
    required this.icon,
    this.backgroundColor,
    this.gradient,
    required this.textColor,
    required this.iconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: backgroundColor,
        gradient: gradient,
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.space4,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: textColor,
                  ),
                ),
                const SizedBox(width: AppSpacing.space2),
                Icon(
                  icon,
                  size: 20,
                  color: iconColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
