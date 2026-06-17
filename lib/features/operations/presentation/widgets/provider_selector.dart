import 'package:flutter/material.dart';
import 'package:smart_expense/core/theme/app_colors.dart';
import 'package:smart_expense/core/theme/app_radius.dart';
import 'package:smart_expense/core/theme/app_spacing.dart';
import 'package:smart_expense/core/theme/app_text_styles.dart';
import 'package:smart_expense/features/operations/domain/entities/provider_type.dart';

class ProviderSelector extends StatelessWidget {
  final ProviderType selectedProvider;
  final ValueChanged<ProviderType> onChanged;

  const ProviderSelector({
    super.key,
    required this.selectedProvider,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.space4),
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
            'مزود الخدمة',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.mutedForeground,
            ),
          ),
          const SizedBox(height: AppSpacing.space3),
          Row(
            children: [
              Expanded(
                child: _ProviderChip(
                  label: 'Vodafone Cash',
                  isSelected: selectedProvider == ProviderType.vodafoneCash,
                  onTap: () => onChanged(ProviderType.vodafoneCash),
                ),
              ),
              const SizedBox(width: AppSpacing.space2),
              Expanded(
                child: _ProviderChip(
                  label: 'InstaPay',
                  isSelected: selectedProvider == ProviderType.instaPay,
                  onTap: () => onChanged(ProviderType.instaPay),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProviderChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ProviderChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.space3,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.background,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border50,
            width: 1,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppTextStyles.body.copyWith(
            color: isSelected ? AppColors.primaryForeground : AppColors.foreground,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
