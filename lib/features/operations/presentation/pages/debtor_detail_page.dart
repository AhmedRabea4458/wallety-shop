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
import 'package:smart_expense/features/operations/domain/entities/debt_entity.dart';
import 'package:smart_expense/features/operations/domain/entities/debt_payment_entity.dart';
import 'package:smart_expense/features/operations/domain/entities/debt_type.dart';
import 'package:smart_expense/features/operations/domain/entities/debtor_entity.dart';
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
  bool _isPaidExpanded = false;

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
                        'تفاصيل الآجل',
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
            SliverToBoxAdapter(child: SizedBox(height: AppSpacing.space4)),
            BlocBuilder<DebtCubit, DebtState>(
              buildWhen:
                  (previous, current) =>
                      current is DebtLoading ||
                      current is DebtError ||
                      current is DebtorDetailLoaded,
              builder: (context, state) {
                if (state is DebtLoading) {
                  return const SliverToBoxAdapter(
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (state is DebtError) {
                  return SliverToBoxAdapter(
                    child: Center(
                      child: Text(
                        state.message,
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.destructive,
                        ),
                      ),
                    ),
                  );
                }
                if (state is DebtorDetailLoaded) {
                  final activeDebts = state.debts.where((d) => !d.isPaid).toList();
                  final paidDebts = state.debts.where((d) => d.isPaid).toList();

                  final totalUnpaid = activeDebts.fold(
                    0.0,
                    (sum, d) {
                      final debtPayments = state.payments.where(
                        (p) => p.debtId == d.id,
                      );
                      final paid = debtPayments.fold(
                        0.0,
                        (s, p) => s + p.amount,
                      );
                      return sum + (d.amount - paid);
                    },
                  );
                  return SliverMainAxisGroup(
                    slivers: [
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
                                _row('الاسم', state.debtor.name),
                                if (state.debtor.phone != null &&
                                    state.debtor.phone!.isNotEmpty)
                                  _row('الهاتف', state.debtor.phone!),
                                const Divider(color: AppColors.border50),
                                _row('الرصيد الحالي', '${_f(totalUnpaid)} ج.م'),
                                _row('الديون المستحقة', '${activeDebts.length}'),
                                _row('الديون المدفوعة', '${paidDebts.length}'),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: SizedBox(height: AppSpacing.space6),
                      ),
                      // Active Debts Header
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.screenHorizontal,
                          ),
                          child: Text(
                            'الديون المستحقة (${activeDebts.length})',
                            style: AppTextStyles.headline.copyWith(
                              color: AppColors.foreground,
                            ),
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: SizedBox(height: AppSpacing.space3),
                      ),
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
                            final debtPayments = state.payments.where(
                              (p) => p.debtId == debt.id,
                            );
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
                              onPay:
                                  () => _showPayDebtDialog(
                                    context,
                                    debt,
                                    remainingBalance,
                                    state.debtor.id,
                                  ),
                              onSettle: () async {
                                final debtCubit =
                                    this.context.read<DebtCubit>();
                                final confirm = await showDialog<bool>(
                                  context: this.context,
                                  builder:
                                      (ctx) => AlertDialog(
                                        title: Text(
                                          'تسوية الدين',
                                          style: AppTextStyles.headline
                                              .copyWith(
                                                color: AppColors.foreground,
                                              ),
                                        ),
                                        content: Text(
                                          'هل أنت متأكد من تسوية هذا الدين؟',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed:
                                                () => Navigator.pop(ctx, false),
                                            child: const Text('إلغاء'),
                                          ),
                                          ElevatedButton(
                                            onPressed:
                                                () => Navigator.pop(ctx, true),
                                            child: const Text('تسوية'),
                                          ),
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
                              onEdit:
                                  () => _showEditDebtDialog(
                                    context,
                                    debt,
                                    state.debtor,
                                  ),
                            );
                          }, childCount: activeDebts.length),
                        ),
                      // Paid Debts Section (Collapsible)
                      if (paidDebts.isNotEmpty) ...[
                        SliverToBoxAdapter(
                          child: SizedBox(height: AppSpacing.space4),
                        ),
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.screenHorizontal,
                            ),
                            child: InkWell(
                              onTap: () => setState(() => _isPaidExpanded = !_isPaidExpanded),
                              borderRadius: BorderRadius.circular(AppRadius.md),
                              child: Container(
                                padding: const EdgeInsets.all(AppSpacing.space3),
                                decoration: BoxDecoration(
                                  color: AppColors.card,
                                  borderRadius: BorderRadius.circular(AppRadius.md),
                                  border: Border.all(color: AppColors.border50),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'الديون المدفوعة (${paidDebts.length})',
                                      style: AppTextStyles.body.copyWith(
                                        color: AppColors.mutedForeground,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Icon(
                                      _isPaidExpanded
                                          ? Icons.keyboard_arrow_up_rounded
                                          : Icons.keyboard_arrow_down_rounded,
                                      color: AppColors.mutedForeground,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        if (_isPaidExpanded) ...[
                          SliverToBoxAdapter(
                            child: SizedBox(height: AppSpacing.space3),
                          ),
                          SliverList(
                            delegate: SliverChildBuilderDelegate((
                              context,
                              index,
                            ) {
                              final debt = paidDebts[index];
                              final debtPayments = state.payments.where(
                                (p) => p.debtId == debt.id,
                              );
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
                                onPay: () {},
                                onSettle: () {},
                                onEdit:
                                    () => _showEditDebtDialog(
                                      context,
                                      debt,
                                      state.debtor,
                                    ),
                              );
                            }, childCount: paidDebts.length),
                          ),
                        ],
                      ],
                      SliverToBoxAdapter(
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
                      SliverToBoxAdapter(
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
                            final sortedPayments = List<DebtPaymentEntity>.from(
                              state.payments,
                            )..sort(
                              (a, b) => b.createdAt.compareTo(a.createdAt),
                            );
                            final payment = sortedPayments[index];
                            return _PaymentTile(payment: payment);
                          }, childCount: state.payments.length),
                        ),
                      SliverToBoxAdapter(
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

    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            backgroundColor: AppColors.card,
            title: Text(
              'سداد جزء من الدين',
              style: AppTextStyles.headline.copyWith(
                color: AppColors.foreground,
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
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
                      notes:
                          notesController.text.trim().isEmpty
                              ? null
                              : notesController.text.trim(),
                      debtorId: debtorId,
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
      builder:
          (ctx) => AlertDialog(
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
                  final newAmount =
                      amountText.isEmpty
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
}

class _DebtTile extends StatelessWidget {
  final DebtEntity debt;
  final DebtorEntity debtor;
  final double remainingBalance;
  final double paidAmount;
  final VoidCallback onSettle;
  final VoidCallback onPay;
  final VoidCallback onEdit;

  const _DebtTile({
    required this.debt,
    required this.debtor,
    required this.remainingBalance,
    required this.paidAmount,
    required this.onSettle,
    required this.onPay,
    required this.onEdit,
  });

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
                          color: (debt.debtType ==
                                      DebtType.settlementDebt
                                  ? AppColors.primary
                                  : AppColors.mutedForeground)
                              .withValues(alpha: .15),
                          borderRadius:
                              BorderRadius.circular(AppRadius.sm),
                        ),
                        child: Text(
                          debt.debtType.label,
                          style: AppTextStyles.caption.copyWith(
                            color:
                                debt.debtType ==
                                        DebtType.settlementDebt
                                    ? AppColors.primary
                                    : AppColors.mutedForeground,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  if (paidAmount > 0 && !debt.isPaid) ...[
                    Text(
                      'المبلغ الأصلي: ${_f(debt.amount)} ج.م',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.mutedForeground,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'المتبقي: ${_f(remainingBalance)} ج.م',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.foreground,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ] else
                    Text(
                      '${_f(debt.amount)} ج.م',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.foreground,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
                onPressed: onPay,
                child: const Text('سداد'),
              ),
              TextButton(
                onPressed: onSettle,
                child: const Text('تسوية'),
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

  static String _f(double v) => NumberFormat('#,##0.##', 'ar').format(v);
}

class _PaymentTile extends StatelessWidget {
  final DebtPaymentEntity payment;

  const _PaymentTile({required this.payment});

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
                  'طريقة الدفع: ${payment.paymentMethod == 'cash' ? 'نقدي' : payment.paymentMethod}',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.mutedForeground,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          Text(
            DateFormat('yyyy/MM/dd hh:mm a', 'ar').format(payment.createdAt),
            style: AppTextStyles.caption.copyWith(
              color: AppColors.mutedForeground,
            ),
          ),
        ],
      ),
    );
  }

  static String _f(double v) => NumberFormat('#,##0.##', 'ar').format(v);
}
