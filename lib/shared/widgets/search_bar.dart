import 'package:flutter/material.dart';
import 'package:smart_expense/core/theme/app_colors.dart';
import 'package:smart_expense/core/theme/app_radius.dart';
import 'package:smart_expense/core/theme/app_spacing.dart';
import 'package:smart_expense/core/theme/app_text_styles.dart';

class SearchBar extends StatelessWidget {
  final String hintText;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;

  const SearchBar({
    super.key,
    required this.hintText,
    this.onTap,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: AppColors.border50,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: AppSpacing.space4),
          Icon(
            Icons.search_rounded,
            size: 20,
            color: AppColors.mutedForeground,
          ),
          const SizedBox(width: AppSpacing.space3),
          Expanded(
            child: TextField(
              onTap: onTap,
              onChanged: onChanged,
              style: AppTextStyles.body.copyWith(
                color: AppColors.foreground,
              ),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: AppTextStyles.body.copyWith(
                  color: AppColors.mutedForeground,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.space4),
        ],
      ),
    );
  }
}
