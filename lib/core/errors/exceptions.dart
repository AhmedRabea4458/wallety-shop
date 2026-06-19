class InsufficientBalanceException implements Exception {
  final String message;

  InsufficientBalanceException([this.message = 'رصيد المحفظة غير كافٍ']);

  @override
  String toString() => message;
}

class InsufficientCashDrawerBalanceException implements Exception {
  final String message;

  InsufficientCashDrawerBalanceException([this.message = 'رصيد الدرج النقدي غير كافٍ']);

  @override
  String toString() => message;
}

class MultipleActiveShiftsException implements Exception {
  final String message;
  final int count;

  MultipleActiveShiftsException(this.count, [this.message = 'يوجد أكثر من وردية نشطة']);

  @override
  String toString() => '$message (عددها: $count)';
}

class ActiveShiftExistsException implements Exception {
  final String message;

  ActiveShiftExistsException([this.message = 'يوجد وردية نشطة بالفعل. أغلقها أولاً قبل فتح وردية جديدة']);

  @override
  String toString() => message;
}

class OperationLinkedToDebtException implements Exception {
  final int operationId;
  final String message;

  OperationLinkedToDebtException(this.operationId, [this.message = 'لا يمكن تعديل أو حذف عملية مرتبطة بدين']);

  @override
  String toString() => '$message (العملية رقم: $operationId)';
}
