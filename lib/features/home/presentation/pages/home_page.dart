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
import 'package:smart_expense/features/operations/domain/entities/wallet_usage.dart';
import 'package:smart_expense/features/operations/domain/utils/wallet_limit_calculator.dart';
import 'package:smart_expense/features/operations/presentation/cubit/cash_drawer_cubit.dart';
import 'package:smart_expense/features/operations/presentation/cubit/cash_drawer_state.dart';
import 'package:smart_expense/features/operations/presentation/cubit/operation_cubit.dart';
import 'package:smart_expense/features/operations/presentation/cubit/operation_state.dart';
import 'package:smart_expense/features/operations/presentation/cubit/wallet_adjustment_cubit.dart';
import 'package:smart_expense/features/operations/presentation/cubit/wallet_adjustment_state.dart';
import 'package:smart_expense/features/operations/presentation/cubit/wallet_cubit.dart';
import 'package:smart_expense/features/operations/presentation/cubit/wallet_state.dart';
import 'package:smart_expense/features/operations/presentation/widgets/cash_drawer_card.dart';
import 'package:smart_expense/features/operations/presentation/widgets/operation_list.dart';
import 'package:smart_expense/features/operations/presentation/widgets/wallet_limit_indicator.dart';

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
                    // Hero Balance Card
                    SliverToBoxAdapter(
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.screenHorizontal,
                        ),
                        padding: const EdgeInsets.all(AppSpacing.space6),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF6366F1),
                              const Color(0xFF8B5CF6),
                              const Color(0xFFA855F7),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(AppRadius.xxl),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF6366F1).withValues(alpha: 0.3),
                              blurRadius: 24,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'إجمالي الرصيد',
                                  style: AppTextStyles.body.copyWith(
                                    color: Colors.white.withValues(alpha: 0.8),
                                  ),
                                ),
                                Icon(
                                  Icons.visibility_outlined,
                                  color: Colors.white.withValues(alpha: 0.8),
                                  size: 20,
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.space4),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  _formatAmount(totalBalance),
                                  style: AppTextStyles.hero.copyWith(
                                    color: Colors.white,
                                    fontSize: 42,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.space2),
                                Text(
                                  'ج.م',
                                  style: AppTextStyles.bodyLarge.copyWith(
                                    color: Colors.white.withValues(alpha: 0.8),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.space6),
                            Divider(
                              color: Colors.white.withValues(alpha: 0.15),
                              thickness: 1,
                              height: 1,
                            ),
                            const SizedBox(height: AppSpacing.space4),
                            Row(
                              children: [
                                Expanded(
                                  child: _HeroStat(
                                    label: 'العمليات اليوم',
                                    value: todayCount.toString(),
                                    icon: Icons.receipt_long_outlined,
                                  ),
                                ),
                                Container(
                                  width: 1,
                                  height: 40,
                                  color: Colors.white.withValues(alpha: 0.15),
                                ),
                                Expanded(
                                  child: _HeroStat(
                                    label: 'إجمالي العمولات',
                                    value: '${_formatAmount(todayCommission)} ج.م',
                                    icon: Icons.trending_up_outlined,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.space4),
                            Divider(
                              color: Colors.white.withValues(alpha: 0.15),
                              thickness: 1,
                              height: 1,
                            ),
                            const SizedBox(height: AppSpacing.space4),
                            Row(
                              children: [
                                Expanded(
                                  child: _HeroStat(
                                    label: 'Vodafone Cash',
                                    value: '${_formatAmount(todayVodafoneCommission)} ج.م',
                                    icon: Icons.account_balance_wallet_outlined,
                                  ),
                                ),
                                Container(
                                  width: 1,
                                  height: 40,
                                  color: Colors.white.withValues(alpha: 0.15),
                                ),
                                Expanded(
                                  child: _HeroStat(
                                    label: 'InstaPay',
                                    value: '${_formatAmount(todayInstaPayCommission)} ج.م',
                                    icon: Icons.point_of_sale_outlined,
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
                                    child: _WalletCard(
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
                                  child: _QuickActionButton(
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
                                  child: _QuickActionButton(
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
                                  child: _QuickActionButton(
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
        ),
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _HeroStat({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: AppSpacing.space1),
        Row(
          children: [
            Icon(
              icon,
              size: 14,
              color: Colors.white.withValues(alpha: 0.8),
            ),
            const SizedBox(width: AppSpacing.space2),
            Text(
              value,
              style: AppTextStyles.bodyLarge.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _WalletCard extends StatelessWidget {
  final WalletEntity wallet;
  final WalletUsage usage;

  const _WalletCard({
    required this.wallet,
    required this.usage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.space4),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: wallet.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: AppSpacing.space2),
              Expanded(
                child: Text(
                  wallet.name,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.mutedForeground,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.space1),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerRight,
            child: Text(
              '${NumberFormat('#,##0.##', 'ar').format(wallet.balance)} ج.م',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.foreground,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.space3),
          WalletLimitIndicator(
            label: 'يومي',
            used: usage.dailyUsed,
            limit: usage.dailyLimit,
          ),
          const SizedBox(height: AppSpacing.space2),
          WalletLimitIndicator(
            label: 'شهري',
            used: usage.monthlyUsed,
            limit: usage.monthlyLimit,
          ),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _QuickActionButton({
    required this.label,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Container(
        padding: const EdgeInsets.symmetric(
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
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 22,
              ),
            ),
            const SizedBox(height: AppSpacing.space2),
            Text(
              label,
              style: AppTextStyles.body.copyWith(
                color: AppColors.foreground,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
