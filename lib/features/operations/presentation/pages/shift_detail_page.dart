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
import 'package:smart_expense/features/operations/domain/entities/debt_type.dart';
import 'package:smart_expense/features/operations/domain/entities/operation_entity.dart';
import 'package:smart_expense/features/operations/presentation/cubit/shift_detail_cubit.dart';
import 'package:smart_expense/features/operations/presentation/cubit/shift_detail_state.dart';

// ── Timeline event model ──────────────────────────────────────────────────

enum _TimelineEventType {
  deposit,
  withdrawal,
  debtAdded,
  debtCollected,
  payableAdded,
  payableSettled,
}

class _TimelineEvent {
  final DateTime time;
  final _TimelineEventType type;
  final String? name;
  final double amount;

  const _TimelineEvent({
    required this.time,
    required this.type,
    this.name,
    required this.amount,
  });

  String get label {
    switch (type) {
      case _TimelineEventType.deposit:
        return 'إيداع';
      case _TimelineEventType.withdrawal:
        return 'سحب';
      case _TimelineEventType.debtAdded:
        return 'إضافة آجل';
      case _TimelineEventType.debtCollected:
        return 'تحصيل آجل';
      case _TimelineEventType.payableAdded:
        return 'إضافة مستحق';
      case _TimelineEventType.payableSettled:
        return 'سداد مستحق';
    }
  }

  Color get color {
    switch (type) {
      case _TimelineEventType.deposit:
        return AppColors.success;
      case _TimelineEventType.withdrawal:
        return AppColors.destructive;
      case _TimelineEventType.debtAdded:
        return const Color(0xFFF59E0B);
      case _TimelineEventType.debtCollected:
        return AppColors.success;
      case _TimelineEventType.payableAdded:
        return const Color(0xFFEC4899);
      case _TimelineEventType.payableSettled:
        return AppColors.destructive;
    }
  }

  IconData get icon {
    switch (type) {
      case _TimelineEventType.deposit:
        return Icons.arrow_downward_rounded;
      case _TimelineEventType.withdrawal:
        return Icons.arrow_upward_rounded;
      case _TimelineEventType.debtAdded:
        return Icons.person_add_rounded;
      case _TimelineEventType.debtCollected:
        return Icons.check_circle_outline_rounded;
      case _TimelineEventType.payableAdded:
        return Icons.add_card_rounded;
      case _TimelineEventType.payableSettled:
        return Icons.payments_rounded;
    }
  }
}

