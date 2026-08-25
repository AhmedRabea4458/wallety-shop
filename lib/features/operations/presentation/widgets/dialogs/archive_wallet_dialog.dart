import 'package:flutter/material.dart';
import 'package:smart_expense/core/theme/app_colors.dart';
import 'package:smart_expense/core/theme/app_radius.dart';
import 'package:smart_expense/core/theme/app_text_styles.dart';
import 'package:smart_expense/features/operations/domain/entities/wallet_entity.dart';
import 'package:smart_expense/features/operations/presentation/cubit/wallet_cubit.dart';

/// Shows a confirmation dialog before archiving a wallet.
///
/// [parentContext] should be a stable context from the parent page.
void showArchiveWalletDialog({
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
            title: Row(
              children: [
                const Icon(
                  Icons.archive_outlined,
                  color: AppColors.warning,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'أرشفة المحفظة',
                  style: AppTextStyles.headline.copyWith(
                    color: AppColors.foreground,
                  ),
                ),
              ],
            ),
            content: Text(
              'هل أنت متأكد من أرشفة محفظة "${wallet.name}"؟\n\n'
              '• لن تظهر المحفظة في نماذج العمليات الجديدة.\n'
              '• ستظل كافة العمليات السابقة المرتبطة بها محفوظة ومتاحة بالسجلات.\n'
              '• يمكنك استعادة المحفظة في أي وقت من قسم المحافظ المؤرشفة.',
              style: AppTextStyles.body.copyWith(
                color: AppColors.foreground,
                height: 1.5,
              ),
            ),
            actions: [
              TextButton(
                onPressed: isLoading ? null : () => Navigator.pop(dialogContext),
                child: Text(
                  'إلغاء',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.mutedForeground,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () async {
                        setStateDialog(() => isLoading = true);
                        try {
                          await walletCubit.archiveWallet(wallet.id);
                          if (!dialogContext.mounted) return;
                          Navigator.pop(dialogContext);
                          if (parentContext.mounted) {
                            ScaffoldMessenger.of(parentContext).showSnackBar(
                              const SnackBar(
                                content: Text('تمت أرشفة المحفظة بنجاح'),
                              ),
                            );
                          }
                        } catch (e) {
                          if (!dialogContext.mounted) return;
                          setStateDialog(() => isLoading = false);
                          ScaffoldMessenger.of(dialogContext).showSnackBar(
                            const SnackBar(
                              content: Text('فشل أرشفة المحفظة'),
                              backgroundColor: AppColors.destructive,
                            ),
                          );
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.warning,
                  foregroundColor: Colors.white,
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('أرشفة'),
              ),
            ],
          );
        },
      );
    },
  );
}
