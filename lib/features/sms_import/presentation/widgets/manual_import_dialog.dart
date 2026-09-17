import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smart_expense/core/di/injection_container.dart';
import 'package:smart_expense/core/errors/error_mapper.dart';
import 'package:smart_expense/core/errors/exceptions.dart';
import 'package:smart_expense/core/theme/app_colors.dart';
import 'package:smart_expense/core/theme/app_radius.dart';
import 'package:smart_expense/core/theme/app_spacing.dart';
import 'package:smart_expense/core/theme/app_text_styles.dart';
import 'package:smart_expense/core/utils/arabic_numerals.dart';
import 'package:smart_expense/features/operations/domain/entities/instapay_account_entity.dart';
import 'package:smart_expense/features/operations/domain/entities/operation_entity.dart';
import 'package:smart_expense/features/operations/domain/entities/provider_type.dart';
import 'package:smart_expense/features/operations/domain/entities/shift_entity.dart';
import 'package:smart_expense/features/operations/domain/entities/wallet_entity.dart';
import 'package:smart_expense/features/operations/domain/repositories/instapay_account_repository.dart';
import 'package:smart_expense/features/operations/domain/repositories/shift_repository.dart';
import 'package:smart_expense/features/operations/domain/repositories/wallet_repository.dart';
import 'package:smart_expense/features/sms_import/data/sms_import_processor.dart';
import 'package:smart_expense/features/sms_import/domain/models/sms_record.dart';

class ManualImportDialog extends StatefulWidget {
  final SmsRecord record;
  final VoidCallback? onImportSuccess;

  const ManualImportDialog({
    super.key,
    required this.record,
    this.onImportSuccess,
  });

  @override
  State<ManualImportDialog> createState() => _ManualImportDialogState();
}

class _ManualImportDialogState extends State<ManualImportDialog> {
  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;

  ShiftEntity? _activeShift;
  List<WalletEntity> _wallets = [];
  List<InstaPayAccountEntity> _accounts = [];

  int? _selectedWalletId;
  int? _selectedAccountId;

  // Form controllers
  final TextEditingController _commissionController = TextEditingController();
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _customerPhoneController = TextEditingController();
  final TextEditingController _paidNowController = TextEditingController();

  // Debt & Payable states (exactly like AddOperationPage)
  bool _isDebt = false;          // For deposit (آجل)
  bool _isCreatePayable = false; // For withdrawal (مستحق)

  @override
  void initState() {
    super.initState();
    _loadDependencies();
  }

  @override
  void dispose() {
    _commissionController.dispose();
    _customerNameController.dispose();
    _customerPhoneController.dispose();
    _paidNowController.dispose();
    super.dispose();
  }

