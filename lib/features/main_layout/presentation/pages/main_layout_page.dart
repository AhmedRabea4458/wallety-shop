import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_expense/core/di/injection_container.dart';
import 'package:smart_expense/features/analytics/presentation/cubit/analytics_cubit.dart';
import 'package:smart_expense/features/analytics/presentation/pages/analytics_page.dart';
import 'package:smart_expense/features/expenses/presentation/cubit/transaction_cubit.dart';
import 'package:smart_expense/features/expenses/presentation/pages/transactions_page.dart';
import 'package:smart_expense/features/home/presentation/pages/home_page.dart';
import 'package:smart_expense/features/main_layout/presentation/widgets/custom_bottom_nav.dart';
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
    sl<TransactionCubit>().getTransactions();
    sl<AnalyticsCubit>().loadAnalytics();
    sl<ProfileCubit>().getProfileStats();

    pages = [
      HomePage(
        onNavigateToTransactions: () => setState(() => currentIndex = 1),
      ),
      const TransactionsPage(),
      const AnalyticsPage(),
      const ProfilePage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: sl<TransactionCubit>()),
        BlocProvider.value(value: sl<AnalyticsCubit>()),
        BlocProvider.value(value: sl<ProfileCubit>()),
      ],
      child: Scaffold(
        extendBody: true,
        body: IndexedStack(
          index: currentIndex,
          children: pages,
        ),
        bottomNavigationBar: SafeArea(
          child: CustomBottomNav(
            currentIndex: currentIndex,
            onTap: (index) => setState(() => currentIndex = index),
          ),
        ),
      ),
    );
  }
}