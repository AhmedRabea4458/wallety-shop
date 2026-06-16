import 'package:flutter/material.dart';
import 'package:smart_expense/core/theme/app_colors.dart';
import 'package:smart_expense/core/theme/app_radius.dart';
import 'package:smart_expense/core/theme/app_text_styles.dart';

class PeriodSegmentedControl extends StatelessWidget {
  final String selectedPeriod;
  final ValueChanged<String> onChanged;

  const PeriodSegmentedControl({
    super.key,
    required this.selectedPeriod,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final periods = [
      'أسبوع',
      'شهر',
      '٣ أشهر',
      'الكل',
    ];

    return Container(
      height: 56,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(
          color: AppColors.border45,
        ),
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        children: periods.map((period) {
          final isSelected = selectedPeriod == period;

          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(period),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : Colors.transparent,
                  borderRadius:
                      BorderRadius.circular(AppRadius.full),
                ),
                child: Text(
                  period,
                  style: AppTextStyles.body.copyWith(
                    color: isSelected
                        ? AppColors.primaryForeground
                        : AppColors.mutedForeground,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}