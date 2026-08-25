import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:smart_expense/core/theme/app_colors.dart';
import 'package:smart_expense/core/theme/app_radius.dart';
import 'package:smart_expense/core/theme/app_spacing.dart';
import 'package:smart_expense/core/theme/app_text_styles.dart';
import 'package:smart_expense/features/operations/domain/entities/wallet_entity.dart';
import 'package:smart_expense/features/operations/presentation/cubit/cash_drawer_cubit.dart';
import 'package:smart_expense/features/operations/presentation/cubit/cash_drawer_state.dart';
import 'package:smart_expense/features/operations/presentation/widgets/cash_drawer_card.dart';
import 'package:smart_expense/features/operations/presentation/cubit/wallet_adjustment_cubit.dart';
import 'package:smart_expense/features/operations/presentation/cubit/wallet_cubit.dart';
import 'package:smart_expense/features/operations/presentation/cubit/wallet_state.dart';
import 'package:smart_expense/features/operations/presentation/widgets/dialogs/add_wallet_dialog.dart';
import 'package:smart_expense/features/operations/presentation/widgets/dialogs/edit_wallet_dialog.dart';
import 'package:smart_expense/features/operations/presentation/widgets/dialogs/add_adjustment_dialog.dart';
import 'package:smart_expense/features/operations/presentation/widgets/dialogs/delete_wallet_dialog.dart';
import 'package:smart_expense/features/operations/presentation/widgets/dialogs/archive_wallet_dialog.dart';

class WalletManagementPage extends StatefulWidget {
  const WalletManagementPage({super.key});

  @override
  State<WalletManagementPage> createState() => _WalletManagementPageState();
}

class _WalletManagementPageState extends State<WalletManagementPage> {
  int _selectedTab = 0; // 0 = نشطة, 1 = مؤرشفة

  @override
  void initState() {
    super.initState();
    context.read<WalletCubit>().getWallets();
    context.read<WalletAdjustmentCubit>().loadAllAdjustments();
    context.read<CashDrawerCubit>().getCashDrawer();
  }

  void _showAddWalletDialog() {
    showAddWalletDialog(
      parentContext: context,
      walletCubit: context.read<WalletCubit>(),
    );
  }

  void _showEditWalletDialog(WalletEntity wallet) {
    showEditWalletDialog(
      parentContext: context,
      walletCubit: context.read<WalletCubit>(),
      wallet: wallet,
    );
  }

  void _showAddAdjustmentDialog(WalletEntity wallet) {
    showAddAdjustmentDialog(
      parentContext: context,
      adjustmentCubit: context.read<WalletAdjustmentCubit>(),
      wallet: wallet,
    );
  }

  Future<void> _handleWalletAction(WalletEntity wallet) async {
    final walletCubit = context.read<WalletCubit>();
    try {
      final hasOps = await walletCubit.repository.walletHasOperations(wallet.id);
      if (!mounted) return;
      if (hasOps) {
        showArchiveWalletDialog(
          parentContext: context,
          walletCubit: walletCubit,
          wallet: wallet,
        );
      } else {
        showDeleteWalletDialog(
          parentContext: context,
          walletCubit: walletCubit,
          wallet: wallet,
        );
      }
    } catch (e) {
      if (!mounted) return;
      showArchiveWalletDialog(
        parentContext: context,
        walletCubit: walletCubit,
        wallet: wallet,
      );
    }
  }

