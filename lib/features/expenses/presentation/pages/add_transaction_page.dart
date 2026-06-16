import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:smart_expense/core/theme/app_colors.dart';
import 'package:smart_expense/core/theme/app_radius.dart';
import 'package:smart_expense/core/theme/app_spacing.dart';
import 'package:smart_expense/core/theme/app_text_styles.dart';
import 'package:smart_expense/core/utils/arabic_numerals.dart';
import 'package:smart_expense/features/expenses/domain/entities/transaction_entity.dart';
import 'package:smart_expense/features/expenses/presentation/cubit/transaction_cubit.dart';
import 'package:smart_expense/features/expenses/presentation/cubit/transaction_state.dart';
import 'package:smart_expense/features/expenses/presentation/widgets/amount_card.dart';
import 'package:smart_expense/features/expenses/presentation/widgets/category_grid.dart';
import 'package:smart_expense/features/expenses/presentation/widgets/date_selector.dart';
import 'package:smart_expense/features/expenses/presentation/widgets/description_field.dart';
import 'package:smart_expense/features/expenses/presentation/widgets/save_transaction_button.dart';
import 'package:smart_expense/features/expenses/presentation/widgets/suggestion_chip.dart';
import 'package:smart_expense/features/expenses/presentation/widgets/transaction_type_selector.dart';

class AddTransactionPage extends StatefulWidget {
  final bool initialIsExpense;

  AddTransactionPage({
    super.key,
    this.initialIsExpense = true,
  });

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  late bool _isExpense;
  String? _selectedCategory;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _isExpense = widget.initialIsExpense;
    _selectedCategory = _isExpense ? 'طعام' : null;
  }

  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  void _saveTransaction() {
    final amountText = _amountController.text.trim();
    if (amountText.isEmpty) {
      _showError('يرجى إدخال المبلغ');
      return;
    }

    final amount = parseArabicNumerals(amountText);
    if (amount <= 0) {
      _showError('يرجى إدخال مبلغ صحيح');
      return;
    }

    if (_isExpense && (_selectedCategory == null || _selectedCategory!.isEmpty)) {
      _showError('يرجى اختيار الفئة');
      return;
    }

    final category = _isExpense
        ? _parseCategory(_selectedCategory!)
        : TransactionCategory.other;
    final type = _isExpense ? TransactionType.expense : TransactionType.income;

    final entity = TransactionEntity(
      id: 0,
      note: _descriptionController.text.trim(),
      amount: amount,
      date: _selectedDate,
      category: category,
      type: type,
    );

    context.read<TransactionCubit>().addTransaction(entity);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.destructive,
      ),
    );
  }

  TransactionCategory _parseCategory(String category) {
    switch (category) {
      case 'طعام':
        return TransactionCategory.food;
      case 'مواصلات':
        return TransactionCategory.transport;
      case 'فواتير':
        return TransactionCategory.bills;
      case 'ترفيه':
        return TransactionCategory.entertainment;
      case 'صحة':
        return TransactionCategory.other;
      case 'تسوق':
        return TransactionCategory.shopping;
      default:
        return TransactionCategory.other;
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              surface: AppColors.surface,
              onSurface: AppColors.foreground,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return 'اليوم، ${DateFormat('d MMMM y', 'ar').format(date)}';
    } else if (dateOnly == today.subtract(const Duration(days: 1))) {
      return 'أمس، ${DateFormat('d MMMM y', 'ar').format(date)}';
    } else {
      return DateFormat('EEEE، d MMMM y', 'ar').format(date);
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocListener<TransactionCubit, TransactionState>(
          listener: (context, state) {
            if (state is TransactionError) {
              _showError(state.message);
            } else if (state is TransactionLoaded) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم إضافة المعاملة بنجاح'),
                  duration: Duration(seconds: 2),
                ),
              );
              Navigator.pop(context);
            }
          },
          child: CustomScrollView(
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenHorizontal,
                    vertical: AppSpacing.space4,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
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
                          _isExpense ? 'إضافة مصروف' : 'إضافة دخل',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.headline.copyWith(
                            color: AppColors.foreground,
                          ),
                        ),
                      ),
                      const SizedBox(width: 48), // Balance for close button
                    ],
                  ),
                ),
              ),
              // Transaction Type Selector
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenHorizontal,
                  ),
                  child: TransactionTypeSelector(
                    isExpense: _isExpense,
                    onChanged: (isExpense) {
                      setState(() {
                        _isExpense = isExpense;
                        if (_isExpense) {
                          _selectedCategory = 'طعام';
                        } else {
                          _selectedCategory = null;
                        }
                      });
                    },
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(height: AppSpacing.space6),
              ),
              // Amount Card
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenHorizontal,
                  ),
                  child: AmountCard(
                    controller: _amountController,
                    isExpense: _isExpense,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(height: AppSpacing.space6),
              ),
              // Description Field
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenHorizontal,
                  ),
                  child: DescriptionField(
                    controller: _descriptionController,
                    hintText: 'أدخل وصف المعاملة',
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(height: AppSpacing.space4),
              ),
              // Suggestion Chip (only for expense)
              if (_isExpense)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.screenHorizontal,
                    ),
                    child: SuggestionChip(
                      label: 'اقتراح: طعام - مواصلات - فواتير',
                      onApply: () {},
                    ),
                  ),
                ),
              if (_isExpense)
                SliverToBoxAdapter(
                  child: SizedBox(height: AppSpacing.space6),
                ),
              // Category Grid (only for expense)
              if (_isExpense)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.screenHorizontal,
                    ),
                    child: CategoryGrid(
                      selectedCategory: _selectedCategory,
                      onCategorySelected: (category) {
                        setState(() {
                          _selectedCategory = category;
                        });
                      },
                    ),
                  ),
                ),
              if (_isExpense)
                SliverToBoxAdapter(
                  child: SizedBox(height: AppSpacing.space6),
                ),
              // Date Selector
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenHorizontal,
                  ),
                  child: DateSelector(
                    dateLabel: _formatDate(_selectedDate),
                    onTap: _pickDate,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(height: AppSpacing.space8),
              ),
              // Save Button
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenHorizontal,
                  ),
                  child: BlocBuilder<TransactionCubit, TransactionState>(
                    builder: (context, state) {
                      return SaveTransactionButton(
                        onPressed: _saveTransaction,
                        isLoading: state is TransactionLoading,
                      );
                    },
                  ),
                ),
              ),
              // Bottom padding
              SliverToBoxAdapter(
                child: SizedBox(height: AppSpacing.space8),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
