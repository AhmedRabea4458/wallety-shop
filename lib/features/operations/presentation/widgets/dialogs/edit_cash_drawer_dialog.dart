import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smart_expense/core/theme/app_colors.dart';
import 'package:smart_expense/core/theme/app_radius.dart';
import 'package:smart_expense/core/theme/app_spacing.dart';
import 'package:smart_expense/core/theme/app_text_styles.dart';
import 'package:smart_expense/core/utils/arabic_numerals.dart';
import 'package:smart_expense/features/operations/presentation/cubit/cash_drawer_cubit.dart';
import 'package:smart_expense/features/operations/presentation/cubit/cash_drawer_state.dart';

String _formatAmount(double amount) {
  return NumberFormat('#,##0.##', 'ar').format(amount);
}

/// Shows a dialog to edit cash drawer balance.
void showEditCashDrawerDialog({
  required BuildContext parentContext,
  required CashDrawerCubit cashDrawerCubit,
  double? currentDrawerBalance,
}) {
  final cubitState = cashDrawerCubit.state;
  final currentBalance = cubitState is CashDrawerLoaded
      ? cubitState.cashDrawer.balance
      : (currentDrawerBalance ?? 0.0);

  final newBalanceController = TextEditingController();
  final reasonController = TextEditingController();
  double? calculatedAdjustment;
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
              'تعديل رصيد الدرج النقدي',
              style: AppTextStyles.headline.copyWith(color: AppColors.foreground),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Current balance: read-only
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.space3,
                      vertical: AppSpacing.space3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(color: AppColors.border50),
                    ),
                    child: Row(
                      children: [
                        Text(
                          'الرصيد الحالي',
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.mutedForeground,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${_formatAmount(currentBalance)} ج.م',
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: AppColors.foreground,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space3),

                  // New balance: required numeric input
                  TextField(
                    controller: newBalanceController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    textAlign: TextAlign.right,
                    enabled: !isLoading,
                    onChanged: (text) {
                      final trimmed = text.trim();
                      if (trimmed.isEmpty) {
                        setStateDialog(() {
                          calculatedAdjustment = null;
                        });
                      } else {
                        final newBal = parseArabicNumerals(trimmed);
                        setStateDialog(() {
                          calculatedAdjustment = newBal - currentBalance;
                        });
                      }
                    },
                    decoration: InputDecoration(
                      labelText: 'الرصيد الجديد *',
                      labelStyle: AppTextStyles.body.copyWith(color: AppColors.mutedForeground),
                      hintText: '0',
                      hintStyle: AppTextStyles.body.copyWith(color: AppColors.mutedForeground),
                      suffixText: 'ج.م',
                      suffixStyle: AppTextStyles.body.copyWith(color: AppColors.mutedForeground),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        borderSide: BorderSide(color: AppColors.border50),
                      ),
                    ),
                  ),

                  // Automatic Adjustment preview
                  if (calculatedAdjustment != null) ...[
                    const SizedBox(height: AppSpacing.space2),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.space3,
                        vertical: AppSpacing.space2,
                      ),
                      decoration: BoxDecoration(
                        color: (calculatedAdjustment! >= 0
                                ? AppColors.success
                                : AppColors.destructive)
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: Row(
                        children: [
                          Text(
                            'قيمة التعديل:',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.foreground,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${calculatedAdjustment! >= 0 ? "+" : ""}${_formatAmount(calculatedAdjustment!)} ج.م',
                            style: AppTextStyles.caption.copyWith(
                              color: calculatedAdjustment! >= 0
                                  ? AppColors.success
                                  : AppColors.destructive,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: AppSpacing.space3),

                  // Reason: required
                  TextField(
                    controller: reasonController,
                    textAlign: TextAlign.right,
                    enabled: !isLoading,
                    decoration: InputDecoration(
                      labelText: 'سبب التعديل *',
                      labelStyle: AppTextStyles.body.copyWith(color: AppColors.mutedForeground),
                      hintText: 'أدخل سبب تعديل الرصيد',
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
                        final newBalanceText = newBalanceController.text.trim();
                        if (newBalanceText.isEmpty) {
                          ScaffoldMessenger.of(dialogContext).showSnackBar(
                            const SnackBar(content: Text('الرصيد الجديد مطلوب')),
                          );
                          return;
                        }

                        final finalBalance = parseArabicNumerals(newBalanceText);
                        if (finalBalance < 0) {
                          ScaffoldMessenger.of(dialogContext).showSnackBar(
                            const SnackBar(content: Text('لا يمكن أن يكون الرصيد سالباً')),
                          );
                          return;
                        }

                        final reasonText = reasonController.text.trim();
                        if (reasonText.isEmpty) {
                          ScaffoldMessenger.of(dialogContext).showSnackBar(
                            const SnackBar(content: Text('سبب التعديل مطلوب')),
                          );
                          return;
                        }

                        setStateDialog(() => isLoading = true);

                        final messenger = ScaffoldMessenger.of(dialogContext);
                        final navigator = Navigator.of(dialogContext);
                        try {
                          await cashDrawerCubit.updateBalance(finalBalance);
                          if (!dialogContext.mounted) return;
                          navigator.pop();
                        } catch (e) {
                          if (!dialogContext.mounted) return;
                          setStateDialog(() => isLoading = false);
                          messenger.showSnackBar(
                            const SnackBar(content: Text('فشل تحديث رصيد الدرج النقدي')),
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
