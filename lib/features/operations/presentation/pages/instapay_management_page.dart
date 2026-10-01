import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:smart_expense/core/theme/app_colors.dart';
import 'package:smart_expense/core/theme/app_radius.dart';
import 'package:smart_expense/core/theme/app_spacing.dart';
import 'package:smart_expense/core/theme/app_text_styles.dart';
import 'package:smart_expense/core/utils/arabic_numerals.dart';
import 'package:smart_expense/features/operations/domain/entities/instapay_account_entity.dart';
import 'package:smart_expense/features/operations/presentation/cubit/instapay_account_cubit.dart';

class InstaPayManagementPage extends StatefulWidget {
  const InstaPayManagementPage({super.key});

  @override
  State<InstaPayManagementPage> createState() => _InstaPayManagementPageState();
}

class _InstaPayManagementPageState extends State<InstaPayManagementPage> {
  static const Color _brandColor = Color(0xFFF59E0B);

  @override
  void initState() {
    super.initState();
    context.read<InstaPayAccountCubit>().loadAccounts();
  }

  static String _formatCurrency(double amount) {
    return NumberFormat('#,##0.##', 'ar').format(amount);
  }

  void _showAddAccountDialog() {
    final nameController = TextEditingController();
    final balanceController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final cubit = context.read<InstaPayAccountCubit>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        bool isSubmitting = false;

        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: AppColors.card,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.space2),
                    decoration: BoxDecoration(
                      color: _brandColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: const Icon(
                      Icons.add_circle_outline_rounded,
                      color: _brandColor,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.space3),
                  Text(
                    'إضافة حساب InstaPay',
                    style: AppTextStyles.headline.copyWith(
                      color: AppColors.foreground,
                    ),
                  ),
                ],
              ),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'اسم الحساب *',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.foreground,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.space1),
                      TextFormField(
                        controller: nameController,
                        textAlign: TextAlign.right,
                        autofocus: true,
                        decoration: const InputDecoration(
                          hintText: 'مثال: حساب البنك الأهلي',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'يرجى إدخال اسم الحساب';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.space4),
                      Text(
                        'الرصيد الافتتاحي (ج.م)',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.foreground,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.space1),
                      TextFormField(
                        controller: balanceController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        textAlign: TextAlign.right,
                        decoration: const InputDecoration(
                          hintText: '0.00',
                          suffixText: 'ج.م',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value != null && value.trim().isNotEmpty) {
                            final parsed = parseArabicNumerals(value.trim());
                            if (parsed < 0) {
                              return 'الرصيد لا يمكن أن يكون سالباً';
                            }
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.space2),
                      Text(
                        'ملاحظة: الرصيد الافتتاحي لا يُنشئ أي عملية مالية جديدة.',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.mutedForeground,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSubmitting ? null : () => Navigator.pop(dialogContext),
                  child: Text(
                    'إلغاء',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.mutedForeground,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) return;
                          setStateDialog(() => isSubmitting = true);
                          final name = nameController.text.trim();
                          final balanceText = balanceController.text.trim();
                          final balance = balanceText.isEmpty
                              ? 0.0
                              : parseArabicNumerals(balanceText);

                          try {
                            await cubit.addAccount(name, balance: balance);
                            if (!dialogContext.mounted) return;
                            Navigator.pop(dialogContext);
                            if (mounted) {
                              ScaffoldMessenger.of(this.context).showSnackBar(
                                const SnackBar(
                                  content: Text('تمت إضافة الحساب بنجاح'),
                                  backgroundColor: AppColors.success,
                                ),
                              );
                            }
                          } catch (e) {
                            if (!dialogContext.mounted) return;
                            setStateDialog(() => isSubmitting = false);
                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                              const SnackBar(
                                content: Text('حدث خطأ أثناء إضافة الحساب'),
                                backgroundColor: AppColors.destructive,
                              ),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _brandColor,
                    foregroundColor: Colors.white,
                  ),
                  child: isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('إضافة الحساب'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditNameDialog(InstaPayAccountEntity account) {
    final nameController = TextEditingController(text: account.name);
    final formKey = GlobalKey<FormState>();
    final cubit = context.read<InstaPayAccountCubit>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        bool isSubmitting = false;

        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: AppColors.card,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.space2),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: const Icon(
                      Icons.edit_rounded,
                      color: AppColors.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.space3),
                  Text(
                    'تعديل اسم الحساب',
                    style: AppTextStyles.headline.copyWith(
                      color: AppColors.foreground,
                    ),
                  ),
                ],
              ),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'اسم الحساب الجديد *',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.foreground,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.space1),
                    TextFormField(
                      controller: nameController,
                      textAlign: TextAlign.right,
                      autofocus: true,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'يرجى إدخال اسم الحساب';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.space2),
                    Text(
                      'تعديل الاسم فقط لا يغيّر الرصيد أو أي عمليات سابقة.',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.mutedForeground,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSubmitting ? null : () => Navigator.pop(dialogContext),
                  child: Text(
                    'إلغاء',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.mutedForeground,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) return;
                          setStateDialog(() => isSubmitting = true);
                          final newName = nameController.text.trim();

                          try {
                            await cubit.updateAccount(
                              InstaPayAccountEntity(
                                id: account.id,
                                name: newName,
                                balance: account.balance,
                                createdAt: account.createdAt,
                              ),
                            );
                            if (!dialogContext.mounted) return;
                            Navigator.pop(dialogContext);
                            if (mounted) {
                              ScaffoldMessenger.of(this.context).showSnackBar(
                                const SnackBar(
                                  content: Text('تم تعديل اسم الحساب بنجاح'),
                                  backgroundColor: AppColors.success,
                                ),
                              );
                            }
                          } catch (e) {
                            if (!dialogContext.mounted) return;
                            setStateDialog(() => isSubmitting = false);
                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                              const SnackBar(
                                content: Text('حدث خطأ أثناء تعديل الاسم'),
                                backgroundColor: AppColors.destructive,
                              ),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.primaryForeground,
                  ),
                  child: isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primaryForeground,
                          ),
                        )
                      : const Text('حفظ التعديل'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAdjustBalanceDialog(InstaPayAccountEntity account) {
    final balanceController = TextEditingController(
      text: account.balance.toStringAsFixed(2),
    );
    final formKey = GlobalKey<FormState>();
    final cubit = context.read<InstaPayAccountCubit>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        bool isSubmitting = false;

        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: AppColors.card,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.space2),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: const Icon(
                      Icons.tune_rounded,
                      color: AppColors.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.space3),
                  Expanded(
                    child: Text(
                      'تعديل الرصيد يدويًا',
                      style: AppTextStyles.headline.copyWith(
                        color: AppColors.foreground,
                      ),
                    ),
                  ),
                ],
              ),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.space3),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          border: Border.all(color: AppColors.border50),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'الحساب:',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.mutedForeground,
                              ),
                            ),
                            Text(
                              account.name,
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.foreground,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.space3),
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.space3),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          border: Border.all(
                            color: AppColors.warning.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.info_outline_rounded,
                              color: AppColors.warning,
                              size: 18,
                            ),
                            const SizedBox(width: AppSpacing.space2),
                            Expanded(
                              child: Text(
                                'تنبيه: هذا تعديل يدوي مباشر لرصيد الحساب فقط. لا يُنشئ أي عملية مالية ولا يؤثر على الدرج أو المحافظ أو السجلات السابقة.',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.warning,
                                  height: 1.35,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.space4),
                      Text(
                        'الرصيد الجديد (ج.م) *',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.foreground,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.space1),
                      TextFormField(
                        controller: balanceController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        textAlign: TextAlign.right,
                        autofocus: true,
                        decoration: const InputDecoration(
                          suffixText: 'ج.م',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'يرجى إدخال الرصيد الجديد';
                          }
                          final parsed = parseArabicNumerals(value.trim());
                          if (parsed < 0) {
                            return 'الرصيد لا يمكن أن يكون سالباً';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSubmitting ? null : () => Navigator.pop(dialogContext),
                  child: Text(
                    'إلغاء',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.mutedForeground,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) return;
                          setStateDialog(() => isSubmitting = true);
                          final newBalance = parseArabicNumerals(
                            balanceController.text.trim(),
                          );

                          try {
                            await cubit.updateBalance(account.id, newBalance);
                            if (!dialogContext.mounted) return;
                            Navigator.pop(dialogContext);
                            if (mounted) {
                              ScaffoldMessenger.of(this.context).showSnackBar(
                                const SnackBar(
                                  content: Text('تم تعديل رصيد الحساب بنجاح'),
                                  backgroundColor: AppColors.success,
                                ),
                              );
                            }
                          } catch (e) {
                            if (!dialogContext.mounted) return;
                            setStateDialog(() => isSubmitting = false);
                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                              const SnackBar(
                                content: Text('حدث خطأ أثناء تعديل الرصيد'),
                                backgroundColor: AppColors.destructive,
                              ),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.primaryForeground,
                  ),
                  child: isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primaryForeground,
                          ),
                        )
                      : const Text('تأكيد التعديل'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _handleDeleteAccount(InstaPayAccountEntity account) async {
    final cubit = context.read<InstaPayAccountCubit>();
    try {
      final hasOps = await cubit.hasOperations(account.id);
      if (!mounted) return;

      if (hasOps) {
        // Linked to historical operations: Hard delete not allowed to maintain financial integrity.
        showDialog(
          context: context,
          builder: (dialogContext) {
            return AlertDialog(
              backgroundColor: AppColors.card,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.space2),
                    decoration: BoxDecoration(
                      color: AppColors.destructive.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: const Icon(
                      Icons.warning_amber_rounded,
                      color: AppColors.destructive,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.space3),
                  Text(
                    'تعذر حذف الحساب',
                    style: AppTextStyles.headline.copyWith(
                      color: AppColors.foreground,
                    ),
                  ),
                ],
              ),
              content: Text(
                'لا يمكن حذف حساب "${account.name}" لأنه مرتبط بعمليات مالية تاريخية مسجلة في النظام. لحماية سلامة البيانات والتقارير المالية، يظل الحساب محفوظاً.',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.foreground,
                  height: 1.4,
                ),
              ),
              actions: [
                ElevatedButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.primaryForeground,
                  ),
                  child: const Text('حسناً'),
                ),
              ],
            );
          },
        );
      } else {
        // Safe delete for unused account
        showDialog(
          context: context,
          builder: (dialogContext) {
            bool isDeleting = false;

            return StatefulBuilder(
              builder: (context, setStateDialog) {
                return AlertDialog(
                  backgroundColor: AppColors.card,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                  title: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.space2),
                        decoration: BoxDecoration(
                          color: AppColors.destructive.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: const Icon(
                          Icons.delete_outline_rounded,
                          color: AppColors.destructive,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.space3),
                      Text(
                        'حذف الحساب',
                        style: AppTextStyles.headline.copyWith(
                          color: AppColors.foreground,
                        ),
                      ),
                    ],
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'هل أنت متأكد من حذف حساب "${account.name}" نهائياً؟',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.foreground,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.space2),
                      Text(
                        'هذا الحساب غير مرتبط بأي عمليات مالية سابقة ويمكن حذفه بأمان.',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: isDeleting ? null : () => Navigator.pop(dialogContext),
                      child: Text(
                        'إلغاء',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.mutedForeground,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: isDeleting
                          ? null
                          : () async {
                              setStateDialog(() => isDeleting = true);
                              try {
                                await cubit.deleteAccount(account.id);
                                if (!dialogContext.mounted) return;
                                Navigator.pop(dialogContext);
                                if (mounted) {
                                  ScaffoldMessenger.of(this.context).showSnackBar(
                                    const SnackBar(
                                      content: Text('تم حذف الحساب بنجاح'),
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (!dialogContext.mounted) return;
                                setStateDialog(() => isDeleting = false);
                                ScaffoldMessenger.of(dialogContext).showSnackBar(
                                  const SnackBar(
                                    content: Text('فشل حذف الحساب'),
                                    backgroundColor: AppColors.destructive,
                                  ),
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.destructive,
                        foregroundColor: Colors.white,
                      ),
                      child: isDeleting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('حذف'),
                    ),
                  ],
                );
              },
            );
          },
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('حدث خطأ أثناء فحص ارتباط الحساب'),
          backgroundColor: AppColors.destructive,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(
              child: SizedBox(height: AppSpacing.space4),
            ),
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
                      onPressed: () => context.pop(),
                      icon: Container(
                        padding: const EdgeInsets.all(AppSpacing.space2),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(AppRadius.full),
                        ),
                        child: const Icon(
                          Icons.arrow_forward_rounded,
                          color: AppColors.foreground,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.space3),
                    Expanded(
                      child: Text(
                        'إدارة حسابات InstaPay',
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
            const SliverToBoxAdapter(
              child: SizedBox(height: AppSpacing.space2),
            ),
            // Total balance summary card
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenHorizontal,
                ),
                child: BlocBuilder<InstaPayAccountCubit, InstaPayAccountState>(
                  builder: (context, state) {
                    final accounts = state is InstaPayAccountLoaded
                        ? state.accounts
                        : <InstaPayAccountEntity>[];
                    final totalBalance = accounts.fold<double>(
                      0.0,
                      (sum, acc) => sum + acc.balance,
                    );

                    return Container(
                      padding: const EdgeInsets.all(AppSpacing.space5),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        border: Border.all(
                          color: AppColors.border50,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: _brandColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(AppRadius.md),
                            ),
                            child: const Icon(
                              Icons.account_balance_wallet_rounded,
                              color: _brandColor,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.space4),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'إجمالي أرصدة InstaPay',
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.mutedForeground,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.space1),
                                Text(
                                  '${_formatCurrency(totalBalance)} ج.م',
                                  style: AppTextStyles.headline.copyWith(
                                    color: _brandColor,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.space3,
                              vertical: AppSpacing.space1,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(AppRadius.full),
                              border: Border.all(color: AppColors.border50),
                            ),
                            child: Text(
                              '${accounts.length} حسابات',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.mutedForeground,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: AppSpacing.space4),
            ),
            // Add account button
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenHorizontal,
                ),
                child: ElevatedButton.icon(
                  onPressed: _showAddAccountDialog,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('إضافة حساب جديد'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _brandColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.space4,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: AppSpacing.space4),
            ),
            // Accounts list or status
            BlocBuilder<InstaPayAccountCubit, InstaPayAccountState>(
              builder: (context, state) {
                if (state is InstaPayAccountLoading) {
                  return const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(AppSpacing.space8),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  );
                }

                if (state is InstaPayAccountError) {
                  return SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.space6),
                        child: Column(
                          children: [
                            Text(
                              state.message,
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.destructive,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.space4),
                            ElevatedButton(
                              onPressed: () {
                                context
                                    .read<InstaPayAccountCubit>()
                                    .loadAccounts();
                              },
                              child: const Text('إعادة المحاولة'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                final accounts = state is InstaPayAccountLoaded
                    ? state.accounts
                    : <InstaPayAccountEntity>[];

                if (accounts.isEmpty && state is InstaPayAccountLoaded) {
                  return SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.space8),
                        child: Container(
                          padding: const EdgeInsets.all(AppSpacing.space6),
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                            border: Border.all(color: AppColors.border50),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: _brandColor.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.account_balance_outlined,
                                  color: _brandColor,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.space3),
                              Text(
                                'لا توجد حسابات InstaPay بعد',
                                style: AppTextStyles.bodyLarge.copyWith(
                                  color: AppColors.foreground,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.space1),
                              Text(
                                'اضغط على "إضافة حساب جديد" لإضافة أول حساب.',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.mutedForeground,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final account = accounts[index];
                      return _InstaPayAccountCard(
                        account: account,
                        brandColor: _brandColor,
                        onEditName: () => _showEditNameDialog(account),
                        onAdjustBalance: () => _showAdjustBalanceDialog(account),
                        onDelete: () => _handleDeleteAccount(account),
                      );
                    },
                    childCount: accounts.length,
                  ),
                );
              },
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: AppSpacing.space8),
            ),
          ],
        ),
      ),
    );
  }
}

class _InstaPayAccountCard extends StatelessWidget {
  final InstaPayAccountEntity account;
  final Color brandColor;
  final VoidCallback onEditName;
  final VoidCallback onAdjustBalance;
  final VoidCallback onDelete;

  const _InstaPayAccountCard({
    required this.account,
    required this.brandColor,
    required this.onEditName,
    required this.onAdjustBalance,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
        vertical: AppSpacing.space2,
      ),
      padding: const EdgeInsets.all(AppSpacing.space4),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: AppColors.border50,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: brandColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Icon(
              Icons.account_balance_rounded,
              color: brandColor,
            ),
          ),
          const SizedBox(width: AppSpacing.space3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        account.name,
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.foreground,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Text(
                        'نشط',
                        style: AppTextStyles.caption.copyWith(
                          fontSize: 10,
                          color: AppColors.success,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${NumberFormat('#,##0.##', 'ar').format(account.balance)} ج.م',
                  style: AppTextStyles.body.copyWith(
                    color: brandColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onAdjustBalance,
            icon: const Icon(
              Icons.tune_rounded,
              color: AppColors.mutedForeground,
              size: 20,
            ),
            tooltip: 'تعديل الرصيد',
          ),
          IconButton(
            onPressed: onEditName,
            icon: const Icon(
              Icons.edit_rounded,
              color: AppColors.primary,
              size: 20,
            ),
            tooltip: 'تعديل الاسم',
          ),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: AppColors.destructive,
              size: 20,
            ),
            tooltip: 'حذف الحساب',
          ),
        ],
      ),
    );
  }
}
