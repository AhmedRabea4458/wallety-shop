import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:smart_expense/core/di/injection_container.dart';
import 'package:smart_expense/core/theme/app_colors.dart';
import 'package:smart_expense/core/theme/app_radius.dart';
import 'package:smart_expense/core/theme/app_spacing.dart';
import 'package:smart_expense/core/theme/app_text_styles.dart';
import 'package:smart_expense/features/operations/domain/entities/debt_entity.dart';
import 'package:smart_expense/features/operations/presentation/cubit/debt_cubit.dart';
import 'package:smart_expense/features/operations/presentation/cubit/debt_state.dart';
import 'package:smart_expense/features/operations/presentation/cubit/operation_cubit.dart';

class DebtorDetailPage extends StatefulWidget {
  final int debtorId;

  const DebtorDetailPage({super.key, required this.debtorId});

  @override
  State<DebtorDetailPage> createState() => _DebtorDetailPageState();
}

class _DebtorDetailPageState extends State<DebtorDetailPage> {
  @override
  void initState() {
    super.initState();
    context.read<DebtCubit>().loadDebtorDetail(widget.debtorId);
  }

  static String _f(double v) => NumberFormat('#,##0.##', 'ar').format(v);

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
                        'تفاصيل الآجل',
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
            BlocBuilder<DebtCubit, DebtState>(
              builder: (context, state) {
                if (state is DebtLoading) {
                  return const SliverToBoxAdapter(
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (state is DebtError) {
                  return SliverToBoxAdapter(
                    child: Center(
                      child: Text(state.message, style: AppTextStyles.body.copyWith(color: AppColors.destructive)),
                    ),
                  );
                }
                if (state is DebtorDetailLoaded) {
                  final totalUnpaid = state.debts
                      .where((d) => !d.isPaid)
                      .fold(0.0, (sum, d) => sum + d.amount);
                  return SliverMainAxisGroup(
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
                          child: Container(
                            padding: const EdgeInsets.all(AppSpacing.space4),
                            decoration: BoxDecoration(
                              color: AppColors.card,
                              borderRadius: BorderRadius.circular(AppRadius.lg),
                              border: Border.all(color: AppColors.border50),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _row('الاسم', state.debtor.name),
                                if (state.debtor.phone != null && state.debtor.phone!.isNotEmpty)
                                  _row('الهاتف', state.debtor.phone!),
                                const Divider(color: AppColors.border50),
                                _row('إجمالي المستحق', '${_f(totalUnpaid)} ج.م'),
                                _row('عدد الديون', '${state.debts.length}'),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(child: SizedBox(height: AppSpacing.space6)),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
                          child: Text(
                            'الديون',
                            style: AppTextStyles.headline.copyWith(color: AppColors.foreground),
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(child: SizedBox(height: AppSpacing.space3)),
                      if (state.debts.isEmpty)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpacing.space8),
                            child: Center(
                              child: Text('لا توجد ديون',
                                  style: AppTextStyles.body.copyWith(color: AppColors.mutedForeground)),
                            ),
                          ),
                        )
                      else
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final debt = state.debts[index];
                              return _DebtTile(
                                debt: debt,
                            onSettle: () async {
                              final debtCubit = this.context.read<DebtCubit>();
                              final confirm = await showDialog<bool>(
                                context: this.context,
                                builder: (ctx) => AlertDialog(
                                  title: Text('تسوية الدين', style: AppTextStyles.headline.copyWith(color: AppColors.foreground)),
                                  content: Text('هل أنت متأكد من تسوية هذا الدين؟'),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')),
                                    ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('تسوية')),
                                  ],
                                ),
                              );
                              if (confirm == true && mounted) {
                                await debtCubit.markDebtAsPaid(debt.id);
                                sl<OperationCubit>().getOperations();
                                if (mounted) {
                                  debtCubit.loadDebtorDetail(widget.debtorId);
                                }
                              }
                            },
                              );
                            },
                            childCount: state.debts.length,
                          ),
                        ),
                      SliverToBoxAdapter(child: SizedBox(height: AppSpacing.space8)),
                    ],
                  );
                }
                return const SliverToBoxAdapter(child: SizedBox.shrink());
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.space2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.body.copyWith(color: AppColors.mutedForeground)),
          Text(value, style: AppTextStyles.body.copyWith(color: AppColors.foreground, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _DebtTile extends StatelessWidget {
  final DebtEntity debt;
  final VoidCallback onSettle;

  const _DebtTile({required this.debt, required this.onSettle});

  @override
  Widget build(BuildContext context) {
    final isDeposit = debt.operationType == 'deposit';
    final typeLabel = isDeposit ? 'إيداع' : 'سحب';
    final color = isDeposit ? AppColors.destructive : AppColors.success;
    final providerLabel = debt.providerType == 'instaPay' ? 'InstaPay' : 'Vodafone Cash';

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
        vertical: AppSpacing.space1,
      ),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space4, vertical: AppSpacing.space3),
      decoration: BoxDecoration(
        color: debt.isPaid ? AppColors.cardSecondary : AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border50),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(typeLabel,
                        style: AppTextStyles.caption.copyWith(color: color, fontWeight: FontWeight.w600)),
                    const SizedBox(width: AppSpacing.space1),
                    Text(providerLabel,
                        style: AppTextStyles.caption.copyWith(color: AppColors.mutedForeground, fontSize: 10)),
                  ],
                ),
                Text('${_f(debt.amount)} ج.م',
                    style: AppTextStyles.body.copyWith(color: AppColors.foreground, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          if (!debt.isPaid)
            TextButton(
              onPressed: onSettle,
              style: TextButton.styleFrom(foregroundColor: AppColors.primary),
              child: const Text('تسوية'),
            )
          else
            const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 20),
        ],
      ),
    );
  }

  static String _f(double v) => NumberFormat('#,##0.##', 'ar').format(v);
}