  void _showRestoreWalletDialog(WalletEntity wallet) {
    final walletCubit = context.read<WalletCubit>();
    showDialog(
      context: context,
      builder: (dialogContext) {
        bool isLoading = false;
        return StatefulBuilder(
          builder: (_, setStateDialog) {
            return AlertDialog(
              backgroundColor: AppColors.card,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              title: Text(
                'استعادة المحفظة',
                style: AppTextStyles.headline.copyWith(
                  color: AppColors.foreground,
                ),
              ),
              content: Text(
                'هل تريد استعادة محفظة "${wallet.name}" لتصبح نشطة ومتاحة في العمليات الجديدة مجدداً؟',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.foreground,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isLoading ? null : () => Navigator.pop(dialogContext),
                  child: Text(
                    'إلغاء',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.mutedForeground,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          setStateDialog(() => isLoading = true);
                          try {
                            await walletCubit.unarchiveWallet(wallet.id);
                            if (!dialogContext.mounted) return;
                            Navigator.pop(dialogContext);
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('تمت استعادة المحفظة بنجاح'),
                                ),
                              );
                            }
                          } catch (e) {
                            if (!dialogContext.mounted) return;
                            setStateDialog(() => isLoading = false);
                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                              const SnackBar(
                                content: Text('فشل استعادة المحفظة'),
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
                      : const Text('استعادة'),
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
              child: SizedBox(height: AppSpacing.space4),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenHorizontal,
                ),
                child: BlocBuilder<CashDrawerCubit, CashDrawerState>(
                  builder: (context, cashState) {
                    final cashDrawer = cashState is CashDrawerLoaded
                        ? cashState.cashDrawer
                        : null;
                    return CashDrawerCard(
                      balance: cashDrawer?.balance ?? 0.0,
                      initialBalance: cashDrawer?.initialBalance ?? 0.0,
                      updatedAt: cashDrawer?.updatedAt,
                    );
                  },
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
            // Tabs: Active vs Archived
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenHorizontal,
                ),
                child: BlocBuilder<WalletCubit, WalletState>(
                  builder: (context, state) {
                    final activeCount = state is WalletLoaded ? state.activeWallets.length : 0;
                    final archivedCount = state is WalletLoaded ? state.archivedWallets.length : 0;

                    return Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        border: Border.all(color: AppColors.border50),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () => setState(() => _selectedTab = 0),
                              borderRadius: BorderRadius.circular(AppRadius.md),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: _selectedTab == 0 ? AppColors.primary : Colors.transparent,
                                  borderRadius: BorderRadius.circular(AppRadius.md),
                                ),
                                child: Center(
                                  child: Text(
                                    'النشطة ($activeCount)',
                                    style: AppTextStyles.body.copyWith(
                                      color: _selectedTab == 0
                                          ? AppColors.primaryForeground
                                          : AppColors.mutedForeground,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: InkWell(
                              onTap: () => setState(() => _selectedTab = 1),
                              borderRadius: BorderRadius.circular(AppRadius.md),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: _selectedTab == 1 ? AppColors.primary : Colors.transparent,
                                  borderRadius: BorderRadius.circular(AppRadius.md),
                                ),
                                child: Center(
                                  child: Text(
                                    'المؤرشفة ($archivedCount)',
                                    style: AppTextStyles.body.copyWith(
                                      color: _selectedTab == 1
                                          ? AppColors.primaryForeground
                                          : AppColors.mutedForeground,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
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

                final wallets = state is WalletLoaded
                    ? (_selectedTab == 0 ? state.activeWallets : state.archivedWallets)
                    : <WalletEntity>[];

                if (wallets.isEmpty && state is WalletLoaded) {
                  return SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.space8),
                        child: Text(
                          _selectedTab == 0
                              ? 'لا توجد محافظ نشطة بعد.'
                              : 'لا توجد محافظ مؤرشفة.',
                          style: const TextStyle(color: AppColors.mutedForeground),
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
                        isArchived: _selectedTab == 1,
                        onEdit: () => _showEditWalletDialog(wallet),
                        onAdjust: () => _showAddAdjustmentDialog(wallet),
                        onAction: () => _handleWalletAction(wallet),
                        onRestore: () => _showRestoreWalletDialog(wallet),
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
  final bool isArchived;
  final VoidCallback onEdit;
  final VoidCallback onAdjust;
  final VoidCallback onAction;
  final VoidCallback onRestore;

  const _WalletListTile({
    required this.wallet,
    required this.isArchived,
    required this.onEdit,
    required this.onAdjust,
    required this.onAction,
    required this.onRestore,
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
        color: isArchived ? AppColors.card.withValues(alpha: 0.6) : AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: isArchived ? AppColors.border50.withValues(alpha: 0.5) : AppColors.border50,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: (isArchived ? AppColors.mutedForeground : wallet.color).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Icon(
              Icons.account_balance_wallet,
              color: isArchived ? AppColors.mutedForeground : wallet.color,
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
                        wallet.name,
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: isArchived ? AppColors.mutedForeground : AppColors.foreground,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (isArchived) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.mutedForeground.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        child: Text(
                          'مؤرشفة',
                          style: AppTextStyles.caption.copyWith(
                            fontSize: 10,
                            color: AppColors.mutedForeground,
                          ),
                        ),
                      ),
                    ],
                  ],
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
                    color: isArchived ? AppColors.mutedForeground : AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (!isArchived) ...[
            IconButton(
              onPressed: onAdjust,
              icon: const Icon(Icons.tune_rounded, color: AppColors.mutedForeground, size: 20),
              tooltip: 'تسوية',
            ),
            IconButton(
              onPressed: onEdit,
              icon: const Icon(Icons.edit_rounded, color: AppColors.primary, size: 20),
              tooltip: 'تعديل',
            ),
            IconButton(
              onPressed: onAction,
              icon: const Icon(Icons.delete_outline_rounded, color: AppColors.destructive, size: 20),
              tooltip: 'حذف أو أرشفة',
            ),
          ] else ...[
            TextButton.icon(
              onPressed: onRestore,
              icon: const Icon(Icons.unarchive_rounded, size: 18),
              label: const Text('استعادة'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

