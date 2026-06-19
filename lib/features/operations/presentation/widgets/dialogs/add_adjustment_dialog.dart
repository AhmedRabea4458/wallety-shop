import 'package:flutter/material.dart';
import 'package:smart_expense/core/theme/app_colors.dart';
import 'package:smart_expense/core/theme/app_radius.dart';
import 'package:smart_expense/core/theme/app_spacing.dart';
import 'package:smart_expense/core/theme/app_text_styles.dart';
import 'package:smart_expense/core/utils/arabic_numerals.dart';
import 'package:smart_expense/features/operations/domain/entities/wallet_adjustment_entity.dart';
import 'package:smart_expense/features/operations/domain/entities/wallet_entity.dart';
import 'package:smart_expense/features/operations/presentation/cubit/wallet_adjustment_cubit.dart';

/// Shows a dialog to add a wallet usage adjustment (daily/monthly).
///
/// [parentContext] should be a stable context from the parent page.
void showAddAdjustmentDialog({
  required BuildContext parentContext,
  required WalletAdjustmentCubit adjustmentCubit,
  required WalletEntity wallet,
}) {
  final amountController = TextEditingController();
  final reasonController = TextEditingController();
  String selectedPeriod = 'daily';
  bool isLoading = false;

  showDialog(
    context: parentContext,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (_, setStateDialog) {
          return AlertDialog(
            backgroundColor: AppColors.card,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            title: Text(
              'تعديل استهلاك ${wallet.name}',
              style: AppTextStyles.headline.copyWith(color: AppColors.foreground),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'نوع الفترة',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.foreground,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space2),
                  Row(
                    children: [
                      Expanded(
                        child: ChoiceChip(
                          label: const Text('يومي'),
                          selected: selectedPeriod == 'daily',
                          onSelected: isLoading ? null : (_) => setStateDialog(() => selectedPeriod = 'daily'),
                          selectedColor: AppColors.primary,
                          labelStyle: TextStyle(
                            color: selectedPeriod == 'daily'
                                ? AppColors.primaryForeground
                                : AppColors.foreground,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.space2),
                      Expanded(
                        child: ChoiceChip(
                          label: const Text('شهري'),
                          selected: selectedPeriod == 'monthly',
                          onSelected: isLoading ? null : (_) => setStateDialog(() => selectedPeriod = 'monthly'),
                          selectedColor: AppColors.primary,
                          labelStyle: TextStyle(
                            color: selectedPeriod == 'monthly'
                                ? AppColors.primaryForeground
                                : AppColors.foreground,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.space3),
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.right,
                    enabled: !isLoading,
                    decoration: InputDecoration(
                      hintText: 'المبلغ المضاف للاستهلاك',
                      hintStyle: AppTextStyles.body.copyWith(color: AppColors.mutedForeground),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        borderSide: BorderSide(color: AppColors.border50),
                      ),
                      suffixText: 'ج.م',
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space3),
                  TextField(
                    controller: reasonController,
                    textAlign: TextAlign.right,
                    enabled: !isLoading,
                    decoration: InputDecoration(
                      hintText: 'السبب (اختياري)',
                      hintStyle: AppTextStyles.body.copyWith(color: AppColors.mutedForeground),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        borderSide: BorderSide(color: AppColors.border50),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: isLoading ? null : () => Navigator.pop(dialogContext),
                child: Text('إلغاء', style: AppTextStyles.body.copyWith(color: AppColors.mutedForeground)),
              ),
              ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () async {
                        final amountText = amountController.text.trim();
                        if (amountText.isEmpty) {
                          ScaffoldMessenger.of(dialogContext).showSnackBar(
                            const SnackBar(content: Text('المبلغ مطلوب')),
                          );
                          return;
                        }
                        setStateDialog(() => isLoading = true);

                        final amount = parseArabicNumerals(amountText);
                        final adjustment = WalletAdjustmentEntity(
                          id: 0,
                          walletId: wallet.id,
                          periodType: selectedPeriod,
                          amount: amount,
                          reason: reasonController.text.trim().isEmpty
                              ? null
                              : reasonController.text.trim(),
                          createdAt: DateTime.now(),
                        );

                        try {
                          await adjustmentCubit.addAdjustment(adjustment);
                          if (!dialogContext.mounted) return;
                          Navigator.pop(dialogContext);
                          if (parentContext.mounted) {
                            ScaffoldMessenger.of(parentContext).showSnackBar(
                              const SnackBar(content: Text('تم إضافة التعديل بنجاح')),
                            );
                          }
                        } catch (e) {
                          if (!dialogContext.mounted) return;
                          setStateDialog(() => isLoading = false);
                          ScaffoldMessenger.of(dialogContext).showSnackBar(
                            const SnackBar(
                              content: Text('فشل إضافة التعديل'),
                              backgroundColor: AppColors.destructive,
                            ),
                          );
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.primaryForeground,
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primaryForeground,
                        ),
                      )
                    : const Text('حفظ'),
              ),
            ],
          );
        },
      );
    },
  );
}
