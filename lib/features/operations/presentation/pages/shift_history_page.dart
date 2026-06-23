import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:smart_expense/core/constants/app_routes.dart';
import 'package:smart_expense/core/theme/app_colors.dart';
import 'package:smart_expense/core/theme/app_radius.dart';
import 'package:smart_expense/core/theme/app_spacing.dart';
import 'package:smart_expense/core/theme/app_text_styles.dart';
import 'package:smart_expense/features/operations/presentation/cubit/shift_history_cubit.dart';
import 'package:smart_expense/features/operations/presentation/cubit/shift_history_state.dart';
import 'package:smart_expense/features/operations/presentation/cubit/shift_stats.dart';

class ShiftHistoryPage extends StatefulWidget {
  const ShiftHistoryPage({super.key});

  @override
  State<ShiftHistoryPage> createState() => _ShiftHistoryPageState();
}

class _ShiftHistoryPageState extends State<ShiftHistoryPage> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (ModalRoute.of(context)?.isCurrent == true) {
      context.read<ShiftHistoryCubit>().loadShiftHistory();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: SizedBox(height: AppSpacing.space4)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenHorizontal,
                  vertical: AppSpacing.space4,
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: Container(
                        padding: const EdgeInsets.all(AppSpacing.space2),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(AppRadius.full),
                        ),
                        child: const Icon(Icons.close_rounded, color: AppColors.foreground, size: 20),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.space3),
                    Expanded(
                      child: Text(
                        'سجل الورديات',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.headline.copyWith(color: AppColors.foreground),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(child: SizedBox(height: AppSpacing.space4)),
            BlocBuilder<ShiftHistoryCubit, ShiftHistoryState>(
              builder: (context, state) {
                if (state is ShiftHistoryLoading) {
                  return const SliverToBoxAdapter(
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (state is ShiftHistoryError) {
                  return SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.space8),
                        child: Column(
                          children: [
                            Text(state.message, style: AppTextStyles.body.copyWith(color: AppColors.destructive)),
                            const SizedBox(height: AppSpacing.space4),
                            ElevatedButton(
                              onPressed: () => context.read<ShiftHistoryCubit>().loadShiftHistory(),
                              child: const Text('إعادة المحاولة'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }
                if (state is ShiftHistoryLoaded) {
                  if (state.shifts.isEmpty) {
                    return const SliverToBoxAdapter(
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.all(AppSpacing.space8),
                          child: Text('لا توجد ورديات سابقة', style: TextStyle(color: AppColors.mutedForeground)),
                        ),
                      ),
                    );
                  }
                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final shift = state.shifts[index];
                        final stats = state.shiftStats[shift.id] ?? ShiftStats(
                          totalOperations: 0,
                          totalDeposits: 0,
                          totalWithdrawals: 0,
                          totalCommissions: 0,
                          totalNetworkFees: 0,
                          netProfit: 0,
                          instaPayCount: 0,
                        );
                        final active = shift.endTime == null;
                        return _ShiftCard(
                          shift: shift,
                          stats: stats,
                          active: active,
                          onTap: () {
                            context.push(
                              AppRoutes.shiftDetail,
                              extra: shift.id,
                            );
                          },
                        );
                      },
                      childCount: state.shifts.length,
                    ),
                  );
                }
                return const SliverToBoxAdapter(child: SizedBox.shrink());
              },
            ),
            SliverToBoxAdapter(child: SizedBox(height: AppSpacing.space8)),
          ],
        ),
      ),
    );
  }
}

class _ShiftCard extends StatelessWidget {
  final dynamic shift;
  final ShiftStats stats;
  final bool active;
  final VoidCallback onTap;

  const _ShiftCard({
    required this.shift,
    required this.stats,
    required this.active,
    required this.onTap,
  });

  static String _date(DateTime d) => DateFormat('yyyy/MM/dd', 'ar').format(d);
  static String _time(DateTime d) => DateFormat('hh:mm a', 'ar').format(d);
  static String _f(double v) => NumberFormat('#,##0.##', 'ar').format(v);

  @override
  Widget build(BuildContext context) {
    final endTime = shift.endTime as DateTime?;
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenHorizontal,
          vertical: AppSpacing.space2,
        ),
        padding: const EdgeInsets.all(AppSpacing.space4),
        decoration: BoxDecoration(
          color: active ? AppColors.primary.withValues(alpha: 0.05) : AppColors.card,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: active ? AppColors.primary : AppColors.border50),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: active ? AppColors.success : AppColors.mutedForeground,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: AppSpacing.space2),
                Text(
                  _date(shift.startTime),
                  style: AppTextStyles.bodyLarge.copyWith(color: AppColors.foreground, fontWeight: FontWeight.w700),
                ),
                const Spacer(),
                Text(
                  active ? 'نشطة' : 'مغلقة',
                  style: AppTextStyles.caption.copyWith(
                    color: active ? AppColors.success : AppColors.mutedForeground,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.space3),
            Row(
              children: [
                _stat('${_time(shift.startTime)} → ${endTime != null ? _time(endTime) : '...'}', Icons.schedule),
                const SizedBox(width: AppSpacing.space4),
                _stat('${stats.totalOperations} عملية', Icons.receipt_long_outlined),
              ],
            ),
            const SizedBox(height: AppSpacing.space2),
            Row(
              children: [
                _stat('عمولات ${_f(stats.totalCommissions)} ج.م', Icons.account_balance_wallet_outlined),
              ],
            ),
            const SizedBox(height: AppSpacing.space3),
            Row(
              children: [
                Expanded(child: _money('فتح', shift.openingCashDrawer)),
                const SizedBox(width: AppSpacing.space2),
                Expanded(child: _money('إغلاق', shift.closingCashDrawer ?? 0)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _stat(String text, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.mutedForeground),
        const SizedBox(width: AppSpacing.space1),
        Text(text, style: AppTextStyles.caption.copyWith(color: AppColors.foreground)),
      ],
    );
  }

  Widget _money(String label, double amount) {
    final color = amount >= 0 ? AppColors.success : AppColors.destructive;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('$label: ', style: AppTextStyles.caption.copyWith(color: AppColors.mutedForeground)),
        Text('${_f(amount)} ج.م', style: AppTextStyles.caption.copyWith(color: color, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
