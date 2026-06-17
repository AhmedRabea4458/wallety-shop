import 'package:flutter/material.dart';
import 'package:smart_expense/core/theme/app_colors.dart';
import 'package:smart_expense/core/theme/app_radius.dart';
import 'package:smart_expense/core/theme/app_spacing.dart';
import 'package:smart_expense/core/theme/app_text_styles.dart';
import 'package:smart_expense/features/operations/domain/entities/wallet_entity.dart';

class WalletSelector extends StatelessWidget {
  final List<WalletEntity> wallets;
  final int? selectedWalletId;
  final ValueChanged<int?> onChanged;

  const WalletSelector({
    super.key,
    required this.wallets,
    this.selectedWalletId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space5,
        vertical: AppSpacing.space4,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'المحفظة',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.mutedForeground,
            ),
          ),
          const SizedBox(height: AppSpacing.space2),
          DropdownButtonHideUnderline(
            child: DropdownButton<int?>(
              isExpanded: true,
              value: selectedWalletId,
              hint: Text(
                'اختر المحفظة',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.mutedForeground,
                ),
              ),
              icon: Icon(
                Icons.arrow_drop_down_rounded,
                color: AppColors.foreground,
              ),
              dropdownColor: AppColors.card,
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.foreground,
              ),
              items: wallets.map((wallet) {
                return DropdownMenuItem<int>(
                  value: wallet.id,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            wallet.name,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          if (wallet.phoneNumber != null && wallet.phoneNumber!.isNotEmpty)
                            Text(
                              wallet.phoneNumber!,
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.mutedForeground,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                        ],
                      ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
