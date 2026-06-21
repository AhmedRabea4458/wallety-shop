// ============================================================================
// MAIN ENTRY POINT
// ============================================================================
// This file creates a single shared instance of the Drift database and
// passes it down to the WalletsScreen.
//
// KEY CONCEPTS SHOWN HERE:
//   - The database is opened once when the app starts.
//   - It is passed directly to the screen (no dependency injection).
//   - The UI layer never creates SQL by hand; it calls methods on the
//     generated `AppDatabase` class.
// ============================================================================

import 'package:flutter/material.dart';

import 'data/app_database.dart';
import 'ui/wallets_screen.dart';

void main() {
  // `WidgetsFlutterBinding.ensureInitialized()` makes sure the Flutter
  // framework is ready before we open the database.
  WidgetsFlutterBinding.ensureInitialized();

  // Create one database instance for the whole app.
  // In larger apps you might use Provider, GetIt, Riverpod, etc. Here we
  // intentionally keep it simple and pass it manually.
  final database = AppDatabase();

  runApp(MyApp(database: database));
}

/// The root widget of the application.
class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.database});

  final AppDatabase database;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Drift Expense Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // Pass the database to the first screen.
      home: WalletsScreen(database: database),
    );
  }
}
