import 'package:smart_expense/features/operations/domain/entities/debt_entity.dart';
import 'package:smart_expense/features/operations/domain/entities/debt_payment_entity.dart';
import 'package:smart_expense/features/operations/domain/entities/debt_type.dart';

/// Single item within a grouped payment breakdown.
class DebtPaymentBreakdownItem {
  final DebtPaymentEntity payment;
  final DebtEntity? debt;
  final String? debtorName;

  const DebtPaymentBreakdownItem({
    required this.payment,
    this.debt,
    this.debtorName,
  });

  int get debtId => payment.debtId;
  double get amount => payment.amount;
  String? get notes => payment.notes;
  String get paymentMethod => payment.paymentMethod;
  DateTime get createdAt => payment.createdAt;
  DebtType? get debtType => debt?.debtType;
}

/// Grouped debt payment representing a single payment action
/// that may have been distributed across one or multiple debts.
class GroupedDebtPayment {
  final DateTime createdAt;
  final String paymentMethod;
  final String? notes;
  final List<DebtPaymentBreakdownItem> items;

  const GroupedDebtPayment({
    required this.createdAt,
    required this.paymentMethod,
    this.notes,
    required this.items,
  });

  double get totalAmount => items.fold(0.0, (sum, item) => sum + item.amount);
  bool get isSingle => items.length <= 1;

  /// Returns single debtor name if all items belong to the same debtor, or combined names.
  String? get debtorNameSummary {
    final names =
        items
            .map((i) => i.debtorName)
            .where((n) => n != null && n.trim().isNotEmpty)
            .cast<String>()
            .toSet()
            .toList();
    if (names.isEmpty) return null;
    if (names.length == 1) return names.first;
    return names.join('، ');
  }

  /// Groups a list of debt payments into unified collection operations.
  /// Payments recorded within a short threshold (<= 3 seconds) with the same
  /// payment method and debt type are grouped together.
  static List<GroupedDebtPayment> groupPayments({
    required List<DebtPaymentEntity> payments,
    Map<int, DebtEntity>? debtsById,
    Map<int, String>? debtorNames,
  }) {
    if (payments.isEmpty) return [];

    final sorted = List<DebtPaymentEntity>.from(payments)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final List<GroupedDebtPayment> groups = [];
    List<DebtPaymentEntity> currentBatch = [];

    for (final payment in sorted) {
      if (currentBatch.isEmpty) {
        currentBatch.add(payment);
      } else {
        final last = currentBatch.last;
        final timeDiff =
            (last.createdAt.difference(payment.createdAt).inMilliseconds).abs();
        final isSameMethod = last.paymentMethod == payment.paymentMethod;

        final lastDebt = debtsById?[last.debtId];
        final currentDebt = debtsById?[payment.debtId];
        final isSameType =
            lastDebt == null ||
            currentDebt == null ||
            lastDebt.debtType == currentDebt.debtType;

        // Same bulk payment if within 3000ms, matching method and debt type
        if (timeDiff <= 3000 && isSameMethod && isSameType) {
          currentBatch.add(payment);
        } else {
          groups.add(_createGroup(currentBatch, debtsById, debtorNames));
          currentBatch = [payment];
        }
      }
    }

    if (currentBatch.isNotEmpty) {
      groups.add(_createGroup(currentBatch, debtsById, debtorNames));
    }

    return groups;
  }

  static GroupedDebtPayment _createGroup(
    List<DebtPaymentEntity> batch,
    Map<int, DebtEntity>? debtsById,
    Map<int, String>? debtorNames,
  ) {
    final first = batch.first;
    String? note = batch
        .map((p) => p.notes)
        .firstWhere(
          (n) => n != null && n.trim().isNotEmpty,
          orElse: () => null,
        );

    final items =
        batch.map((p) {
          final debt = debtsById?[p.debtId];
          final debtorName =
              (debt != null && debtorNames != null)
                  ? debtorNames[debt.debtorId]
                  : null;
          return DebtPaymentBreakdownItem(
            payment: p,
            debt: debt,
            debtorName: debtorName,
          );
        }).toList();

    return GroupedDebtPayment(
      createdAt: first.createdAt,
      paymentMethod: first.paymentMethod,
      notes: note,
      items: items,
    );
  }
}
