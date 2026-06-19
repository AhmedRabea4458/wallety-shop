import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:smart_expense/core/constants/app_routes.dart';
import 'package:smart_expense/core/theme/app_colors.dart';
import 'package:smart_expense/core/theme/app_radius.dart';
import 'package:smart_expense/core/theme/app_spacing.dart';
import 'package:smart_expense/core/theme/app_text_styles.dart';
import 'package:smart_expense/features/operations/domain/entities/operation_entity.dart';
import 'package:smart_expense/features/operations/domain/entities/provider_type.dart';
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
import 'package:smart_expense/features/operations/presentation/widgets/cash_drawer_card.dart';
import 'package:smart_expense/features/operations/presentation/widgets/operation_list.dart';
import 'package:smart_expense/features/home/presentation/widgets/hero_balance_card.dart';
import 'package:smart_expense/features/home/presentation/widgets/home_wallet_card.dart';
import 'package:smart_expense/features/home/presentation/widgets/quick_action_button.dart';
import 'package:smart_expense/features/home/presentation/widgets/shift_status_card.dart';

class HomePage extends StatelessWidget {
  final VoidCallback? onNavigateToOperations;

  const HomePage({
    super.key,
    this.onNavigateToOperations,
  });

  static String _formatAmount(double amount) {
    return NumberFormat('#,##0.##', 'ar').format(amount);
  }

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
                    if (walletState is WalletLoaded) {
                      wallets = walletState.wallets;
                    }

                    List<OperationEntity> operations = [];
                    double todayCommission = 0;
                    double todayVodafoneCommission = 0;
                    double todayInstaPayCommission = 0;
                    int todayCount = 0;

                    if (operationState is OperationLoaded) {
                      operations = operationState.allOperations;
                      final today = DateTime(now.year, now.month, now.day);
                      final todayOps = operations.where((o) {
                        final d = o.createdAt;
                        return d.year == today.year && d.month == today.month && d.day == today.day;
                      });
                      todayCount = todayOps.length;
                      todayCommission = todayOps.fold(0.0, (sum, o) => sum + o.commission);
                      todayVodafoneCommission = todayOps
                          .where((o) => o.providerType == ProviderType.vodafoneCash)
                          .fold(0.0, (sum, o) => sum + o.commission);
                      todayInstaPayCommission = todayOps
                          .where((o) => o.providerType == ProviderType.instaPay)
                          .fold(0.0, (sum, o) => sum + o.commission);
                    }

                    final adjustments = adjustmentState is WalletAdjustmentLoaded
                        ? adjustmentState.adjustments
                        : <WalletAdjustmentEntity>[];

                    final totalBalance = wallets.fold(0.0, (sum, w) => sum + w.balance);

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
                    // Shift Status Card
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
                    // Outstanding Debt Card
                    BlocBuilder<DebtCubit, DebtState>(
                      builder: (context, debtState) {
                        final totalOutstanding = context.read<DebtCubit>().totalOutstanding;
                        if (totalOutstanding > 0) {
                          return SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
                              child: Container(
                                padding: const EdgeInsets.all(AppSpacing.space4),
                                decoration: BoxDecoration(
                                  color: AppColors.card,
                                  borderRadius: BorderRadius.circular(AppRadius.lg),
                                  border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(color: AppColors.warning, shape: BoxShape.circle),
                                    ),
                                    const SizedBox(width: AppSpacing.space2),
                                    Expanded(
                                      child: Text(
                                        'إجمالي الآجل: ${_formatAmount(totalOutstanding)} ج.م',
                                        style: AppTextStyles.body.copyWith(color: AppColors.foreground, fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }
                        return const SliverToBoxAdapter(child: SizedBox.shrink());
                      },
                    ),
                    SliverToBoxAdapter(
                      child: SizedBox(height: AppSpacing.space4),
                    ),
                    // Hero Balance Card
                    SliverToBoxAdapter(
                      child: HeroBalanceCard(
                        totalBalance: totalBalance,
                        todayCount: todayCount,
                        todayCommission: todayCommission,
                        todayVodafoneCommission: todayVodafoneCommission,
                        todayInstaPayCommission: todayInstaPayCommission,
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: SizedBox(height: AppSpacing.space6),
                    ),
                    // Cash Drawer Card
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.screenHorizontal,
                        ),
                        child: BlocBuilder<CashDrawerCubit, CashDrawerState>(
                          builder: (context, cashState) {
                            if (cashState is CashDrawerLoaded) {
                              return CashDrawerCard(
                                balance: cashState.cashDrawer.balance,
                                initialBalance: cashState.cashDrawer.initialBalance,
                                updatedAt: cashState.cashDrawer.updatedAt,
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: SizedBox(height: AppSpacing.space6),
                    ),
                    // Wallet Cards
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
                                itemCount: wallets.length,
                                separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.space2),
                                itemBuilder: (context, index) {
                                  final wallet = wallets[index];
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
                    // Quick Actions
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
                                const SizedBox(width: AppSpacing.space2),
                                Expanded(
                                  child: QuickActionButton(
                                    label: 'العمليات',
                                    icon: Icons.receipt_long_rounded,
                                    color: AppColors.primary,
                                    onTap: onNavigateToOperations,
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
