class ShiftEntity {
  final int id;
  final DateTime startTime;
  final DateTime? endTime;
  final double openingCashDrawer;
  final double? closingCashDrawer;
  final String? notes;
  final DateTime createdAt;

  const ShiftEntity({
    required this.id,
    required this.startTime,
    this.endTime,
    required this.openingCashDrawer,
    this.closingCashDrawer,
    this.notes,
    required this.createdAt,
  });

  bool get isActive => endTime == null;
}
