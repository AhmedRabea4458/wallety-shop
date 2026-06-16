import 'package:flutter/material.dart';
import 'package:smart_expense/core/theme/app_colors.dart';
import 'package:smart_expense/features/expenses/domain/entities/transaction_entity.dart';

class CategoryColors {
  // ── Brand-Aligned Category Palette ──
  static const Color food = Color(0xFF8B5CF6);        // violet 500
  static const Color transport = Color(0xFF3B82F6);   // blue 500
  static const Color bills = Color(0xFFF59E0B);       // amber 500 (warning)
  static const Color entertainment = Color(0xFFF97316); // orange 500
  static const Color shopping = AppColors.primary;      // cyan 500
  static const Color salary = AppColors.success;        // green 500
  static const Color other = AppColors.mutedForeground; // slate 500
  static const Color health = AppColors.destructive;    // red 500

  static Color getColor(String category) {
    switch (category) {
      case 'طعام':
      case 'food':
        return food;
      case 'مواصلات':
      case 'transport':
        return transport;
      case 'فواتير':
      case 'bills':
        return bills;
      case 'تسوق':
      case 'shopping':
        return shopping;
      case 'ترفيه':
      case 'entertainment':
        return entertainment;
      case 'راتب':
      case 'salary':
        return salary;
      case 'أخرى':
      case 'other':
        return other;
      default:
        return Colors.grey;
    }
  }

  static Color getColorForEnum(TransactionCategory category) {
    switch (category) {
      case TransactionCategory.food:
        return food;
      case TransactionCategory.transport:
        return transport;
      case TransactionCategory.bills:
        return bills;
      case TransactionCategory.entertainment:
        return entertainment;
      case TransactionCategory.shopping:
        return shopping;
      case TransactionCategory.salary:
        return salary;
      case TransactionCategory.other:
        return other;
    }
  }

  static String getLabel(String category) {
    switch (category) {
      case 'food':
        return 'طعام';
      case 'transport':
        return 'مواصلات';
      case 'bills':
        return 'فواتير';
      case 'entertainment':
        return 'ترفيه';
      case 'shopping':
        return 'تسوق';
      case 'salary':
        return 'راتب';
      case 'other':
        return 'أخرى';
      default:
        return category;
    }
  }
}
