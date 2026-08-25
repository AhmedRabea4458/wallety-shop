import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:smart_expense/core/constants/app_routes.dart';
import 'package:smart_expense/core/theme/app_colors.dart';
import 'package:smart_expense/core/theme/app_radius.dart';
import 'package:smart_expense/core/theme/app_spacing.dart';
import 'package:smart_expense/core/theme/app_text_styles.dart';
import 'package:smart_expense/features/operations/domain/entities/debt_type.dart';
import 'package:smart_expense/features/operations/domain/entities/operation_entity.dart';
import 'package:smart_expense/features/operations/domain/entities/wallet_adjustment_entity.dart';
import 'package:smart_expense/features/operations/domain/entities/wallet_entity.dart';
import 'package:smart_expense/features/operations/domain/utils/wallet_limit_calculator.dart';
import 'package:smart_expense/features/operations/presentation/cubit/cash_drawer_cubit.dart';
import 'package:smart_expense/features/operations/presentation/cubit/cash_drawer_state.dart';
import 'package:smart_expense/features/operations/presentation/cubit/operation_cubit.dart';
import 'package:smart_expense/features/operations/presentation/cubit/operation_state.dart';
import 'package:smart_expense/features/operations/presentation/cubit/active_shift_cubit.dart';
import 'package:smart_expense/features/operations/presentation/cubit/active_shift_state.dart';
import 'package:smart_expense/features/operations/presentation/cubit/debt_cubit.dart';
import 'package:smart_expense/features/operations/presentation/cubit/debt_state.dart';
import 'package:smart_expense/features/operations/presentation/cubit/wallet_adjustment_cubit.dart';
import 'package:smart_expense/features/operations/presentation/cubit/wallet_adjustment_state.dart';
import 'package:smart_expense/features/operations/presentation/cubit/wallet_cubit.dart';
import 'package:smart_expense/features/operations/presentation/cubit/wallet_state.dart';

import 'package:smart_expense/features/operations/presentation/widgets/operation_list.dart';
import 'package:smart_expense/features/operations/presentation/widgets/dialogs/edit_cash_drawer_dialog.dart';
import 'package:smart_expense/features/home/presentation/widgets/dashboard_balances_section.dart';
import 'package:smart_expense/features/home/presentation/widgets/dashboard_today_activity_section.dart';
import 'package:smart_expense/features/home/presentation/widgets/home_wallet_card.dart';
import 'package:smart_expense/features/home/presentation/widgets/quick_action_button.dart';
import 'package:smart_expense/features/home/presentation/widgets/shift_status_card.dart';

class HomePage extends StatelessWidget {
  final VoidCallback? onNavigateToOperations;

