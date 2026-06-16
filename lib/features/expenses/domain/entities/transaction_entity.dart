enum TransactionType {
  expense,
  income,
}
enum TransactionCategory {
  food,
  transport,
  entertainment,
  shopping,
  bills,
  salary,
  other,
}
class TransactionEntity {
  final int id;
  final String note;
  final TransactionType type;
  final double amount;
  final DateTime date;
  final TransactionCategory category;

  TransactionEntity({
    required this.id,
    required this.note,
    required this.amount,
    required this.date,
    required this.category,
    required this.type,
  });
}
