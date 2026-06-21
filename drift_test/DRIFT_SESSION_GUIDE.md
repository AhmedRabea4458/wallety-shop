# Drift Teaching Session Guide

This guide suggests an order for presenting the concepts in this project during a **45–60 minute live coding session**. The goal is to move from "what is Drift?" to a working reactive UI with a foreign-key relation.

---

## 0. Project overview (3 min)

- Show the running app briefly if possible.
- Explain what we are building: a tiny Expense Tracker with Wallets and Transactions.
- Mention what is intentionally **not** in the project: no Cubit, no Clean Architecture, no Repository Pattern, no Dependency Injection. This keeps the focus purely on Drift.

---

## 1. What problem does Drift solve? (5 min)

**Goal:** Motivate why we use Drift instead of raw SQLite.

- SQLite is great but writing raw SQL strings is error-prone.
- Drift gives us:
  - Type-safe tables and queries.
  - Automatic code generation.
  - Reactive Streams (`watch()`).
  - Cross-platform Flutter support.
- Show `pubspec.yaml`:
  - `drift` = core ORM.
  - `drift_flutter` = platform connection.
  - `drift_dev` + `build_runner` = code generation.

---

## 2. Tables: the schema of the database (8 min)

**File:** `lib/data/app_database.dart` — `Wallets` and `Transactions` classes.

**Goal:** Explain what a Table is in Drift.

- A `Table` is a Dart description of an SQL table.
- Each `Column` becomes a column in SQLite.
- Live-code or walk through `Wallets`:
  - `id` with `autoIncrement()`.
  - `name` as `text()`.
  - `balance` as `real()` with a default.
- Explain that Drift will run `CREATE TABLE` for us at runtime.

---

## 3. Code generation: the `.g.dart` file (5 min)

**Goal:** Show how Drift generates code.

- Explain the `part 'app_database.g.dart';` directive.
- Run:
  ```bash
  dart run build_runner build
  ```
- Open the generated file and point out:
  - The generated `_$AppDatabase` base class.
  - The `Wallet` data class (Row).
  - The `WalletsCompanion` class (used for inserts/updates).
  - The `wallets` getter that represents the table at runtime.
- Emphasize: **we never edit `.g.dart` by hand**.

---

## 4. Rows: generated data classes (5 min)

**Goal:** Explain what a Row is in Drift.

- A Row is an instance of a generated data class like `Wallet` or `Transaction`.
- It is an immutable snapshot of one database row.
- Show how `Wallet` has `id`, `name`, and `balance` fields.
- Mention that the UI will display these objects directly.

---

## 5. The database class and connections (5 min)

**File:** `lib/data/app_database.dart` — `AppDatabase` class.

**Goal:** Explain the `@DriftDatabase` annotation and connection setup.

- `@DriftDatabase(tables: [Wallets, Transactions])` tells Drift which tables to include.
- `AppDatabase extends _$AppDatabase` uses the generated base class.
- `schemaVersion` is used for migrations.
- `driftDatabase(name: 'expense_tracker')` creates the SQLite file in the correct platform location.

---

## 6. Insert: creating rows (5 min)

**File:** `lib/data/app_database.dart` — `createWallet(...)`.

**Goal:** Show how to insert data.

- `into(wallets).insert(...)` targets the `wallets` table.
- `WalletsCompanion` is used for inserts because it can represent missing values.
- Show the UI flow in `add_wallet_screen.dart`:
  - User fills the form.
  - `_save()` calls `database.createWallet(...)`.
  - The list screen refreshes automatically.

---

## 7. Read and Watch: queries and Streams (8 min)

**File:** `lib/data/app_database.dart` — `getAllWallets()` and `watchAllWallets()`.
**File:** `lib/ui/wallets_screen.dart` — `StreamBuilder`.

**Goal:** Explain Queries, `watch()`, and Streams.

- A **Query** is a request for data. Drift turns it into SQL.
- `select(wallets).get()` fetches data once.
- `select(wallets).watch()` returns a `Stream<List<Wallet>>`.
- A **Stream** is an asynchronous sequence of events. Flutter listens to it with `StreamBuilder`.
- `watch()` re-emits automatically when the underlying table changes.
- The wallet cards have explicit **View**, **Edit** and **Delete** buttons so every screen is reachable without hidden gestures.
- Demonstrate live: add a wallet and watch the list update without a manual refresh.

---

## 8. Update and Delete (5 min)

**Files:**

- `lib/data/app_database.dart` — `updateWallet(...)` and `deleteWallet(...)`.
- `lib/ui/edit_wallet_screen.dart`
- `lib/ui/wallets_screen.dart` — explicit Edit/Delete buttons.

**Goal:** Show modifying and removing rows.

- `update(wallets).replace(...)` updates an existing row.
- `delete(wallets).where(...)` removes matching rows.
- The Edit button opens the update screen; the Delete button removes the wallet immediately.
- Mention that after each operation, the `watch()` Stream re-emits and the UI updates.

---

## 9. Relations and Foreign Keys (6 min)

**File:** `lib/data/app_database.dart` — `Transactions` table.

**Goal:** Explain relationships between tables.

- `wallet_id` in `Transactions` is a **foreign key** referencing `Wallets.id`.
- The `FOREIGN KEY ... REFERENCES ... ON DELETE CASCADE` constraint means:
  - You cannot insert a transaction for a wallet that does not exist.
  - Deleting a wallet automatically deletes its transactions.
- Show the relation in the UI:
  - `wallet_detail_screen.dart` watches only transactions for one wallet.
  - This is a one-to-many relation: one wallet has many transactions.

---

## 10. Live recap and Q&A (5 min)

**Goal:** Reinforce the core Drift concepts.

Quickly trace a full user flow:

1. Open app → `AppDatabase` is created.
2. `WalletsScreen` listens to `watchAllWallets()`.
3. Add wallet → `createWallet()` inserts a row.
4. Drift detects the change → Stream emits new list.
5. `StreamBuilder` rebuilds → new wallet appears.
6. Tap wallet → `WalletDetailScreen` watches related transactions.
7. Add transaction → `createTransaction()` inserts child row.
8. Delete wallet → CASCADE deletes transactions automatically.

**Key takeaways:**

- Tables describe schema.
- Rows are generated data classes.
- Companions help with inserts/updates.
- Queries become SQL.
- `watch()` gives reactive Streams.
- Foreign keys define relations.
- `build_runner` generates the glue code.

---

## Optional extra topics (if time permits)

- **Migrations:** what happens when `schemaVersion` changes.
- **`getSingleOrNull()`** vs `getSingle()` for safer lookups.
- **Indexes** for faster queries on large tables.
- **DAOs** (Data Access Objects) for organizing queries in bigger projects.
