import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:smart_expense/core/di/injection_container.dart';
import 'package:smart_expense/core/theme/app_colors.dart';
import 'package:smart_expense/core/theme/app_radius.dart';
import 'package:smart_expense/core/theme/app_spacing.dart';
import 'package:smart_expense/core/theme/app_text_styles.dart';
import 'package:smart_expense/core/utils/arabic_numerals.dart';
import 'package:smart_expense/core/utils/date_formatter.dart';
import 'package:smart_expense/core/utils/debt_reminder_helper.dart';
import 'package:smart_expense/features/operations/domain/entities/debt_entity.dart';
import 'package:smart_expense/features/operations/domain/entities/debt_payment_entity.dart';
import 'package:smart_expense/features/operations/domain/entities/debt_type.dart';
import 'package:smart_expense/features/operations/domain/entities/debtor_entity.dart';
import 'package:smart_expense/features/operations/presentation/cubit/debt_cubit.dart';
import 'package:smart_expense/features/operations/presentation/cubit/debt_state.dart';
import 'package:smart_expense/features/operations/presentation/cubit/operation_cubit.dart';

class DebtorDetailPage extends StatefulWidget {
  final int debtorId;
  final DebtType activeLiabilityType;

  const DebtorDetailPage({
    super.key,
    required this.debtorId,
    this.activeLiabilityType = DebtType.customerDebt,
  });

  @override
  State<DebtorDetailPage> createState() => _DebtorDetailPageState();
}

class _DebtorDetailPageState extends State<DebtorDetailPage> {
  bool _isPaidExpanded = false;

  @override
  void initState() {
    super.initState();
    context.read<DebtCubit>().loadDebtorDetail(
          widget.debtorId,
          activeLiabilityType: widget.activeLiabilityType,
        );
  }

  static String _f(double v) => NumberFormat('#,##0.##', 'ar').format(v);

