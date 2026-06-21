// ignore_for_file: depend_on_referenced_packages

// ============================================================================
// DRIFT DATABASE DEFINITION
// ============================================================================
// This file is the heart of the Drift lesson. It defines:
//   1. Tables (the schema of our SQLite database).
//   2. The database class that Drift will use to generate code.
//   3. The methods our UI will call to insert, read, update, delete and watch.
//
// After editing this file we run:
//   dart run build_runner build
// to produce app_database.g.dart, which contains all the generated helpers.
// ============================================================================

import 'package:drift/drift.dart';

// drift_flutter gives us a platform-aware database connection.
import 'package:drift_flutter/drift_flutter.dart';

// The `part` directive tells Dart that the generated code lives in the file
// named `app_database.g.dart`. The `.g` stands for "generated".
// Drift reads this file, finds our @DriftDatabase annotation and Table
// classes, then writes companion classes, data classes and query helpers
// into that generated file.
part 'app_database.g.dart';

// ============================================================================
// 1. TABLES
// ============================================================================
// In SQL, a TABLE is a collection of rows that share the same columns.
// Think of it like a spreadsheet sheet: it has a fixed header (columns) and
// many data rows underneath.
//
// In Drift, we define a table by creating a Dart class that extends `Table`.
// Each `Column` we declare becomes a column in the SQLite table.
//
// Drift uses these classes at TWO times:
//   A. At compile time: `drift_dev` reads them and generates code.
//   B. At runtime: Drift creates the actual SQLite tables for us.
// ============================================================================

/// The `wallets` table.
///
/// A Table in Drift is a Dart description of an SQL table. When the app runs,
/// Drift will execute `CREATE TABLE wallets (...)` in SQLite for us.
class Wallets extends Table {
  // --------------------------------------------------------------------------
  // Primary key column
  // --------------------------------------------------------------------------
  // `IntColumn` tells Drift this column stores integers.
  // `.autoIncrement()` means SQLite will generate a unique id for every row.
  // In SQL this becomes: `id INTEGER PRIMARY KEY AUTOINCREMENT`.
  IntColumn get id => integer().autoIncrement()();

  // --------------------------------------------------------------------------
  // Name column
  // --------------------------------------------------------------------------
  // `TextColumn` stores text (SQL TEXT).
  // `.withLength(...)` adds a length constraint at the Dart level and can
  // also generate SQL constraints if requested.
  TextColumn get name => text().withLength(min: 1, max: 50)();

  // --------------------------------------------------------------------------
  // Balance column
  // --------------------------------------------------------------------------
  // `RealColumn` stores floating-point numbers (SQL REAL).
  // We default the balance to 0.0 so every new wallet starts with zero money.
  RealColumn get balance => real().withDefault(Constant(0.0))();

  // --------------------------------------------------------------------------
  // Table customization
  // --------------------------------------------------------------------------
  // `get tableName` lets us override the default table name. Drift would
  // otherwise call this table `wallets` anyway (plural of the class name),
  // but being explicit is good for teaching.
  @override
  String? get tableName => 'wallets';
}

/// The `transactions` table.
///
/// This table stores individual money movements that belong to a wallet.
/// It demonstrates a FOREIGN KEY: every transaction points back to the
/// wallet it belongs to.
class Transactions extends Table {
  // --------------------------------------------------------------------------
  // Primary key column
  // --------------------------------------------------------------------------
  IntColumn get id => integer().autoIncrement()();

  // --------------------------------------------------------------------------
  // Foreign key column
  // --------------------------------------------------------------------------
  // `IntColumn` named `wallet_id` will store the id of the related wallet.
  //
  // WHAT IS A FOREIGN KEY?
  // A foreign key is a column in one table that references the primary key
  // of another table. It creates a relationship: "this transaction belongs
  // to that wallet". SQLite can enforce this relationship, preventing us
  // from inserting a transaction for a wallet that does not exist and from
  // deleting a wallet that still has transactions (depending on the rule).
  IntColumn get walletId => integer().named('wallet_id')();

  // --------------------------------------------------------------------------
  // Amount column
  // --------------------------------------------------------------------------
  // Positive amount = income, negative amount = expense. We store both in
  // the same column as real numbers.
  RealColumn get amount => real()();

