import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smart_expense/core/theme/app_colors.dart';
import 'package:smart_expense/core/theme/app_radius.dart';
import 'package:smart_expense/core/theme/app_spacing.dart';
import 'package:smart_expense/core/theme/app_text_styles.dart';
import 'package:smart_expense/core/utils/date_formatter.dart';
import 'package:smart_expense/core/errors/error_mapper.dart';
import 'package:smart_expense/features/operations/domain/entities/operation_entity.dart';
import 'package:smart_expense/features/operations/domain/entities/provider_type.dart';
import 'package:smart_expense/features/operations/presentation/cubit/operation_cubit.dart';

/// Shows a safe confirmation dialog before deleting an operation.
///
/// [parentContext] must be a mounted BuildContext from the calling page.
Future<bool> showDeleteOperationDialog({
  required BuildContext parentContext,
  required OperationCubit operationCubit,
  required OperationEntity operation,
  String? walletName,
}) async {
  bool isLoading = false;
  final isDeposit = operation.operationType == OperationType.deposit;
  final opTypeLabel = isDeposit ? 'إيداع' : 'سحب';
  final formattedAmount = '${NumberFormat('#,##0.##', 'ar').format(operation.amount)} ج.م';
  final formattedDate = DateFormatter.formatTransactionDate(operation.createdAt);
  final isVodafone = operation.providerType == ProviderType.vodafoneCash;

  final result = await showDialog<bool>(
    context: parentContext,
    barrierDismissible: false,
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
                  Icons.warning_amber_rounded,
                  color: AppColors.destructive,
                  size: 26,
                ),
                const SizedBox(width: AppSpacing.space2),
                Text(
                  'حذف العملية',
                  style: AppTextStyles.headline.copyWith(
                    color: AppColors.destructive,
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'هل أنت متأكد من رغبتك في حذف هذه العملية نهائياً؟',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.foreground,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space3),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.space3),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(color: AppColors.border50),
                    ),
                    child: Column(
                      children: [
                        _buildRow('نوع العملية:', opTypeLabel),
                        const SizedBox(height: AppSpacing.space2),
                        _buildRow('المبلغ:', formattedAmount),
                        const SizedBox(height: AppSpacing.space2),
                        _buildRow('التاريخ:', formattedDate),
                        if (isVodafone && walletName != null) ...[
                          const SizedBox(height: AppSpacing.space2),
                          _buildRow('المحفظة:', walletName),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space3),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.space2),
                    decoration: BoxDecoration(
                      color: AppColors.destructive.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.info_outline_rounded,
                          color: AppColors.destructive,
                          size: 18,
                        ),
                        const SizedBox(width: AppSpacing.space2),
                        Expanded(
                          child: Text(
                            'تنبيه مالي: سيتم التراجع عن التأثيرات المالية للعملية وإعادة ضبط رصيد الدرج النقدي والمحفظة وسجل العمليات.',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.destructive,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: isLoading ? null : () => Navigator.pop(dialogContext, false),
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
                          await operationCubit.deleteOperation(operation.id);
                          if (!dialogContext.mounted) return;
                          Navigator.pop(dialogContext, true);
                          if (parentContext.mounted) {
                            ScaffoldMessenger.of(parentContext).showSnackBar(
                              const SnackBar(
                                content: Text('تم حذف العملية وإرجاع الأرصدة بنجاح'),
                                backgroundColor: AppColors.destructive,
                              ),
                            );
                          }
                        } catch (e) {
                          if (!dialogContext.mounted) return;
                          setStateDialog(() => isLoading = false);
                          Navigator.pop(dialogContext, false);
                          if (parentContext.mounted) {
                            ScaffoldMessenger.of(parentContext).showSnackBar(
                              SnackBar(
                                content: Text(ErrorMapper.map(e)),
                                backgroundColor: AppColors.destructive,
                                duration: const Duration(seconds: 4),
                              ),
                            );
                          }
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
                    : const Text('حذف وتراجع'),
              ),
            ],
          );
        },
      );
    },
  );

  return result ?? false;
}

Widget _buildRow(String label, String value) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        label,
        style: AppTextStyles.caption.copyWith(color: AppColors.mutedForeground),
      ),
      Text(
        value,
        style: AppTextStyles.caption.copyWith(
          color: AppColors.foreground,
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  );
}
