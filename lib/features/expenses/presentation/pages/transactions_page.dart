import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_expense/core/constants/app_routes.dart';
import 'package:smart_expense/core/constants/category_colors.dart';
import 'package:smart_expense/core/theme/app_colors.dart';
import 'package:smart_expense/core/theme/app_radius.dart';
import 'package:smart_expense/core/theme/app_spacing.dart';
import 'package:smart_expense/core/theme/app_text_styles.dart';
import 'package:smart_expense/core/utils/date_formatter.dart';
import 'package:smart_expense/features/expenses/domain/entities/transaction_entity.dart';
import 'package:smart_expense/features/expenses/presentation/cubit/transaction_cubit.dart';
import 'package:smart_expense/features/expenses/presentation/cubit/transaction_state.dart';
import 'package:smart_expense/features/expenses/presentation/widgets/transaction_card.dart';
import 'package:smart_expense/shared/widgets/filter_chip_widget.dart';
import 'package:smart_expense/shared/widgets/search_bar.dart' as app_search;

class TransactionsPage extends StatelessWidget {
  const TransactionsPage({super.key});

  static final _filterChips = [
    {'label': 'الكل', 'category': null},
    {'label': 'طعام', 'category': TransactionCategory.food},
    {'label': 'مواصلات', 'category': TransactionCategory.transport},
    {'label': 'فواتير', 'category': TransactionCategory.bills},
    {'label': 'ترفيه', 'category': TransactionCategory.entertainment},
    {'label': 'تسوق', 'category': TransactionCategory.shopping},
    {'label': 'أخرى', 'category': TransactionCategory.other},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // AppBar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenHorizontal,
                  vertical: AppSpacing.space4,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.tune_rounded,
                        color: AppColors.foreground,
                      ),
                    ),
                    Text(
                      'المعاملات',
                      style: AppTextStyles.headline.copyWith(
                        color: AppColors.foreground,
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.arrow_forward_rounded,
                        color: AppColors.foreground,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Search Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenHorizontal,
                ),
                child: app_search.SearchBar(
                  hintText: 'البحث في المعاملات...',
                  onChanged: (query) {
                    context.read<TransactionCubit>().search(query);
                  },
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(height: AppSpacing.space4),
            ),
            // Filter Chips
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenHorizontal,
                ),
                child: BlocBuilder<TransactionCubit, TransactionState>(
                  buildWhen: (previous, current) =>
                    current is TransactionLoaded,
                  builder: (context, state) {
                    final selectedCategory = state is TransactionLoaded
                        ? state.selectedCategory
                        : null;
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _filterChips.map((chip) {
                          final category = chip['category'] as TransactionCategory?;
                          final isActive = category == selectedCategory;
                          return Padding(
                            padding: const EdgeInsets.only(
                              right: AppSpacing.space2,
                            ),
                            child: FilterChipWidget(
                              label: chip['label'] as String,
                              isActive: isActive,
                              onTap: () {
                                context.read<TransactionCubit>().filterByCategory(category);
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  },
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(height: AppSpacing.space4),
            ),
            // BlocBuilder for transactions
            BlocBuilder<TransactionCubit, TransactionState>(
              builder: (context, state) {
                if (state is TransactionLoading) {
                  return SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.space8),
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  );
                } else if (state is TransactionError) {
                  return SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.space8),
                        child: Text(
                          'حدث خطأ: ${state.message}',
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.destructive,
                          ),
                        ),
                      ),
                    ),
                  );
                } else if (state is TransactionLoaded) {
                  if (state.visibleTransactions.isEmpty) {
                    final bool isSearching = state.searchQuery.isNotEmpty;
                    return SliverToBoxAdapter(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.space8),
                          child: Column(
                            children: [
                              Text(
                                isSearching
                                    ? 'لا توجد نتائج للبحث'
                                    : 'لا توجد معاملات',
                                style: AppTextStyles.body.copyWith(
                                  color: AppColors.mutedForeground,
                                ),
                              ),
                              if (!isSearching) ...[
                                const SizedBox(height: AppSpacing.space4),
                                ElevatedButton(
                                  onPressed: () {
                                    context.push(
                                      AppRoutes.addTransaction,
                                      extra: {'isExpense': true},
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: AppColors.primaryForeground,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(AppRadius.md),
                                    ),
                                  ),
                                  child: Text(
                                    'إضافة معاملة',
                                    style: AppTextStyles.body.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    );
                  }
                  return _TransactionsList(
                    transactions: state.visibleTransactions,
                  );
                }
                return const SliverToBoxAdapter(
                  child: SizedBox.shrink(),
                );
              },
            ),
            // Bottom padding
            SliverToBoxAdapter(
              child: SizedBox(height: AppSpacing.space8),
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionsList extends StatelessWidget {
  final List<TransactionEntity> transactions;

  const _TransactionsList({required this.transactions});

  @override
  Widget build(BuildContext context) {
    // Group transactions by date
    final grouped = _groupByDate(transactions);

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final group = grouped[index];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date group header
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenHorizontal,
                  vertical: AppSpacing.space3,
                ),
                child: Text(
                  group.dateLabel,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.mutedForeground,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              // Transactions in this group
              ...group.transactions.map((transaction) {
                final categoryInfo = _getCategoryInfo(transaction.category);
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenHorizontal,
                    vertical: AppSpacing.space1,
                  ),
                  child: Dismissible(
                    key: Key('transaction_${transaction.id}'),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      decoration: BoxDecoration(
                        color: AppColors.destructive,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                      ),
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.only(left: AppSpacing.space5),
                      child: const Icon(
                        Icons.delete_rounded,
                        color: Colors.white,
                      ),
                    ),
                    onDismissed: (_) {
                      context.read<TransactionCubit>().deleteTransaction(transaction.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('تم حذف المعاملة'),
                          backgroundColor: AppColors.destructive,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    child: TransactionCard(
                      name: transaction.note,
                      category: categoryInfo.label,
                      date: DateFormatter.formatTransactionDate(transaction.date),
                      amount: '${transaction.amount.toStringAsFixed(0)} ج.م',
                      iconBackgroundColor: AppColors.withAlpha(
                        categoryInfo.color,
                        0.15,
                      ),
                      iconColor: categoryInfo.color,
                      icon: categoryInfo.icon,
                      isExpense: transaction.type == TransactionType.expense,
                      onTap: () {},
                    ),
                  ),
                );
              }),
            ],
          );
        },
        childCount: grouped.length,
      ),
    );
  }

  List<_TransactionGroup> _groupByDate(List<TransactionEntity> transactions) {
    final Map<String, List<TransactionEntity>> map = {};
    for (final t in transactions) {
      final key = DateFormatter.groupKey(t.date);
      map.putIfAbsent(key, () => []).add(t);
    }
    return map.entries.map((e) => _TransactionGroup(e.key, e.value)).toList();
  }

  _CategoryInfo _getCategoryInfo(TransactionCategory category) {
    switch (category) {
      case TransactionCategory.food:
        return _CategoryInfo(
          label: 'طعام',
          icon: Icons.restaurant_rounded,
          color: CategoryColors.food,
        );
      case TransactionCategory.transport:
        return _CategoryInfo(
          label: 'مواصلات',
          icon: Icons.directions_car_rounded,
          color: CategoryColors.transport,
        );
      case TransactionCategory.bills:
        return _CategoryInfo(
          label: 'فواتير',
          icon: Icons.receipt_long_rounded,
          color: CategoryColors.bills,
        );
      case TransactionCategory.entertainment:
        return _CategoryInfo(
          label: 'ترفيه',
          icon: Icons.movie_rounded,
          color: CategoryColors.entertainment,
        );
      case TransactionCategory.shopping:
        return _CategoryInfo(
          label: 'تسوق',
          icon: Icons.shopping_bag_rounded,
          color: CategoryColors.shopping,
        );
      case TransactionCategory.salary:
        return _CategoryInfo(
          label: 'راتب',
          icon: Icons.attach_money_rounded,
          color: CategoryColors.salary,
        );
      case TransactionCategory.other:
        return _CategoryInfo(
          label: 'أخرى',
          icon: Icons.more_horiz_rounded,
          color: CategoryColors.other,
        );
    }
  }
}

class _TransactionGroup {
  final String dateLabel;
  final List<TransactionEntity> transactions;

  _TransactionGroup(this.dateLabel, this.transactions);
}

class _CategoryInfo {
  final String label;
  final IconData icon;
  final Color color;

  _CategoryInfo({
    required this.label,
    required this.icon,
    required this.color,
  });
}