  // --------------------------------------------------------------------------
  // Note column
  // --------------------------------------------------------------------------
  // Optional text description of the transaction.
  TextColumn get note => text().withLength(min: 1, max: 200)();

  // --------------------------------------------------------------------------
  // Created-at column
  // --------------------------------------------------------------------------
  // `DateTimeColumn` is a Drift convenience. Drift stores DateTime values
  // as integers (Unix milliseconds) in SQLite by default, and converts
  // them back to Dart DateTime objects automatically.
  DateTimeColumn get createdAt => dateTime().named('created_at')();

  // --------------------------------------------------------------------------
  // Foreign key constraint
  // --------------------------------------------------------------------------
  // `references(...)` tells Drift to add an SQL FOREIGN KEY constraint.
  // The first argument is the table being referenced (`Wallets`).
  // The second argument is the column being referenced (`id`).
  //
  // The `onDelete: KeyAction.cascade` rule means: if a wallet is deleted,
  // SQLite will automatically delete all transactions that reference it.
  // This keeps the database consistent without us having to delete children
  // manually.
  @override
  List<String> get customConstraints => [
        'FOREIGN KEY(wallet_id) REFERENCES wallets(id) ON DELETE CASCADE',
      ];

  @override
  String? get tableName => 'transactions';
}

// ============================================================================
// 2. DATABASE CLASS
// ============================================================================
// The database class is the main object our app interacts with. It extends
// `_$AppDatabase`, which will be generated by drift_dev in app_database.g.dart.
//
// `@DriftDatabase` is an annotation. Annotations are metadata attached to
// code. Here it tells the code generator:
//   "Please generate a complete database using these tables and these daos."
//
// Tables: the list of Table classes we defined above.
// Daos: optional Data Access Objects. We are not using them here to keep
//       the example minimal; all queries live directly in this class.
// ============================================================================

@DriftDatabase(tables: [Wallets, Transactions])
class AppDatabase extends _$AppDatabase {
  // --------------------------------------------------------------------------
  // Single public constructor
  // --------------------------------------------------------------------------
  // `super(...)` receives a `QueryExecutor`. The QueryExecutor is the bridge
  // between Drift and the underlying SQLite engine. On Flutter we obtain it
  // through `driftDatabase(...)` from the `drift_flutter` package, which
  // automatically picks the correct implementation for Android, iOS, desktop
  // and web.
  AppDatabase() : super(_openConnection());

  // --------------------------------------------------------------------------
  // Schema version
  // --------------------------------------------------------------------------
  // Every Drift database has a schema version. Drift uses this number to
  // decide whether to run migrations. For this teaching app we keep it at 1.
  // If we later added a new column we would bump this to 2 and write a
  // migration strategy.
  @override
  int get schemaVersion => 1;

