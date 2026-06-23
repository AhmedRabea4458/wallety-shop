import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_expense/core/constants/app_routes.dart';
import 'package:smart_expense/core/di/injection_container.dart';
import 'package:smart_expense/core/theme/app_colors.dart';
import 'package:smart_expense/features/analytics/presentation/cubit/analytics_cubit.dart';
import 'package:smart_expense/features/expenses/presentation/pages/transactions_page.dart';
import 'package:smart_expense/features/home/presentation/pages/home_page.dart';
import 'package:smart_expense/features/main_layout/presentation/widgets/custom_bottom_nav.dart';
import 'package:smart_expense/features/operations/presentation/cubit/cash_drawer_cubit.dart';
import 'package:smart_expense/features/operations/presentation/cubit/operation_cubit.dart';
import 'package:smart_expense/features/operations/presentation/cubit/operation_state.dart';
import 'package:smart_expense/features/operations/presentation/cubit/active_shift_cubit.dart';
import 'package:smart_expense/features/operations/presentation/cubit/debt_cubit.dart';
import 'package:smart_expense/features/operations/presentation/cubit/instapay_account_cubit.dart';
import 'package:smart_expense/features/operations/presentation/cubit/wallet_adjustment_cubit.dart';
import 'package:smart_expense/features/operations/presentation/cubit/wallet_cubit.dart';
import 'package:smart_expense/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:smart_expense/features/profile/presentation/pages/profile_page.dart';

 class MainLayoutPage extends StatefulWidget {
  const MainLayoutPage({super.key});

  @override
  State<MainLayoutPage> createState() => _MainLayoutPageState();
}

class _MainLayoutPageState extends State<MainLayoutPage> {
  int currentIndex = 0;

  late final List<Widget> pages;

  @override
  void initState() {
    super.initState();
    // Load data on app start
    sl<OperationCubit>().getOperations();
    sl<WalletCubit>().getWallets();
    sl<AnalyticsCubit>().loadAnalytics();
    sl<ProfileCubit>().getProfileStats();
    sl<CashDrawerCubit>().getCashDrawer();
    sl<WalletAdjustmentCubit>().loadAllAdjustments();
    sl<ActiveShiftCubit>().loadActiveShift();
    sl<DebtCubit>().loadOutstandingDebt();
    sl<InstaPayAccountCubit>().loadAccounts();

    pages = [
      HomePage(
        onNavigateToOperations: () => setState(() => currentIndex = 1),
      ),
      const TransactionsPage(),
      const ProfilePage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: sl<OperationCubit>()),
        BlocProvider.value(value: sl<WalletCubit>()),
        BlocProvider.value(value: sl<AnalyticsCubit>()),
        BlocProvider.value(value: sl<ProfileCubit>()),
        BlocProvider.value(value: sl<CashDrawerCubit>()),
        BlocProvider.value(value: sl<WalletAdjustmentCubit>()),
        BlocProvider.value(value: sl<ActiveShiftCubit>()),
        BlocProvider.value(value: sl<DebtCubit>()),
        BlocProvider.value(value: sl<InstaPayAccountCubit>()),
      ],
      child: Scaffold(
        extendBody: true,
        body: BlocListener<OperationCubit, OperationState>(
          listener: (context, state) {
            if (state is OperationLoaded) {
              context.read<CashDrawerCubit>().refreshCashDrawer();
              context.read<WalletAdjustmentCubit>().refreshAllAdjustments();
              context.read<ProfileCubit>().silentReload();
              context.read<AnalyticsCubit>().silentReload();
              context.read<WalletCubit>().getWallets();
              context.read<ActiveShiftCubit>().loadActiveShift();
              context.read<DebtCubit>().loadOutstandingDebt();
            }
          },
          child: IndexedStack(
            index: currentIndex,
            children: pages,
          ),
        ),
        bottomNavigationBar: CustomBottomNav(
          currentIndex: currentIndex,
          onTap: (index) => setState(() => currentIndex = index),
        ),
        floatingActionButton: GestureDetector(
          onTap: () => context.push(AppRoutes.addOperation),
          child: Container(
            width: 60,
            height: 60,
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
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ),
    );
  }
}
