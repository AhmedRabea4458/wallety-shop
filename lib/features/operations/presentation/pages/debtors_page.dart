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
import 'package:smart_expense/features/operations/domain/entities/debtor_entity.dart';
import 'package:smart_expense/features/operations/domain/entities/debtor_filter.dart';
import 'package:smart_expense/features/operations/presentation/cubit/debt_cubit.dart';
import 'package:smart_expense/features/operations/presentation/cubit/debt_state.dart';
import 'package:smart_expense/shared/widgets/filter_chip_widget.dart';

class DebtorsPage extends StatefulWidget {
  const DebtorsPage({super.key});

  @override
  State<DebtorsPage> createState() => _DebtorsPageState();
}

class _DebtorsPageState extends State<DebtorsPage> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<DebtCubit>().loadDebtors();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(
                  left: AppSpacing.screenHorizontal,
                  right: AppSpacing.screenHorizontal,
                  top: AppSpacing.space4,
                  bottom: AppSpacing.space2,
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
                        'الذمم',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.headline.copyWith(color: AppColors.foreground),
                      ),
                    ),
                    const SizedBox(width: 48),
                    IconButton(
                      onPressed: () => _showManualDebtDialog(context),
                      icon: Container(
                        padding: const EdgeInsets.all(AppSpacing.space2),
                        decoration: BoxDecoration(
                          color: AppColors.primary10,
                          borderRadius: BorderRadius.circular(AppRadius.full),
                        ),
                        child: const Icon(Icons.add_rounded, color: AppColors.primary, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Liability Type Selector Tabs
            BlocBuilder<DebtCubit, DebtState>(
              buildWhen: (previous, current) => current is DebtorsLoaded,
              builder: (context, state) {
                final currentType = state is DebtorsLoaded ? state.activeLiabilityType : DebtType.customerDebt;
                return SliverToBoxAdapter(
                  child: _buildTabSelector(context, currentType),
                );
              },
            ),
            // Summary Card for Active Tab
            BlocBuilder<DebtCubit, DebtState>(
              buildWhen: (previous, current) => current is DebtorsLoaded,
              builder: (context, state) {
                if (state is! DebtorsLoaded) return const SliverToBoxAdapter(child: SizedBox.shrink());
                final isPayable = state.activeLiabilityType == DebtType.payable;
                final totalBalance = state.debtorBalances.values.fold(0.0, (sum, b) => sum + b);
                final label = isPayable ? 'إجمالي المستحقات عليّ' : 'إجمالي آجل العملاء';
                final color = isPayable ? AppColors.warning : AppColors.primary;
                final count = state.debtors.where((d) => (state.debtorBalances[d.id] ?? 0) > 0).length;

                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.screenHorizontal,
                      vertical: AppSpacing.space2,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.space4),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        border: Border.all(color: color.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.mutedForeground)),
                              const SizedBox(height: AppSpacing.space1),
                              Text(
                                '${NumberFormat('#,##0.##', 'ar').format(totalBalance)} ج.م',
                                style: AppTextStyles.headline.copyWith(
                                  color: color,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space3, vertical: AppSpacing.space1),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(AppRadius.full),
                            ),
                            child: Text(
                              isPayable ? '$count مستحق' : '$count مدين',
                              style: AppTextStyles.caption.copyWith(color: color, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            // Search Bar
            BlocBuilder<DebtCubit, DebtState>(
              buildWhen: (previous, current) => current is DebtorsLoaded,
              builder: (context, state) {
                final isPayable = state is DebtorsLoaded && state.activeLiabilityType == DebtType.payable;
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: AppSpacing.screenHorizontal,
                      right: AppSpacing.screenHorizontal,
                      bottom: AppSpacing.space3,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        border: Border.all(color: AppColors.border50),
                      ),
                      child: TextField(
                        controller: _searchController,
                        textAlign: TextAlign.right,
                        onChanged: (v) {
                          setState(() {});
                          context.read<DebtCubit>().searchDebtors(v);
                        },
                        decoration: InputDecoration(
                          hintText: isPayable ? 'بحث باسم الشخص/الجهة أو الهاتف...' : 'بحث باسم العميل أو رقم الهاتف...',
                          hintStyle: AppTextStyles.caption.copyWith(color: AppColors.mutedForeground),
                          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.mutedForeground, size: 20),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear_rounded, color: AppColors.mutedForeground, size: 18),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {});
                                    context.read<DebtCubit>().searchDebtors('');
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.space4,
                            vertical: AppSpacing.space3,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            BlocBuilder<DebtCubit, DebtState>(
              buildWhen: (previous, current) => current is DebtorsLoaded,
              builder: (context, state) {
                final activeFilter = state is DebtorsLoaded ? state.selectedFilter : DebtorFilter.outstanding;
                final isPayable = state is DebtorsLoaded && state.activeLiabilityType == DebtType.payable;
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: AppSpacing.screenHorizontal,
                      right: AppSpacing.screenHorizontal,
                      bottom: AppSpacing.space3,
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          FilterChipWidget(
                            label: 'الكل',
                            isActive: activeFilter == DebtorFilter.all || activeFilter == null,
                            onTap: () => context.read<DebtCubit>().filterByDebtorType(DebtorFilter.all),
                          ),
                          const SizedBox(width: AppSpacing.space2),
                          FilterChipWidget(
                            label: isPayable ? 'مستحق' : 'آجل',
                            isActive: activeFilter == DebtorFilter.outstanding,
                            onTap: () => context.read<DebtCubit>().filterByDebtorType(DebtorFilter.outstanding),
                          ),
                          const SizedBox(width: AppSpacing.space2),
                          FilterChipWidget(
                            label: 'خالص',
                            isActive: activeFilter == DebtorFilter.paid,
                            onTap: () => context.read<DebtCubit>().filterByDebtorType(DebtorFilter.paid),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            BlocBuilder<DebtCubit, DebtState>(
              buildWhen: (previous, current) =>
                  (current is DebtLoading && (previous is DebtInitial || previous is DebtError)) ||
                  current is DebtError ||
                  current is DebtorsLoaded,
              builder: (context, state) {
                if (state is DebtLoading) {
                  return const SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(AppSpacing.space8),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  );
                }
                if (state is DebtError) {
                  return SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.space8),
                        child: Text(state.message, style: AppTextStyles.body.copyWith(color: AppColors.destructive)),
                      ),
                    ),
                  );
                }
                if (state is DebtorsLoaded) {
                  final isPayable = state.activeLiabilityType == DebtType.payable;
                  if (state.debtors.isEmpty) {
                    String emptyMessage = isPayable ? 'لا توجد مستحقات عليّ' : 'لا يوجد آجل للعملاء';
                    if (state.searchQuery.isNotEmpty) {
                      emptyMessage = 'لا توجد نتائج للبحث "${state.searchQuery}"';
                    } else if (state.selectedFilter == DebtorFilter.outstanding) {
                      emptyMessage = isPayable ? 'لا توجد مستحقات معلقة' : 'لا يوجد مدينين مستحقين';
                    } else if (state.selectedFilter == DebtorFilter.paid) {
                      emptyMessage = isPayable ? 'لا توجد مستحقات خالصين' : 'لا يوجد مدينين خالصين';
                    }
                    return SliverToBoxAdapter(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.space8),
                          child: Text(emptyMessage, style: const TextStyle(color: AppColors.mutedForeground)),
                        ),
                      ),
                    );
                  }
                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final debtor = state.debtors[index];
                        final balance = state.debtorBalances[debtor.id] ?? 0.0;
                        return _DebtorCard(
                          debtor: debtor,
                          balance: balance,
                          onTap: () async {
                            final debtCubit = context.read<DebtCubit>();
                            await context.push(AppRoutes.debtorDetail, extra: debtor.id);
                            if (mounted) {
                              debtCubit.loadDebtors(silent: true);
                            }
                          },
                        );
                      },
                      childCount: state.debtors.length,
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

  Widget _buildTabSelector(BuildContext context, DebtType currentType) {
    final isCustomer = currentType == DebtType.customerDebt;
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
        vertical: AppSpacing.space2,
      ),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border50),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => context.read<DebtCubit>().selectLiabilityType(DebtType.customerDebt),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.space2),
                decoration: BoxDecoration(
                  color: isCustomer ? AppColors.primary10 : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: isCustomer ? Border.all(color: AppColors.primary.withValues(alpha: 0.3)) : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('🟢 ', style: TextStyle(fontSize: 12)),
                    Text(
                      'آجل العملاء',
                      style: AppTextStyles.body.copyWith(
                        color: isCustomer ? AppColors.primary : AppColors.mutedForeground,
                        fontWeight: isCustomer ? FontWeight.w700 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.space2),
          Expanded(
            child: GestureDetector(
              onTap: () => context.read<DebtCubit>().selectLiabilityType(DebtType.payable),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.space2),
                decoration: BoxDecoration(
                  color: !isCustomer ? AppColors.warning.withValues(alpha: 0.15) : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: !isCustomer ? Border.all(color: AppColors.warning.withValues(alpha: 0.4)) : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('🟠 ', style: TextStyle(fontSize: 12)),
                    Text(
                      'المستحقات عليّ',
                      style: AppTextStyles.body.copyWith(
                        color: !isCustomer ? AppColors.warning : AppColors.mutedForeground,
                        fontWeight: !isCustomer ? FontWeight.w700 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showManualDebtDialog(BuildContext context) {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final amountController = TextEditingController();
    final notesController = TextEditingController();
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final debtCubit = context.read<DebtCubit>();
    final activeLiability = debtCubit.activeLiabilityType;
    final isPayable = activeLiability == DebtType.payable;
    bool isCashLoan = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(
            isPayable ? 'إضافة مستحق يدوي' : 'إضافة آجل يدوي',
            style: AppTextStyles.headline.copyWith(color: AppColors.foreground),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  textAlign: TextAlign.right,
                  decoration: InputDecoration(
                    hintText: isPayable ? 'اسم الشخص / الجهة' : 'اسم العميل',
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: AppSpacing.space2),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  textAlign: TextAlign.right,
                  decoration: const InputDecoration(hintText: 'رقم الهاتف (اختياري)', border: OutlineInputBorder()),
                ),
                const SizedBox(height: AppSpacing.space2),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.right,
                  decoration: const InputDecoration(hintText: 'المبلغ', border: OutlineInputBorder()),
                ),
                const SizedBox(height: AppSpacing.space2),
                TextField(
                  controller: notesController,
                  textAlign: TextAlign.right,
                  maxLines: 2,
                  decoration: const InputDecoration(hintText: 'ملاحظات (اختياري)', border: OutlineInputBorder()),
                ),
                if (!isPayable) ...[
                  const SizedBox(height: AppSpacing.space2),
                  CheckboxListTile(
                    value: isCashLoan,
                    onChanged: (v) => setDialogState(() => isCashLoan = v ?? false),
                    title: Text('دين نقدي من الدرج', style: AppTextStyles.body.copyWith(color: AppColors.foreground)),
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    activeColor: AppColors.primary,
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
            ElevatedButton(
              onPressed: () {
                final name = nameController.text.trim();
                final amountText = amountController.text.trim();
                if (name.isEmpty) {
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text(isPayable ? 'اسم الشخص / الجهة مطلوب' : 'اسم العميل مطلوب'),
                      backgroundColor: AppColors.destructive,
                    ),
                  );
                  return;
                }
                final amount = double.tryParse(amountText) ?? 0;
                if (amount <= 0) {
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(content: Text('المبلغ غير صحيح'), backgroundColor: AppColors.destructive),
                  );
                  return;
                }
                final notes = notesController.text.trim();
                debtCubit.createManualDebt(
                  customerName: name,
                  customerPhone: phoneController.text.trim().isEmpty ? null : phoneController.text.trim(),
                  amount: amount,
                  notes: notes.isEmpty ? null : notes,
                  isCashLoan: isCashLoan,
                  debtType: activeLiability,
                ).then((_) {
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text(isPayable ? 'تم إضافة المستحق بنجاح' : 'تم إضافة الدين بنجاح'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }).catchError((e) {
                  scaffoldMessenger.showSnackBar(
                    SnackBar(content: Text(e.toString()), backgroundColor: AppColors.destructive),
                  );
                });
                Navigator.pop(ctx);
              },
              child: const Text('حفظ'),
            ),
          ],
        ),
      ),
    );
  }
}

