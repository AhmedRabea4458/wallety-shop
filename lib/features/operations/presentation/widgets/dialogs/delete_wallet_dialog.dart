import 'package:flutter/material.dart';
import 'package:smart_expense/core/theme/app_colors.dart';
import 'package:smart_expense/core/theme/app_radius.dart';
import 'package:smart_expense/core/theme/app_text_styles.dart';
import 'package:smart_expense/features/operations/domain/entities/wallet_entity.dart';
import 'package:smart_expense/features/operations/presentation/cubit/wallet_cubit.dart';

/// Shows a confirmation dialog before deleting a wallet.
///
/// [parentContext] should be a stable context from the parent page.
void showDeleteWalletDialog({
  required BuildContext parentContext,
  required WalletCubit walletCubit,
  required WalletEntity wallet,
}) {
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
              'حذف المحفظة',
              style: AppTextStyles.headline.copyWith(color: AppColors.destructive),
            ),
            content: Text(
              'هل أنت متأكد من حذف ${wallet.name}؟\nلا يمكن حذف محفظة تحتوي على عمليات.',
              style: AppTextStyles.body.copyWith(color: AppColors.foreground),
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
                        setStateDialog(() => isLoading = true);
                        try {
                          await walletCubit.deleteWallet(wallet.id);
                          if (!dialogContext.mounted) return;
                          Navigator.pop(dialogContext);
                          if (parentContext.mounted) {
                            ScaffoldMessenger.of(parentContext).showSnackBar(
                              const SnackBar(content: Text('تم حذف المحفظة بنجاح')),
                            );
                          }
                        } catch (e) {
                          if (!dialogContext.mounted) return;
                          setStateDialog(() => isLoading = false);
                          ScaffoldMessenger.of(dialogContext).showSnackBar(
                            const SnackBar(
                              content: Text('فشل حذف المحفظة'),
                              backgroundColor: AppColors.destructive,
                            ),
                          );
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.destructive,
                  foregroundColor: AppColors.destructiveForeground,
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.destructiveForeground,
                        ),
                      )
                    : const Text('حذف'),
              ),
            ],
          );
        },
      );
    },
  );
}
