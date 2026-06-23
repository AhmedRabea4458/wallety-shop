import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:smart_expense/core/constants/app_routes.dart';
import 'package:smart_expense/core/errors/error_mapper.dart';
import 'package:smart_expense/core/theme/app_colors.dart';
import 'package:smart_expense/core/theme/app_radius.dart';
import 'package:smart_expense/core/theme/app_spacing.dart';
import 'package:smart_expense/core/theme/app_text_styles.dart';
import 'package:smart_expense/core/utils/date_formatter.dart';
import 'package:smart_expense/features/operations/domain/entities/debt_entity.dart';
import 'package:smart_expense/features/operations/domain/entities/instapay_account_entity.dart';
import 'package:smart_expense/features/operations/domain/entities/operation_entity.dart';
import 'package:smart_expense/features/operations/domain/entities/provider_type.dart';
import 'package:smart_expense/features/operations/domain/entities/wallet_entity.dart';
import 'package:smart_expense/features/operations/presentation/cubit/instapay_account_cubit.dart';
import 'package:smart_expense/features/operations/presentation/cubit/operation_cubit.dart';
import 'package:smart_expense/features/operations/presentation/cubit/operation_state.dart';
import 'package:smart_expense/features/operations/presentation/cubit/wallet_cubit.dart';
import 'package:smart_expense/features/operations/presentation/cubit/wallet_state.dart';
import 'package:smart_expense/shared/widgets/filter_chip_widget.dart';
import 'package:smart_expense/shared/widgets/search_bar.dart' as app_search;
import 'package:smart_expense/shared/widgets/transaction_row.dart';

class TransactionsPage extends StatelessWidget {
  const TransactionsPage({super.key});

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
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // AppBar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenHorizontal,
                  vertical: AppSpacing.space4,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.tune_rounded,
                        color: AppColors.foreground,
                      ),
                    ),
                    Text(
                      'العمليات',
                      style: AppTextStyles.headline.copyWith(
                        color: AppColors.foreground,
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.arrow_forward_rounded,
                        color: AppColors.foreground,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Search Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenHorizontal,
                ),
                child: app_search.SearchBar(
                  hintText: 'البحث في العمليات...',
                  onChanged: (query) {
                    context.read<OperationCubit>().search(query);
                  },
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(height: AppSpacing.space4),
            ),
            // Filter Chips
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenHorizontal,
                ),
                child: BlocBuilder<OperationCubit, OperationState>(
                  buildWhen: (previous, current) => current is OperationLoaded,
                  builder: (context, state) {
                    final selectedType = state is OperationLoaded
                        ? state.selectedOperationType
                        : null;
                    final selectedProvider = state is OperationLoaded
                        ? state.selectedProviderType
                        : null;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildFilterChip(
                                label: 'الكل',
                                isActive: selectedType == null,
                                onTap: () => context.read<OperationCubit>().filterByOperationType(null),
                              ),
                              _buildFilterChip(
                                label: 'إيداع',
                                isActive: selectedType == OperationType.deposit,
                                onTap: () => context.read<OperationCubit>().filterByOperationType(OperationType.deposit),
                              ),
                              _buildFilterChip(
                                label: 'سحب',
                                isActive: selectedType == OperationType.withdrawal,
                                onTap: () => context.read<OperationCubit>().filterByOperationType(OperationType.withdrawal),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.space2),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildFilterChip(
                                label: 'كل المزودين',
                                isActive: selectedProvider == null,
                                onTap: () => context.read<OperationCubit>().filterByProvider(null),
                              ),
                              _buildFilterChip(
                                label: 'Vodafone Cash',
                                isActive: selectedProvider == ProviderType.vodafoneCash,
                                onTap: () => context.read<OperationCubit>().filterByProvider(ProviderType.vodafoneCash),
                              ),
                              _buildFilterChip(
                                label: 'InstaPay',
                                isActive: selectedProvider == ProviderType.instaPay,
                                onTap: () => context.read<OperationCubit>().filterByProvider(ProviderType.instaPay),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(height: AppSpacing.space4),
            ),
            // BlocBuilder for operations
            BlocBuilder<OperationCubit, OperationState>(
              builder: (context, state) {
                if (state is OperationLoading) {
                  return SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.space8),
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  );
                } else if (state is OperationError) {
                  return SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.space8),
                        child: Text(
                          'حدث خطأ: ${state.message}',
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.destructive,
                          ),
                        ),
                      ),
                    ),
                  );
                } else if (state is OperationLoaded) {
                  if (state.visibleOperations.isEmpty) {
                    final bool isSearching = state.searchQuery.isNotEmpty;
                    return SliverToBoxAdapter(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.space8),
                          child: Column(
                            children: [
                              Text(
                                isSearching
                                    ? 'لا توجد نتائج للبحث'
                                    : 'لا توجد عمليات',
                                style: AppTextStyles.body.copyWith(
                                  color: AppColors.mutedForeground,
                                ),
                              ),
                              if (!isSearching) ...[
                                const SizedBox(height: AppSpacing.space4),
                                ElevatedButton(
                                  onPressed: () {
                                    context.push(AppRoutes.addOperation);
                                  },
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
                            ],
                          ),
                        ),
                      ),
                    );
                  }
                  return _OperationsList(
                    operations: state.visibleOperations,
                    operationDebts: state.operationDebts,
                  );
                }
                return const SliverToBoxAdapter(
                  child: SizedBox.shrink(),
                );
              },
            ),
            // Bottom padding
            SliverToBoxAdapter(
              child: SizedBox(height: AppSpacing.space8),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.space2),
      child: FilterChipWidget(
        label: label,
        isActive: isActive,
        onTap: onTap,
      ),
    );
  }
}

