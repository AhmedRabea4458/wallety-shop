import 'package:flutter/material.dart';
import 'package:smart_expense/core/theme/app_colors.dart';
import 'package:smart_expense/core/theme/app_radius.dart';
import 'package:smart_expense/core/theme/app_spacing.dart';
import 'package:smart_expense/core/theme/app_text_styles.dart';

/// The debt section shown in the Add Operation form when the operation
/// type is deposit. Includes a toggle switch and customer info fields.
/// - Customer name: REQUIRED
/// - Customer phone: OPTIONAL — stored in DebtorEntity, used for WhatsApp & call
/// - Operation phone (phoneNumber field) remains separate and is NOT used here.
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
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(AppSpacing.space4),
      decoration: BoxDecoration(
        color: isDebt
            ? AppColors.primary.withValues(alpha: 0.05)
            : AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: isDebt
              ? AppColors.primary.withValues(alpha: 0.4)
              : AppColors.border50,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SwitchListTile(
            title: Text(
              'تسجيل كآجل',
              style: AppTextStyles.body.copyWith(
                color: isDebt ? AppColors.primary : AppColors.foreground,
                fontWeight: isDebt ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            subtitle: Text(
              'عند التفعيل سيتم تسجيل دين للعميل',
              style: AppTextStyles.caption
                  .copyWith(color: AppColors.mutedForeground),
            ),
            value: isDebt,
            onChanged: isSaving ? null : onDebtChanged,
            contentPadding: EdgeInsets.zero,
            activeTrackColor: AppColors.primary,
          ),
          if (isDebt) ...[
            const Divider(height: 1),
            const SizedBox(height: AppSpacing.space3),
            // ── اسم العميل (مطلوب) ──────────────────────────────────
            TextField(
              controller: customerNameController,
              textAlign: TextAlign.right,
              decoration: InputDecoration(
                labelText: 'اسم العميل (مطلوب)',
                hintText: 'أدخل اسم العميل',
                border: const OutlineInputBorder(),
                labelStyle:
                    AppTextStyles.caption.copyWith(color: AppColors.primary),
                prefixIcon: const Icon(
                  Icons.person_outline_rounded,
                  size: 20,
                  color: AppColors.primary,
                ),
              ),
              style: AppTextStyles.body.copyWith(color: AppColors.foreground),
            ),
            const SizedBox(height: AppSpacing.space3),
            // ── رقم هاتف العميل (اختياري) ────────────────────────────
            TextField(
              controller: customerPhoneController,
              keyboardType: TextInputType.phone,
              textAlign: TextAlign.right,
              decoration: InputDecoration(
                labelText: 'رقم هاتف العميل (اختياري)',
                hintText: '01XXXXXXXXX',
                border: const OutlineInputBorder(),
                labelStyle: AppTextStyles.caption
                    .copyWith(color: AppColors.mutedForeground),
                prefixIcon: const Icon(
                  Icons.phone_outlined,
                  size: 20,
                  color: AppColors.mutedForeground,
                ),
                helperText: 'يُحفظ في بيانات العميل للاتصال وإرسال تذكير',
                helperStyle: AppTextStyles.caption.copyWith(
                  color: AppColors.mutedForeground,
                  fontSize: 11,
                ),
              ),
              style: AppTextStyles.body.copyWith(color: AppColors.foreground),
            ),
          ],
        ],
      ),
    );
  }
}
