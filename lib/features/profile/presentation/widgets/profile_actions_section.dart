import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_expense/core/constants/app_routes.dart';
import 'package:smart_expense/core/errors/error_mapper.dart';
import 'package:smart_expense/core/services/backup_restore_service.dart';
import 'package:smart_expense/core/theme/app_colors.dart';
import 'package:smart_expense/core/theme/app_radius.dart';
import 'package:smart_expense/core/theme/app_spacing.dart';
import 'package:smart_expense/core/theme/app_text_styles.dart';
import 'package:smart_expense/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:smart_expense/shared/widgets/action_row.dart';

class ProfileActionsSection extends StatelessWidget {
  const ProfileActionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space5,
        vertical: AppSpacing.space3,
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
        children: [
          ActionRow(
            icon: Icons.download_rounded,
            iconBackgroundColor: AppColors.primary10,
            iconColor: AppColors.primary,
            label: 'تصدير البيانات CSV',
            onTap: () async {
              final cubit = context.read<ProfileCubit>();
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              try {
                await cubit.exportToCsv();
                scaffoldMessenger.showSnackBar(
                  const SnackBar(
                    content: Text('تم تصدير البيانات بنجاح'),
                    duration: Duration(seconds: 2),
                  ),
                );
              } catch (e) {
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Text('حدث خطأ أثناء التصدير: ${ErrorMapper.map(e)}'),
                    backgroundColor: AppColors.destructive,
                    duration: const Duration(seconds: 3),
                  ),
                );
              }
            },
          ),
          Divider(
            color: AppColors.border45,
            indent: AppSpacing.space5,
            endIndent: AppSpacing.space5,
          ),
          ActionRow(
            icon: Icons.history_rounded,
            iconBackgroundColor: AppColors.primary10,
            iconColor: AppColors.primary,
            label: 'سجل الورديات',
            onTap: () => context.push(AppRoutes.shiftHistory),
          ),
          Divider(
            color: AppColors.border45,
            indent: AppSpacing.space5,
            endIndent: AppSpacing.space5,
          ),
          ActionRow(
            icon: Icons.credit_card_off_rounded,
            iconBackgroundColor: AppColors.warning.withValues(alpha: 0.15),
            iconColor: AppColors.warning,
            label: 'سجل الآجل',
            onTap: () => context.push(AppRoutes.debtors),
          ),
          Divider(
            color: AppColors.border45,
            indent: AppSpacing.space5,
            endIndent: AppSpacing.space5,
          ),
          ActionRow(
            icon: Icons.wallet_outlined,
            iconBackgroundColor: AppColors.primary10,
            iconColor: AppColors.primary,
            label: 'إدارة المحافظ',
            onTap: () => context.push(AppRoutes.walletManagement),
          ),
          Divider(
            color: AppColors.border45,
            indent: AppSpacing.space5,
            endIndent: AppSpacing.space5,
          ),
          ActionRow(
            icon: Icons.account_balance_wallet_outlined,
            iconBackgroundColor: AppColors.primary10,
            iconColor: AppColors.primary,
            label: 'ضبط أرصدة المحافظ',
            onTap: () => context.push(AppRoutes.walletSetup),
          ),
          Divider(
            color: AppColors.border45,
            indent: AppSpacing.space5,
            endIndent: AppSpacing.space5,
          ),
           ActionRow(
            icon: Icons.backup_rounded,
            iconBackgroundColor: AppColors.primary10,
            iconColor: AppColors.primary,
            label: 'إنشاء نسخة احتياطية',
            onTap: () async {
              final messenger = ScaffoldMessenger.of(context);
              try {
                await BackupRestoreService.backup();
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('تم إنشاء النسخة الاحتياطية بنجاح'),
                    duration: Duration(seconds: 2),
                  ),
                );
              } catch (e) {
                messenger.showSnackBar(
                  SnackBar(
                    content: Text('فشل إنشاء النسخة الاحتياطية: ${ErrorMapper.map(e)}'),
                    backgroundColor: AppColors.destructive,
                    duration: const Duration(seconds: 4),
                  ),
                );
              }
            },
          ),
            Divider(
            color: AppColors.border45,
            indent: AppSpacing.space5,
            endIndent: AppSpacing.space5,
          ),
           ActionRow(
            icon: Icons.restore_from_trash_rounded,
            iconBackgroundColor: AppColors.primary10,
            iconColor: AppColors.primary,
            label: 'استعادة نسخة احتياطية',
            onTap: () async {
              final messenger = ScaffoldMessenger.of(context);
              try {
                final filePath = await BackupRestoreService.pickBackupFile();
                if (filePath == null || !context.mounted) return;
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: AppColors.card,
                    title: Text('تأكيد الاستعادة',
                        style: AppTextStyles.headline.copyWith(color: AppColors.foreground)),
                    content: Text(
                        'سيتم حذف جميع البيانات الحالية واستبدالها بالنسخة الاحتياطية. هل أنت متأكد؟',
                        style: AppTextStyles.body.copyWith(color: AppColors.mutedForeground)),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('إلغاء')),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.destructive),
                        child: const Text('استعادة'),
                      ),
                    ],
                  ),
                );
                if (confirm == true && context.mounted) {
                  await BackupRestoreService.restore(filePath);
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('تمت استعادة البيانات بنجاح'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text('فشلت استعادة البيانات: ${ErrorMapper.map(e)}'),
                      backgroundColor: AppColors.destructive,
                      duration: const Duration(seconds: 4),
                    ),
                  );
                }
              }
            },
          ),
            Divider(
            color: AppColors.border45,
            indent: AppSpacing.space5,
            endIndent: AppSpacing.space5,
          ),
          ActionRow(
            icon: Icons.info_outline_rounded,
            iconBackgroundColor: AppColors.primary10,
            iconColor: AppColors.primary,
            label: 'عن التطبيق',
            onTap: () => _showAboutDialog(context),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          title: Text(
            'Wallety',
            style: AppTextStyles.headline.copyWith(
              color: AppColors.foreground,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Version 1.0 Shop',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.mutedForeground,
                  ),
                ),
                const SizedBox(height: AppSpacing.space4),
                Text(
                  'A Vodafone Cash shop management app built with:',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.foreground,
                  ),
                ),
                const SizedBox(height: AppSpacing.space3),
                Text(
                  '• Flutter\n• Drift\n• flutter_bloc\n• GetIt\n• GoRouter\n• Clean Architecture',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.foreground,
                  ),
                ),
                const SizedBox(height: AppSpacing.space4),
                Text(
                  'Wallety Team',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.foreground,
                  ),
                ),
                const SizedBox(height: AppSpacing.space1),
                Text(
                  '© 2026',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.primaryForeground,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
              ),
              child: Text(
                'حسنًا',
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