  const HomePage({
    super.key,
    this.onNavigateToOperations,
  });


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<WalletCubit, WalletState>(
          builder: (context, walletState) {
            return BlocBuilder<OperationCubit, OperationState>(
              builder: (context, operationState) {
                return BlocBuilder<WalletAdjustmentCubit, WalletAdjustmentState>(
                  builder: (context, adjustmentState) {
                    return BlocConsumer<ActiveShiftCubit, ActiveShiftState>(
                      listener: (context, shiftState) {
                        if (shiftState is ActiveShiftError) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(shiftState.message),
                              backgroundColor: AppColors.destructive,
                              action: SnackBarAction(
                                label: 'إعادة المحاولة',
                                textColor: AppColors.destructiveForeground,
                                onPressed: () => context.read<ActiveShiftCubit>().loadActiveShift(),
                              ),
                            ),
                          );
                        }
                      },
                      builder: (context, shiftState) {
                    final now = DateTime.now();
                    final monthName = DateFormat('MMMM y', 'ar').format(now);

                    final isLoading = walletState is WalletLoading ||
                        operationState is OperationLoading ||
                        adjustmentState is WalletAdjustmentLoading;

                    if (isLoading) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    List<WalletEntity> wallets = [];
                    List<WalletEntity> activeWallets = [];
                    if (walletState is WalletLoaded) {
                      wallets = walletState.wallets;
                      activeWallets = walletState.activeWallets;
                    }

                    List<OperationEntity> operations = [];
                    double todayDeposits = 0;
                    double todayWithdrawals = 0;
                    double totalCommissions = 0;

                    if (operationState is OperationLoaded) {
                      operations = operationState.allOperations;
                      final today = DateTime(now.year, now.month, now.day);
                      final todayOps = operations.where((o) {
                        final d = o.createdAt;
                        return d.year == today.year && d.month == today.month && d.day == today.day;
                      });
                      todayDeposits = todayOps
                          .where((o) => o.operationType == OperationType.deposit)
                          .fold(0.0, (sum, o) => sum + o.amount);
                      todayWithdrawals = todayOps
                          .where((o) => o.operationType == OperationType.withdrawal)
                          .fold(0.0, (sum, o) => sum + o.amount);
                      totalCommissions = todayOps.fold(
                        0.0,
                        (sum, o) => sum + o.commission,
                      );
                    }

                    final adjustments = adjustmentState is WalletAdjustmentLoaded
                        ? adjustmentState.adjustments
                        : <WalletAdjustmentEntity>[];

                    final totalWalletBalance = activeWallets.fold(0.0, (sum, w) => sum + w.balance);

                    return CustomScrollView(
                      slivers: [
                        SliverToBoxAdapter(
                          child: SizedBox(height: AppSpacing.space4),
                        ),
                    // Header
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.screenHorizontal,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Wallety Shop',
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.mutedForeground,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.space1),
                                Text(
                                  monthName,
                                  style: AppTextStyles.headline.copyWith(
                                    color: AppColors.foreground,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.primary,
                                    AppColors.gradientHeroEnd,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(AppRadius.lg),
                              ),
                              child: const Icon(
                                Icons.account_balance_wallet,
                                color: AppColors.primaryForeground,
                                size: 22,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: SizedBox(height: AppSpacing.space6),
                    ),
                    // 1. Shift Status Card
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.screenHorizontal,
                        ),
                        child: const ShiftStatusCard(),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: SizedBox(height: AppSpacing.space4),
                    ),

                    // 2. Current Balances (Clean separate cards for Cash Drawer, Total Wallets, Receivables, Payables)
                    BlocBuilder<DebtCubit, DebtState>(
                      builder: (context, debtState) {
                        final debtCubit = context.read<DebtCubit>();
                        final customerReceivables = debtCubit.totalOutstanding;
                        final payables = debtCubit.totalOutstandingPayable;
                        final todayCollections = debtCubit.todayCustomerDebtCollected;
                        final todaySettlements = debtCubit.todayPayablesSettled;

                        return BlocBuilder<CashDrawerCubit, CashDrawerState>(
                          builder: (context, cashState) {
                            final cashDrawerBalance = cashState is CashDrawerLoaded
                                ? cashState.cashDrawer.balance
                                : 0.0;

                            return SliverToBoxAdapter(
                              child: Column(
                                children: [
                                  DashboardBalancesSection(
                                    totalWalletBalance: totalWalletBalance,
                                    cashDrawerBalance: cashDrawerBalance,
                                    customerReceivables: customerReceivables,
                                    payables: payables,
                                    onEditCashDrawer: () {
                                      showEditCashDrawerDialog(
                                        parentContext: context,
                                        cashDrawerCubit: context.read<CashDrawerCubit>(),
                                        currentDrawerBalance: cashDrawerBalance,
                                      );
                                    },
                                  ),
                                  const SizedBox(height: AppSpacing.space4),
                                  // 3. Today's Activity Section
                                  DashboardTodayActivitySection(
                                    todayDeposits: todayDeposits,
                                    todayWithdrawals: todayWithdrawals,
                                    todayCollections: todayCollections,
                                    todaySettlements: todaySettlements,
                                    totalCommissions: totalCommissions,
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                    SliverToBoxAdapter(
                      child: SizedBox(height: AppSpacing.space6),
                    ),

                    // 4. Wallet Cards
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.screenHorizontal,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'المحافظ',
                                  style: AppTextStyles.headline.copyWith(
                                    color: AppColors.foreground,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => context.push(AppRoutes.walletManagement),
                                  child: Text(
                                    'إدارة',
                                    style: AppTextStyles.body.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.space4),
                            SizedBox(
                              height: 152,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: activeWallets.length,
                                separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.space2),
                                itemBuilder: (context, index) {
                                  final wallet = activeWallets[index];
                                  final usage = WalletLimitCalculator.calculate(
                                    wallet: wallet,
                                    operations: operations,
                                    adjustments: adjustments,
                                  );
                                  return SizedBox(
                                    width: 174,
                                    child: HomeWalletCard(
                                      wallet: wallet,
                                      usage: usage,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: SizedBox(height: AppSpacing.space6),
                    ),

                    // 5. Quick Actions (Deposit, Withdrawal, Customer Debt, Payable, Cash Drawer Adjustment)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.screenHorizontal,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'العمليات السريعة',
                              style: AppTextStyles.headline.copyWith(
                                color: AppColors.foreground,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.space4),
                            // Row 1: Deposit & Withdrawal
                            Row(
                              children: [
                                Expanded(
                                  child: QuickActionButton(
                                    label: 'إيداع',
                                    icon: Icons.arrow_upward_rounded,
                                    color: AppColors.destructive,
                                    onTap: () {
                                      context.push(AppRoutes.addOperation);
                                    },
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.space2),
                                Expanded(
                                  child: QuickActionButton(
                                    label: 'سحب',
                                    icon: Icons.arrow_downward_rounded,
                                    color: AppColors.success,
                                    onTap: () {
                                      context.push(AppRoutes.addOperation);
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.space2),
                            // Row 2: Customer Debt, Payable, Cash Drawer Adjustment
                            Row(
                              children: [
                                Expanded(
                                  child: QuickActionButton(
                                    label: 'آجل عميل',
                                    icon: Icons.person_add_alt_1_rounded,
                                    color: const Color(0xFF10B981),
                                    onTap: () {
                                      context.read<DebtCubit>().selectLiabilityType(DebtType.customerDebt);
                                      context.push(AppRoutes.debtors);
                                    },
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.space2),
                                Expanded(
                                  child: QuickActionButton(
                                    label: 'مستحق علينا',
                                    icon: Icons.request_quote_rounded,
                                    color: const Color(0xFFF97316),
                                    onTap: () {
                                      context.read<DebtCubit>().selectLiabilityType(DebtType.payable);
                                      context.push(AppRoutes.debtors);
                                    },
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.space2),
                                Expanded(
                                  child: QuickActionButton(
                                    label: 'تعديل الدرج',
                                    icon: Icons.tune_rounded,
                                    color: const Color(0xFFF59E0B),
                                    onTap: () {
                                      final cashCubit = context.read<CashDrawerCubit>();
                                      final balance = cashCubit.state is CashDrawerLoaded
                                          ? (cashCubit.state as CashDrawerLoaded).cashDrawer.balance
                                          : 0.0;
                                      showEditCashDrawerDialog(
                                        parentContext: context,
                                        cashDrawerCubit: cashCubit,
                                        currentDrawerBalance: balance,
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: SizedBox(height: AppSpacing.space6),
                    ),
                    // OperationList
                    SliverToBoxAdapter(
                      child: OperationList(
                        operations: operations,
                        wallets: wallets,
                        operationDebts: operationState is OperationLoaded ? operationState.operationDebts : {},
                        onViewAll: onNavigateToOperations,
                        onAddOperation: () {
                          context.push(AppRoutes.addOperation);
                        },
                      ),
                    ),
                    // Bottom padding
                    SliverToBoxAdapter(
                      child: SizedBox(height: AppSpacing.space8),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  },
),
),
);
  }
}
