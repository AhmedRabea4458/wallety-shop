import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smart_expense/core/theme/app_colors.dart';
import 'package:smart_expense/core/theme/app_radius.dart';
import 'package:smart_expense/core/theme/app_spacing.dart';
import 'package:smart_expense/core/theme/app_text_styles.dart';
import 'package:smart_expense/features/operations/domain/entities/operation_entity.dart';
import 'package:smart_expense/features/sms_import/data/sms_import_processor.dart';
import 'package:smart_expense/features/sms_import/data/sms_storage_service.dart';
import 'package:smart_expense/features/sms_import/domain/models/sms_record.dart';
import 'package:smart_expense/features/sms_import/presentation/widgets/manual_import_dialog.dart';
import 'package:smart_expense/features/sms_import/sms_listener_service.dart';

class SmsTransactionsPage extends StatefulWidget {
  const SmsTransactionsPage({super.key});

  @override
  State<SmsTransactionsPage> createState() => _SmsTransactionsPageState();
}

class _SmsTransactionsPageState extends State<SmsTransactionsPage> {
  bool _isImportingRecent = false;

  @override
  void initState() {
    super.initState();
    SmsStorageService.instance.loadRecords();
    SmsImportProcessor().retryPendingRecords();
  }

  Future<void> _handleImportRecent() async {
    setState(() => _isImportingRecent = true);
    final count = await SmsListenerService.instance.importRecentSms(count: 15);
    await SmsImportProcessor().retryPendingRecords();
    setState(() => _isImportingRecent = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            count > 0
                ? 'تم استيراد $count عملية جديدة من الرسائل الأخيرة'
                : 'لم يتم العثور على رسائل مالية جديدة في صندوق الوارد',
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy/MM/dd - hh:mm a');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('سجل رسائل المعاملات (SMS)'),
        actions: [
          IconButton(
            tooltip: 'استيراد الرسائل الأخيرة من الهاتف',
            icon:
                _isImportingRecent
                    ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                    : const Icon(Icons.sync_rounded),
            onPressed: _isImportingRecent ? null : _handleImportRecent,
          ),
        ],
      ),
      body: ValueListenableBuilder<List<SmsRecord>>(
        valueListenable: SmsStorageService.instance.recordsNotifier,
        builder: (context, records, child) {
          if (records.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.sms_outlined,
                    size: 64,
                    color: AppColors.mutedForeground.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: AppSpacing.space3),
                  Text(
                    'لا توجد رسائل مسجلة حتى الآن',
                    style: AppTextStyles.headline.copyWith(
                      color: AppColors.foregroundSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space2),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      'عند استلام رسائل من فودافون كاش أو إنستا باي سيتم التقاطها وعرضها هنا تلقائياً.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.body,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space5),
                  ElevatedButton.icon(
                    onPressed: _isImportingRecent ? null : _handleImportRecent,
                    icon: const Icon(Icons.download_rounded),
                    label: const Text('فحص الرسائل الأخيرة بالهاتف'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.primaryForeground,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
            itemCount: records.length,
            separatorBuilder:
                (context, index) => const SizedBox(height: AppSpacing.space3),
            itemBuilder: (context, index) {
              final record = records[index];
              return _buildRecordCard(context, record, dateFormat);
            },
          );
        },
      ),
    );
  }

  Widget _buildRecordCard(
    BuildContext context,
    SmsRecord record,
    DateFormat dateFormat,
  ) {
    final isDeposit = record.operationType == OperationType.deposit;
    final isPending = record.importStatus == SmsImportStatus.pending;
    final isFailed = record.importStatus == SmsImportStatus.failed;

    Color statusBgColor;
    Color statusTextColor;
    String statusLabel;

    switch (record.importStatus) {
      case SmsImportStatus.imported:
        statusBgColor = AppColors.success.withValues(alpha: 0.15);
        statusTextColor = AppColors.success;
        statusLabel = 'تم الاستيراد';
        break;
      case SmsImportStatus.pending:
        final isWaitingForShift = record.failureReason != null &&
            record.failureReason!.contains('وردية');
        statusBgColor = isWaitingForShift
            ? AppColors.warning.withValues(alpha: 0.15)
            : AppColors.primary10;
        statusTextColor =
            isWaitingForShift ? AppColors.warning : AppColors.primary;
        statusLabel =
            isWaitingForShift ? 'بانتظار الوردية' : 'في انتظار المراجعة';
        break;
      case SmsImportStatus.failed:
        statusBgColor = AppColors.destructive.withValues(alpha: 0.15);
        statusTextColor = AppColors.destructive;
        statusLabel = 'فشل الاستيراد';
        break;
      case SmsImportStatus.ignored:
        statusBgColor = AppColors.muted;
        statusTextColor = AppColors.mutedForeground;
        statusLabel = 'تجاهل';
        break;
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: BorderSide(
          color:
              isPending
                  ? AppColors.warning.withValues(alpha: 0.6)
                  : AppColors.border,
          width: isPending ? 1.5 : 1,
        ),
      ),
      color: AppColors.card,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        onTap:
            (isPending || isFailed)
                ? () {
                  showDialog(
                    context: context,
                    builder:
                        (_) => ManualImportDialog(
                          record: record,
                          onImportSuccess: () {
                            setState(() {});
                          },
                        ),
                  );
                }
                : null,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.space4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Provider / Type badge + Status badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color:
                                isDeposit
                                    ? AppColors.success.withValues(alpha: 0.1)
                                    : AppColors.destructive.withValues(
                                      alpha: 0.1,
                                    ),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isDeposit
                                ? Icons.arrow_downward_rounded
                                : Icons.arrow_upward_rounded,
                            color:
                                isDeposit
                                    ? AppColors.success
                                    : AppColors.destructive,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.space2),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                record.providerType?.label ?? 'رسالة SMS',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.body.copyWith(
                                  color: AppColors.foreground,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                isDeposit
                                    ? 'إيداع (المحل أرسل للعميل)'
                                    : 'سحب (العميل أرسل للمحل)',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.foregroundSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.space2),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.space2,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusBgColor,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Text(
                      statusLabel,
                      style: AppTextStyles.caption.copyWith(
                        color: statusTextColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.space3),

              // Middle: Amount & Reference
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Flexible(
                    child: Text(
                      '${record.amount?.toStringAsFixed(2) ?? "0.00"} ج.م',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.headline.copyWith(
                        color:
                            isDeposit ? AppColors.success : AppColors.foreground,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (record.referenceNumber != null) ...[
                    const SizedBox(width: AppSpacing.space2),
                    Flexible(
                      child: Text(
                        'مرجع: ${record.referenceNumber}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.end,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.mutedForeground,
                        ),
                      ),
                    ),
                  ],
                ],
              ),

              // Party info (Phone / Name)
              if (record.partyName != null || record.phoneNumber != null) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    if (record.partyName != null) ...[
                      const Icon(
                        Icons.person_outline,
                        size: 14,
                        color: AppColors.mutedForeground,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          record.partyName!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.foregroundSecondary,
                          ),
                        ),
                      ),
                    ],
                    if (record.phoneNumber != null) ...[
                      if (record.partyName != null)
                        const SizedBox(width: AppSpacing.space2),
                      const Icon(
                        Icons.phone_iphone_outlined,
                        size: 14,
                        color: AppColors.mutedForeground,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          record.phoneNumber!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.foregroundSecondary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],

              // Failure / Pending Reason
              if (record.failureReason != null) ...[
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.space2),
                  decoration: BoxDecoration(
                    color:
                        isPending
                            ? AppColors.warning.withValues(alpha: 0.1)
                            : AppColors.destructive.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Text(
                    record.failureReason!,
                    style: AppTextStyles.caption.copyWith(
                      color:
                          isPending ? AppColors.warning : AppColors.destructive,
                    ),
                  ),
                ),
              ],

              const Divider(height: 16),

              // Bottom row: Date/Time
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      dateFormat.format(
                        record.transactionDateTime ?? record.receivedAt,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.mutedForeground,
                      ),
                    ),
                  ),
                  if (isPending) ...[
                    const SizedBox(width: AppSpacing.space2),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'اضغط للمتابعة',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Icon(
                          Icons.chevron_left_rounded,
                          size: 16,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
