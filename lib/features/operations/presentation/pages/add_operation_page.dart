import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:smart_expense/core/theme/app_colors.dart';
import 'package:smart_expense/core/theme/app_radius.dart';
import 'package:smart_expense/core/theme/app_spacing.dart';
import 'package:smart_expense/core/theme/app_text_styles.dart';
import 'package:smart_expense/core/utils/arabic_numerals.dart';
import 'package:smart_expense/features/operations/domain/entities/operation_entity.dart';
import 'package:smart_expense/features/operations/domain/entities/provider_type.dart';
import 'package:smart_expense/features/operations/presentation/cubit/operation_cubit.dart';
import 'package:smart_expense/features/operations/presentation/cubit/operation_state.dart';
import 'package:smart_expense/features/operations/presentation/cubit/wallet_cubit.dart';
import 'package:smart_expense/features/operations/presentation/cubit/wallet_state.dart';
import 'package:smart_expense/features/operations/presentation/widgets/operation_type_selector.dart';
import 'package:smart_expense/features/operations/presentation/widgets/provider_selector.dart';
import 'package:smart_expense/features/operations/presentation/widgets/wallet_selector.dart';
import 'package:smart_expense/features/expenses/presentation/widgets/amount_card.dart';
import 'package:smart_expense/features/expenses/presentation/widgets/date_selector.dart';
import 'package:smart_expense/features/expenses/presentation/widgets/description_field.dart';
import 'package:smart_expense/features/expenses/presentation/widgets/save_transaction_button.dart';

class AddOperationPage extends StatefulWidget {
  final OperationEntity? operationToEdit;

  const AddOperationPage({
    super.key,
    this.operationToEdit,
  });

  @override
  State<AddOperationPage> createState() => _AddOperationPageState();
}

class _AddOperationPageState extends State<AddOperationPage> {
  late OperationType _selectedType;
  late ProviderType _selectedProvider;
  int? _selectedWalletId;
  late DateTime _selectedDate;
  bool _isSaving = false;

  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _commissionController = TextEditingController();
  final TextEditingController _networkFeeController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  bool get _isEditing => widget.operationToEdit != null;

  @override
  void initState() {
    super.initState();
    context.read<WalletCubit>().getWallets();

    if (_isEditing) {
      final op = widget.operationToEdit!;
      _selectedType = op.operationType;
      _selectedProvider = op.providerType;
      _selectedWalletId = op.walletId;
      _selectedDate = op.createdAt;
      _amountController.text = op.amount.toStringAsFixed(0);
      _commissionController.text = op.commission > 0 ? op.commission.toStringAsFixed(0) : '';
      _networkFeeController.text = op.networkFee > 0 ? op.networkFee.toStringAsFixed(0) : '';
      _phoneController.text = op.phoneNumber ?? '';
      _notesController.text = op.notes ?? '';
    } else {
      _selectedType = OperationType.deposit;
      _selectedProvider = ProviderType.vodafoneCash;
      _selectedDate = DateTime.now();
    }
  }

