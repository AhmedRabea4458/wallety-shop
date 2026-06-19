import 'package:flutter/material.dart';
import 'package:smart_expense/core/theme/app_colors.dart';
import 'package:smart_expense/core/theme/app_radius.dart';
import 'package:smart_expense/core/theme/app_spacing.dart';
import 'package:smart_expense/core/theme/app_text_styles.dart';

/// The debt section shown in the Add Operation form when the operation
/// type is deposit. Includes a toggle switch and customer info fields.
class DebtSection extends StatelessWidget {
  final bool isDebt;
  final bool isSaving;
  final ValueChanged<bool> onDebtChanged;
  final TextEditingController customerNameController;
  final TextEditingController customerPhoneController;

  const DebtSection({
    super.key,
    required this.isDebt,
    required this.isSaving,
    required this.onDebtChanged,
    required this.customerNameController,
    required this.customerPhoneController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.space4),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border50),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SwitchListTile(
            title: Text('تسجيل كآجل',
                style: AppTextStyles.body.copyWith(color: AppColors.foreground)),
            subtitle: Text('عند التفعيل سيتم تسجيل دين للعميل',
                style: AppTextStyles.caption.copyWith(color: AppColors.mutedForeground)),
            value: isDebt,
            onChanged: isSaving ? null : onDebtChanged,
            contentPadding: EdgeInsets.zero,
            activeTrackColor: AppColors.primary,
          ),
          if (isDebt) ...[
            TextField(
              controller: customerNameController,
              textAlign: TextAlign.right,
              decoration: const InputDecoration(
                hintText: 'اسم العميل',
                border: OutlineInputBorder(),
              ),
              style: AppTextStyles.body.copyWith(color: AppColors.foreground),
            ),
            const SizedBox(height: AppSpacing.space2),
            TextField(
              controller: customerPhoneController,
              keyboardType: TextInputType.phone,
              textAlign: TextAlign.right,
              decoration: const InputDecoration(
                hintText: 'رقم هاتف العميل (اختياري)',
                border: OutlineInputBorder(),
              ),
              style: AppTextStyles.body.copyWith(color: AppColors.foreground),
            ),
          ],
        ],
      ),
    );
  }
}
