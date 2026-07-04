enum DebtType {
  customerDebt,
  settlementDebt;

  String get value => this == customerDebt ? 'customerDebt' : 'settlementDebt';

  static DebtType fromString(String? value) {
    if (value == 'settlementDebt') return DebtType.settlementDebt;
    return DebtType.customerDebt;
  }

  String get label {
    switch (this) {
      case DebtType.customerDebt:
        return 'دين عميل';
      case DebtType.settlementDebt:
        return 'دين تسوية';
    }
  }
}
