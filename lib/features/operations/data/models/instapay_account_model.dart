import 'package:smart_expense/core/database/app_database.dart';
import 'package:smart_expense/features/operations/domain/entities/instapay_account_entity.dart';

class InstaPayAccountModel {
  final int id;
  final String name;
  final DateTime createdAt;

  InstaPayAccountModel({
    required this.id,
    required this.name,
    required this.createdAt,
  });

  InstaPayAccountEntity toEntity() {
    return InstaPayAccountEntity(
      id: id,
      name: name,
      createdAt: createdAt,
    );
  }

  factory InstaPayAccountModel.fromDrift(InstaPayAccountsTableData data) {
    return InstaPayAccountModel(
      id: data.id,
      name: data.name,
      createdAt: data.createdAt,
    );
  }
}
