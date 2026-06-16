import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_expense/core/theme/app_colors.dart';
import 'package:smart_expense/core/theme/app_radius.dart';
import 'package:smart_expense/core/theme/app_spacing.dart';
import 'package:smart_expense/core/theme/app_text_styles.dart';
import 'package:smart_expense/features/home/presentation/widgets/section_header.dart';
import 'package:smart_expense/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:smart_expense/features/profile/presentation/cubit/profile_state.dart';
import 'package:smart_expense/features/profile/presentation/widgets/budget_progress_section.dart';
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
                      'حسابي',
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
            // Profile Card
            SliverToBoxAdapter(
              child: BlocBuilder<ProfileCubit, ProfileState>(
                builder: (context, state) {
                    if (state is ProfileLoading) {
                      return const ProfileCard(
                        stats: [
                          StatItem(label: 'معاملة', value: '...'),
                          StatItem(label: 'هذا الشهر', value: '...'),
                          StatItem(label: 'معدل إدخار', value: '...'),
                        ],
                      );
                    } else if (state is ProfileLoaded) {
                      return ProfileCard(
                        stats: [
                          StatItem(
                            label: 'معاملة',
                            value: state.stats.totalTransactions.toString(),
                          ),
                          StatItem(
                            label: 'هذا الشهر',
                            value: state.stats.totalExpense.toStringAsFixed(0),
                          ),
                          StatItem(
                            label: 'معدل إدخار',
                            value: '${state.stats.savingsRate.toStringAsFixed(0)}%',
                          ),
                        ],
                      );
                    } else if (state is ProfileError) {
                      return Column(
                        children: [
                          const ProfileCard(
                            stats: [
                              StatItem(label: 'معاملة', value: '-'),
                              StatItem(label: 'هذا الشهر', value: '-'),
                              StatItem(label: 'معدل إدخار', value: '-'),
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
                        StatItem(label: 'معاملة', value: '-'),
                        StatItem(label: 'هذا الشهر', value: '-'),
                        StatItem(label: 'معدل إدخار', value: '-'),
                      ],
                    );
                  },
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(height: AppSpacing.space6),
              ),
              // Budget Section
              SliverToBoxAdapter(
                child: BlocBuilder<ProfileCubit, ProfileState>(
                  builder: (context, state) {
                    if (state is ProfileLoaded) {
                      if (state.budget > 0) {
                        final now = DateTime.now();
                        final lastDay = DateTime(now.year, now.month + 1, 0);
                        final daysLeft = lastDay.day - now.day;
                        final progress = state.monthlySpent / state.budget;

                        return BudgetProgressSection(
                          budgetLabel: 'الميزانية الشهرية',
                          spentLabel: 'المنفق من الميزانية',
                          budgetAmount: '${state.budget.toStringAsFixed(0)} ج.م',
                          spentAmount: '${state.monthlySpent.toStringAsFixed(0)} ج.م',
                          progress: progress.clamp(0.0, 1.0),
                          daysLeft: '$daysLeft أيام متبقية',
                        );
                      } else {
                        return Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.screenHorizontal,
                          ),
                          padding: const EdgeInsets.all(AppSpacing.space6),
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
                                'الميزانية الشهرية',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.mutedForeground,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.space3),
                              Text(
                                'لم يتم تحديد ميزانية بعد',
                                style: AppTextStyles.bodyLarge.copyWith(
                                  color: AppColors.foreground,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.space4),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () => _showBudgetDialog(context),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: AppColors.primaryForeground,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(AppRadius.md),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: AppSpacing.space3,
                                    ),
                                  ),
                                  child: Text(
                                    'تعديل الميزانية',
                                    style: AppTextStyles.body.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(height: AppSpacing.space6),
              ),
              // Data Section
              SliverToBoxAdapter(
                child: SectionHeader(
                  title: 'الحساب والبيانات',
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

  void _showBudgetDialog(BuildContext context) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          title: Text(
            'تحديد الميزانية',
            style: AppTextStyles.headline.copyWith(
              color: AppColors.foreground,
            ),
          ),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.right,
            decoration: InputDecoration(
              hintText: 'أدخل الميزانية الشهرية',
              hintStyle: AppTextStyles.body.copyWith(
                color: AppColors.mutedForeground,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
                borderSide: BorderSide(color: AppColors.border50),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
                borderSide: BorderSide(color: AppColors.border50),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
                borderSide: BorderSide(color: AppColors.primary),
              ),
            ),
            style: AppTextStyles.body.copyWith(
              color: AppColors.foreground,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                'إلغاء',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.mutedForeground,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final amount = double.tryParse(controller.text) ?? 0;
                if (amount > 0) {
                  context.read<ProfileCubit>().setBudget(amount);
                  Navigator.of(dialogContext).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('تم تحديد الميزانية بنجاح'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.primaryForeground,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
              ),
              child: Text(
                'حفظ',
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
                  'Version 1.0 MVP',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.mutedForeground,
                  ),
                ),
                const SizedBox(height: AppSpacing.space4),
                Text(
                  'A personal expense tracking app built with:',
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
