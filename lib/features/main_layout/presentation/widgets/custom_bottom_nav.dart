import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_expense/core/constants/app_routes.dart';
import 'package:smart_expense/core/theme/app_colors.dart';
import 'package:smart_expense/core/theme/app_radius.dart';
import 'package:smart_expense/core/theme/app_spacing.dart';
import 'package:smart_expense/features/main_layout/presentation/widgets/custom_bottom_nav_item.dart';

class CustomBottomNav extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<CustomBottomNav> createState() => _CustomBottomNavState();
}

class _CustomBottomNavState extends State<CustomBottomNav> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.card95,
                border: Border(
                  top: BorderSide(color: AppColors.border50, width: 1),
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppRadius.xxxl),
                  topRight: Radius.circular(AppRadius.xxxl),
                ),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.border50,
                    blurRadius: 20,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: CustomBottomNavItem(
                      icon: Icons.home_rounded,
                      label: 'الرئيسية',
                      isSelected: widget.currentIndex == 0,
                      onTap: () => widget.onTap(0),
                    ),
                  ),
                  Expanded(
                    child:                     CustomBottomNavItem(
                      icon: Icons.receipt_long_rounded,
                      label: 'العمليات',
                      isSelected: widget.currentIndex == 1,
                      onTap: () => widget.onTap(1),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.space10 * 2),
                  Expanded(
                    child: CustomBottomNavItem(
                      icon: Icons.bar_chart_rounded,
                      label: 'التحليلات',
                      isSelected: widget.currentIndex == 2,
                      onTap: () => widget.onTap(2),
                    ),
                  ),
                  Expanded(
                    child:                     CustomBottomNavItem(
                      icon: Icons.description_rounded,
                      label: 'التقارير',
                      isSelected: widget.currentIndex == 3,
                      onTap: () => widget.onTap(3),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: -30,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: () {
                  context.push(AppRoutes.addOperation);
                },
                child: Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.ctaGradientLinear,
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.fabGlow,
                        blurRadius: 30,
                        spreadRadius: 6,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.add_rounded,
                    color: AppColors.primaryForeground,
                    size: 30,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
