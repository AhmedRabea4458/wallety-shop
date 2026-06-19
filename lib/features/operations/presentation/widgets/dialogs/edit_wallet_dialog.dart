import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smart_expense/core/theme/app_colors.dart';
import 'package:smart_expense/core/theme/app_radius.dart';
import 'package:smart_expense/core/theme/app_spacing.dart';
import 'package:smart_expense/core/theme/app_text_styles.dart';
import 'package:smart_expense/core/utils/arabic_numerals.dart';
import 'package:smart_expense/features/operations/domain/entities/wallet_entity.dart';
import 'package:smart_expense/features/operations/presentation/cubit/wallet_cubit.dart';
import 'package:smart_expense/features/operations/presentation/widgets/wallet_color_picker.dart';

/// Shows a dialog to edit an existing wallet.
///
/// [parentContext] should be a stable context from the parent page.
void showEditWalletDialog({
  required BuildContext parentContext,
  required WalletCubit walletCubit,
  required WalletEntity wallet,
}) {
  final nameController = TextEditingController(text: wallet.name);
  final phoneController = TextEditingController(text: wallet.phoneNumber ?? '');
  final dailyLimitController = TextEditingController(text: wallet.dailyLimit.toStringAsFixed(0));
  final monthlyLimitController = TextEditingController(text: wallet.monthlyLimit.toStringAsFixed(0));
  Color selectedColor = wallet.color;
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
              'تعديل المحفظة',
              style: AppTextStyles.headline.copyWith(color: AppColors.foreground),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: nameController,
                    textAlign: TextAlign.right,
                    enabled: !isLoading,
                    decoration: InputDecoration(
                      hintText: 'اسم المحفظة',
                      hintStyle: AppTextStyles.body.copyWith(color: AppColors.mutedForeground),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        borderSide: BorderSide(color: AppColors.border50),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space3),
                  TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    textAlign: TextAlign.right,
                    enabled: !isLoading,
                    decoration: InputDecoration(
                      hintText: 'رقم الهاتف',
                      hintStyle: AppTextStyles.body.copyWith(color: AppColors.mutedForeground),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        borderSide: BorderSide(color: AppColors.border50),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space3),
                  _LimitField(
                    controller: dailyLimitController,
                    label: 'الحد اليومي',
                    enabled: !isLoading,
                  ),
                  const SizedBox(height: AppSpacing.space3),
                  _LimitField(
                    controller: monthlyLimitController,
                    label: 'الحد الشهري',
                    enabled: !isLoading,
                  ),
                  const SizedBox(height: AppSpacing.space3),
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
                          '${NumberFormat("#,##0.##", "ar").format(wallet.balance)} ج.م',
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space4),
                  Text(
                    'لون المحفظة',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.foreground,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space2),
                  if (!isLoading)
                    WalletColorPicker(
                      selectedColor: selectedColor,
                      onColorSelected: (color) {
                        setStateDialog(() => selectedColor = color);
                      },
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
                        final name = nameController.text.trim();
                        if (name.isEmpty) {
                          ScaffoldMessenger.of(dialogContext).showSnackBar(
                            const SnackBar(content: Text('اسم المحفظة مطلوب')),
                          );
                          return;
                        }
                        setStateDialog(() => isLoading = true);

                        final phone = phoneController.text.trim().isEmpty ? null : phoneController.text.trim();
                        final dailyLimit = dailyLimitController.text.trim().isEmpty
                            ? wallet.dailyLimit
                            : parseArabicNumerals(dailyLimitController.text.trim());
                        final monthlyLimit = monthlyLimitController.text.trim().isEmpty
                            ? wallet.monthlyLimit
                            : parseArabicNumerals(monthlyLimitController.text.trim());

                        final updated = WalletEntity(
                          id: wallet.id,
                          name: name,
                          phoneNumber: phone,
                          balance: wallet.balance,
                          color: selectedColor,
                          dailyLimit: dailyLimit,
                          weeklyLimit: wallet.weeklyLimit,
                          monthlyLimit: monthlyLimit,
                          createdAt: wallet.createdAt,
                        );

                        try {
                          await walletCubit.updateWallet(updated);
                          if (!dialogContext.mounted) return;
                          Navigator.pop(dialogContext);
                          if (parentContext.mounted) {
                            ScaffoldMessenger.of(parentContext).showSnackBar(
                              const SnackBar(content: Text('تم تحديث المحفظة بنجاح')),
                            );
                          }
                        } catch (e) {
                          if (!dialogContext.mounted) return;
                          setStateDialog(() => isLoading = false);
                          ScaffoldMessenger.of(dialogContext).showSnackBar(
                            const SnackBar(
                              content: Text('فشل تحديث المحفظة'),
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

class _LimitField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool enabled;

  const _LimitField({
    required this.controller,
    required this.label,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      textAlign: TextAlign.right,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTextStyles.body.copyWith(color: AppColors.mutedForeground),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: AppColors.border50),
        ),
        suffixText: 'ج.م',
      ),
    );
  }
}