  Future<void> _saveOperation() async {
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

    if (_selectedProvider == ProviderType.vodafoneCash && _selectedWalletId == null) {
      _showError('يرجى اختيار المحفظة');
      return;
    }

    final phoneText = _phoneController.text.trim();
    if (phoneText.isEmpty) {
      _showError('رقم الهاتف مطلوب');
      return;
    }

    final commissionText = _commissionController.text.trim();
    final commission = commissionText.isEmpty ? 0.0 : parseArabicNumerals(commissionText);
    if (commission < 0) {
      _showError('لا يمكن أن تكون العمولة سالبة');
      return;
    }

    final networkFeeText = _networkFeeController.text.trim();
    final networkFee = networkFeeText.isEmpty ? 0.0 : parseArabicNumerals(networkFeeText);
    if (networkFee < 0) {
      _showError('لا يمكن أن تكون رسوم الشبكة سالبة');
      return;
    }

    int walletId;
    if (_selectedProvider == ProviderType.instaPay) {
      walletId = _selectedWalletId ?? widget.operationToEdit?.walletId ?? 0;
    } else {
      walletId = _selectedWalletId!;
    }

    final entity = OperationEntity(
      id: _isEditing ? widget.operationToEdit!.id : 0,
      walletId: walletId,
      operationType: _selectedType,
      providerType: _selectedProvider,
      amount: amount,
      commission: commission,
      networkFee: _selectedProvider == ProviderType.vodafoneCash ? networkFee : 0.0,
      phoneNumber: phoneText,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      createdAt: _selectedDate,
    );

    final operationCubit = context.read<OperationCubit>();

    setState(() => _isSaving = true);

    try {
      if (_isEditing) {
        await operationCubit.updateOperation(entity);
      } else {
        await operationCubit.addOperation(entity);
      }
      if (!mounted) return;
      _showSuccess(_isEditing ? 'تم تحديث العملية بنجاح' : 'تم إضافة العملية بنجاح');
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      _showError(e.toString());
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.destructive,
      ),
    );
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
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
    _commissionController.dispose();
    _networkFeeController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocListener<OperationCubit, OperationState>(
          listener: (context, state) {
            if (state is OperationError) {
              _showError(state.message);
            }
          },
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenHorizontal,
                    vertical: AppSpacing.space4,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: _isSaving ? null : () => Navigator.pop(context),
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
                          _isEditing ? 'تعديل عملية' : 'إضافة عملية',
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
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenHorizontal,
                  ),
                  child: OperationTypeSelector(
                    selectedType: _selectedType,
                    onChanged: (type) {
                      if (_isSaving) return;
                      setState(() => _selectedType = type);
                    },
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(height: AppSpacing.space6),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenHorizontal,
                  ),
                  child: ProviderSelector(
                    selectedProvider: _selectedProvider,
                    onChanged: (provider) {
                      if (_isSaving) return;
                      setState(() => _selectedProvider = provider);
                    },
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(height: AppSpacing.space6),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenHorizontal,
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: _selectedProvider == ProviderType.vodafoneCash
                        ? BlocBuilder<WalletCubit, WalletState>(
                            builder: (context, state) {
                              if (state is WalletLoaded) {
                                return WalletSelector(
                                  wallets: state.wallets,
                                  selectedWalletId: _selectedWalletId,
                                  onChanged: (id) {
                                    if (_isSaving) return;
                                    setState(() => _selectedWalletId = id);
                                  },
                                );
                              }
                              return Container(
                                padding: const EdgeInsets.all(AppSpacing.space4),
                                decoration: BoxDecoration(
                                  color: AppColors.card,
                                  borderRadius: BorderRadius.circular(AppRadius.lg),
                                ),
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            },
                          )
                        : const SizedBox.shrink(),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(height: AppSpacing.space6),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenHorizontal,
                  ),
                  child: AmountCard(
                    controller: _amountController,
                    isExpense: _selectedType == OperationType.deposit,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(height: AppSpacing.space6),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenHorizontal,
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.space5,
                      vertical: AppSpacing.space4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(
                        color: AppColors.border50,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'العمولة',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.mutedForeground,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.space2),
                        TextField(
                          controller: _commissionController,
                          keyboardType: TextInputType.number,
                          enabled: !_isSaving,
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: AppColors.foreground,
                          ),
                          decoration: InputDecoration(
                            hintText: '0',
                            hintStyle: AppTextStyles.body.copyWith(
                              color: AppColors.mutedForeground,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                            isDense: true,
                            suffixText: 'ج.م',
                            suffixStyle: AppTextStyles.body.copyWith(
                              color: AppColors.mutedForeground,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(height: AppSpacing.space4),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenHorizontal,
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: _selectedProvider == ProviderType.vodafoneCash
                        ? Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.space5,
                              vertical: AppSpacing.space4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.card,
                              borderRadius: BorderRadius.circular(AppRadius.lg),
                              border: Border.all(
                                color: AppColors.border50,
                                width: 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'رسوم الشبكة (Vodafone Cash)',
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.mutedForeground,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.space2),
                                TextField(
                                  controller: _networkFeeController,
                                  keyboardType: TextInputType.number,
                                  enabled: !_isSaving,
                                  style: AppTextStyles.bodyLarge.copyWith(
                                    color: AppColors.foreground,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: '0',
                                    hintStyle: AppTextStyles.body.copyWith(
                                      color: AppColors.mutedForeground,
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.zero,
                                    isDense: true,
                                    suffixText: 'ج.م',
                                    suffixStyle: AppTextStyles.body.copyWith(
                                      color: AppColors.mutedForeground,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(height: AppSpacing.space4),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenHorizontal,
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.space5,
                      vertical: AppSpacing.space4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(
                        color: AppColors.border50,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'رقم الهاتف',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.mutedForeground,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.space2),
                        TextField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          textAlign: TextAlign.right,
                          enabled: !_isSaving,
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: AppColors.foreground,
                          ),
                          decoration: InputDecoration(
                            hintText: '01XXXXXXXXX',
                            hintStyle: AppTextStyles.body.copyWith(
                              color: AppColors.mutedForeground,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                            isDense: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(height: AppSpacing.space4),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenHorizontal,
                  ),
                  child: DescriptionField(
                    controller: _notesController,
                    hintText: 'ملاحظات إضافية',
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(height: AppSpacing.space4),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenHorizontal,
                  ),
                  child: DateSelector(
                    dateLabel: _formatDate(_selectedDate),
                    onTap: _isSaving ? null : _pickDate,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(height: AppSpacing.space8),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenHorizontal,
                  ),
                  child: BlocBuilder<OperationCubit, OperationState>(
                    builder: (context, state) {
                      return SaveTransactionButton(
                        label: _isEditing ? 'تحديث العملية' : 'حفظ العملية',
                        onPressed: _isSaving ? null : _saveOperation,
                        isLoading: state is OperationLoading || _isSaving,
                      );
                    },
                  ),
                ),
              ),
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
