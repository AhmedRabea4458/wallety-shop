// ignore_for_file: depend_on_referenced_packages

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

// Wallets table
class Wallets extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 50)();
  RealColumn get balance => real().withDefault(Constant(0.0))();

  @override
  String? get tableName => 'wallets';
}

// Transactions table. Foreign key: transaction belongs to a wallet.
// CASCADE deletes related transactions when a wallet is deleted.
class Transactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get walletId => integer().named('wallet_id')();
  RealColumn get amount => real()();
  TextColumn get note => text().withLength(min: 1, max: 200)();
  DateTimeColumn get createdAt => dateTime().named('created_at')();

  @override
  List<String> get customConstraints => [
        'FOREIGN KEY(wallet_id) REFERENCES wallets(id) ON DELETE CASCADE',
      ];

  @override
  String? get tableName => 'transactions';
}

// Drift database. Tables are registered via @DriftDatabase.
// Run: dart run build_runner build
@DriftDatabase(tables: [Wallets, Transactions])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'expense_tracker');
  }

  // CRUD: Wallet

  Future<int> createWallet(String name, double balance) {
    return into(wallets).insert(
      WalletsCompanion(name: Value(name), balance: Value(balance)),
    );
  }

  Future<List<Wallet>> getAllWallets() => select(wallets).get();

  // Reactive stream that updates automatically on DB changes.
  Stream<List<Wallet>> watchAllWallets() => select(wallets).watch();

  Future<void> updateWallet(int id, String newName, double newBalance) {
    return update(wallets).replace(
      Wallet(id: id, name: newName, balance: newBalance),
    );
  }

  Future<void> deleteWallet(int id) {
    return (delete(wallets)..where((w) => w.id.equals(id))).go();
  }

  // Relationship: transactions for a specific wallet.
  Stream<List<Transaction>> watchTransactionsForWallet(int walletId) {
    return (select(transactions)
          ..where((t) => t.walletId.equals(walletId))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch();
  }

  // CRUD: Transaction

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

  Future<Wallet?> getWalletById(int id) {
    return (select(wallets)..where((w) => w.id.equals(id))).getSingleOrNull();
  }

  Future<void> deleteTransaction(int id) {
    return (delete(transactions)..where((t) => t.id.equals(id))).go();
  }
}
