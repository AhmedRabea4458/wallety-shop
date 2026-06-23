import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:smart_expense/core/theme/app_colors.dart';
import 'package:smart_expense/core/theme/app_radius.dart';
import 'package:smart_expense/core/theme/app_spacing.dart';
import 'package:smart_expense/core/theme/app_text_styles.dart';
import 'package:smart_expense/core/errors/error_mapper.dart';
import 'package:smart_expense/core/utils/arabic_numerals.dart';
import 'package:smart_expense/features/operations/domain/entities/instapay_account_entity.dart';
import 'package:smart_expense/features/operations/domain/entities/operation_entity.dart';
import 'package:smart_expense/features/operations/domain/entities/provider_type.dart';
import 'package:smart_expense/features/operations/presentation/cubit/operation_cubit.dart';
import 'package:smart_expense/features/operations/presentation/cubit/operation_state.dart';
import 'package:smart_expense/features/operations/presentation/cubit/active_shift_cubit.dart';
import 'package:smart_expense/features/operations/presentation/cubit/active_shift_state.dart';
import 'package:smart_expense/features/operations/presentation/cubit/wallet_cubit.dart';
import 'package:smart_expense/features/operations/presentation/cubit/wallet_state.dart';
import 'package:smart_expense/features/operations/presentation/widgets/operation_type_selector.dart';
import 'package:smart_expense/features/operations/presentation/widgets/provider_selector.dart';
import 'package:smart_expense/features/operations/presentation/widgets/wallet_selector.dart';
import 'package:smart_expense/features/operations/presentation/widgets/operation_input_card.dart';
import 'package:smart_expense/features/operations/presentation/widgets/debt_section.dart';
import 'package:smart_expense/features/expenses/presentation/widgets/amount_card.dart';
import 'package:smart_expense/features/expenses/presentation/widgets/date_selector.dart';
import 'package:smart_expense/features/expenses/presentation/widgets/description_field.dart';
import 'package:smart_expense/features/operations/presentation/cubit/debt_cubit.dart';
import 'package:smart_expense/features/operations/presentation/cubit/instapay_account_cubit.dart';
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
  bool _isDebt = false;
  int? _instaPayAccountId;

  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _commissionController = TextEditingController();
  final TextEditingController _networkFeeController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _customerPhoneController = TextEditingController();

  bool get _isEditing => widget.operationToEdit != null;
  bool _isDebtLinked = false;

  @override
  void initState() {
    super.initState();
    context.read<WalletCubit>().getWallets();
    context.read<InstaPayAccountCubit>().loadAccounts();

    if (_isEditing) {
      final op = widget.operationToEdit!;
      _selectedType = op.operationType;
      _selectedProvider = op.providerType;
      _selectedWalletId = op.walletId;
      _instaPayAccountId = op.instaPayAccountId;
      _selectedDate = op.createdAt;
      _amountController.text = op.amount.toStringAsFixed(0);
      _commissionController.text = op.commission > 0 ? op.commission.toStringAsFixed(0) : '';
      _networkFeeController.text = op.networkFee > 0 ? op.networkFee.toStringAsFixed(0) : '';
      _phoneController.text = op.phoneNumber ?? '';
      _notesController.text = op.notes ?? '';
      _isDebtLinked = context.read<OperationCubit>().getDebtForOperation(op.id) != null;
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

    // Require active shift
    final shiftState = context.read<ActiveShiftCubit>().state;
    int? shiftId;
    if (shiftState is ActiveShiftLoaded) {
      shiftId = shiftState.shift.id;
    } else {
      _showError('يجب فتح وردية أولاً قبل إضافة عملية');
      return;
    }

    if (_isDebt && _customerNameController.text.trim().isEmpty) {
      _showError('اسم العميل مطلوب لتسجيل الآجل');
      return;
    }

    final entity = OperationEntity(
      id: _isEditing ? widget.operationToEdit!.id : 0,
      walletId: walletId,
      operationType: _selectedType,
      providerType: _selectedProvider,
      amount: amount,
      commission: commission,
      networkFee: _selectedProvider == ProviderType.vodafoneCash ? networkFee : 0.0,
      shiftId: shiftId,
      instaPayAccountId: _selectedProvider == ProviderType.instaPay ? _instaPayAccountId : null,
      phoneNumber: phoneText,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      createdAt: _selectedDate,
    );

    final operationCubit = context.read<OperationCubit>();

    setState(() => _isSaving = true);

    try {
      int operationId;
      if (_isEditing) {
        await operationCubit.updateOperation(entity);
        operationId = entity.id;
      } else {
        operationId = await operationCubit.addOperation(entity, isDebt: _isDebt);
      }
      if (_isDebt && !_isEditing) {
        if (!mounted) return;
        final debtCubit = context.read<DebtCubit>();
        await debtCubit.createDebtFromOperation(
          operationId: operationId,
          customerName: _customerNameController.text.trim(),
          customerPhone: _customerPhoneController.text.trim().isEmpty
              ? null
              : _customerPhoneController.text.trim(),
          operationType: _selectedType.name,
          providerType: _selectedProvider.name,
          amount: amount + commission,
        );
        await operationCubit.getOperations();
      }
      if (!mounted) return;
      _showSuccess(_isEditing ? 'تم تحديث العملية بنجاح' : 'تم إضافة العملية بنجاح');
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      _showError(ErrorMapper.map(e));
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

  void _showManageInstaPayAccountsDialog(BuildContext context) {
    final nameController = TextEditingController();
    InstaPayAccountEntity? editingAccount;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          return BlocBuilder<InstaPayAccountCubit, InstaPayAccountState>(
            builder: (context, state) {
              final accounts = state is InstaPayAccountLoaded
                  ? state.accounts
                  : <InstaPayAccountEntity>[];
              return AlertDialog(
                backgroundColor: AppColors.card,
                title: Text('إدارة حسابات InstaPay',
                    style: AppTextStyles.headline.copyWith(color: AppColors.foreground)),
                content: SizedBox(
                  width: double.maxFinite,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: nameController,
                                textAlign: TextAlign.right,
                                decoration: InputDecoration(
                                  hintText: editingAccount != null ? 'تعديل الاسم' : 'اسم الحساب الجديد',
                                  border: const OutlineInputBorder(),
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.space2),
                            ElevatedButton(
                              onPressed: () async {
                                final name = nameController.text.trim();
                                if (name.isEmpty) return;
                                final cubit = context.read<InstaPayAccountCubit>();
                                if (editingAccount != null) {
                                  await cubit.updateAccount(InstaPayAccountEntity(
                                    id: editingAccount!.id,
                                    name: name,
                                    createdAt: editingAccount!.createdAt,
                                  ));
                                } else {
                                  await cubit.addAccount(name);
                                }
                                nameController.clear();
                                setDialogState(() => editingAccount = null);
                              },
                              child: Text(editingAccount != null ? 'تعديل' : 'إضافة'),
                            ),
                          ],
                        ),
                        if (accounts.isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.space4),
                          const Divider(),
                          ...accounts.map((a) => ListTile(
                                title: Text(a.name),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit_rounded, size: 18),
                                      onPressed: () {
                                        nameController.text = a.name;
                                        setDialogState(() => editingAccount = a);
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline_rounded, size: 18),
                                      onPressed: () async {
                                        await context.read<InstaPayAccountCubit>().deleteAccount(a.id);
                                      },
                                    ),
                                  ],
                                ),
                              )),
                        ],
                      ],
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('إغلاق'),
                  ),
                ],
              );
        },
      );
    },
  ),
);
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
    _customerNameController.dispose();
    _customerPhoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
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
              if (_isDebtLinked)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.screenHorizontal,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.space4),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.lock_outline_rounded, color: AppColors.warning, size: 20),
                          const SizedBox(width: AppSpacing.space3),
                          Expanded(
                              child: Text(
                                'لا يمكن تعديل أو حذف عملية مرتبطة بدين',
                              style: AppTextStyles.body.copyWith(color: AppColors.warning),
                            ),
                          ),
                        ],
                      ),
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
                      setState(() {
                        _selectedType = type;
                        if (type == OperationType.withdrawal) _isDebt = false;
                      });
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
                            key: const ValueKey('wallet'),
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
                        : BlocBuilder<InstaPayAccountCubit, InstaPayAccountState>(
                            key: const ValueKey('instapay'),
                            builder: (context, state) {
                              final accounts = state is InstaPayAccountLoaded
                                  ? state.accounts
                                  : <InstaPayAccountEntity>[];
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.space5,
                                  vertical: AppSpacing.space4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.card,
                                  borderRadius: BorderRadius.circular(AppRadius.lg),
                                  border: Border.all(color: AppColors.border50, width: 1),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'حساب InstaPay',
                                      style: AppTextStyles.caption.copyWith(
                                        color: AppColors.mutedForeground,
                                      ),
                                    ),
                                    const SizedBox(height: AppSpacing.space3),
                                    if (accounts.isEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: AppSpacing.space2),
                                        child: Text(
                                          'لا توجد حسابات، أضف حساباً جديداً',
                                          style: AppTextStyles.caption.copyWith(
                                            color: AppColors.mutedForeground,
                                          ),
                                        ),
                                      ),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: DropdownButtonFormField<int>(
                                            value: _instaPayAccountId,
                                            isExpanded: true,
                                            decoration: const InputDecoration(
                                              border: InputBorder.none,
                                              contentPadding: EdgeInsets.zero,
                                              isDense: true,
                                            ),
                                            hint: Text(
                                              'اختر الحساب',
                                              style: AppTextStyles.body.copyWith(
                                                color: AppColors.mutedForeground,
                                              ),
                                            ),
                                            items: accounts.map((a) {
                                              return DropdownMenuItem(
                                                value: a.id,
                                                child: Text(a.name),
                                              );
                                            }).toList(),
                                            onChanged: _isSaving
                                                ? null
                                                : (v) => setState(() => _instaPayAccountId = v),
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.add_circle_outline_rounded, size: 22),
                                          color: AppColors.primary,
                                          onPressed: _isSaving
                                              ? null
                                              : () => _showManageInstaPayAccountsDialog(context),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
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
                  child: OperationInputCard(
                    label: 'العمولة',
                    controller: _commissionController,
                    keyboardType: TextInputType.number,
                    enabled: !_isSaving,
                    suffixText: 'ج.م',
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
                        ? OperationInputCard(
                            label: 'رسوم الشبكة (Vodafone Cash)',
                            controller: _networkFeeController,
                            keyboardType: TextInputType.number,
                            enabled: !_isSaving,
                            suffixText: 'ج.م',
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
                  child: OperationInputCard(
                    label: 'رقم الهاتف',
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    textAlign: TextAlign.right,
                    enabled: !_isSaving,
                    hintText: '01XXXXXXXXX',
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
                child: SizedBox(height: AppSpacing.space4),
              ),
              if (!_isEditing && _selectedType == OperationType.deposit)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
                    child: DebtSection(
                      isDebt: _isDebt,
                      isSaving: _isSaving,
                      onDebtChanged: (v) => setState(() => _isDebt = v),
                      customerNameController: _customerNameController,
                      customerPhoneController: _customerPhoneController,
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
                        onPressed: (_isSaving || _isDebtLinked) ? null : _saveOperation,
                        isLoading: _isSaving,
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
    );
  }
}
