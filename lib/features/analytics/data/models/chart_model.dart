// In analytics/data/models/chart_data.dart

class ChartDataPoint {
  final int monthIndex; // 0 = Jan, 1 = Feb
  final double value;
  final String label; // Arabic month name

  const ChartDataPoint({
    required this.monthIndex,
    required this.value,
    required this.label,
  });
}


