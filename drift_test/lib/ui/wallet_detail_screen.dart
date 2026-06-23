import 'package:flutter/material.dart';

import 'package:drift_test/data/app_database.dart';

class WalletDetailScreen extends StatelessWidget {
  const WalletDetailScreen({
    super.key,
    required this.database,
    required this.wallet,
  });

  final AppDatabase database;
  final Wallet wallet;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(wallet.name),
            Text(
              'Balance: \$${wallet.balance.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ),
          ],
        ),
      ),
      body: StreamBuilder<List<Transaction>>(
        // Relationship: watch only transactions for this wallet.
        stream: database.watchTransactionsForWallet(wallet.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final transactions = snapshot.data ?? [];

          if (transactions.isEmpty) {
            return const Center(
              child: Text('No transactions yet. Tap + to add one.'),
            );
          }

          return ListView.builder(
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final transaction = transactions[index];

              return ListTile(
                leading: Icon(
                  transaction.amount >= 0 ? Icons.arrow_downward : Icons.arrow_upward,
                  color: transaction.amount >= 0 ? Colors.green : Colors.red,
                ),
                title: Text(transaction.note),
                subtitle: Text(
                  transaction.createdAt.toLocal().toString(),
                  style: const TextStyle(fontSize: 12),
                ),
                trailing: Text(
                  '\$${transaction.amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: transaction.amount >= 0 ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onLongPress: () => database.deleteTransaction(transaction.id),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTransactionDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _showAddTransactionDialog(BuildContext context) async {
    final noteController = TextEditingController();
    final amountController = TextEditingController();

    final amount = await showDialog<double>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Transaction'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: noteController,
                decoration: const InputDecoration(
                  labelText: 'Note',
                  hintText: 'e.g. Groceries',
                ),
              ),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  hintText: 'Use negative for expense',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final value = double.tryParse(amountController.text.trim()) ?? 0.0;
                Navigator.of(context).pop(value);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (amount == null) return;

    final note = noteController.text.trim();
    if (note.isEmpty) return;

    await database.createTransaction(
      walletId: wallet.id,
      amount: amount,
      note: note,
    );
  }
}
