import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:smart_expense/core/theme/app_colors.dart';
import 'package:smart_expense/core/theme/app_radius.dart';
import 'package:smart_expense/core/theme/app_spacing.dart';
import 'package:smart_expense/core/theme/app_text_styles.dart';
import 'package:smart_expense/core/utils/date_formatter.dart';
import 'package:smart_expense/features/operations/domain/entities/debtor_entity.dart';
import 'package:smart_expense/features/operations/domain/entities/instapay_account_entity.dart';
import 'package:smart_expense/features/operations/domain/entities/operation_entity.dart';
import 'package:smart_expense/features/operations/domain/entities/provider_type.dart';
import 'package:smart_expense/features/operations/domain/entities/wallet_entity.dart';
import 'package:smart_expense/features/operations/presentation/cubit/debt_cubit.dart';
import 'package:smart_expense/features/operations/presentation/cubit/instapay_account_cubit.dart';
import 'package:smart_expense/features/operations/presentation/cubit/operation_cubit.dart';
import 'package:smart_expense/features/operations/presentation/cubit/operation_state.dart';
import 'package:smart_expense/features/operations/presentation/cubit/wallet_cubit.dart';
import 'package:smart_expense/features/operations/presentation/cubit/wallet_state.dart';

class OperationDetailPage extends StatelessWidget {
  final OperationEntity operation;

  const OperationDetailPage({
    super.key,
    required this.operation,
  });

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

  static String _getOperationTypeLabel(OperationType type) {
    switch (type) {
      case OperationType.deposit:
        return 'إيداع';
      case OperationType.withdrawal:
        return 'سحب';
    }
  }

  @override
  Widget build(BuildContext context) {
    final typeColor = _getOperationTypeColor(operation.operationType);
    final typeIcon = _getOperationTypeIcon(operation.operationType);
    final typeLabel = _getOperationTypeLabel(operation.operationType);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenHorizontal,
                  vertical: AppSpacing.space4,
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Container(
                        padding: const EdgeInsets.all(AppSpacing.space2),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(AppRadius.full),
                        ),
                        child: const Icon(
                          Icons.arrow_forward_rounded,
                          color: AppColors.foreground,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.space3),
                    Expanded(
                      child: Text(
                        'تفاصيل العملية',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.headline.copyWith(
                          color: AppColors.foreground,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenHorizontal,
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.space6),
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
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.space4),
                            decoration: BoxDecoration(
                              color: AppColors.withAlpha(typeColor, 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              typeIcon,
                              color: typeColor,
                              size: 32,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.space4),
                          Text(
                            '${operation.amount.toStringAsFixed(0)} ج.م',
                            style: AppTextStyles.headline.copyWith(
                              color: AppColors.foreground,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.space2),
                          Text(
                            typeLabel,
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: typeColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.space4),
                    _DebtBanner(operation: operation),
                    const SizedBox(height: AppSpacing.space4),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.space5),
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
                          _DetailRow(
                            label: 'المزود',
                            value: operation.providerType.label,
                          ),
                          const Divider(color: AppColors.border45),
                          if (operation.providerType == ProviderType.instaPay)
                            BlocBuilder<InstaPayAccountCubit, InstaPayAccountState>(
                              builder: (context, state) {
                                String accountName = '--';
                                if (state is InstaPayAccountLoaded) {
                                  final account = state.accounts.firstWhere(
                                    (a) => a.id == operation.instaPayAccountId,
                                    orElse: () => InstaPayAccountEntity(
                                      id: 0,
                                      name: 'غير معروف',
                                      createdAt: DateTime.now(),
                                    ),
                                  );
                                  accountName = account.name;
                         }
                                return Column(
                                  children: [
                                    _DetailRow(
                                      label: 'الحساب',
                                      value: accountName,
                                    ),
                                    const Divider(color: AppColors.border45),
                                  ],
                                );
                              },
                            ),
                          if (operation.providerType == ProviderType.vodafoneCash)
                            BlocBuilder<WalletCubit, WalletState>(
                              builder: (context, state) {
                                final walletName = state is WalletLoaded
                                    ? state.wallets.firstWhere(
                                        (w) => w.id == operation.walletId,
                                        orElse: () => WalletEntity(
                                          id: 0,
                                          name: 'غير معروف',
                                          balance: 0,
                                          color: const Color(0xFF6366F1),
                                          createdAt: DateTime.now(),
                                        ),
                                      ).name
                                    : '--';
                                return Column(
                                  children: [
                                    _DetailRow(
                                      label: 'المحفظة',
                                      value: walletName,
                                    ),
                                    const Divider(color: AppColors.border45),
                                  ],
                                );
                              },
                            ),
                          _DetailRow(
                            label: 'رقم الهاتف',
                            value: operation.phoneNumber ?? '--',
                          ),
                          const Divider(color: AppColors.border45),
                          _DetailRow(
                            label: 'العمولة',
                            value: '${operation.commission.toStringAsFixed(0)} ج.م',
                          ),
                          if (operation.providerType == ProviderType.vodafoneCash) ...[
                            const Divider(color: AppColors.border45),
                            _DetailRow(
                              label: 'رسوم الشبكة',
                              value: '${operation.networkFee.toStringAsFixed(0)} ج.م',
                            ),
                          ],
                          const Divider(color: AppColors.border45),
                          _DetailRow(
                            label: 'الملاحظات',
                            value: operation.notes?.isNotEmpty == true ? operation.notes! : '--',
                          ),
                          const Divider(color: AppColors.border45),
                          _DetailRow(
                            label: 'التاريخ',
                            value: DateFormatter.formatTransactionDate(operation.createdAt),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.space8),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DebtBanner extends StatelessWidget {
  final OperationEntity operation;

  const _DebtBanner({required this.operation});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OperationCubit, OperationState>(
      builder: (context, state) {
        final debt = state is OperationLoaded ? state.operationDebts[operation.id] : null;
        if (debt == null) return const SizedBox.shrink();

        return FutureBuilder<DebtorEntity?>(
          future: context.read<DebtCubit>().getDebtorById(debt.debtorId),
          builder: (context, snapshot) {
            final debtorName = snapshot.data?.name ?? '--';
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.space4),
              decoration: BoxDecoration(
                color: debt.isPaid ? AppColors.success.withValues(alpha: 0.1) : AppColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(
                  color: debt.isPaid ? AppColors.success.withValues(alpha: 0.3) : AppColors.warning.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        debt.isPaid ? Icons.check_circle_rounded : Icons.access_time_rounded,
                        color: debt.isPaid ? AppColors.success : AppColors.warning,
                        size: 20,
                      ),
                      const SizedBox(width: AppSpacing.space2),
                      Text(
                        debt.isPaid ? 'تم سداد الآجل' : 'عملية آجل',
                        style: AppTextStyles.body.copyWith(
                          color: debt.isPaid ? AppColors.success : AppColors.warning,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.space2),
                  Text(
                    'العميل: $debtorName',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.foreground,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space1),
                  Text(
                    'مبلغ الدين: ${NumberFormat('#,##0.##', 'ar').format(debt.amount)} ج.م',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.foreground,
                    ),
                  ),
                  if (debt.isPaid && debt.paidAt != null)
                    Text(
                      'تاريخ السداد: ${DateFormatter.formatTransactionDate(debt.paidAt!)}',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.mutedForeground,
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.space3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.body.copyWith(
              color: AppColors.mutedForeground,
            ),
          ),
          const SizedBox(width: AppSpacing.space4),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.left,
              style: AppTextStyles.body.copyWith(
                color: AppColors.foreground,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
