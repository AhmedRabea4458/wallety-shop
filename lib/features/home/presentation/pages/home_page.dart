import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:smart_expense/core/constants/app_routes.dart';
import 'package:smart_expense/core/theme/app_colors.dart';
import 'package:smart_expense/core/theme/app_spacing.dart';
import 'package:smart_expense/core/theme/app_text_styles.dart';
import 'package:smart_expense/features/expenses/domain/entities/transaction_entity.dart';
import 'package:smart_expense/features/expenses/presentation/cubit/transaction_cubit.dart';
import 'package:smart_expense/features/expenses/presentation/cubit/transaction_state.dart';
import 'package:smart_expense/features/home/presentation/widgets/balance_card.dart';
import 'package:smart_expense/features/home/presentation/widgets/home_header.dart';
import 'package:smart_expense/features/home/presentation/widgets/quick_actions_row.dart';
import 'package:smart_expense/features/home/presentation/widgets/transaction_list.dart';

class HomePage extends StatelessWidget {
  final VoidCallback? onNavigateToTransactions;

  const HomePage({
    super.key,
    this.onNavigateToTransactions,
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
        child: BlocBuilder<TransactionCubit, TransactionState>(
          builder: (context, state) {
            final now = DateTime.now();
            final monthName = DateFormat('MMMM y', 'ar').format(now);

            if (state is TransactionLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (state is TransactionError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: AppColors.destructive,
                      size: 48,
                    ),
                    const SizedBox(height: AppSpacing.space4),
                    Text(
                      'حدث خطأ أثناء تحميل البيانات',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.destructive,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.space4),
                    ElevatedButton(
                      onPressed: () {
                        context.read<TransactionCubit>().getTransactions();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.primaryForeground,
                      ),
                      child: Text(
                        'إعادة المحاولة',
                        style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            List<TransactionEntity> transactions = [];
            double income = 0;
            double expenses = 0;

            if (state is TransactionLoaded) {
              transactions = state.allTransactions;
              income = transactions
                  .where((t) => t.type == TransactionType.income)
                  .fold(0.0, (sum, t) => sum + t.amount);
              expenses = transactions
                  .where((t) => t.type == TransactionType.expense)
                  .fold(0.0, (sum, t) => sum + t.amount);
            }

            final balance = income - expenses;

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: SizedBox(height: AppSpacing.space4),
                ),
                // HomeHeader
                SliverToBoxAdapter(
                  child: HomeHeader(
                    date: monthName,
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(height: AppSpacing.space6),
                ),
                // BalanceCard
                SliverToBoxAdapter(
                  child: BalanceCard(
                    balance: _formatAmount(balance),
                    income: _formatAmount(income),
                    expenses: _formatAmount(expenses),
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(height: AppSpacing.space6),
                ),
                // QuickActions
                SliverToBoxAdapter(
                  child: QuickActionsRow(
                    onAddIncome: () {
                      context.push(
                        AppRoutes.addTransaction,
                        extra: {'isExpense': false},
                      );
                    },
                    onAddExpense: () {
                      context.push(
                        AppRoutes.addTransaction,
                        extra: {'isExpense': true},
                      );
                    },
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(height: AppSpacing.space6),
                ),
                // TransactionList
                SliverToBoxAdapter(
                  child: TransactionList(
                    transactions: transactions,
                    onViewAll: onNavigateToTransactions,
                    onAddTransaction: () {
                      context.push(
                        AppRoutes.addTransaction,
                        extra: {'isExpense': true},
                      );
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
        ),
      ),
    );
  }
}
