import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_expense/core/constants/app_routes.dart';
import 'package:smart_expense/core/theme/app_colors.dart';
import 'package:smart_expense/core/theme/app_radius.dart';
import 'package:smart_expense/core/theme/app_spacing.dart';
import 'package:smart_expense/core/theme/app_text_styles.dart';
import 'package:smart_expense/features/sms_import/data/sms_storage_service.dart';
import 'package:smart_expense/features/sms_import/domain/models/sms_record.dart';
import 'package:smart_expense/features/sms_import/sms_listener_service.dart';
import 'package:smart_expense/shared/widgets/action_row.dart';

class SmsTransactionsSection extends StatelessWidget {
  const SmsTransactionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
      ),
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
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary10,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: const Icon(
                  Icons.sms_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.space3),
              Expanded(
                child: Text(
                  'استيراد الرسائل (SMS)',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.foreground,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.space3),
          Divider(color: AppColors.border45, height: 1),

          // 1. SMS Monitoring Toggle
          ValueListenableBuilder<bool>(
            valueListenable: SmsListenerService.instance.isListening,
            builder: (context, isListening, child) {
              return ActionRow(
                icon: isListening ? Icons.notifications_active_rounded : Icons.notifications_off_outlined,
                iconBackgroundColor: isListening
                    ? AppColors.success.withValues(alpha: 0.15)
                    : AppColors.primary10,
                iconColor: isListening ? AppColors.success : AppColors.primary,
                label: isListening ? 'مراقبة الرسائل (قيد التشغيل)' : 'مراقبة الرسائل (متوقفة)',
                onTap: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  final newState =
                      await SmsListenerService.instance.toggleListening();
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(newState
                          ? 'تم تفعيل الاستماع للرسائل الواردة بنجاح'
                          : 'تم إيقاف الاستماع للرسائل'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              );
            },
          ),

          Divider(color: AppColors.border45, height: 1),

          // 2. Stats & Latest Transaction
          ValueListenableBuilder<List<SmsRecord>>(
            valueListenable: SmsStorageService.instance.recordsNotifier,
            builder: (context, records, child) {
              final importedCount = records
                  .where((r) => r.importStatus == SmsImportStatus.imported)
                  .length;
              final latestRecord = records.isNotEmpty ? records.first : null;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.space3),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            'عدد العمليات المستوردة:',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.mutedForeground,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.space2),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary10,
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                          child: Text(
                            '$importedCount عملية',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.space2),
                    Row(
                      children: [
                        Text(
                          'آخر عملية:',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.mutedForeground,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.space2),
                        Expanded(
                          child: Text(
                            latestRecord != null
                                ? '${latestRecord.amount?.toStringAsFixed(0) ?? "0"} ج.م - ${latestRecord.providerType?.label ?? "SMS"}'
                                : 'لا توجد عمليات بعد',
                            textAlign: TextAlign.end,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.caption.copyWith(
                              fontWeight: FontWeight.bold,
                              color: latestRecord != null
                                  ? AppColors.foreground
                                  : AppColors.mutedForeground,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (latestRecord != null) ...[
                      const SizedBox(height: AppSpacing.space2),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              'حالة آخر عملية:',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.mutedForeground,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.space2),
                          _buildStatusBadge(latestRecord.importStatus),
                        ],
                      ),
                    ],
                  ],
                ),
              );
            },
          ),

          Divider(color: AppColors.border45, height: 1),

          // 3. Navigation to Imported SMS List
          ActionRow(
            icon: Icons.list_alt_rounded,
            iconBackgroundColor: AppColors.primary10,
            iconColor: AppColors.primary,
            label: 'سجل العمليات المستوردة',
            onTap: () {
              context.push(AppRoutes.smsTransactions);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(SmsImportStatus status) {
    Color bg;
    Color fg;
    String text;

    switch (status) {
      case SmsImportStatus.imported:
        bg = AppColors.success.withValues(alpha: 0.15);
        fg = AppColors.success;
        text = 'تم الاستيراد بنجاح';
        break;
      case SmsImportStatus.pending:
        bg = AppColors.warning.withValues(alpha: 0.15);
        fg = AppColors.warning;
        text = 'في الانتظار';
        break;
      case SmsImportStatus.failed:
        bg = AppColors.destructive.withValues(alpha: 0.15);
        fg = AppColors.destructive;
        text = 'فشلت';
        break;
      case SmsImportStatus.ignored:
        bg = AppColors.muted;
        fg = AppColors.mutedForeground;
        text = 'متجاهلة';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(
        text,
        style: AppTextStyles.caption.copyWith(
          color: fg,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
