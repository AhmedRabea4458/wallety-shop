import 'package:get_it/get_it.dart';
import 'package:smart_expense/core/database/app_database.dart';
import 'package:smart_expense/features/analytics/data/datasources/local/analytics_local_datasource.dart';
import 'package:smart_expense/features/analytics/data/datasources/local/analytics_local_datasource_impl.dart';
import 'package:smart_expense/features/analytics/data/repositories/analytics_repository_impl.dart';
import 'package:smart_expense/features/analytics/domain/repositories/analytics_repository.dart';
import 'package:smart_expense/features/analytics/presentation/cubit/analytics_cubit.dart';
import 'package:smart_expense/features/operations/data/datasources/local/debt_local_datasource.dart';
import 'package:smart_expense/features/operations/data/datasources/local/debt_local_datasource_impl.dart';
import 'package:smart_expense/features/operations/data/datasources/local/instapay_account_local_datasource.dart';
import 'package:smart_expense/features/operations/data/datasources/local/instapay_account_local_datasource_impl.dart';
import 'package:smart_expense/features/operations/data/datasources/local/cash_drawer_local_datasource.dart';
import 'package:smart_expense/features/operations/data/datasources/local/cash_drawer_local_datasource_impl.dart';
import 'package:smart_expense/features/operations/data/datasources/local/operation_local_datasource.dart';
import 'package:smart_expense/features/operations/data/datasources/local/operation_local_datasource_impl.dart';
import 'package:smart_expense/features/operations/data/datasources/local/shift_local_datasource.dart';
import 'package:smart_expense/features/operations/data/datasources/local/shift_local_datasource_impl.dart';
import 'package:smart_expense/features/operations/data/datasources/local/wallet_adjustment_local_datasource.dart';
import 'package:smart_expense/features/operations/data/datasources/local/wallet_adjustment_local_datasource_impl.dart';
import 'package:smart_expense/features/operations/data/datasources/local/wallet_local_datasource.dart';
import 'package:smart_expense/features/operations/data/datasources/local/wallet_local_datasource_impl.dart';
import 'package:smart_expense/features/operations/data/repositories/debt_repository_impl.dart';
import 'package:smart_expense/features/operations/data/repositories/instapay_account_repository_impl.dart';
import 'package:smart_expense/features/operations/domain/repositories/debt_repository.dart';
import 'package:smart_expense/features/operations/domain/repositories/instapay_account_repository.dart';
import 'package:smart_expense/features/operations/data/repositories/cash_drawer_repository_impl.dart';
import 'package:smart_expense/features/operations/data/repositories/operation_repository_impl.dart';
import 'package:smart_expense/features/operations/data/repositories/shift_repository_impl.dart';
import 'package:smart_expense/features/operations/data/repositories/wallet_adjustment_repository_impl.dart';
import 'package:smart_expense/features/operations/data/repositories/wallet_repository_impl.dart';
import 'package:smart_expense/features/operations/domain/repositories/cash_drawer_repository.dart';
import 'package:smart_expense/features/operations/domain/repositories/operation_repository.dart';
import 'package:smart_expense/features/operations/domain/repositories/shift_repository.dart';
import 'package:smart_expense/features/operations/domain/repositories/wallet_adjustment_repository.dart';
import 'package:smart_expense/features/operations/domain/repositories/wallet_repository.dart';
import 'package:smart_expense/features/operations/presentation/cubit/active_shift_cubit.dart';
import 'package:smart_expense/features/operations/presentation/cubit/cash_drawer_cubit.dart';
import 'package:smart_expense/features/operations/presentation/cubit/operation_cubit.dart';
import 'package:smart_expense/features/operations/presentation/cubit/debt_cubit.dart';
import 'package:smart_expense/features/operations/presentation/cubit/instapay_account_cubit.dart';
import 'package:smart_expense/features/operations/presentation/cubit/shift_detail_cubit.dart';
import 'package:smart_expense/features/operations/presentation/cubit/shift_history_cubit.dart';
import 'package:smart_expense/features/operations/presentation/cubit/wallet_adjustment_cubit.dart';
import 'package:smart_expense/features/operations/presentation/cubit/wallet_cubit.dart';
import 'package:smart_expense/features/profile/presentation/cubit/profile_cubit.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Database
  sl.registerLazySingleton(() => AppDatabase());

  // DataSource
  sl.registerLazySingleton<AnalyticsLocalDataSource>(
    () => AnalyticsLocalDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<CashDrawerLocalDataSource>(
    () => CashDrawerLocalDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<OperationLocalDataSource>(
    () => OperationLocalDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<ShiftLocalDataSource>(
    () => ShiftLocalDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<WalletAdjustmentLocalDataSource>(
    () => WalletAdjustmentLocalDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<WalletLocalDataSource>(
    () => WalletLocalDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<DebtLocalDataSource>(
    () => DebtLocalDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<InstaPayAccountLocalDataSource>(
    () => InstaPayAccountLocalDataSourceImpl(sl()),
  );

  // Repository
  sl.registerLazySingleton<AnalyticsRepository>(
    () => AnalyticsRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<CashDrawerRepository>(
    () => CashDrawerRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<OperationRepository>(
    () => OperationRepositoryImpl(sl(), debtDataSource: sl()),
  );
  sl.registerLazySingleton<ShiftRepository>(
    () => ShiftRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<WalletAdjustmentRepository>(
    () => WalletAdjustmentRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<WalletRepository>(
    () => WalletRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<DebtRepository>(
    () => DebtRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<InstaPayAccountRepository>(
    () => InstaPayAccountRepositoryImpl(sl()),
  );

  // Cubit
  sl.registerLazySingleton(
    () => AnalyticsCubit(sl<AnalyticsRepository>()),
  );
  sl.registerLazySingleton(
    () => CashDrawerCubit(sl<CashDrawerRepository>()),
  );
  sl.registerLazySingleton(
    () => ProfileCubit(sl<OperationRepository>()),
  );
  sl.registerLazySingleton(
    () => WalletAdjustmentCubit(sl<WalletAdjustmentRepository>()),
  );
  sl.registerLazySingleton(
    () => OperationCubit(sl<OperationRepository>(), debtRepository: sl<DebtRepository>()),
  );
  sl.registerLazySingleton(
    () => ActiveShiftCubit(sl<ShiftRepository>()),
  );
  sl.registerFactory(
    () => ShiftHistoryCubit(sl<ShiftRepository>()),
  );
  sl.registerFactory(
    () => ShiftDetailCubit(sl<ShiftRepository>()),
  );
  sl.registerLazySingleton(
    () => WalletCubit(sl<WalletRepository>()),
  );
  sl.registerLazySingleton(
    () => DebtCubit(sl<DebtRepository>(), cashDrawerCubit: sl()),
  );
  sl.registerLazySingleton(
    () => InstaPayAccountCubit(sl<InstaPayAccountRepository>()),
  );
}
