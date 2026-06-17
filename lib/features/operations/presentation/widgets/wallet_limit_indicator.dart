import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smart_expense/core/theme/app_colors.dart';
import 'package:smart_expense/core/theme/app_radius.dart';
import 'package:smart_expense/core/theme/app_spacing.dart';
import 'package:smart_expense/core/theme/app_text_styles.dart';

class WalletLimitIndicator extends StatelessWidget {
  final String label;
  final double used;
  final double limit;

  const WalletLimitIndicator({
    super.key,
    required this.label,
    required this.used,
    required this.limit,
  });

  static String _format(double amount) {
    return NumberFormat('#,##0', 'ar').format(amount);
  }

  double get _progress => limit > 0 ? (used / limit).clamp(0.0, 1.0) : 0.0;
  double get _percentage => limit > 0 ? used / limit : 0.0;

  Color get _color {
    if (_percentage > 1.0) return const Color(0xFFB91C1C); // critical red-700
    if (_percentage >= 0.9) return const Color(0xFFEF4444); // red-500
    if (_percentage >= 0.8) return const Color(0xFFF97316); // orange-500
    return AppColors.success;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 42,
          child: Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.mutedForeground,
              fontSize: 11,
            ),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.full),
            child: LinearProgressIndicator(
              value: _progress,
              backgroundColor: AppColors.border50,
              valueColor: AlwaysStoppedAnimation<Color>(_color),
              minHeight: 5,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.space2),
        SizedBox(
          width: 76,
          child: Text(
            '${_format(used)} / ${_format(limit)}',
            textAlign: TextAlign.right,
            style: AppTextStyles.caption.copyWith(
              color: _color,
              fontWeight: FontWeight.w600,
              fontSize: 10,
            ),
          ),
        ),
      ],
    );
  }
}
