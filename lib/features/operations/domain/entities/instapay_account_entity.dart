class InstaPayAccountEntity {
  final int id;
  final String name;
  final double balance;
  final DateTime createdAt;

  const InstaPayAccountEntity({
    required this.id,
    required this.name,
    this.balance = 0.0,
    required this.createdAt,
  });
}