  // --------------------------------------------------------------------------
  // Connection helper
  // --------------------------------------------------------------------------
  // `_openConnection` is a private static function that returns a QueryExecutor.
  // `driftDatabase(name: 'expense_tracker')` opens (or creates) a file named
  // `expense_tracker.sqlite` in the platform-appropriate app documents
  // directory and sets up SQLite for us.
  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'expense_tracker');
  }

  // ==========================================================================
  // 3. QUERY METHODS
  // ==========================================================================
  // A QUERY is a request we send to the database. Drift turns our Dart
  // method calls into SQL statements and runs them through SQLite.
  //
  // Each method below demonstrates a core operation:
  //   CREATE (insert)  -> adds a new row
  //   READ   (select)  -> fetches rows
  //   UPDATE           -> changes an existing row
  //   DELETE           -> removes a row
  //   WATCH            -> returns a Stream that emits new data automatically
  // ==========================================================================

  // --------------------------------------------------------------------------
  // CREATE: Insert a wallet
  // --------------------------------------------------------------------------
  // `into(wallets)` says "target the wallets table".
  // `insert(...)` takes a `WalletsCompanion`, which is a generated class that
  // represents a row we want to insert. Companions are useful because they
  // let Drift distinguish between "null value" and "value not provided".
  //
  // The returned `Future<int>` is the auto-generated id of the new wallet.
  Future<int> createWallet(String name, double balance) {
    return into(wallets).insert(
      WalletsCompanion(
        // `Value(...)` wraps the value we want to set.
        name: Value(name),
        balance: Value(balance),
      ),
    );
  }

  // --------------------------------------------------------------------------
  // READ: Fetch all wallets as a one-time list
  // --------------------------------------------------------------------------
  // `select(wallets)` creates a `SelectStatement` for the wallets table.
  // `.get()` executes the query immediately and returns a `Future<List<Wallet>>`.
  //
  // `Wallet` (singular) is a generated DATA CLASS. A Row in Drift is an
  // instance of this generated data class. Each `Wallet` object is an
  // immutable snapshot of one database row.
  Future<List<Wallet>> getAllWallets() {
    return select(wallets).get();
  }

  // --------------------------------------------------------------------------
  // READ: Watch all wallets as a Stream
  // --------------------------------------------------------------------------
  // `watch()` is one of Drift's most powerful features. Instead of fetching
  // data once, it returns a `Stream<List<Wallet>>`.
  //
  // WHAT IS A STREAM?
  // A Stream is a sequence of asynchronous events. You can listen to it and
  // receive new values over time. In Flutter, `StreamBuilder` listens to a
  // Stream and rebuilds whenever a new event arrives.
  //
  // WHAT DOES watch() DO?
  // `watch()` does three things:
  //   1. It runs the query once and emits the current result.
  //   2. It remembers the query.
  //   3. Whenever ANY write operation changes data that could affect this
  //      query (insert, update, delete), Drift re-runs the query and emits
  //      a new list. This makes the UI reactive without manual refresh.
  Stream<List<Wallet>> watchAllWallets() {
    return select(wallets).watch();
  }

  // --------------------------------------------------------------------------
  // UPDATE: Change an existing wallet
  // --------------------------------------------------------------------------
  // `update(wallets)` creates an `UpdateStatement`.
  // `where(...)` restricts the update to the row whose id matches.
  // `write(...)` applies the companion values.
  //
  // The `where` clause uses the generated `tbl` (table) reference. `tbl.id`
  // refers to the `id` column of the wallets table.
  Future<void> updateWallet(int id, String newName, double newBalance) {
    return update(wallets).replace(
      Wallet(
        id: id,
        name: newName,
        balance: newBalance,
      ),
    );
  }

  // --------------------------------------------------------------------------
  // DELETE: Remove a wallet
  // --------------------------------------------------------------------------
  // `delete(wallets)` creates a `DeleteStatement`.
  // `where(...)` restricts the delete to the matching row.
  //
  // Because we defined `ON DELETE CASCADE` on the foreign key in the
  // transactions table, deleting a wallet will also delete all of its
  // transactions automatically.
  Future<void> deleteWallet(int id) {
    return (delete(wallets)..where((w) => w.id.equals(id))).go();
  }

  // --------------------------------------------------------------------------
  // RELATION EXAMPLE: Transactions for a specific wallet
  // --------------------------------------------------------------------------
  // `where((t) => t.walletId.equals(walletId))` filters the transactions
  // table to only rows whose `wallet_id` column equals the given wallet id.
  // This is the simplest form of a one-to-many relationship: one wallet has
  // many transactions.
  Stream<List<Transaction>> watchTransactionsForWallet(int walletId) {
    return (select(transactions)
          ..where((t) => t.walletId.equals(walletId))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch();
  }

  // --------------------------------------------------------------------------
  // CREATE: Insert a transaction
  // --------------------------------------------------------------------------
  // We also provide an insert for transactions so we can demonstrate the
  // relation between wallets and transactions in the UI.
  Future<int> createTransaction({
    required int walletId,
    required double amount,
    required String note,
  }) {
    return into(transactions).insert(
      TransactionsCompanion(
        walletId: Value(walletId),
        amount: Value(amount),
        note: Value(note),
        createdAt: Value(DateTime.now()),
      ),
    );
  }

  // --------------------------------------------------------------------------
  // READ: Get a single wallet by id
  // --------------------------------------------------------------------------
  // `getSingle()` expects exactly one row. If the id does not exist, Drift
  // throws an exception, so in a production app you might prefer `.getSingleOrNull()`.
  Future<Wallet> getWalletById(int id) {
    return (select(wallets)..where((w) => w.id.equals(id))).getSingle();
  }

  // --------------------------------------------------------------------------
  // DELETE: Remove a transaction
  // --------------------------------------------------------------------------
  Future<void> deleteTransaction(int id) {
    return (delete(transactions)..where((t) => t.id.equals(id))).go();
  }
}
