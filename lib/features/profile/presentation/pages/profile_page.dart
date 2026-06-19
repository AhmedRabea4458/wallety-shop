import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_expense/core/theme/app_colors.dart';
import 'package:smart_expense/core/theme/app_radius.dart';
import 'package:smart_expense/core/theme/app_spacing.dart';
import 'package:smart_expense/core/theme/app_text_styles.dart';
import 'package:smart_expense/features/home/presentation/widgets/section_header.dart';
import 'package:smart_expense/features/profile/domain/entities/profile_stats.dart';
import 'package:smart_expense/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:smart_expense/features/profile/presentation/cubit/profile_state.dart';
import 'package:smart_expense/features/profile/presentation/widgets/profile_card.dart';
import 'package:smart_expense/features/profile/presentation/widgets/outstanding_debt_card.dart';
import 'package:smart_expense/features/profile/presentation/widgets/provider_stats_card.dart';
import 'package:smart_expense/features/profile/presentation/widgets/profile_actions_section.dart';
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
            const SliverToBoxAdapter(
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
            const SliverToBoxAdapter(
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
                        StatItem(label: 'السحب', value: '...'),
                        StatItem(label: 'العمولات', value: '...'),
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
                          value: state.stats.totalDeposits.toStringAsFixed(0),
                        ),
                        StatItem(
                          label: 'السحب',
                          value: state.stats.totalWithdrawals.toStringAsFixed(0),
                        ),
                        StatItem(
                          label: 'العمولات',
                          value: state.stats.commission.toStringAsFixed(0),
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
                            StatItem(label: 'السحب', value: '-'),
                            StatItem(label: 'العمولات', value: '-'),
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
                                const Icon(
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
                      StatItem(label: 'السحب', value: '-'),
                      StatItem(label: 'العمولات', value: '-'),
                    ],
                  );
                },
              ),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: AppSpacing.space6),
            ),
            // Outstanding Debt Card
            const SliverToBoxAdapter(
              child: OutstandingDebtCard(),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: AppSpacing.space6),
            ),
            // Provider Analytics Section
            SliverToBoxAdapter(
              child: SectionHeader(
                title: 'تحليلات المزودين',
              ),
            ),
            const SliverToBoxAdapter(
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
                        ProviderStatsCard(
                          title: 'Vodafone Cash',
                          icon: Icons.account_balance_wallet_outlined,
                          color: AppColors.primary,
                          stats: vodafoneStats,
                        ),
                        const SizedBox(height: AppSpacing.space3),
                        ProviderStatsCard(
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
            const SliverToBoxAdapter(
              child: SizedBox(height: AppSpacing.space6),
            ),
            // Data Section
            SliverToBoxAdapter(
              child: SectionHeader(
                title: 'البيانات',
              ),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: AppSpacing.space4),
            ),
            const SliverToBoxAdapter(
              child: ProfileActionsSection(),
            ),
            // Bottom padding
            const SliverToBoxAdapter(
              child: SizedBox(height: AppSpacing.space8),
            ),
          ],
        ),
      ),
    );
  }
}
