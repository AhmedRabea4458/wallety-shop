class InsufficientBalanceException implements Exception {
  final String message;

  InsufficientBalanceException([this.message = 'رصيد المحفظة غير كافٍ']);

  @override
  String toString() => message;
}

class InsufficientInstaPayBalanceException implements Exception {
  final String message;

  InsufficientInstaPayBalanceException([this.message = 'رصيد حساب InstaPay غير كافٍ']);

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

  OperationLinkedToDebtException(this.operationId, [this.message = 'لا يمكن حذف عملية مرتبطة بدين عميل']);

  @override
  String toString() => '$message (العملية رقم: $operationId)';
}

class OperationHasPaidDebtException implements Exception {
  final int operationId;
  final String message;

  OperationHasPaidDebtException(this.operationId, [this.message = 'لا يمكن حذف هذه العملية لوجود دفعات مسجلة على الدين المرتبط بها. يرجى إلغاء الدفعات أولاً.']);

  @override
  String toString() => message;
}

class OperationLinkedToPayableException implements Exception {
  final int operationId;
  final String message;

  OperationLinkedToPayableException(this.operationId, [this.message = 'لا يمكن حذف عملية مرتبطة بمستحق تم سداده جزئياً أو كلياً.']);

  @override
  String toString() => message;
}
