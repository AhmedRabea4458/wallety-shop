import 'package:flutter/material.dart';

import 'package:drift_test/data/app_database.dart';

class EditWalletScreen extends StatefulWidget {
  const EditWalletScreen({
    super.key,
    required this.database,
    required this.wallet,
  });

  final AppDatabase database;
  final Wallet wallet;

  @override
  State<EditWalletScreen> createState() => _EditWalletScreenState();
}

class _EditWalletScreenState extends State<EditWalletScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _balanceController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.wallet.name);
    _balanceController = TextEditingController(
      text: widget.wallet.balance.toStringAsFixed(2),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Wallet')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Wallet name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _balanceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Balance',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _update,
                child: const Text('Update Wallet'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _delete,
                icon: const Icon(Icons.delete, color: Colors.red),
                label: const Text(
                  'Delete Wallet',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _update() async {
    final name = _nameController.text.trim();
    final balanceText = _balanceController.text.trim();

    if (name.isEmpty) return;

    final balance = double.tryParse(balanceText) ?? 0.0;

    await widget.database.updateWallet(widget.wallet.id, name, balance);

    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _delete() async {
    // CASCADE deletes related transactions automatically.
    await widget.database.deleteWallet(widget.wallet.id);

    if (mounted) Navigator.of(context).pop();
  }
}
