class DebtorEntity {
  final int id;
  final String name;
  final String? phone;
  final String? notes;
  final DateTime createdAt;

  const DebtorEntity({
    required this.id,
    required this.name,
    this.phone,
    this.notes,
    required this.createdAt,
  });
}