// ── Page ──────────────────────────────────────────────────────────────────

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
  static String _dt(DateTime d) =>
      DateFormat('yyyy/MM/dd  hh:mm a', 'ar').format(d);

  /// Build unified timeline events sorted by time (oldest first)
  List<_TimelineEvent> _buildTimeline(ShiftDetailLoaded state) {
    final events = <_TimelineEvent>[];

    // Operations: deposits & withdrawals
    for (final op in state.operations) {
      events.add(_TimelineEvent(
        time: op.createdAt,
        type: op.operationType == OperationType.deposit
            ? _TimelineEventType.deposit
            : _TimelineEventType.withdrawal,
        name: op.providerType.label,
        amount: op.amount,
      ));
    }

    // Debts created during shift
    for (final debt in state.shiftDebts) {
      final name = state.debtorNames[debt.debtorId];
      if (debt.debtType == DebtType.payable) {
        events.add(_TimelineEvent(
          time: debt.createdAt,
          type: _TimelineEventType.payableAdded,
          name: name,
          amount: debt.amount,
        ));
      } else {
        events.add(_TimelineEvent(
          time: debt.createdAt,
          type: _TimelineEventType.debtAdded,
          name: name,
          amount: debt.amount,
        ));
      }
    }

    // Payments made during shift
    for (final payment in state.shiftPayments) {
      final linkedDebt = state.allDebtsById[payment.debtId];
      final debtorId = linkedDebt?.debtorId;
      final name = debtorId != null ? state.debtorNames[debtorId] : null;
      if (linkedDebt?.debtType == DebtType.payable) {
        events.add(_TimelineEvent(
          time: payment.createdAt,
          type: _TimelineEventType.payableSettled,
          name: name,
          amount: payment.amount,
        ));
      } else {
        events.add(_TimelineEvent(
          time: payment.createdAt,
          type: _TimelineEventType.debtCollected,
          name: name,
          amount: payment.amount,
        ));
      }
    }

    events.sort((a, b) => a.time.compareTo(b.time));
    return events;
  }

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
                // ── App Bar ──
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
                            child: const Icon(
                              Icons.close_rounded,
                              color: AppColors.foreground,
                              size: 20,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.space3),
                        Expanded(
                          child: Text(
                            'تفاصيل الوردية',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.headline.copyWith(
                              color: AppColors.foreground,
                            ),
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
                                      content: Text(
                                        'فشل الطباعة: ${ErrorMapper.map(e)}',
                                      ),
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
                              child: const Icon(
                                Icons.print,
                                color: AppColors.foreground,
                                size: 20,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(child: SizedBox(height: AppSpacing.space4)),

                // ── Loading ──
                if (state is ShiftDetailLoading)
                  const SliverToBoxAdapter(
                    child: Center(child: CircularProgressIndicator()),
                  ),

                // ── Error ──
                if (state is ShiftDetailError)
                  SliverToBoxAdapter(
                    child: Center(
                      child: Text(
                        state.message,
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.destructive,
                        ),
                      ),
                    ),
                  ),

                // ── Content ──
                if (state is ShiftDetailLoaded)
                  SliverList(
                    delegate: SliverChildListDelegate([

                      // 1. معلومات الوردية
                      _sectionCard(
                        title: 'معلومات الوردية',
                        children: [
                          _row('البداية', _dt(state.shift.startTime)),
                          if (state.shift.endTime != null)
                            _row('النهاية', _dt(state.shift.endTime!)),
                          _row(
                            'رصيد الافتتاح',
                            '${_f(state.shift.openingCashDrawer)} ج.م',
                          ),
                          if (state.shift.closingCashDrawer != null)
                            _row(
                              'رصيد الإغلاق',
                              '${_f(state.shift.closingCashDrawer!)} ج.م',
                            ),
                        ],
                      ),
                      SizedBox(height: AppSpacing.space4),

                      // 2. ملخص الأرصدة (read-only)
                      _sectionCard(
                        title: 'ملخص الأرصدة',
                        children: [
                          _row(
                            state.shift.closingCashDrawer != null
                                ? 'درج الكاش (الإغلاق)'
                                : 'درج الكاش (الافتتاح)',
                            '${_f(state.shift.closingCashDrawer ?? state.shift.openingCashDrawer)} ج.م',
                            highlight: AppColors.primary,
                          ),
                          const Divider(color: AppColors.border50, height: 16),
                          _row(
                            'إجمالي أرصدة المحافظ',
                            '${_f(state.totalWalletBalance)} ج.م',
                          ),
                          _row(
                            'إجمالي رصيد InstaPay',
                            '${_f(state.totalInstaPayBalance)} ج.م',
                          ),
                          const Divider(color: AppColors.border50, height: 16),
                          _row(
                            'المتبقي من ديون العملاء',
                            '${_f(state.totalOutstandingCustomerDebt)} ج.م',
                            highlight: state.totalOutstandingCustomerDebt > 0
                                ? const Color(0xFFF59E0B)
                                : null,
                          ),
                          _row(
                            'المستحقات على المحل',
                            '${_f(state.totalOutstandingPayable)} ج.م',
                            highlight: state.totalOutstandingPayable > 0
                                ? const Color(0xFFEC4899)
                                : null,
                          ),
                        ],
                      ),
                      SizedBox(height: AppSpacing.space4),

                      // 3. ملخص العمليات
                      _sectionCard(
                        title: 'ملخص العمليات',
                        children: [
                          _row('عدد الإيداعات', '${state.stats.depositCount}'),
                          _row(
                            'إجمالي الإيداع',
                            '${_f(state.stats.totalDeposits)} ج.م',
                            highlight: AppColors.success,
                          ),
                          _row('عدد السحوبات', '${state.stats.withdrawalCount}'),
                          _row(
                            'إجمالي السحب',
                            '${_f(state.stats.totalWithdrawals)} ج.م',
                            highlight: AppColors.destructive,
                          ),
                          const Divider(color: AppColors.border50, height: 16),
                          _row(
                            'إجمالي العمولات',
                            '${_f(state.stats.totalCommissions)} ج.م',
                            highlight: AppColors.success,
                          ),
                          _row(
                            'رسوم الشبكة',
                            '${_f(state.stats.totalNetworkFees)} ج.م',
                          ),
                          _row(
                            'صافي الربح',
                            '${_f(state.stats.netProfit)} ج.م',
                            highlight: AppColors.primary,
                          ),
                          _row('عمليات InstaPay', '${state.stats.instaPayCount}'),
                          _row('إجمالي العمليات', '${state.stats.totalOperations}'),
                        ],
                      ),
                      SizedBox(height: AppSpacing.space6),

                      // 4. نشاط الوردية (Timeline)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.screenHorizontal,
                        ),
                        child: Text(
                          'نشاط الوردية',
                          style: AppTextStyles.headline.copyWith(
                            color: AppColors.foreground,
                          ),
                        ),
                      ),
                      SizedBox(height: AppSpacing.space3),
                      Builder(builder: (context) {
                        final events = _buildTimeline(state);
                        if (events.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.all(AppSpacing.space8),
                            child: Center(
                              child: Text(
                                'لا يوجد نشاط في هذه الوردية',
                                style: AppTextStyles.body.copyWith(
                                  color: AppColors.mutedForeground,
                                ),
                              ),
                            ),
                          );
                        }
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.screenHorizontal,
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.card,
                              borderRadius: BorderRadius.circular(AppRadius.lg),
                              border: Border.all(color: AppColors.border50),
                            ),
                            child: Column(
                              children: [
                                for (int i = 0; i < events.length; i++) ...[
                                  _TimelineTile(
                                    event: events[i],
                                    isFirst: i == 0,
                                    isLast: i == events.length - 1,
                                  ),
                                  if (i < events.length - 1)
                                    const Divider(
                                      height: 1,
                                      color: AppColors.border50,
                                      indent: 52,
                                    ),
                                ],
                              ],
                            ),
                          ),
                        );
                      }),
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

  Widget _sectionCard({required String title, required List<Widget> children}) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
      ),
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
            Text(
              title,
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.foreground,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.space3),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value, {Color? highlight}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.space2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.body.copyWith(color: AppColors.mutedForeground),
          ),
          Text(
            value,
            style: AppTextStyles.body.copyWith(
              color: highlight ?? AppColors.foreground,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Timeline Tile ─────────────────────────────────────────────────────────

class _TimelineTile extends StatelessWidget {
  final _TimelineEvent event;
  final bool isFirst;
  final bool isLast;

  const _TimelineTile({
    required this.event,
    required this.isFirst,
    required this.isLast,
  });

  static String _f(double v) => NumberFormat('#,##0.##', 'ar').format(v);

  @override
  Widget build(BuildContext context) {
    final color = event.color;
    return Padding(
      padding: EdgeInsets.only(
        top: isFirst ? AppSpacing.space3 : 0,
        bottom: isLast ? AppSpacing.space3 : 0,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space4,
          vertical: AppSpacing.space3,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Icon badge
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.withAlpha(color, 0.15),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Icon(event.icon, color: color, size: 18),
            ),
            const SizedBox(width: AppSpacing.space3),
            // Label & name
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.label,
                    style: AppTextStyles.body.copyWith(
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (event.name != null && event.name!.isNotEmpty)
                    Text(
                      event.name!,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.mutedForeground,
                      ),
                    ),
                ],
              ),
            ),
            // Amount & time
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${_f(event.amount)} ج.م',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.foreground,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  DateFormat('hh:mm a', 'ar').format(event.time),
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.mutedForeground,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
