import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_expense/core/database/app_database.dart';
import 'package:smart_expense/features/analytics/data/datasources/local/analytics_local_datasource.dart';
import 'package:smart_expense/features/analytics/data/datasources/local/analytics_local_datasource_impl.dart';
import 'package:smart_expense/features/analytics/data/repositories/analytics_repository_impl.dart';
import 'package:smart_expense/features/analytics/domain/repositories/analytics_repository.dart';
import 'package:smart_expense/features/analytics/presentation/cubit/analytics_cubit.dart';
import 'package:smart_expense/features/expenses/data/datasources/local/transaction_local_datasource.dart';
import 'package:smart_expense/features/expenses/data/datasources/local/transaction_local_datasource_imp.dart';
import 'package:smart_expense/features/expenses/data/repositories/transaction_repository_imp.dart';
import 'package:smart_expense/features/expenses/domain/repositories/transaction_repository.dart';
import 'package:smart_expense/features/expenses/presentation/cubit/transaction_cubit.dart';
import 'package:smart_expense/features/profile/presentation/cubit/profile_cubit.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Database
  sl.registerLazySingleton(() => AppDatabase());

  // SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => prefs);

  // DataSource
  sl.registerLazySingleton<TransactionLocalDataSource>(
    () => TransactionLocalDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<AnalyticsLocalDataSource>(
    () => AnalyticsLocalDataSourceImpl(sl()),
  );

  // Repository
  sl.registerLazySingleton<TransactionRepository>(
    () => TransactionRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<AnalyticsRepository>(
    () => AnalyticsRepositoryImpl(sl()),
  );

  // Cubit
  sl.registerLazySingleton(
    () => TransactionCubit(sl()),
  );
  sl.registerLazySingleton(
    () => AnalyticsCubit(sl<AnalyticsRepository>()),
  );
  sl.registerLazySingleton(
    () => ProfileCubit(
      sl<TransactionRepository>(),
      sl<SharedPreferences>(),
    ),
  );
}