  Future<void> _loadDependencies() async {
    try {
      final shift = await sl<ShiftRepository>().getActiveShift();
      final allWallets = await sl<WalletRepository>().getWallets();
      final allAccounts = await sl<InstaPayAccountRepository>().getAll();

      setState(() {
        _activeShift = shift;
        _wallets = allWallets.where((w) => !w.isArchived).toList();
        _accounts = allAccounts;

        _selectedWalletId = widget.record.selectedWalletId ??
            (_wallets.isNotEmpty ? _wallets.first.id : null);
        _selectedAccountId = widget.record.selectedInstaPayAccountId ??
            (_accounts.isNotEmpty ? _accounts.first.id : null);

        // Pre-fill customer name and phone from SMS if available
        if (widget.record.partyName != null &&
            widget.record.partyName!.isNotEmpty) {
          _customerNameController.text = widget.record.partyName!;
        }
        if (widget.record.phoneNumber != null &&
            widget.record.phoneNumber!.isNotEmpty) {
          _customerPhoneController.text = widget.record.phoneNumber!;
        }

        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'فشل تحميل بيانات الحسابات: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _handleConfirmImport() async {
    setState(() => _errorMessage = null);

    if (_activeShift == null) {
      setState(() => _errorMessage = 'يجب فتح وردية أولاً قبل استيراد العملية');
      return;
    }

    if (widget.record.providerType == ProviderType.vodafoneCash &&
        _selectedWalletId == null) {
      setState(() => _errorMessage = 'يرجى اختيار المحفظة أولاً');
      return;
    }

    if (widget.record.providerType == ProviderType.instaPay &&
        _selectedAccountId == null) {
      setState(() => _errorMessage = 'يرجى اختيار حساب InstaPay أولاً');
      return;
    }

    // Parse commission
    final commissionText = _commissionController.text.trim();
    final commission = commissionText.isEmpty
        ? 0.0
        : parseArabicNumerals(commissionText);

    if (commission < 0) {
      setState(() => _errorMessage = 'لا يمكن أن تكون العمولة بالسالب');
      return;
    }

    // Validation for debt / payable matching AddOperationPage
    final isWithdrawal = widget.record.operationType == OperationType.withdrawal;

    if (!isWithdrawal && _isDebt) {
      if (_customerNameController.text.trim().isEmpty) {
        setState(() => _errorMessage = 'اسم العميل مطلوب لتسجيل الآجل');
        return;
      }
    }

    if (isWithdrawal && _isCreatePayable) {
      if (_customerNameController.text.trim().isEmpty) {
        setState(() => _errorMessage = 'اسم المستحق له مطلوب');
        return;
      }
    }

    final paidNowText = _paidNowController.text.trim();
    final paidNowVal =
        paidNowText.isEmpty ? 0.0 : parseArabicNumerals(paidNowText);

    setState(() => _isSaving = true);

    try {
      final processor = SmsImportProcessor();
      await processor.importPendingRecord(
        widget.record,
        walletId: _selectedWalletId,
        instaPayAccountId: _selectedAccountId,
        commission: commission,
        isDebt: _isDebt,
        isCreatePayable: _isCreatePayable,
        paidNow: paidNowVal,
        customerName: _customerNameController.text.trim().isNotEmpty
            ? _customerNameController.text.trim()
            : null,
        customerPhone: _customerPhoneController.text.trim().isNotEmpty
            ? _customerPhoneController.text.trim()
            : null,
      );

      if (mounted) {
        Navigator.of(context).pop();
        widget.onImportSuccess?.call();
        String successMsg = 'تم استيراد العملية بنجاح إلى سجل العمليات';
        if (_isDebt) {
          successMsg += ' (مسجلة كآجل على العميل)';
        } else if (_isCreatePayable) {
          successMsg += ' (مسجلة كمستحق مؤجل)';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(successMsg),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } on InsufficientCashDrawerBalanceException {
      if (mounted) {
        setState(() {
          _isSaving = false;
          _errorMessage =
              'رصيد درج النقدية غير كافٍ لإتمام السحب نقداً. يمكنك تفعيل خيار "تسجيل كمستحق مؤجل" لتسجيل العملية دون خصمها من الدرج.';
        });
      }
    } on InsufficientBalanceException {
      if (mounted) {
        setState(() {
          _isSaving = false;
          _errorMessage = 'رصيد المحفظة غير كافٍ لإتمام العملية.';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSaving = false;
          _errorMessage = ErrorMapper.map(e);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final record = widget.record;
    final isWithdrawal = record.operationType == OperationType.withdrawal;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.space5),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'مراجعة واستيراد العملية',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.foreground,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.space3),

              // Summary Card
              Container(
                padding: const EdgeInsets.all(AppSpacing.space4),
                decoration: BoxDecoration(
                  color: AppColors.cardSecondary,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            record.providerType?.label ?? 'غير محدد',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.space2),
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.space2,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: isWithdrawal
                                  ? AppColors.success.withValues(alpha: 0.15)
                                  : AppColors.destructive.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                            ),
                            child: Text(
                              isWithdrawal ? 'سحب (عميل أرسل للمحل)' : 'إيداع (المحل أرسل للعميل)',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.caption.copyWith(
                                color: isWithdrawal
                                    ? AppColors.success
                                    : AppColors.destructive,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.space2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'المبلغ:',
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.mutedForeground,
                          ),
                        ),
                        Flexible(
                          child: Text(
                            '${record.amount?.toStringAsFixed(2) ?? "0.00"} ج.م',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.end,
                            style: AppTextStyles.headline.copyWith(
                              color: AppColors.foreground,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (record.referenceNumber != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('رقم المرجع:', style: AppTextStyles.caption),
                          Text(
                            record.referenceNumber!,
                            style: AppTextStyles.caption.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (record.partyName != null &&
                        record.partyName!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('الطرف الآخر:', style: AppTextStyles.caption),
                          Expanded(
                            child: Text(
                              record.partyName!,
                              textAlign: TextAlign.end,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.caption.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (record.phoneNumber != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('رقم الهاتف:', style: AppTextStyles.caption),
                          Text(
                            record.phoneNumber!,
                            style: AppTextStyles.caption.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.space4),

              // Active Shift Warning
              if (_activeShift == null && !_isLoading) ...[
                Container(
                  padding: const EdgeInsets.all(AppSpacing.space3),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: AppColors.warning),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded,
                          color: AppColors.warning),
                      const SizedBox(width: AppSpacing.space2),
                      Expanded(
                        child: Text(
                          'لا توجد وردية نشطة حالياً. يرجى فتح وردية من الشاشة الرئيسية لتتمكن من إضافة العملية.',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.foreground,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.space4),
              ],

              // Account Selector
              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.space4),
                    child: CircularProgressIndicator(),
                  ),
                )
              else ...[
                if (record.providerType == ProviderType.vodafoneCash) ...[
                  Text(
                    'اختر المحفظة:',
                    style: AppTextStyles.bodyLarge,
                  ),
                  const SizedBox(height: AppSpacing.space2),
                  DropdownButtonFormField<int>(
                    value: _selectedWalletId,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.space3,
                        vertical: AppSpacing.space2,
                      ),
                    ),
                    items: _wallets.map((w) {
                      return DropdownMenuItem<int>(
                        value: w.id,
                        child: Text('${w.name} (${w.balance} ج.م)'),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() => _selectedWalletId = val);
                    },
                  ),
                ] else if (record.providerType == ProviderType.instaPay) ...[
                  Text(
                    'اختر حساب InstaPay:',
                    style: AppTextStyles.bodyLarge,
                  ),
                  const SizedBox(height: AppSpacing.space2),
                  DropdownButtonFormField<int>(
                    value: _selectedAccountId,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.space3,
                        vertical: AppSpacing.space2,
                      ),
                    ),
                    items: _accounts.map((a) {
                      return DropdownMenuItem<int>(
                        value: a.id,
                        child: Text('${a.name} (${a.balance} ج.م)'),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() => _selectedAccountId = val);
                    },
                  ),
                ],

                const SizedBox(height: AppSpacing.space4),

                // Commission Field (numeric, matches AddOperationPage)
                Text(
                  'العمولة (اختياري):',
                  style: AppTextStyles.bodyLarge,
                ),
                const SizedBox(height: AppSpacing.space2),
                TextFormField(
                  controller: _commissionController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                  ],
                  decoration: InputDecoration(
                    hintText: '0',
                    suffixText: 'ج.م',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.space3,
                      vertical: AppSpacing.space2,
                    ),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: AppSpacing.space4),

                // DEPOSIT FLOW: Debt Section (آجل) - EXACTLY like AddOperationPage
                if (!isWithdrawal) ...[
                  Container(
                    decoration: BoxDecoration(
                      color: _isDebt
                          ? AppColors.primary.withValues(alpha: 0.08)
                          : AppColors.cardSecondary,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(
                        color: _isDebt
                            ? AppColors.primary.withValues(alpha: 0.4)
                            : AppColors.border50,
                      ),
                    ),
                    child: Column(
                      children: [
                        SwitchListTile(
                          title: Text(
                            'تسجيل كآجل على العميل',
                            style: AppTextStyles.body.copyWith(
                              color: _isDebt
                                  ? AppColors.primary
                                  : AppColors.foreground,
                              fontWeight: _isDebt
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                          subtitle: Text(
                            'سيتم تسجيل دين على العميل بالمبلغ والعمولة',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.mutedForeground,
                            ),
                          ),
                          value: _isDebt,
                          activeTrackColor: AppColors.primary,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.space3,
                            vertical: 0,
                          ),
                          onChanged: (val) {
                            setState(() => _isDebt = val);
                          },
                        ),
                        if (_isDebt) ...[
                          const Divider(height: 1),
                          Padding(
                            padding: const EdgeInsets.all(AppSpacing.space3),
                            child: Column(
                              children: [
                                TextFormField(
                                  controller: _customerNameController,
                                  decoration: InputDecoration(
                                    labelText: 'اسم العميل (مطلوب)',
                                    hintText: 'أدخل اسم العميل لتسجيل الآجل',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(AppRadius.md),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.space3,
                                      vertical: AppSpacing.space2,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.space3),
                                TextFormField(
                                  controller: _customerPhoneController,
                                  keyboardType: TextInputType.phone,
                                  decoration: InputDecoration(
                                    labelText: 'رقم الهاتف (اختياري)',
                                    hintText: '01XXXXXXXXX',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(AppRadius.md),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.space3,
                                      vertical: AppSpacing.space2,
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

                // WITHDRAWAL FLOW: Payable Section (مستحق مؤجل) - EXACTLY like AddOperationPage
                if (isWithdrawal) ...[
                  Container(
                    decoration: BoxDecoration(
                      color: _isCreatePayable
                          ? AppColors.warning.withValues(alpha: 0.08)
                          : AppColors.cardSecondary,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(
                        color: _isCreatePayable
                            ? AppColors.warning.withValues(alpha: 0.4)
                            : AppColors.border50,
                      ),
                    ),
                    child: Column(
                      children: [
                        CheckboxListTile(
                          value: _isCreatePayable,
                          onChanged: (v) {
                            setState(() {
                              _isCreatePayable = v ?? false;
                            });
                          },
                          title: Text(
                            'تسجيل كمستحق مؤجل',
                            style: AppTextStyles.body.copyWith(
                              color: _isCreatePayable
                                  ? AppColors.warning
                                  : AppColors.foreground,
                              fontWeight: _isCreatePayable
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                          subtitle: Text(
                            'سيتم تسجيل المبلغ كمستحق دون خصمه من الدرج',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.mutedForeground,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.space3,
                            vertical: 0,
                          ),
                          controlAffinity: ListTileControlAffinity.leading,
                          activeColor: AppColors.warning,
                        ),
                        if (_isCreatePayable) ...[
                          const Divider(height: 1),
                          Padding(
                            padding: const EdgeInsets.all(AppSpacing.space3),
                            child: Column(
                              children: [
                                TextFormField(
                                  controller: _paidNowController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    labelText:
                                        'المبلغ المدفوع كاش الآن (اختياري - 0 للمؤجل بالكامل)',
                                    hintText: '0',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(AppRadius.md),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.space3,
                                      vertical: AppSpacing.space2,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.space3),
                                TextFormField(
                                  controller: _customerNameController,
                                  decoration: InputDecoration(
                                    labelText: 'اسم المستحق له (مطلوب)',
                                    hintText: 'أدخل اسم العميل / الجهة',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(AppRadius.md),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.space3,
                                      vertical: AppSpacing.space2,
                                    ),
                                    labelStyle: AppTextStyles.caption.copyWith(
                                      color: AppColors.warning,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.space3),
                                TextFormField(
                                  controller: _customerPhoneController,
                                  keyboardType: TextInputType.phone,
                                  decoration: InputDecoration(
                                    labelText: 'رقم الهاتف (اختياري)',
                                    hintText: '01XXXXXXXXX',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(AppRadius.md),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.space3,
                                      vertical: AppSpacing.space2,
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
              ],

              // Error display
              if (_errorMessage != null) ...[
                const SizedBox(height: AppSpacing.space3),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.space3),
                  decoration: BoxDecoration(
                    color: AppColors.destructive.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: AppColors.destructive.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline,
                          color: AppColors.destructive, size: 20),
                      const SizedBox(width: AppSpacing.space2),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.destructive,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: AppSpacing.space5),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                      ),
                      child: const Text('إلغاء'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.space3),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: (_isSaving || _isLoading || _activeShift == null)
                          ? null
                          : _handleConfirmImport,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.primaryForeground,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('تأكيد الاستيراد'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
