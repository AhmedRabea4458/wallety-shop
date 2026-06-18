import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:smart_expense/core/theme/app_colors.dart';
import 'package:smart_expense/core/theme/app_radius.dart';
import 'package:smart_expense/core/theme/app_spacing.dart';
import 'package:smart_expense/core/theme/app_text_styles.dart';
import 'package:smart_expense/core/utils/arabic_numerals.dart';
import 'package:smart_expense/features/operations/domain/entities/wallet_adjustment_entity.dart';
import 'package:smart_expense/features/operations/domain/entities/wallet_entity.dart';
import 'package:smart_expense/features/operations/presentation/cubit/wallet_adjustment_cubit.dart';
import 'package:smart_expense/features/operations/presentation/cubit/wallet_cubit.dart';
import 'package:smart_expense/features/operations/presentation/cubit/wallet_state.dart';
import 'package:smart_expense/features/operations/presentation/widgets/wallet_color_picker.dart';

class WalletManagementPage extends StatefulWidget {
  const WalletManagementPage({super.key});

  @override
  State<WalletManagementPage> createState() => _WalletManagementPageState();
}

class _WalletManagementPageState extends State<WalletManagementPage> {
  @override
  void initState() {
    super.initState();
    context.read<WalletCubit>().getWallets();
    context.read<WalletAdjustmentCubit>().loadAllAdjustments();
  }