class _DebtorCard extends StatelessWidget {
  final DebtorEntity debtor;
  final double balance;
  final VoidCallback onTap;

  const _DebtorCard({
    required this.debtor,
    required this.balance,
    required this.onTap,
  });

  static String _f(double v) => NumberFormat('#,##0.##', 'ar').format(v);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenHorizontal,
          vertical: AppSpacing.space2,
        ),
        padding: const EdgeInsets.all(AppSpacing.space4),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.border50),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: const Icon(Icons.person_outline_rounded, color: AppColors.warning, size: 20),
            ),
            const SizedBox(width: AppSpacing.space3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(debtor.name, style: AppTextStyles.body.copyWith(color: AppColors.foreground, fontWeight: FontWeight.w600)),
                  if (debtor.phone != null && debtor.phone!.isNotEmpty)
                    Text(debtor.phone!, style: AppTextStyles.caption.copyWith(color: AppColors.mutedForeground)),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.space2),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${_f(balance)} ج.م',
                  style: AppTextStyles.body.copyWith(
                    color: balance > 0 ? AppColors.destructive : AppColors.mutedForeground,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  balance > 0 ? 'مستحق' : 'خالص',
                  style: AppTextStyles.caption.copyWith(
                    color: balance > 0 ? AppColors.destructive : AppColors.success,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
            const SizedBox(width: AppSpacing.space2),
            const Icon(Icons.chevron_left, color: AppColors.mutedForeground),
          ],
        ),
      ),
    );
  }
}

