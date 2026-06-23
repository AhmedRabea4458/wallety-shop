import 'package:smart_expense/core/errors/exceptions.dart';

class ErrorMapper {
  ErrorMapper._();

  static const String fallback = 'حدث خطأ غير متوقع، حاول مرة أخرى';

  static String map(Object error) {
    if (error is InsufficientBalanceException) return error.message;
    if (error is InsufficientCashDrawerBalanceException) return error.message;
    if (error is OperationLinkedToDebtException) return error.message;
    if (error is ActiveShiftExistsException) return error.message;
    if (error is MultipleActiveShiftsException) return error.toString();

    final name = error.runtimeType.toString().toLowerCase();

    if (name.contains('formatexception')) return 'الملف غير صالح، تأكد من اختيار نسخة احتياطية صحيحة';
    if (name.contains('sqliteexception')) return 'حدث خطأ في قاعدة البيانات';
    if (name.contains('filesystemexception')) return 'حدث خطأ في ملفات النظام';
    if (name.contains('pathexception')) return 'حدث خطأ في ملفات النظام';
    if (name.contains('missingpluginexception')) return 'حدث خطأ في النظام';
    if (name.contains('platformexception')) return 'حدث خطأ في النظام';
    if (name.contains('networkexception')) return 'فشل الاتصال';
    if (error is Exception && error.toString().contains('Arabic font')) {
      return error.toString();
    }

    return fallback;
  }
}
