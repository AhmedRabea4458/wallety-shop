import 'package:flutter/material.dart';
import 'package:smart_expense/core/theme/app_colors.dart';
import 'package:smart_expense/core/theme/app_radius.dart';
import 'package:smart_expense/core/theme/app_spacing.dart';
import 'package:smart_expense/core/theme/app_text_styles.dart';

class BalanceCard extends StatefulWidget {
  final String balance;
  final String income;
  final String expenses;
  final String currency;
  final VoidCallback? onTap;

  const BalanceCard({
    super.key,
    required this.balance,
    required this.income,
    required this.expenses,
    this.currency = 'ج.م',
    this.onTap,
  });

  @override
  State<BalanceCard> createState() => _BalanceCardState();
}

class _BalanceCardState extends State<BalanceCard> {
  bool _isVisible = true;

  void _toggleVisibility() {
    setState(() {
      _isVisible = !_isVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
      ),
      decoration: BoxDecoration(
        gradient: AppColors.heroGradientLinear,
        borderRadius: BorderRadius.circular(AppRadius.heroCard),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.heroCard),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.space6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'الرصيد الحالي',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.withAlpha(
                            AppColors.primaryForeground,
                            0.7,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: _toggleVisibility,
                        icon: Icon(
                          _isVisible
                              ? Icons.remove_red_eye_outlined
                              : Icons.visibility_off_outlined,
                          size: 20,
                          color: AppColors.primaryForeground,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.space2),
                  // Amount
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _isVisible ? widget.balance : '****',
                        style: AppTextStyles.hero.copyWith(
                          color: AppColors.primaryForeground,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.space2),
                      Text(
                        widget.currency,
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.withAlpha(
                            AppColors.primaryForeground,
                            0.8,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.space6),
                  // Divider
                  Divider(
                    color: AppColors.withAlpha(
                      AppColors.primaryForeground,
                      0.1,
                    ),
                    thickness: 1,
                    height: 1,
                  ),
                  const SizedBox(height: AppSpacing.space4),
                  // Income & Expenses
                  Row(
                    children: [
                      Expanded(
                        child: _SummaryItem(
                          label: 'العمولات',
                          amount: widget.income,
                          icon: Icons.arrow_upward_rounded,
                          color: AppColors.success,
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: AppColors.withAlpha(
                          AppColors.primaryForeground,
                          0.1,
                        ),
                      ),
                      Expanded(
                        child: _SummaryItem(
                          label: 'العمليات',
                          amount: widget.expenses,
                          icon: Icons.arrow_downward_rounded,
                          color: AppColors.destructive,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String amount;
  final IconData icon;
  final Color color;

  const _SummaryItem({
    required this.label,
    required this.amount,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.withAlpha(
              AppColors.primaryForeground,
              0.6,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.space1),
        Row(
          children: [
            Text(
              amount,
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.primaryForeground,
              ),
            ),
            const SizedBox(width: AppSpacing.space2),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.withAlpha(color, 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 12,
                color: color,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
