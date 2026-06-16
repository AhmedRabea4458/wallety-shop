import 'dart:ui';

class CategoryBreakdown {
  final String category;

  final double amount;

  final double percentage;
  final Color color;

  CategoryBreakdown({
    required this.category,
    required this.amount,
    required this.percentage,
    required this.color,
  });
}