import 'package:flutter/material.dart';
import 'package:smart_expense/core/theme/app_colors.dart';
import 'package:smart_expense/core/theme/app_radius.dart';
import 'package:smart_expense/core/theme/app_spacing.dart';
import 'package:smart_expense/core/theme/app_text_styles.dart';

/// Base settings row widget.
///
/// Used as the foundation for [ToggleRow], [DropdownRow], and [ActionRow].
/// Displays an icon inside a tinted container, a label, and an optional trailing widget.
class SettingsRow extends StatelessWidget {
  final IconData icon;
  final Color iconBackgroundColor;
  final Color iconColor;
  final String label;
  final Widget? trailing;
  final VoidCallback? onTap;

  const SettingsRow({
    super.key,
    required this.icon,
    required this.iconBackgroundColor,
    required this.iconColor,
    required this.label,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.space3,
        ),
        child: Row(
          children: [
            // Icon container
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconBackgroundColor,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(
                icon,
                size: 18,
                color: iconColor,
              ),
            ),
            const SizedBox(width: AppSpacing.space3),
            // Label
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.foreground,
                ),
              ),
            ),
            // Trailing action
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}
