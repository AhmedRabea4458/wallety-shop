import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:smart_expense/core/constants/app_routes.dart';
import 'package:smart_expense/core/theme/app_colors.dart';
import 'package:smart_expense/core/theme/app_radius.dart';
import 'package:smart_expense/core/theme/app_spacing.dart';
import 'package:smart_expense/core/theme/app_text_styles.dart';
import 'package:smart_expense/features/home/presentation/widgets/section_header.dart';
import 'package:smart_expense/features/profile/domain/entities/profile_stats.dart';
import 'package:smart_expense/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:smart_expense/features/profile/presentation/cubit/profile_state.dart';
import 'package:smart_expense/features/profile/presentation/widgets/profile_card.dart';
import 'package:smart_expense/shared/widgets/action_row.dart';
import 'package:smart_expense/shared/widgets/stats_row.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Top spacing
            SliverToBoxAdapter(
              child: SizedBox(height: AppSpacing.space6),
            ),
            // Page header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenHorizontal,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'التقارير',
                      style: AppTextStyles.display.copyWith(
                        color: AppColors.foreground,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(height: AppSpacing.space6),
            ),
            // Stats Card
            SliverToBoxAdapter(
              child: BlocBuilder<ProfileCubit, ProfileState>(
                builder: (context, state) {
                  if (state is ProfileLoading) {
                    return const ProfileCard(
                      stats: [
                        StatItem(label: 'العمليات', value: '...'),
                        StatItem(label: 'الإيداع', value: '...'),
                        StatItem(label: 'العمولات', value: '...'),
                        StatItem(label: 'رسوم الشبكة', value: '...'),
                      ],
                    );
                  } else if (state is ProfileLoaded) {
                    return ProfileCard(
                      stats: [
                        StatItem(
                          label: 'العمليات',
                          value: state.stats.totalTransactions.toString(),
                        ),
                        StatItem(
                          label: 'الإيداع',
                          value: state.stats.totalExpense.toStringAsFixed(0),
                        ),
                        StatItem(
                          label: 'العمولات',
                          value: state.stats.commission.toStringAsFixed(0),
                        ),
                        StatItem(
                          label: 'رسوم الشبكة',
                          value: state.stats.networkFee.toStringAsFixed(0),
                        ),
                      ],
                    );
                  } else if (state is ProfileError) {
                    return Column(
                      children: [
                        const ProfileCard(
                          stats: [
                            StatItem(label: 'العمليات', value: '-'),
                            StatItem(label: 'الإيداع', value: '-'),
                            StatItem(label: 'العمولات', value: '-'),
                            StatItem(label: 'رسوم الشبكة', value: '-'),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.space4),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.screenHorizontal,
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(AppSpacing.space4),
                            decoration: BoxDecoration(
                              color: AppColors.withAlpha(
                                AppColors.destructive,
                                0.1,
                              ),
                              borderRadius: BorderRadius.circular(AppRadius.md),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color: AppColors.destructive,
                                  size: 20,
                                ),
                                const SizedBox(width: AppSpacing.space3),
                                Expanded(
                                  child: Text(
                                    'حدث خطأ أثناء تحميل البيانات: ${state.message}',
                                    style: AppTextStyles.body.copyWith(
                                      color: AppColors.destructive,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  }
                  return const ProfileCard(
                    stats: [
                      StatItem(label: 'العمليات', value: '-'),
                      StatItem(label: 'الإيداع', value: '-'),
                      StatItem(label: 'العمولات', value: '-'),
                      StatItem(label: 'رسوم الشبكة', value: '-'),
                    ],
                  );
                },
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(height: AppSpacing.space6),
            ),
            // Provider Analytics Section
            SliverToBoxAdapter(
              child: SectionHeader(
                title: 'تحليلات المزودين',
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(height: AppSpacing.space4),
            ),
            SliverToBoxAdapter(
              child: BlocBuilder<ProfileCubit, ProfileState>(
                builder: (context, state) {
                  final vodafoneStats = state is ProfileLoaded ? state.stats.vodafoneCash : const ProviderStats.empty();
                  final instaPayStats = state is ProfileLoaded ? state.stats.instaPay : const ProviderStats.empty();
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.screenHorizontal,
                    ),
                    child: Column(
                      children: [
                        _ProviderStatsCard(
                          title: 'Vodafone Cash',
                          icon: Icons.account_balance_wallet_outlined,
                          color: AppColors.primary,
                          stats: vodafoneStats,
                        ),
                        const SizedBox(height: AppSpacing.space3),
                        _ProviderStatsCard(
                          title: 'InstaPay',
                          icon: Icons.point_of_sale_outlined,
                          color: const Color(0xFFF59E0B),
                          stats: instaPayStats,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(height: AppSpacing.space6),
            ),
            // Data Section
            SliverToBoxAdapter(
              child: SectionHeader(
                title: 'البيانات',
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(height: AppSpacing.space4),
            ),
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenHorizontal,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.space5,
                  vertical: AppSpacing.space3,
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
                  children: [
                    ActionRow(
                      icon: Icons.download_rounded,
                      iconBackgroundColor: AppColors.primary10,
                      iconColor: AppColors.primary,
                      label: 'تصدير البيانات CSV',
                      onTap: () async {
                        final cubit = context.read<ProfileCubit>();
                        final scaffoldMessenger = ScaffoldMessenger.of(context);
                        try {
                          await cubit.exportToCsv();
                          scaffoldMessenger.showSnackBar(
                            const SnackBar(
                              content: Text('تم تصدير البيانات بنجاح'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        } catch (e) {
                          scaffoldMessenger.showSnackBar(
                            SnackBar(
                              content: Text('حدث خطأ أثناء التصدير: $e'),
                              backgroundColor: AppColors.destructive,
                              duration: const Duration(seconds: 3),
                            ),
                          );
                        }
                      },
                    ),
                    Divider(
                      color: AppColors.border45,
                      indent: AppSpacing.space5,
                      endIndent: AppSpacing.space5,
                    ),
                    ActionRow(
                      icon: Icons.wallet_outlined,
                      iconBackgroundColor: AppColors.primary10,
                      iconColor: AppColors.primary,
                      label: 'إدارة المحافظ',
                      onTap: () => context.push(AppRoutes.walletManagement),
                    ),
                    Divider(
                      color: AppColors.border45,
                      indent: AppSpacing.space5,
                      endIndent: AppSpacing.space5,
                    ),
                    ActionRow(
                      icon: Icons.account_balance_wallet_outlined,
                      iconBackgroundColor: AppColors.primary10,
                      iconColor: AppColors.primary,
                      label: 'ضبط أرصدة المحافظ',
                      onTap: () => context.push(AppRoutes.walletSetup),
                    ),
                    Divider(
                      color: AppColors.border45,
                      indent: AppSpacing.space5,
                      endIndent: AppSpacing.space5,
                    ),
                    ActionRow(
                      icon: Icons.info_outline_rounded,
                      iconBackgroundColor: AppColors.primary10,
                      iconColor: AppColors.primary,
                      label: 'عن التطبيق',
                      onTap: () => _showAboutDialog(context),
                    ),
                  ],
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
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          title: Text(
            'Wallety',
            style: AppTextStyles.headline.copyWith(
              color: AppColors.foreground,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Version 1.0 Shop',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.mutedForeground,
                  ),
                ),
                const SizedBox(height: AppSpacing.space4),
                Text(
                  'A Vodafone Cash shop management app built with:',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.foreground,
                  ),
                ),
                const SizedBox(height: AppSpacing.space3),
                Text(
                  '• Flutter\n• Drift\n• flutter_bloc\n• GetIt\n• GoRouter\n• Clean Architecture',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.foreground,
                  ),
                ),
                const SizedBox(height: AppSpacing.space4),
                Text(
                  'Wallety Team',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.foreground,
                  ),
                ),
                const SizedBox(height: AppSpacing.space1),
                Text(
                  '© 2026',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.primaryForeground,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
              ),
              child: Text(
                'حسنًا',
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ProviderStatsCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final ProviderStats stats;

  const _ProviderStatsCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.stats,
  });

  static String _format(double amount) {
    return NumberFormat('#,##0.##', 'ar').format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.space4),
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
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 18,
                ),
              ),
              const SizedBox(width: AppSpacing.space3),
              Text(
                title,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.foreground,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.space4),
          _StatRow(label: 'عدد العمليات', value: stats.operationCount.toString()),
          const SizedBox(height: AppSpacing.space2),
          _StatRow(label: 'إجمالي المبالغ', value: '${_format(stats.totalAmount)} ج.م'),
          const SizedBox(height: AppSpacing.space2),
          _StatRow(label: 'إجمالي العمولات', value: '${_format(stats.totalCommission)} ج.م'),
          const SizedBox(height: AppSpacing.space2),
          _StatRow(label: 'رسوم الشبكة', value: '${_format(stats.totalNetworkFee)} ج.م'),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;

  const _StatRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.body.copyWith(
            color: AppColors.mutedForeground,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.body.copyWith(
            color: AppColors.foreground,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
