import 'package:flutter/material.dart';

class WalletEntity {
  final int id;
  final String name;
  final String? phoneNumber;
  final double balance;
  final Color color;
  final double dailyLimit;
  final double weeklyLimit;
  final double monthlyLimit;
  final DateTime createdAt;

  WalletEntity({
    required this.id,
    required this.name,
    this.phoneNumber,
    required this.balance,
    this.color = const Color(0xFF6366F1),
    this.dailyLimit = 60000.0,
    this.weeklyLimit = 200000.0,
    this.monthlyLimit = 200000.0,
    required this.createdAt,
  });
}
