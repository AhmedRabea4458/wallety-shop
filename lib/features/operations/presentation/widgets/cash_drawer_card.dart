import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:smart_expense/core/theme/app_colors.dart';
import 'package:smart_expense/core/theme/app_radius.dart';
import 'package:smart_expense/core/theme/app_spacing.dart';
import 'package:smart_expense/core/theme/app_text_styles.dart';
import 'package:smart_expense/core/utils/arabic_numerals.dart';
import 'package:smart_expense/features/operations/presentation/cubit/cash_drawer_cubit.dart';

class CashDrawerCard extends StatelessWidget {
  final double balance;
  final double initialBalance;
  final DateTime? updatedAt;

  const CashDrawerCard({
    super.key,
    required this.balance,
    required this.initialBalance,
    this.updatedAt,
  });

  static String _formatAmount(double amount) {
    return NumberFormat('#,##0.##', 'ar').format(amount);
  }

  @override
  Widget build(BuildContext context) {
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
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: const Icon(
              Icons.point_of_sale_rounded,
              color: Color(0xFFF59E0B),
              size: 22,
            ),
          ),
          const SizedBox(width: AppSpacing.space4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'الدرج النقدي',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.mutedForeground,
                  ),
                ),
                const SizedBox(height: AppSpacing.space1),
                Text(
                  '${_formatAmount(balance)} ج.م',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.foreground,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _showEditInitialBalanceDialog(context),
            icon: const Icon(
              Icons.edit_rounded,
              color: AppColors.mutedForeground,
              size: 18,
            ),
            tooltip: 'تعديل الرصيد الافتتاحي',
          ),
        ],
      ),
    );
  }

  void _showEditInitialBalanceDialog(BuildContext context) {
    final controller = TextEditingController(
      text: initialBalance > 0 ? initialBalance.toStringAsFixed(0) : '',
    );

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          title: Text(
            'الرصيد الافتتاحي للدرج النقدي',
            style: AppTextStyles.headline.copyWith(color: AppColors.foreground),
          ),
          content: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textAlign: TextAlign.right,
            decoration: InputDecoration(
              hintText: '0',
              hintStyle: AppTextStyles.body.copyWith(color: AppColors.mutedForeground),
              suffixText: 'ج.م',
              suffixStyle: AppTextStyles.body.copyWith(color: AppColors.mutedForeground),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
                borderSide: BorderSide(color: AppColors.border50),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('إلغاء', style: AppTextStyles.body.copyWith(color: AppColors.mutedForeground)),
            ),
            ElevatedButton(
              onPressed: () {
                final text = controller.text.trim();
                final value = text.isEmpty ? 0.0 : parseArabicNumerals(text);
                if (value < 0) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(content: Text('لا يمكن أن يكون الرصيد الافتتاحي سالباً')),
                  );
                  return;
                }
                context.read<CashDrawerCubit>().updateInitialBalance(value);
                Navigator.pop(dialogContext);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.primaryForeground,
              ),
              child: const Text('حفظ'),
            ),
          ],
        );
      },
    );
  }
}