class _OperationsList extends StatelessWidget {
  final List<OperationEntity> operations;
  final Map<int, DebtEntity> operationDebts;

  const _OperationsList({required this.operations, this.operationDebts = const {}});

  @override
  Widget build(BuildContext context) {
    final grouped = _groupByDate(operations);
    final operationCubit = context.read<OperationCubit>();
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    return BlocBuilder<WalletCubit, WalletState>(
      builder: (context, walletState) {
        final wallets = walletState is WalletLoaded ? walletState.wallets : <WalletEntity>[];

        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final group = grouped[index];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date group header
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.screenHorizontal,
                      vertical: AppSpacing.space3,
                    ),
                    child: Text(
                      group.dateLabel,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.mutedForeground,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  // Operations in this group
                  ...group.operations.map((operation) {
                    final typeColor = TransactionsPage._getOperationTypeColor(operation.operationType);
                    final typeIcon = TransactionsPage._getOperationTypeIcon(operation.operationType);
                    final typeLabel = TransactionsPage._getOperationTypeLabel(operation.operationType);
                    final walletName = wallets.firstWhere(
                      (w) => w.id == operation.walletId,
                      orElse: () => WalletEntity(
                        id: 0,
                        name: '',
                        balance: 0,
                        color: const Color(0xFF6366F1),
                        createdAt: DateTime.now(),
                      ),
                    ).name;
                    final isOutgoing = operation.operationType == OperationType.deposit;
                    final providerLabel = operation.providerType.label;
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
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.screenHorizontal,
                        vertical: AppSpacing.space1,
                      ),
                      child: Column(
                        children: [
                          if (debt != null)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space5, vertical: AppSpacing.space1),
                              decoration: BoxDecoration(
                                color: debt.isPaid ? AppColors.success.withValues(alpha: 0.1) : AppColors.warning.withValues(alpha: 0.1),
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(AppRadius.lg),
                                  topRight: Radius.circular(AppRadius.lg),
                                ),
                                border: Border.all(color: AppColors.border50, width: 1),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    debt.isPaid ? '🟢 تم السداد' : '🟠 آجل',
                                    style: AppTextStyles.caption.copyWith(
                                      color: debt.isPaid ? AppColors.success : AppColors.warning,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    '${_format(debt.amount)} ج.م',
                                    style: AppTextStyles.caption.copyWith(color: AppColors.mutedForeground),
                                  ),
                                ],
                              ),
                            ),
                          Dismissible(
                        key: Key('operation_${operation.id}'),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          decoration: BoxDecoration(
                            color: AppColors.destructive,
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                          ),
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.only(left: AppSpacing.space5),
                          child: const Icon(
                            Icons.delete_rounded,
                            color: Colors.white,
                          ),
                        ),
                        confirmDismiss: (direction) async {
                          if (debt != null) {
                            scaffoldMessenger.showSnackBar(
                              const SnackBar(
                                content: Text('لا يمكن تعديل أو حذف عملية مرتبطة بدين'),
                                backgroundColor: AppColors.destructive,
                              ),
                            );
                            return false;
                          }
                          try {
                            await operationCubit.deleteOperation(operation.id);
                            return true;
                          } catch (e) {
                            scaffoldMessenger.showSnackBar(
                              SnackBar(
                                content: Text(ErrorMapper.map(e)),
                                backgroundColor: AppColors.destructive,
                              ),
                            );
                            return false;
                          }
                        },
                        onDismissed: (_) {
                          scaffoldMessenger.showSnackBar(
                            const SnackBar(
                              content: Text('تم حذف العملية'),
                              backgroundColor: AppColors.destructive,
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                            border: Border.all(
                              color: AppColors.border50,
                              width: 1,
                            ),
                          ),
                          child: TransactionRow(
                            name: title,
                            category: providerLabel,
                            date: DateFormatter.formatTransactionDate(operation.createdAt),
                            amount: '${operation.amount.toStringAsFixed(0)} ج.م',
                            iconBackgroundColor: AppColors.withAlpha(typeColor, 0.15),
                            iconColor: typeColor,
                            icon: typeIcon,
                            isExpense: isOutgoing,
                            onTap: () {
                              if (debt != null) {
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
                        ),
                      ),
                        ]
                      ),
                    );

                  }),
                ],
              );
            },
            childCount: grouped.length,
          ),
        );
      },
    );
  }
  static String _format(double amount) {
    return NumberFormat('#,##0.##', 'ar').format(amount);
  }
  List<_OperationGroup> _groupByDate(List<OperationEntity> operations) {
    final Map<String, List<OperationEntity>> map = {};
    for (final o in operations) {
      final key = DateFormatter.groupKey(o.createdAt);
      map.putIfAbsent(key, () => []).add(o);
    }
    return map.entries.map((e) => _OperationGroup(e.key, e.value)).toList();
  }
}

class _OperationGroup {
  final String dateLabel;
  final List<OperationEntity> operations;

  _OperationGroup(this.dateLabel, this.operations);
}
   