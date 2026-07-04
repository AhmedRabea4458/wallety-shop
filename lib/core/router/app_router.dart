import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_expense/core/di/injection_container.dart';
import 'package:smart_expense/core/constants/app_routes.dart';
import 'package:smart_expense/features/main_layout/presentation/pages/main_layout_page.dart';
import 'package:smart_expense/features/operations/domain/entities/operation_entity.dart';
import 'package:smart_expense/features/operations/presentation/cubit/operation_cubit.dart';
import 'package:smart_expense/features/operations/presentation/cubit/active_shift_cubit.dart';
import 'package:smart_expense/features/operations/presentation/cubit/shift_detail_cubit.dart';
import 'package:smart_expense/features/operations/presentation/cubit/shift_history_cubit.dart';
import 'package:smart_expense/features/operations/presentation/cubit/debt_cubit.dart';
import 'package:smart_expense/features/operations/presentation/cubit/instapay_account_cubit.dart';
import 'package:smart_expense/features/operations/presentation/cubit/wallet_adjustment_cubit.dart';
import 'package:smart_expense/features/operations/presentation/cubit/wallet_cubit.dart';
import 'package:smart_expense/features/operations/presentation/pages/add_operation_page.dart';
import 'package:smart_expense/features/operations/presentation/pages/debtor_detail_page.dart';
import 'package:smart_expense/features/operations/presentation/pages/operation_detail_page.dart';
import 'package:smart_expense/features/operations/presentation/pages/debtors_page.dart';
import 'package:smart_expense/features/operations/presentation/pages/shift_detail_page.dart';
import 'package:smart_expense/features/operations/presentation/pages/shift_history_page.dart';
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
            BlocProvider.value(value: sl<ActiveShiftCubit>()),
            BlocProvider.value(value: sl<DebtCubit>()),
            BlocProvider.value(value: sl<InstaPayAccountCubit>()),
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
            BlocProvider.value(value: sl<ActiveShiftCubit>()),
            BlocProvider.value(value: sl<DebtCubit>()),
            BlocProvider.value(value: sl<InstaPayAccountCubit>()),
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
        return MultiBlocProvider(
          providers: [
            BlocProvider.value(value: sl<WalletCubit>()),
            BlocProvider.value(value: sl<WalletAdjustmentCubit>()),
          ],
          child: const WalletManagementPage(),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.shiftHistory,
      builder: (context, state) {
        return BlocProvider(
          create: (context) => sl<ShiftHistoryCubit>(),
          child: const ShiftHistoryPage(),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.shiftDetail,
      builder: (context, state) {
        final shiftId = state.extra as int;
        return BlocProvider(
          create: (context) => sl<ShiftDetailCubit>(),
          child: ShiftDetailPage(shiftId: shiftId),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.operationDetail,
      builder: (context, state) {
        final operation = state.extra as OperationEntity;
        return MultiBlocProvider(
          providers: [
            BlocProvider.value(value: sl<OperationCubit>()),
            BlocProvider.value(value: sl<WalletCubit>()),
            BlocProvider.value(value: sl<DebtCubit>()),
            BlocProvider.value(value: sl<InstaPayAccountCubit>()),
          ],
          child: OperationDetailPage(operation: operation),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.debtors,
      builder: (context, state) {
        return BlocProvider.value(
          value: sl<DebtCubit>(),
          child: const DebtorsPage(),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.debtorDetail,
      builder: (context, state) {
        final debtorId = state.extra as int;
        return BlocProvider.value(
          value: sl<DebtCubit>(),
          child: DebtorDetailPage(debtorId: debtorId),
        );
      },
    ),
  ],
);
