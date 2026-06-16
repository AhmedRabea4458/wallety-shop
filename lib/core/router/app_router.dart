import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_expense/core/di/injection_container.dart';
import 'package:smart_expense/core/constants/app_routes.dart';
import 'package:smart_expense/features/expenses/presentation/cubit/transaction_cubit.dart';
import 'package:smart_expense/features/expenses/presentation/pages/add_transaction_page.dart';
import 'package:smart_expense/features/main_layout/presentation/pages/main_layout_page.dart';
import 'package:smart_expense/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:smart_expense/features/splash/presentation/pages/splash_page.dart';

final appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      builder: (context, state) => const SplashPage(),
    ),
    GoRoute(
      path: AppRoutes.onboarding,
      builder: (context, state) => const OnboardingPage(),
    ),
    GoRoute(
      path: AppRoutes.main,
      builder: (context, state) => const MainLayoutPage(),
    ),
    GoRoute(
      path: AppRoutes.addTransaction,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final isExpense = extra?['isExpense'] as bool? ?? true;
        return BlocProvider.value(
          value: sl<TransactionCubit>(),
          child: AddTransactionPage(initialIsExpense: isExpense),
        );
      },
    ),
    
  ],
);