  /// Handles sending a WhatsApp debt reminder with missing-phone fallback flow.
  Future<void> _handleWhatsAppReminder({
    required DebtorEntity debtor,
    required double totalUnpaid,
  }) async {
    if (widget.activeLiabilityType == DebtType.payable) return;
    String? phone = debtor.phone;
    if (phone == null || phone.trim().isEmpty) {
      final added = await _showMissingPhoneDialog(debtor);
      if (!added || !mounted) return;
      final updatedDebtor = await context.read<DebtCubit>().getDebtorById(debtor.id);
      phone = updatedDebtor?.phone;
      if (phone == null || phone.trim().isEmpty) return;
    }

    final message = DebtReminderHelper.buildDebtReminderMessage(
      customerName: debtor.name,
      remainingAmount: totalUnpaid,
    );

    final success = await DebtReminderHelper.openWhatsApp(
      phone: phone,
      message: message,
    );

    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'تعذر فتح تطبيق واتساب. يرجى التأكد من تثبيت واتساب والتحقق من صحة الرقم.',
          ),
          backgroundColor: AppColors.destructive,
        ),
      );
    }
  }

  /// Handles calling the customer via device dialer with missing-phone fallback flow.
  Future<void> _handleCallCustomer(DebtorEntity debtor) async {
    String? phone = debtor.phone;
    if (phone == null || phone.trim().isEmpty) {
      final added = await _showMissingPhoneDialog(debtor);
      if (!added || !mounted) return;
      final updatedDebtor = await context.read<DebtCubit>().getDebtorById(debtor.id);
      phone = updatedDebtor?.phone;
      if (phone == null || phone.trim().isEmpty) return;
    }

    final success = await DebtReminderHelper.openDialer(phone: phone);
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تعذر فتح تطبيق الهاتف.'),
          backgroundColor: AppColors.destructive,
        ),
      );
    }
  }

  /// Displays the missing phone dialog followed by the input dialog.
  Future<bool> _showMissingPhoneDialog(DebtorEntity debtor) async {
    final shouldAdd = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        title: Row(
          children: [
            const Icon(Icons.phone_missed_rounded, color: AppColors.warning),
            const SizedBox(width: AppSpacing.space2),
            Text(
              'لا يوجد رقم هاتف',
              style: AppTextStyles.headline.copyWith(
                color: AppColors.foreground,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: Text(
          widget.activeLiabilityType == DebtType.payable
              ? 'لا يوجد رقم هاتف لهذا الشخص / الجهة'
              : 'لا يوجد رقم هاتف لهذا العميل',
          style: AppTextStyles.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.primaryForeground,
            ),
            child: const Text('إضافة رقم'),
          ),
        ],
      ),
    );

    if (shouldAdd != true || !mounted) return false;

    final phoneController = TextEditingController();
    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        title: Text(
          'إضافة رقم الهاتف',
          style: AppTextStyles.headline.copyWith(
            color: AppColors.foreground,
            fontSize: 18,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'العميل: ${debtor.name}',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.mutedForeground,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.space3),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              autofocus: true,
              textAlign: TextAlign.right,
              decoration: const InputDecoration(
                hintText: 'أدخل رقم الهاتف (مثال: 01012345678)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone_outlined, size: 20),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              final text = phoneController.text.trim();
              if (text.isEmpty) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(
                    content: Text('الرجاء إدخال رقم الهاتف'),
                    backgroundColor: AppColors.destructive,
                  ),
                );
                return;
              }
              Navigator.pop(ctx, true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.primaryForeground,
            ),
            child: const Text('حفظ والمتابعة'),
          ),
        ],
      ),
    );

    if (saved == true && mounted) {
      final phone = phoneController.text.trim();
      try {
        await context.read<DebtCubit>().updateDebtorPhone(
              debtorId: debtor.id,
              phone: phone,
              activeLiabilityType: widget.activeLiabilityType,
            );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم حفظ رقم الهاتف بنجاح'),
              backgroundColor: AppColors.success,
            ),
          );
        }
        return true;
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('فشل حفظ رقم الهاتف: $e'),
              backgroundColor: AppColors.destructive,
            ),
          );
        }
        return false;
      }
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    final isPayable = widget.activeLiabilityType == DebtType.payable;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: SizedBox(height: AppSpacing.space4)),
            // Top App Bar
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
                          border: Border.all(color: AppColors.border50),
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
                        isPayable ? 'تفاصيل المستحق' : 'تفاصيل الآجل',
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
            SliverToBoxAdapter(child: SizedBox(height: AppSpacing.space2)),

            // Main Body Content
            BlocBuilder<DebtCubit, DebtState>(
              buildWhen: (previous, current) =>
                  current is DebtLoading ||
                  current is DebtError ||
                  current is DebtorDetailLoaded,
              builder: (context, state) {
                if (state is DebtLoading) {
                  return const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(AppSpacing.space8),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  );
                }
                if (state is DebtError) {
                  return SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.space8),
                        child: Text(
                          state.message,
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.destructive,
                          ),
                        ),
                      ),
                    ),
                  );
                }
                if (state is DebtorDetailLoaded) {
                  final activeDebts = state.debts.where((d) => !d.isPaid).toList();
                  final paidDebts = state.debts.where((d) => d.isPaid).toList();

                  // Map payments by debt ID
                  final paymentsByDebt = <int, double>{};
                  for (final p in state.payments) {
                    paymentsByDebt[p.debtId] =
                        (paymentsByDebt[p.debtId] ?? 0.0) + p.amount;
                  }

                  // Calculate total remaining unpaid
                  final totalUnpaid = activeDebts.fold(0.0, (sum, d) {
                    final paid = paymentsByDebt[d.id] ?? 0.0;
                    return sum + (d.amount - paid);
                  });

                  final totalOriginal = state.debts.fold(0.0, (s, d) => s + d.amount);
                  final totalPaid = state.payments.fold(0.0, (s, p) => s + p.amount);
                  final lastPayment = state.payments.isNotEmpty
                      ? state.payments.reduce(
                          (a, b) => a.createdAt.isAfter(b.createdAt) ? a : b,
                        )
                      : null;

                  // Find oldest active debt
                  DebtEntity? oldestDebt;
                  double oldestRemaining = 0.0;
                  String oldestDurationText = '';
                  if (activeDebts.isNotEmpty) {
                    final sortedByAge = List<DebtEntity>.from(activeDebts)
                      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
                    oldestDebt = sortedByAge.first;
                    final paid = paymentsByDebt[oldestDebt.id] ?? 0.0;
                    oldestRemaining = oldestDebt.amount - paid;
                    oldestDurationText =
                        DebtReminderHelper.formatDebtAgeArabic(oldestDebt.createdAt);
                  }

                  return SliverMainAxisGroup(
                    slivers: [
                      // 1. Customer & Actions Hero Card
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.screenHorizontal,
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(AppSpacing.space4),
                            decoration: BoxDecoration(
                              color: AppColors.card,
                              borderRadius: BorderRadius.circular(AppRadius.lg),
                              border: Border.all(color: AppColors.border50),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.03),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Debtor Header with Name & Phone
                                Row(
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: (isPayable
                                                ? AppColors.warning
                                                : AppColors.primary)
                                            .withValues(alpha: 0.12),
                                        borderRadius:
                                            BorderRadius.circular(AppRadius.md),
                                      ),
                                      child: Icon(
                                        Icons.person_rounded,
                                        color: isPayable
                                            ? AppColors.warning
                                            : AppColors.primary,
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.space3),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            state.debtor.name,
                                            style: AppTextStyles.headline.copyWith(
                                              fontSize: 18,
                                              color: AppColors.foreground,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            (state.debtor.phone != null &&
                                                    state.debtor.phone!.isNotEmpty)
                                                ? state.debtor.phone!
                                                : 'لا يوجد رقم هاتف مسجل',
                                            style: AppTextStyles.caption.copyWith(
                                              color: (state.debtor.phone != null &&
                                                      state.debtor.phone!.isNotEmpty)
                                                  ? AppColors.mutedForeground
                                                  : AppColors.warning,
                                              fontWeight: (state.debtor.phone != null &&
                                                      state.debtor.phone!.isNotEmpty)
                                                  ? FontWeight.normal
                                                  : FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      tooltip: 'تعديل بيانات العميل',
                                      onPressed: () => _showEditDebtorDialog(state.debtor),
                                      icon: const Icon(
                                        Icons.edit_outlined,
                                        size: 20,
                                        color: AppColors.mutedForeground,
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: AppSpacing.space4),

                                // Prominent Contact Actions (WhatsApp & Call)
                                Row(
                                  children: [
                                    if (!isPayable) ...[
                                      // WhatsApp Action Button
                                      Expanded(
                                        flex: 3,
                                        child: ElevatedButton.icon(
                                          onPressed: () => _handleWhatsAppReminder(
                                            debtor: state.debtor,
                                            totalUnpaid: totalUnpaid,
                                          ),
                                          icon: const Icon(
                                            Icons.chat_rounded,
                                            size: 18,
                                          ),
                                          label: const Text(
                                            'تذكير واتساب',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 13,
                                            ),
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.whatsapp,
                                            foregroundColor: Colors.white,
                                            elevation: 0,
                                            padding: const EdgeInsets.symmetric(
                                              vertical: AppSpacing.space3,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(AppRadius.md),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: AppSpacing.space2),
                                    ],
                                    // Call Action Button
                                    Expanded(
                                      flex: isPayable ? 1 : 2,
                                      child: isPayable
                                          ? ElevatedButton.icon(
                                              onPressed: () =>
                                                  _handleCallCustomer(state.debtor),
                                              icon: const Icon(
                                                Icons.phone_rounded,
                                                size: 18,
                                              ),
                                              label: const Text(
                                                'اتصال',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 13,
                                                ),
                                              ),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: AppColors.primary,
                                                foregroundColor: AppColors.primaryForeground,
                                                elevation: 0,
                                                padding: const EdgeInsets.symmetric(
                                                  vertical: AppSpacing.space3,
                                                ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(AppRadius.md),
                                                ),
                                              ),
                                            )
                                          : OutlinedButton.icon(
                                              onPressed: () =>
                                                  _handleCallCustomer(state.debtor),
                                              icon: const Icon(
                                                Icons.phone_rounded,
                                                size: 18,
                                              ),
                                              label: const Text(
                                                'اتصال',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 13,
                                                ),
                                              ),
                                              style: OutlinedButton.styleFrom(
                                                foregroundColor: AppColors.foreground,
                                                side: const BorderSide(
                                                  color: AppColors.border,
                                                ),
                                                padding: const EdgeInsets.symmetric(
                                                  vertical: AppSpacing.space3,
                                                ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(AppRadius.md),
                                                ),
                                              ),
                                            ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SliverToBoxAdapter(
                        child: SizedBox(height: AppSpacing.space4),
                      ),

                      // 2. Financial & Duration Highlights Card
                      SliverToBoxAdapter(
                        child: Padding(
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
                                // Total Unpaid Balance Hero
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          isPayable
                                              ? 'إجمالي المستحق عليّ'
                                              : 'الرصيد الحالي المستحق',
                                          style: AppTextStyles.caption.copyWith(
                                            color: AppColors.mutedForeground,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${_f(totalUnpaid)} ج.م',
                                          style: AppTextStyles.headline.copyWith(
                                            fontSize: 24,
                                            color: totalUnpaid > 0
                                                ? AppColors.destructive
                                                : AppColors.success,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: AppSpacing.space3,
                                        vertical: AppSpacing.space2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: (totalUnpaid > 0
                                                ? AppColors.destructive
                                                : AppColors.success)
                                            .withValues(alpha: 0.1),
                                        borderRadius:
                                            BorderRadius.circular(AppRadius.full),
                                      ),
                                      child: Text(
                                        activeDebts.isNotEmpty
                                            ? '${activeDebts.length} ${isPayable ? "مستحق نشط" : "آجل نشط"}'
                                            : 'خالص تماماً',
                                        style: AppTextStyles.caption.copyWith(
                                          color: totalUnpaid > 0
                                              ? AppColors.destructive
                                              : AppColors.success,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                // Highlight Oldest Debt if active debts exist
                                if (oldestDebt != null) ...[
                                  const SizedBox(height: AppSpacing.space3),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.space3,
                                      vertical: AppSpacing.space2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.warning.withValues(alpha: 0.08),
                                      borderRadius:
                                          BorderRadius.circular(AppRadius.md),
                                      border: Border.all(
                                        color:
                                            AppColors.warning.withValues(alpha: 0.25),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.hourglass_top_rounded,
                                          size: 16,
                                          color: AppColors.warning,
                                        ),
                                        const SizedBox(width: AppSpacing.space2),
                                        Expanded(
                                          child: Text(
                                            'أقدم ${isPayable ? "مستحق" : "آجل"}: ${_f(oldestRemaining)} ج.م — $oldestDurationText',
                                            style: AppTextStyles.caption.copyWith(
                                              color: AppColors.foreground,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],

                                const SizedBox(height: AppSpacing.space3),
                                const Divider(color: AppColors.border50),
                                const SizedBox(height: AppSpacing.space2),

                                // Secondary stats
                                _row(
                                  'الديون المستحقة المعلقة',
                                  '${activeDebts.length}',
                                ),
                                _row(
                                  'الديون المسددة (الخالصة)',
                                  '${paidDebts.length}',
                                ),
                                const Divider(color: AppColors.border50),
                                _row(
                                  'إجمالي أصل الدين',
                                  '${_f(totalOriginal)} ج.م',
                                ),
                                _row(
                                  'إجمالي المدفوع',
                                  '${_f(totalPaid)} ج.م',
                                ),
                                if (lastPayment != null)
                                  _row(
                                    'آخر دفعة',
                                    DateFormatter.formatTransactionDate(
                                      lastPayment.createdAt,
                                    ),
                                  ),

                                // Bulk Pay CTA
                                if (activeDebts.isNotEmpty) ...[
                                  const SizedBox(height: AppSpacing.space3),
                                  const Divider(color: AppColors.border50),
                                  const SizedBox(height: AppSpacing.space2),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton.icon(
                                      onPressed: () => _showBulkPayDialog(
                                        context,
                                        state.debtor.id,
                                        totalUnpaid,
                                        state.debts,
                                        state.payments,
                                      ),
                                      icon: const Icon(
                                        Icons.payments_outlined,
                                        size: 18,
                                      ),
                                      label: const Text('دفعة من الرصيد'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primary,
                                        foregroundColor:
                                            AppColors.primaryForeground,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: AppSpacing.space3,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(AppRadius.md),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SliverToBoxAdapter(
                        child: SizedBox(height: AppSpacing.space6),
                      ),

                      // 3. Active Debts Header
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.screenHorizontal,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'الديون المستحقة (${activeDebts.length})',
                                style: AppTextStyles.headline.copyWith(
                                  color: AppColors.foreground,
                                ),
                              ),
                              if (activeDebts.isNotEmpty)
                                Text(
                                  'مرتبة حسب التاريخ',
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.mutedForeground,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SliverToBoxAdapter(
                        child: SizedBox(height: AppSpacing.space3),
                      ),

                      // Active Debts List
                      if (activeDebts.isEmpty)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpacing.space6),
                            child: Center(
                              child: Text(
                                'لا توجد ديون مستحقة',
                                style: AppTextStyles.body.copyWith(
                                  color: AppColors.mutedForeground,
                                ),
                              ),
                            ),
                          ),
                        )
                      else
                        SliverList(
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final debt = activeDebts[index];
                            final debtPayments = state.payments
                                .where((p) => p.debtId == debt.id)
                                .toList();
                            final paidAmount = debtPayments.fold(
                              0.0,
                              (sum, p) => sum + p.amount,
                            );
                            final remainingBalance = debt.amount - paidAmount;
                            return _DebtTile(
                              debt: debt,
                              debtor: state.debtor,
                              remainingBalance: remainingBalance,
                              paidAmount: paidAmount,
                              payments: debtPayments,
                              onPay: () => _showPayDebtDialog(
                                context,
                                debt,
                                remainingBalance,
                                state.debtor.id,
                              ),
                              onSettle: () async {
                                final debtCubit = this.context.read<DebtCubit>();
                                String selectedMethod = 'cash';
                                final isPayableDebt =
                                    debt.debtType == DebtType.payable;
                                final confirm = await showDialog<bool>(
                                  context: this.context,
                                  builder: (ctx) => StatefulBuilder(
                                    builder: (ctx, setDlgState) => AlertDialog(
                                      backgroundColor: AppColors.card,
                                      title: Text(
                                        isPayableDebt
                                            ? 'تسوية المستحق'
                                            : 'تسوية الدين',
                                        style: AppTextStyles.headline.copyWith(
                                          color: AppColors.foreground,
                                        ),
                                      ),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'هل أنت متأكد من تسوية هذا ${isPayableDebt ? "المستحق" : "الدين"} بالكامل (${_f(remainingBalance)} ج.م)؟',
                                            style: AppTextStyles.body.copyWith(
                                              color: AppColors.foreground,
                                            ),
                                          ),
                                          const SizedBox(
                                            height: AppSpacing.space3,
                                          ),
                                          Text(
                                            'طريقة التسوية:',
                                            style: AppTextStyles.caption.copyWith(
                                              color: AppColors.mutedForeground,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(
                                            height: AppSpacing.space2,
                                          ),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: ChoiceChip(
                                                  label: const Center(
                                                    child: Text('نقدي'),
                                                  ),
                                                  selected:
                                                      selectedMethod == 'cash',
                                                  onSelected: (val) {
                                                    if (val) {
                                                      setDlgState(
                                                        () => selectedMethod =
                                                            'cash',
                                                      );
                                                    }
                                                  },
                                                ),
                                              ),
                                              const SizedBox(
                                                width: AppSpacing.space2,
                                              ),
                                              Expanded(
                                                child: ChoiceChip(
                                                  label: const Center(
                                                    child: Text('أخرى'),
                                                  ),
                                                  selected:
                                                      selectedMethod == 'other',
                                                  onSelected: (val) {
                                                    if (val) {
                                                      setDlgState(
                                                        () => selectedMethod =
                                                            'other',
                                                      );
                                                    }
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(
                                            height: AppSpacing.space2,
                                          ),
                                          Text(
                                            selectedMethod == 'cash'
                                                ? (isPayableDebt
                                                    ? 'سيتم خصم المبلغ من الخزينة النقدية'
                                                    : 'سيتم إضافة المبلغ إلى الخزينة النقدية')
                                                : 'تنبيه: اختيار (أخرى) يسجل التسوية دون أي تأثير على رصيد الخزينة أو المحافظ',
                                            style: AppTextStyles.caption.copyWith(
                                              color: selectedMethod == 'cash'
                                                  ? AppColors.mutedForeground
                                                  : AppColors.warning,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ],
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(ctx, false),
                                          child: const Text('إلغاء'),
                                        ),
                                        ElevatedButton(
                                          onPressed: () =>
                                              Navigator.pop(ctx, true),
                                          child: const Text('تسوية'),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                                if (confirm == true && mounted) {
                                  await debtCubit.markDebtAsPaid(
                                    debt.id,
                                    paymentMethod: selectedMethod,
                                  );
                                  sl<OperationCubit>().getOperations();
                                  if (mounted) {
                                    debtCubit.loadDebtorDetail(
                                      widget.debtorId,
                                      activeLiabilityType:
                                          widget.activeLiabilityType,
                                    );
                                  }
                                }
                              },
                              onEdit: () => _showEditDebtDialog(
                                context,
                                debt,
                                state.debtor,
                              ),
                              onCancel: () => _showCancelDebtDialog(
                                context,
                                debt,
                                state.debtor.id,
                              ),
                            );
                          }, childCount: activeDebts.length),
                        ),

                      // 4. Paid Debts Section (Collapsible)
                      if (paidDebts.isNotEmpty) ...[
                        const SliverToBoxAdapter(
                          child: SizedBox(height: AppSpacing.space4),
                        ),
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.screenHorizontal,
                            ),
                            child: InkWell(
                              onTap: () => setState(
                                () => _isPaidExpanded = !_isPaidExpanded,
                              ),
                              borderRadius: BorderRadius.circular(AppRadius.md),
                              child: Container(
                                padding: const EdgeInsets.all(AppSpacing.space3),
                                decoration: BoxDecoration(
                                  color: AppColors.card,
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.md),
                                  border: Border.all(color: AppColors.border50),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'الديون المدفوعة الخالصة (${paidDebts.length})',
                                      style: AppTextStyles.body.copyWith(
                                        color: AppColors.foreground,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Icon(
                                      _isPaidExpanded
                                          ? Icons.keyboard_arrow_up
                                          : Icons.keyboard_arrow_down,
                                      color: AppColors.mutedForeground,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        if (_isPaidExpanded) ...[
                          const SliverToBoxAdapter(
                            child: SizedBox(height: AppSpacing.space3),
                          ),
                          SliverList(
                            delegate: SliverChildBuilderDelegate((
                              context,
                              index,
                            ) {
                              final debt = paidDebts[index];
                              final debtPayments = state.payments
                                  .where((p) => p.debtId == debt.id)
                                  .toList();
                              final paidAmount = debtPayments.fold(
                                0.0,
                                (sum, p) => sum + p.amount,
                              );
                              final remainingBalance = debt.amount - paidAmount;
                              return _DebtTile(
                                debt: debt,
                                debtor: state.debtor,
                                remainingBalance: remainingBalance,
                                paidAmount: paidAmount,
                                payments: debtPayments,
                                onPay: () {},
                                onSettle: () {},
                                onEdit: () => _showEditDebtDialog(
                                  context,
                                  debt,
                                  state.debtor,
                                ),
                                onCancel: () {},
                              );
                            }, childCount: paidDebts.length),
                          ),
                        ],
                      ],

                      // 5. Payment History Section
                      const SliverToBoxAdapter(
                        child: SizedBox(height: AppSpacing.space6),
                      ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.screenHorizontal,
                          ),
                          child: Text(
                            'سجل الدفعات',
                            style: AppTextStyles.headline.copyWith(
                              color: AppColors.foreground,
                            ),
                          ),
                        ),
                      ),
                      const SliverToBoxAdapter(
                        child: SizedBox(height: AppSpacing.space3),
                      ),
                      if (state.payments.isEmpty)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpacing.space8),
                            child: Center(
                              child: Text(
                                'لا توجد دفعات مسجلة',
                                style: AppTextStyles.body.copyWith(
                                  color: AppColors.mutedForeground,
                                ),
                              ),
                            ),
                          ),
                        )
                      else
                        SliverList(
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final sortedPayments =
                                List<DebtPaymentEntity>.from(state.payments)
                                  ..sort(
                                    (a, b) => b.createdAt.compareTo(a.createdAt),
                                  );
                            final payment = sortedPayments[index];
                            return _PaymentTile(payment: payment);
                          }, childCount: state.payments.length),
                        ),
                      const SliverToBoxAdapter(
                        child: SizedBox(height: AppSpacing.space8),
                      ),
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
          Text(
            label,
            style: AppTextStyles.body.copyWith(
              color: AppColors.mutedForeground,
            ),
          ),
          Text(
            value,
            style: AppTextStyles.body.copyWith(
              color: AppColors.foreground,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _showEditDebtorDialog(DebtorEntity debtor) {
    final nameController = TextEditingController(text: debtor.name);
    final phoneController = TextEditingController(text: debtor.phone ?? '');
    final notesController = TextEditingController(text: debtor.notes ?? '');
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final debtCubit = context.read<DebtCubit>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        title: Text(
          'تعديل بيانات العميل',
          style: AppTextStyles.headline.copyWith(color: AppColors.foreground),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                textAlign: TextAlign.right,
                decoration: const InputDecoration(
                  hintText: 'اسم العميل',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: AppSpacing.space2),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                textAlign: TextAlign.right,
                decoration: const InputDecoration(
                  hintText: 'رقم الهاتف',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: AppSpacing.space2),
              TextField(
                controller: notesController,
                textAlign: TextAlign.right,
                maxLines: 2,
                decoration: const InputDecoration(
                  hintText: 'ملاحظات (اختياري)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newName = nameController.text.trim();
              final newPhone = phoneController.text.trim();
              final newNotes = notesController.text.trim();

              if (newName.isEmpty) {
                scaffoldMessenger.showSnackBar(
                  const SnackBar(
                    content: Text('اسم العميل مطلوب'),
                    backgroundColor: AppColors.destructive,
                  ),
                );
                return;
              }

              final nav = Navigator.of(ctx);
              try {
                await debtCubit.repository.updateDebtor(DebtorEntity(
                  id: debtor.id,
                  name: newName,
                  phone: newPhone.isEmpty ? null : newPhone,
                  notes: newNotes.isEmpty ? null : newNotes,
                  createdAt: debtor.createdAt,
                ));
                await debtCubit.loadDebtorDetail(
                  debtor.id,
                  activeLiabilityType: widget.activeLiabilityType,
                );
                await debtCubit.loadDebtors(silent: true);
                nav.pop();
              } catch (e) {
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Text('فشل التحديث: $e'),
                    backgroundColor: AppColors.destructive,
                  ),
                );
              }
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  void _showPayDebtDialog(
    BuildContext context,
    DebtEntity debt,
    double remainingBalance,
    int debtorId,
  ) {
    final amountController = TextEditingController();
    final notesController = TextEditingController();
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final debtCubit = context.read<DebtCubit>();
    String selectedMethod = 'cash';
    final isPayable = debt.debtType == DebtType.payable;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: AppColors.card,
          title: Text(
            isPayable ? 'سداد جزء من المستحق' : 'سداد جزء من الدين',
            style: AppTextStyles.headline.copyWith(
              color: AppColors.foreground,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'المبلغ المتبقي المستحق: ${_f(remainingBalance)} ج.م',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.mutedForeground,
                  ),
                ),
                const SizedBox(height: AppSpacing.space3),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.right,
                  decoration: const InputDecoration(
                    hintText: 'قيمة الدفعة',
                    suffixText: 'ج.م',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: AppSpacing.space3),
                Text(
                  'طريقة السداد:',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.mutedForeground,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.space2),
                Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        label: const Center(child: Text('نقدي')),
                        selected: selectedMethod == 'cash',
                        onSelected: (val) {
                          if (val) setDialogState(() => selectedMethod = 'cash');
                        },
                      ),
                    ),
                    const SizedBox(width: AppSpacing.space2),
                    Expanded(
                      child: ChoiceChip(
                        label: const Center(child: Text('أخرى')),
                        selected: selectedMethod == 'other',
                        onSelected: (val) {
                          if (val) setDialogState(() => selectedMethod = 'other');
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.space2),
                Text(
                  selectedMethod == 'cash'
                      ? (isPayable
                          ? 'سيتم خصم المبلغ من الخزينة النقدية'
                          : 'سيتم إضافة المبلغ إلى الخزينة النقدية')
                      : 'تنبيه: اختيار (أخرى) يسجل الدفعة دون أي تأثير على رصيد الخزينة أو المحافظ',
                  style: AppTextStyles.caption.copyWith(
                    color: selectedMethod == 'cash'
                        ? AppColors.mutedForeground
                        : AppColors.warning,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: AppSpacing.space3),
                TextField(
                  controller: notesController,
                  textAlign: TextAlign.right,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    hintText: 'ملاحظات (اختياري)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () async {
                final amountText = amountController.text.trim();
                if (amountText.isEmpty) {
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(
                      content: Text('الرجاء إدخال قيمة الدفعة'),
                      backgroundColor: AppColors.destructive,
                    ),
                  );
                  return;
                }
                final amount = parseArabicNumerals(amountText);
                if (amount <= 0) {
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(
                      content: Text('يجب أن تكون قيمة الدفعة أكبر من الصفر'),
                      backgroundColor: AppColors.destructive,
                    ),
                  );
                  return;
                }
                if (amount > remainingBalance) {
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text(
                        'المبلغ لا يمكن أن يتجاوز المتبقي (${_f(remainingBalance)} ج.م)',
                      ),
                      backgroundColor: AppColors.destructive,
                    ),
                  );
                  return;
                }

                final navigator = Navigator.of(ctx);
                try {
                  await debtCubit.payDebt(
                    debtId: debt.id,
                    amount: amount,
                    notes: notesController.text.trim().isEmpty
                        ? null
                        : notesController.text.trim(),
                    paymentMethod: selectedMethod,
                    debtorId: debtorId,
                    activeLiabilityType: widget.activeLiabilityType,
                  );
                  navigator.pop();
                } catch (e) {
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text(
                        e.toString().replaceAll('Exception: ', ''),
                      ),
                      backgroundColor: AppColors.destructive,
                    ),
                  );
                }
              },
              child: const Text('سداد'),
            ),
          ],
        ),
      ),
    );
  }

  void _showBulkPayDialog(
    BuildContext context,
    int debtorId,
    double totalUnpaid,
    List<DebtEntity> debts,
    List<DebtPaymentEntity> payments,
  ) {
    final amountController = TextEditingController();
    final notesController = TextEditingController();
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final debtCubit = context.read<DebtCubit>();
    bool isSaving = false;
    String selectedMethod = 'cash';
    final isPayable = widget.activeLiabilityType == DebtType.payable;

    final paymentsByDebt = <int, double>{};
    for (final p in payments) {
      paymentsByDebt[p.debtId] = (paymentsByDebt[p.debtId] ?? 0.0) + p.amount;
    }
    final activeDebts = debts.where((d) => !d.isPaid).toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    showDialog(
      context: context,
      barrierDismissible: !isSaving,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          return AlertDialog(
            backgroundColor: AppColors.card,
            title: Text(
              'دفعة من الرصيد',
              style: AppTextStyles.headline.copyWith(color: AppColors.foreground),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'إجمالي المستحق: ${_f(totalUnpaid)} ج.م',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.mutedForeground,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space1),
                  Text(
                    'يتم توزيع الدفعة تلقائياً من الأقدم إلى الأحدث',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.mutedForeground,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space4),
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.right,
                    autofocus: true,
                    enabled: !isSaving,
                    decoration: const InputDecoration(
                      hintText: 'قيمة الدفعة',
                      suffixText: 'ج.م',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space3),
                  Text(
                    'طريقة السداد:',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.mutedForeground,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space2),
                  Row(
                    children: [
                      Expanded(
                        child: ChoiceChip(
                          label: const Center(child: Text('نقدي')),
                          selected: selectedMethod == 'cash',
                          onSelected: isSaving
                              ? null
                              : (val) {
                                  if (val) {
                                    setDialogState(
                                      () => selectedMethod = 'cash',
                                    );
                                  }
                                },
                        ),
                      ),
                      const SizedBox(width: AppSpacing.space2),
                      Expanded(
                        child: ChoiceChip(
                          label: const Center(child: Text('أخرى')),
                          selected: selectedMethod == 'other',
                          onSelected: isSaving
                              ? null
                              : (val) {
                                  if (val) {
                                    setDialogState(
                                      () => selectedMethod = 'other',
                                    );
                                  }
                                },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.space2),
                  Text(
                    selectedMethod == 'cash'
                        ? (isPayable
                            ? 'سيتم خصم المبلغ من الخزينة النقدية'
                            : 'سيتم إضافة المبلغ إلى الخزينة النقدية')
                        : 'تنبيه: اختيار (أخرى) يسجل الدفعة دون أي تأثير على رصيد الخزينة أو المحافظ',
                    style: AppTextStyles.caption.copyWith(
                      color: selectedMethod == 'cash'
                          ? AppColors.mutedForeground
                          : AppColors.warning,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space3),
                  TextField(
                    controller: notesController,
                    textAlign: TextAlign.right,
                    maxLines: 2,
                    enabled: !isSaving,
                    decoration: const InputDecoration(
                      hintText: 'ملاحظات (اختياري)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space4),
                  // Preview section with natural duration
                  Text(
                    'الديون المستحقة (${activeDebts.length})',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.mutedForeground,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space2),
                  ...activeDebts.map((d) {
                    final paid = paymentsByDebt[d.id] ?? 0.0;
                    final remaining = d.amount - paid;
                    final durationText =
                        DebtReminderHelper.formatDebtAgeArabic(d.createdAt);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.space1),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            paid > 0
                                ? 'متبقي ${_f(remaining)} ج.م'
                                : '${_f(d.amount)} ج.م',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.foreground,
                            ),
                          ),
                          Text(
                            durationText,
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.mutedForeground,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: isSaving ? null : () => Navigator.pop(ctx),
                child: const Text('إلغاء'),
              ),
              ElevatedButton(
                onPressed: isSaving
                    ? null
                    : () async {
                        final amountText = amountController.text.trim();
                        if (amountText.isEmpty) {
                          scaffoldMessenger.showSnackBar(
                            const SnackBar(
                              content: Text('الرجاء إدخال المبلغ'),
                              backgroundColor: AppColors.destructive,
                            ),
                          );
                          return;
                        }
                        final amount = parseArabicNumerals(amountText);
                        if (amount <= 0) {
                          scaffoldMessenger.showSnackBar(
                            const SnackBar(
                              content: Text('يجب أن يكون المبلغ أكبر من الصفر'),
                              backgroundColor: AppColors.destructive,
                            ),
                          );
                          return;
                        }
                        final notesText = notesController.text.trim();
                        setDialogState(() => isSaving = true);
                        final navigator = Navigator.of(ctx);
                        try {
                          await debtCubit.bulkPayDebts(
                            debtorId: debtorId,
                            totalAmount: amount,
                            notes: notesText.isEmpty ? null : notesText,
                            paymentMethod: selectedMethod,
                            activeLiabilityType: widget.activeLiabilityType,
                          );
                          navigator.pop();
                          if (mounted) {
                            scaffoldMessenger.showSnackBar(
                              SnackBar(
                                content: Text(
                                  'تم سداد ${_f(amount)} ج.م بنجاح',
                                ),
                                backgroundColor: AppColors.success,
                              ),
                            );
                          }
                        } catch (e) {
                          setDialogState(() => isSaving = false);
                          scaffoldMessenger.showSnackBar(
                            SnackBar(
                              content: Text(
                                e.toString().replaceAll('Exception: ', ''),
                              ),
                              backgroundColor: AppColors.destructive,
                            ),
                          );
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.primaryForeground,
                ),
                child: isSaving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('تأكيد السداد'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showEditDebtDialog(
    BuildContext context,
    DebtEntity debt,
    DebtorEntity debtor,
  ) {
    final isManual = debt.operationId == null;
    final nameController = TextEditingController(text: debtor.name);
    final phoneController = TextEditingController(text: debtor.phone ?? '');
    final notesController = TextEditingController(text: debtor.notes ?? '');
    final amountController = TextEditingController(
      text: debt.amount > 0 ? debt.amount.toStringAsFixed(0) : '',
    );
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final debtCubit = context.read<DebtCubit>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        title: Text(
          'تعديل الدين',
          style: AppTextStyles.headline.copyWith(
            color: AppColors.foreground,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isManual)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.space3),
                  margin: const EdgeInsets.only(bottom: AppSpacing.space3),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(
                      color: AppColors.warning.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    'هذا الدين مرتبط بعملية - يمكن تعديل الملاحظات فقط',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.warning,
                    ),
                  ),
                ),
              if (isManual) ...[
                if (debt.isCashLoan)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.space3),
                    margin: const EdgeInsets.only(
                      bottom: AppSpacing.space3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(
                        color: AppColors.warning.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      'تغيير المبلغ سيعدل رصيد الدرج النقدي تلقائياً',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.warning,
                      ),
                    ),
                  ),
                TextField(
                  controller: nameController,
                  textAlign: TextAlign.right,
                  decoration: const InputDecoration(
                    hintText: 'اسم العميل',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: AppSpacing.space2),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  textAlign: TextAlign.right,
                  decoration: const InputDecoration(
                    hintText: 'رقم الهاتف (اختياري)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: AppSpacing.space2),
              ],
              TextField(
                controller: notesController,
                textAlign: TextAlign.right,
                maxLines: 2,
                decoration: const InputDecoration(
                  hintText: 'ملاحظات (اختياري)',
                  border: OutlineInputBorder(),
                ),
              ),
              if (isManual) ...[
                const SizedBox(height: AppSpacing.space2),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.right,
                  decoration: const InputDecoration(
                    hintText: 'المبلغ',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newName = nameController.text.trim();
              final newPhone = phoneController.text.trim();
              final newNotes = notesController.text.trim();
              final amountText = amountController.text.trim();
              final newAmount = amountText.isEmpty
                  ? 0.0
                  : parseArabicNumerals(amountText);

              if (isManual) {
                if (newName.isEmpty) {
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(
                      content: Text('اسم العميل مطلوب'),
                      backgroundColor: AppColors.destructive,
                    ),
                  );
                  return;
                }
                if (newAmount <= 0) {
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(
                      content: Text('المبلغ غير صحيح'),
                      backgroundColor: AppColors.destructive,
                    ),
                  );
                  return;
                }
              }

              final navigator = Navigator.of(ctx);
              try {
                await debtCubit.editDebt(
                  debt: debt,
                  debtor: debtor,
                  newName: newName,
                  newPhone: newPhone,
                  newNotes: newNotes,
                  newAmount: newAmount,
                );
                navigator.pop();
              } catch (e) {
                scaffoldMessenger.showSnackBar(
                  const SnackBar(
                    content: Text('فشل تحديث الدين'),
                    backgroundColor: AppColors.destructive,
                  ),
                );
              }
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  Future<void> _showCancelDebtDialog(
    BuildContext context,
    DebtEntity debt,
    int debtorId,
  ) async {
    final isPayable = debt.debtType == DebtType.payable;
    final label = isPayable ? 'المستحق' : 'الذمة';
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final debtCubit = context.read<DebtCubit>();

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        title: Text(
          'إلغاء $label',
          style: AppTextStyles.headline.copyWith(
            color: AppColors.destructive,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'هل تريد إلغاء هذا $label بمبلغ ${_f(debt.amount)} ج.م؟',
              style: AppTextStyles.body.copyWith(color: AppColors.foreground),
            ),
            const SizedBox(height: AppSpacing.space3),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.space3),
              decoration: BoxDecoration(
                color: AppColors.destructive.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppRadius.sm),
                border: Border.all(
                  color: AppColors.destructive.withValues(alpha: 0.25),
                ),
              ),
              child: Text(
                'تنبيه: الإلغاء يُستخدم فقط للذمم التي أُضيفت بالخطأ.\n'
                'لن يتم تسجيل أي دفعة ولن يتأثر رصيد الخزينة أو المحافظ.\n'
                '${debt.isCashLoan ? "سيتم استعادة مبلغ القرض النقدي إلى الدرج." : ""}'
                '\nلا يمكن الإلغاء إذا كانت هناك دفعات مسجلة أو إذا كانت الذمة مرتبطة بعملية.',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.destructive,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('تراجع'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.destructive,
              foregroundColor: Colors.white,
            ),
            child: const Text('إلغاء الذمة'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    try {
      await debtCubit.cancelDebt(
        debtId: debt.id,
        debtorId: debtorId,
        activeLiabilityType: widget.activeLiabilityType,
      );
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('تم إلغاء $label بنجاح'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: AppColors.destructive,
          ),
        );
      }
    }
  }
}

class _DebtTile extends StatelessWidget {
  final DebtEntity debt;
  final DebtorEntity debtor;
  final double remainingBalance;
  final double paidAmount;
  final List<DebtPaymentEntity> payments;
  final VoidCallback onSettle;
  final VoidCallback onPay;
  final VoidCallback onEdit;
  final VoidCallback onCancel;

  const _DebtTile({
    required this.debt,
    required this.debtor,
    required this.remainingBalance,
    required this.paidAmount,
    this.payments = const [],
    required this.onSettle,
    required this.onPay,
    required this.onEdit,
    required this.onCancel,
  });

  static String _f(double v) => NumberFormat('#,##0.##', 'ar').format(v);

  @override
  Widget build(BuildContext context) {
    final String typeLabel;
    final Color color;
    final String providerLabel;

    if (debt.isCashLoan) {
      typeLabel = 'دين نقدي من الدرج';
      color = AppColors.warning;
      providerLabel = '';
    } else {
      final isDeposit = debt.operationType == 'deposit';
      typeLabel = isDeposit ? 'إيداع' : 'سحب';
      color = isDeposit ? AppColors.destructive : AppColors.success;
      providerLabel =
          debt.providerType == 'instaPay' ? 'InstaPay' : 'Vodafone Cash';
    }

    final durationText = DebtReminderHelper.formatDebtAgeArabic(debt.createdAt);

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
        vertical: AppSpacing.space1,
      ),
      padding: const EdgeInsets.all(AppSpacing.space4),
      decoration: BoxDecoration(
        color: debt.isPaid ? AppColors.cardSecondary : AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border50),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top badges row: Type, Provider, Duration
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          typeLabel,
                          style: AppTextStyles.caption.copyWith(
                            color: color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        if (providerLabel.isNotEmpty)
                          Text(
                            providerLabel,
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.mutedForeground,
                              fontSize: 10,
                            ),
                          ),

                        if (debt.isCashLoan)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.space2,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.warning.withValues(alpha: .15),
                              borderRadius:
                                  BorderRadius.circular(AppRadius.sm),
                            ),
                            child: Text(
                              'دين نقدي',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.warning,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.space2,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: (debt.debtType == DebtType.settlementDebt
                                    ? AppColors.primary
                                    : AppColors.mutedForeground)
                                .withValues(alpha: .15),
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                          child: Text(
                            debt.debtType.label,
                            style: AppTextStyles.caption.copyWith(
                              color: debt.debtType == DebtType.settlementDebt
                                  ? AppColors.primary
                                  : AppColors.mutedForeground,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),

                        // Debt duration badge (e.g. "منذ 16 يوم")
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.space2,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.schedule_rounded,
                                size: 11,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                durationText,
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.primary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    // Date created
                    Text(
                      DateFormatter.formatFullDateTime(debt.createdAt),
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.mutedForeground,
                        fontSize: 11,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Amounts breakdown: Original, Paid, Remaining
                    if (paidAmount > 0) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'المبلغ الأصلي:',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.mutedForeground,
                            ),
                          ),
                          Text(
                            '${_f(debt.amount)} ج.م',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.mutedForeground,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'تم سداد:',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.success,
                            ),
                          ),
                          Text(
                            '${_f(paidAmount)} ج.م',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.success,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'المتبقي:',
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.foreground,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${_f(remainingBalance)} ج.م — $durationText',
                            style: AppTextStyles.body.copyWith(
                              color: debt.isPaid
                                  ? AppColors.success
                                  : AppColors.destructive,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      Text(
                        '${_f(debt.amount)} ج.م — $durationText',
                        style: AppTextStyles.body.copyWith(
                          color: debt.isPaid
                              ? AppColors.foreground
                              : AppColors.foreground,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],

                    if (debt.notes != null && debt.notes!.trim().isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppSpacing.space3),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                          border: Border.all(color: AppColors.border50),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.sticky_note_2_outlined,
                              size: 18,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: AppSpacing.space2),
                            Expanded(
                              child: Text(
                                debt.notes!,
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.foreground,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 8),

          if (!debt.isPaid)
            Wrap(
              alignment: WrapAlignment.end,
              spacing: 6,
              runSpacing: 6,
              children: [
                IconButton(
                  onPressed: onEdit,
                  icon: const Icon(
                    Icons.edit_rounded,
                    size: 18,
                  ),
                ),
                TextButton(
                  onPressed: onCancel,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.destructive,
                  ),
                  child: const Text('إلغاء الذمة'),
                ),
                TextButton(
                  onPressed: onPay,
                  child: const Text('سداد جزء'),
                ),
                ElevatedButton(
                  onPressed: onSettle,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.primaryForeground,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.space3,
                      vertical: AppSpacing.space1,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                  ),
                  child: const Text('تسوية بالكامل'),
                ),
              ],
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: onEdit,
                  icon: const Icon(
                    Icons.edit_rounded,
                    size: 18,
                  ),
                ),
                const Icon(
                  Icons.check_circle,
                  color: AppColors.success,
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _PaymentTile extends StatelessWidget {
  final DebtPaymentEntity payment;

  const _PaymentTile({required this.payment});

  static String _f(double v) => NumberFormat('#,##0.##', 'ar').format(v);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
        vertical: AppSpacing.space1,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space4,
        vertical: AppSpacing.space3,
      ),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border50),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'دفعة بقيمة ${_f(payment.amount)} ج.م',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (payment.notes != null && payment.notes!.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.space1),
                  Text(
                    payment.notes!,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.mutedForeground,
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.space1),
                Text(
                  'طريقة الدفع: ${payment.paymentMethod == 'cash' ? 'نقدي' : (payment.paymentMethod == 'other' ? 'أخرى' : payment.paymentMethod)}',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.mutedForeground,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          Text(
            DateFormatter.formatFullDateTime(payment.createdAt),
            style: AppTextStyles.caption.copyWith(
              color: AppColors.mutedForeground,
            ),
          ),
        ],
      ),
    );
  }
}
