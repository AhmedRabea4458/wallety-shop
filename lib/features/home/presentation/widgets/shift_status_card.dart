import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smart_expense/core/theme/app_colors.dart';
import 'package:smart_expense/core/theme/app_radius.dart';
import 'package:smart_expense/core/theme/app_spacing.dart';
import 'package:smart_expense/core/theme/app_text_styles.dart';
import 'package:smart_expense/features/operations/presentation/cubit/active_shift_cubit.dart';
import 'package:smart_expense/features/operations/presentation/cubit/active_shift_state.dart';
import 'package:smart_expense/features/operations/presentation/cubit/cash_drawer_cubit.dart';
import 'package:smart_expense/features/operations/presentation/cubit/cash_drawer_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Displays the current shift status (active, loading, error, or no shift).
///
/// Provides open/close shift actions inline.
class ShiftStatusCard extends StatelessWidget {
  const ShiftStatusCard({super.key});

  static String _formatAmount(double amount) {
    return NumberFormat('#,##0.##', 'ar').format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ActiveShiftCubit, ActiveShiftState>(
      builder: (context, state) {
        return _buildContent(context, state);
      },
    );
  }

  Widget _buildContent(BuildContext context, ActiveShiftState state) {
    if (state is ActiveShiftLoading) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.space4),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.border50),
        ),
        child: const Row(
          children: [
            SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
            SizedBox(width: AppSpacing.space3),
            Text('جاري تحميل الوردية...', style: TextStyle(color: AppColors.mutedForeground)),
          ],
        ),
      );
    }
    if (state is ActiveShiftError) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.space4),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.destructive.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline_rounded, color: AppColors.destructive, size: 20),
            const SizedBox(width: AppSpacing.space2),
            Expanded(
              child: Text(state.message, style: AppTextStyles.body.copyWith(color: AppColors.destructive)),
            ),
            TextButton(
              onPressed: () => context.read<ActiveShiftCubit>().loadActiveShift(),
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    }
    if (state is ActiveShiftLoaded) {
      final shift = state.shift;
      final startedAt = DateFormat('hh:mm a', 'ar').format(shift.startTime);
      return Container(
        padding: const EdgeInsets.all(AppSpacing.space4),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: AppColors.success, shape: BoxShape.circle),
            ),
            const SizedBox(width: AppSpacing.space2),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('الوردية نشطة منذ $startedAt',
                      style: AppTextStyles.caption.copyWith(color: AppColors.foreground, fontWeight: FontWeight.w600)),
                  Text('رصيد البداية: ${_formatAmount(shift.openingCashDrawer)} ج.م',
                      style: AppTextStyles.caption.copyWith(color: AppColors.mutedForeground)),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text('إغلاق الوردية', style: AppTextStyles.headline.copyWith(color: AppColors.foreground)),
                    content: Text('هل أنت متأكد من إغلاق الوردية الحالية؟'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
                      ElevatedButton(
                        onPressed: () {
                          final drawCubit = context.read<CashDrawerCubit>();
                          final drawerBalance = drawCubit.state is CashDrawerLoaded
                              ? (drawCubit.state as CashDrawerLoaded).cashDrawer.balance
                              : 0.0;
                              context.read<ActiveShiftCubit>().closeShift(shift.id, drawerBalance);
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('تم إغلاق الوردية بنجاح')),
                              );
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.destructive),
                        child: const Text('إغلاق'),
                      ),
                    ],
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.withAlpha(AppColors.destructive, 0.1),
                foregroundColor: AppColors.destructive,
              ),
              child: const Text('إغلاق'),
            ),
          ],
        ),
      );
    }
    // No active shift
    return Container(
      padding: const EdgeInsets.all(AppSpacing.space4),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: AppColors.warning, shape: BoxShape.circle),
          ),
          const SizedBox(width: AppSpacing.space2),
          const Expanded(
            child: Text('لا توجد وردية نشطة',
                style: TextStyle(color: AppColors.mutedForeground)),
          ),
          ElevatedButton(
            onPressed: () {
              final drawCubit = context.read<CashDrawerCubit>();
              final drawerBalance = drawCubit.state is CashDrawerLoaded
                  ? (drawCubit.state as CashDrawerLoaded).cashDrawer.balance
                  : 0.0;
              context.read<ActiveShiftCubit>().openShift(drawerBalance);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم فتح الوردية بنجاح')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('فتح وردية'),
          ),
        ],
      ),
    );
  }
}
