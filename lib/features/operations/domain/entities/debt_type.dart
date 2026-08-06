enum DebtType {
  customerDebt,
  payable,
  settlementDebt;

  String get value {
    switch (this) {
      case DebtType.customerDebt:
        return 'customerDebt';
      case DebtType.payable:
        return 'payable';
      case DebtType.settlementDebt:
        return 'settlementDebt';
    }
  }

  static DebtType fromString(String? value) {
    if (value == 'payable') return DebtType.payable;
    if (value == 'settlementDebt') return DebtType.settlementDebt;
    return DebtType.customerDebt;
  }

  String get label {
    switch (this) {
      case DebtType.customerDebt:
        return 'آجل عميل';
      case DebtType.payable:
        return 'مستحق علي';
      case DebtType.settlementDebt:
        return 'دين تسوية';
    }
  }
}

