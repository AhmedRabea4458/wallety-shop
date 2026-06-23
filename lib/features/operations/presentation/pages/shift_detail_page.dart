import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:smart_expense/core/errors/error_mapper.dart';
import 'package:smart_expense/core/services/shift_pdf_service.dart';
import 'package:smart_expense/core/theme/app_colors.dart';
import 'package:smart_expense/core/theme/app_radius.dart';
import 'package:smart_expense/core/theme/app_spacing.dart';
import 'package:smart_expense/core/theme/app_text_styles.dart';
import 'package:smart_expense/features/operations/domain/entities/operation_entity.dart';
import 'package:smart_expense/features/operations/presentation/cubit/shift_detail_cubit.dart';
import 'package:smart_expense/features/operations/presentation/cubit/shift_detail_state.dart';

class ShiftDetailPage extends StatefulWidget {
  final int shiftId;

  const ShiftDetailPage({super.key, required this.shiftId});

  @override
  State<ShiftDetailPage> createState() => _ShiftDetailPageState();
}

class _ShiftDetailPageState extends State<ShiftDetailPage> {
  @override
  void initState() {
    super.initState();
    context.read<ShiftDetailCubit>().loadShiftDetail(widget.shiftId);
  }

  static String _f(double v) => NumberFormat('#,##0.##', 'ar').format(v);
  static String _dt(DateTime d) => DateFormat('yyyy/MM/dd  hh:mm a', 'ar').format(d);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocBuilder<ShiftDetailCubit, ShiftDetailState>(
          builder: (context, state) {
            return CustomScrollView(
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
                            'تفاصيل الوردية',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.headline.copyWith(color: AppColors.foreground),
                          ),
                        ),
                        const SizedBox(width: 48),
                        if (state is ShiftDetailLoaded)
                          IconButton(
                            onPressed: () async {
                              try {
                                await ShiftPdfService.printShift(
                                  shift: state.shift,
                                  stats: state.stats,
                                  operations: state.operations,
                                );
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('فشل الطباعة: ${ErrorMapper.map(e)}'),
                                      backgroundColor: AppColors.destructive,
                                      duration: const Duration(seconds: 4),
                                    ),
                                  );
                                }
                              }
                            },
                            icon: Container(
                              padding: const EdgeInsets.all(AppSpacing.space2),
                              decoration: BoxDecoration(
                                color: AppColors.card,
                                borderRadius: BorderRadius.circular(AppRadius.full),
                              ),
                              child: const Icon(Icons.print, color: AppColors.foreground, size: 20),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(child: SizedBox(height: AppSpacing.space4)),
                if (state is ShiftDetailLoading)
                  const SliverToBoxAdapter(
                    child: Center(child: CircularProgressIndicator()),
                  ),
                if (state is ShiftDetailError)
                  SliverToBoxAdapter(
                    child: Center(
                      child: Text(state.message, style: AppTextStyles.body.copyWith(color: AppColors.destructive)),
                    ),
                  ),
                if (state is ShiftDetailLoaded)
                  SliverList(
                    delegate: SliverChildListDelegate([
                      // Stats Card
                      Padding(
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
                              _row('البداية', _dt(state.shift.startTime)),
                              if (state.shift.endTime != null) _row('النهاية', _dt(state.shift.endTime!)),
                              _row('رصيد البداية', '${_f(state.shift.openingCashDrawer)} ج.م'),
                              if (state.shift.closingCashDrawer != null)
                                _row('رصيد النهاية', '${_f(state.shift.closingCashDrawer!)} ج.م'),
                              const Divider(color: AppColors.border50),
                              _row('إجمالي الإيداع', '${_f(state.stats.totalDeposits)} ج.م'),
                              _row('إجمالي السحب', '${_f(state.stats.totalWithdrawals)} ج.م'),
                              _row('إجمالي العمولات', '${_f(state.stats.totalCommissions)} ج.م'),
                              _row('رسوم الشبكة', '${_f(state.stats.totalNetworkFees)} ج.م'),
                              _row('صافي الربح', '${_f(state.stats.netProfit)} ج.م'),
                              _row('عمليات InstaPay', state.stats.instaPayCount.toString()),
                              _row('إجمالي العمليات', '${state.stats.totalOperations}'),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: AppSpacing.space6),
                      // Section Header
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
                        child: Text(
                          'العمليات',
                          style: AppTextStyles.headline.copyWith(color: AppColors.foreground),
                        ),
                      ),
                      SizedBox(height: AppSpacing.space3),
                      // Operations List or Empty
                      if (state.operations.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(AppSpacing.space8),
                          child: Center(
                            child: Text('لا توجد عمليات في هذه الوردية',
                                style: AppTextStyles.body.copyWith(color: AppColors.mutedForeground)),
                          ),
                        )
                      else
                        ...state.operations.reversed.map((op) => _OperationTile(operation: op)),
                      SizedBox(height: AppSpacing.space8),
                    ]),
                  ),
              ],
            );
          },
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

class _OperationTile extends StatelessWidget {
  final OperationEntity operation;

  const _OperationTile({required this.operation});

  static String _time(DateTime d) => DateFormat('hh:mm a', 'ar').format(d);
  static String _f(double v) => NumberFormat('#,##0.##', 'ar').format(v);

  @override
  Widget build(BuildContext context) {
    final isDeposit = operation.operationType == OperationType.deposit;
    final color = isDeposit ? AppColors.destructive : AppColors.success;
    final icon = isDeposit ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded;
    final typeLabel = isDeposit ? 'إيداع' : 'سحب';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal, vertical: AppSpacing.space1),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space4, vertical: AppSpacing.space3),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border50),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.withAlpha(color, 0.15),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: AppSpacing.space3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(typeLabel, style: AppTextStyles.caption.copyWith(color: color, fontWeight: FontWeight.w600)),
                Text(operation.providerType.label,
                    style: AppTextStyles.caption.copyWith(color: AppColors.mutedForeground, fontSize: 10)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${_f(operation.amount)} ج.م',
                  style: AppTextStyles.body.copyWith(color: AppColors.foreground, fontWeight: FontWeight.w700)),
              Text(_time(operation.createdAt),
                  style: AppTextStyles.caption.copyWith(color: AppColors.mutedForeground)),
            ],
          ),
        ],
      ),
    );
  }
}
