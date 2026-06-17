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
