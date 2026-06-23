// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $TransactionsTableTable extends TransactionsTable
    with TableInfo<$TransactionsTableTable, TransactionsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransactionsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    note,
    amount,
    date,
    category,
    type,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transactions_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<TransactionsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    } else if (isInserting) {
      context.missing(_noteMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TransactionsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TransactionsTableData(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      note:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}note'],
          )!,
      amount:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}amount'],
          )!,
      date:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}date'],
          )!,
      category:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}category'],
          )!,
      type:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}type'],
          )!,
    );
  }

  @override
  $TransactionsTableTable createAlias(String alias) {
    return $TransactionsTableTable(attachedDatabase, alias);
  }
}

class TransactionsTableData extends DataClass
    implements Insertable<TransactionsTableData> {
  final int id;
  final String note;
  final double amount;
  final DateTime date;
  final String category;
  final String type;
  const TransactionsTableData({
    required this.id,
    required this.note,
    required this.amount,
    required this.date,
    required this.category,
    required this.type,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['note'] = Variable<String>(note);
    map['amount'] = Variable<double>(amount);
    map['date'] = Variable<DateTime>(date);
    map['category'] = Variable<String>(category);
    map['type'] = Variable<String>(type);
    return map;
  }

  TransactionsTableCompanion toCompanion(bool nullToAbsent) {
    return TransactionsTableCompanion(
      id: Value(id),
      note: Value(note),
      amount: Value(amount),
      date: Value(date),
      category: Value(category),
      type: Value(type),
    );
  }

  factory TransactionsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TransactionsTableData(
      id: serializer.fromJson<int>(json['id']),
      note: serializer.fromJson<String>(json['note']),
      amount: serializer.fromJson<double>(json['amount']),
      date: serializer.fromJson<DateTime>(json['date']),
      category: serializer.fromJson<String>(json['category']),
      type: serializer.fromJson<String>(json['type']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'note': serializer.toJson<String>(note),
      'amount': serializer.toJson<double>(amount),
      'date': serializer.toJson<DateTime>(date),
      'category': serializer.toJson<String>(category),
      'type': serializer.toJson<String>(type),
    };
  }

  TransactionsTableData copyWith({
    int? id,
    String? note,
    double? amount,
    DateTime? date,
    String? category,
    String? type,
  }) => TransactionsTableData(
    id: id ?? this.id,
    note: note ?? this.note,
    amount: amount ?? this.amount,
    date: date ?? this.date,
    category: category ?? this.category,
    type: type ?? this.type,
  );
  TransactionsTableData copyWithCompanion(TransactionsTableCompanion data) {
    return TransactionsTableData(
      id: data.id.present ? data.id.value : this.id,
      note: data.note.present ? data.note.value : this.note,
      amount: data.amount.present ? data.amount.value : this.amount,
      date: data.date.present ? data.date.value : this.date,
      category: data.category.present ? data.category.value : this.category,
      type: data.type.present ? data.type.value : this.type,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TransactionsTableData(')
          ..write('id: $id, ')
          ..write('note: $note, ')
          ..write('amount: $amount, ')
          ..write('date: $date, ')
          ..write('category: $category, ')
          ..write('type: $type')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, note, amount, date, category, type);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TransactionsTableData &&
          other.id == this.id &&
          other.note == this.note &&
          other.amount == this.amount &&
          other.date == this.date &&
          other.category == this.category &&
          other.type == this.type);
}

class TransactionsTableCompanion
    extends UpdateCompanion<TransactionsTableData> {
  final Value<int> id;
  final Value<String> note;
  final Value<double> amount;
  final Value<DateTime> date;
  final Value<String> category;
  final Value<String> type;
  const TransactionsTableCompanion({
    this.id = const Value.absent(),
    this.note = const Value.absent(),
    this.amount = const Value.absent(),
    this.date = const Value.absent(),
    this.category = const Value.absent(),
    this.type = const Value.absent(),
  });
  TransactionsTableCompanion.insert({
    this.id = const Value.absent(),
    required String note,
    required double amount,
    required DateTime date,
    required String category,
    required String type,
  }) : note = Value(note),
       amount = Value(amount),
       date = Value(date),
       category = Value(category),
       type = Value(type);
  static Insertable<TransactionsTableData> custom({
    Expression<int>? id,
    Expression<String>? note,
    Expression<double>? amount,
    Expression<DateTime>? date,
    Expression<String>? category,
    Expression<String>? type,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (note != null) 'note': note,
      if (amount != null) 'amount': amount,
      if (date != null) 'date': date,
      if (category != null) 'category': category,
      if (type != null) 'type': type,
    });
  }

  TransactionsTableCompanion copyWith({
    Value<int>? id,
    Value<String>? note,
    Value<double>? amount,
    Value<DateTime>? date,
    Value<String>? category,
    Value<String>? type,
  }) {
    return TransactionsTableCompanion(
      id: id ?? this.id,
      note: note ?? this.note,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      category: category ?? this.category,
      type: type ?? this.type,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransactionsTableCompanion(')
          ..write('id: $id, ')
          ..write('note: $note, ')
          ..write('amount: $amount, ')
          ..write('date: $date, ')
          ..write('category: $category, ')
          ..write('type: $type')
          ..write(')'))
        .toString();
  }
}

class $WalletsTableTable extends WalletsTable
    with TableInfo<$WalletsTableTable, WalletsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WalletsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _phoneNumberMeta = const VerificationMeta(
    'phoneNumber',
  );
  @override
  late final GeneratedColumn<String> phoneNumber = GeneratedColumn<String>(
    'phone_number',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _balanceMeta = const VerificationMeta(
    'balance',
  );
  @override
  late final GeneratedColumn<double> balance = GeneratedColumn<double>(
    'balance',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
    'color',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('#6366F1'),
  );
  static const VerificationMeta _dailyLimitMeta = const VerificationMeta(
    'dailyLimit',
  );
  @override
  late final GeneratedColumn<double> dailyLimit = GeneratedColumn<double>(
    'daily_limit',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(60000.0),
  );
  static const VerificationMeta _weeklyLimitMeta = const VerificationMeta(
    'weeklyLimit',
  );
  @override
  late final GeneratedColumn<double> weeklyLimit = GeneratedColumn<double>(
    'weekly_limit',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(200000.0),
  );
  static const VerificationMeta _monthlyLimitMeta = const VerificationMeta(
    'monthlyLimit',
  );
  @override
  late final GeneratedColumn<double> monthlyLimit = GeneratedColumn<double>(
    'monthly_limit',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(200000.0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    phoneNumber,
    balance,
    color,
    dailyLimit,
    weeklyLimit,
    monthlyLimit,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'wallets_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<WalletsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('phone_number')) {
      context.handle(
        _phoneNumberMeta,
        phoneNumber.isAcceptableOrUnknown(
          data['phone_number']!,
          _phoneNumberMeta,
        ),
      );
    }
    if (data.containsKey('balance')) {
      context.handle(
        _balanceMeta,
        balance.isAcceptableOrUnknown(data['balance']!, _balanceMeta),
      );
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    }
    if (data.containsKey('daily_limit')) {
      context.handle(
        _dailyLimitMeta,
        dailyLimit.isAcceptableOrUnknown(data['daily_limit']!, _dailyLimitMeta),
      );
    }
    if (data.containsKey('weekly_limit')) {
      context.handle(
        _weeklyLimitMeta,
        weeklyLimit.isAcceptableOrUnknown(
          data['weekly_limit']!,
          _weeklyLimitMeta,
        ),
      );
    }
    if (data.containsKey('monthly_limit')) {
      context.handle(
        _monthlyLimitMeta,
        monthlyLimit.isAcceptableOrUnknown(
          data['monthly_limit']!,
          _monthlyLimitMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WalletsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WalletsTableData(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      name:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}name'],
          )!,
      phoneNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone_number'],
      ),
      balance:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}balance'],
          )!,
      color:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}color'],
          )!,
      dailyLimit:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}daily_limit'],
          )!,
      weeklyLimit:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}weekly_limit'],
          )!,
      monthlyLimit:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}monthly_limit'],
          )!,
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}created_at'],
          )!,
    );
  }

  @override
  $WalletsTableTable createAlias(String alias) {
    return $WalletsTableTable(attachedDatabase, alias);
  }
}

class WalletsTableData extends DataClass
    implements Insertable<WalletsTableData> {
  final int id;
  final String name;
  final String? phoneNumber;
  final double balance;
  final String color;
  final double dailyLimit;
  final double weeklyLimit;
  final double monthlyLimit;
  final DateTime createdAt;
  const WalletsTableData({
    required this.id,
    required this.name,
    this.phoneNumber,
    required this.balance,
    required this.color,
    required this.dailyLimit,
    required this.weeklyLimit,
    required this.monthlyLimit,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || phoneNumber != null) {
      map['phone_number'] = Variable<String>(phoneNumber);
    }
    map['balance'] = Variable<double>(balance);
    map['color'] = Variable<String>(color);
    map['daily_limit'] = Variable<double>(dailyLimit);
    map['weekly_limit'] = Variable<double>(weeklyLimit);
    map['monthly_limit'] = Variable<double>(monthlyLimit);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  WalletsTableCompanion toCompanion(bool nullToAbsent) {
    return WalletsTableCompanion(
      id: Value(id),
      name: Value(name),
      phoneNumber:
          phoneNumber == null && nullToAbsent
              ? const Value.absent()
              : Value(phoneNumber),
      balance: Value(balance),
      color: Value(color),
      dailyLimit: Value(dailyLimit),
      weeklyLimit: Value(weeklyLimit),
      monthlyLimit: Value(monthlyLimit),
      createdAt: Value(createdAt),
    );
  }

  factory WalletsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WalletsTableData(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      phoneNumber: serializer.fromJson<String?>(json['phoneNumber']),
      balance: serializer.fromJson<double>(json['balance']),
      color: serializer.fromJson<String>(json['color']),
      dailyLimit: serializer.fromJson<double>(json['dailyLimit']),
      weeklyLimit: serializer.fromJson<double>(json['weeklyLimit']),
      monthlyLimit: serializer.fromJson<double>(json['monthlyLimit']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'phoneNumber': serializer.toJson<String?>(phoneNumber),
      'balance': serializer.toJson<double>(balance),
      'color': serializer.toJson<String>(color),
      'dailyLimit': serializer.toJson<double>(dailyLimit),
      'weeklyLimit': serializer.toJson<double>(weeklyLimit),
      'monthlyLimit': serializer.toJson<double>(monthlyLimit),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  WalletsTableData copyWith({
    int? id,
    String? name,
    Value<String?> phoneNumber = const Value.absent(),
    double? balance,
    String? color,
    double? dailyLimit,
    double? weeklyLimit,
    double? monthlyLimit,
    DateTime? createdAt,
  }) => WalletsTableData(
    id: id ?? this.id,
    name: name ?? this.name,
    phoneNumber: phoneNumber.present ? phoneNumber.value : this.phoneNumber,
    balance: balance ?? this.balance,
    color: color ?? this.color,
    dailyLimit: dailyLimit ?? this.dailyLimit,
    weeklyLimit: weeklyLimit ?? this.weeklyLimit,
    monthlyLimit: monthlyLimit ?? this.monthlyLimit,
    createdAt: createdAt ?? this.createdAt,
  );
  WalletsTableData copyWithCompanion(WalletsTableCompanion data) {
    return WalletsTableData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      phoneNumber:
          data.phoneNumber.present ? data.phoneNumber.value : this.phoneNumber,
      balance: data.balance.present ? data.balance.value : this.balance,
      color: data.color.present ? data.color.value : this.color,
      dailyLimit:
          data.dailyLimit.present ? data.dailyLimit.value : this.dailyLimit,
      weeklyLimit:
          data.weeklyLimit.present ? data.weeklyLimit.value : this.weeklyLimit,
      monthlyLimit:
          data.monthlyLimit.present
              ? data.monthlyLimit.value
              : this.monthlyLimit,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WalletsTableData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('phoneNumber: $phoneNumber, ')
          ..write('balance: $balance, ')
          ..write('color: $color, ')
          ..write('dailyLimit: $dailyLimit, ')
          ..write('weeklyLimit: $weeklyLimit, ')
          ..write('monthlyLimit: $monthlyLimit, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    phoneNumber,
    balance,
    color,
    dailyLimit,
    weeklyLimit,
    monthlyLimit,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WalletsTableData &&
          other.id == this.id &&
          other.name == this.name &&
          other.phoneNumber == this.phoneNumber &&
          other.balance == this.balance &&
          other.color == this.color &&
          other.dailyLimit == this.dailyLimit &&
          other.weeklyLimit == this.weeklyLimit &&
          other.monthlyLimit == this.monthlyLimit &&
          other.createdAt == this.createdAt);
}

class WalletsTableCompanion extends UpdateCompanion<WalletsTableData> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> phoneNumber;
  final Value<double> balance;
  final Value<String> color;
  final Value<double> dailyLimit;
  final Value<double> weeklyLimit;
  final Value<double> monthlyLimit;
  final Value<DateTime> createdAt;
  const WalletsTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.phoneNumber = const Value.absent(),
    this.balance = const Value.absent(),
    this.color = const Value.absent(),
    this.dailyLimit = const Value.absent(),
    this.weeklyLimit = const Value.absent(),
    this.monthlyLimit = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  WalletsTableCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.phoneNumber = const Value.absent(),
    this.balance = const Value.absent(),
    this.color = const Value.absent(),
    this.dailyLimit = const Value.absent(),
    this.weeklyLimit = const Value.absent(),
    this.monthlyLimit = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : name = Value(name);
  static Insertable<WalletsTableData> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? phoneNumber,
    Expression<double>? balance,
    Expression<String>? color,
    Expression<double>? dailyLimit,
    Expression<double>? weeklyLimit,
    Expression<double>? monthlyLimit,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (phoneNumber != null) 'phone_number': phoneNumber,
      if (balance != null) 'balance': balance,
      if (color != null) 'color': color,
      if (dailyLimit != null) 'daily_limit': dailyLimit,
      if (weeklyLimit != null) 'weekly_limit': weeklyLimit,
      if (monthlyLimit != null) 'monthly_limit': monthlyLimit,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  WalletsTableCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String?>? phoneNumber,
    Value<double>? balance,
    Value<String>? color,
    Value<double>? dailyLimit,
    Value<double>? weeklyLimit,
    Value<double>? monthlyLimit,
    Value<DateTime>? createdAt,
  }) {
    return WalletsTableCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      balance: balance ?? this.balance,
      color: color ?? this.color,
      dailyLimit: dailyLimit ?? this.dailyLimit,
      weeklyLimit: weeklyLimit ?? this.weeklyLimit,
      monthlyLimit: monthlyLimit ?? this.monthlyLimit,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (phoneNumber.present) {
      map['phone_number'] = Variable<String>(phoneNumber.value);
    }
    if (balance.present) {
      map['balance'] = Variable<double>(balance.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (dailyLimit.present) {
      map['daily_limit'] = Variable<double>(dailyLimit.value);
    }
    if (weeklyLimit.present) {
      map['weekly_limit'] = Variable<double>(weeklyLimit.value);
    }
    if (monthlyLimit.present) {
      map['monthly_limit'] = Variable<double>(monthlyLimit.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WalletsTableCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('phoneNumber: $phoneNumber, ')
          ..write('balance: $balance, ')
          ..write('color: $color, ')
          ..write('dailyLimit: $dailyLimit, ')
          ..write('weeklyLimit: $weeklyLimit, ')
          ..write('monthlyLimit: $monthlyLimit, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $OperationsTableTable extends OperationsTable
    with TableInfo<$OperationsTableTable, OperationsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OperationsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _walletIdMeta = const VerificationMeta(
    'walletId',
  );
  @override
  late final GeneratedColumn<int> walletId = GeneratedColumn<int>(
    'wallet_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES wallets_table (id)',
    ),
  );
  static const VerificationMeta _shiftIdMeta = const VerificationMeta(
    'shiftId',
  );
  @override
  late final GeneratedColumn<int> shiftId = GeneratedColumn<int>(
    'shift_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _operationTypeMeta = const VerificationMeta(
    'operationType',
  );
  @override
  late final GeneratedColumn<String> operationType = GeneratedColumn<String>(
    'operation_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('deposit'),
  );
  static const VerificationMeta _providerTypeMeta = const VerificationMeta(
    'providerType',
  );
  @override
  late final GeneratedColumn<String> providerType = GeneratedColumn<String>(
    'provider_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('vodafoneCash'),
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _commissionMeta = const VerificationMeta(
    'commission',
  );
  @override
  late final GeneratedColumn<double> commission = GeneratedColumn<double>(
    'commission',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _networkFeeMeta = const VerificationMeta(
    'networkFee',
  );
  @override
  late final GeneratedColumn<double> networkFee = GeneratedColumn<double>(
    'network_fee',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _phoneNumberMeta = const VerificationMeta(
    'phoneNumber',
  );
  @override
  late final GeneratedColumn<String> phoneNumber = GeneratedColumn<String>(
    'phone_number',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isDebtMeta = const VerificationMeta('isDebt');
  @override
  late final GeneratedColumn<bool> isDebt = GeneratedColumn<bool>(
    'is_debt',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_debt" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _instaPayAccountIdMeta = const VerificationMeta(
    'instaPayAccountId',
  );
  @override
  late final GeneratedColumn<int> instaPayAccountId = GeneratedColumn<int>(
    'insta_pay_account_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    walletId,
    shiftId,
    operationType,
    providerType,
    amount,
    commission,
    networkFee,
    phoneNumber,
    notes,
    isDebt,
    instaPayAccountId,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'operations_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<OperationsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('wallet_id')) {
      context.handle(
        _walletIdMeta,
        walletId.isAcceptableOrUnknown(data['wallet_id']!, _walletIdMeta),
      );
    } else if (isInserting) {
      context.missing(_walletIdMeta);
    }
    if (data.containsKey('shift_id')) {
      context.handle(
        _shiftIdMeta,
        shiftId.isAcceptableOrUnknown(data['shift_id']!, _shiftIdMeta),
      );
    }
    if (data.containsKey('operation_type')) {
      context.handle(
        _operationTypeMeta,
        operationType.isAcceptableOrUnknown(
          data['operation_type']!,
          _operationTypeMeta,
        ),
      );
    }
    if (data.containsKey('provider_type')) {
      context.handle(
        _providerTypeMeta,
        providerType.isAcceptableOrUnknown(
          data['provider_type']!,
          _providerTypeMeta,
        ),
      );
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('commission')) {
      context.handle(
        _commissionMeta,
        commission.isAcceptableOrUnknown(data['commission']!, _commissionMeta),
      );
    }
    if (data.containsKey('network_fee')) {
      context.handle(
        _networkFeeMeta,
        networkFee.isAcceptableOrUnknown(data['network_fee']!, _networkFeeMeta),
      );
    }
    if (data.containsKey('phone_number')) {
      context.handle(
        _phoneNumberMeta,
        phoneNumber.isAcceptableOrUnknown(
          data['phone_number']!,
          _phoneNumberMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('is_debt')) {
      context.handle(
        _isDebtMeta,
        isDebt.isAcceptableOrUnknown(data['is_debt']!, _isDebtMeta),
      );
    }
    if (data.containsKey('insta_pay_account_id')) {
      context.handle(
        _instaPayAccountIdMeta,
        instaPayAccountId.isAcceptableOrUnknown(
          data['insta_pay_account_id']!,
          _instaPayAccountIdMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OperationsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OperationsTableData(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      walletId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}wallet_id'],
          )!,
      shiftId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}shift_id'],
      ),
      operationType:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}operation_type'],
          )!,
      providerType:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}provider_type'],
          )!,
      amount:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}amount'],
          )!,
      commission:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}commission'],
          )!,
      networkFee:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}network_fee'],
          )!,
      phoneNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone_number'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      isDebt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}is_debt'],
          )!,
      instaPayAccountId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}insta_pay_account_id'],
      ),
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}created_at'],
          )!,
    );
  }

  @override
  $OperationsTableTable createAlias(String alias) {
    return $OperationsTableTable(attachedDatabase, alias);
  }
}

