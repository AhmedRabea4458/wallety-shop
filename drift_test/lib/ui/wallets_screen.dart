import 'package:flutter/material.dart';

import 'package:drift_test/data/app_database.dart';

import 'add_wallet_screen.dart';
import 'edit_wallet_screen.dart';
import 'wallet_detail_screen.dart';

class WalletsScreen extends StatelessWidget {
  const WalletsScreen({super.key, required this.database});

  final AppDatabase database;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Wallets')),
      body: StreamBuilder<List<Wallet>>(
        // Reactive stream that updates automatically on DB changes.
        stream: database.watchAllWallets(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

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
              final wallet = wallets[index];

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        wallet.name,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Text('Balance: \$${wallet.balance.toStringAsFixed(2)}'),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
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
