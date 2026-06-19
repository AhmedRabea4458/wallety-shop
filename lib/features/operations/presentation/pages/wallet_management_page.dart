import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:smart_expense/core/theme/app_colors.dart';
import 'package:smart_expense/core/theme/app_radius.dart';
import 'package:smart_expense/core/theme/app_spacing.dart';
import 'package:smart_expense/core/theme/app_text_styles.dart';
import 'package:smart_expense/features/operations/domain/entities/wallet_entity.dart';
import 'package:smart_expense/features/operations/presentation/cubit/wallet_adjustment_cubit.dart';
import 'package:smart_expense/features/operations/presentation/cubit/wallet_cubit.dart';
import 'package:smart_expense/features/operations/presentation/cubit/wallet_state.dart';
import 'package:smart_expense/features/operations/presentation/widgets/dialogs/add_wallet_dialog.dart';
import 'package:smart_expense/features/operations/presentation/widgets/dialogs/edit_wallet_dialog.dart';
import 'package:smart_expense/features/operations/presentation/widgets/dialogs/add_adjustment_dialog.dart';
import 'package:smart_expense/features/operations/presentation/widgets/dialogs/delete_wallet_dialog.dart';

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

  void _showDeleteConfirmDialog(WalletEntity wallet) {
    showDeleteWalletDialog(
      parentContext: context,
      walletCubit: context.read<WalletCubit>(),
      wallet: wallet,
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
