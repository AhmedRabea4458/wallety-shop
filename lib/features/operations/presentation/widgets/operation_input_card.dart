import 'package:flutter/material.dart';
import 'package:smart_expense/core/theme/app_colors.dart';
import 'package:smart_expense/core/theme/app_radius.dart';
import 'package:smart_expense/core/theme/app_spacing.dart';
import 'package:smart_expense/core/theme/app_text_styles.dart';

/// A reusable input card used in the Add Operation form.
///
/// Wraps a [TextField] inside a styled card container with a label.
/// Used for commission, network fee, phone number, etc.
class OperationInputCard extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final bool enabled;
  final String? hintText;
  final String? suffixText;
  final TextAlign textAlign;

  const OperationInputCard({
    super.key,
    required this.label,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.enabled = true,
    this.hintText,
    this.suffixText,
    this.textAlign = TextAlign.start,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space5,
        vertical: AppSpacing.space4,
      ),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: AppColors.border50,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.mutedForeground,
            ),
          ),
          const SizedBox(height: AppSpacing.space2),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            textAlign: textAlign,
            enabled: enabled,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.foreground,
            ),
            decoration: InputDecoration(
              hintText: hintText ?? '0',
              hintStyle: AppTextStyles.body.copyWith(
                color: AppColors.mutedForeground,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
              isDense: true,
              suffixText: suffixText,
              suffixStyle: suffixText != null
                  ? AppTextStyles.body.copyWith(
                      color: AppColors.mutedForeground,
                    )
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}
