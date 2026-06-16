import 'package:flutter/material.dart';

class OnboardingData {
  final int pageNumber;
  final String title;
  final String description;
  final IconData icon;

  const OnboardingData({
    required this.pageNumber,
    required this.title,
    required this.description,
    required this.icon,
  });

  static const List<OnboardingData> pages = [
    OnboardingData(
      pageNumber: 1,
      title: 'تتبع مصروفاتك',
      description: 'سجل مصروفاتك اليومية بسهولة لتبقي على دراية بميزانيتك وقراراتك',
      icon: Icons.receipt_long_rounded,
    ),
    OnboardingData(
      pageNumber: 2,
      title: 'حلل مصاريفك بذكاء',
      description: 'شاهد توزيع مصاريفك على فئات مختلفة لتحسين ميزانيتك',
      icon: Icons.bar_chart_rounded,
    ),
    OnboardingData(
      pageNumber: 3,
      title: 'ادخر واستثمر بذكاء',
      description: 'حدد أهداف ادخار وخطط لمستقبلك المالي مع نصائح ذكية',
      icon: Icons.savings_rounded,
    ),
  ];
}
