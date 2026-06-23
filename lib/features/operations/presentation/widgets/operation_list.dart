import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:smart_expense/core/constants/app_routes.dart';
import 'package:smart_expense/core/theme/app_colors.dart';
import 'package:smart_expense/core/theme/app_radius.dart';
import 'package:smart_expense/core/theme/app_spacing.dart';
import 'package:smart_expense/core/theme/app_text_styles.dart';
import 'package:smart_expense/core/utils/date_formatter.dart';
import 'package:smart_expense/features/home/presentation/widgets/section_header.dart';
import 'package:smart_expense/features/operations/domain/entities/debt_entity.dart';
import 'package:smart_expense/features/operations/domain/entities/instapay_account_entity.dart';
import 'package:smart_expense/features/operations/domain/entities/operation_entity.dart';
import 'package:smart_expense/features/operations/domain/entities/provider_type.dart';
import 'package:smart_expense/features/operations/domain/entities/wallet_entity.dart';
import 'package:smart_expense/features/operations/presentation/cubit/instapay_account_cubit.dart';
import 'package:smart_expense/shared/widgets/transaction_row.dart';

class OperationList extends StatelessWidget {
  final List<OperationEntity> operations;
  final List<WalletEntity> wallets;
  final VoidCallback? onViewAll;
  final VoidCallback? onAddOperation;
  final Map<int, DebtEntity> operationDebts;

  const OperationList({
    super.key,
    required this.operations,
    required this.wallets,
    this.onViewAll,
    this.onAddOperation,
    this.operationDebts = const {},
  });

  static String _formatAmount(double amount) {
    return '${NumberFormat('#,##0.##', 'ar').format(amount)} ج.م';
  }

  static String _getOperationTypeLabel(OperationType type) {
    switch (type) {
      case OperationType.deposit:
        return 'إيداع';
      case OperationType.withdrawal:
        return 'سحب';
    }
  }

  static Color _getOperationTypeColor(OperationType type) {
    switch (type) {
      case OperationType.deposit:
        return AppColors.destructive;
      case OperationType.withdrawal:
        return AppColors.success;
    }
  }

  static IconData _getOperationTypeIcon(OperationType type) {
    switch (type) {
      case OperationType.deposit:
        return Icons.arrow_upward_rounded;
      case OperationType.withdrawal:
        return Icons.arrow_downward_rounded;
    }
  }

  String _getWalletName(int walletId) {
    return wallets.firstWhere(
      (w) => w.id == walletId,
      orElse: () => WalletEntity(
        id: 0,
        name: '',
        balance: 0,
        color: const Color(0xFF6366F1),
        createdAt: DateTime.now(),
      ),
    ).name;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
      ),
      child: Column(
        children: [
          SectionHeader(
            title: 'العمليات الأخيرة',
            actionLabel: 'عرض الكل',
            onTap: onViewAll,
          ),
          const SizedBox(height: AppSpacing.space4),
          Container(
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(
                color: AppColors.border45,
                width: 1,
              ),
            ),
            child: Column(
              children: operations.isEmpty
                  ? [
                      Padding(
                        padding: const EdgeInsets.all(AppSpacing.space6),
                        child: Column(
                          children: [
                            Text(
                              'ابدأ بإضافة عمليتك الأولى',
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.mutedForeground,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.space4),
                            if (onAddOperation != null)
                              ElevatedButton(
                                onPressed: onAddOperation,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: AppColors.primaryForeground,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(AppRadius.md),
                                  ),
                                ),
                                child: Text(
                                  'إضافة عملية',
                                  style: AppTextStyles.body.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ]
                  : operations.take(3).map((operation) {
                      final typeLabel = _getOperationTypeLabel(operation.operationType);
                      final typeColor = _getOperationTypeColor(operation.operationType);
                      final typeIcon = _getOperationTypeIcon(operation.operationType);
                      final walletName = _getWalletName(operation.walletId);
                      final providerLabel = operation.providerType.label;
                      final isOutgoing = operation.operationType == OperationType.deposit;
                      String instaPayAccountName = '';
                      if (operation.providerType == ProviderType.instaPay) {
                        final cubit = context.read<InstaPayAccountCubit>();
                        if (cubit.state is InstaPayAccountLoaded) {
                          final accounts = (cubit.state as InstaPayAccountLoaded).accounts;
                          final match = accounts.firstWhere(
                            (a) => a.id == operation.instaPayAccountId,
                            orElse: () => InstaPayAccountEntity(
                              id: 0, name: operation.providerType.label, createdAt: DateTime.now(),
                            ),
                          );
                          instaPayAccountName = match.name;
                        } else {
                          instaPayAccountName = operation.providerType.label;
                        }
                      }
                      final title = operation.notes?.trim().isNotEmpty == true
                          ? operation.notes!
                          : operation.providerType == ProviderType.vodafoneCash
                              ? '$typeLabel - $walletName'
                              : '$typeLabel - $instaPayAccountName';
                      final debt = operationDebts[operation.id];
                      return Column(
                        children: [
                          if (debt != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: AppSpacing.space1),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space4, vertical: AppSpacing.space1),
                                decoration: BoxDecoration(
                                  color: debt.isPaid ? AppColors.success.withValues(alpha: 0.1) : AppColors.warning.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(AppRadius.sm),
                                ),
                                child: Text(
                                  debt.isPaid ? '🟢 تم السداد' : '🟠 آجل',
                                  style: AppTextStyles.caption.copyWith(
                                    color: debt.isPaid ? AppColors.success : AppColors.warning,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          TransactionRow(
                            name: title,
                            category: providerLabel,
                            date: DateFormatter.formatTransactionDate(operation.createdAt),
                            amount: _formatAmount(operation.amount),
                            iconBackgroundColor: AppColors.withAlpha(typeColor, 0.15),
                            iconColor: typeColor,
                            icon: typeIcon,
                            isExpense: isOutgoing,
                            onTap: () {
                              final hasDebt = operationDebts.containsKey(operation.id);
                              if (hasDebt) {
                                context.push(
                                  AppRoutes.operationDetail,
                                  extra: operation,
                                );
                              } else {
                                context.push(
                                  AppRoutes.editOperation,
                                  extra: operation,
                                );
                              }
                            },
                          ),
                          if (operation != operations.last && operation != operations.take(3).last)
                            const Divider(
                              color: AppColors.border45,
                              indent: AppSpacing.space5,
                              endIndent: AppSpacing.space5,
                            ),
                        ],
                      );
                    }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
