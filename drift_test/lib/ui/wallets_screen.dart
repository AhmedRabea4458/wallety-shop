// ============================================================================
// WALLETS SCREEN
// ============================================================================
// This is the home screen of the app. It demonstrates reading data from
// Drift using a reactive Stream and performing update/delete operations.
//
// KEY CONCEPTS SHOWN HERE:
//   - `StreamBuilder` listens to a Drift Stream.
//   - `watchAllWallets()` re-emits automatically when data changes.
//   - Explicit buttons make every screen (view, edit, delete) easy to reach.
//   - FAB navigates to a screen that inserts a new wallet.
// ============================================================================

import 'package:flutter/material.dart';

// Import the generated data class `Wallet` and the database class.
import 'package:drift_test/data/app_database.dart';

// Import the other screens.
import 'add_wallet_screen.dart';
import 'edit_wallet_screen.dart';
import 'wallet_detail_screen.dart';

/// The main screen that lists every wallet in the database.
///
/// It receives the same `AppDatabase` instance that was created in main.dart.
/// We pass the database around directly because this demo intentionally
/// avoids Cubits, repositories and dependency injection.
class WalletsScreen extends StatelessWidget {
  const WalletsScreen({super.key, required this.database});

  // The single database instance shared by the whole app.
  final AppDatabase database;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wallets'),
        // A subtitle that reminds students what they are looking at.
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(24),
          child: Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Text(
              'Live Drift Stream demo',
              style: TextStyle(fontSize: 12),
            ),
          ),
        ),
      ),

      // -----------------------------------------------------------------------
      // StreamBuilder
      // -----------------------------------------------------------------------
      // `StreamBuilder` is a Flutter widget that rebuilds whenever the Stream
      // it is listening to emits a new value.
      //
      // In our case the Stream is `database.watchAllWallets()`.
      // Remember: `watch()` returns a Stream that re-emits automatically
      // whenever the underlying table changes. So when we add, update or
      // delete a wallet, this builder will run again with a fresh list.
      body: StreamBuilder<List<Wallet>>(
        stream: database.watchAllWallets(),
        builder: (context, snapshot) {
          // `snapshot.connectionState` tells us whether the Stream is waiting
          // for the first event, active, or done.
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // `snapshot.hasError` is true if the Stream emitted an error.
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          // The actual data is inside `snapshot.data`. Drift emits a
          // `List<Wallet>`, where each `Wallet` is one row from the table.
          final wallets = snapshot.data ?? [];

          if (wallets.isEmpty) {
            return const Center(
              child: Text('No wallets yet. Tap + to add one.'),
            );
          }

          return ListView.builder(
            itemCount: wallets.length,
            padding: const EdgeInsets.all(12),
            itemBuilder: (context, index) {
              // Each `Wallet` object is a generated data class (a Row).
              final wallet = wallets[index];

              // We use a Card so each wallet has a clear boundary and a row
              // of explicit action buttons. This makes every screen reachable
              // without hidden gestures like long-press or swipe.
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Wallet name and balance.
                      Text(
                        wallet.name,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Balance: \$${wallet.balance.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 12),

                      // Explicit action buttons.
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // VIEW button -> opens the detail/transactions screen.
                          TextButton.icon(
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => WalletDetailScreen(
                                  database: database,
                                  wallet: wallet,
                                ),
                              ),
                            ),
                            icon: const Icon(Icons.visibility),
                            label: const Text('View'),
                          ),
                          // EDIT button -> opens the update screen.
                          TextButton.icon(
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => EditWalletScreen(
                                  database: database,
                                  wallet: wallet,
                                ),
                              ),
                            ),
                            icon: const Icon(Icons.edit),
                            label: const Text('Edit'),
                          ),
                          // DELETE button -> removes the wallet.
                          TextButton.icon(
                            onPressed: () => database.deleteWallet(wallet.id),
                            icon: const Icon(Icons.delete, color: Colors.red),
                            label: const Text(
                              'Delete',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => AddWalletScreen(database: database),
          ),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}
