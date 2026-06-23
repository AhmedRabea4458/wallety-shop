import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_expense/core/theme/app_colors.dart';
import 'package:smart_expense/core/theme/app_radius.dart';
import 'package:smart_expense/core/theme/app_spacing.dart';
import 'package:smart_expense/core/theme/app_text_styles.dart';
import 'package:smart_expense/core/utils/arabic_numerals.dart';
import 'package:smart_expense/features/operations/domain/entities/wallet_entity.dart';
import 'package:smart_expense/features/operations/presentation/cubit/wallet_cubit.dart';
import 'package:smart_expense/features/operations/presentation/cubit/wallet_state.dart';

class WalletSetupPage extends StatefulWidget {
  const WalletSetupPage({super.key});

  @override
  State<WalletSetupPage> createState() => _WalletSetupPageState();
}

class _WalletSetupPageState extends State<WalletSetupPage> {
  final Map<int, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    context.read<WalletCubit>().getWallets();
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _save() {
    final walletCubit = context.read<WalletCubit>();
    final state = walletCubit.state;
    if (state is! WalletLoaded) return;

    for (final wallet in state.wallets) {
      final controller = _controllers[wallet.id];
      if (controller == null) continue;

      final text = controller.text.trim();
      if (text.isEmpty) continue;

      final balance = parseArabicNumerals(text);
      if (balance < 0) {
        _showError('رصيد ${wallet.name} غير صحيح');
        return;
      }

      // Use repository directly to update balance
      walletCubit.repository.updateWalletBalance(wallet.id, balance);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم تحديث الأرصدة بنجاح'),
        duration: Duration(seconds: 2),
      ),
    );

    // Refresh wallets
    walletCubit.refreshWallets();

    if (mounted) {
      context.pop();
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.destructive,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocBuilder<WalletCubit, WalletState>(
          builder: (context, state) {
            if (state is WalletLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is WalletError) {
              return Center(
                child: Text(
                  'فشل تحميل المحافظ',
                  style: AppTextStyles.body.copyWith(color: AppColors.destructive),
                ),
              );
            }

            final wallets = state is WalletLoaded ? state.wallets : <WalletEntity>[];

            // Initialize controllers for new wallets
            for (final wallet in wallets) {
              if (!_controllers.containsKey(wallet.id)) {
                _controllers[wallet.id] = TextEditingController(
                  text: wallet.balance > 0 ? wallet.balance.toStringAsFixed(0) : '',
                );
              }
            }

            return CustomScrollView(
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
                            'ضبط الأرصدة',
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
                // Description
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.screenHorizontal,
                    ),
                    child: Text(
                      'أدخل الرصيد الحالي لكل محفظة في المحل',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.mutedForeground,
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(height: AppSpacing.space6),
                ),
                // Empty state
                if (wallets.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.space8),
                      child: Center(
                        child: Column(
                          children: [
                            Text(
                              'لا توجد محافظ لضبطها',
                              style: AppTextStyles.body.copyWith(color: AppColors.mutedForeground),
                            ),
                            const SizedBox(height: AppSpacing.space4),
                            Text(
                              'قم بإنشاء محفظة من صفحة إدارة المحافظ',
                              style: AppTextStyles.caption.copyWith(color: AppColors.mutedForeground),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                // Wallet inputs
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final wallet = wallets[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.screenHorizontal,
                          vertical: AppSpacing.space2,
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(AppSpacing.space5),
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
                                wallet.name,
                                style: AppTextStyles.bodyLarge.copyWith(
                                  color: AppColors.foreground,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.space3),
                              TextField(
                                controller: _controllers[wallet.id],
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.right,
                                style: AppTextStyles.hero.copyWith(
                                  color: AppColors.foreground,
                                  fontSize: 36,
                                ),
                                decoration: InputDecoration(
                                  hintText: '0',
                                  hintStyle: AppTextStyles.hero.copyWith(
                                    color: AppColors.mutedForeground,
                                    fontSize: 36,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.zero,
                                  isDense: true,
                                  suffixText: 'ج.م',
                                  suffixStyle: AppTextStyles.bodyLarge.copyWith(
                                    color: AppColors.mutedForeground,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    childCount: wallets.length,
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
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.primaryForeground,
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.space4,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.xl),
                          ),
                        ),
                        child: Text(
                          'حفظ الأرصدة',
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
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
