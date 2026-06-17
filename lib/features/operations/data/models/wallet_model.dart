import 'package:flutter/material.dart';
import 'package:smart_expense/core/database/app_database.dart';
import 'package:smart_expense/features/operations/domain/entities/wallet_entity.dart';

class WalletModel {
  final int id;
  final String name;
  final String? phoneNumber;
  final double balance;
  final Color color;
  final double dailyLimit;
  final double weeklyLimit;
  final double monthlyLimit;
  final DateTime createdAt;

  WalletModel({
    required this.id,
    required this.name,
    this.phoneNumber,
    required this.balance,
    required this.color,
    this.dailyLimit = 60000.0,
    this.weeklyLimit = 200000.0,
    this.monthlyLimit = 200000.0,
    required this.createdAt,
  });

  WalletEntity toEntity() {
    return WalletEntity(
      id: id,
      name: name,
      phoneNumber: phoneNumber,
      balance: balance,
      color: color,
      dailyLimit: dailyLimit,
      weeklyLimit: weeklyLimit,
      monthlyLimit: monthlyLimit,
      createdAt: createdAt,
    );
  }

  factory WalletModel.fromEntity(WalletEntity entity) {
    return WalletModel(
      id: entity.id,
      name: entity.name,
      phoneNumber: entity.phoneNumber,
      balance: entity.balance,
      color: entity.color,
      dailyLimit: entity.dailyLimit,
      weeklyLimit: entity.weeklyLimit,
      monthlyLimit: entity.monthlyLimit,
      createdAt: entity.createdAt,
    );
  }

  factory WalletModel.fromDrift(WalletsTableData data) {
    return WalletModel(
      id: data.id,
      name: data.name,
      phoneNumber: data.phoneNumber,
      balance: data.balance,
      color: _colorFromHex(data.color),
      dailyLimit: data.dailyLimit,
      weeklyLimit: data.weeklyLimit,
      monthlyLimit: data.monthlyLimit,
      createdAt: data.createdAt,
    );
  }

  static Color _colorFromHex(String hex) {
    try {
      final buffer = StringBuffer();
      if (hex.length == 6 || hex.length == 7) buffer.write('ff');
      buffer.write(hex.replaceFirst('#', ''));
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (e) {
      return const Color(0xFF6366F1);
    }
  }

  static String colorToHex(Color color) {
    return '#${color.value.toRadixString(16).padLeft(8, '0').substring(2)}';
  }
}
