import 'package:flutter/material.dart';
import 'package:smart_expense/core/theme/app_colors.dart';
import 'package:smart_expense/shared/widgets/settings_row.dart';

class ActionRow extends StatelessWidget {
  final IconData icon;
  final Color iconBackgroundColor;
  final Color iconColor;
  final String label;
  final VoidCallback? onTap;

  const ActionRow({
    super.key,
    required this.icon,
    required this.iconBackgroundColor,
    required this.iconColor,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SettingsRow(
      icon: icon,
      iconBackgroundColor: iconBackgroundColor,
      iconColor: iconColor,
      label: label,
      trailing: Icon(
        Icons.arrow_back_ios_rounded,
        size: 14,
        color: AppColors.mutedForeground,
      ),
      onTap: onTap,
    );
  }
}
