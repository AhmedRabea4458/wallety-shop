import 'package:smart_expense/core/database/app_database.dart';
import 'package:smart_expense/features/operations/domain/entities/shift_entity.dart';

class ShiftModel {
  final int id;
  final DateTime startTime;
  final DateTime? endTime;
  final double openingCashDrawer;
  final double? closingCashDrawer;
  final String? notes;
  final DateTime createdAt;

  const ShiftModel({
    required this.id,
    required this.startTime,
    this.endTime,
    required this.openingCashDrawer,
    this.closingCashDrawer,
    this.notes,
    required this.createdAt,
  });

  ShiftEntity toEntity() {
    return ShiftEntity(
      id: id,
      startTime: startTime,
      endTime: endTime,
      openingCashDrawer: openingCashDrawer,
      closingCashDrawer: closingCashDrawer,
      notes: notes,
      createdAt: createdAt,
    );
  }

  factory ShiftModel.fromDrift(ShiftsTableData data) {
    return ShiftModel(
      id: data.id,
      startTime: data.startTime,
      endTime: data.endTime,
      openingCashDrawer: data.openingCashDrawer,
      closingCashDrawer: data.closingCashDrawer,
      notes: data.notes,
      createdAt: data.createdAt,
    );
  }
}
