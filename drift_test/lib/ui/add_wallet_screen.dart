

import 'package:flutter/material.dart';

import 'package:drift_test/data/app_database.dart';

class AddWalletScreen extends StatefulWidget {
  const AddWalletScreen({super.key, required this.database});

  final AppDatabase database;

  @override
  State<AddWalletScreen> createState() => _AddWalletScreenState();
}

class _AddWalletScreenState extends State<AddWalletScreen> {
  // Controllers hold the text typed by the user.
  final _nameController = TextEditingController();
  final _balanceController = TextEditingController();

  @override
  void dispose() {
    // Always dispose controllers to avoid memory leaks.
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Wallet')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // -----------------------------------------------------------------
            // Name input
            // -----------------------------------------------------------------
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Wallet name',
                hintText: 'e.g. Cash, Bank, Savings',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // -----------------------------------------------------------------
            // Balance input
            // -----------------------------------------------------------------
            TextField(
              controller: _balanceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Starting balance',
                hintText: '0.00',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),

            // -----------------------------------------------------------------
            // Save button
            // -----------------------------------------------------------------
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _save,
                child: const Text('Save Wallet'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // INSERT: create a new wallet row
  // ---------------------------------------------------------------------------
  // `_save` parses the form values and calls `database.createWallet(...)`.
  // That method in turn calls `into(wallets).insert(WalletsCompanion(...))`.
  //
  // Because `WalletsScreen` is listening to `watchAllWallets()`, it will
  // automatically rebuild and show the new wallet without us sending any
  // extra events.
  Future<void> _save() async {
    final name = _nameController.text.trim();
    final balanceText = _balanceController.text.trim();

    if (name.isEmpty) return;

    final balance = double.tryParse(balanceText) ?? 0.0;

    // `await` waits for the database insert to finish.
    await widget.database.createWallet(name, balance);

    if (mounted) {
      // Pop back to the list. The list is already updating in the background
      // thanks to the Drift Stream.
      Navigator.of(context).pop();
    }
  }
}
