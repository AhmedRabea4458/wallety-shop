import 'package:intl/intl.dart';

enum OperationDateFilterType {
  all,
  today,
  yesterday,
  last7Days,
  custom,
}

class OperationDateFilter {
  final OperationDateFilterType type;
  final DateTime? customDate;

  const OperationDateFilter({
    this.type = OperationDateFilterType.all,
    this.customDate,
  });

  static const all = OperationDateFilter(type: OperationDateFilterType.all);
  static const today = OperationDateFilter(type: OperationDateFilterType.today);
  static const yesterday = OperationDateFilter(type: OperationDateFilterType.yesterday);
  static const last7Days = OperationDateFilter(type: OperationDateFilterType.last7Days);

  String get label {
    switch (type) {
      case OperationDateFilterType.all:
        return 'التاريخ: الكل';
      case OperationDateFilterType.today:
        return 'التاريخ: اليوم';
      case OperationDateFilterType.yesterday:
        return 'التاريخ: أمس';
      case OperationDateFilterType.last7Days:
        return 'التاريخ: آخر 7 أيام';
      case OperationDateFilterType.custom:
        if (customDate != null) {
          return 'التاريخ: ${DateFormat('yyyy/MM/dd', 'ar').format(customDate!)}';
        }
        return 'التاريخ: محدد';
    }
  }

  bool matches(DateTime createdAt) {
    final now = DateTime.now();
    final localCreated = createdAt.toLocal();

    switch (type) {
      case OperationDateFilterType.all:
        return true;
      case OperationDateFilterType.today:
        return localCreated.year == now.year &&
            localCreated.month == now.month &&
            localCreated.day == now.day;
      case OperationDateFilterType.yesterday:
        final yesterday = now.subtract(const Duration(days: 1));
        return localCreated.year == yesterday.year &&
            localCreated.month == yesterday.month &&
            localCreated.day == yesterday.day;
      case OperationDateFilterType.last7Days:
        final startOf7DaysAgo = DateTime(now.year, now.month, now.day - 6, 0, 0, 0);
        final endOfToday = DateTime(now.year, now.month, now.day, 23, 59, 59, 999, 999);
        return !localCreated.isBefore(startOf7DaysAgo) && !localCreated.isAfter(endOfToday);
      case OperationDateFilterType.custom:
        if (customDate == null) return true;
        return localCreated.year == customDate!.year &&
            localCreated.month == customDate!.month &&
            localCreated.day == customDate!.day;
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OperationDateFilter &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          (customDate == null && other.customDate == null ||
              customDate != null &&
                  other.customDate != null &&
                  customDate!.year == other.customDate!.year &&
                  customDate!.month == other.customDate!.month &&
                  customDate!.day == other.customDate!.day);

  @override
  int get hashCode => type.hashCode ^ (customDate?.day.hashCode ?? 0);
}
