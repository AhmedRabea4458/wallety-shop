import 'package:flutter/material.dart';
import 'package:smart_expense/core/theme/app_colors.dart';
import 'package:smart_expense/features/main_layout/presentation/widgets/custom_bottom_nav_item.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.card95,
      elevation: 0,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 80,
          child: Row(
            children: [
              Expanded(
                child: CustomBottomNavItem(
                  icon: Icons.home_rounded,
                  label: 'الرئيسية',
                  isSelected: currentIndex == 0,
                  onTap: () => onTap(0),
                ),
              ),
              Expanded(
                child: CustomBottomNavItem(
                  icon: Icons.receipt_long_rounded,
                  label: 'العمليات',
                  isSelected: currentIndex == 1,
                  onTap: () => onTap(1),
                ),
              ),
              const SizedBox(width: 56),
              Expanded(
                child: CustomBottomNavItem(
                  icon: Icons.description_rounded,
                  label: 'التقارير',
                  isSelected: currentIndex == 2,
                  onTap: () => onTap(2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

