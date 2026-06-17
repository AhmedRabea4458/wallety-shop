import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_expense/core/di/injection_container.dart';
import 'package:smart_expense/core/constants/app_routes.dart';
import 'package:smart_expense/features/main_layout/presentation/pages/main_layout_page.dart';
import 'package:smart_expense/features/operations/domain/entities/operation_entity.dart';
import 'package:smart_expense/features/operations/presentation/cubit/operation_cubit.dart';
import 'package:smart_expense/features/operations/presentation/cubit/wallet_cubit.dart';
import 'package:smart_expense/features/operations/presentation/pages/add_operation_page.dart';
import 'package:smart_expense/features/operations/presentation/pages/wallet_management_page.dart';
import 'package:smart_expense/features/operations/presentation/pages/wallet_setup_page.dart';
import 'package:smart_expense/features/splash/presentation/pages/splash_page.dart';

final appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      builder: (context, state) => const SplashPage(),
    ),
    GoRoute(
      path: AppRoutes.main,
      builder: (context, state) => const MainLayoutPage(),
    ),
    GoRoute(
      path: AppRoutes.addOperation,
      builder: (context, state) {
        return MultiBlocProvider(
          providers: [
            BlocProvider.value(value: sl<OperationCubit>()),
            BlocProvider.value(value: sl<WalletCubit>()),
          ],
          child: const AddOperationPage(),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.editOperation,
      builder: (context, state) {
        final operation = state.extra as OperationEntity;
        return MultiBlocProvider(
          providers: [
            BlocProvider.value(value: sl<OperationCubit>()),
            BlocProvider.value(value: sl<WalletCubit>()),
          ],
          child: AddOperationPage(operationToEdit: operation),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.walletSetup,
      builder: (context, state) {
        return BlocProvider.value(
          value: sl<WalletCubit>(),
          child: const WalletSetupPage(),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.walletManagement,
      builder: (context, state) {
        return BlocProvider.value(
          value: sl<WalletCubit>(),
          child: const WalletManagementPage(),
        );
      },
    ),
  ],
);