class OperationsTableData extends DataClass
    implements Insertable<OperationsTableData> {
  final int id;
  final int walletId;
  final int? shiftId;
  final String operationType;
  final String providerType;
  final double amount;
  final double commission;
  final double networkFee;
  final String? phoneNumber;
  final String? notes;
  final bool isDebt;
  final int? instaPayAccountId;
  final DateTime createdAt;
  const OperationsTableData({
    required this.id,
    required this.walletId,
    this.shiftId,
    required this.operationType,
    required this.providerType,
    required this.amount,
    required this.commission,
    required this.networkFee,
    this.phoneNumber,
    this.notes,
    required this.isDebt,
    this.instaPayAccountId,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['wallet_id'] = Variable<int>(walletId);
    if (!nullToAbsent || shiftId != null) {
      map['shift_id'] = Variable<int>(shiftId);
    }
    map['operation_type'] = Variable<String>(operationType);
    map['provider_type'] = Variable<String>(providerType);
    map['amount'] = Variable<double>(amount);
    map['commission'] = Variable<double>(commission);
    map['network_fee'] = Variable<double>(networkFee);
    if (!nullToAbsent || phoneNumber != null) {
      map['phone_number'] = Variable<String>(phoneNumber);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['is_debt'] = Variable<bool>(isDebt);
    if (!nullToAbsent || instaPayAccountId != null) {
      map['insta_pay_account_id'] = Variable<int>(instaPayAccountId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  OperationsTableCompanion toCompanion(bool nullToAbsent) {
    return OperationsTableCompanion(
      id: Value(id),
      walletId: Value(walletId),
      shiftId:
          shiftId == null && nullToAbsent
              ? const Value.absent()
              : Value(shiftId),
      operationType: Value(operationType),
      providerType: Value(providerType),
      amount: Value(amount),
      commission: Value(commission),
      networkFee: Value(networkFee),
      phoneNumber:
          phoneNumber == null && nullToAbsent
              ? const Value.absent()
              : Value(phoneNumber),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      isDebt: Value(isDebt),
      instaPayAccountId:
          instaPayAccountId == null && nullToAbsent
              ? const Value.absent()
              : Value(instaPayAccountId),
      createdAt: Value(createdAt),
    );
  }

  factory OperationsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OperationsTableData(
      id: serializer.fromJson<int>(json['id']),
      walletId: serializer.fromJson<int>(json['walletId']),
      shiftId: serializer.fromJson<int?>(json['shiftId']),
      operationType: serializer.fromJson<String>(json['operationType']),
      providerType: serializer.fromJson<String>(json['providerType']),
      amount: serializer.fromJson<double>(json['amount']),
      commission: serializer.fromJson<double>(json['commission']),
      networkFee: serializer.fromJson<double>(json['networkFee']),
      phoneNumber: serializer.fromJson<String?>(json['phoneNumber']),
      notes: serializer.fromJson<String?>(json['notes']),
      isDebt: serializer.fromJson<bool>(json['isDebt']),
      instaPayAccountId: serializer.fromJson<int?>(json['instaPayAccountId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'walletId': serializer.toJson<int>(walletId),
      'shiftId': serializer.toJson<int?>(shiftId),
      'operationType': serializer.toJson<String>(operationType),
      'providerType': serializer.toJson<String>(providerType),
      'amount': serializer.toJson<double>(amount),
      'commission': serializer.toJson<double>(commission),
      'networkFee': serializer.toJson<double>(networkFee),
      'phoneNumber': serializer.toJson<String?>(phoneNumber),
      'notes': serializer.toJson<String?>(notes),
      'isDebt': serializer.toJson<bool>(isDebt),
      'instaPayAccountId': serializer.toJson<int?>(instaPayAccountId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  OperationsTableData copyWith({
    int? id,
    int? walletId,
    Value<int?> shiftId = const Value.absent(),
    String? operationType,
    String? providerType,
    double? amount,
    double? commission,
    double? networkFee,
    Value<String?> phoneNumber = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    bool? isDebt,
    Value<int?> instaPayAccountId = const Value.absent(),
    DateTime? createdAt,
  }) => OperationsTableData(
    id: id ?? this.id,
    walletId: walletId ?? this.walletId,
    shiftId: shiftId.present ? shiftId.value : this.shiftId,
    operationType: operationType ?? this.operationType,
    providerType: providerType ?? this.providerType,
    amount: amount ?? this.amount,
    commission: commission ?? this.commission,
    networkFee: networkFee ?? this.networkFee,
    phoneNumber: phoneNumber.present ? phoneNumber.value : this.phoneNumber,
    notes: notes.present ? notes.value : this.notes,
    isDebt: isDebt ?? this.isDebt,
    instaPayAccountId:
        instaPayAccountId.present
            ? instaPayAccountId.value
            : this.instaPayAccountId,
    createdAt: createdAt ?? this.createdAt,
  );
  OperationsTableData copyWithCompanion(OperationsTableCompanion data) {
    return OperationsTableData(
      id: data.id.present ? data.id.value : this.id,
      walletId: data.walletId.present ? data.walletId.value : this.walletId,
      shiftId: data.shiftId.present ? data.shiftId.value : this.shiftId,
      operationType:
          data.operationType.present
              ? data.operationType.value
              : this.operationType,
      providerType:
          data.providerType.present
              ? data.providerType.value
              : this.providerType,
      amount: data.amount.present ? data.amount.value : this.amount,
      commission:
          data.commission.present ? data.commission.value : this.commission,
      networkFee:
          data.networkFee.present ? data.networkFee.value : this.networkFee,
      phoneNumber:
          data.phoneNumber.present ? data.phoneNumber.value : this.phoneNumber,
      notes: data.notes.present ? data.notes.value : this.notes,
      isDebt: data.isDebt.present ? data.isDebt.value : this.isDebt,
      instaPayAccountId:
          data.instaPayAccountId.present
              ? data.instaPayAccountId.value
              : this.instaPayAccountId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OperationsTableData(')
          ..write('id: $id, ')
          ..write('walletId: $walletId, ')
          ..write('shiftId: $shiftId, ')
          ..write('operationType: $operationType, ')
          ..write('providerType: $providerType, ')
          ..write('amount: $amount, ')
          ..write('commission: $commission, ')
          ..write('networkFee: $networkFee, ')
          ..write('phoneNumber: $phoneNumber, ')
          ..write('notes: $notes, ')
          ..write('isDebt: $isDebt, ')
          ..write('instaPayAccountId: $instaPayAccountId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    walletId,
    shiftId,
    operationType,
    providerType,
    amount,
    commission,
    networkFee,
    phoneNumber,
    notes,
    isDebt,
    instaPayAccountId,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OperationsTableData &&
          other.id == this.id &&
          other.walletId == this.walletId &&
          other.shiftId == this.shiftId &&
          other.operationType == this.operationType &&
          other.providerType == this.providerType &&
          other.amount == this.amount &&
          other.commission == this.commission &&
          other.networkFee == this.networkFee &&
          other.phoneNumber == this.phoneNumber &&
          other.notes == this.notes &&
          other.isDebt == this.isDebt &&
          other.instaPayAccountId == this.instaPayAccountId &&
          other.createdAt == this.createdAt);
}

class OperationsTableCompanion extends UpdateCompanion<OperationsTableData> {
  final Value<int> id;
  final Value<int> walletId;
  final Value<int?> shiftId;
  final Value<String> operationType;
  final Value<String> providerType;
  final Value<double> amount;
  final Value<double> commission;
  final Value<double> networkFee;
  final Value<String?> phoneNumber;
  final Value<String?> notes;
  final Value<bool> isDebt;
  final Value<int?> instaPayAccountId;
  final Value<DateTime> createdAt;
  const OperationsTableCompanion({
    this.id = const Value.absent(),
    this.walletId = const Value.absent(),
    this.shiftId = const Value.absent(),
    this.operationType = const Value.absent(),
    this.providerType = const Value.absent(),
    this.amount = const Value.absent(),
    this.commission = const Value.absent(),
    this.networkFee = const Value.absent(),
    this.phoneNumber = const Value.absent(),
    this.notes = const Value.absent(),
    this.isDebt = const Value.absent(),
    this.instaPayAccountId = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  OperationsTableCompanion.insert({
    this.id = const Value.absent(),
    required int walletId,
    this.shiftId = const Value.absent(),
    this.operationType = const Value.absent(),
    this.providerType = const Value.absent(),
    required double amount,
    this.commission = const Value.absent(),
    this.networkFee = const Value.absent(),
    this.phoneNumber = const Value.absent(),
    this.notes = const Value.absent(),
    this.isDebt = const Value.absent(),
    this.instaPayAccountId = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : walletId = Value(walletId),
       amount = Value(amount);
  static Insertable<OperationsTableData> custom({
    Expression<int>? id,
    Expression<int>? walletId,
    Expression<int>? shiftId,
    Expression<String>? operationType,
    Expression<String>? providerType,
    Expression<double>? amount,
    Expression<double>? commission,
    Expression<double>? networkFee,
    Expression<String>? phoneNumber,
    Expression<String>? notes,
    Expression<bool>? isDebt,
    Expression<int>? instaPayAccountId,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (walletId != null) 'wallet_id': walletId,
      if (shiftId != null) 'shift_id': shiftId,
      if (operationType != null) 'operation_type': operationType,
      if (providerType != null) 'provider_type': providerType,
      if (amount != null) 'amount': amount,
      if (commission != null) 'commission': commission,
      if (networkFee != null) 'network_fee': networkFee,
      if (phoneNumber != null) 'phone_number': phoneNumber,
      if (notes != null) 'notes': notes,
      if (isDebt != null) 'is_debt': isDebt,
      if (instaPayAccountId != null) 'insta_pay_account_id': instaPayAccountId,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  OperationsTableCompanion copyWith({
    Value<int>? id,
    Value<int>? walletId,
    Value<int?>? shiftId,
    Value<String>? operationType,
    Value<String>? providerType,
    Value<double>? amount,
    Value<double>? commission,
    Value<double>? networkFee,
    Value<String?>? phoneNumber,
    Value<String?>? notes,
    Value<bool>? isDebt,
    Value<int?>? instaPayAccountId,
    Value<DateTime>? createdAt,
  }) {
    return OperationsTableCompanion(
      id: id ?? this.id,
      walletId: walletId ?? this.walletId,
      shiftId: shiftId ?? this.shiftId,
      operationType: operationType ?? this.operationType,
      providerType: providerType ?? this.providerType,
      amount: amount ?? this.amount,
      commission: commission ?? this.commission,
      networkFee: networkFee ?? this.networkFee,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      notes: notes ?? this.notes,
      isDebt: isDebt ?? this.isDebt,
      instaPayAccountId: instaPayAccountId ?? this.instaPayAccountId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (walletId.present) {
      map['wallet_id'] = Variable<int>(walletId.value);
    }
    if (shiftId.present) {
      map['shift_id'] = Variable<int>(shiftId.value);
    }
    if (operationType.present) {
      map['operation_type'] = Variable<String>(operationType.value);
    }
    if (providerType.present) {
      map['provider_type'] = Variable<String>(providerType.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (commission.present) {
      map['commission'] = Variable<double>(commission.value);
    }
    if (networkFee.present) {
      map['network_fee'] = Variable<double>(networkFee.value);
    }
    if (phoneNumber.present) {
      map['phone_number'] = Variable<String>(phoneNumber.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (isDebt.present) {
      map['is_debt'] = Variable<bool>(isDebt.value);
    }
    if (instaPayAccountId.present) {
      map['insta_pay_account_id'] = Variable<int>(instaPayAccountId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OperationsTableCompanion(')
          ..write('id: $id, ')
          ..write('walletId: $walletId, ')
          ..write('shiftId: $shiftId, ')
          ..write('operationType: $operationType, ')
          ..write('providerType: $providerType, ')
          ..write('amount: $amount, ')
          ..write('commission: $commission, ')
          ..write('networkFee: $networkFee, ')
          ..write('phoneNumber: $phoneNumber, ')
          ..write('notes: $notes, ')
          ..write('isDebt: $isDebt, ')
          ..write('instaPayAccountId: $instaPayAccountId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $CashDrawerTableTable extends CashDrawerTable
    with TableInfo<$CashDrawerTableTable, CashDrawerTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CashDrawerTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _balanceMeta = const VerificationMeta(
    'balance',
  );
  @override
  late final GeneratedColumn<double> balance = GeneratedColumn<double>(
    'balance',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _initialBalanceMeta = const VerificationMeta(
    'initialBalance',
  );
  @override
  late final GeneratedColumn<double> initialBalance = GeneratedColumn<double>(
    'initial_balance',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    balance,
    initialBalance,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cash_drawer_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<CashDrawerTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('balance')) {
      context.handle(
        _balanceMeta,
        balance.isAcceptableOrUnknown(data['balance']!, _balanceMeta),
      );
    }
    if (data.containsKey('initial_balance')) {
      context.handle(
        _initialBalanceMeta,
        initialBalance.isAcceptableOrUnknown(
          data['initial_balance']!,
          _initialBalanceMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CashDrawerTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CashDrawerTableData(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      balance:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}balance'],
          )!,
      initialBalance:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}initial_balance'],
          )!,
      updatedAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}updated_at'],
          )!,
    );
  }

  @override
  $CashDrawerTableTable createAlias(String alias) {
    return $CashDrawerTableTable(attachedDatabase, alias);
  }
}

class CashDrawerTableData extends DataClass
    implements Insertable<CashDrawerTableData> {
  final int id;
  final double balance;
  final double initialBalance;
  final DateTime updatedAt;
  const CashDrawerTableData({
    required this.id,
    required this.balance,
    required this.initialBalance,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['balance'] = Variable<double>(balance);
    map['initial_balance'] = Variable<double>(initialBalance);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  CashDrawerTableCompanion toCompanion(bool nullToAbsent) {
    return CashDrawerTableCompanion(
      id: Value(id),
      balance: Value(balance),
      initialBalance: Value(initialBalance),
      updatedAt: Value(updatedAt),
    );
  }

  factory CashDrawerTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CashDrawerTableData(
      id: serializer.fromJson<int>(json['id']),
      balance: serializer.fromJson<double>(json['balance']),
      initialBalance: serializer.fromJson<double>(json['initialBalance']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'balance': serializer.toJson<double>(balance),
      'initialBalance': serializer.toJson<double>(initialBalance),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  CashDrawerTableData copyWith({
    int? id,
    double? balance,
    double? initialBalance,
    DateTime? updatedAt,
  }) => CashDrawerTableData(
    id: id ?? this.id,
    balance: balance ?? this.balance,
    initialBalance: initialBalance ?? this.initialBalance,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  CashDrawerTableData copyWithCompanion(CashDrawerTableCompanion data) {
    return CashDrawerTableData(
      id: data.id.present ? data.id.value : this.id,
      balance: data.balance.present ? data.balance.value : this.balance,
      initialBalance:
          data.initialBalance.present
              ? data.initialBalance.value
              : this.initialBalance,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CashDrawerTableData(')
          ..write('id: $id, ')
          ..write('balance: $balance, ')
          ..write('initialBalance: $initialBalance, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, balance, initialBalance, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CashDrawerTableData &&
          other.id == this.id &&
          other.balance == this.balance &&
          other.initialBalance == this.initialBalance &&
          other.updatedAt == this.updatedAt);
}

class CashDrawerTableCompanion extends UpdateCompanion<CashDrawerTableData> {
  final Value<int> id;
  final Value<double> balance;
  final Value<double> initialBalance;
  final Value<DateTime> updatedAt;
  const CashDrawerTableCompanion({
    this.id = const Value.absent(),
    this.balance = const Value.absent(),
    this.initialBalance = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  CashDrawerTableCompanion.insert({
    this.id = const Value.absent(),
    this.balance = const Value.absent(),
    this.initialBalance = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  static Insertable<CashDrawerTableData> custom({
    Expression<int>? id,
    Expression<double>? balance,
    Expression<double>? initialBalance,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (balance != null) 'balance': balance,
      if (initialBalance != null) 'initial_balance': initialBalance,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  CashDrawerTableCompanion copyWith({
    Value<int>? id,
    Value<double>? balance,
    Value<double>? initialBalance,
    Value<DateTime>? updatedAt,
  }) {
    return CashDrawerTableCompanion(
      id: id ?? this.id,
      balance: balance ?? this.balance,
      initialBalance: initialBalance ?? this.initialBalance,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (balance.present) {
      map['balance'] = Variable<double>(balance.value);
    }
    if (initialBalance.present) {
      map['initial_balance'] = Variable<double>(initialBalance.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CashDrawerTableCompanion(')
          ..write('id: $id, ')
          ..write('balance: $balance, ')
          ..write('initialBalance: $initialBalance, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $WalletAdjustmentsTableTable extends WalletAdjustmentsTable
    with TableInfo<$WalletAdjustmentsTableTable, WalletAdjustmentsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WalletAdjustmentsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _walletIdMeta = const VerificationMeta(
    'walletId',
  );
  @override
  late final GeneratedColumn<int> walletId = GeneratedColumn<int>(
    'wallet_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES wallets_table (id)',
    ),
  );
  static const VerificationMeta _periodTypeMeta = const VerificationMeta(
    'periodType',
  );
  @override
  late final GeneratedColumn<String> periodType = GeneratedColumn<String>(
    'period_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
    'reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    walletId,
    periodType,
    amount,
    reason,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'wallet_adjustments_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<WalletAdjustmentsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('wallet_id')) {
      context.handle(
        _walletIdMeta,
        walletId.isAcceptableOrUnknown(data['wallet_id']!, _walletIdMeta),
      );
    } else if (isInserting) {
      context.missing(_walletIdMeta);
    }
    if (data.containsKey('period_type')) {
      context.handle(
        _periodTypeMeta,
        periodType.isAcceptableOrUnknown(data['period_type']!, _periodTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_periodTypeMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('reason')) {
      context.handle(
        _reasonMeta,
        reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WalletAdjustmentsTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WalletAdjustmentsTableData(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      walletId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}wallet_id'],
          )!,
      periodType:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}period_type'],
          )!,
      amount:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}amount'],
          )!,
      reason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reason'],
      ),
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}created_at'],
          )!,
    );
  }

  @override
  $WalletAdjustmentsTableTable createAlias(String alias) {
    return $WalletAdjustmentsTableTable(attachedDatabase, alias);
  }
}

class WalletAdjustmentsTableData extends DataClass
    implements Insertable<WalletAdjustmentsTableData> {
  final int id;
  final int walletId;
  final String periodType;
  final double amount;
  final String? reason;
  final DateTime createdAt;
  const WalletAdjustmentsTableData({
    required this.id,
    required this.walletId,
    required this.periodType,
    required this.amount,
    this.reason,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['wallet_id'] = Variable<int>(walletId);
    map['period_type'] = Variable<String>(periodType);
    map['amount'] = Variable<double>(amount);
    if (!nullToAbsent || reason != null) {
      map['reason'] = Variable<String>(reason);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  WalletAdjustmentsTableCompanion toCompanion(bool nullToAbsent) {
    return WalletAdjustmentsTableCompanion(
      id: Value(id),
      walletId: Value(walletId),
      periodType: Value(periodType),
      amount: Value(amount),
      reason:
          reason == null && nullToAbsent ? const Value.absent() : Value(reason),
      createdAt: Value(createdAt),
    );
  }

  factory WalletAdjustmentsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WalletAdjustmentsTableData(
      id: serializer.fromJson<int>(json['id']),
      walletId: serializer.fromJson<int>(json['walletId']),
      periodType: serializer.fromJson<String>(json['periodType']),
      amount: serializer.fromJson<double>(json['amount']),
      reason: serializer.fromJson<String?>(json['reason']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'walletId': serializer.toJson<int>(walletId),
      'periodType': serializer.toJson<String>(periodType),
      'amount': serializer.toJson<double>(amount),
      'reason': serializer.toJson<String?>(reason),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  WalletAdjustmentsTableData copyWith({
    int? id,
    int? walletId,
    String? periodType,
    double? amount,
    Value<String?> reason = const Value.absent(),
    DateTime? createdAt,
  }) => WalletAdjustmentsTableData(
    id: id ?? this.id,
    walletId: walletId ?? this.walletId,
    periodType: periodType ?? this.periodType,
    amount: amount ?? this.amount,
    reason: reason.present ? reason.value : this.reason,
    createdAt: createdAt ?? this.createdAt,
  );
  WalletAdjustmentsTableData copyWithCompanion(
    WalletAdjustmentsTableCompanion data,
  ) {
    return WalletAdjustmentsTableData(
      id: data.id.present ? data.id.value : this.id,
      walletId: data.walletId.present ? data.walletId.value : this.walletId,
      periodType:
          data.periodType.present ? data.periodType.value : this.periodType,
      amount: data.amount.present ? data.amount.value : this.amount,
      reason: data.reason.present ? data.reason.value : this.reason,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WalletAdjustmentsTableData(')
          ..write('id: $id, ')
          ..write('walletId: $walletId, ')
          ..write('periodType: $periodType, ')
          ..write('amount: $amount, ')
          ..write('reason: $reason, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, walletId, periodType, amount, reason, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WalletAdjustmentsTableData &&
          other.id == this.id &&
          other.walletId == this.walletId &&
          other.periodType == this.periodType &&
          other.amount == this.amount &&
          other.reason == this.reason &&
          other.createdAt == this.createdAt);
}

class WalletAdjustmentsTableCompanion
    extends UpdateCompanion<WalletAdjustmentsTableData> {
  final Value<int> id;
  final Value<int> walletId;
  final Value<String> periodType;
  final Value<double> amount;
  final Value<String?> reason;
  final Value<DateTime> createdAt;
  const WalletAdjustmentsTableCompanion({
    this.id = const Value.absent(),
    this.walletId = const Value.absent(),
    this.periodType = const Value.absent(),
    this.amount = const Value.absent(),
    this.reason = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  WalletAdjustmentsTableCompanion.insert({
    this.id = const Value.absent(),
    required int walletId,
    required String periodType,
    required double amount,
    this.reason = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : walletId = Value(walletId),
       periodType = Value(periodType),
       amount = Value(amount);
  static Insertable<WalletAdjustmentsTableData> custom({
    Expression<int>? id,
    Expression<int>? walletId,
    Expression<String>? periodType,
    Expression<double>? amount,
    Expression<String>? reason,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (walletId != null) 'wallet_id': walletId,
      if (periodType != null) 'period_type': periodType,
      if (amount != null) 'amount': amount,
      if (reason != null) 'reason': reason,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  WalletAdjustmentsTableCompanion copyWith({
    Value<int>? id,
    Value<int>? walletId,
    Value<String>? periodType,
    Value<double>? amount,
    Value<String?>? reason,
    Value<DateTime>? createdAt,
  }) {
    return WalletAdjustmentsTableCompanion(
      id: id ?? this.id,
      walletId: walletId ?? this.walletId,
      periodType: periodType ?? this.periodType,
      amount: amount ?? this.amount,
      reason: reason ?? this.reason,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (walletId.present) {
      map['wallet_id'] = Variable<int>(walletId.value);
    }
    if (periodType.present) {
      map['period_type'] = Variable<String>(periodType.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WalletAdjustmentsTableCompanion(')
          ..write('id: $id, ')
          ..write('walletId: $walletId, ')
          ..write('periodType: $periodType, ')
          ..write('amount: $amount, ')
          ..write('reason: $reason, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $ShiftsTableTable extends ShiftsTable
    with TableInfo<$ShiftsTableTable, ShiftsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ShiftsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _startTimeMeta = const VerificationMeta(
    'startTime',
  );
  @override
  late final GeneratedColumn<DateTime> startTime = GeneratedColumn<DateTime>(
    'start_time',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endTimeMeta = const VerificationMeta(
    'endTime',
  );
  @override
  late final GeneratedColumn<DateTime> endTime = GeneratedColumn<DateTime>(
    'end_time',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _openingCashDrawerMeta = const VerificationMeta(
    'openingCashDrawer',
  );
  @override
  late final GeneratedColumn<double> openingCashDrawer =
      GeneratedColumn<double>(
        'opening_cash_drawer',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _closingCashDrawerMeta = const VerificationMeta(
    'closingCashDrawer',
  );
  @override
  late final GeneratedColumn<double> closingCashDrawer =
      GeneratedColumn<double>(
        'closing_cash_drawer',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    startTime,
    endTime,
    openingCashDrawer,
    closingCashDrawer,
    notes,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'shifts_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<ShiftsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('start_time')) {
      context.handle(
        _startTimeMeta,
        startTime.isAcceptableOrUnknown(data['start_time']!, _startTimeMeta),
      );
    } else if (isInserting) {
      context.missing(_startTimeMeta);
    }
    if (data.containsKey('end_time')) {
      context.handle(
        _endTimeMeta,
        endTime.isAcceptableOrUnknown(data['end_time']!, _endTimeMeta),
      );
    }
    if (data.containsKey('opening_cash_drawer')) {
      context.handle(
        _openingCashDrawerMeta,
        openingCashDrawer.isAcceptableOrUnknown(
          data['opening_cash_drawer']!,
          _openingCashDrawerMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_openingCashDrawerMeta);
    }
    if (data.containsKey('closing_cash_drawer')) {
      context.handle(
        _closingCashDrawerMeta,
        closingCashDrawer.isAcceptableOrUnknown(
          data['closing_cash_drawer']!,
          _closingCashDrawerMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ShiftsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ShiftsTableData(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      startTime:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}start_time'],
          )!,
      endTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}end_time'],
      ),
      openingCashDrawer:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}opening_cash_drawer'],
          )!,
      closingCashDrawer: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}closing_cash_drawer'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}created_at'],
          )!,
    );
  }

  @override
  $ShiftsTableTable createAlias(String alias) {
    return $ShiftsTableTable(attachedDatabase, alias);
  }
}

class ShiftsTableData extends DataClass implements Insertable<ShiftsTableData> {
  final int id;
  final DateTime startTime;
  final DateTime? endTime;
  final double openingCashDrawer;
  final double? closingCashDrawer;
  final String? notes;
  final DateTime createdAt;
  const ShiftsTableData({
    required this.id,
    required this.startTime,
    this.endTime,
    required this.openingCashDrawer,
    this.closingCashDrawer,
    this.notes,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['start_time'] = Variable<DateTime>(startTime);
    if (!nullToAbsent || endTime != null) {
      map['end_time'] = Variable<DateTime>(endTime);
    }
    map['opening_cash_drawer'] = Variable<double>(openingCashDrawer);
    if (!nullToAbsent || closingCashDrawer != null) {
      map['closing_cash_drawer'] = Variable<double>(closingCashDrawer);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ShiftsTableCompanion toCompanion(bool nullToAbsent) {
    return ShiftsTableCompanion(
      id: Value(id),
      startTime: Value(startTime),
      endTime:
          endTime == null && nullToAbsent
              ? const Value.absent()
              : Value(endTime),
      openingCashDrawer: Value(openingCashDrawer),
      closingCashDrawer:
          closingCashDrawer == null && nullToAbsent
              ? const Value.absent()
              : Value(closingCashDrawer),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      createdAt: Value(createdAt),
    );
  }

  factory ShiftsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ShiftsTableData(
      id: serializer.fromJson<int>(json['id']),
      startTime: serializer.fromJson<DateTime>(json['startTime']),
      endTime: serializer.fromJson<DateTime?>(json['endTime']),
      openingCashDrawer: serializer.fromJson<double>(json['openingCashDrawer']),
      closingCashDrawer: serializer.fromJson<double?>(
        json['closingCashDrawer'],
      ),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'startTime': serializer.toJson<DateTime>(startTime),
      'endTime': serializer.toJson<DateTime?>(endTime),
      'openingCashDrawer': serializer.toJson<double>(openingCashDrawer),
      'closingCashDrawer': serializer.toJson<double?>(closingCashDrawer),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ShiftsTableData copyWith({
    int? id,
    DateTime? startTime,
    Value<DateTime?> endTime = const Value.absent(),
    double? openingCashDrawer,
    Value<double?> closingCashDrawer = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    DateTime? createdAt,
  }) => ShiftsTableData(
    id: id ?? this.id,
    startTime: startTime ?? this.startTime,
    endTime: endTime.present ? endTime.value : this.endTime,
    openingCashDrawer: openingCashDrawer ?? this.openingCashDrawer,
    closingCashDrawer:
        closingCashDrawer.present
            ? closingCashDrawer.value
            : this.closingCashDrawer,
    notes: notes.present ? notes.value : this.notes,
    createdAt: createdAt ?? this.createdAt,
  );
  ShiftsTableData copyWithCompanion(ShiftsTableCompanion data) {
    return ShiftsTableData(
      id: data.id.present ? data.id.value : this.id,
      startTime: data.startTime.present ? data.startTime.value : this.startTime,
      endTime: data.endTime.present ? data.endTime.value : this.endTime,
      openingCashDrawer:
          data.openingCashDrawer.present
              ? data.openingCashDrawer.value
              : this.openingCashDrawer,
      closingCashDrawer:
          data.closingCashDrawer.present
              ? data.closingCashDrawer.value
              : this.closingCashDrawer,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ShiftsTableData(')
          ..write('id: $id, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('openingCashDrawer: $openingCashDrawer, ')
          ..write('closingCashDrawer: $closingCashDrawer, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    startTime,
    endTime,
    openingCashDrawer,
    closingCashDrawer,
    notes,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ShiftsTableData &&
          other.id == this.id &&
          other.startTime == this.startTime &&
          other.endTime == this.endTime &&
          other.openingCashDrawer == this.openingCashDrawer &&
          other.closingCashDrawer == this.closingCashDrawer &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt);
}

class ShiftsTableCompanion extends UpdateCompanion<ShiftsTableData> {
  final Value<int> id;
  final Value<DateTime> startTime;
  final Value<DateTime?> endTime;
  final Value<double> openingCashDrawer;
  final Value<double?> closingCashDrawer;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  const ShiftsTableCompanion({
    this.id = const Value.absent(),
    this.startTime = const Value.absent(),
    this.endTime = const Value.absent(),
    this.openingCashDrawer = const Value.absent(),
    this.closingCashDrawer = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  ShiftsTableCompanion.insert({
    this.id = const Value.absent(),
    required DateTime startTime,
    this.endTime = const Value.absent(),
    required double openingCashDrawer,
    this.closingCashDrawer = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : startTime = Value(startTime),
       openingCashDrawer = Value(openingCashDrawer);
  static Insertable<ShiftsTableData> custom({
    Expression<int>? id,
    Expression<DateTime>? startTime,
    Expression<DateTime>? endTime,
    Expression<double>? openingCashDrawer,
    Expression<double>? closingCashDrawer,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (startTime != null) 'start_time': startTime,
      if (endTime != null) 'end_time': endTime,
      if (openingCashDrawer != null) 'opening_cash_drawer': openingCashDrawer,
      if (closingCashDrawer != null) 'closing_cash_drawer': closingCashDrawer,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  ShiftsTableCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? startTime,
    Value<DateTime?>? endTime,
    Value<double>? openingCashDrawer,
    Value<double?>? closingCashDrawer,
    Value<String?>? notes,
    Value<DateTime>? createdAt,
  }) {
    return ShiftsTableCompanion(
      id: id ?? this.id,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      openingCashDrawer: openingCashDrawer ?? this.openingCashDrawer,
      closingCashDrawer: closingCashDrawer ?? this.closingCashDrawer,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (startTime.present) {
      map['start_time'] = Variable<DateTime>(startTime.value);
    }
    if (endTime.present) {
      map['end_time'] = Variable<DateTime>(endTime.value);
    }
    if (openingCashDrawer.present) {
      map['opening_cash_drawer'] = Variable<double>(openingCashDrawer.value);
    }
    if (closingCashDrawer.present) {
      map['closing_cash_drawer'] = Variable<double>(closingCashDrawer.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ShiftsTableCompanion(')
          ..write('id: $id, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('openingCashDrawer: $openingCashDrawer, ')
          ..write('closingCashDrawer: $closingCashDrawer, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $DebtorsTableTable extends DebtorsTable
    with TableInfo<$DebtorsTableTable, DebtorsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DebtorsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 255,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 20,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 255,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, phone, notes, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'debtors_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<DebtorsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DebtorsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DebtorsTableData(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      name:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}name'],
          )!,
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}created_at'],
          )!,
    );
  }

  @override
  $DebtorsTableTable createAlias(String alias) {
    return $DebtorsTableTable(attachedDatabase, alias);
  }
}

class DebtorsTableData extends DataClass
    implements Insertable<DebtorsTableData> {
  final int id;
  final String name;
  final String? phone;
  final String? notes;
  final DateTime createdAt;
  const DebtorsTableData({
    required this.id,
    required this.name,
    this.phone,
    this.notes,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  DebtorsTableCompanion toCompanion(bool nullToAbsent) {
    return DebtorsTableCompanion(
      id: Value(id),
      name: Value(name),
      phone:
          phone == null && nullToAbsent ? const Value.absent() : Value(phone),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      createdAt: Value(createdAt),
    );
  }

  factory DebtorsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DebtorsTableData(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      phone: serializer.fromJson<String?>(json['phone']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'phone': serializer.toJson<String?>(phone),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  DebtorsTableData copyWith({
    int? id,
    String? name,
    Value<String?> phone = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    DateTime? createdAt,
  }) => DebtorsTableData(
    id: id ?? this.id,
    name: name ?? this.name,
    phone: phone.present ? phone.value : this.phone,
    notes: notes.present ? notes.value : this.notes,
    createdAt: createdAt ?? this.createdAt,
  );
  DebtorsTableData copyWithCompanion(DebtorsTableCompanion data) {
    return DebtorsTableData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      phone: data.phone.present ? data.phone.value : this.phone,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DebtorsTableData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, phone, notes, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DebtorsTableData &&
          other.id == this.id &&
          other.name == this.name &&
          other.phone == this.phone &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt);
}

class DebtorsTableCompanion extends UpdateCompanion<DebtorsTableData> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> phone;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  const DebtorsTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.phone = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  DebtorsTableCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.phone = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : name = Value(name);
  static Insertable<DebtorsTableData> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? phone,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (phone != null) 'phone': phone,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  DebtorsTableCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String?>? phone,
    Value<String?>? notes,
    Value<DateTime>? createdAt,
  }) {
    return DebtorsTableCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DebtorsTableCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $DebtsTableTable extends DebtsTable
    with TableInfo<$DebtsTableTable, DebtsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DebtsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _debtorIdMeta = const VerificationMeta(
    'debtorId',
  );
  @override
  late final GeneratedColumn<int> debtorId = GeneratedColumn<int>(
    'debtor_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES debtors_table (id)',
    ),
  );
  static const VerificationMeta _operationIdMeta = const VerificationMeta(
    'operationId',
  );
  @override
  late final GeneratedColumn<int> operationId = GeneratedColumn<int>(
    'operation_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES operations_table (id)',
    ),
  );
  static const VerificationMeta _operationTypeMeta = const VerificationMeta(
    'operationType',
  );
  @override
  late final GeneratedColumn<String> operationType = GeneratedColumn<String>(
    'operation_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('deposit'),
  );
  static const VerificationMeta _providerTypeMeta = const VerificationMeta(
    'providerType',
  );
  @override
  late final GeneratedColumn<String> providerType = GeneratedColumn<String>(
    'provider_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('vodafoneCash'),
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isPaidMeta = const VerificationMeta('isPaid');
  @override
  late final GeneratedColumn<bool> isPaid = GeneratedColumn<bool>(
    'is_paid',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_paid" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isCashLoanMeta = const VerificationMeta(
    'isCashLoan',
  );
  @override
  late final GeneratedColumn<bool> isCashLoan = GeneratedColumn<bool>(
    'is_cash_loan',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_cash_loan" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _paidAtMeta = const VerificationMeta('paidAt');
  @override
  late final GeneratedColumn<DateTime> paidAt = GeneratedColumn<DateTime>(
    'paid_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    debtorId,
    operationId,
    operationType,
    providerType,
    amount,
    isPaid,
    isCashLoan,
    paidAt,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'debts_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<DebtsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('debtor_id')) {
      context.handle(
        _debtorIdMeta,
        debtorId.isAcceptableOrUnknown(data['debtor_id']!, _debtorIdMeta),
      );
    } else if (isInserting) {
      context.missing(_debtorIdMeta);
    }
    if (data.containsKey('operation_id')) {
      context.handle(
        _operationIdMeta,
        operationId.isAcceptableOrUnknown(
          data['operation_id']!,
          _operationIdMeta,
        ),
      );
    }
    if (data.containsKey('operation_type')) {
      context.handle(
        _operationTypeMeta,
        operationType.isAcceptableOrUnknown(
          data['operation_type']!,
          _operationTypeMeta,
        ),
      );
    }
    if (data.containsKey('provider_type')) {
      context.handle(
        _providerTypeMeta,
        providerType.isAcceptableOrUnknown(
          data['provider_type']!,
          _providerTypeMeta,
        ),
      );
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('is_paid')) {
      context.handle(
        _isPaidMeta,
        isPaid.isAcceptableOrUnknown(data['is_paid']!, _isPaidMeta),
      );
    }
    if (data.containsKey('is_cash_loan')) {
      context.handle(
        _isCashLoanMeta,
        isCashLoan.isAcceptableOrUnknown(
          data['is_cash_loan']!,
          _isCashLoanMeta,
        ),
      );
    }
    if (data.containsKey('paid_at')) {
      context.handle(
        _paidAtMeta,
        paidAt.isAcceptableOrUnknown(data['paid_at']!, _paidAtMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DebtsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DebtsTableData(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      debtorId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}debtor_id'],
          )!,
      operationId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}operation_id'],
      ),
      operationType:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}operation_type'],
          )!,
      providerType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider_type'],
      ),
      amount:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}amount'],
          )!,
      isPaid:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}is_paid'],
          )!,
      isCashLoan:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}is_cash_loan'],
          )!,
      paidAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}paid_at'],
      ),
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}created_at'],
          )!,
    );
  }

  @override
  $DebtsTableTable createAlias(String alias) {
    return $DebtsTableTable(attachedDatabase, alias);
  }
}

class DebtsTableData extends DataClass implements Insertable<DebtsTableData> {
  final int id;
  final int debtorId;
  final int? operationId;
  final String operationType;
  final String? providerType;
  final double amount;
  final bool isPaid;
  final bool isCashLoan;
  final DateTime? paidAt;
  final DateTime createdAt;
  const DebtsTableData({
    required this.id,
    required this.debtorId,
    this.operationId,
    required this.operationType,
    this.providerType,
    required this.amount,
    required this.isPaid,
    required this.isCashLoan,
    this.paidAt,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['debtor_id'] = Variable<int>(debtorId);
    if (!nullToAbsent || operationId != null) {
      map['operation_id'] = Variable<int>(operationId);
    }
    map['operation_type'] = Variable<String>(operationType);
    if (!nullToAbsent || providerType != null) {
      map['provider_type'] = Variable<String>(providerType);
    }
    map['amount'] = Variable<double>(amount);
    map['is_paid'] = Variable<bool>(isPaid);
    map['is_cash_loan'] = Variable<bool>(isCashLoan);
    if (!nullToAbsent || paidAt != null) {
      map['paid_at'] = Variable<DateTime>(paidAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  DebtsTableCompanion toCompanion(bool nullToAbsent) {
    return DebtsTableCompanion(
      id: Value(id),
      debtorId: Value(debtorId),
      operationId:
          operationId == null && nullToAbsent
              ? const Value.absent()
              : Value(operationId),
      operationType: Value(operationType),
      providerType:
          providerType == null && nullToAbsent
              ? const Value.absent()
              : Value(providerType),
      amount: Value(amount),
      isPaid: Value(isPaid),
      isCashLoan: Value(isCashLoan),
      paidAt:
          paidAt == null && nullToAbsent ? const Value.absent() : Value(paidAt),
      createdAt: Value(createdAt),
    );
  }

  factory DebtsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DebtsTableData(
      id: serializer.fromJson<int>(json['id']),
      debtorId: serializer.fromJson<int>(json['debtorId']),
      operationId: serializer.fromJson<int?>(json['operationId']),
      operationType: serializer.fromJson<String>(json['operationType']),
      providerType: serializer.fromJson<String?>(json['providerType']),
      amount: serializer.fromJson<double>(json['amount']),
      isPaid: serializer.fromJson<bool>(json['isPaid']),
      isCashLoan: serializer.fromJson<bool>(json['isCashLoan']),
      paidAt: serializer.fromJson<DateTime?>(json['paidAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'debtorId': serializer.toJson<int>(debtorId),
      'operationId': serializer.toJson<int?>(operationId),
      'operationType': serializer.toJson<String>(operationType),
      'providerType': serializer.toJson<String?>(providerType),
      'amount': serializer.toJson<double>(amount),
      'isPaid': serializer.toJson<bool>(isPaid),
      'isCashLoan': serializer.toJson<bool>(isCashLoan),
      'paidAt': serializer.toJson<DateTime?>(paidAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  DebtsTableData copyWith({
    int? id,
    int? debtorId,
    Value<int?> operationId = const Value.absent(),
    String? operationType,
    Value<String?> providerType = const Value.absent(),
    double? amount,
    bool? isPaid,
    bool? isCashLoan,
    Value<DateTime?> paidAt = const Value.absent(),
    DateTime? createdAt,
  }) => DebtsTableData(
    id: id ?? this.id,
    debtorId: debtorId ?? this.debtorId,
    operationId: operationId.present ? operationId.value : this.operationId,
    operationType: operationType ?? this.operationType,
    providerType: providerType.present ? providerType.value : this.providerType,
    amount: amount ?? this.amount,
    isPaid: isPaid ?? this.isPaid,
    isCashLoan: isCashLoan ?? this.isCashLoan,
    paidAt: paidAt.present ? paidAt.value : this.paidAt,
    createdAt: createdAt ?? this.createdAt,
  );
  DebtsTableData copyWithCompanion(DebtsTableCompanion data) {
    return DebtsTableData(
      id: data.id.present ? data.id.value : this.id,
      debtorId: data.debtorId.present ? data.debtorId.value : this.debtorId,
      operationId:
          data.operationId.present ? data.operationId.value : this.operationId,
      operationType:
          data.operationType.present
              ? data.operationType.value
              : this.operationType,
      providerType:
          data.providerType.present
              ? data.providerType.value
              : this.providerType,
      amount: data.amount.present ? data.amount.value : this.amount,
      isPaid: data.isPaid.present ? data.isPaid.value : this.isPaid,
      isCashLoan:
          data.isCashLoan.present ? data.isCashLoan.value : this.isCashLoan,
      paidAt: data.paidAt.present ? data.paidAt.value : this.paidAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DebtsTableData(')
          ..write('id: $id, ')
          ..write('debtorId: $debtorId, ')
          ..write('operationId: $operationId, ')
          ..write('operationType: $operationType, ')
          ..write('providerType: $providerType, ')
          ..write('amount: $amount, ')
          ..write('isPaid: $isPaid, ')
          ..write('isCashLoan: $isCashLoan, ')
          ..write('paidAt: $paidAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    debtorId,
    operationId,
    operationType,
    providerType,
    amount,
    isPaid,
    isCashLoan,
    paidAt,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DebtsTableData &&
          other.id == this.id &&
          other.debtorId == this.debtorId &&
          other.operationId == this.operationId &&
          other.operationType == this.operationType &&
          other.providerType == this.providerType &&
          other.amount == this.amount &&
          other.isPaid == this.isPaid &&
          other.isCashLoan == this.isCashLoan &&
          other.paidAt == this.paidAt &&
          other.createdAt == this.createdAt);
}

class DebtsTableCompanion extends UpdateCompanion<DebtsTableData> {
  final Value<int> id;
  final Value<int> debtorId;
  final Value<int?> operationId;
  final Value<String> operationType;
  final Value<String?> providerType;
  final Value<double> amount;
  final Value<bool> isPaid;
  final Value<bool> isCashLoan;
  final Value<DateTime?> paidAt;
  final Value<DateTime> createdAt;
  const DebtsTableCompanion({
    this.id = const Value.absent(),
    this.debtorId = const Value.absent(),
    this.operationId = const Value.absent(),
    this.operationType = const Value.absent(),
    this.providerType = const Value.absent(),
    this.amount = const Value.absent(),
    this.isPaid = const Value.absent(),
    this.isCashLoan = const Value.absent(),
    this.paidAt = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  DebtsTableCompanion.insert({
    this.id = const Value.absent(),
    required int debtorId,
    this.operationId = const Value.absent(),
    this.operationType = const Value.absent(),
    this.providerType = const Value.absent(),
    required double amount,
    this.isPaid = const Value.absent(),
    this.isCashLoan = const Value.absent(),
    this.paidAt = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : debtorId = Value(debtorId),
       amount = Value(amount);
  static Insertable<DebtsTableData> custom({
    Expression<int>? id,
    Expression<int>? debtorId,
    Expression<int>? operationId,
    Expression<String>? operationType,
    Expression<String>? providerType,
    Expression<double>? amount,
    Expression<bool>? isPaid,
    Expression<bool>? isCashLoan,
    Expression<DateTime>? paidAt,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (debtorId != null) 'debtor_id': debtorId,
      if (operationId != null) 'operation_id': operationId,
      if (operationType != null) 'operation_type': operationType,
      if (providerType != null) 'provider_type': providerType,
      if (amount != null) 'amount': amount,
      if (isPaid != null) 'is_paid': isPaid,
      if (isCashLoan != null) 'is_cash_loan': isCashLoan,
      if (paidAt != null) 'paid_at': paidAt,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  DebtsTableCompanion copyWith({
    Value<int>? id,
    Value<int>? debtorId,
    Value<int?>? operationId,
    Value<String>? operationType,
    Value<String?>? providerType,
    Value<double>? amount,
    Value<bool>? isPaid,
    Value<bool>? isCashLoan,
    Value<DateTime?>? paidAt,
    Value<DateTime>? createdAt,
  }) {
    return DebtsTableCompanion(
      id: id ?? this.id,
      debtorId: debtorId ?? this.debtorId,
      operationId: operationId ?? this.operationId,
      operationType: operationType ?? this.operationType,
      providerType: providerType ?? this.providerType,
      amount: amount ?? this.amount,
      isPaid: isPaid ?? this.isPaid,
      isCashLoan: isCashLoan ?? this.isCashLoan,
      paidAt: paidAt ?? this.paidAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (debtorId.present) {
      map['debtor_id'] = Variable<int>(debtorId.value);
    }
    if (operationId.present) {
      map['operation_id'] = Variable<int>(operationId.value);
    }
    if (operationType.present) {
      map['operation_type'] = Variable<String>(operationType.value);
    }
    if (providerType.present) {
      map['provider_type'] = Variable<String>(providerType.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (isPaid.present) {
      map['is_paid'] = Variable<bool>(isPaid.value);
    }
    if (isCashLoan.present) {
      map['is_cash_loan'] = Variable<bool>(isCashLoan.value);
    }
    if (paidAt.present) {
      map['paid_at'] = Variable<DateTime>(paidAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DebtsTableCompanion(')
          ..write('id: $id, ')
          ..write('debtorId: $debtorId, ')
          ..write('operationId: $operationId, ')
          ..write('operationType: $operationType, ')
          ..write('providerType: $providerType, ')
          ..write('amount: $amount, ')
          ..write('isPaid: $isPaid, ')
          ..write('isCashLoan: $isCashLoan, ')
          ..write('paidAt: $paidAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $InstaPayAccountsTableTable extends InstaPayAccountsTable
    with TableInfo<$InstaPayAccountsTableTable, InstaPayAccountsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InstaPayAccountsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'insta_pay_accounts_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<InstaPayAccountsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  InstaPayAccountsTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InstaPayAccountsTableData(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      name:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}name'],
          )!,
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}created_at'],
          )!,
    );
  }

  @override
  $InstaPayAccountsTableTable createAlias(String alias) {
    return $InstaPayAccountsTableTable(attachedDatabase, alias);
  }
}

class InstaPayAccountsTableData extends DataClass
    implements Insertable<InstaPayAccountsTableData> {
  final int id;
  final String name;
  final DateTime createdAt;
  const InstaPayAccountsTableData({
    required this.id,
    required this.name,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  InstaPayAccountsTableCompanion toCompanion(bool nullToAbsent) {
    return InstaPayAccountsTableCompanion(
      id: Value(id),
      name: Value(name),
      createdAt: Value(createdAt),
    );
  }

  factory InstaPayAccountsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InstaPayAccountsTableData(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  InstaPayAccountsTableData copyWith({
    int? id,
    String? name,
    DateTime? createdAt,
  }) => InstaPayAccountsTableData(
    id: id ?? this.id,
    name: name ?? this.name,
    createdAt: createdAt ?? this.createdAt,
  );
  InstaPayAccountsTableData copyWithCompanion(
    InstaPayAccountsTableCompanion data,
  ) {
    return InstaPayAccountsTableData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InstaPayAccountsTableData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InstaPayAccountsTableData &&
          other.id == this.id &&
          other.name == this.name &&
          other.createdAt == this.createdAt);
}

class InstaPayAccountsTableCompanion
    extends UpdateCompanion<InstaPayAccountsTableData> {
  final Value<int> id;
  final Value<String> name;
  final Value<DateTime> createdAt;
  const InstaPayAccountsTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  InstaPayAccountsTableCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.createdAt = const Value.absent(),
  }) : name = Value(name);
  static Insertable<InstaPayAccountsTableData> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  InstaPayAccountsTableCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<DateTime>? createdAt,
  }) {
    return InstaPayAccountsTableCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InstaPayAccountsTableCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $TransactionsTableTable transactionsTable =
      $TransactionsTableTable(this);
  late final $WalletsTableTable walletsTable = $WalletsTableTable(this);
  late final $OperationsTableTable operationsTable = $OperationsTableTable(
    this,
  );
  late final $CashDrawerTableTable cashDrawerTable = $CashDrawerTableTable(
    this,
  );
  late final $WalletAdjustmentsTableTable walletAdjustmentsTable =
      $WalletAdjustmentsTableTable(this);
  late final $ShiftsTableTable shiftsTable = $ShiftsTableTable(this);
  late final $DebtorsTableTable debtorsTable = $DebtorsTableTable(this);
  late final $DebtsTableTable debtsTable = $DebtsTableTable(this);
  late final $InstaPayAccountsTableTable instaPayAccountsTable =
      $InstaPayAccountsTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    transactionsTable,
    walletsTable,
    operationsTable,
    cashDrawerTable,
    walletAdjustmentsTable,
    shiftsTable,
    debtorsTable,
    debtsTable,
    instaPayAccountsTable,
  ];
}

typedef $$TransactionsTableTableCreateCompanionBuilder =
    TransactionsTableCompanion Function({
      Value<int> id,
      required String note,
      required double amount,
      required DateTime date,
      required String category,
      required String type,
    });
typedef $$TransactionsTableTableUpdateCompanionBuilder =
    TransactionsTableCompanion Function({
      Value<int> id,
      Value<String> note,
      Value<double> amount,
      Value<DateTime> date,
      Value<String> category,
      Value<String> type,
    });

class $$TransactionsTableTableFilterComposer
    extends Composer<_$AppDatabase, $TransactionsTableTable> {
  $$TransactionsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TransactionsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $TransactionsTableTable> {
  $$TransactionsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TransactionsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $TransactionsTableTable> {
  $$TransactionsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);
}

class $$TransactionsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TransactionsTableTable,
          TransactionsTableData,
          $$TransactionsTableTableFilterComposer,
          $$TransactionsTableTableOrderingComposer,
          $$TransactionsTableTableAnnotationComposer,
          $$TransactionsTableTableCreateCompanionBuilder,
          $$TransactionsTableTableUpdateCompanionBuilder,
          (
            TransactionsTableData,
            BaseReferences<
              _$AppDatabase,
              $TransactionsTableTable,
              TransactionsTableData
            >,
          ),
          TransactionsTableData,
          PrefetchHooks Function()
        > {
  $$TransactionsTableTableTableManager(
    _$AppDatabase db,
    $TransactionsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$TransactionsTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer:
              () => $$TransactionsTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer:
              () => $$TransactionsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> note = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String> type = const Value.absent(),
              }) => TransactionsTableCompanion(
                id: id,
                note: note,
                amount: amount,
                date: date,
                category: category,
                type: type,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String note,
                required double amount,
                required DateTime date,
                required String category,
                required String type,
              }) => TransactionsTableCompanion.insert(
                id: id,
                note: note,
                amount: amount,
                date: date,
                category: category,
                type: type,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TransactionsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TransactionsTableTable,
      TransactionsTableData,
      $$TransactionsTableTableFilterComposer,
      $$TransactionsTableTableOrderingComposer,
      $$TransactionsTableTableAnnotationComposer,
      $$TransactionsTableTableCreateCompanionBuilder,
      $$TransactionsTableTableUpdateCompanionBuilder,
      (
        TransactionsTableData,
        BaseReferences<
          _$AppDatabase,
          $TransactionsTableTable,
          TransactionsTableData
        >,
      ),
      TransactionsTableData,
      PrefetchHooks Function()
    >;
typedef $$WalletsTableTableCreateCompanionBuilder =
    WalletsTableCompanion Function({
      Value<int> id,
      required String name,
      Value<String?> phoneNumber,
      Value<double> balance,
      Value<String> color,
      Value<double> dailyLimit,
      Value<double> weeklyLimit,
      Value<double> monthlyLimit,
      Value<DateTime> createdAt,
    });
typedef $$WalletsTableTableUpdateCompanionBuilder =
    WalletsTableCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String?> phoneNumber,
      Value<double> balance,
      Value<String> color,
      Value<double> dailyLimit,
      Value<double> weeklyLimit,
      Value<double> monthlyLimit,
      Value<DateTime> createdAt,
    });

final class $$WalletsTableTableReferences
    extends
        BaseReferences<_$AppDatabase, $WalletsTableTable, WalletsTableData> {
  $$WalletsTableTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$OperationsTableTable, List<OperationsTableData>>
  _operationsTableRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.operationsTable,
    aliasName: $_aliasNameGenerator(
      db.walletsTable.id,
      db.operationsTable.walletId,
    ),
  );

  $$OperationsTableTableProcessedTableManager get operationsTableRefs {
    final manager = $$OperationsTableTableTableManager(
      $_db,
      $_db.operationsTable,
    ).filter((f) => f.walletId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _operationsTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $WalletAdjustmentsTableTable,
    List<WalletAdjustmentsTableData>
  >
  _walletAdjustmentsTableRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.walletAdjustmentsTable,
        aliasName: $_aliasNameGenerator(
          db.walletsTable.id,
          db.walletAdjustmentsTable.walletId,
        ),
      );

  $$WalletAdjustmentsTableTableProcessedTableManager
  get walletAdjustmentsTableRefs {
    final manager = $$WalletAdjustmentsTableTableTableManager(
      $_db,
      $_db.walletAdjustmentsTable,
    ).filter((f) => f.walletId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _walletAdjustmentsTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$WalletsTableTableFilterComposer
    extends Composer<_$AppDatabase, $WalletsTableTable> {
  $$WalletsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phoneNumber => $composableBuilder(
    column: $table.phoneNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get balance => $composableBuilder(
    column: $table.balance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get dailyLimit => $composableBuilder(
    column: $table.dailyLimit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get weeklyLimit => $composableBuilder(
    column: $table.weeklyLimit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get monthlyLimit => $composableBuilder(
    column: $table.monthlyLimit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> operationsTableRefs(
    Expression<bool> Function($$OperationsTableTableFilterComposer f) f,
  ) {
    final $$OperationsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.operationsTable,
      getReferencedColumn: (t) => t.walletId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OperationsTableTableFilterComposer(
            $db: $db,
            $table: $db.operationsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> walletAdjustmentsTableRefs(
    Expression<bool> Function($$WalletAdjustmentsTableTableFilterComposer f) f,
  ) {
    final $$WalletAdjustmentsTableTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.walletAdjustmentsTable,
          getReferencedColumn: (t) => t.walletId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$WalletAdjustmentsTableTableFilterComposer(
                $db: $db,
                $table: $db.walletAdjustmentsTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$WalletsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $WalletsTableTable> {
  $$WalletsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phoneNumber => $composableBuilder(
    column: $table.phoneNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get balance => $composableBuilder(
    column: $table.balance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get dailyLimit => $composableBuilder(
    column: $table.dailyLimit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weeklyLimit => $composableBuilder(
    column: $table.weeklyLimit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get monthlyLimit => $composableBuilder(
    column: $table.monthlyLimit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WalletsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $WalletsTableTable> {
  $$WalletsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get phoneNumber => $composableBuilder(
    column: $table.phoneNumber,
    builder: (column) => column,
  );

  GeneratedColumn<double> get balance =>
      $composableBuilder(column: $table.balance, builder: (column) => column);

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<double> get dailyLimit => $composableBuilder(
    column: $table.dailyLimit,
    builder: (column) => column,
  );

  GeneratedColumn<double> get weeklyLimit => $composableBuilder(
    column: $table.weeklyLimit,
    builder: (column) => column,
  );

  GeneratedColumn<double> get monthlyLimit => $composableBuilder(
    column: $table.monthlyLimit,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> operationsTableRefs<T extends Object>(
    Expression<T> Function($$OperationsTableTableAnnotationComposer a) f,
  ) {
    final $$OperationsTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.operationsTable,
      getReferencedColumn: (t) => t.walletId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OperationsTableTableAnnotationComposer(
            $db: $db,
            $table: $db.operationsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> walletAdjustmentsTableRefs<T extends Object>(
    Expression<T> Function($$WalletAdjustmentsTableTableAnnotationComposer a) f,
  ) {
    final $$WalletAdjustmentsTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.walletAdjustmentsTable,
          getReferencedColumn: (t) => t.walletId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$WalletAdjustmentsTableTableAnnotationComposer(
                $db: $db,
                $table: $db.walletAdjustmentsTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$WalletsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WalletsTableTable,
          WalletsTableData,
          $$WalletsTableTableFilterComposer,
          $$WalletsTableTableOrderingComposer,
          $$WalletsTableTableAnnotationComposer,
          $$WalletsTableTableCreateCompanionBuilder,
          $$WalletsTableTableUpdateCompanionBuilder,
          (WalletsTableData, $$WalletsTableTableReferences),
          WalletsTableData,
          PrefetchHooks Function({
            bool operationsTableRefs,
            bool walletAdjustmentsTableRefs,
          })
        > {
  $$WalletsTableTableTableManager(_$AppDatabase db, $WalletsTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$WalletsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$WalletsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () =>
                  $$WalletsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> phoneNumber = const Value.absent(),
                Value<double> balance = const Value.absent(),
                Value<String> color = const Value.absent(),
                Value<double> dailyLimit = const Value.absent(),
                Value<double> weeklyLimit = const Value.absent(),
                Value<double> monthlyLimit = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => WalletsTableCompanion(
                id: id,
                name: name,
                phoneNumber: phoneNumber,
                balance: balance,
                color: color,
                dailyLimit: dailyLimit,
                weeklyLimit: weeklyLimit,
                monthlyLimit: monthlyLimit,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String?> phoneNumber = const Value.absent(),
                Value<double> balance = const Value.absent(),
                Value<String> color = const Value.absent(),
                Value<double> dailyLimit = const Value.absent(),
                Value<double> weeklyLimit = const Value.absent(),
                Value<double> monthlyLimit = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => WalletsTableCompanion.insert(
                id: id,
                name: name,
                phoneNumber: phoneNumber,
                balance: balance,
                color: color,
                dailyLimit: dailyLimit,
                weeklyLimit: weeklyLimit,
                monthlyLimit: monthlyLimit,
                createdAt: createdAt,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$WalletsTableTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({
            operationsTableRefs = false,
            walletAdjustmentsTableRefs = false,
          }) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (operationsTableRefs) db.operationsTable,
                if (walletAdjustmentsTableRefs) db.walletAdjustmentsTable,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (operationsTableRefs)
                    await $_getPrefetchedData<
                      WalletsTableData,
                      $WalletsTableTable,
                      OperationsTableData
                    >(
                      currentTable: table,
                      referencedTable: $$WalletsTableTableReferences
                          ._operationsTableRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$WalletsTableTableReferences(
                                db,
                                table,
                                p0,
                              ).operationsTableRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) => referencedItems.where(
                            (e) => e.walletId == item.id,
                          ),
                      typedResults: items,
                    ),
                  if (walletAdjustmentsTableRefs)
                    await $_getPrefetchedData<
                      WalletsTableData,
                      $WalletsTableTable,
                      WalletAdjustmentsTableData
                    >(
                      currentTable: table,
                      referencedTable: $$WalletsTableTableReferences
                          ._walletAdjustmentsTableRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$WalletsTableTableReferences(
                                db,
                                table,
                                p0,
                              ).walletAdjustmentsTableRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) => referencedItems.where(
                            (e) => e.walletId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$WalletsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WalletsTableTable,
      WalletsTableData,
      $$WalletsTableTableFilterComposer,
      $$WalletsTableTableOrderingComposer,
      $$WalletsTableTableAnnotationComposer,
      $$WalletsTableTableCreateCompanionBuilder,
      $$WalletsTableTableUpdateCompanionBuilder,
      (WalletsTableData, $$WalletsTableTableReferences),
      WalletsTableData,
      PrefetchHooks Function({
        bool operationsTableRefs,
        bool walletAdjustmentsTableRefs,
      })
    >;
typedef $$OperationsTableTableCreateCompanionBuilder =
    OperationsTableCompanion Function({
      Value<int> id,
      required int walletId,
      Value<int?> shiftId,
      Value<String> operationType,
      Value<String> providerType,
      required double amount,
      Value<double> commission,
      Value<double> networkFee,
      Value<String?> phoneNumber,
      Value<String?> notes,
      Value<bool> isDebt,
      Value<int?> instaPayAccountId,
      Value<DateTime> createdAt,
    });
typedef $$OperationsTableTableUpdateCompanionBuilder =
    OperationsTableCompanion Function({
      Value<int> id,
      Value<int> walletId,
      Value<int?> shiftId,
      Value<String> operationType,
      Value<String> providerType,
      Value<double> amount,
      Value<double> commission,
      Value<double> networkFee,
      Value<String?> phoneNumber,
      Value<String?> notes,
      Value<bool> isDebt,
      Value<int?> instaPayAccountId,
      Value<DateTime> createdAt,
    });

final class $$OperationsTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $OperationsTableTable,
          OperationsTableData
        > {
  $$OperationsTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $WalletsTableTable _walletIdTable(_$AppDatabase db) =>
      db.walletsTable.createAlias(
        $_aliasNameGenerator(db.operationsTable.walletId, db.walletsTable.id),
      );

  $$WalletsTableTableProcessedTableManager get walletId {
    final $_column = $_itemColumn<int>('wallet_id')!;

    final manager = $$WalletsTableTableTableManager(
      $_db,
      $_db.walletsTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_walletIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$DebtsTableTable, List<DebtsTableData>>
  _debtsTableRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.debtsTable,
    aliasName: $_aliasNameGenerator(
      db.operationsTable.id,
      db.debtsTable.operationId,
    ),
  );

  $$DebtsTableTableProcessedTableManager get debtsTableRefs {
    final manager = $$DebtsTableTableTableManager(
      $_db,
      $_db.debtsTable,
    ).filter((f) => f.operationId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_debtsTableRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$OperationsTableTableFilterComposer
    extends Composer<_$AppDatabase, $OperationsTableTable> {
  $$OperationsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get shiftId => $composableBuilder(
    column: $table.shiftId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get operationType => $composableBuilder(
    column: $table.operationType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get providerType => $composableBuilder(
    column: $table.providerType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get commission => $composableBuilder(
    column: $table.commission,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get networkFee => $composableBuilder(
    column: $table.networkFee,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phoneNumber => $composableBuilder(
    column: $table.phoneNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDebt => $composableBuilder(
    column: $table.isDebt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get instaPayAccountId => $composableBuilder(
    column: $table.instaPayAccountId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$WalletsTableTableFilterComposer get walletId {
    final $$WalletsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.walletId,
      referencedTable: $db.walletsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WalletsTableTableFilterComposer(
            $db: $db,
            $table: $db.walletsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> debtsTableRefs(
    Expression<bool> Function($$DebtsTableTableFilterComposer f) f,
  ) {
    final $$DebtsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.debtsTable,
      getReferencedColumn: (t) => t.operationId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DebtsTableTableFilterComposer(
            $db: $db,
            $table: $db.debtsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$OperationsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $OperationsTableTable> {
  $$OperationsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get shiftId => $composableBuilder(
    column: $table.shiftId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get operationType => $composableBuilder(
    column: $table.operationType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get providerType => $composableBuilder(
    column: $table.providerType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get commission => $composableBuilder(
    column: $table.commission,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get networkFee => $composableBuilder(
    column: $table.networkFee,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phoneNumber => $composableBuilder(
    column: $table.phoneNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDebt => $composableBuilder(
    column: $table.isDebt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get instaPayAccountId => $composableBuilder(
    column: $table.instaPayAccountId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$WalletsTableTableOrderingComposer get walletId {
    final $$WalletsTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.walletId,
      referencedTable: $db.walletsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WalletsTableTableOrderingComposer(
            $db: $db,
            $table: $db.walletsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$OperationsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $OperationsTableTable> {
  $$OperationsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get shiftId =>
      $composableBuilder(column: $table.shiftId, builder: (column) => column);

  GeneratedColumn<String> get operationType => $composableBuilder(
    column: $table.operationType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get providerType => $composableBuilder(
    column: $table.providerType,
    builder: (column) => column,
  );

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<double> get commission => $composableBuilder(
    column: $table.commission,
    builder: (column) => column,
  );

  GeneratedColumn<double> get networkFee => $composableBuilder(
    column: $table.networkFee,
    builder: (column) => column,
  );

  GeneratedColumn<String> get phoneNumber => $composableBuilder(
    column: $table.phoneNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<bool> get isDebt =>
      $composableBuilder(column: $table.isDebt, builder: (column) => column);

  GeneratedColumn<int> get instaPayAccountId => $composableBuilder(
    column: $table.instaPayAccountId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$WalletsTableTableAnnotationComposer get walletId {
    final $$WalletsTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.walletId,
      referencedTable: $db.walletsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WalletsTableTableAnnotationComposer(
            $db: $db,
            $table: $db.walletsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> debtsTableRefs<T extends Object>(
    Expression<T> Function($$DebtsTableTableAnnotationComposer a) f,
  ) {
    final $$DebtsTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.debtsTable,
      getReferencedColumn: (t) => t.operationId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DebtsTableTableAnnotationComposer(
            $db: $db,
            $table: $db.debtsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$OperationsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OperationsTableTable,
          OperationsTableData,
          $$OperationsTableTableFilterComposer,
          $$OperationsTableTableOrderingComposer,
          $$OperationsTableTableAnnotationComposer,
          $$OperationsTableTableCreateCompanionBuilder,
          $$OperationsTableTableUpdateCompanionBuilder,
          (OperationsTableData, $$OperationsTableTableReferences),
          OperationsTableData,
          PrefetchHooks Function({bool walletId, bool debtsTableRefs})
        > {
  $$OperationsTableTableTableManager(
    _$AppDatabase db,
    $OperationsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () =>
                  $$OperationsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$OperationsTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer:
              () => $$OperationsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> walletId = const Value.absent(),
                Value<int?> shiftId = const Value.absent(),
                Value<String> operationType = const Value.absent(),
                Value<String> providerType = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<double> commission = const Value.absent(),
                Value<double> networkFee = const Value.absent(),
                Value<String?> phoneNumber = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<bool> isDebt = const Value.absent(),
                Value<int?> instaPayAccountId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => OperationsTableCompanion(
                id: id,
                walletId: walletId,
                shiftId: shiftId,
                operationType: operationType,
                providerType: providerType,
                amount: amount,
                commission: commission,
                networkFee: networkFee,
                phoneNumber: phoneNumber,
                notes: notes,
                isDebt: isDebt,
                instaPayAccountId: instaPayAccountId,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int walletId,
                Value<int?> shiftId = const Value.absent(),
                Value<String> operationType = const Value.absent(),
                Value<String> providerType = const Value.absent(),
                required double amount,
                Value<double> commission = const Value.absent(),
                Value<double> networkFee = const Value.absent(),
                Value<String?> phoneNumber = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<bool> isDebt = const Value.absent(),
                Value<int?> instaPayAccountId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => OperationsTableCompanion.insert(
                id: id,
                walletId: walletId,
                shiftId: shiftId,
                operationType: operationType,
                providerType: providerType,
                amount: amount,
                commission: commission,
                networkFee: networkFee,
                phoneNumber: phoneNumber,
                notes: notes,
                isDebt: isDebt,
                instaPayAccountId: instaPayAccountId,
                createdAt: createdAt,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$OperationsTableTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({walletId = false, debtsTableRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (debtsTableRefs) db.debtsTable],
              addJoins: <
                T extends TableManagerState<
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic
                >
              >(state) {
                if (walletId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.walletId,
                            referencedTable: $$OperationsTableTableReferences
                                ._walletIdTable(db),
                            referencedColumn:
                                $$OperationsTableTableReferences
                                    ._walletIdTable(db)
                                    .id,
                          )
                          as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (debtsTableRefs)
                    await $_getPrefetchedData<
                      OperationsTableData,
                      $OperationsTableTable,
                      DebtsTableData
                    >(
                      currentTable: table,
                      referencedTable: $$OperationsTableTableReferences
                          ._debtsTableRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$OperationsTableTableReferences(
                                db,
                                table,
                                p0,
                              ).debtsTableRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) => referencedItems.where(
                            (e) => e.operationId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$OperationsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OperationsTableTable,
      OperationsTableData,
      $$OperationsTableTableFilterComposer,
      $$OperationsTableTableOrderingComposer,
      $$OperationsTableTableAnnotationComposer,
      $$OperationsTableTableCreateCompanionBuilder,
      $$OperationsTableTableUpdateCompanionBuilder,
      (OperationsTableData, $$OperationsTableTableReferences),
      OperationsTableData,
      PrefetchHooks Function({bool walletId, bool debtsTableRefs})
    >;
typedef $$CashDrawerTableTableCreateCompanionBuilder =
    CashDrawerTableCompanion Function({
      Value<int> id,
      Value<double> balance,
      Value<double> initialBalance,
      Value<DateTime> updatedAt,
    });
typedef $$CashDrawerTableTableUpdateCompanionBuilder =
    CashDrawerTableCompanion Function({
      Value<int> id,
      Value<double> balance,
      Value<double> initialBalance,
      Value<DateTime> updatedAt,
    });

class $$CashDrawerTableTableFilterComposer
    extends Composer<_$AppDatabase, $CashDrawerTableTable> {
  $$CashDrawerTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get balance => $composableBuilder(
    column: $table.balance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get initialBalance => $composableBuilder(
    column: $table.initialBalance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CashDrawerTableTableOrderingComposer
    extends Composer<_$AppDatabase, $CashDrawerTableTable> {
  $$CashDrawerTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get balance => $composableBuilder(
    column: $table.balance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get initialBalance => $composableBuilder(
    column: $table.initialBalance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CashDrawerTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $CashDrawerTableTable> {
  $$CashDrawerTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get balance =>
      $composableBuilder(column: $table.balance, builder: (column) => column);

  GeneratedColumn<double> get initialBalance => $composableBuilder(
    column: $table.initialBalance,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$CashDrawerTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CashDrawerTableTable,
          CashDrawerTableData,
          $$CashDrawerTableTableFilterComposer,
          $$CashDrawerTableTableOrderingComposer,
          $$CashDrawerTableTableAnnotationComposer,
          $$CashDrawerTableTableCreateCompanionBuilder,
          $$CashDrawerTableTableUpdateCompanionBuilder,
          (
            CashDrawerTableData,
            BaseReferences<
              _$AppDatabase,
              $CashDrawerTableTable,
              CashDrawerTableData
            >,
          ),
          CashDrawerTableData,
          PrefetchHooks Function()
        > {
  $$CashDrawerTableTableTableManager(
    _$AppDatabase db,
    $CashDrawerTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () =>
                  $$CashDrawerTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$CashDrawerTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer:
              () => $$CashDrawerTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<double> balance = const Value.absent(),
                Value<double> initialBalance = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => CashDrawerTableCompanion(
                id: id,
                balance: balance,
                initialBalance: initialBalance,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<double> balance = const Value.absent(),
                Value<double> initialBalance = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => CashDrawerTableCompanion.insert(
                id: id,
                balance: balance,
                initialBalance: initialBalance,
                updatedAt: updatedAt,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CashDrawerTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CashDrawerTableTable,
      CashDrawerTableData,
      $$CashDrawerTableTableFilterComposer,
      $$CashDrawerTableTableOrderingComposer,
      $$CashDrawerTableTableAnnotationComposer,
      $$CashDrawerTableTableCreateCompanionBuilder,
      $$CashDrawerTableTableUpdateCompanionBuilder,
      (
        CashDrawerTableData,
        BaseReferences<
          _$AppDatabase,
          $CashDrawerTableTable,
          CashDrawerTableData
        >,
      ),
      CashDrawerTableData,
      PrefetchHooks Function()
    >;
typedef $$WalletAdjustmentsTableTableCreateCompanionBuilder =
    WalletAdjustmentsTableCompanion Function({
      Value<int> id,
      required int walletId,
      required String periodType,
      required double amount,
      Value<String?> reason,
      Value<DateTime> createdAt,
    });
typedef $$WalletAdjustmentsTableTableUpdateCompanionBuilder =
    WalletAdjustmentsTableCompanion Function({
      Value<int> id,
      Value<int> walletId,
      Value<String> periodType,
      Value<double> amount,
      Value<String?> reason,
      Value<DateTime> createdAt,
    });

final class $$WalletAdjustmentsTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $WalletAdjustmentsTableTable,
          WalletAdjustmentsTableData
        > {
  $$WalletAdjustmentsTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $WalletsTableTable _walletIdTable(_$AppDatabase db) =>
      db.walletsTable.createAlias(
        $_aliasNameGenerator(
          db.walletAdjustmentsTable.walletId,
          db.walletsTable.id,
        ),
      );

  $$WalletsTableTableProcessedTableManager get walletId {
    final $_column = $_itemColumn<int>('wallet_id')!;

    final manager = $$WalletsTableTableTableManager(
      $_db,
      $_db.walletsTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_walletIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$WalletAdjustmentsTableTableFilterComposer
    extends Composer<_$AppDatabase, $WalletAdjustmentsTableTable> {
  $$WalletAdjustmentsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get periodType => $composableBuilder(
    column: $table.periodType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$WalletsTableTableFilterComposer get walletId {
    final $$WalletsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.walletId,
      referencedTable: $db.walletsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WalletsTableTableFilterComposer(
            $db: $db,
            $table: $db.walletsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WalletAdjustmentsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $WalletAdjustmentsTableTable> {
  $$WalletAdjustmentsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get periodType => $composableBuilder(
    column: $table.periodType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$WalletsTableTableOrderingComposer get walletId {
    final $$WalletsTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.walletId,
      referencedTable: $db.walletsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WalletsTableTableOrderingComposer(
            $db: $db,
            $table: $db.walletsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WalletAdjustmentsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $WalletAdjustmentsTableTable> {
  $$WalletAdjustmentsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get periodType => $composableBuilder(
    column: $table.periodType,
    builder: (column) => column,
  );

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$WalletsTableTableAnnotationComposer get walletId {
    final $$WalletsTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.walletId,
      referencedTable: $db.walletsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WalletsTableTableAnnotationComposer(
            $db: $db,
            $table: $db.walletsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WalletAdjustmentsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WalletAdjustmentsTableTable,
          WalletAdjustmentsTableData,
          $$WalletAdjustmentsTableTableFilterComposer,
          $$WalletAdjustmentsTableTableOrderingComposer,
          $$WalletAdjustmentsTableTableAnnotationComposer,
          $$WalletAdjustmentsTableTableCreateCompanionBuilder,
          $$WalletAdjustmentsTableTableUpdateCompanionBuilder,
          (WalletAdjustmentsTableData, $$WalletAdjustmentsTableTableReferences),
          WalletAdjustmentsTableData,
          PrefetchHooks Function({bool walletId})
        > {
  $$WalletAdjustmentsTableTableTableManager(
    _$AppDatabase db,
    $WalletAdjustmentsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$WalletAdjustmentsTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer:
              () => $$WalletAdjustmentsTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer:
              () => $$WalletAdjustmentsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> walletId = const Value.absent(),
                Value<String> periodType = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<String?> reason = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => WalletAdjustmentsTableCompanion(
                id: id,
                walletId: walletId,
                periodType: periodType,
                amount: amount,
                reason: reason,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int walletId,
                required String periodType,
                required double amount,
                Value<String?> reason = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => WalletAdjustmentsTableCompanion.insert(
                id: id,
                walletId: walletId,
                periodType: periodType,
                amount: amount,
                reason: reason,
                createdAt: createdAt,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$WalletAdjustmentsTableTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({walletId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                T extends TableManagerState<
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic
                >
              >(state) {
                if (walletId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.walletId,
                            referencedTable:
                                $$WalletAdjustmentsTableTableReferences
                                    ._walletIdTable(db),
                            referencedColumn:
                                $$WalletAdjustmentsTableTableReferences
                                    ._walletIdTable(db)
                                    .id,
                          )
                          as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$WalletAdjustmentsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WalletAdjustmentsTableTable,
      WalletAdjustmentsTableData,
      $$WalletAdjustmentsTableTableFilterComposer,
      $$WalletAdjustmentsTableTableOrderingComposer,
      $$WalletAdjustmentsTableTableAnnotationComposer,
      $$WalletAdjustmentsTableTableCreateCompanionBuilder,
      $$WalletAdjustmentsTableTableUpdateCompanionBuilder,
      (WalletAdjustmentsTableData, $$WalletAdjustmentsTableTableReferences),
      WalletAdjustmentsTableData,
      PrefetchHooks Function({bool walletId})
    >;
typedef $$ShiftsTableTableCreateCompanionBuilder =
    ShiftsTableCompanion Function({
      Value<int> id,
      required DateTime startTime,
      Value<DateTime?> endTime,
      required double openingCashDrawer,
      Value<double?> closingCashDrawer,
      Value<String?> notes,
      Value<DateTime> createdAt,
    });
typedef $$ShiftsTableTableUpdateCompanionBuilder =
    ShiftsTableCompanion Function({
      Value<int> id,
      Value<DateTime> startTime,
      Value<DateTime?> endTime,
      Value<double> openingCashDrawer,
      Value<double?> closingCashDrawer,
      Value<String?> notes,
      Value<DateTime> createdAt,
    });

class $$ShiftsTableTableFilterComposer
    extends Composer<_$AppDatabase, $ShiftsTableTable> {
  $$ShiftsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startTime => $composableBuilder(
    column: $table.startTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endTime => $composableBuilder(
    column: $table.endTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get openingCashDrawer => $composableBuilder(
    column: $table.openingCashDrawer,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get closingCashDrawer => $composableBuilder(
    column: $table.closingCashDrawer,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ShiftsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ShiftsTableTable> {
  $$ShiftsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startTime => $composableBuilder(
    column: $table.startTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endTime => $composableBuilder(
    column: $table.endTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get openingCashDrawer => $composableBuilder(
    column: $table.openingCashDrawer,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get closingCashDrawer => $composableBuilder(
    column: $table.closingCashDrawer,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ShiftsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ShiftsTableTable> {
  $$ShiftsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get startTime =>
      $composableBuilder(column: $table.startTime, builder: (column) => column);

  GeneratedColumn<DateTime> get endTime =>
      $composableBuilder(column: $table.endTime, builder: (column) => column);

  GeneratedColumn<double> get openingCashDrawer => $composableBuilder(
    column: $table.openingCashDrawer,
    builder: (column) => column,
  );

  GeneratedColumn<double> get closingCashDrawer => $composableBuilder(
    column: $table.closingCashDrawer,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$ShiftsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ShiftsTableTable,
          ShiftsTableData,
          $$ShiftsTableTableFilterComposer,
          $$ShiftsTableTableOrderingComposer,
          $$ShiftsTableTableAnnotationComposer,
          $$ShiftsTableTableCreateCompanionBuilder,
          $$ShiftsTableTableUpdateCompanionBuilder,
          (
            ShiftsTableData,
            BaseReferences<_$AppDatabase, $ShiftsTableTable, ShiftsTableData>,
          ),
          ShiftsTableData,
          PrefetchHooks Function()
        > {
  $$ShiftsTableTableTableManager(_$AppDatabase db, $ShiftsTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$ShiftsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$ShiftsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () =>
                  $$ShiftsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> startTime = const Value.absent(),
                Value<DateTime?> endTime = const Value.absent(),
                Value<double> openingCashDrawer = const Value.absent(),
                Value<double?> closingCashDrawer = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => ShiftsTableCompanion(
                id: id,
                startTime: startTime,
                endTime: endTime,
                openingCashDrawer: openingCashDrawer,
                closingCashDrawer: closingCashDrawer,
                notes: notes,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime startTime,
                Value<DateTime?> endTime = const Value.absent(),
                required double openingCashDrawer,
                Value<double?> closingCashDrawer = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => ShiftsTableCompanion.insert(
                id: id,
                startTime: startTime,
                endTime: endTime,
                openingCashDrawer: openingCashDrawer,
                closingCashDrawer: closingCashDrawer,
                notes: notes,
                createdAt: createdAt,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ShiftsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ShiftsTableTable,
      ShiftsTableData,
      $$ShiftsTableTableFilterComposer,
      $$ShiftsTableTableOrderingComposer,
      $$ShiftsTableTableAnnotationComposer,
      $$ShiftsTableTableCreateCompanionBuilder,
      $$ShiftsTableTableUpdateCompanionBuilder,
      (
        ShiftsTableData,
        BaseReferences<_$AppDatabase, $ShiftsTableTable, ShiftsTableData>,
      ),
      ShiftsTableData,
      PrefetchHooks Function()
    >;
typedef $$DebtorsTableTableCreateCompanionBuilder =
    DebtorsTableCompanion Function({
      Value<int> id,
      required String name,
      Value<String?> phone,
      Value<String?> notes,
      Value<DateTime> createdAt,
    });
typedef $$DebtorsTableTableUpdateCompanionBuilder =
    DebtorsTableCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String?> phone,
      Value<String?> notes,
      Value<DateTime> createdAt,
    });

final class $$DebtorsTableTableReferences
    extends
        BaseReferences<_$AppDatabase, $DebtorsTableTable, DebtorsTableData> {
  $$DebtorsTableTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$DebtsTableTable, List<DebtsTableData>>
  _debtsTableRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.debtsTable,
    aliasName: $_aliasNameGenerator(db.debtorsTable.id, db.debtsTable.debtorId),
  );

  $$DebtsTableTableProcessedTableManager get debtsTableRefs {
    final manager = $$DebtsTableTableTableManager(
      $_db,
      $_db.debtsTable,
    ).filter((f) => f.debtorId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_debtsTableRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$DebtorsTableTableFilterComposer
    extends Composer<_$AppDatabase, $DebtorsTableTable> {
  $$DebtorsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> debtsTableRefs(
    Expression<bool> Function($$DebtsTableTableFilterComposer f) f,
  ) {
    final $$DebtsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.debtsTable,
      getReferencedColumn: (t) => t.debtorId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DebtsTableTableFilterComposer(
            $db: $db,
            $table: $db.debtsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DebtorsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $DebtorsTableTable> {
  $$DebtorsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DebtorsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $DebtorsTableTable> {
  $$DebtorsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> debtsTableRefs<T extends Object>(
    Expression<T> Function($$DebtsTableTableAnnotationComposer a) f,
  ) {
    final $$DebtsTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.debtsTable,
      getReferencedColumn: (t) => t.debtorId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DebtsTableTableAnnotationComposer(
            $db: $db,
            $table: $db.debtsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DebtorsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DebtorsTableTable,
          DebtorsTableData,
          $$DebtorsTableTableFilterComposer,
          $$DebtorsTableTableOrderingComposer,
          $$DebtorsTableTableAnnotationComposer,
          $$DebtorsTableTableCreateCompanionBuilder,
          $$DebtorsTableTableUpdateCompanionBuilder,
          (DebtorsTableData, $$DebtorsTableTableReferences),
          DebtorsTableData,
          PrefetchHooks Function({bool debtsTableRefs})
        > {
  $$DebtorsTableTableTableManager(_$AppDatabase db, $DebtorsTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$DebtorsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$DebtorsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () =>
                  $$DebtorsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => DebtorsTableCompanion(
                id: id,
                name: name,
                phone: phone,
                notes: notes,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String?> phone = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => DebtorsTableCompanion.insert(
                id: id,
                name: name,
                phone: phone,
                notes: notes,
                createdAt: createdAt,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$DebtorsTableTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({debtsTableRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (debtsTableRefs) db.debtsTable],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (debtsTableRefs)
                    await $_getPrefetchedData<
                      DebtorsTableData,
                      $DebtorsTableTable,
                      DebtsTableData
                    >(
                      currentTable: table,
                      referencedTable: $$DebtorsTableTableReferences
                          ._debtsTableRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$DebtorsTableTableReferences(
                                db,
                                table,
                                p0,
                              ).debtsTableRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) => referencedItems.where(
                            (e) => e.debtorId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$DebtorsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DebtorsTableTable,
      DebtorsTableData,
      $$DebtorsTableTableFilterComposer,
      $$DebtorsTableTableOrderingComposer,
      $$DebtorsTableTableAnnotationComposer,
      $$DebtorsTableTableCreateCompanionBuilder,
      $$DebtorsTableTableUpdateCompanionBuilder,
      (DebtorsTableData, $$DebtorsTableTableReferences),
      DebtorsTableData,
      PrefetchHooks Function({bool debtsTableRefs})
    >;
typedef $$DebtsTableTableCreateCompanionBuilder =
    DebtsTableCompanion Function({
      Value<int> id,
      required int debtorId,
      Value<int?> operationId,
      Value<String> operationType,
      Value<String?> providerType,
      required double amount,
      Value<bool> isPaid,
      Value<bool> isCashLoan,
      Value<DateTime?> paidAt,
      Value<DateTime> createdAt,
    });
typedef $$DebtsTableTableUpdateCompanionBuilder =
    DebtsTableCompanion Function({
      Value<int> id,
      Value<int> debtorId,
      Value<int?> operationId,
      Value<String> operationType,
      Value<String?> providerType,
      Value<double> amount,
      Value<bool> isPaid,
      Value<bool> isCashLoan,
      Value<DateTime?> paidAt,
      Value<DateTime> createdAt,
    });

final class $$DebtsTableTableReferences
    extends BaseReferences<_$AppDatabase, $DebtsTableTable, DebtsTableData> {
  $$DebtsTableTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $DebtorsTableTable _debtorIdTable(_$AppDatabase db) =>
      db.debtorsTable.createAlias(
        $_aliasNameGenerator(db.debtsTable.debtorId, db.debtorsTable.id),
      );

  $$DebtorsTableTableProcessedTableManager get debtorId {
    final $_column = $_itemColumn<int>('debtor_id')!;

    final manager = $$DebtorsTableTableTableManager(
      $_db,
      $_db.debtorsTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_debtorIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $OperationsTableTable _operationIdTable(_$AppDatabase db) =>
      db.operationsTable.createAlias(
        $_aliasNameGenerator(db.debtsTable.operationId, db.operationsTable.id),
      );

  $$OperationsTableTableProcessedTableManager? get operationId {
    final $_column = $_itemColumn<int>('operation_id');
    if ($_column == null) return null;
    final manager = $$OperationsTableTableTableManager(
      $_db,
      $_db.operationsTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_operationIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$DebtsTableTableFilterComposer
    extends Composer<_$AppDatabase, $DebtsTableTable> {
  $$DebtsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get operationType => $composableBuilder(
    column: $table.operationType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get providerType => $composableBuilder(
    column: $table.providerType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPaid => $composableBuilder(
    column: $table.isPaid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCashLoan => $composableBuilder(
    column: $table.isCashLoan,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get paidAt => $composableBuilder(
    column: $table.paidAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$DebtorsTableTableFilterComposer get debtorId {
    final $$DebtorsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.debtorId,
      referencedTable: $db.debtorsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DebtorsTableTableFilterComposer(
            $db: $db,
            $table: $db.debtorsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$OperationsTableTableFilterComposer get operationId {
    final $$OperationsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.operationId,
      referencedTable: $db.operationsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OperationsTableTableFilterComposer(
            $db: $db,
            $table: $db.operationsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DebtsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $DebtsTableTable> {
  $$DebtsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get operationType => $composableBuilder(
    column: $table.operationType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get providerType => $composableBuilder(
    column: $table.providerType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPaid => $composableBuilder(
    column: $table.isPaid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCashLoan => $composableBuilder(
    column: $table.isCashLoan,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get paidAt => $composableBuilder(
    column: $table.paidAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$DebtorsTableTableOrderingComposer get debtorId {
    final $$DebtorsTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.debtorId,
      referencedTable: $db.debtorsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DebtorsTableTableOrderingComposer(
            $db: $db,
            $table: $db.debtorsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$OperationsTableTableOrderingComposer get operationId {
    final $$OperationsTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.operationId,
      referencedTable: $db.operationsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OperationsTableTableOrderingComposer(
            $db: $db,
            $table: $db.operationsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DebtsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $DebtsTableTable> {
  $$DebtsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get operationType => $composableBuilder(
    column: $table.operationType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get providerType => $composableBuilder(
    column: $table.providerType,
    builder: (column) => column,
  );

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<bool> get isPaid =>
      $composableBuilder(column: $table.isPaid, builder: (column) => column);

  GeneratedColumn<bool> get isCashLoan => $composableBuilder(
    column: $table.isCashLoan,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get paidAt =>
      $composableBuilder(column: $table.paidAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$DebtorsTableTableAnnotationComposer get debtorId {
    final $$DebtorsTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.debtorId,
      referencedTable: $db.debtorsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DebtorsTableTableAnnotationComposer(
            $db: $db,
            $table: $db.debtorsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$OperationsTableTableAnnotationComposer get operationId {
    final $$OperationsTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.operationId,
      referencedTable: $db.operationsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OperationsTableTableAnnotationComposer(
            $db: $db,
            $table: $db.operationsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DebtsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DebtsTableTable,
          DebtsTableData,
          $$DebtsTableTableFilterComposer,
          $$DebtsTableTableOrderingComposer,
          $$DebtsTableTableAnnotationComposer,
          $$DebtsTableTableCreateCompanionBuilder,
          $$DebtsTableTableUpdateCompanionBuilder,
          (DebtsTableData, $$DebtsTableTableReferences),
          DebtsTableData,
          PrefetchHooks Function({bool debtorId, bool operationId})
        > {
  $$DebtsTableTableTableManager(_$AppDatabase db, $DebtsTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$DebtsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$DebtsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$DebtsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> debtorId = const Value.absent(),
                Value<int?> operationId = const Value.absent(),
                Value<String> operationType = const Value.absent(),
                Value<String?> providerType = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<bool> isPaid = const Value.absent(),
                Value<bool> isCashLoan = const Value.absent(),
                Value<DateTime?> paidAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => DebtsTableCompanion(
                id: id,
                debtorId: debtorId,
                operationId: operationId,
                operationType: operationType,
                providerType: providerType,
                amount: amount,
                isPaid: isPaid,
                isCashLoan: isCashLoan,
                paidAt: paidAt,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int debtorId,
                Value<int?> operationId = const Value.absent(),
                Value<String> operationType = const Value.absent(),
                Value<String?> providerType = const Value.absent(),
                required double amount,
                Value<bool> isPaid = const Value.absent(),
                Value<bool> isCashLoan = const Value.absent(),
                Value<DateTime?> paidAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => DebtsTableCompanion.insert(
                id: id,
                debtorId: debtorId,
                operationId: operationId,
                operationType: operationType,
                providerType: providerType,
                amount: amount,
                isPaid: isPaid,
                isCashLoan: isCashLoan,
                paidAt: paidAt,
                createdAt: createdAt,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$DebtsTableTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({debtorId = false, operationId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                T extends TableManagerState<
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic
                >
              >(state) {
                if (debtorId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.debtorId,
                            referencedTable: $$DebtsTableTableReferences
                                ._debtorIdTable(db),
                            referencedColumn:
                                $$DebtsTableTableReferences
                                    ._debtorIdTable(db)
                                    .id,
                          )
                          as T;
                }
                if (operationId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.operationId,
                            referencedTable: $$DebtsTableTableReferences
                                ._operationIdTable(db),
                            referencedColumn:
                                $$DebtsTableTableReferences
                                    ._operationIdTable(db)
                                    .id,
                          )
                          as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$DebtsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DebtsTableTable,
      DebtsTableData,
      $$DebtsTableTableFilterComposer,
      $$DebtsTableTableOrderingComposer,
      $$DebtsTableTableAnnotationComposer,
      $$DebtsTableTableCreateCompanionBuilder,
      $$DebtsTableTableUpdateCompanionBuilder,
      (DebtsTableData, $$DebtsTableTableReferences),
      DebtsTableData,
      PrefetchHooks Function({bool debtorId, bool operationId})
    >;
typedef $$InstaPayAccountsTableTableCreateCompanionBuilder =
    InstaPayAccountsTableCompanion Function({
      Value<int> id,
      required String name,
      Value<DateTime> createdAt,
    });
typedef $$InstaPayAccountsTableTableUpdateCompanionBuilder =
    InstaPayAccountsTableCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<DateTime> createdAt,
    });

class $$InstaPayAccountsTableTableFilterComposer
    extends Composer<_$AppDatabase, $InstaPayAccountsTableTable> {
  $$InstaPayAccountsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$InstaPayAccountsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $InstaPayAccountsTableTable> {
  $$InstaPayAccountsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$InstaPayAccountsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $InstaPayAccountsTableTable> {
  $$InstaPayAccountsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$InstaPayAccountsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $InstaPayAccountsTableTable,
          InstaPayAccountsTableData,
          $$InstaPayAccountsTableTableFilterComposer,
          $$InstaPayAccountsTableTableOrderingComposer,
          $$InstaPayAccountsTableTableAnnotationComposer,
          $$InstaPayAccountsTableTableCreateCompanionBuilder,
          $$InstaPayAccountsTableTableUpdateCompanionBuilder,
          (
            InstaPayAccountsTableData,
            BaseReferences<
              _$AppDatabase,
              $InstaPayAccountsTableTable,
              InstaPayAccountsTableData
            >,
          ),
          InstaPayAccountsTableData,
          PrefetchHooks Function()
        > {
  $$InstaPayAccountsTableTableTableManager(
    _$AppDatabase db,
    $InstaPayAccountsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$InstaPayAccountsTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer:
              () => $$InstaPayAccountsTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer:
              () => $$InstaPayAccountsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => InstaPayAccountsTableCompanion(
                id: id,
                name: name,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<DateTime> createdAt = const Value.absent(),
              }) => InstaPayAccountsTableCompanion.insert(
                id: id,
                name: name,
                createdAt: createdAt,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$InstaPayAccountsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $InstaPayAccountsTableTable,
      InstaPayAccountsTableData,
      $$InstaPayAccountsTableTableFilterComposer,
      $$InstaPayAccountsTableTableOrderingComposer,
      $$InstaPayAccountsTableTableAnnotationComposer,
      $$InstaPayAccountsTableTableCreateCompanionBuilder,
      $$InstaPayAccountsTableTableUpdateCompanionBuilder,
      (
        InstaPayAccountsTableData,
        BaseReferences<
          _$AppDatabase,
          $InstaPayAccountsTableTable,
          InstaPayAccountsTableData
        >,
      ),
      InstaPayAccountsTableData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$TransactionsTableTableTableManager get transactionsTable =>
      $$TransactionsTableTableTableManager(_db, _db.transactionsTable);
  $$WalletsTableTableTableManager get walletsTable =>
      $$WalletsTableTableTableManager(_db, _db.walletsTable);
  $$OperationsTableTableTableManager get operationsTable =>
      $$OperationsTableTableTableManager(_db, _db.operationsTable);
  $$CashDrawerTableTableTableManager get cashDrawerTable =>
      $$CashDrawerTableTableTableManager(_db, _db.cashDrawerTable);
  $$WalletAdjustmentsTableTableTableManager get walletAdjustmentsTable =>
      $$WalletAdjustmentsTableTableTableManager(
        _db,
        _db.walletAdjustmentsTable,
      );
  $$ShiftsTableTableTableManager get shiftsTable =>
      $$ShiftsTableTableTableManager(_db, _db.shiftsTable);
  $$DebtorsTableTableTableManager get debtorsTable =>
      $$DebtorsTableTableTableManager(_db, _db.debtorsTable);
  $$DebtsTableTableTableManager get debtsTable =>
      $$DebtsTableTableTableManager(_db, _db.debtsTable);
  $$InstaPayAccountsTableTableTableManager get instaPayAccountsTable =>
      $$InstaPayAccountsTableTableTableManager(_db, _db.instaPayAccountsTable);
}
