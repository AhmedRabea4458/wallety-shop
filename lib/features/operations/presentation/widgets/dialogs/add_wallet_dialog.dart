import 'package:flutter/material.dart';
import 'package:smart_expense/core/theme/app_colors.dart';
import 'package:smart_expense/core/theme/app_radius.dart';
import 'package:smart_expense/core/theme/app_spacing.dart';
import 'package:smart_expense/core/theme/app_text_styles.dart';
import 'package:smart_expense/core/utils/arabic_numerals.dart';
import 'package:smart_expense/features/operations/domain/entities/wallet_entity.dart';
import 'package:smart_expense/features/operations/presentation/cubit/wallet_cubit.dart';
import 'package:smart_expense/features/operations/presentation/widgets/wallet_color_picker.dart';

/// Shows a dialog to add a new wallet.
///
/// [parentContext] should be a stable context from the parent page
/// (not a list-item builder context) to safely show SnackBars after
/// the dialog is dismissed.
void showAddWalletDialog({
  required BuildContext parentContext,
  required WalletCubit walletCubit,
}) {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final balanceController = TextEditingController();
  Color selectedColor = const Color(0xFF6366F1);
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
              'إضافة محفظة جديدة',
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
                  TextField(
                    controller: balanceController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.right,
                    enabled: !isLoading,
                    decoration: InputDecoration(
                      hintText: 'الرصيد الافتتاحي',
                      hintStyle: AppTextStyles.body.copyWith(color: AppColors.mutedForeground),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        borderSide: BorderSide(color: AppColors.border50),
                      ),
                      suffixText: 'ج.م',
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

                        final balance = balanceController.text.trim().isEmpty
                            ? 0.0
                            : parseArabicNumerals(balanceController.text.trim());
                        final phone = phoneController.text.trim().isEmpty ? null : phoneController.text.trim();

                        final wallet = WalletEntity(
                          id: 0,
                          name: name,
                          phoneNumber: phone,
                          balance: balance,
                          color: selectedColor,
                          createdAt: DateTime.now(),
                        );

                        try {
                          await walletCubit.addWallet(wallet);
                          if (!dialogContext.mounted) return;
                          Navigator.pop(dialogContext);
                          if (parentContext.mounted) {
                            ScaffoldMessenger.of(parentContext).showSnackBar(
                              const SnackBar(content: Text('تم إضافة المحفظة بنجاح')),
                            );
                          }
                        } catch (e) {
                          if (!dialogContext.mounted) return;
                          setStateDialog(() => isLoading = false);
                          ScaffoldMessenger.of(dialogContext).showSnackBar(
                            const SnackBar(
                              content: Text('فشل إضافة المحفظة'),
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
                    : const Text('إضافة'),
              ),
            ],
          );
        },
      );
    },
  );
}
