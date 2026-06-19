import 'package:smart_expense/core/database/app_database.dart';
import 'package:smart_expense/features/operations/domain/entities/debtor_entity.dart';

class DebtorModel {
  final int id;
  final String name;
  final String? phone;
  final String? notes;
  final DateTime createdAt;

  DebtorModel({
    required this.id,
    required this.name,
    this.phone,
    this.notes,
    required this.createdAt,
  });

  DebtorEntity toEntity() {
    return DebtorEntity(
      id: id,
      name: name,
      phone: phone,
      notes: notes,
      createdAt: createdAt,
    );
  }

  factory DebtorModel.fromEntity(DebtorEntity entity) {
    return DebtorModel(
      id: entity.id,
      name: entity.name,
      phone: entity.phone,
      notes: entity.notes,
      createdAt: entity.createdAt,
    );
  }

  factory DebtorModel.fromDrift(DebtorsTableData data) {
    return DebtorModel(
      id: data.id,
      name: data.name,
      phone: data.phone,
      notes: data.notes,
      createdAt: data.createdAt,
    );
  }

  DebtorModel copyWith({int? id}) {
    return DebtorModel(
      id: id ?? this.id,
      name: name,
      phone: phone,
      notes: notes,
      createdAt: createdAt,
    );
  }
}
