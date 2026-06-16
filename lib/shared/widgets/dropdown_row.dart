import 'package:flutter/material.dart';
import 'package:smart_expense/core/theme/app_colors.dart';
import 'package:smart_expense/core/theme/app_spacing.dart';
import 'package:smart_expense/core/theme/app_text_styles.dart';
import 'package:smart_expense/shared/widgets/settings_row.dart';

class DropdownRow extends StatelessWidget {
  final IconData icon;
  final Color iconBackgroundColor;
  final Color iconColor;
  final String label;
  final String value;
  final VoidCallback? onTap;

  const DropdownRow({
    super.key,
    required this.icon,
    required this.iconBackgroundColor,
    required this.iconColor,
    required this.label,
    required this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SettingsRow(
      icon: icon,
      iconBackgroundColor: iconBackgroundColor,
      iconColor: iconColor,
      label: label,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: AppTextStyles.body.copyWith(
              color: AppColors.mutedForeground,
            ),
          ),
          const SizedBox(width: AppSpacing.space2),
          Icon(
            Icons.arrow_back_ios_rounded,
            size: 14,
            color: AppColors.mutedForeground,
          ),
        ],
      ),
      onTap: onTap,
    );
  }
}