  void _showAddWalletDialog() {
    final walletCubit = context.read<WalletCubit>();
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final balanceController = TextEditingController();
    Color selectedColor = const Color(0xFF6366F1);
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (_, setStateDialog) {
            return AlertDialog(
              backgroundColor: AppColors.card,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              title: Text(
                'إضافة محفظة جديدة',
                style: AppTextStyles.headline.copyWith(color: AppColors.foreground),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: nameController,
                      textAlign: TextAlign.right,
                      enabled: !isLoading,
                      decoration: InputDecoration(
                        hintText: 'اسم المحفظة',
                        hintStyle: AppTextStyles.body.copyWith(color: AppColors.mutedForeground),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          borderSide: BorderSide(color: AppColors.border50),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.space3),
                    TextField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      textAlign: TextAlign.right,
                      enabled: !isLoading,
                      decoration: InputDecoration(
                        hintText: 'رقم الهاتف',
                        hintStyle: AppTextStyles.body.copyWith(color: AppColors.mutedForeground),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          borderSide: BorderSide(color: AppColors.border50),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.space3),
                    TextField(
                      controller: balanceController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.right,
                      enabled: !isLoading,
                      decoration: InputDecoration(
                        hintText: 'الرصيد الافتتاحي',
                        hintStyle: AppTextStyles.body.copyWith(color: AppColors.mutedForeground),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          borderSide: BorderSide(color: AppColors.border50),
                        ),
                        suffixText: 'ج.م',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.space4),
                    Text(
                      'لون المحفظة',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.foreground,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.space2),
                    if (!isLoading)
                      WalletColorPicker(
                        selectedColor: selectedColor,
                        onColorSelected: (color) {
                          setStateDialog(() => selectedColor = color);
                        },
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isLoading ? null : () => Navigator.pop(dialogContext),
                  child: Text('إلغاء', style: AppTextStyles.body.copyWith(color: AppColors.mutedForeground)),
                ),
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          final name = nameController.text.trim();
                          if (name.isEmpty) {
                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                              const SnackBar(content: Text('اسم المحفظة مطلوب')),
                            );
                            return;
                          }
                          setStateDialog(() => isLoading = true);

                          final balance = balanceController.text.trim().isEmpty
                              ? 0.0
                              : parseArabicNumerals(balanceController.text.trim());
                          final phone = phoneController.text.trim().isEmpty ? null : phoneController.text.trim();

                          final wallet = WalletEntity(
                            id: 0,
                            name: name,
                            phoneNumber: phone,
                            balance: balance,
                            color: selectedColor,
                            createdAt: DateTime.now(),
                          );

                          try {
                            await walletCubit.addWallet(wallet);
                            if (!dialogContext.mounted) return;
                            Navigator.pop(dialogContext);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('تم إضافة المحفظة بنجاح')),
                              );
                            }
                          } catch (e) {
                            if (!dialogContext.mounted) return;
                            setStateDialog(() => isLoading = false);
                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                              const SnackBar(
                                content: Text('فشل إضافة المحفظة'),
                                backgroundColor: AppColors.destructive,
                              ),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.primaryForeground,
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primaryForeground,
                          ),
                        )
                      : const Text('إضافة'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditWalletDialog(WalletEntity wallet) {
    final walletCubit = context.read<WalletCubit>();
    final nameController = TextEditingController(text: wallet.name);
    final phoneController = TextEditingController(text: wallet.phoneNumber ?? '');
    final dailyLimitController = TextEditingController(text: wallet.dailyLimit.toStringAsFixed(0));
    final monthlyLimitController = TextEditingController(text: wallet.monthlyLimit.toStringAsFixed(0));
    Color selectedColor = wallet.color;
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (_, setStateDialog) {
            return AlertDialog(
              backgroundColor: AppColors.card,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              title: Text(
                'تعديل المحفظة',
                style: AppTextStyles.headline.copyWith(color: AppColors.foreground),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: nameController,
                      textAlign: TextAlign.right,
                      enabled: !isLoading,
                      decoration: InputDecoration(
                        hintText: 'اسم المحفظة',
                        hintStyle: AppTextStyles.body.copyWith(color: AppColors.mutedForeground),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          borderSide: BorderSide(color: AppColors.border50),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.space3),
                    TextField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      textAlign: TextAlign.right,
                      enabled: !isLoading,
                      decoration: InputDecoration(
                        hintText: 'رقم الهاتف',
                        hintStyle: AppTextStyles.body.copyWith(color: AppColors.mutedForeground),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          borderSide: BorderSide(color: AppColors.border50),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.space3),
                    _LimitField(
                      controller: dailyLimitController,
                      label: 'الحد اليومي',
                      enabled: !isLoading,
                    ),
                    const SizedBox(height: AppSpacing.space3),
                    _LimitField(
                      controller: monthlyLimitController,
                      label: 'الحد الشهري',
                      enabled: !isLoading,
                    ),
                    const SizedBox(height: AppSpacing.space3),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.space3,
                        vertical: AppSpacing.space3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: Border.all(color: AppColors.border50),
                      ),
                      child: Row(
                        children: [
                          Text(
                            'الرصيد الحالي',
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.mutedForeground,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${NumberFormat("#,##0.##", "ar").format(wallet.balance)} ج.م',
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.space4),
                    Text(
                      'لون المحفظة',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.foreground,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.space2),
                    if (!isLoading)
                      WalletColorPicker(
                        selectedColor: selectedColor,
                        onColorSelected: (color) {
                          setStateDialog(() => selectedColor = color);
                        },
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isLoading ? null : () => Navigator.pop(dialogContext),
                  child: Text('إلغاء', style: AppTextStyles.body.copyWith(color: AppColors.mutedForeground)),
                ),
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          final name = nameController.text.trim();
                          if (name.isEmpty) {
                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                              const SnackBar(content: Text('اسم المحفظة مطلوب')),
                            );
                            return;
                          }
                          setStateDialog(() => isLoading = true);

                          final phone = phoneController.text.trim().isEmpty ? null : phoneController.text.trim();
                          final dailyLimit = dailyLimitController.text.trim().isEmpty
                              ? wallet.dailyLimit
                              : parseArabicNumerals(dailyLimitController.text.trim());
                          final monthlyLimit = monthlyLimitController.text.trim().isEmpty
                              ? wallet.monthlyLimit
                              : parseArabicNumerals(monthlyLimitController.text.trim());

                          final updated = WalletEntity(
                            id: wallet.id,
                            name: name,
                            phoneNumber: phone,
                            balance: wallet.balance,
                            color: selectedColor,
                            dailyLimit: dailyLimit,
                            weeklyLimit: wallet.weeklyLimit,
                            monthlyLimit: monthlyLimit,
                            createdAt: wallet.createdAt,
                          );

                          try {
                            await walletCubit.updateWallet(updated);
                            if (!dialogContext.mounted) return;
                            Navigator.pop(dialogContext);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('تم تحديث المحفظة بنجاح')),
                              );
                            }
                          } catch (e) {
                            if (!dialogContext.mounted) return;
                            setStateDialog(() => isLoading = false);
                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                              const SnackBar(
                                content: Text('فشل تحديث المحفظة'),
                                backgroundColor: AppColors.destructive,
                              ),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.primaryForeground,
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primaryForeground,
                          ),
                        )
                      : const Text('حفظ'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAddAdjustmentDialog(WalletEntity wallet) {
    final adjustmentCubit = context.read<WalletAdjustmentCubit>();
    final amountController = TextEditingController();
    final reasonController = TextEditingController();
    String selectedPeriod = 'daily';
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (_, setStateDialog) {
            return AlertDialog(
              backgroundColor: AppColors.card,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              title: Text(
                'تعديل استهلاك ${wallet.name}',
                style: AppTextStyles.headline.copyWith(color: AppColors.foreground),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'نوع الفترة',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.foreground,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.space2),
                    Row(
                      children: [
                        Expanded(
                          child: ChoiceChip(
                            label: const Text('يومي'),
                            selected: selectedPeriod == 'daily',
                            onSelected: isLoading ? null : (_) => setStateDialog(() => selectedPeriod = 'daily'),
                            selectedColor: AppColors.primary,
                            labelStyle: TextStyle(
                              color: selectedPeriod == 'daily'
                                  ? AppColors.primaryForeground
                                  : AppColors.foreground,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.space2),
                        Expanded(
                          child: ChoiceChip(
                            label: const Text('شهري'),
                            selected: selectedPeriod == 'monthly',
                            onSelected: isLoading ? null : (_) => setStateDialog(() => selectedPeriod = 'monthly'),
                            selectedColor: AppColors.primary,
                            labelStyle: TextStyle(
                              color: selectedPeriod == 'monthly'
                                  ? AppColors.primaryForeground
                                  : AppColors.foreground,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.space3),
                    TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.right,
                      enabled: !isLoading,
                      decoration: InputDecoration(
                        hintText: 'المبلغ المضاف للاستهلاك',
                        hintStyle: AppTextStyles.body.copyWith(color: AppColors.mutedForeground),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          borderSide: BorderSide(color: AppColors.border50),
                        ),
                        suffixText: 'ج.م',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.space3),
                    TextField(
                      controller: reasonController,
                      textAlign: TextAlign.right,
                      enabled: !isLoading,
                      decoration: InputDecoration(
                        hintText: 'السبب (اختياري)',
                        hintStyle: AppTextStyles.body.copyWith(color: AppColors.mutedForeground),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          borderSide: BorderSide(color: AppColors.border50),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isLoading ? null : () => Navigator.pop(dialogContext),
                  child: Text('إلغاء', style: AppTextStyles.body.copyWith(color: AppColors.mutedForeground)),
                ),
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          final amountText = amountController.text.trim();
                          if (amountText.isEmpty) {
                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                              const SnackBar(content: Text('المبلغ مطلوب')),
                            );
                            return;
                          }
                          setStateDialog(() => isLoading = true);

                          final amount = parseArabicNumerals(amountText);
                          final adjustment = WalletAdjustmentEntity(
                            id: 0,
                            walletId: wallet.id,
                            periodType: selectedPeriod,
                            amount: amount,
                            reason: reasonController.text.trim().isEmpty
                                ? null
                                : reasonController.text.trim(),
                            createdAt: DateTime.now(),
                          );

                          try {
                            await adjustmentCubit.addAdjustment(adjustment);
                            if (!dialogContext.mounted) return;
                            Navigator.pop(dialogContext);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('تم إضافة التعديل بنجاح')),
                              );
                            }
                          } catch (e) {
                            if (!dialogContext.mounted) return;
                            setStateDialog(() => isLoading = false);
                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                              const SnackBar(
                                content: Text('فشل إضافة التعديل'),
                                backgroundColor: AppColors.destructive,
                              ),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.primaryForeground,
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primaryForeground,
                          ),
                        )
                      : const Text('حفظ'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDeleteConfirmDialog(WalletEntity wallet) {
    final walletCubit = context.read<WalletCubit>();
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (_, setStateDialog) {
            return AlertDialog(
              backgroundColor: AppColors.card,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              title: Text(
                'حذف المحفظة',
                style: AppTextStyles.headline.copyWith(color: AppColors.destructive),
              ),
              content: Text(
                'هل أنت متأكد من حذف ${wallet.name}؟\nلا يمكن حذف محفظة تحتوي على عمليات.',
                style: AppTextStyles.body.copyWith(color: AppColors.foreground),
              ),
              actions: [
                TextButton(
                  onPressed: isLoading ? null : () => Navigator.pop(dialogContext),
                  child: Text('إلغاء', style: AppTextStyles.body.copyWith(color: AppColors.mutedForeground)),
                ),
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          setStateDialog(() => isLoading = true);
                          try {
                            await walletCubit.deleteWallet(wallet.id);
                            if (!dialogContext.mounted) return;
                            Navigator.pop(dialogContext);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('تم حذف المحفظة بنجاح')),
                              );
                            }
                          } catch (e) {
                            if (!dialogContext.mounted) return;
                            setStateDialog(() => isLoading = false);
                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                              const SnackBar(
                                content: Text('فشل حذف المحفظة'),
                                backgroundColor: AppColors.destructive,
                              ),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.destructive,
                    foregroundColor: AppColors.destructiveForeground,
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.destructiveForeground,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: SizedBox(height: AppSpacing.space4),
            ),
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
                        'إدارة المحافظ',
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
              child: SizedBox(height: AppSpacing.space6),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenHorizontal,
                ),
                child: ElevatedButton.icon(
                  onPressed: _showAddWalletDialog,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('إضافة محفظة جديدة'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.primaryForeground,
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.space4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(height: AppSpacing.space4),
            ),
            BlocBuilder<WalletCubit, WalletState>(
              builder: (context, state) {
                if (state is WalletLoading) {
                  return const SliverToBoxAdapter(
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (state is WalletError) {
                  return SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.space6),
                        child: Column(
                          children: [
                            Text(
                              state.message,
                              style: AppTextStyles.body.copyWith(color: AppColors.destructive),
                            ),
                            const SizedBox(height: AppSpacing.space4),
                            ElevatedButton(
                              onPressed: () {
                                context.read<WalletCubit>().getWallets();
                              },
                              child: const Text('إعادة المحاولة'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }
                final wallets = state is WalletLoaded ? state.wallets : <WalletEntity>[];
                if (wallets.isEmpty && state is WalletLoaded) {
                  return const SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(AppSpacing.space8),
                        child: Text(
                          'لا توجد محافظ بعد. اضغط على زر الإضافة.',
                          style: TextStyle(color: AppColors.mutedForeground),
                        ),
                      ),
                    ),
                  );
                }
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final wallet = wallets[index];
                      return _WalletListTile(
                        wallet: wallet,
                        onEdit: () => _showEditWalletDialog(wallet),
                        onAdjust: () => _showAddAdjustmentDialog(wallet),
                        onDelete: () => _showDeleteConfirmDialog(wallet),
                      );
                    },
                    childCount: wallets.length,
                  ),
                );
              },
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

class _WalletListTile extends StatelessWidget {
  final WalletEntity wallet;
  final VoidCallback onEdit;
  final VoidCallback onAdjust;
  final VoidCallback onDelete;

  const _WalletListTile({
    required this.wallet,
    required this.onEdit,
    required this.onAdjust,
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
              color: wallet.color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Icon(
              Icons.account_balance_wallet,
              color: wallet.color,
            ),
          ),
          const SizedBox(width: AppSpacing.space3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  wallet.name,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.foreground,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (wallet.phoneNumber != null && wallet.phoneNumber!.isNotEmpty)
                  Text(
                    wallet.phoneNumber!,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.mutedForeground,
                    ),
                  ),
                Text(
                  '${NumberFormat('#,##0.##', 'ar').format(wallet.balance)} ج.م',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onAdjust,
            icon: const Icon(Icons.tune_rounded, color: AppColors.mutedForeground, size: 20),
          ),
          IconButton(
            onPressed: onEdit,
            icon: const Icon(Icons.edit_rounded, color: AppColors.primary, size: 20),
          ),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_rounded, color: AppColors.destructive, size: 20),
          ),
        ],
      ),
    );
  }
}

class _LimitField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool enabled;

  const _LimitField({
    required this.controller,
    required this.label,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      textAlign: TextAlign.right,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTextStyles.body.copyWith(color: AppColors.mutedForeground),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: AppColors.border50),
        ),
        suffixText: 'ج.م',
      ),
    );
  }
}
