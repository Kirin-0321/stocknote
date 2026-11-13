// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $AppMetaTable extends AppMeta with TableInfo<$AppMetaTable, AppMetaRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppMetaTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_meta';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppMetaRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppMetaRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppMetaRow(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $AppMetaTable createAlias(String alias) {
    return $AppMetaTable(attachedDatabase, alias);
  }
}

class AppMetaRow extends DataClass implements Insertable<AppMetaRow> {
  final String key;
  final String value;
  const AppMetaRow({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  AppMetaCompanion toCompanion(bool nullToAbsent) {
    return AppMetaCompanion(key: Value(key), value: Value(value));
  }

  factory AppMetaRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppMetaRow(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  AppMetaRow copyWith({String? key, String? value}) =>
      AppMetaRow(key: key ?? this.key, value: value ?? this.value);
  AppMetaRow copyWithCompanion(AppMetaCompanion data) {
    return AppMetaRow(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppMetaRow(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppMetaRow &&
          other.key == this.key &&
          other.value == this.value);
}

class AppMetaCompanion extends UpdateCompanion<AppMetaRow> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const AppMetaCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppMetaCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<AppMetaRow> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppMetaCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return AppMetaCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppMetaCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $InstrumentsTable extends Instruments
    with TableInfo<$InstrumentsTable, Instrument> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InstrumentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _exchangeMeta = const VerificationMeta(
    'exchange',
  );
  @override
  late final GeneratedColumn<String> exchange = GeneratedColumn<String>(
    'exchange',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pinyinMeta = const VerificationMeta('pinyin');
  @override
  late final GeneratedColumn<String> pinyin = GeneratedColumn<String>(
    'pinyin',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _listDateMeta = const VerificationMeta(
    'listDate',
  );
  @override
  late final GeneratedColumn<String> listDate = GeneratedColumn<String>(
    'list_date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Map<String, dynamic>?, String>
  extra = GeneratedColumn<String>(
    'extra',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  ).withConverter<Map<String, dynamic>?>($InstrumentsTable.$converterextran);
  @override
  List<GeneratedColumn> get $columns => [
    code,
    name,
    type,
    exchange,
    pinyin,
    listDate,
    extra,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'instruments';
  @override
  VerificationContext validateIntegrity(
    Insertable<Instrument> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('exchange')) {
      context.handle(
        _exchangeMeta,
        exchange.isAcceptableOrUnknown(data['exchange']!, _exchangeMeta),
      );
    }
    if (data.containsKey('pinyin')) {
      context.handle(
        _pinyinMeta,
        pinyin.isAcceptableOrUnknown(data['pinyin']!, _pinyinMeta),
      );
    }
    if (data.containsKey('list_date')) {
      context.handle(
        _listDateMeta,
        listDate.isAcceptableOrUnknown(data['list_date']!, _listDateMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {code};
  @override
  Instrument map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Instrument(
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      exchange: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exchange'],
      ),
      pinyin: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pinyin'],
      ),
      listDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}list_date'],
      ),
      extra: $InstrumentsTable.$converterextran.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}extra'],
        ),
      ),
    );
  }

  @override
  $InstrumentsTable createAlias(String alias) {
    return $InstrumentsTable(attachedDatabase, alias);
  }

  static TypeConverter<Map<String, dynamic>, String> $converterextra =
      const JsonMapConverter();
  static TypeConverter<Map<String, dynamic>?, String?> $converterextran =
      NullAwareTypeConverter.wrap($converterextra);
}

class Instrument extends DataClass implements Insertable<Instrument> {
  final String code;
  final String name;

  /// stock | etf | index | sector
  final String type;
  final String? exchange;
  final String? pinyin;
  final String? listDate;
  final Map<String, dynamic>? extra;
  const Instrument({
    required this.code,
    required this.name,
    required this.type,
    this.exchange,
    this.pinyin,
    this.listDate,
    this.extra,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['code'] = Variable<String>(code);
    map['name'] = Variable<String>(name);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || exchange != null) {
      map['exchange'] = Variable<String>(exchange);
    }
    if (!nullToAbsent || pinyin != null) {
      map['pinyin'] = Variable<String>(pinyin);
    }
    if (!nullToAbsent || listDate != null) {
      map['list_date'] = Variable<String>(listDate);
    }
    if (!nullToAbsent || extra != null) {
      map['extra'] = Variable<String>(
        $InstrumentsTable.$converterextran.toSql(extra),
      );
    }
    return map;
  }

  InstrumentsCompanion toCompanion(bool nullToAbsent) {
    return InstrumentsCompanion(
      code: Value(code),
      name: Value(name),
      type: Value(type),
      exchange: exchange == null && nullToAbsent
          ? const Value.absent()
          : Value(exchange),
      pinyin: pinyin == null && nullToAbsent
          ? const Value.absent()
          : Value(pinyin),
      listDate: listDate == null && nullToAbsent
          ? const Value.absent()
          : Value(listDate),
      extra: extra == null && nullToAbsent
          ? const Value.absent()
          : Value(extra),
    );
  }

  factory Instrument.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Instrument(
      code: serializer.fromJson<String>(json['code']),
      name: serializer.fromJson<String>(json['name']),
      type: serializer.fromJson<String>(json['type']),
      exchange: serializer.fromJson<String?>(json['exchange']),
      pinyin: serializer.fromJson<String?>(json['pinyin']),
      listDate: serializer.fromJson<String?>(json['listDate']),
      extra: serializer.fromJson<Map<String, dynamic>?>(json['extra']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'code': serializer.toJson<String>(code),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<String>(type),
      'exchange': serializer.toJson<String?>(exchange),
      'pinyin': serializer.toJson<String?>(pinyin),
      'listDate': serializer.toJson<String?>(listDate),
      'extra': serializer.toJson<Map<String, dynamic>?>(extra),
    };
  }

  Instrument copyWith({
    String? code,
    String? name,
    String? type,
    Value<String?> exchange = const Value.absent(),
    Value<String?> pinyin = const Value.absent(),
    Value<String?> listDate = const Value.absent(),
    Value<Map<String, dynamic>?> extra = const Value.absent(),
  }) => Instrument(
    code: code ?? this.code,
    name: name ?? this.name,
    type: type ?? this.type,
    exchange: exchange.present ? exchange.value : this.exchange,
    pinyin: pinyin.present ? pinyin.value : this.pinyin,
    listDate: listDate.present ? listDate.value : this.listDate,
    extra: extra.present ? extra.value : this.extra,
  );
  Instrument copyWithCompanion(InstrumentsCompanion data) {
    return Instrument(
      code: data.code.present ? data.code.value : this.code,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      exchange: data.exchange.present ? data.exchange.value : this.exchange,
      pinyin: data.pinyin.present ? data.pinyin.value : this.pinyin,
      listDate: data.listDate.present ? data.listDate.value : this.listDate,
      extra: data.extra.present ? data.extra.value : this.extra,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Instrument(')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('exchange: $exchange, ')
          ..write('pinyin: $pinyin, ')
          ..write('listDate: $listDate, ')
          ..write('extra: $extra')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(code, name, type, exchange, pinyin, listDate, extra);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Instrument &&
          other.code == this.code &&
          other.name == this.name &&
          other.type == this.type &&
          other.exchange == this.exchange &&
          other.pinyin == this.pinyin &&
          other.listDate == this.listDate &&
          other.extra == this.extra);
}

class InstrumentsCompanion extends UpdateCompanion<Instrument> {
  final Value<String> code;
  final Value<String> name;
  final Value<String> type;
  final Value<String?> exchange;
  final Value<String?> pinyin;
  final Value<String?> listDate;
  final Value<Map<String, dynamic>?> extra;
  final Value<int> rowid;
  const InstrumentsCompanion({
    this.code = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.exchange = const Value.absent(),
    this.pinyin = const Value.absent(),
    this.listDate = const Value.absent(),
    this.extra = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InstrumentsCompanion.insert({
    required String code,
    required String name,
    required String type,
    this.exchange = const Value.absent(),
    this.pinyin = const Value.absent(),
    this.listDate = const Value.absent(),
    this.extra = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : code = Value(code),
       name = Value(name),
       type = Value(type);
  static Insertable<Instrument> custom({
    Expression<String>? code,
    Expression<String>? name,
    Expression<String>? type,
    Expression<String>? exchange,
    Expression<String>? pinyin,
    Expression<String>? listDate,
    Expression<String>? extra,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (code != null) 'code': code,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (exchange != null) 'exchange': exchange,
      if (pinyin != null) 'pinyin': pinyin,
      if (listDate != null) 'list_date': listDate,
      if (extra != null) 'extra': extra,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InstrumentsCompanion copyWith({
    Value<String>? code,
    Value<String>? name,
    Value<String>? type,
    Value<String?>? exchange,
    Value<String?>? pinyin,
    Value<String?>? listDate,
    Value<Map<String, dynamic>?>? extra,
    Value<int>? rowid,
  }) {
    return InstrumentsCompanion(
      code: code ?? this.code,
      name: name ?? this.name,
      type: type ?? this.type,
      exchange: exchange ?? this.exchange,
      pinyin: pinyin ?? this.pinyin,
      listDate: listDate ?? this.listDate,
      extra: extra ?? this.extra,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (exchange.present) {
      map['exchange'] = Variable<String>(exchange.value);
    }
    if (pinyin.present) {
      map['pinyin'] = Variable<String>(pinyin.value);
    }
    if (listDate.present) {
      map['list_date'] = Variable<String>(listDate.value);
    }
    if (extra.present) {
      map['extra'] = Variable<String>(
        $InstrumentsTable.$converterextran.toSql(extra.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InstrumentsCompanion(')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('exchange: $exchange, ')
          ..write('pinyin: $pinyin, ')
          ..write('listDate: $listDate, ')
          ..write('extra: $extra, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TradingDaysTable extends TradingDays
    with TableInfo<$TradingDaysTable, TradingDay> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TradingDaysTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isOpenMeta = const VerificationMeta('isOpen');
  @override
  late final GeneratedColumn<bool> isOpen = GeneratedColumn<bool>(
    'is_open',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_open" IN (0, 1))',
    ),
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [date, isOpen, note];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'trading_days';
  @override
  VerificationContext validateIntegrity(
    Insertable<TradingDay> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('is_open')) {
      context.handle(
        _isOpenMeta,
        isOpen.isAcceptableOrUnknown(data['is_open']!, _isOpenMeta),
      );
    } else if (isInserting) {
      context.missing(_isOpenMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {date};
  @override
  TradingDay map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TradingDay(
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      )!,
      isOpen: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_open'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
    );
  }

  @override
  $TradingDaysTable createAlias(String alias) {
    return $TradingDaysTable(attachedDatabase, alias);
  }
}

class TradingDay extends DataClass implements Insertable<TradingDay> {
  final String date;
  final bool isOpen;
  final String? note;
  const TradingDay({required this.date, required this.isOpen, this.note});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['date'] = Variable<String>(date);
    map['is_open'] = Variable<bool>(isOpen);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    return map;
  }

  TradingDaysCompanion toCompanion(bool nullToAbsent) {
    return TradingDaysCompanion(
      date: Value(date),
      isOpen: Value(isOpen),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
    );
  }

  factory TradingDay.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TradingDay(
      date: serializer.fromJson<String>(json['date']),
      isOpen: serializer.fromJson<bool>(json['isOpen']),
      note: serializer.fromJson<String?>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'date': serializer.toJson<String>(date),
      'isOpen': serializer.toJson<bool>(isOpen),
      'note': serializer.toJson<String?>(note),
    };
  }

  TradingDay copyWith({
    String? date,
    bool? isOpen,
    Value<String?> note = const Value.absent(),
  }) => TradingDay(
    date: date ?? this.date,
    isOpen: isOpen ?? this.isOpen,
    note: note.present ? note.value : this.note,
  );
  TradingDay copyWithCompanion(TradingDaysCompanion data) {
    return TradingDay(
      date: data.date.present ? data.date.value : this.date,
      isOpen: data.isOpen.present ? data.isOpen.value : this.isOpen,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TradingDay(')
          ..write('date: $date, ')
          ..write('isOpen: $isOpen, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(date, isOpen, note);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TradingDay &&
          other.date == this.date &&
          other.isOpen == this.isOpen &&
          other.note == this.note);
}

class TradingDaysCompanion extends UpdateCompanion<TradingDay> {
  final Value<String> date;
  final Value<bool> isOpen;
  final Value<String?> note;
  final Value<int> rowid;
  const TradingDaysCompanion({
    this.date = const Value.absent(),
    this.isOpen = const Value.absent(),
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TradingDaysCompanion.insert({
    required String date,
    required bool isOpen,
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : date = Value(date),
       isOpen = Value(isOpen);
  static Insertable<TradingDay> custom({
    Expression<String>? date,
    Expression<bool>? isOpen,
    Expression<String>? note,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (date != null) 'date': date,
      if (isOpen != null) 'is_open': isOpen,
      if (note != null) 'note': note,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TradingDaysCompanion copyWith({
    Value<String>? date,
    Value<bool>? isOpen,
    Value<String?>? note,
    Value<int>? rowid,
  }) {
    return TradingDaysCompanion(
      date: date ?? this.date,
      isOpen: isOpen ?? this.isOpen,
      note: note ?? this.note,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (isOpen.present) {
      map['is_open'] = Variable<bool>(isOpen.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TradingDaysCompanion(')
          ..write('date: $date, ')
          ..write('isOpen: $isOpen, ')
          ..write('note: $note, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $KlineCacheTable extends KlineCache
    with TableInfo<$KlineCacheTable, KlineBar> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $KlineCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _periodMeta = const VerificationMeta('period');
  @override
  late final GeneratedColumn<String> period = GeneratedColumn<String>(
    'period',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _openMeta = const VerificationMeta('open');
  @override
  late final GeneratedColumn<double> open = GeneratedColumn<double>(
    'open',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _highMeta = const VerificationMeta('high');
  @override
  late final GeneratedColumn<double> high = GeneratedColumn<double>(
    'high',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lowMeta = const VerificationMeta('low');
  @override
  late final GeneratedColumn<double> low = GeneratedColumn<double>(
    'low',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _closeMeta = const VerificationMeta('close');
  @override
  late final GeneratedColumn<double> close = GeneratedColumn<double>(
    'close',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _volumeMeta = const VerificationMeta('volume');
  @override
  late final GeneratedColumn<double> volume = GeneratedColumn<double>(
    'volume',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    code,
    period,
    date,
    open,
    high,
    low,
    close,
    volume,
    amount,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'kline_cache';
  @override
  VerificationContext validateIntegrity(
    Insertable<KlineBar> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('period')) {
      context.handle(
        _periodMeta,
        period.isAcceptableOrUnknown(data['period']!, _periodMeta),
      );
    } else if (isInserting) {
      context.missing(_periodMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('open')) {
      context.handle(
        _openMeta,
        open.isAcceptableOrUnknown(data['open']!, _openMeta),
      );
    } else if (isInserting) {
      context.missing(_openMeta);
    }
    if (data.containsKey('high')) {
      context.handle(
        _highMeta,
        high.isAcceptableOrUnknown(data['high']!, _highMeta),
      );
    } else if (isInserting) {
      context.missing(_highMeta);
    }
    if (data.containsKey('low')) {
      context.handle(
        _lowMeta,
        low.isAcceptableOrUnknown(data['low']!, _lowMeta),
      );
    } else if (isInserting) {
      context.missing(_lowMeta);
    }
    if (data.containsKey('close')) {
      context.handle(
        _closeMeta,
        close.isAcceptableOrUnknown(data['close']!, _closeMeta),
      );
    } else if (isInserting) {
      context.missing(_closeMeta);
    }
    if (data.containsKey('volume')) {
      context.handle(
        _volumeMeta,
        volume.isAcceptableOrUnknown(data['volume']!, _volumeMeta),
      );
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {code, period, date};
  @override
  KlineBar map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return KlineBar(
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      )!,
      period: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}period'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      )!,
      open: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}open'],
      )!,
      high: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}high'],
      )!,
      low: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}low'],
      )!,
      close: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}close'],
      )!,
      volume: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}volume'],
      ),
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      ),
    );
  }

  @override
  $KlineCacheTable createAlias(String alias) {
    return $KlineCacheTable(attachedDatabase, alias);
  }
}

class KlineBar extends DataClass implements Insertable<KlineBar> {
  final String code;

  /// 1d | 1w | 1m(minute) ...
  final String period;

  /// 日线为 yyyyMMdd；分钟线为 yyyyMMddHHmm
  final String date;
  final double open;
  final double high;
  final double low;
  final double close;
  final double? volume;
  final double? amount;
  const KlineBar({
    required this.code,
    required this.period,
    required this.date,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    this.volume,
    this.amount,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['code'] = Variable<String>(code);
    map['period'] = Variable<String>(period);
    map['date'] = Variable<String>(date);
    map['open'] = Variable<double>(open);
    map['high'] = Variable<double>(high);
    map['low'] = Variable<double>(low);
    map['close'] = Variable<double>(close);
    if (!nullToAbsent || volume != null) {
      map['volume'] = Variable<double>(volume);
    }
    if (!nullToAbsent || amount != null) {
      map['amount'] = Variable<double>(amount);
    }
    return map;
  }

  KlineCacheCompanion toCompanion(bool nullToAbsent) {
    return KlineCacheCompanion(
      code: Value(code),
      period: Value(period),
      date: Value(date),
      open: Value(open),
      high: Value(high),
      low: Value(low),
      close: Value(close),
      volume: volume == null && nullToAbsent
          ? const Value.absent()
          : Value(volume),
      amount: amount == null && nullToAbsent
          ? const Value.absent()
          : Value(amount),
    );
  }

  factory KlineBar.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return KlineBar(
      code: serializer.fromJson<String>(json['code']),
      period: serializer.fromJson<String>(json['period']),
      date: serializer.fromJson<String>(json['date']),
      open: serializer.fromJson<double>(json['open']),
      high: serializer.fromJson<double>(json['high']),
      low: serializer.fromJson<double>(json['low']),
      close: serializer.fromJson<double>(json['close']),
      volume: serializer.fromJson<double?>(json['volume']),
      amount: serializer.fromJson<double?>(json['amount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'code': serializer.toJson<String>(code),
      'period': serializer.toJson<String>(period),
      'date': serializer.toJson<String>(date),
      'open': serializer.toJson<double>(open),
      'high': serializer.toJson<double>(high),
      'low': serializer.toJson<double>(low),
      'close': serializer.toJson<double>(close),
      'volume': serializer.toJson<double?>(volume),
      'amount': serializer.toJson<double?>(amount),
    };
  }

  KlineBar copyWith({
    String? code,
    String? period,
    String? date,
    double? open,
    double? high,
    double? low,
    double? close,
    Value<double?> volume = const Value.absent(),
    Value<double?> amount = const Value.absent(),
  }) => KlineBar(
    code: code ?? this.code,
    period: period ?? this.period,
    date: date ?? this.date,
    open: open ?? this.open,
    high: high ?? this.high,
    low: low ?? this.low,
    close: close ?? this.close,
    volume: volume.present ? volume.value : this.volume,
    amount: amount.present ? amount.value : this.amount,
  );
  KlineBar copyWithCompanion(KlineCacheCompanion data) {
    return KlineBar(
      code: data.code.present ? data.code.value : this.code,
      period: data.period.present ? data.period.value : this.period,
      date: data.date.present ? data.date.value : this.date,
      open: data.open.present ? data.open.value : this.open,
      high: data.high.present ? data.high.value : this.high,
      low: data.low.present ? data.low.value : this.low,
      close: data.close.present ? data.close.value : this.close,
      volume: data.volume.present ? data.volume.value : this.volume,
      amount: data.amount.present ? data.amount.value : this.amount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('KlineBar(')
          ..write('code: $code, ')
          ..write('period: $period, ')
          ..write('date: $date, ')
          ..write('open: $open, ')
          ..write('high: $high, ')
          ..write('low: $low, ')
          ..write('close: $close, ')
          ..write('volume: $volume, ')
          ..write('amount: $amount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(code, period, date, open, high, low, close, volume, amount);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is KlineBar &&
          other.code == this.code &&
          other.period == this.period &&
          other.date == this.date &&
          other.open == this.open &&
          other.high == this.high &&
          other.low == this.low &&
          other.close == this.close &&
          other.volume == this.volume &&
          other.amount == this.amount);
}

class KlineCacheCompanion extends UpdateCompanion<KlineBar> {
  final Value<String> code;
  final Value<String> period;
  final Value<String> date;
  final Value<double> open;
  final Value<double> high;
  final Value<double> low;
  final Value<double> close;
  final Value<double?> volume;
  final Value<double?> amount;
  final Value<int> rowid;
  const KlineCacheCompanion({
    this.code = const Value.absent(),
    this.period = const Value.absent(),
    this.date = const Value.absent(),
    this.open = const Value.absent(),
    this.high = const Value.absent(),
    this.low = const Value.absent(),
    this.close = const Value.absent(),
    this.volume = const Value.absent(),
    this.amount = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  KlineCacheCompanion.insert({
    required String code,
    required String period,
    required String date,
    required double open,
    required double high,
    required double low,
    required double close,
    this.volume = const Value.absent(),
    this.amount = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : code = Value(code),
       period = Value(period),
       date = Value(date),
       open = Value(open),
       high = Value(high),
       low = Value(low),
       close = Value(close);
  static Insertable<KlineBar> custom({
    Expression<String>? code,
    Expression<String>? period,
    Expression<String>? date,
    Expression<double>? open,
    Expression<double>? high,
    Expression<double>? low,
    Expression<double>? close,
    Expression<double>? volume,
    Expression<double>? amount,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (code != null) 'code': code,
      if (period != null) 'period': period,
      if (date != null) 'date': date,
      if (open != null) 'open': open,
      if (high != null) 'high': high,
      if (low != null) 'low': low,
      if (close != null) 'close': close,
      if (volume != null) 'volume': volume,
      if (amount != null) 'amount': amount,
      if (rowid != null) 'rowid': rowid,
    });
  }

  KlineCacheCompanion copyWith({
    Value<String>? code,
    Value<String>? period,
    Value<String>? date,
    Value<double>? open,
    Value<double>? high,
    Value<double>? low,
    Value<double>? close,
    Value<double?>? volume,
    Value<double?>? amount,
    Value<int>? rowid,
  }) {
    return KlineCacheCompanion(
      code: code ?? this.code,
      period: period ?? this.period,
      date: date ?? this.date,
      open: open ?? this.open,
      high: high ?? this.high,
      low: low ?? this.low,
      close: close ?? this.close,
      volume: volume ?? this.volume,
      amount: amount ?? this.amount,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (period.present) {
      map['period'] = Variable<String>(period.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (open.present) {
      map['open'] = Variable<double>(open.value);
    }
    if (high.present) {
      map['high'] = Variable<double>(high.value);
    }
    if (low.present) {
      map['low'] = Variable<double>(low.value);
    }
    if (close.present) {
      map['close'] = Variable<double>(close.value);
    }
    if (volume.present) {
      map['volume'] = Variable<double>(volume.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('KlineCacheCompanion(')
          ..write('code: $code, ')
          ..write('period: $period, ')
          ..write('date: $date, ')
          ..write('open: $open, ')
          ..write('high: $high, ')
          ..write('low: $low, ')
          ..write('close: $close, ')
          ..write('volume: $volume, ')
          ..write('amount: $amount, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $JournalEntriesTable extends JournalEntries
    with TableInfo<$JournalEntriesTable, JournalEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $JournalEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tradeDateMeta = const VerificationMeta(
    'tradeDate',
  );
  @override
  late final GeneratedColumn<String> tradeDate = GeneratedColumn<String>(
    'trade_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sessionMeta = const VerificationMeta(
    'session',
  );
  @override
  late final GeneratedColumn<String> session = GeneratedColumn<String>(
    'session',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tsMeta = const VerificationMeta('ts');
  @override
  late final GeneratedColumn<int> ts = GeneratedColumn<int>(
    'ts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _subcategoryMeta = const VerificationMeta(
    'subcategory',
  );
  @override
  late final GeneratedColumn<String> subcategory = GeneratedColumn<String>(
    'subcategory',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _stanceMeta = const VerificationMeta('stance');
  @override
  late final GeneratedColumn<String> stance = GeneratedColumn<String>(
    'stance',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _actionMeta = const VerificationMeta('action');
  @override
  late final GeneratedColumn<String> action = GeneratedColumn<String>(
    'action',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _horizonMeta = const VerificationMeta(
    'horizon',
  );
  @override
  late final GeneratedColumn<String> horizon = GeneratedColumn<String>(
    'horizon',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _emotionMeta = const VerificationMeta(
    'emotion',
  );
  @override
  late final GeneratedColumn<String> emotion = GeneratedColumn<String>(
    'emotion',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String> tags =
      GeneratedColumn<String>(
        'tags',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('[]'),
      ).withConverter<List<String>>($JournalEntriesTable.$convertertags);
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String>
  instrumentCodes = GeneratedColumn<String>(
    'instrument_codes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  ).withConverter<List<String>>($JournalEntriesTable.$converterinstrumentCodes);
  static const VerificationMeta _snapshotIdMeta = const VerificationMeta(
    'snapshotId',
  );
  @override
  late final GeneratedColumn<String> snapshotId = GeneratedColumn<String>(
    'snapshot_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _templateIdMeta = const VerificationMeta(
    'templateId',
  );
  @override
  late final GeneratedColumn<String> templateId = GeneratedColumn<String>(
    'template_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _revisionCountMeta = const VerificationMeta(
    'revisionCount',
  );
  @override
  late final GeneratedColumn<int> revisionCount = GeneratedColumn<int>(
    'revision_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    deviceId,
    tradeDate,
    session,
    ts,
    content,
    category,
    subcategory,
    stance,
    action,
    horizon,
    emotion,
    tags,
    instrumentCodes,
    snapshotId,
    templateId,
    revisionCount,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'journal_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<JournalEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('trade_date')) {
      context.handle(
        _tradeDateMeta,
        tradeDate.isAcceptableOrUnknown(data['trade_date']!, _tradeDateMeta),
      );
    } else if (isInserting) {
      context.missing(_tradeDateMeta);
    }
    if (data.containsKey('session')) {
      context.handle(
        _sessionMeta,
        session.isAcceptableOrUnknown(data['session']!, _sessionMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionMeta);
    }
    if (data.containsKey('ts')) {
      context.handle(_tsMeta, ts.isAcceptableOrUnknown(data['ts']!, _tsMeta));
    } else if (isInserting) {
      context.missing(_tsMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    }
    if (data.containsKey('subcategory')) {
      context.handle(
        _subcategoryMeta,
        subcategory.isAcceptableOrUnknown(
          data['subcategory']!,
          _subcategoryMeta,
        ),
      );
    }
    if (data.containsKey('stance')) {
      context.handle(
        _stanceMeta,
        stance.isAcceptableOrUnknown(data['stance']!, _stanceMeta),
      );
    }
    if (data.containsKey('action')) {
      context.handle(
        _actionMeta,
        action.isAcceptableOrUnknown(data['action']!, _actionMeta),
      );
    }
    if (data.containsKey('horizon')) {
      context.handle(
        _horizonMeta,
        horizon.isAcceptableOrUnknown(data['horizon']!, _horizonMeta),
      );
    }
    if (data.containsKey('emotion')) {
      context.handle(
        _emotionMeta,
        emotion.isAcceptableOrUnknown(data['emotion']!, _emotionMeta),
      );
    }
    if (data.containsKey('snapshot_id')) {
      context.handle(
        _snapshotIdMeta,
        snapshotId.isAcceptableOrUnknown(data['snapshot_id']!, _snapshotIdMeta),
      );
    }
    if (data.containsKey('template_id')) {
      context.handle(
        _templateIdMeta,
        templateId.isAcceptableOrUnknown(data['template_id']!, _templateIdMeta),
      );
    }
    if (data.containsKey('revision_count')) {
      context.handle(
        _revisionCountMeta,
        revisionCount.isAcceptableOrUnknown(
          data['revision_count']!,
          _revisionCountMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  JournalEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return JournalEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      tradeDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}trade_date'],
      )!,
      session: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session'],
      )!,
      ts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ts'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      ),
      subcategory: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subcategory'],
      ),
      stance: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stance'],
      ),
      action: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}action'],
      ),
      horizon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}horizon'],
      ),
      emotion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}emotion'],
      ),
      tags: $JournalEntriesTable.$convertertags.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}tags'],
        )!,
      ),
      instrumentCodes: $JournalEntriesTable.$converterinstrumentCodes.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}instrument_codes'],
        )!,
      ),
      snapshotId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}snapshot_id'],
      ),
      templateId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}template_id'],
      ),
      revisionCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revision_count'],
      )!,
    );
  }

  @override
  $JournalEntriesTable createAlias(String alias) {
    return $JournalEntriesTable(attachedDatabase, alias);
  }

  static TypeConverter<List<String>, String> $convertertags =
      const StringListConverter();
  static TypeConverter<List<String>, String> $converterinstrumentCodes =
      const StringListConverter();
}

class JournalEntry extends DataClass implements Insertable<JournalEntry> {
  final String id;
  final int createdAt;
  final int updatedAt;
  final int? deletedAt;
  final String deviceId;
  final String tradeDate;

  /// TradingSession.code
  final String session;
  final int ts;
  final String content;

  /// 一级分类：observe | judge | plan | review | other（v2 新增；旧数据为 null）
  final String? category;

  /// 二级分类：观察主题 / 判断对象 / 复盘类型
  final String? subcategory;

  /// 判断方向：bull | bear | range（旧版另有 wait）
  final String? stance;

  /// 计划动作：buy | add | reduce | sell（旧版另有 hold | flat）
  final String? action;

  /// 判断周期（close | t1 | t5 | mid）或计划时间（today | soon | future）
  final String? horizon;
  final String? emotion;
  final List<String> tags;
  final List<String> instrumentCodes;
  final String? snapshotId;
  final String? templateId;
  final int revisionCount;
  const JournalEntry({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.deviceId,
    required this.tradeDate,
    required this.session,
    required this.ts,
    required this.content,
    this.category,
    this.subcategory,
    this.stance,
    this.action,
    this.horizon,
    this.emotion,
    required this.tags,
    required this.instrumentCodes,
    this.snapshotId,
    this.templateId,
    required this.revisionCount,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['device_id'] = Variable<String>(deviceId);
    map['trade_date'] = Variable<String>(tradeDate);
    map['session'] = Variable<String>(session);
    map['ts'] = Variable<int>(ts);
    map['content'] = Variable<String>(content);
    if (!nullToAbsent || category != null) {
      map['category'] = Variable<String>(category);
    }
    if (!nullToAbsent || subcategory != null) {
      map['subcategory'] = Variable<String>(subcategory);
    }
    if (!nullToAbsent || stance != null) {
      map['stance'] = Variable<String>(stance);
    }
    if (!nullToAbsent || action != null) {
      map['action'] = Variable<String>(action);
    }
    if (!nullToAbsent || horizon != null) {
      map['horizon'] = Variable<String>(horizon);
    }
    if (!nullToAbsent || emotion != null) {
      map['emotion'] = Variable<String>(emotion);
    }
    {
      map['tags'] = Variable<String>(
        $JournalEntriesTable.$convertertags.toSql(tags),
      );
    }
    {
      map['instrument_codes'] = Variable<String>(
        $JournalEntriesTable.$converterinstrumentCodes.toSql(instrumentCodes),
      );
    }
    if (!nullToAbsent || snapshotId != null) {
      map['snapshot_id'] = Variable<String>(snapshotId);
    }
    if (!nullToAbsent || templateId != null) {
      map['template_id'] = Variable<String>(templateId);
    }
    map['revision_count'] = Variable<int>(revisionCount);
    return map;
  }

  JournalEntriesCompanion toCompanion(bool nullToAbsent) {
    return JournalEntriesCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      deviceId: Value(deviceId),
      tradeDate: Value(tradeDate),
      session: Value(session),
      ts: Value(ts),
      content: Value(content),
      category: category == null && nullToAbsent
          ? const Value.absent()
          : Value(category),
      subcategory: subcategory == null && nullToAbsent
          ? const Value.absent()
          : Value(subcategory),
      stance: stance == null && nullToAbsent
          ? const Value.absent()
          : Value(stance),
      action: action == null && nullToAbsent
          ? const Value.absent()
          : Value(action),
      horizon: horizon == null && nullToAbsent
          ? const Value.absent()
          : Value(horizon),
      emotion: emotion == null && nullToAbsent
          ? const Value.absent()
          : Value(emotion),
      tags: Value(tags),
      instrumentCodes: Value(instrumentCodes),
      snapshotId: snapshotId == null && nullToAbsent
          ? const Value.absent()
          : Value(snapshotId),
      templateId: templateId == null && nullToAbsent
          ? const Value.absent()
          : Value(templateId),
      revisionCount: Value(revisionCount),
    );
  }

  factory JournalEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return JournalEntry(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      tradeDate: serializer.fromJson<String>(json['tradeDate']),
      session: serializer.fromJson<String>(json['session']),
      ts: serializer.fromJson<int>(json['ts']),
      content: serializer.fromJson<String>(json['content']),
      category: serializer.fromJson<String?>(json['category']),
      subcategory: serializer.fromJson<String?>(json['subcategory']),
      stance: serializer.fromJson<String?>(json['stance']),
      action: serializer.fromJson<String?>(json['action']),
      horizon: serializer.fromJson<String?>(json['horizon']),
      emotion: serializer.fromJson<String?>(json['emotion']),
      tags: serializer.fromJson<List<String>>(json['tags']),
      instrumentCodes: serializer.fromJson<List<String>>(
        json['instrumentCodes'],
      ),
      snapshotId: serializer.fromJson<String?>(json['snapshotId']),
      templateId: serializer.fromJson<String?>(json['templateId']),
      revisionCount: serializer.fromJson<int>(json['revisionCount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'deviceId': serializer.toJson<String>(deviceId),
      'tradeDate': serializer.toJson<String>(tradeDate),
      'session': serializer.toJson<String>(session),
      'ts': serializer.toJson<int>(ts),
      'content': serializer.toJson<String>(content),
      'category': serializer.toJson<String?>(category),
      'subcategory': serializer.toJson<String?>(subcategory),
      'stance': serializer.toJson<String?>(stance),
      'action': serializer.toJson<String?>(action),
      'horizon': serializer.toJson<String?>(horizon),
      'emotion': serializer.toJson<String?>(emotion),
      'tags': serializer.toJson<List<String>>(tags),
      'instrumentCodes': serializer.toJson<List<String>>(instrumentCodes),
      'snapshotId': serializer.toJson<String?>(snapshotId),
      'templateId': serializer.toJson<String?>(templateId),
      'revisionCount': serializer.toJson<int>(revisionCount),
    };
  }

  JournalEntry copyWith({
    String? id,
    int? createdAt,
    int? updatedAt,
    Value<int?> deletedAt = const Value.absent(),
    String? deviceId,
    String? tradeDate,
    String? session,
    int? ts,
    String? content,
    Value<String?> category = const Value.absent(),
    Value<String?> subcategory = const Value.absent(),
    Value<String?> stance = const Value.absent(),
    Value<String?> action = const Value.absent(),
    Value<String?> horizon = const Value.absent(),
    Value<String?> emotion = const Value.absent(),
    List<String>? tags,
    List<String>? instrumentCodes,
    Value<String?> snapshotId = const Value.absent(),
    Value<String?> templateId = const Value.absent(),
    int? revisionCount,
  }) => JournalEntry(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    deviceId: deviceId ?? this.deviceId,
    tradeDate: tradeDate ?? this.tradeDate,
    session: session ?? this.session,
    ts: ts ?? this.ts,
    content: content ?? this.content,
    category: category.present ? category.value : this.category,
    subcategory: subcategory.present ? subcategory.value : this.subcategory,
    stance: stance.present ? stance.value : this.stance,
    action: action.present ? action.value : this.action,
    horizon: horizon.present ? horizon.value : this.horizon,
    emotion: emotion.present ? emotion.value : this.emotion,
    tags: tags ?? this.tags,
    instrumentCodes: instrumentCodes ?? this.instrumentCodes,
    snapshotId: snapshotId.present ? snapshotId.value : this.snapshotId,
    templateId: templateId.present ? templateId.value : this.templateId,
    revisionCount: revisionCount ?? this.revisionCount,
  );
  JournalEntry copyWithCompanion(JournalEntriesCompanion data) {
    return JournalEntry(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      tradeDate: data.tradeDate.present ? data.tradeDate.value : this.tradeDate,
      session: data.session.present ? data.session.value : this.session,
      ts: data.ts.present ? data.ts.value : this.ts,
      content: data.content.present ? data.content.value : this.content,
      category: data.category.present ? data.category.value : this.category,
      subcategory: data.subcategory.present
          ? data.subcategory.value
          : this.subcategory,
      stance: data.stance.present ? data.stance.value : this.stance,
      action: data.action.present ? data.action.value : this.action,
      horizon: data.horizon.present ? data.horizon.value : this.horizon,
      emotion: data.emotion.present ? data.emotion.value : this.emotion,
      tags: data.tags.present ? data.tags.value : this.tags,
      instrumentCodes: data.instrumentCodes.present
          ? data.instrumentCodes.value
          : this.instrumentCodes,
      snapshotId: data.snapshotId.present
          ? data.snapshotId.value
          : this.snapshotId,
      templateId: data.templateId.present
          ? data.templateId.value
          : this.templateId,
      revisionCount: data.revisionCount.present
          ? data.revisionCount.value
          : this.revisionCount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('JournalEntry(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('tradeDate: $tradeDate, ')
          ..write('session: $session, ')
          ..write('ts: $ts, ')
          ..write('content: $content, ')
          ..write('category: $category, ')
          ..write('subcategory: $subcategory, ')
          ..write('stance: $stance, ')
          ..write('action: $action, ')
          ..write('horizon: $horizon, ')
          ..write('emotion: $emotion, ')
          ..write('tags: $tags, ')
          ..write('instrumentCodes: $instrumentCodes, ')
          ..write('snapshotId: $snapshotId, ')
          ..write('templateId: $templateId, ')
          ..write('revisionCount: $revisionCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    deviceId,
    tradeDate,
    session,
    ts,
    content,
    category,
    subcategory,
    stance,
    action,
    horizon,
    emotion,
    tags,
    instrumentCodes,
    snapshotId,
    templateId,
    revisionCount,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is JournalEntry &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.deviceId == this.deviceId &&
          other.tradeDate == this.tradeDate &&
          other.session == this.session &&
          other.ts == this.ts &&
          other.content == this.content &&
          other.category == this.category &&
          other.subcategory == this.subcategory &&
          other.stance == this.stance &&
          other.action == this.action &&
          other.horizon == this.horizon &&
          other.emotion == this.emotion &&
          other.tags == this.tags &&
          other.instrumentCodes == this.instrumentCodes &&
          other.snapshotId == this.snapshotId &&
          other.templateId == this.templateId &&
          other.revisionCount == this.revisionCount);
}

class JournalEntriesCompanion extends UpdateCompanion<JournalEntry> {
  final Value<String> id;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<String> deviceId;
  final Value<String> tradeDate;
  final Value<String> session;
  final Value<int> ts;
  final Value<String> content;
  final Value<String?> category;
  final Value<String?> subcategory;
  final Value<String?> stance;
  final Value<String?> action;
  final Value<String?> horizon;
  final Value<String?> emotion;
  final Value<List<String>> tags;
  final Value<List<String>> instrumentCodes;
  final Value<String?> snapshotId;
  final Value<String?> templateId;
  final Value<int> revisionCount;
  final Value<int> rowid;
  const JournalEntriesCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.tradeDate = const Value.absent(),
    this.session = const Value.absent(),
    this.ts = const Value.absent(),
    this.content = const Value.absent(),
    this.category = const Value.absent(),
    this.subcategory = const Value.absent(),
    this.stance = const Value.absent(),
    this.action = const Value.absent(),
    this.horizon = const Value.absent(),
    this.emotion = const Value.absent(),
    this.tags = const Value.absent(),
    this.instrumentCodes = const Value.absent(),
    this.snapshotId = const Value.absent(),
    this.templateId = const Value.absent(),
    this.revisionCount = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  JournalEntriesCompanion.insert({
    required String id,
    required int createdAt,
    required int updatedAt,
    this.deletedAt = const Value.absent(),
    required String deviceId,
    required String tradeDate,
    required String session,
    required int ts,
    required String content,
    this.category = const Value.absent(),
    this.subcategory = const Value.absent(),
    this.stance = const Value.absent(),
    this.action = const Value.absent(),
    this.horizon = const Value.absent(),
    this.emotion = const Value.absent(),
    this.tags = const Value.absent(),
    this.instrumentCodes = const Value.absent(),
    this.snapshotId = const Value.absent(),
    this.templateId = const Value.absent(),
    this.revisionCount = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       deviceId = Value(deviceId),
       tradeDate = Value(tradeDate),
       session = Value(session),
       ts = Value(ts),
       content = Value(content);
  static Insertable<JournalEntry> custom({
    Expression<String>? id,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<String>? deviceId,
    Expression<String>? tradeDate,
    Expression<String>? session,
    Expression<int>? ts,
    Expression<String>? content,
    Expression<String>? category,
    Expression<String>? subcategory,
    Expression<String>? stance,
    Expression<String>? action,
    Expression<String>? horizon,
    Expression<String>? emotion,
    Expression<String>? tags,
    Expression<String>? instrumentCodes,
    Expression<String>? snapshotId,
    Expression<String>? templateId,
    Expression<int>? revisionCount,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (deviceId != null) 'device_id': deviceId,
      if (tradeDate != null) 'trade_date': tradeDate,
      if (session != null) 'session': session,
      if (ts != null) 'ts': ts,
      if (content != null) 'content': content,
      if (category != null) 'category': category,
      if (subcategory != null) 'subcategory': subcategory,
      if (stance != null) 'stance': stance,
      if (action != null) 'action': action,
      if (horizon != null) 'horizon': horizon,
      if (emotion != null) 'emotion': emotion,
      if (tags != null) 'tags': tags,
      if (instrumentCodes != null) 'instrument_codes': instrumentCodes,
      if (snapshotId != null) 'snapshot_id': snapshotId,
      if (templateId != null) 'template_id': templateId,
      if (revisionCount != null) 'revision_count': revisionCount,
      if (rowid != null) 'rowid': rowid,
    });
  }

  JournalEntriesCompanion copyWith({
    Value<String>? id,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int?>? deletedAt,
    Value<String>? deviceId,
    Value<String>? tradeDate,
    Value<String>? session,
    Value<int>? ts,
    Value<String>? content,
    Value<String?>? category,
    Value<String?>? subcategory,
    Value<String?>? stance,
    Value<String?>? action,
    Value<String?>? horizon,
    Value<String?>? emotion,
    Value<List<String>>? tags,
    Value<List<String>>? instrumentCodes,
    Value<String?>? snapshotId,
    Value<String?>? templateId,
    Value<int>? revisionCount,
    Value<int>? rowid,
  }) {
    return JournalEntriesCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      deviceId: deviceId ?? this.deviceId,
      tradeDate: tradeDate ?? this.tradeDate,
      session: session ?? this.session,
      ts: ts ?? this.ts,
      content: content ?? this.content,
      category: category ?? this.category,
      subcategory: subcategory ?? this.subcategory,
      stance: stance ?? this.stance,
      action: action ?? this.action,
      horizon: horizon ?? this.horizon,
      emotion: emotion ?? this.emotion,
      tags: tags ?? this.tags,
      instrumentCodes: instrumentCodes ?? this.instrumentCodes,
      snapshotId: snapshotId ?? this.snapshotId,
      templateId: templateId ?? this.templateId,
      revisionCount: revisionCount ?? this.revisionCount,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (tradeDate.present) {
      map['trade_date'] = Variable<String>(tradeDate.value);
    }
    if (session.present) {
      map['session'] = Variable<String>(session.value);
    }
    if (ts.present) {
      map['ts'] = Variable<int>(ts.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (subcategory.present) {
      map['subcategory'] = Variable<String>(subcategory.value);
    }
    if (stance.present) {
      map['stance'] = Variable<String>(stance.value);
    }
    if (action.present) {
      map['action'] = Variable<String>(action.value);
    }
    if (horizon.present) {
      map['horizon'] = Variable<String>(horizon.value);
    }
    if (emotion.present) {
      map['emotion'] = Variable<String>(emotion.value);
    }
    if (tags.present) {
      map['tags'] = Variable<String>(
        $JournalEntriesTable.$convertertags.toSql(tags.value),
      );
    }
    if (instrumentCodes.present) {
      map['instrument_codes'] = Variable<String>(
        $JournalEntriesTable.$converterinstrumentCodes.toSql(
          instrumentCodes.value,
        ),
      );
    }
    if (snapshotId.present) {
      map['snapshot_id'] = Variable<String>(snapshotId.value);
    }
    if (templateId.present) {
      map['template_id'] = Variable<String>(templateId.value);
    }
    if (revisionCount.present) {
      map['revision_count'] = Variable<int>(revisionCount.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('JournalEntriesCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('tradeDate: $tradeDate, ')
          ..write('session: $session, ')
          ..write('ts: $ts, ')
          ..write('content: $content, ')
          ..write('category: $category, ')
          ..write('subcategory: $subcategory, ')
          ..write('stance: $stance, ')
          ..write('action: $action, ')
          ..write('horizon: $horizon, ')
          ..write('emotion: $emotion, ')
          ..write('tags: $tags, ')
          ..write('instrumentCodes: $instrumentCodes, ')
          ..write('snapshotId: $snapshotId, ')
          ..write('templateId: $templateId, ')
          ..write('revisionCount: $revisionCount, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MarketSnapshotsTable extends MarketSnapshots
    with TableInfo<$MarketSnapshotsTable, MarketSnapshot> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MarketSnapshotsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tsMeta = const VerificationMeta('ts');
  @override
  late final GeneratedColumn<int> ts = GeneratedColumn<int>(
    'ts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Map<String, dynamic>, String>
  indices =
      GeneratedColumn<String>(
        'indices',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<Map<String, dynamic>>(
        $MarketSnapshotsTable.$converterindices,
      );
  @override
  late final GeneratedColumnWithTypeConverter<Map<String, dynamic>?, String>
  breadth =
      GeneratedColumn<String>(
        'breadth',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<Map<String, dynamic>?>(
        $MarketSnapshotsTable.$converterbreadthn,
      );
  static const VerificationMeta _turnoverMeta = const VerificationMeta(
    'turnover',
  );
  @override
  late final GeneratedColumn<double> turnover = GeneratedColumn<double>(
    'turnover',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Map<String, dynamic>?, String>
  extra =
      GeneratedColumn<String>(
        'extra',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<Map<String, dynamic>?>(
        $MarketSnapshotsTable.$converterextran,
      );
  static const VerificationMeta _isBackfilledMeta = const VerificationMeta(
    'isBackfilled',
  );
  @override
  late final GeneratedColumn<bool> isBackfilled = GeneratedColumn<bool>(
    'is_backfilled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_backfilled" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    deviceId,
    ts,
    indices,
    breadth,
    turnover,
    extra,
    isBackfilled,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'market_snapshots';
  @override
  VerificationContext validateIntegrity(
    Insertable<MarketSnapshot> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('ts')) {
      context.handle(_tsMeta, ts.isAcceptableOrUnknown(data['ts']!, _tsMeta));
    } else if (isInserting) {
      context.missing(_tsMeta);
    }
    if (data.containsKey('turnover')) {
      context.handle(
        _turnoverMeta,
        turnover.isAcceptableOrUnknown(data['turnover']!, _turnoverMeta),
      );
    }
    if (data.containsKey('is_backfilled')) {
      context.handle(
        _isBackfilledMeta,
        isBackfilled.isAcceptableOrUnknown(
          data['is_backfilled']!,
          _isBackfilledMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MarketSnapshot map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MarketSnapshot(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      ts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ts'],
      )!,
      indices: $MarketSnapshotsTable.$converterindices.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}indices'],
        )!,
      ),
      breadth: $MarketSnapshotsTable.$converterbreadthn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}breadth'],
        ),
      ),
      turnover: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}turnover'],
      ),
      extra: $MarketSnapshotsTable.$converterextran.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}extra'],
        ),
      ),
      isBackfilled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_backfilled'],
      )!,
    );
  }

  @override
  $MarketSnapshotsTable createAlias(String alias) {
    return $MarketSnapshotsTable(attachedDatabase, alias);
  }

  static TypeConverter<Map<String, dynamic>, String> $converterindices =
      const JsonMapConverter();
  static TypeConverter<Map<String, dynamic>, String> $converterbreadth =
      const JsonMapConverter();
  static TypeConverter<Map<String, dynamic>?, String?> $converterbreadthn =
      NullAwareTypeConverter.wrap($converterbreadth);
  static TypeConverter<Map<String, dynamic>, String> $converterextra =
      const JsonMapConverter();
  static TypeConverter<Map<String, dynamic>?, String?> $converterextran =
      NullAwareTypeConverter.wrap($converterextra);
}

class MarketSnapshot extends DataClass implements Insertable<MarketSnapshot> {
  final String id;
  final int createdAt;
  final int updatedAt;
  final int? deletedAt;
  final String deviceId;
  final int ts;
  final Map<String, dynamic> indices;
  final Map<String, dynamic>? breadth;
  final double? turnover;
  final Map<String, dynamic>? extra;
  final bool isBackfilled;
  const MarketSnapshot({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.deviceId,
    required this.ts,
    required this.indices,
    this.breadth,
    this.turnover,
    this.extra,
    required this.isBackfilled,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['device_id'] = Variable<String>(deviceId);
    map['ts'] = Variable<int>(ts);
    {
      map['indices'] = Variable<String>(
        $MarketSnapshotsTable.$converterindices.toSql(indices),
      );
    }
    if (!nullToAbsent || breadth != null) {
      map['breadth'] = Variable<String>(
        $MarketSnapshotsTable.$converterbreadthn.toSql(breadth),
      );
    }
    if (!nullToAbsent || turnover != null) {
      map['turnover'] = Variable<double>(turnover);
    }
    if (!nullToAbsent || extra != null) {
      map['extra'] = Variable<String>(
        $MarketSnapshotsTable.$converterextran.toSql(extra),
      );
    }
    map['is_backfilled'] = Variable<bool>(isBackfilled);
    return map;
  }

  MarketSnapshotsCompanion toCompanion(bool nullToAbsent) {
    return MarketSnapshotsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      deviceId: Value(deviceId),
      ts: Value(ts),
      indices: Value(indices),
      breadth: breadth == null && nullToAbsent
          ? const Value.absent()
          : Value(breadth),
      turnover: turnover == null && nullToAbsent
          ? const Value.absent()
          : Value(turnover),
      extra: extra == null && nullToAbsent
          ? const Value.absent()
          : Value(extra),
      isBackfilled: Value(isBackfilled),
    );
  }

  factory MarketSnapshot.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MarketSnapshot(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      ts: serializer.fromJson<int>(json['ts']),
      indices: serializer.fromJson<Map<String, dynamic>>(json['indices']),
      breadth: serializer.fromJson<Map<String, dynamic>?>(json['breadth']),
      turnover: serializer.fromJson<double?>(json['turnover']),
      extra: serializer.fromJson<Map<String, dynamic>?>(json['extra']),
      isBackfilled: serializer.fromJson<bool>(json['isBackfilled']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'deviceId': serializer.toJson<String>(deviceId),
      'ts': serializer.toJson<int>(ts),
      'indices': serializer.toJson<Map<String, dynamic>>(indices),
      'breadth': serializer.toJson<Map<String, dynamic>?>(breadth),
      'turnover': serializer.toJson<double?>(turnover),
      'extra': serializer.toJson<Map<String, dynamic>?>(extra),
      'isBackfilled': serializer.toJson<bool>(isBackfilled),
    };
  }

  MarketSnapshot copyWith({
    String? id,
    int? createdAt,
    int? updatedAt,
    Value<int?> deletedAt = const Value.absent(),
    String? deviceId,
    int? ts,
    Map<String, dynamic>? indices,
    Value<Map<String, dynamic>?> breadth = const Value.absent(),
    Value<double?> turnover = const Value.absent(),
    Value<Map<String, dynamic>?> extra = const Value.absent(),
    bool? isBackfilled,
  }) => MarketSnapshot(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    deviceId: deviceId ?? this.deviceId,
    ts: ts ?? this.ts,
    indices: indices ?? this.indices,
    breadth: breadth.present ? breadth.value : this.breadth,
    turnover: turnover.present ? turnover.value : this.turnover,
    extra: extra.present ? extra.value : this.extra,
    isBackfilled: isBackfilled ?? this.isBackfilled,
  );
  MarketSnapshot copyWithCompanion(MarketSnapshotsCompanion data) {
    return MarketSnapshot(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      ts: data.ts.present ? data.ts.value : this.ts,
      indices: data.indices.present ? data.indices.value : this.indices,
      breadth: data.breadth.present ? data.breadth.value : this.breadth,
      turnover: data.turnover.present ? data.turnover.value : this.turnover,
      extra: data.extra.present ? data.extra.value : this.extra,
      isBackfilled: data.isBackfilled.present
          ? data.isBackfilled.value
          : this.isBackfilled,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MarketSnapshot(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('ts: $ts, ')
          ..write('indices: $indices, ')
          ..write('breadth: $breadth, ')
          ..write('turnover: $turnover, ')
          ..write('extra: $extra, ')
          ..write('isBackfilled: $isBackfilled')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    deviceId,
    ts,
    indices,
    breadth,
    turnover,
    extra,
    isBackfilled,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MarketSnapshot &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.deviceId == this.deviceId &&
          other.ts == this.ts &&
          other.indices == this.indices &&
          other.breadth == this.breadth &&
          other.turnover == this.turnover &&
          other.extra == this.extra &&
          other.isBackfilled == this.isBackfilled);
}

class MarketSnapshotsCompanion extends UpdateCompanion<MarketSnapshot> {
  final Value<String> id;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<String> deviceId;
  final Value<int> ts;
  final Value<Map<String, dynamic>> indices;
  final Value<Map<String, dynamic>?> breadth;
  final Value<double?> turnover;
  final Value<Map<String, dynamic>?> extra;
  final Value<bool> isBackfilled;
  final Value<int> rowid;
  const MarketSnapshotsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.ts = const Value.absent(),
    this.indices = const Value.absent(),
    this.breadth = const Value.absent(),
    this.turnover = const Value.absent(),
    this.extra = const Value.absent(),
    this.isBackfilled = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MarketSnapshotsCompanion.insert({
    required String id,
    required int createdAt,
    required int updatedAt,
    this.deletedAt = const Value.absent(),
    required String deviceId,
    required int ts,
    required Map<String, dynamic> indices,
    this.breadth = const Value.absent(),
    this.turnover = const Value.absent(),
    this.extra = const Value.absent(),
    this.isBackfilled = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       deviceId = Value(deviceId),
       ts = Value(ts),
       indices = Value(indices);
  static Insertable<MarketSnapshot> custom({
    Expression<String>? id,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<String>? deviceId,
    Expression<int>? ts,
    Expression<String>? indices,
    Expression<String>? breadth,
    Expression<double>? turnover,
    Expression<String>? extra,
    Expression<bool>? isBackfilled,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (deviceId != null) 'device_id': deviceId,
      if (ts != null) 'ts': ts,
      if (indices != null) 'indices': indices,
      if (breadth != null) 'breadth': breadth,
      if (turnover != null) 'turnover': turnover,
      if (extra != null) 'extra': extra,
      if (isBackfilled != null) 'is_backfilled': isBackfilled,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MarketSnapshotsCompanion copyWith({
    Value<String>? id,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int?>? deletedAt,
    Value<String>? deviceId,
    Value<int>? ts,
    Value<Map<String, dynamic>>? indices,
    Value<Map<String, dynamic>?>? breadth,
    Value<double?>? turnover,
    Value<Map<String, dynamic>?>? extra,
    Value<bool>? isBackfilled,
    Value<int>? rowid,
  }) {
    return MarketSnapshotsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      deviceId: deviceId ?? this.deviceId,
      ts: ts ?? this.ts,
      indices: indices ?? this.indices,
      breadth: breadth ?? this.breadth,
      turnover: turnover ?? this.turnover,
      extra: extra ?? this.extra,
      isBackfilled: isBackfilled ?? this.isBackfilled,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (ts.present) {
      map['ts'] = Variable<int>(ts.value);
    }
    if (indices.present) {
      map['indices'] = Variable<String>(
        $MarketSnapshotsTable.$converterindices.toSql(indices.value),
      );
    }
    if (breadth.present) {
      map['breadth'] = Variable<String>(
        $MarketSnapshotsTable.$converterbreadthn.toSql(breadth.value),
      );
    }
    if (turnover.present) {
      map['turnover'] = Variable<double>(turnover.value);
    }
    if (extra.present) {
      map['extra'] = Variable<String>(
        $MarketSnapshotsTable.$converterextran.toSql(extra.value),
      );
    }
    if (isBackfilled.present) {
      map['is_backfilled'] = Variable<bool>(isBackfilled.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MarketSnapshotsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('ts: $ts, ')
          ..write('indices: $indices, ')
          ..write('breadth: $breadth, ')
          ..write('turnover: $turnover, ')
          ..write('extra: $extra, ')
          ..write('isBackfilled: $isBackfilled, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AttachmentsTable extends Attachments
    with TableInfo<$AttachmentsTable, Attachment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AttachmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entryIdMeta = const VerificationMeta(
    'entryId',
  );
  @override
  late final GeneratedColumn<String> entryId = GeneratedColumn<String>(
    'entry_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localPathMeta = const VerificationMeta(
    'localPath',
  );
  @override
  late final GeneratedColumn<String> localPath = GeneratedColumn<String>(
    'local_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mimeMeta = const VerificationMeta('mime');
  @override
  late final GeneratedColumn<String> mime = GeneratedColumn<String>(
    'mime',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sizeMeta = const VerificationMeta('size');
  @override
  late final GeneratedColumn<int> size = GeneratedColumn<int>(
    'size',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    deviceId,
    entryId,
    localPath,
    mime,
    size,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'attachments';
  @override
  VerificationContext validateIntegrity(
    Insertable<Attachment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('entry_id')) {
      context.handle(
        _entryIdMeta,
        entryId.isAcceptableOrUnknown(data['entry_id']!, _entryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entryIdMeta);
    }
    if (data.containsKey('local_path')) {
      context.handle(
        _localPathMeta,
        localPath.isAcceptableOrUnknown(data['local_path']!, _localPathMeta),
      );
    } else if (isInserting) {
      context.missing(_localPathMeta);
    }
    if (data.containsKey('mime')) {
      context.handle(
        _mimeMeta,
        mime.isAcceptableOrUnknown(data['mime']!, _mimeMeta),
      );
    } else if (isInserting) {
      context.missing(_mimeMeta);
    }
    if (data.containsKey('size')) {
      context.handle(
        _sizeMeta,
        size.isAcceptableOrUnknown(data['size']!, _sizeMeta),
      );
    } else if (isInserting) {
      context.missing(_sizeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Attachment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Attachment(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      entryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entry_id'],
      )!,
      localPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_path'],
      )!,
      mime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mime'],
      )!,
      size: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}size'],
      )!,
    );
  }

  @override
  $AttachmentsTable createAlias(String alias) {
    return $AttachmentsTable(attachedDatabase, alias);
  }
}

class Attachment extends DataClass implements Insertable<Attachment> {
  final String id;
  final int createdAt;
  final int updatedAt;
  final int? deletedAt;
  final String deviceId;
  final String entryId;
  final String localPath;
  final String mime;
  final int size;
  const Attachment({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.deviceId,
    required this.entryId,
    required this.localPath,
    required this.mime,
    required this.size,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['device_id'] = Variable<String>(deviceId);
    map['entry_id'] = Variable<String>(entryId);
    map['local_path'] = Variable<String>(localPath);
    map['mime'] = Variable<String>(mime);
    map['size'] = Variable<int>(size);
    return map;
  }

  AttachmentsCompanion toCompanion(bool nullToAbsent) {
    return AttachmentsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      deviceId: Value(deviceId),
      entryId: Value(entryId),
      localPath: Value(localPath),
      mime: Value(mime),
      size: Value(size),
    );
  }

  factory Attachment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Attachment(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      entryId: serializer.fromJson<String>(json['entryId']),
      localPath: serializer.fromJson<String>(json['localPath']),
      mime: serializer.fromJson<String>(json['mime']),
      size: serializer.fromJson<int>(json['size']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'deviceId': serializer.toJson<String>(deviceId),
      'entryId': serializer.toJson<String>(entryId),
      'localPath': serializer.toJson<String>(localPath),
      'mime': serializer.toJson<String>(mime),
      'size': serializer.toJson<int>(size),
    };
  }

  Attachment copyWith({
    String? id,
    int? createdAt,
    int? updatedAt,
    Value<int?> deletedAt = const Value.absent(),
    String? deviceId,
    String? entryId,
    String? localPath,
    String? mime,
    int? size,
  }) => Attachment(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    deviceId: deviceId ?? this.deviceId,
    entryId: entryId ?? this.entryId,
    localPath: localPath ?? this.localPath,
    mime: mime ?? this.mime,
    size: size ?? this.size,
  );
  Attachment copyWithCompanion(AttachmentsCompanion data) {
    return Attachment(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      entryId: data.entryId.present ? data.entryId.value : this.entryId,
      localPath: data.localPath.present ? data.localPath.value : this.localPath,
      mime: data.mime.present ? data.mime.value : this.mime,
      size: data.size.present ? data.size.value : this.size,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Attachment(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('entryId: $entryId, ')
          ..write('localPath: $localPath, ')
          ..write('mime: $mime, ')
          ..write('size: $size')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    deviceId,
    entryId,
    localPath,
    mime,
    size,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Attachment &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.deviceId == this.deviceId &&
          other.entryId == this.entryId &&
          other.localPath == this.localPath &&
          other.mime == this.mime &&
          other.size == this.size);
}

class AttachmentsCompanion extends UpdateCompanion<Attachment> {
  final Value<String> id;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<String> deviceId;
  final Value<String> entryId;
  final Value<String> localPath;
  final Value<String> mime;
  final Value<int> size;
  final Value<int> rowid;
  const AttachmentsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.entryId = const Value.absent(),
    this.localPath = const Value.absent(),
    this.mime = const Value.absent(),
    this.size = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AttachmentsCompanion.insert({
    required String id,
    required int createdAt,
    required int updatedAt,
    this.deletedAt = const Value.absent(),
    required String deviceId,
    required String entryId,
    required String localPath,
    required String mime,
    required int size,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       deviceId = Value(deviceId),
       entryId = Value(entryId),
       localPath = Value(localPath),
       mime = Value(mime),
       size = Value(size);
  static Insertable<Attachment> custom({
    Expression<String>? id,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<String>? deviceId,
    Expression<String>? entryId,
    Expression<String>? localPath,
    Expression<String>? mime,
    Expression<int>? size,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (deviceId != null) 'device_id': deviceId,
      if (entryId != null) 'entry_id': entryId,
      if (localPath != null) 'local_path': localPath,
      if (mime != null) 'mime': mime,
      if (size != null) 'size': size,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AttachmentsCompanion copyWith({
    Value<String>? id,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int?>? deletedAt,
    Value<String>? deviceId,
    Value<String>? entryId,
    Value<String>? localPath,
    Value<String>? mime,
    Value<int>? size,
    Value<int>? rowid,
  }) {
    return AttachmentsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      deviceId: deviceId ?? this.deviceId,
      entryId: entryId ?? this.entryId,
      localPath: localPath ?? this.localPath,
      mime: mime ?? this.mime,
      size: size ?? this.size,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (entryId.present) {
      map['entry_id'] = Variable<String>(entryId.value);
    }
    if (localPath.present) {
      map['local_path'] = Variable<String>(localPath.value);
    }
    if (mime.present) {
      map['mime'] = Variable<String>(mime.value);
    }
    if (size.present) {
      map['size'] = Variable<int>(size.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AttachmentsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('entryId: $entryId, ')
          ..write('localPath: $localPath, ')
          ..write('mime: $mime, ')
          ..write('size: $size, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $QuickPhrasesTable extends QuickPhrases
    with TableInfo<$QuickPhrasesTable, QuickPhrase> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $QuickPhrasesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _phraseMeta = const VerificationMeta('phrase');
  @override
  late final GeneratedColumn<String> phrase = GeneratedColumn<String>(
    'phrase',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sortMeta = const VerificationMeta('sort');
  @override
  late final GeneratedColumn<int> sort = GeneratedColumn<int>(
    'sort',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    deviceId,
    phrase,
    category,
    sort,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'quick_phrases';
  @override
  VerificationContext validateIntegrity(
    Insertable<QuickPhrase> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('phrase')) {
      context.handle(
        _phraseMeta,
        phrase.isAcceptableOrUnknown(data['phrase']!, _phraseMeta),
      );
    } else if (isInserting) {
      context.missing(_phraseMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    }
    if (data.containsKey('sort')) {
      context.handle(
        _sortMeta,
        sort.isAcceptableOrUnknown(data['sort']!, _sortMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  QuickPhrase map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return QuickPhrase(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      phrase: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phrase'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      ),
      sort: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort'],
      )!,
    );
  }

  @override
  $QuickPhrasesTable createAlias(String alias) {
    return $QuickPhrasesTable(attachedDatabase, alias);
  }
}

class QuickPhrase extends DataClass implements Insertable<QuickPhrase> {
  final String id;
  final int createdAt;
  final int updatedAt;
  final int? deletedAt;
  final String deviceId;
  final String phrase;
  final String? category;
  final int sort;
  const QuickPhrase({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.deviceId,
    required this.phrase,
    this.category,
    required this.sort,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['device_id'] = Variable<String>(deviceId);
    map['phrase'] = Variable<String>(phrase);
    if (!nullToAbsent || category != null) {
      map['category'] = Variable<String>(category);
    }
    map['sort'] = Variable<int>(sort);
    return map;
  }

  QuickPhrasesCompanion toCompanion(bool nullToAbsent) {
    return QuickPhrasesCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      deviceId: Value(deviceId),
      phrase: Value(phrase),
      category: category == null && nullToAbsent
          ? const Value.absent()
          : Value(category),
      sort: Value(sort),
    );
  }

  factory QuickPhrase.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return QuickPhrase(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      phrase: serializer.fromJson<String>(json['phrase']),
      category: serializer.fromJson<String?>(json['category']),
      sort: serializer.fromJson<int>(json['sort']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'deviceId': serializer.toJson<String>(deviceId),
      'phrase': serializer.toJson<String>(phrase),
      'category': serializer.toJson<String?>(category),
      'sort': serializer.toJson<int>(sort),
    };
  }

  QuickPhrase copyWith({
    String? id,
    int? createdAt,
    int? updatedAt,
    Value<int?> deletedAt = const Value.absent(),
    String? deviceId,
    String? phrase,
    Value<String?> category = const Value.absent(),
    int? sort,
  }) => QuickPhrase(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    deviceId: deviceId ?? this.deviceId,
    phrase: phrase ?? this.phrase,
    category: category.present ? category.value : this.category,
    sort: sort ?? this.sort,
  );
  QuickPhrase copyWithCompanion(QuickPhrasesCompanion data) {
    return QuickPhrase(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      phrase: data.phrase.present ? data.phrase.value : this.phrase,
      category: data.category.present ? data.category.value : this.category,
      sort: data.sort.present ? data.sort.value : this.sort,
    );
  }

  @override
  String toString() {
    return (StringBuffer('QuickPhrase(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('phrase: $phrase, ')
          ..write('category: $category, ')
          ..write('sort: $sort')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    deviceId,
    phrase,
    category,
    sort,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is QuickPhrase &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.deviceId == this.deviceId &&
          other.phrase == this.phrase &&
          other.category == this.category &&
          other.sort == this.sort);
}

class QuickPhrasesCompanion extends UpdateCompanion<QuickPhrase> {
  final Value<String> id;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<String> deviceId;
  final Value<String> phrase;
  final Value<String?> category;
  final Value<int> sort;
  final Value<int> rowid;
  const QuickPhrasesCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.phrase = const Value.absent(),
    this.category = const Value.absent(),
    this.sort = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  QuickPhrasesCompanion.insert({
    required String id,
    required int createdAt,
    required int updatedAt,
    this.deletedAt = const Value.absent(),
    required String deviceId,
    required String phrase,
    this.category = const Value.absent(),
    this.sort = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       deviceId = Value(deviceId),
       phrase = Value(phrase);
  static Insertable<QuickPhrase> custom({
    Expression<String>? id,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<String>? deviceId,
    Expression<String>? phrase,
    Expression<String>? category,
    Expression<int>? sort,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (deviceId != null) 'device_id': deviceId,
      if (phrase != null) 'phrase': phrase,
      if (category != null) 'category': category,
      if (sort != null) 'sort': sort,
      if (rowid != null) 'rowid': rowid,
    });
  }

  QuickPhrasesCompanion copyWith({
    Value<String>? id,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int?>? deletedAt,
    Value<String>? deviceId,
    Value<String>? phrase,
    Value<String?>? category,
    Value<int>? sort,
    Value<int>? rowid,
  }) {
    return QuickPhrasesCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      deviceId: deviceId ?? this.deviceId,
      phrase: phrase ?? this.phrase,
      category: category ?? this.category,
      sort: sort ?? this.sort,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (phrase.present) {
      map['phrase'] = Variable<String>(phrase.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (sort.present) {
      map['sort'] = Variable<int>(sort.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('QuickPhrasesCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('phrase: $phrase, ')
          ..write('category: $category, ')
          ..write('sort: $sort, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EntryTemplatesTable extends EntryTemplates
    with TableInfo<$EntryTemplatesTable, EntryTemplate> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EntryTemplatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  @override
  late final GeneratedColumnWithTypeConverter<Map<String, dynamic>, String>
  fields = GeneratedColumn<String>(
    'fields',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<Map<String, dynamic>>($EntryTemplatesTable.$converterfields);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    deviceId,
    name,
    fields,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'entry_templates';
  @override
  VerificationContext validateIntegrity(
    Insertable<EntryTemplate> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EntryTemplate map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EntryTemplate(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      fields: $EntryTemplatesTable.$converterfields.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}fields'],
        )!,
      ),
    );
  }

  @override
  $EntryTemplatesTable createAlias(String alias) {
    return $EntryTemplatesTable(attachedDatabase, alias);
  }

  static TypeConverter<Map<String, dynamic>, String> $converterfields =
      const JsonMapConverter();
}

class EntryTemplate extends DataClass implements Insertable<EntryTemplate> {
  final String id;
  final int createdAt;
  final int updatedAt;
  final int? deletedAt;
  final String deviceId;
  final String name;
  final Map<String, dynamic> fields;
  const EntryTemplate({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.deviceId,
    required this.name,
    required this.fields,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['device_id'] = Variable<String>(deviceId);
    map['name'] = Variable<String>(name);
    {
      map['fields'] = Variable<String>(
        $EntryTemplatesTable.$converterfields.toSql(fields),
      );
    }
    return map;
  }

  EntryTemplatesCompanion toCompanion(bool nullToAbsent) {
    return EntryTemplatesCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      deviceId: Value(deviceId),
      name: Value(name),
      fields: Value(fields),
    );
  }

  factory EntryTemplate.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EntryTemplate(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      name: serializer.fromJson<String>(json['name']),
      fields: serializer.fromJson<Map<String, dynamic>>(json['fields']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'deviceId': serializer.toJson<String>(deviceId),
      'name': serializer.toJson<String>(name),
      'fields': serializer.toJson<Map<String, dynamic>>(fields),
    };
  }

  EntryTemplate copyWith({
    String? id,
    int? createdAt,
    int? updatedAt,
    Value<int?> deletedAt = const Value.absent(),
    String? deviceId,
    String? name,
    Map<String, dynamic>? fields,
  }) => EntryTemplate(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    deviceId: deviceId ?? this.deviceId,
    name: name ?? this.name,
    fields: fields ?? this.fields,
  );
  EntryTemplate copyWithCompanion(EntryTemplatesCompanion data) {
    return EntryTemplate(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      name: data.name.present ? data.name.value : this.name,
      fields: data.fields.present ? data.fields.value : this.fields,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EntryTemplate(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('name: $name, ')
          ..write('fields: $fields')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, createdAt, updatedAt, deletedAt, deviceId, name, fields);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EntryTemplate &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.deviceId == this.deviceId &&
          other.name == this.name &&
          other.fields == this.fields);
}

class EntryTemplatesCompanion extends UpdateCompanion<EntryTemplate> {
  final Value<String> id;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<String> deviceId;
  final Value<String> name;
  final Value<Map<String, dynamic>> fields;
  final Value<int> rowid;
  const EntryTemplatesCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.name = const Value.absent(),
    this.fields = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EntryTemplatesCompanion.insert({
    required String id,
    required int createdAt,
    required int updatedAt,
    this.deletedAt = const Value.absent(),
    required String deviceId,
    required String name,
    required Map<String, dynamic> fields,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       deviceId = Value(deviceId),
       name = Value(name),
       fields = Value(fields);
  static Insertable<EntryTemplate> custom({
    Expression<String>? id,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<String>? deviceId,
    Expression<String>? name,
    Expression<String>? fields,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (deviceId != null) 'device_id': deviceId,
      if (name != null) 'name': name,
      if (fields != null) 'fields': fields,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EntryTemplatesCompanion copyWith({
    Value<String>? id,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int?>? deletedAt,
    Value<String>? deviceId,
    Value<String>? name,
    Value<Map<String, dynamic>>? fields,
    Value<int>? rowid,
  }) {
    return EntryTemplatesCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      deviceId: deviceId ?? this.deviceId,
      name: name ?? this.name,
      fields: fields ?? this.fields,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (fields.present) {
      map['fields'] = Variable<String>(
        $EntryTemplatesTable.$converterfields.toSql(fields.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EntryTemplatesCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('name: $name, ')
          ..write('fields: $fields, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PredictionsTable extends Predictions
    with TableInfo<$PredictionsTable, Prediction> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PredictionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entryIdMeta = const VerificationMeta(
    'entryId',
  );
  @override
  late final GeneratedColumn<String> entryId = GeneratedColumn<String>(
    'entry_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _analysisIdMeta = const VerificationMeta(
    'analysisId',
  );
  @override
  late final GeneratedColumn<String> analysisId = GeneratedColumn<String>(
    'analysis_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _targetCodeMeta = const VerificationMeta(
    'targetCode',
  );
  @override
  late final GeneratedColumn<String> targetCode = GeneratedColumn<String>(
    'target_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _directionMeta = const VerificationMeta(
    'direction',
  );
  @override
  late final GeneratedColumn<String> direction = GeneratedColumn<String>(
    'direction',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _horizonTypeMeta = const VerificationMeta(
    'horizonType',
  );
  @override
  late final GeneratedColumn<String> horizonType = GeneratedColumn<String>(
    'horizon_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dueDateMeta = const VerificationMeta(
    'dueDate',
  );
  @override
  late final GeneratedColumn<String> dueDate = GeneratedColumn<String>(
    'due_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _basePriceMeta = const VerificationMeta(
    'basePrice',
  );
  @override
  late final GeneratedColumn<double> basePrice = GeneratedColumn<double>(
    'base_price',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _targetPriceMeta = const VerificationMeta(
    'targetPrice',
  );
  @override
  late final GeneratedColumn<double> targetPrice = GeneratedColumn<double>(
    'target_price',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _stopPriceMeta = const VerificationMeta(
    'stopPrice',
  );
  @override
  late final GeneratedColumn<double> stopPrice = GeneratedColumn<double>(
    'stop_price',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rangeLowMeta = const VerificationMeta(
    'rangeLow',
  );
  @override
  late final GeneratedColumn<double> rangeLow = GeneratedColumn<double>(
    'range_low',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rangeHighMeta = const VerificationMeta(
    'rangeHigh',
  );
  @override
  late final GeneratedColumn<double> rangeHigh = GeneratedColumn<double>(
    'range_high',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _thresholdPctMeta = const VerificationMeta(
    'thresholdPct',
  );
  @override
  late final GeneratedColumn<double> thresholdPct = GeneratedColumn<double>(
    'threshold_pct',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _confidenceMeta = const VerificationMeta(
    'confidence',
  );
  @override
  late final GeneratedColumn<int> confidence = GeneratedColumn<int>(
    'confidence',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(3),
  );
  static const VerificationMeta _revisionCountMeta = const VerificationMeta(
    'revisionCount',
  );
  @override
  late final GeneratedColumn<int> revisionCount = GeneratedColumn<int>(
    'revision_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _modifiedBeforeDueMeta = const VerificationMeta(
    'modifiedBeforeDue',
  );
  @override
  late final GeneratedColumn<bool> modifiedBeforeDue = GeneratedColumn<bool>(
    'modified_before_due',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("modified_before_due" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    deviceId,
    entryId,
    source,
    analysisId,
    targetCode,
    direction,
    horizonType,
    dueDate,
    basePrice,
    targetPrice,
    stopPrice,
    rangeLow,
    rangeHigh,
    thresholdPct,
    confidence,
    revisionCount,
    modifiedBeforeDue,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'predictions';
  @override
  VerificationContext validateIntegrity(
    Insertable<Prediction> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('entry_id')) {
      context.handle(
        _entryIdMeta,
        entryId.isAcceptableOrUnknown(data['entry_id']!, _entryIdMeta),
      );
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('analysis_id')) {
      context.handle(
        _analysisIdMeta,
        analysisId.isAcceptableOrUnknown(data['analysis_id']!, _analysisIdMeta),
      );
    }
    if (data.containsKey('target_code')) {
      context.handle(
        _targetCodeMeta,
        targetCode.isAcceptableOrUnknown(data['target_code']!, _targetCodeMeta),
      );
    } else if (isInserting) {
      context.missing(_targetCodeMeta);
    }
    if (data.containsKey('direction')) {
      context.handle(
        _directionMeta,
        direction.isAcceptableOrUnknown(data['direction']!, _directionMeta),
      );
    } else if (isInserting) {
      context.missing(_directionMeta);
    }
    if (data.containsKey('horizon_type')) {
      context.handle(
        _horizonTypeMeta,
        horizonType.isAcceptableOrUnknown(
          data['horizon_type']!,
          _horizonTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_horizonTypeMeta);
    }
    if (data.containsKey('due_date')) {
      context.handle(
        _dueDateMeta,
        dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta),
      );
    } else if (isInserting) {
      context.missing(_dueDateMeta);
    }
    if (data.containsKey('base_price')) {
      context.handle(
        _basePriceMeta,
        basePrice.isAcceptableOrUnknown(data['base_price']!, _basePriceMeta),
      );
    }
    if (data.containsKey('target_price')) {
      context.handle(
        _targetPriceMeta,
        targetPrice.isAcceptableOrUnknown(
          data['target_price']!,
          _targetPriceMeta,
        ),
      );
    }
    if (data.containsKey('stop_price')) {
      context.handle(
        _stopPriceMeta,
        stopPrice.isAcceptableOrUnknown(data['stop_price']!, _stopPriceMeta),
      );
    }
    if (data.containsKey('range_low')) {
      context.handle(
        _rangeLowMeta,
        rangeLow.isAcceptableOrUnknown(data['range_low']!, _rangeLowMeta),
      );
    }
    if (data.containsKey('range_high')) {
      context.handle(
        _rangeHighMeta,
        rangeHigh.isAcceptableOrUnknown(data['range_high']!, _rangeHighMeta),
      );
    }
    if (data.containsKey('threshold_pct')) {
      context.handle(
        _thresholdPctMeta,
        thresholdPct.isAcceptableOrUnknown(
          data['threshold_pct']!,
          _thresholdPctMeta,
        ),
      );
    }
    if (data.containsKey('confidence')) {
      context.handle(
        _confidenceMeta,
        confidence.isAcceptableOrUnknown(data['confidence']!, _confidenceMeta),
      );
    }
    if (data.containsKey('revision_count')) {
      context.handle(
        _revisionCountMeta,
        revisionCount.isAcceptableOrUnknown(
          data['revision_count']!,
          _revisionCountMeta,
        ),
      );
    }
    if (data.containsKey('modified_before_due')) {
      context.handle(
        _modifiedBeforeDueMeta,
        modifiedBeforeDue.isAcceptableOrUnknown(
          data['modified_before_due']!,
          _modifiedBeforeDueMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Prediction map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Prediction(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      entryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entry_id'],
      ),
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      analysisId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}analysis_id'],
      ),
      targetCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_code'],
      )!,
      direction: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}direction'],
      )!,
      horizonType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}horizon_type'],
      )!,
      dueDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}due_date'],
      )!,
      basePrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}base_price'],
      ),
      targetPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}target_price'],
      ),
      stopPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}stop_price'],
      ),
      rangeLow: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}range_low'],
      ),
      rangeHigh: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}range_high'],
      ),
      thresholdPct: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}threshold_pct'],
      ),
      confidence: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}confidence'],
      )!,
      revisionCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revision_count'],
      )!,
      modifiedBeforeDue: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}modified_before_due'],
      )!,
    );
  }

  @override
  $PredictionsTable createAlias(String alias) {
    return $PredictionsTable(attachedDatabase, alias);
  }
}

class Prediction extends DataClass implements Insertable<Prediction> {
  final String id;
  final int createdAt;
  final int updatedAt;
  final int? deletedAt;
  final String deviceId;
  final String? entryId;

  /// user | ai
  final String source;
  final String? analysisId;
  final String targetCode;

  /// up | down | range
  final String direction;

  /// close | t1 | t3 | t5 | custom
  final String horizonType;
  final String dueDate;
  final double? basePrice;
  final double? targetPrice;
  final double? stopPrice;
  final double? rangeLow;
  final double? rangeHigh;

  /// 单条判断的阈值覆盖（百分比，如 0.5 表示 ±0.5%）
  final double? thresholdPct;
  final int confidence;
  final int revisionCount;
  final bool modifiedBeforeDue;
  const Prediction({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.deviceId,
    this.entryId,
    required this.source,
    this.analysisId,
    required this.targetCode,
    required this.direction,
    required this.horizonType,
    required this.dueDate,
    this.basePrice,
    this.targetPrice,
    this.stopPrice,
    this.rangeLow,
    this.rangeHigh,
    this.thresholdPct,
    required this.confidence,
    required this.revisionCount,
    required this.modifiedBeforeDue,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['device_id'] = Variable<String>(deviceId);
    if (!nullToAbsent || entryId != null) {
      map['entry_id'] = Variable<String>(entryId);
    }
    map['source'] = Variable<String>(source);
    if (!nullToAbsent || analysisId != null) {
      map['analysis_id'] = Variable<String>(analysisId);
    }
    map['target_code'] = Variable<String>(targetCode);
    map['direction'] = Variable<String>(direction);
    map['horizon_type'] = Variable<String>(horizonType);
    map['due_date'] = Variable<String>(dueDate);
    if (!nullToAbsent || basePrice != null) {
      map['base_price'] = Variable<double>(basePrice);
    }
    if (!nullToAbsent || targetPrice != null) {
      map['target_price'] = Variable<double>(targetPrice);
    }
    if (!nullToAbsent || stopPrice != null) {
      map['stop_price'] = Variable<double>(stopPrice);
    }
    if (!nullToAbsent || rangeLow != null) {
      map['range_low'] = Variable<double>(rangeLow);
    }
    if (!nullToAbsent || rangeHigh != null) {
      map['range_high'] = Variable<double>(rangeHigh);
    }
    if (!nullToAbsent || thresholdPct != null) {
      map['threshold_pct'] = Variable<double>(thresholdPct);
    }
    map['confidence'] = Variable<int>(confidence);
    map['revision_count'] = Variable<int>(revisionCount);
    map['modified_before_due'] = Variable<bool>(modifiedBeforeDue);
    return map;
  }

  PredictionsCompanion toCompanion(bool nullToAbsent) {
    return PredictionsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      deviceId: Value(deviceId),
      entryId: entryId == null && nullToAbsent
          ? const Value.absent()
          : Value(entryId),
      source: Value(source),
      analysisId: analysisId == null && nullToAbsent
          ? const Value.absent()
          : Value(analysisId),
      targetCode: Value(targetCode),
      direction: Value(direction),
      horizonType: Value(horizonType),
      dueDate: Value(dueDate),
      basePrice: basePrice == null && nullToAbsent
          ? const Value.absent()
          : Value(basePrice),
      targetPrice: targetPrice == null && nullToAbsent
          ? const Value.absent()
          : Value(targetPrice),
      stopPrice: stopPrice == null && nullToAbsent
          ? const Value.absent()
          : Value(stopPrice),
      rangeLow: rangeLow == null && nullToAbsent
          ? const Value.absent()
          : Value(rangeLow),
      rangeHigh: rangeHigh == null && nullToAbsent
          ? const Value.absent()
          : Value(rangeHigh),
      thresholdPct: thresholdPct == null && nullToAbsent
          ? const Value.absent()
          : Value(thresholdPct),
      confidence: Value(confidence),
      revisionCount: Value(revisionCount),
      modifiedBeforeDue: Value(modifiedBeforeDue),
    );
  }

  factory Prediction.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Prediction(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      entryId: serializer.fromJson<String?>(json['entryId']),
      source: serializer.fromJson<String>(json['source']),
      analysisId: serializer.fromJson<String?>(json['analysisId']),
      targetCode: serializer.fromJson<String>(json['targetCode']),
      direction: serializer.fromJson<String>(json['direction']),
      horizonType: serializer.fromJson<String>(json['horizonType']),
      dueDate: serializer.fromJson<String>(json['dueDate']),
      basePrice: serializer.fromJson<double?>(json['basePrice']),
      targetPrice: serializer.fromJson<double?>(json['targetPrice']),
      stopPrice: serializer.fromJson<double?>(json['stopPrice']),
      rangeLow: serializer.fromJson<double?>(json['rangeLow']),
      rangeHigh: serializer.fromJson<double?>(json['rangeHigh']),
      thresholdPct: serializer.fromJson<double?>(json['thresholdPct']),
      confidence: serializer.fromJson<int>(json['confidence']),
      revisionCount: serializer.fromJson<int>(json['revisionCount']),
      modifiedBeforeDue: serializer.fromJson<bool>(json['modifiedBeforeDue']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'deviceId': serializer.toJson<String>(deviceId),
      'entryId': serializer.toJson<String?>(entryId),
      'source': serializer.toJson<String>(source),
      'analysisId': serializer.toJson<String?>(analysisId),
      'targetCode': serializer.toJson<String>(targetCode),
      'direction': serializer.toJson<String>(direction),
      'horizonType': serializer.toJson<String>(horizonType),
      'dueDate': serializer.toJson<String>(dueDate),
      'basePrice': serializer.toJson<double?>(basePrice),
      'targetPrice': serializer.toJson<double?>(targetPrice),
      'stopPrice': serializer.toJson<double?>(stopPrice),
      'rangeLow': serializer.toJson<double?>(rangeLow),
      'rangeHigh': serializer.toJson<double?>(rangeHigh),
      'thresholdPct': serializer.toJson<double?>(thresholdPct),
      'confidence': serializer.toJson<int>(confidence),
      'revisionCount': serializer.toJson<int>(revisionCount),
      'modifiedBeforeDue': serializer.toJson<bool>(modifiedBeforeDue),
    };
  }

  Prediction copyWith({
    String? id,
    int? createdAt,
    int? updatedAt,
    Value<int?> deletedAt = const Value.absent(),
    String? deviceId,
    Value<String?> entryId = const Value.absent(),
    String? source,
    Value<String?> analysisId = const Value.absent(),
    String? targetCode,
    String? direction,
    String? horizonType,
    String? dueDate,
    Value<double?> basePrice = const Value.absent(),
    Value<double?> targetPrice = const Value.absent(),
    Value<double?> stopPrice = const Value.absent(),
    Value<double?> rangeLow = const Value.absent(),
    Value<double?> rangeHigh = const Value.absent(),
    Value<double?> thresholdPct = const Value.absent(),
    int? confidence,
    int? revisionCount,
    bool? modifiedBeforeDue,
  }) => Prediction(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    deviceId: deviceId ?? this.deviceId,
    entryId: entryId.present ? entryId.value : this.entryId,
    source: source ?? this.source,
    analysisId: analysisId.present ? analysisId.value : this.analysisId,
    targetCode: targetCode ?? this.targetCode,
    direction: direction ?? this.direction,
    horizonType: horizonType ?? this.horizonType,
    dueDate: dueDate ?? this.dueDate,
    basePrice: basePrice.present ? basePrice.value : this.basePrice,
    targetPrice: targetPrice.present ? targetPrice.value : this.targetPrice,
    stopPrice: stopPrice.present ? stopPrice.value : this.stopPrice,
    rangeLow: rangeLow.present ? rangeLow.value : this.rangeLow,
    rangeHigh: rangeHigh.present ? rangeHigh.value : this.rangeHigh,
    thresholdPct: thresholdPct.present ? thresholdPct.value : this.thresholdPct,
    confidence: confidence ?? this.confidence,
    revisionCount: revisionCount ?? this.revisionCount,
    modifiedBeforeDue: modifiedBeforeDue ?? this.modifiedBeforeDue,
  );
  Prediction copyWithCompanion(PredictionsCompanion data) {
    return Prediction(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      entryId: data.entryId.present ? data.entryId.value : this.entryId,
      source: data.source.present ? data.source.value : this.source,
      analysisId: data.analysisId.present
          ? data.analysisId.value
          : this.analysisId,
      targetCode: data.targetCode.present
          ? data.targetCode.value
          : this.targetCode,
      direction: data.direction.present ? data.direction.value : this.direction,
      horizonType: data.horizonType.present
          ? data.horizonType.value
          : this.horizonType,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      basePrice: data.basePrice.present ? data.basePrice.value : this.basePrice,
      targetPrice: data.targetPrice.present
          ? data.targetPrice.value
          : this.targetPrice,
      stopPrice: data.stopPrice.present ? data.stopPrice.value : this.stopPrice,
      rangeLow: data.rangeLow.present ? data.rangeLow.value : this.rangeLow,
      rangeHigh: data.rangeHigh.present ? data.rangeHigh.value : this.rangeHigh,
      thresholdPct: data.thresholdPct.present
          ? data.thresholdPct.value
          : this.thresholdPct,
      confidence: data.confidence.present
          ? data.confidence.value
          : this.confidence,
      revisionCount: data.revisionCount.present
          ? data.revisionCount.value
          : this.revisionCount,
      modifiedBeforeDue: data.modifiedBeforeDue.present
          ? data.modifiedBeforeDue.value
          : this.modifiedBeforeDue,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Prediction(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('entryId: $entryId, ')
          ..write('source: $source, ')
          ..write('analysisId: $analysisId, ')
          ..write('targetCode: $targetCode, ')
          ..write('direction: $direction, ')
          ..write('horizonType: $horizonType, ')
          ..write('dueDate: $dueDate, ')
          ..write('basePrice: $basePrice, ')
          ..write('targetPrice: $targetPrice, ')
          ..write('stopPrice: $stopPrice, ')
          ..write('rangeLow: $rangeLow, ')
          ..write('rangeHigh: $rangeHigh, ')
          ..write('thresholdPct: $thresholdPct, ')
          ..write('confidence: $confidence, ')
          ..write('revisionCount: $revisionCount, ')
          ..write('modifiedBeforeDue: $modifiedBeforeDue')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    createdAt,
    updatedAt,
    deletedAt,
    deviceId,
    entryId,
    source,
    analysisId,
    targetCode,
    direction,
    horizonType,
    dueDate,
    basePrice,
    targetPrice,
    stopPrice,
    rangeLow,
    rangeHigh,
    thresholdPct,
    confidence,
    revisionCount,
    modifiedBeforeDue,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Prediction &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.deviceId == this.deviceId &&
          other.entryId == this.entryId &&
          other.source == this.source &&
          other.analysisId == this.analysisId &&
          other.targetCode == this.targetCode &&
          other.direction == this.direction &&
          other.horizonType == this.horizonType &&
          other.dueDate == this.dueDate &&
          other.basePrice == this.basePrice &&
          other.targetPrice == this.targetPrice &&
          other.stopPrice == this.stopPrice &&
          other.rangeLow == this.rangeLow &&
          other.rangeHigh == this.rangeHigh &&
          other.thresholdPct == this.thresholdPct &&
          other.confidence == this.confidence &&
          other.revisionCount == this.revisionCount &&
          other.modifiedBeforeDue == this.modifiedBeforeDue);
}

class PredictionsCompanion extends UpdateCompanion<Prediction> {
  final Value<String> id;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<String> deviceId;
  final Value<String?> entryId;
  final Value<String> source;
  final Value<String?> analysisId;
  final Value<String> targetCode;
  final Value<String> direction;
  final Value<String> horizonType;
  final Value<String> dueDate;
  final Value<double?> basePrice;
  final Value<double?> targetPrice;
  final Value<double?> stopPrice;
  final Value<double?> rangeLow;
  final Value<double?> rangeHigh;
  final Value<double?> thresholdPct;
  final Value<int> confidence;
  final Value<int> revisionCount;
  final Value<bool> modifiedBeforeDue;
  final Value<int> rowid;
  const PredictionsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.entryId = const Value.absent(),
    this.source = const Value.absent(),
    this.analysisId = const Value.absent(),
    this.targetCode = const Value.absent(),
    this.direction = const Value.absent(),
    this.horizonType = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.basePrice = const Value.absent(),
    this.targetPrice = const Value.absent(),
    this.stopPrice = const Value.absent(),
    this.rangeLow = const Value.absent(),
    this.rangeHigh = const Value.absent(),
    this.thresholdPct = const Value.absent(),
    this.confidence = const Value.absent(),
    this.revisionCount = const Value.absent(),
    this.modifiedBeforeDue = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PredictionsCompanion.insert({
    required String id,
    required int createdAt,
    required int updatedAt,
    this.deletedAt = const Value.absent(),
    required String deviceId,
    this.entryId = const Value.absent(),
    required String source,
    this.analysisId = const Value.absent(),
    required String targetCode,
    required String direction,
    required String horizonType,
    required String dueDate,
    this.basePrice = const Value.absent(),
    this.targetPrice = const Value.absent(),
    this.stopPrice = const Value.absent(),
    this.rangeLow = const Value.absent(),
    this.rangeHigh = const Value.absent(),
    this.thresholdPct = const Value.absent(),
    this.confidence = const Value.absent(),
    this.revisionCount = const Value.absent(),
    this.modifiedBeforeDue = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       deviceId = Value(deviceId),
       source = Value(source),
       targetCode = Value(targetCode),
       direction = Value(direction),
       horizonType = Value(horizonType),
       dueDate = Value(dueDate);
  static Insertable<Prediction> custom({
    Expression<String>? id,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<String>? deviceId,
    Expression<String>? entryId,
    Expression<String>? source,
    Expression<String>? analysisId,
    Expression<String>? targetCode,
    Expression<String>? direction,
    Expression<String>? horizonType,
    Expression<String>? dueDate,
    Expression<double>? basePrice,
    Expression<double>? targetPrice,
    Expression<double>? stopPrice,
    Expression<double>? rangeLow,
    Expression<double>? rangeHigh,
    Expression<double>? thresholdPct,
    Expression<int>? confidence,
    Expression<int>? revisionCount,
    Expression<bool>? modifiedBeforeDue,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (deviceId != null) 'device_id': deviceId,
      if (entryId != null) 'entry_id': entryId,
      if (source != null) 'source': source,
      if (analysisId != null) 'analysis_id': analysisId,
      if (targetCode != null) 'target_code': targetCode,
      if (direction != null) 'direction': direction,
      if (horizonType != null) 'horizon_type': horizonType,
      if (dueDate != null) 'due_date': dueDate,
      if (basePrice != null) 'base_price': basePrice,
      if (targetPrice != null) 'target_price': targetPrice,
      if (stopPrice != null) 'stop_price': stopPrice,
      if (rangeLow != null) 'range_low': rangeLow,
      if (rangeHigh != null) 'range_high': rangeHigh,
      if (thresholdPct != null) 'threshold_pct': thresholdPct,
      if (confidence != null) 'confidence': confidence,
      if (revisionCount != null) 'revision_count': revisionCount,
      if (modifiedBeforeDue != null) 'modified_before_due': modifiedBeforeDue,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PredictionsCompanion copyWith({
    Value<String>? id,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int?>? deletedAt,
    Value<String>? deviceId,
    Value<String?>? entryId,
    Value<String>? source,
    Value<String?>? analysisId,
    Value<String>? targetCode,
    Value<String>? direction,
    Value<String>? horizonType,
    Value<String>? dueDate,
    Value<double?>? basePrice,
    Value<double?>? targetPrice,
    Value<double?>? stopPrice,
    Value<double?>? rangeLow,
    Value<double?>? rangeHigh,
    Value<double?>? thresholdPct,
    Value<int>? confidence,
    Value<int>? revisionCount,
    Value<bool>? modifiedBeforeDue,
    Value<int>? rowid,
  }) {
    return PredictionsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      deviceId: deviceId ?? this.deviceId,
      entryId: entryId ?? this.entryId,
      source: source ?? this.source,
      analysisId: analysisId ?? this.analysisId,
      targetCode: targetCode ?? this.targetCode,
      direction: direction ?? this.direction,
      horizonType: horizonType ?? this.horizonType,
      dueDate: dueDate ?? this.dueDate,
      basePrice: basePrice ?? this.basePrice,
      targetPrice: targetPrice ?? this.targetPrice,
      stopPrice: stopPrice ?? this.stopPrice,
      rangeLow: rangeLow ?? this.rangeLow,
      rangeHigh: rangeHigh ?? this.rangeHigh,
      thresholdPct: thresholdPct ?? this.thresholdPct,
      confidence: confidence ?? this.confidence,
      revisionCount: revisionCount ?? this.revisionCount,
      modifiedBeforeDue: modifiedBeforeDue ?? this.modifiedBeforeDue,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (entryId.present) {
      map['entry_id'] = Variable<String>(entryId.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (analysisId.present) {
      map['analysis_id'] = Variable<String>(analysisId.value);
    }
    if (targetCode.present) {
      map['target_code'] = Variable<String>(targetCode.value);
    }
    if (direction.present) {
      map['direction'] = Variable<String>(direction.value);
    }
    if (horizonType.present) {
      map['horizon_type'] = Variable<String>(horizonType.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<String>(dueDate.value);
    }
    if (basePrice.present) {
      map['base_price'] = Variable<double>(basePrice.value);
    }
    if (targetPrice.present) {
      map['target_price'] = Variable<double>(targetPrice.value);
    }
    if (stopPrice.present) {
      map['stop_price'] = Variable<double>(stopPrice.value);
    }
    if (rangeLow.present) {
      map['range_low'] = Variable<double>(rangeLow.value);
    }
    if (rangeHigh.present) {
      map['range_high'] = Variable<double>(rangeHigh.value);
    }
    if (thresholdPct.present) {
      map['threshold_pct'] = Variable<double>(thresholdPct.value);
    }
    if (confidence.present) {
      map['confidence'] = Variable<int>(confidence.value);
    }
    if (revisionCount.present) {
      map['revision_count'] = Variable<int>(revisionCount.value);
    }
    if (modifiedBeforeDue.present) {
      map['modified_before_due'] = Variable<bool>(modifiedBeforeDue.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PredictionsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('entryId: $entryId, ')
          ..write('source: $source, ')
          ..write('analysisId: $analysisId, ')
          ..write('targetCode: $targetCode, ')
          ..write('direction: $direction, ')
          ..write('horizonType: $horizonType, ')
          ..write('dueDate: $dueDate, ')
          ..write('basePrice: $basePrice, ')
          ..write('targetPrice: $targetPrice, ')
          ..write('stopPrice: $stopPrice, ')
          ..write('rangeLow: $rangeLow, ')
          ..write('rangeHigh: $rangeHigh, ')
          ..write('thresholdPct: $thresholdPct, ')
          ..write('confidence: $confidence, ')
          ..write('revisionCount: $revisionCount, ')
          ..write('modifiedBeforeDue: $modifiedBeforeDue, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PredictionResultsTable extends PredictionResults
    with TableInfo<$PredictionResultsTable, PredictionResult> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PredictionResultsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _predictionIdMeta = const VerificationMeta(
    'predictionId',
  );
  @override
  late final GeneratedColumn<String> predictionId = GeneratedColumn<String>(
    'prediction_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _actualCloseMeta = const VerificationMeta(
    'actualClose',
  );
  @override
  late final GeneratedColumn<double> actualClose = GeneratedColumn<double>(
    'actual_close',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _changePctMeta = const VerificationMeta(
    'changePct',
  );
  @override
  late final GeneratedColumn<double> changePct = GeneratedColumn<double>(
    'change_pct',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _mfeMeta = const VerificationMeta('mfe');
  @override
  late final GeneratedColumn<double> mfe = GeneratedColumn<double>(
    'mfe',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _maeMeta = const VerificationMeta('mae');
  @override
  late final GeneratedColumn<double> mae = GeneratedColumn<double>(
    'mae',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _decidedAtMeta = const VerificationMeta(
    'decidedAt',
  );
  @override
  late final GeneratedColumn<int> decidedAt = GeneratedColumn<int>(
    'decided_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isManualMeta = const VerificationMeta(
    'isManual',
  );
  @override
  late final GeneratedColumn<bool> isManual = GeneratedColumn<bool>(
    'is_manual',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_manual" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _ruleVersionMeta = const VerificationMeta(
    'ruleVersion',
  );
  @override
  late final GeneratedColumn<int> ruleVersion = GeneratedColumn<int>(
    'rule_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    deviceId,
    predictionId,
    status,
    actualClose,
    changePct,
    mfe,
    mae,
    decidedAt,
    isManual,
    ruleVersion,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'prediction_results';
  @override
  VerificationContext validateIntegrity(
    Insertable<PredictionResult> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('prediction_id')) {
      context.handle(
        _predictionIdMeta,
        predictionId.isAcceptableOrUnknown(
          data['prediction_id']!,
          _predictionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_predictionIdMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('actual_close')) {
      context.handle(
        _actualCloseMeta,
        actualClose.isAcceptableOrUnknown(
          data['actual_close']!,
          _actualCloseMeta,
        ),
      );
    }
    if (data.containsKey('change_pct')) {
      context.handle(
        _changePctMeta,
        changePct.isAcceptableOrUnknown(data['change_pct']!, _changePctMeta),
      );
    }
    if (data.containsKey('mfe')) {
      context.handle(
        _mfeMeta,
        mfe.isAcceptableOrUnknown(data['mfe']!, _mfeMeta),
      );
    }
    if (data.containsKey('mae')) {
      context.handle(
        _maeMeta,
        mae.isAcceptableOrUnknown(data['mae']!, _maeMeta),
      );
    }
    if (data.containsKey('decided_at')) {
      context.handle(
        _decidedAtMeta,
        decidedAt.isAcceptableOrUnknown(data['decided_at']!, _decidedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_decidedAtMeta);
    }
    if (data.containsKey('is_manual')) {
      context.handle(
        _isManualMeta,
        isManual.isAcceptableOrUnknown(data['is_manual']!, _isManualMeta),
      );
    }
    if (data.containsKey('rule_version')) {
      context.handle(
        _ruleVersionMeta,
        ruleVersion.isAcceptableOrUnknown(
          data['rule_version']!,
          _ruleVersionMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PredictionResult map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PredictionResult(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      predictionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}prediction_id'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      actualClose: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}actual_close'],
      ),
      changePct: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}change_pct'],
      ),
      mfe: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}mfe'],
      ),
      mae: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}mae'],
      ),
      decidedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}decided_at'],
      )!,
      isManual: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_manual'],
      )!,
      ruleVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rule_version'],
      )!,
    );
  }

  @override
  $PredictionResultsTable createAlias(String alias) {
    return $PredictionResultsTable(attachedDatabase, alias);
  }
}

class PredictionResult extends DataClass
    implements Insertable<PredictionResult> {
  final String id;
  final int createdAt;
  final int updatedAt;
  final int? deletedAt;
  final String deviceId;
  final String predictionId;

  /// correct | wrong | partial | pending_manual
  final String status;
  final double? actualClose;
  final double? changePct;
  final double? mfe;
  final double? mae;
  final int decidedAt;
  final bool isManual;
  final int ruleVersion;
  const PredictionResult({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.deviceId,
    required this.predictionId,
    required this.status,
    this.actualClose,
    this.changePct,
    this.mfe,
    this.mae,
    required this.decidedAt,
    required this.isManual,
    required this.ruleVersion,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['device_id'] = Variable<String>(deviceId);
    map['prediction_id'] = Variable<String>(predictionId);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || actualClose != null) {
      map['actual_close'] = Variable<double>(actualClose);
    }
    if (!nullToAbsent || changePct != null) {
      map['change_pct'] = Variable<double>(changePct);
    }
    if (!nullToAbsent || mfe != null) {
      map['mfe'] = Variable<double>(mfe);
    }
    if (!nullToAbsent || mae != null) {
      map['mae'] = Variable<double>(mae);
    }
    map['decided_at'] = Variable<int>(decidedAt);
    map['is_manual'] = Variable<bool>(isManual);
    map['rule_version'] = Variable<int>(ruleVersion);
    return map;
  }

  PredictionResultsCompanion toCompanion(bool nullToAbsent) {
    return PredictionResultsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      deviceId: Value(deviceId),
      predictionId: Value(predictionId),
      status: Value(status),
      actualClose: actualClose == null && nullToAbsent
          ? const Value.absent()
          : Value(actualClose),
      changePct: changePct == null && nullToAbsent
          ? const Value.absent()
          : Value(changePct),
      mfe: mfe == null && nullToAbsent ? const Value.absent() : Value(mfe),
      mae: mae == null && nullToAbsent ? const Value.absent() : Value(mae),
      decidedAt: Value(decidedAt),
      isManual: Value(isManual),
      ruleVersion: Value(ruleVersion),
    );
  }

  factory PredictionResult.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PredictionResult(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      predictionId: serializer.fromJson<String>(json['predictionId']),
      status: serializer.fromJson<String>(json['status']),
      actualClose: serializer.fromJson<double?>(json['actualClose']),
      changePct: serializer.fromJson<double?>(json['changePct']),
      mfe: serializer.fromJson<double?>(json['mfe']),
      mae: serializer.fromJson<double?>(json['mae']),
      decidedAt: serializer.fromJson<int>(json['decidedAt']),
      isManual: serializer.fromJson<bool>(json['isManual']),
      ruleVersion: serializer.fromJson<int>(json['ruleVersion']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'deviceId': serializer.toJson<String>(deviceId),
      'predictionId': serializer.toJson<String>(predictionId),
      'status': serializer.toJson<String>(status),
      'actualClose': serializer.toJson<double?>(actualClose),
      'changePct': serializer.toJson<double?>(changePct),
      'mfe': serializer.toJson<double?>(mfe),
      'mae': serializer.toJson<double?>(mae),
      'decidedAt': serializer.toJson<int>(decidedAt),
      'isManual': serializer.toJson<bool>(isManual),
      'ruleVersion': serializer.toJson<int>(ruleVersion),
    };
  }

  PredictionResult copyWith({
    String? id,
    int? createdAt,
    int? updatedAt,
    Value<int?> deletedAt = const Value.absent(),
    String? deviceId,
    String? predictionId,
    String? status,
    Value<double?> actualClose = const Value.absent(),
    Value<double?> changePct = const Value.absent(),
    Value<double?> mfe = const Value.absent(),
    Value<double?> mae = const Value.absent(),
    int? decidedAt,
    bool? isManual,
    int? ruleVersion,
  }) => PredictionResult(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    deviceId: deviceId ?? this.deviceId,
    predictionId: predictionId ?? this.predictionId,
    status: status ?? this.status,
    actualClose: actualClose.present ? actualClose.value : this.actualClose,
    changePct: changePct.present ? changePct.value : this.changePct,
    mfe: mfe.present ? mfe.value : this.mfe,
    mae: mae.present ? mae.value : this.mae,
    decidedAt: decidedAt ?? this.decidedAt,
    isManual: isManual ?? this.isManual,
    ruleVersion: ruleVersion ?? this.ruleVersion,
  );
  PredictionResult copyWithCompanion(PredictionResultsCompanion data) {
    return PredictionResult(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      predictionId: data.predictionId.present
          ? data.predictionId.value
          : this.predictionId,
      status: data.status.present ? data.status.value : this.status,
      actualClose: data.actualClose.present
          ? data.actualClose.value
          : this.actualClose,
      changePct: data.changePct.present ? data.changePct.value : this.changePct,
      mfe: data.mfe.present ? data.mfe.value : this.mfe,
      mae: data.mae.present ? data.mae.value : this.mae,
      decidedAt: data.decidedAt.present ? data.decidedAt.value : this.decidedAt,
      isManual: data.isManual.present ? data.isManual.value : this.isManual,
      ruleVersion: data.ruleVersion.present
          ? data.ruleVersion.value
          : this.ruleVersion,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PredictionResult(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('predictionId: $predictionId, ')
          ..write('status: $status, ')
          ..write('actualClose: $actualClose, ')
          ..write('changePct: $changePct, ')
          ..write('mfe: $mfe, ')
          ..write('mae: $mae, ')
          ..write('decidedAt: $decidedAt, ')
          ..write('isManual: $isManual, ')
          ..write('ruleVersion: $ruleVersion')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    deviceId,
    predictionId,
    status,
    actualClose,
    changePct,
    mfe,
    mae,
    decidedAt,
    isManual,
    ruleVersion,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PredictionResult &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.deviceId == this.deviceId &&
          other.predictionId == this.predictionId &&
          other.status == this.status &&
          other.actualClose == this.actualClose &&
          other.changePct == this.changePct &&
          other.mfe == this.mfe &&
          other.mae == this.mae &&
          other.decidedAt == this.decidedAt &&
          other.isManual == this.isManual &&
          other.ruleVersion == this.ruleVersion);
}

class PredictionResultsCompanion extends UpdateCompanion<PredictionResult> {
  final Value<String> id;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<String> deviceId;
  final Value<String> predictionId;
  final Value<String> status;
  final Value<double?> actualClose;
  final Value<double?> changePct;
  final Value<double?> mfe;
  final Value<double?> mae;
  final Value<int> decidedAt;
  final Value<bool> isManual;
  final Value<int> ruleVersion;
  final Value<int> rowid;
  const PredictionResultsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.predictionId = const Value.absent(),
    this.status = const Value.absent(),
    this.actualClose = const Value.absent(),
    this.changePct = const Value.absent(),
    this.mfe = const Value.absent(),
    this.mae = const Value.absent(),
    this.decidedAt = const Value.absent(),
    this.isManual = const Value.absent(),
    this.ruleVersion = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PredictionResultsCompanion.insert({
    required String id,
    required int createdAt,
    required int updatedAt,
    this.deletedAt = const Value.absent(),
    required String deviceId,
    required String predictionId,
    required String status,
    this.actualClose = const Value.absent(),
    this.changePct = const Value.absent(),
    this.mfe = const Value.absent(),
    this.mae = const Value.absent(),
    required int decidedAt,
    this.isManual = const Value.absent(),
    this.ruleVersion = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       deviceId = Value(deviceId),
       predictionId = Value(predictionId),
       status = Value(status),
       decidedAt = Value(decidedAt);
  static Insertable<PredictionResult> custom({
    Expression<String>? id,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<String>? deviceId,
    Expression<String>? predictionId,
    Expression<String>? status,
    Expression<double>? actualClose,
    Expression<double>? changePct,
    Expression<double>? mfe,
    Expression<double>? mae,
    Expression<int>? decidedAt,
    Expression<bool>? isManual,
    Expression<int>? ruleVersion,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (deviceId != null) 'device_id': deviceId,
      if (predictionId != null) 'prediction_id': predictionId,
      if (status != null) 'status': status,
      if (actualClose != null) 'actual_close': actualClose,
      if (changePct != null) 'change_pct': changePct,
      if (mfe != null) 'mfe': mfe,
      if (mae != null) 'mae': mae,
      if (decidedAt != null) 'decided_at': decidedAt,
      if (isManual != null) 'is_manual': isManual,
      if (ruleVersion != null) 'rule_version': ruleVersion,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PredictionResultsCompanion copyWith({
    Value<String>? id,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int?>? deletedAt,
    Value<String>? deviceId,
    Value<String>? predictionId,
    Value<String>? status,
    Value<double?>? actualClose,
    Value<double?>? changePct,
    Value<double?>? mfe,
    Value<double?>? mae,
    Value<int>? decidedAt,
    Value<bool>? isManual,
    Value<int>? ruleVersion,
    Value<int>? rowid,
  }) {
    return PredictionResultsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      deviceId: deviceId ?? this.deviceId,
      predictionId: predictionId ?? this.predictionId,
      status: status ?? this.status,
      actualClose: actualClose ?? this.actualClose,
      changePct: changePct ?? this.changePct,
      mfe: mfe ?? this.mfe,
      mae: mae ?? this.mae,
      decidedAt: decidedAt ?? this.decidedAt,
      isManual: isManual ?? this.isManual,
      ruleVersion: ruleVersion ?? this.ruleVersion,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (predictionId.present) {
      map['prediction_id'] = Variable<String>(predictionId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (actualClose.present) {
      map['actual_close'] = Variable<double>(actualClose.value);
    }
    if (changePct.present) {
      map['change_pct'] = Variable<double>(changePct.value);
    }
    if (mfe.present) {
      map['mfe'] = Variable<double>(mfe.value);
    }
    if (mae.present) {
      map['mae'] = Variable<double>(mae.value);
    }
    if (decidedAt.present) {
      map['decided_at'] = Variable<int>(decidedAt.value);
    }
    if (isManual.present) {
      map['is_manual'] = Variable<bool>(isManual.value);
    }
    if (ruleVersion.present) {
      map['rule_version'] = Variable<int>(ruleVersion.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PredictionResultsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('predictionId: $predictionId, ')
          ..write('status: $status, ')
          ..write('actualClose: $actualClose, ')
          ..write('changePct: $changePct, ')
          ..write('mfe: $mfe, ')
          ..write('mae: $mae, ')
          ..write('decidedAt: $decidedAt, ')
          ..write('isManual: $isManual, ')
          ..write('ruleVersion: $ruleVersion, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReviewNotesTable extends ReviewNotes
    with TableInfo<$ReviewNotesTable, ReviewNote> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReviewNotesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _predictionIdMeta = const VerificationMeta(
    'predictionId',
  );
  @override
  late final GeneratedColumn<String> predictionId = GeneratedColumn<String>(
    'prediction_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _entryIdMeta = const VerificationMeta(
    'entryId',
  );
  @override
  late final GeneratedColumn<String> entryId = GeneratedColumn<String>(
    'entry_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String> reasons =
      GeneratedColumn<String>(
        'reasons',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('[]'),
      ).withConverter<List<String>>($ReviewNotesTable.$converterreasons);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    deviceId,
    predictionId,
    entryId,
    content,
    reasons,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'review_notes';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReviewNote> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('prediction_id')) {
      context.handle(
        _predictionIdMeta,
        predictionId.isAcceptableOrUnknown(
          data['prediction_id']!,
          _predictionIdMeta,
        ),
      );
    }
    if (data.containsKey('entry_id')) {
      context.handle(
        _entryIdMeta,
        entryId.isAcceptableOrUnknown(data['entry_id']!, _entryIdMeta),
      );
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReviewNote map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReviewNote(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      predictionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}prediction_id'],
      ),
      entryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entry_id'],
      ),
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      reasons: $ReviewNotesTable.$converterreasons.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}reasons'],
        )!,
      ),
    );
  }

  @override
  $ReviewNotesTable createAlias(String alias) {
    return $ReviewNotesTable(attachedDatabase, alias);
  }

  static TypeConverter<List<String>, String> $converterreasons =
      const StringListConverter();
}

class ReviewNote extends DataClass implements Insertable<ReviewNote> {
  final String id;
  final int createdAt;
  final int updatedAt;
  final int? deletedAt;
  final String deviceId;
  final String? predictionId;
  final String? entryId;
  final String content;
  final List<String> reasons;
  const ReviewNote({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.deviceId,
    this.predictionId,
    this.entryId,
    required this.content,
    required this.reasons,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['device_id'] = Variable<String>(deviceId);
    if (!nullToAbsent || predictionId != null) {
      map['prediction_id'] = Variable<String>(predictionId);
    }
    if (!nullToAbsent || entryId != null) {
      map['entry_id'] = Variable<String>(entryId);
    }
    map['content'] = Variable<String>(content);
    {
      map['reasons'] = Variable<String>(
        $ReviewNotesTable.$converterreasons.toSql(reasons),
      );
    }
    return map;
  }

  ReviewNotesCompanion toCompanion(bool nullToAbsent) {
    return ReviewNotesCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      deviceId: Value(deviceId),
      predictionId: predictionId == null && nullToAbsent
          ? const Value.absent()
          : Value(predictionId),
      entryId: entryId == null && nullToAbsent
          ? const Value.absent()
          : Value(entryId),
      content: Value(content),
      reasons: Value(reasons),
    );
  }

  factory ReviewNote.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReviewNote(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      predictionId: serializer.fromJson<String?>(json['predictionId']),
      entryId: serializer.fromJson<String?>(json['entryId']),
      content: serializer.fromJson<String>(json['content']),
      reasons: serializer.fromJson<List<String>>(json['reasons']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'deviceId': serializer.toJson<String>(deviceId),
      'predictionId': serializer.toJson<String?>(predictionId),
      'entryId': serializer.toJson<String?>(entryId),
      'content': serializer.toJson<String>(content),
      'reasons': serializer.toJson<List<String>>(reasons),
    };
  }

  ReviewNote copyWith({
    String? id,
    int? createdAt,
    int? updatedAt,
    Value<int?> deletedAt = const Value.absent(),
    String? deviceId,
    Value<String?> predictionId = const Value.absent(),
    Value<String?> entryId = const Value.absent(),
    String? content,
    List<String>? reasons,
  }) => ReviewNote(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    deviceId: deviceId ?? this.deviceId,
    predictionId: predictionId.present ? predictionId.value : this.predictionId,
    entryId: entryId.present ? entryId.value : this.entryId,
    content: content ?? this.content,
    reasons: reasons ?? this.reasons,
  );
  ReviewNote copyWithCompanion(ReviewNotesCompanion data) {
    return ReviewNote(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      predictionId: data.predictionId.present
          ? data.predictionId.value
          : this.predictionId,
      entryId: data.entryId.present ? data.entryId.value : this.entryId,
      content: data.content.present ? data.content.value : this.content,
      reasons: data.reasons.present ? data.reasons.value : this.reasons,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReviewNote(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('predictionId: $predictionId, ')
          ..write('entryId: $entryId, ')
          ..write('content: $content, ')
          ..write('reasons: $reasons')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    deviceId,
    predictionId,
    entryId,
    content,
    reasons,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReviewNote &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.deviceId == this.deviceId &&
          other.predictionId == this.predictionId &&
          other.entryId == this.entryId &&
          other.content == this.content &&
          other.reasons == this.reasons);
}

class ReviewNotesCompanion extends UpdateCompanion<ReviewNote> {
  final Value<String> id;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<String> deviceId;
  final Value<String?> predictionId;
  final Value<String?> entryId;
  final Value<String> content;
  final Value<List<String>> reasons;
  final Value<int> rowid;
  const ReviewNotesCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.predictionId = const Value.absent(),
    this.entryId = const Value.absent(),
    this.content = const Value.absent(),
    this.reasons = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReviewNotesCompanion.insert({
    required String id,
    required int createdAt,
    required int updatedAt,
    this.deletedAt = const Value.absent(),
    required String deviceId,
    this.predictionId = const Value.absent(),
    this.entryId = const Value.absent(),
    required String content,
    this.reasons = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       deviceId = Value(deviceId),
       content = Value(content);
  static Insertable<ReviewNote> custom({
    Expression<String>? id,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<String>? deviceId,
    Expression<String>? predictionId,
    Expression<String>? entryId,
    Expression<String>? content,
    Expression<String>? reasons,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (deviceId != null) 'device_id': deviceId,
      if (predictionId != null) 'prediction_id': predictionId,
      if (entryId != null) 'entry_id': entryId,
      if (content != null) 'content': content,
      if (reasons != null) 'reasons': reasons,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReviewNotesCompanion copyWith({
    Value<String>? id,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int?>? deletedAt,
    Value<String>? deviceId,
    Value<String?>? predictionId,
    Value<String?>? entryId,
    Value<String>? content,
    Value<List<String>>? reasons,
    Value<int>? rowid,
  }) {
    return ReviewNotesCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      deviceId: deviceId ?? this.deviceId,
      predictionId: predictionId ?? this.predictionId,
      entryId: entryId ?? this.entryId,
      content: content ?? this.content,
      reasons: reasons ?? this.reasons,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (predictionId.present) {
      map['prediction_id'] = Variable<String>(predictionId.value);
    }
    if (entryId.present) {
      map['entry_id'] = Variable<String>(entryId.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (reasons.present) {
      map['reasons'] = Variable<String>(
        $ReviewNotesTable.$converterreasons.toSql(reasons.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReviewNotesCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('predictionId: $predictionId, ')
          ..write('entryId: $entryId, ')
          ..write('content: $content, ')
          ..write('reasons: $reasons, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ThresholdRulesTable extends ThresholdRules
    with TableInfo<$ThresholdRulesTable, ThresholdRule> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ThresholdRulesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scopeMeta = const VerificationMeta('scope');
  @override
  late final GeneratedColumn<String> scope = GeneratedColumn<String>(
    'scope',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _instrumentTypeMeta = const VerificationMeta(
    'instrumentType',
  );
  @override
  late final GeneratedColumn<String> instrumentType = GeneratedColumn<String>(
    'instrument_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _horizonTypeMeta = const VerificationMeta(
    'horizonType',
  );
  @override
  late final GeneratedColumn<String> horizonType = GeneratedColumn<String>(
    'horizon_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pctMeta = const VerificationMeta('pct');
  @override
  late final GeneratedColumn<double> pct = GeneratedColumn<double>(
    'pct',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    deviceId,
    scope,
    instrumentType,
    horizonType,
    pct,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'threshold_rules';
  @override
  VerificationContext validateIntegrity(
    Insertable<ThresholdRule> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('scope')) {
      context.handle(
        _scopeMeta,
        scope.isAcceptableOrUnknown(data['scope']!, _scopeMeta),
      );
    } else if (isInserting) {
      context.missing(_scopeMeta);
    }
    if (data.containsKey('instrument_type')) {
      context.handle(
        _instrumentTypeMeta,
        instrumentType.isAcceptableOrUnknown(
          data['instrument_type']!,
          _instrumentTypeMeta,
        ),
      );
    }
    if (data.containsKey('horizon_type')) {
      context.handle(
        _horizonTypeMeta,
        horizonType.isAcceptableOrUnknown(
          data['horizon_type']!,
          _horizonTypeMeta,
        ),
      );
    }
    if (data.containsKey('pct')) {
      context.handle(
        _pctMeta,
        pct.isAcceptableOrUnknown(data['pct']!, _pctMeta),
      );
    } else if (isInserting) {
      context.missing(_pctMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ThresholdRule map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ThresholdRule(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      scope: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scope'],
      )!,
      instrumentType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}instrument_type'],
      ),
      horizonType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}horizon_type'],
      ),
      pct: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}pct'],
      )!,
    );
  }

  @override
  $ThresholdRulesTable createAlias(String alias) {
    return $ThresholdRulesTable(attachedDatabase, alias);
  }
}

class ThresholdRule extends DataClass implements Insertable<ThresholdRule> {
  final String id;
  final int createdAt;
  final int updatedAt;
  final int? deletedAt;
  final String deviceId;

  /// global | type | horizon
  final String scope;
  final String? instrumentType;
  final String? horizonType;
  final double pct;
  const ThresholdRule({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.deviceId,
    required this.scope,
    this.instrumentType,
    this.horizonType,
    required this.pct,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['device_id'] = Variable<String>(deviceId);
    map['scope'] = Variable<String>(scope);
    if (!nullToAbsent || instrumentType != null) {
      map['instrument_type'] = Variable<String>(instrumentType);
    }
    if (!nullToAbsent || horizonType != null) {
      map['horizon_type'] = Variable<String>(horizonType);
    }
    map['pct'] = Variable<double>(pct);
    return map;
  }

  ThresholdRulesCompanion toCompanion(bool nullToAbsent) {
    return ThresholdRulesCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      deviceId: Value(deviceId),
      scope: Value(scope),
      instrumentType: instrumentType == null && nullToAbsent
          ? const Value.absent()
          : Value(instrumentType),
      horizonType: horizonType == null && nullToAbsent
          ? const Value.absent()
          : Value(horizonType),
      pct: Value(pct),
    );
  }

  factory ThresholdRule.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ThresholdRule(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      scope: serializer.fromJson<String>(json['scope']),
      instrumentType: serializer.fromJson<String?>(json['instrumentType']),
      horizonType: serializer.fromJson<String?>(json['horizonType']),
      pct: serializer.fromJson<double>(json['pct']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'deviceId': serializer.toJson<String>(deviceId),
      'scope': serializer.toJson<String>(scope),
      'instrumentType': serializer.toJson<String?>(instrumentType),
      'horizonType': serializer.toJson<String?>(horizonType),
      'pct': serializer.toJson<double>(pct),
    };
  }

  ThresholdRule copyWith({
    String? id,
    int? createdAt,
    int? updatedAt,
    Value<int?> deletedAt = const Value.absent(),
    String? deviceId,
    String? scope,
    Value<String?> instrumentType = const Value.absent(),
    Value<String?> horizonType = const Value.absent(),
    double? pct,
  }) => ThresholdRule(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    deviceId: deviceId ?? this.deviceId,
    scope: scope ?? this.scope,
    instrumentType: instrumentType.present
        ? instrumentType.value
        : this.instrumentType,
    horizonType: horizonType.present ? horizonType.value : this.horizonType,
    pct: pct ?? this.pct,
  );
  ThresholdRule copyWithCompanion(ThresholdRulesCompanion data) {
    return ThresholdRule(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      scope: data.scope.present ? data.scope.value : this.scope,
      instrumentType: data.instrumentType.present
          ? data.instrumentType.value
          : this.instrumentType,
      horizonType: data.horizonType.present
          ? data.horizonType.value
          : this.horizonType,
      pct: data.pct.present ? data.pct.value : this.pct,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ThresholdRule(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('scope: $scope, ')
          ..write('instrumentType: $instrumentType, ')
          ..write('horizonType: $horizonType, ')
          ..write('pct: $pct')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    deviceId,
    scope,
    instrumentType,
    horizonType,
    pct,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ThresholdRule &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.deviceId == this.deviceId &&
          other.scope == this.scope &&
          other.instrumentType == this.instrumentType &&
          other.horizonType == this.horizonType &&
          other.pct == this.pct);
}

class ThresholdRulesCompanion extends UpdateCompanion<ThresholdRule> {
  final Value<String> id;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<String> deviceId;
  final Value<String> scope;
  final Value<String?> instrumentType;
  final Value<String?> horizonType;
  final Value<double> pct;
  final Value<int> rowid;
  const ThresholdRulesCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.scope = const Value.absent(),
    this.instrumentType = const Value.absent(),
    this.horizonType = const Value.absent(),
    this.pct = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ThresholdRulesCompanion.insert({
    required String id,
    required int createdAt,
    required int updatedAt,
    this.deletedAt = const Value.absent(),
    required String deviceId,
    required String scope,
    this.instrumentType = const Value.absent(),
    this.horizonType = const Value.absent(),
    required double pct,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       deviceId = Value(deviceId),
       scope = Value(scope),
       pct = Value(pct);
  static Insertable<ThresholdRule> custom({
    Expression<String>? id,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<String>? deviceId,
    Expression<String>? scope,
    Expression<String>? instrumentType,
    Expression<String>? horizonType,
    Expression<double>? pct,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (deviceId != null) 'device_id': deviceId,
      if (scope != null) 'scope': scope,
      if (instrumentType != null) 'instrument_type': instrumentType,
      if (horizonType != null) 'horizon_type': horizonType,
      if (pct != null) 'pct': pct,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ThresholdRulesCompanion copyWith({
    Value<String>? id,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int?>? deletedAt,
    Value<String>? deviceId,
    Value<String>? scope,
    Value<String?>? instrumentType,
    Value<String?>? horizonType,
    Value<double>? pct,
    Value<int>? rowid,
  }) {
    return ThresholdRulesCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      deviceId: deviceId ?? this.deviceId,
      scope: scope ?? this.scope,
      instrumentType: instrumentType ?? this.instrumentType,
      horizonType: horizonType ?? this.horizonType,
      pct: pct ?? this.pct,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (scope.present) {
      map['scope'] = Variable<String>(scope.value);
    }
    if (instrumentType.present) {
      map['instrument_type'] = Variable<String>(instrumentType.value);
    }
    if (horizonType.present) {
      map['horizon_type'] = Variable<String>(horizonType.value);
    }
    if (pct.present) {
      map['pct'] = Variable<double>(pct.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ThresholdRulesCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('scope: $scope, ')
          ..write('instrumentType: $instrumentType, ')
          ..write('horizonType: $horizonType, ')
          ..write('pct: $pct, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RevisionsTable extends Revisions
    with TableInfo<$RevisionsTable, Revision> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RevisionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityTypeMeta = const VerificationMeta(
    'entityType',
  );
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
    'entity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _revisionNoMeta = const VerificationMeta(
    'revisionNo',
  );
  @override
  late final GeneratedColumn<int> revisionNo = GeneratedColumn<int>(
    'revision_no',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Map<String, dynamic>, String>
  before = GeneratedColumn<String>(
    'before',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<Map<String, dynamic>>($RevisionsTable.$converterbefore);
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String>
  changedFields = GeneratedColumn<String>(
    'changed_fields',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<List<String>>($RevisionsTable.$converterchangedFields);
  static const VerificationMeta _tsMeta = const VerificationMeta('ts');
  @override
  late final GeneratedColumn<int> ts = GeneratedColumn<int>(
    'ts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    deviceId,
    entityType,
    entityId,
    revisionNo,
    before,
    changedFields,
    ts,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'revisions';
  @override
  VerificationContext validateIntegrity(
    Insertable<Revision> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('entity_type')) {
      context.handle(
        _entityTypeMeta,
        entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('revision_no')) {
      context.handle(
        _revisionNoMeta,
        revisionNo.isAcceptableOrUnknown(data['revision_no']!, _revisionNoMeta),
      );
    } else if (isInserting) {
      context.missing(_revisionNoMeta);
    }
    if (data.containsKey('ts')) {
      context.handle(_tsMeta, ts.isAcceptableOrUnknown(data['ts']!, _tsMeta));
    } else if (isInserting) {
      context.missing(_tsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Revision map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Revision(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      entityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_type'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      revisionNo: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revision_no'],
      )!,
      before: $RevisionsTable.$converterbefore.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}before'],
        )!,
      ),
      changedFields: $RevisionsTable.$converterchangedFields.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}changed_fields'],
        )!,
      ),
      ts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ts'],
      )!,
    );
  }

  @override
  $RevisionsTable createAlias(String alias) {
    return $RevisionsTable(attachedDatabase, alias);
  }

  static TypeConverter<Map<String, dynamic>, String> $converterbefore =
      const JsonMapConverter();
  static TypeConverter<List<String>, String> $converterchangedFields =
      const StringListConverter();
}

class Revision extends DataClass implements Insertable<Revision> {
  final String id;
  final int createdAt;
  final int updatedAt;
  final int? deletedAt;
  final String deviceId;

  /// journal_entry | prediction | trade | position_snapshot
  final String entityType;
  final String entityId;
  final int revisionNo;

  /// 修改前的完整记录
  final Map<String, dynamic> before;
  final List<String> changedFields;
  final int ts;
  const Revision({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.deviceId,
    required this.entityType,
    required this.entityId,
    required this.revisionNo,
    required this.before,
    required this.changedFields,
    required this.ts,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['device_id'] = Variable<String>(deviceId);
    map['entity_type'] = Variable<String>(entityType);
    map['entity_id'] = Variable<String>(entityId);
    map['revision_no'] = Variable<int>(revisionNo);
    {
      map['before'] = Variable<String>(
        $RevisionsTable.$converterbefore.toSql(before),
      );
    }
    {
      map['changed_fields'] = Variable<String>(
        $RevisionsTable.$converterchangedFields.toSql(changedFields),
      );
    }
    map['ts'] = Variable<int>(ts);
    return map;
  }

  RevisionsCompanion toCompanion(bool nullToAbsent) {
    return RevisionsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      deviceId: Value(deviceId),
      entityType: Value(entityType),
      entityId: Value(entityId),
      revisionNo: Value(revisionNo),
      before: Value(before),
      changedFields: Value(changedFields),
      ts: Value(ts),
    );
  }

  factory Revision.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Revision(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      entityType: serializer.fromJson<String>(json['entityType']),
      entityId: serializer.fromJson<String>(json['entityId']),
      revisionNo: serializer.fromJson<int>(json['revisionNo']),
      before: serializer.fromJson<Map<String, dynamic>>(json['before']),
      changedFields: serializer.fromJson<List<String>>(json['changedFields']),
      ts: serializer.fromJson<int>(json['ts']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'deviceId': serializer.toJson<String>(deviceId),
      'entityType': serializer.toJson<String>(entityType),
      'entityId': serializer.toJson<String>(entityId),
      'revisionNo': serializer.toJson<int>(revisionNo),
      'before': serializer.toJson<Map<String, dynamic>>(before),
      'changedFields': serializer.toJson<List<String>>(changedFields),
      'ts': serializer.toJson<int>(ts),
    };
  }

  Revision copyWith({
    String? id,
    int? createdAt,
    int? updatedAt,
    Value<int?> deletedAt = const Value.absent(),
    String? deviceId,
    String? entityType,
    String? entityId,
    int? revisionNo,
    Map<String, dynamic>? before,
    List<String>? changedFields,
    int? ts,
  }) => Revision(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    deviceId: deviceId ?? this.deviceId,
    entityType: entityType ?? this.entityType,
    entityId: entityId ?? this.entityId,
    revisionNo: revisionNo ?? this.revisionNo,
    before: before ?? this.before,
    changedFields: changedFields ?? this.changedFields,
    ts: ts ?? this.ts,
  );
  Revision copyWithCompanion(RevisionsCompanion data) {
    return Revision(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      revisionNo: data.revisionNo.present
          ? data.revisionNo.value
          : this.revisionNo,
      before: data.before.present ? data.before.value : this.before,
      changedFields: data.changedFields.present
          ? data.changedFields.value
          : this.changedFields,
      ts: data.ts.present ? data.ts.value : this.ts,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Revision(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('revisionNo: $revisionNo, ')
          ..write('before: $before, ')
          ..write('changedFields: $changedFields, ')
          ..write('ts: $ts')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    deviceId,
    entityType,
    entityId,
    revisionNo,
    before,
    changedFields,
    ts,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Revision &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.deviceId == this.deviceId &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.revisionNo == this.revisionNo &&
          other.before == this.before &&
          other.changedFields == this.changedFields &&
          other.ts == this.ts);
}

class RevisionsCompanion extends UpdateCompanion<Revision> {
  final Value<String> id;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<String> deviceId;
  final Value<String> entityType;
  final Value<String> entityId;
  final Value<int> revisionNo;
  final Value<Map<String, dynamic>> before;
  final Value<List<String>> changedFields;
  final Value<int> ts;
  final Value<int> rowid;
  const RevisionsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.revisionNo = const Value.absent(),
    this.before = const Value.absent(),
    this.changedFields = const Value.absent(),
    this.ts = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RevisionsCompanion.insert({
    required String id,
    required int createdAt,
    required int updatedAt,
    this.deletedAt = const Value.absent(),
    required String deviceId,
    required String entityType,
    required String entityId,
    required int revisionNo,
    required Map<String, dynamic> before,
    required List<String> changedFields,
    required int ts,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       deviceId = Value(deviceId),
       entityType = Value(entityType),
       entityId = Value(entityId),
       revisionNo = Value(revisionNo),
       before = Value(before),
       changedFields = Value(changedFields),
       ts = Value(ts);
  static Insertable<Revision> custom({
    Expression<String>? id,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<String>? deviceId,
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<int>? revisionNo,
    Expression<String>? before,
    Expression<String>? changedFields,
    Expression<int>? ts,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (deviceId != null) 'device_id': deviceId,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (revisionNo != null) 'revision_no': revisionNo,
      if (before != null) 'before': before,
      if (changedFields != null) 'changed_fields': changedFields,
      if (ts != null) 'ts': ts,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RevisionsCompanion copyWith({
    Value<String>? id,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int?>? deletedAt,
    Value<String>? deviceId,
    Value<String>? entityType,
    Value<String>? entityId,
    Value<int>? revisionNo,
    Value<Map<String, dynamic>>? before,
    Value<List<String>>? changedFields,
    Value<int>? ts,
    Value<int>? rowid,
  }) {
    return RevisionsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      deviceId: deviceId ?? this.deviceId,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      revisionNo: revisionNo ?? this.revisionNo,
      before: before ?? this.before,
      changedFields: changedFields ?? this.changedFields,
      ts: ts ?? this.ts,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (revisionNo.present) {
      map['revision_no'] = Variable<int>(revisionNo.value);
    }
    if (before.present) {
      map['before'] = Variable<String>(
        $RevisionsTable.$converterbefore.toSql(before.value),
      );
    }
    if (changedFields.present) {
      map['changed_fields'] = Variable<String>(
        $RevisionsTable.$converterchangedFields.toSql(changedFields.value),
      );
    }
    if (ts.present) {
      map['ts'] = Variable<int>(ts.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RevisionsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('revisionNo: $revisionNo, ')
          ..write('before: $before, ')
          ..write('changedFields: $changedFields, ')
          ..write('ts: $ts, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AiAnalysesTable extends AiAnalyses
    with TableInfo<$AiAnalysesTable, AiAnalysis> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AiAnalysesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tsMeta = const VerificationMeta('ts');
  @override
  late final GeneratedColumn<int> ts = GeneratedColumn<int>(
    'ts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _triggerMeta = const VerificationMeta(
    'trigger',
  );
  @override
  late final GeneratedColumn<String> trigger = GeneratedColumn<String>(
    'trigger',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _providerMeta = const VerificationMeta(
    'provider',
  );
  @override
  late final GeneratedColumn<String> provider = GeneratedColumn<String>(
    'provider',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modelMeta = const VerificationMeta('model');
  @override
  late final GeneratedColumn<String> model = GeneratedColumn<String>(
    'model',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _promptVersionMeta = const VerificationMeta(
    'promptVersion',
  );
  @override
  late final GeneratedColumn<String> promptVersion = GeneratedColumn<String>(
    'prompt_version',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _inputDigestMeta = const VerificationMeta(
    'inputDigest',
  );
  @override
  late final GeneratedColumn<String> inputDigest = GeneratedColumn<String>(
    'input_digest',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Map<String, dynamic>?, String>
  output = GeneratedColumn<String>(
    'output',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  ).withConverter<Map<String, dynamic>?>($AiAnalysesTable.$converteroutputn);
  static const VerificationMeta _rawTextMeta = const VerificationMeta(
    'rawText',
  );
  @override
  late final GeneratedColumn<String> rawText = GeneratedColumn<String>(
    'raw_text',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tokensInMeta = const VerificationMeta(
    'tokensIn',
  );
  @override
  late final GeneratedColumn<int> tokensIn = GeneratedColumn<int>(
    'tokens_in',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tokensOutMeta = const VerificationMeta(
    'tokensOut',
  );
  @override
  late final GeneratedColumn<int> tokensOut = GeneratedColumn<int>(
    'tokens_out',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    deviceId,
    ts,
    trigger,
    provider,
    model,
    promptVersion,
    inputDigest,
    output,
    rawText,
    tokensIn,
    tokensOut,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ai_analyses';
  @override
  VerificationContext validateIntegrity(
    Insertable<AiAnalysis> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('ts')) {
      context.handle(_tsMeta, ts.isAcceptableOrUnknown(data['ts']!, _tsMeta));
    } else if (isInserting) {
      context.missing(_tsMeta);
    }
    if (data.containsKey('trigger')) {
      context.handle(
        _triggerMeta,
        trigger.isAcceptableOrUnknown(data['trigger']!, _triggerMeta),
      );
    } else if (isInserting) {
      context.missing(_triggerMeta);
    }
    if (data.containsKey('provider')) {
      context.handle(
        _providerMeta,
        provider.isAcceptableOrUnknown(data['provider']!, _providerMeta),
      );
    } else if (isInserting) {
      context.missing(_providerMeta);
    }
    if (data.containsKey('model')) {
      context.handle(
        _modelMeta,
        model.isAcceptableOrUnknown(data['model']!, _modelMeta),
      );
    } else if (isInserting) {
      context.missing(_modelMeta);
    }
    if (data.containsKey('prompt_version')) {
      context.handle(
        _promptVersionMeta,
        promptVersion.isAcceptableOrUnknown(
          data['prompt_version']!,
          _promptVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_promptVersionMeta);
    }
    if (data.containsKey('input_digest')) {
      context.handle(
        _inputDigestMeta,
        inputDigest.isAcceptableOrUnknown(
          data['input_digest']!,
          _inputDigestMeta,
        ),
      );
    }
    if (data.containsKey('raw_text')) {
      context.handle(
        _rawTextMeta,
        rawText.isAcceptableOrUnknown(data['raw_text']!, _rawTextMeta),
      );
    }
    if (data.containsKey('tokens_in')) {
      context.handle(
        _tokensInMeta,
        tokensIn.isAcceptableOrUnknown(data['tokens_in']!, _tokensInMeta),
      );
    }
    if (data.containsKey('tokens_out')) {
      context.handle(
        _tokensOutMeta,
        tokensOut.isAcceptableOrUnknown(data['tokens_out']!, _tokensOutMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AiAnalysis map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AiAnalysis(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      ts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ts'],
      )!,
      trigger: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}trigger'],
      )!,
      provider: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider'],
      )!,
      model: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model'],
      )!,
      promptVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}prompt_version'],
      )!,
      inputDigest: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}input_digest'],
      ),
      output: $AiAnalysesTable.$converteroutputn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}output'],
        ),
      ),
      rawText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}raw_text'],
      ),
      tokensIn: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tokens_in'],
      ),
      tokensOut: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tokens_out'],
      ),
    );
  }

  @override
  $AiAnalysesTable createAlias(String alias) {
    return $AiAnalysesTable(attachedDatabase, alias);
  }

  static TypeConverter<Map<String, dynamic>, String> $converteroutput =
      const JsonMapConverter();
  static TypeConverter<Map<String, dynamic>?, String?> $converteroutputn =
      NullAwareTypeConverter.wrap($converteroutput);
}

class AiAnalysis extends DataClass implements Insertable<AiAnalysis> {
  final String id;
  final int createdAt;
  final int updatedAt;
  final int? deletedAt;
  final String deviceId;
  final int ts;

  /// manual | scheduled
  final String trigger;
  final String provider;
  final String model;
  final String promptVersion;
  final String? inputDigest;
  final Map<String, dynamic>? output;
  final String? rawText;
  final int? tokensIn;
  final int? tokensOut;
  const AiAnalysis({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.deviceId,
    required this.ts,
    required this.trigger,
    required this.provider,
    required this.model,
    required this.promptVersion,
    this.inputDigest,
    this.output,
    this.rawText,
    this.tokensIn,
    this.tokensOut,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['device_id'] = Variable<String>(deviceId);
    map['ts'] = Variable<int>(ts);
    map['trigger'] = Variable<String>(trigger);
    map['provider'] = Variable<String>(provider);
    map['model'] = Variable<String>(model);
    map['prompt_version'] = Variable<String>(promptVersion);
    if (!nullToAbsent || inputDigest != null) {
      map['input_digest'] = Variable<String>(inputDigest);
    }
    if (!nullToAbsent || output != null) {
      map['output'] = Variable<String>(
        $AiAnalysesTable.$converteroutputn.toSql(output),
      );
    }
    if (!nullToAbsent || rawText != null) {
      map['raw_text'] = Variable<String>(rawText);
    }
    if (!nullToAbsent || tokensIn != null) {
      map['tokens_in'] = Variable<int>(tokensIn);
    }
    if (!nullToAbsent || tokensOut != null) {
      map['tokens_out'] = Variable<int>(tokensOut);
    }
    return map;
  }

  AiAnalysesCompanion toCompanion(bool nullToAbsent) {
    return AiAnalysesCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      deviceId: Value(deviceId),
      ts: Value(ts),
      trigger: Value(trigger),
      provider: Value(provider),
      model: Value(model),
      promptVersion: Value(promptVersion),
      inputDigest: inputDigest == null && nullToAbsent
          ? const Value.absent()
          : Value(inputDigest),
      output: output == null && nullToAbsent
          ? const Value.absent()
          : Value(output),
      rawText: rawText == null && nullToAbsent
          ? const Value.absent()
          : Value(rawText),
      tokensIn: tokensIn == null && nullToAbsent
          ? const Value.absent()
          : Value(tokensIn),
      tokensOut: tokensOut == null && nullToAbsent
          ? const Value.absent()
          : Value(tokensOut),
    );
  }

  factory AiAnalysis.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AiAnalysis(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      ts: serializer.fromJson<int>(json['ts']),
      trigger: serializer.fromJson<String>(json['trigger']),
      provider: serializer.fromJson<String>(json['provider']),
      model: serializer.fromJson<String>(json['model']),
      promptVersion: serializer.fromJson<String>(json['promptVersion']),
      inputDigest: serializer.fromJson<String?>(json['inputDigest']),
      output: serializer.fromJson<Map<String, dynamic>?>(json['output']),
      rawText: serializer.fromJson<String?>(json['rawText']),
      tokensIn: serializer.fromJson<int?>(json['tokensIn']),
      tokensOut: serializer.fromJson<int?>(json['tokensOut']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'deviceId': serializer.toJson<String>(deviceId),
      'ts': serializer.toJson<int>(ts),
      'trigger': serializer.toJson<String>(trigger),
      'provider': serializer.toJson<String>(provider),
      'model': serializer.toJson<String>(model),
      'promptVersion': serializer.toJson<String>(promptVersion),
      'inputDigest': serializer.toJson<String?>(inputDigest),
      'output': serializer.toJson<Map<String, dynamic>?>(output),
      'rawText': serializer.toJson<String?>(rawText),
      'tokensIn': serializer.toJson<int?>(tokensIn),
      'tokensOut': serializer.toJson<int?>(tokensOut),
    };
  }

  AiAnalysis copyWith({
    String? id,
    int? createdAt,
    int? updatedAt,
    Value<int?> deletedAt = const Value.absent(),
    String? deviceId,
    int? ts,
    String? trigger,
    String? provider,
    String? model,
    String? promptVersion,
    Value<String?> inputDigest = const Value.absent(),
    Value<Map<String, dynamic>?> output = const Value.absent(),
    Value<String?> rawText = const Value.absent(),
    Value<int?> tokensIn = const Value.absent(),
    Value<int?> tokensOut = const Value.absent(),
  }) => AiAnalysis(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    deviceId: deviceId ?? this.deviceId,
    ts: ts ?? this.ts,
    trigger: trigger ?? this.trigger,
    provider: provider ?? this.provider,
    model: model ?? this.model,
    promptVersion: promptVersion ?? this.promptVersion,
    inputDigest: inputDigest.present ? inputDigest.value : this.inputDigest,
    output: output.present ? output.value : this.output,
    rawText: rawText.present ? rawText.value : this.rawText,
    tokensIn: tokensIn.present ? tokensIn.value : this.tokensIn,
    tokensOut: tokensOut.present ? tokensOut.value : this.tokensOut,
  );
  AiAnalysis copyWithCompanion(AiAnalysesCompanion data) {
    return AiAnalysis(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      ts: data.ts.present ? data.ts.value : this.ts,
      trigger: data.trigger.present ? data.trigger.value : this.trigger,
      provider: data.provider.present ? data.provider.value : this.provider,
      model: data.model.present ? data.model.value : this.model,
      promptVersion: data.promptVersion.present
          ? data.promptVersion.value
          : this.promptVersion,
      inputDigest: data.inputDigest.present
          ? data.inputDigest.value
          : this.inputDigest,
      output: data.output.present ? data.output.value : this.output,
      rawText: data.rawText.present ? data.rawText.value : this.rawText,
      tokensIn: data.tokensIn.present ? data.tokensIn.value : this.tokensIn,
      tokensOut: data.tokensOut.present ? data.tokensOut.value : this.tokensOut,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AiAnalysis(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('ts: $ts, ')
          ..write('trigger: $trigger, ')
          ..write('provider: $provider, ')
          ..write('model: $model, ')
          ..write('promptVersion: $promptVersion, ')
          ..write('inputDigest: $inputDigest, ')
          ..write('output: $output, ')
          ..write('rawText: $rawText, ')
          ..write('tokensIn: $tokensIn, ')
          ..write('tokensOut: $tokensOut')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    deviceId,
    ts,
    trigger,
    provider,
    model,
    promptVersion,
    inputDigest,
    output,
    rawText,
    tokensIn,
    tokensOut,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AiAnalysis &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.deviceId == this.deviceId &&
          other.ts == this.ts &&
          other.trigger == this.trigger &&
          other.provider == this.provider &&
          other.model == this.model &&
          other.promptVersion == this.promptVersion &&
          other.inputDigest == this.inputDigest &&
          other.output == this.output &&
          other.rawText == this.rawText &&
          other.tokensIn == this.tokensIn &&
          other.tokensOut == this.tokensOut);
}

class AiAnalysesCompanion extends UpdateCompanion<AiAnalysis> {
  final Value<String> id;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<String> deviceId;
  final Value<int> ts;
  final Value<String> trigger;
  final Value<String> provider;
  final Value<String> model;
  final Value<String> promptVersion;
  final Value<String?> inputDigest;
  final Value<Map<String, dynamic>?> output;
  final Value<String?> rawText;
  final Value<int?> tokensIn;
  final Value<int?> tokensOut;
  final Value<int> rowid;
  const AiAnalysesCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.ts = const Value.absent(),
    this.trigger = const Value.absent(),
    this.provider = const Value.absent(),
    this.model = const Value.absent(),
    this.promptVersion = const Value.absent(),
    this.inputDigest = const Value.absent(),
    this.output = const Value.absent(),
    this.rawText = const Value.absent(),
    this.tokensIn = const Value.absent(),
    this.tokensOut = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AiAnalysesCompanion.insert({
    required String id,
    required int createdAt,
    required int updatedAt,
    this.deletedAt = const Value.absent(),
    required String deviceId,
    required int ts,
    required String trigger,
    required String provider,
    required String model,
    required String promptVersion,
    this.inputDigest = const Value.absent(),
    this.output = const Value.absent(),
    this.rawText = const Value.absent(),
    this.tokensIn = const Value.absent(),
    this.tokensOut = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       deviceId = Value(deviceId),
       ts = Value(ts),
       trigger = Value(trigger),
       provider = Value(provider),
       model = Value(model),
       promptVersion = Value(promptVersion);
  static Insertable<AiAnalysis> custom({
    Expression<String>? id,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<String>? deviceId,
    Expression<int>? ts,
    Expression<String>? trigger,
    Expression<String>? provider,
    Expression<String>? model,
    Expression<String>? promptVersion,
    Expression<String>? inputDigest,
    Expression<String>? output,
    Expression<String>? rawText,
    Expression<int>? tokensIn,
    Expression<int>? tokensOut,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (deviceId != null) 'device_id': deviceId,
      if (ts != null) 'ts': ts,
      if (trigger != null) 'trigger': trigger,
      if (provider != null) 'provider': provider,
      if (model != null) 'model': model,
      if (promptVersion != null) 'prompt_version': promptVersion,
      if (inputDigest != null) 'input_digest': inputDigest,
      if (output != null) 'output': output,
      if (rawText != null) 'raw_text': rawText,
      if (tokensIn != null) 'tokens_in': tokensIn,
      if (tokensOut != null) 'tokens_out': tokensOut,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AiAnalysesCompanion copyWith({
    Value<String>? id,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int?>? deletedAt,
    Value<String>? deviceId,
    Value<int>? ts,
    Value<String>? trigger,
    Value<String>? provider,
    Value<String>? model,
    Value<String>? promptVersion,
    Value<String?>? inputDigest,
    Value<Map<String, dynamic>?>? output,
    Value<String?>? rawText,
    Value<int?>? tokensIn,
    Value<int?>? tokensOut,
    Value<int>? rowid,
  }) {
    return AiAnalysesCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      deviceId: deviceId ?? this.deviceId,
      ts: ts ?? this.ts,
      trigger: trigger ?? this.trigger,
      provider: provider ?? this.provider,
      model: model ?? this.model,
      promptVersion: promptVersion ?? this.promptVersion,
      inputDigest: inputDigest ?? this.inputDigest,
      output: output ?? this.output,
      rawText: rawText ?? this.rawText,
      tokensIn: tokensIn ?? this.tokensIn,
      tokensOut: tokensOut ?? this.tokensOut,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (ts.present) {
      map['ts'] = Variable<int>(ts.value);
    }
    if (trigger.present) {
      map['trigger'] = Variable<String>(trigger.value);
    }
    if (provider.present) {
      map['provider'] = Variable<String>(provider.value);
    }
    if (model.present) {
      map['model'] = Variable<String>(model.value);
    }
    if (promptVersion.present) {
      map['prompt_version'] = Variable<String>(promptVersion.value);
    }
    if (inputDigest.present) {
      map['input_digest'] = Variable<String>(inputDigest.value);
    }
    if (output.present) {
      map['output'] = Variable<String>(
        $AiAnalysesTable.$converteroutputn.toSql(output.value),
      );
    }
    if (rawText.present) {
      map['raw_text'] = Variable<String>(rawText.value);
    }
    if (tokensIn.present) {
      map['tokens_in'] = Variable<int>(tokensIn.value);
    }
    if (tokensOut.present) {
      map['tokens_out'] = Variable<int>(tokensOut.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AiAnalysesCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('ts: $ts, ')
          ..write('trigger: $trigger, ')
          ..write('provider: $provider, ')
          ..write('model: $model, ')
          ..write('promptVersion: $promptVersion, ')
          ..write('inputDigest: $inputDigest, ')
          ..write('output: $output, ')
          ..write('rawText: $rawText, ')
          ..write('tokensIn: $tokensIn, ')
          ..write('tokensOut: $tokensOut, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AccountsTable extends Accounts with TableInfo<$AccountsTable, Account> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AccountsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _brokerMeta = const VerificationMeta('broker');
  @override
  late final GeneratedColumn<String> broker = GeneratedColumn<String>(
    'broker',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _commissionRateMeta = const VerificationMeta(
    'commissionRate',
  );
  @override
  late final GeneratedColumn<double> commissionRate = GeneratedColumn<double>(
    'commission_rate',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.00025),
  );
  static const VerificationMeta _minCommissionMeta = const VerificationMeta(
    'minCommission',
  );
  @override
  late final GeneratedColumn<double> minCommission = GeneratedColumn<double>(
    'min_commission',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(5),
  );
  static const VerificationMeta _stampTaxRateMeta = const VerificationMeta(
    'stampTaxRate',
  );
  @override
  late final GeneratedColumn<double> stampTaxRate = GeneratedColumn<double>(
    'stamp_tax_rate',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0005),
  );
  static const VerificationMeta _transferFeeRateMeta = const VerificationMeta(
    'transferFeeRate',
  );
  @override
  late final GeneratedColumn<double> transferFeeRate = GeneratedColumn<double>(
    'transfer_fee_rate',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.00001),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    deviceId,
    name,
    broker,
    commissionRate,
    minCommission,
    stampTaxRate,
    transferFeeRate,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'accounts';
  @override
  VerificationContext validateIntegrity(
    Insertable<Account> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('broker')) {
      context.handle(
        _brokerMeta,
        broker.isAcceptableOrUnknown(data['broker']!, _brokerMeta),
      );
    }
    if (data.containsKey('commission_rate')) {
      context.handle(
        _commissionRateMeta,
        commissionRate.isAcceptableOrUnknown(
          data['commission_rate']!,
          _commissionRateMeta,
        ),
      );
    }
    if (data.containsKey('min_commission')) {
      context.handle(
        _minCommissionMeta,
        minCommission.isAcceptableOrUnknown(
          data['min_commission']!,
          _minCommissionMeta,
        ),
      );
    }
    if (data.containsKey('stamp_tax_rate')) {
      context.handle(
        _stampTaxRateMeta,
        stampTaxRate.isAcceptableOrUnknown(
          data['stamp_tax_rate']!,
          _stampTaxRateMeta,
        ),
      );
    }
    if (data.containsKey('transfer_fee_rate')) {
      context.handle(
        _transferFeeRateMeta,
        transferFeeRate.isAcceptableOrUnknown(
          data['transfer_fee_rate']!,
          _transferFeeRateMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Account map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Account(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      broker: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}broker'],
      ),
      commissionRate: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}commission_rate'],
      )!,
      minCommission: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}min_commission'],
      )!,
      stampTaxRate: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}stamp_tax_rate'],
      )!,
      transferFeeRate: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}transfer_fee_rate'],
      )!,
    );
  }

  @override
  $AccountsTable createAlias(String alias) {
    return $AccountsTable(attachedDatabase, alias);
  }
}

class Account extends DataClass implements Insertable<Account> {
  final String id;
  final int createdAt;
  final int updatedAt;
  final int? deletedAt;
  final String deviceId;
  final String name;
  final String? broker;
  final double commissionRate;
  final double minCommission;
  final double stampTaxRate;
  final double transferFeeRate;
  const Account({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.deviceId,
    required this.name,
    this.broker,
    required this.commissionRate,
    required this.minCommission,
    required this.stampTaxRate,
    required this.transferFeeRate,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['device_id'] = Variable<String>(deviceId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || broker != null) {
      map['broker'] = Variable<String>(broker);
    }
    map['commission_rate'] = Variable<double>(commissionRate);
    map['min_commission'] = Variable<double>(minCommission);
    map['stamp_tax_rate'] = Variable<double>(stampTaxRate);
    map['transfer_fee_rate'] = Variable<double>(transferFeeRate);
    return map;
  }

  AccountsCompanion toCompanion(bool nullToAbsent) {
    return AccountsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      deviceId: Value(deviceId),
      name: Value(name),
      broker: broker == null && nullToAbsent
          ? const Value.absent()
          : Value(broker),
      commissionRate: Value(commissionRate),
      minCommission: Value(minCommission),
      stampTaxRate: Value(stampTaxRate),
      transferFeeRate: Value(transferFeeRate),
    );
  }

  factory Account.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Account(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      name: serializer.fromJson<String>(json['name']),
      broker: serializer.fromJson<String?>(json['broker']),
      commissionRate: serializer.fromJson<double>(json['commissionRate']),
      minCommission: serializer.fromJson<double>(json['minCommission']),
      stampTaxRate: serializer.fromJson<double>(json['stampTaxRate']),
      transferFeeRate: serializer.fromJson<double>(json['transferFeeRate']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'deviceId': serializer.toJson<String>(deviceId),
      'name': serializer.toJson<String>(name),
      'broker': serializer.toJson<String?>(broker),
      'commissionRate': serializer.toJson<double>(commissionRate),
      'minCommission': serializer.toJson<double>(minCommission),
      'stampTaxRate': serializer.toJson<double>(stampTaxRate),
      'transferFeeRate': serializer.toJson<double>(transferFeeRate),
    };
  }

  Account copyWith({
    String? id,
    int? createdAt,
    int? updatedAt,
    Value<int?> deletedAt = const Value.absent(),
    String? deviceId,
    String? name,
    Value<String?> broker = const Value.absent(),
    double? commissionRate,
    double? minCommission,
    double? stampTaxRate,
    double? transferFeeRate,
  }) => Account(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    deviceId: deviceId ?? this.deviceId,
    name: name ?? this.name,
    broker: broker.present ? broker.value : this.broker,
    commissionRate: commissionRate ?? this.commissionRate,
    minCommission: minCommission ?? this.minCommission,
    stampTaxRate: stampTaxRate ?? this.stampTaxRate,
    transferFeeRate: transferFeeRate ?? this.transferFeeRate,
  );
  Account copyWithCompanion(AccountsCompanion data) {
    return Account(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      name: data.name.present ? data.name.value : this.name,
      broker: data.broker.present ? data.broker.value : this.broker,
      commissionRate: data.commissionRate.present
          ? data.commissionRate.value
          : this.commissionRate,
      minCommission: data.minCommission.present
          ? data.minCommission.value
          : this.minCommission,
      stampTaxRate: data.stampTaxRate.present
          ? data.stampTaxRate.value
          : this.stampTaxRate,
      transferFeeRate: data.transferFeeRate.present
          ? data.transferFeeRate.value
          : this.transferFeeRate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Account(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('name: $name, ')
          ..write('broker: $broker, ')
          ..write('commissionRate: $commissionRate, ')
          ..write('minCommission: $minCommission, ')
          ..write('stampTaxRate: $stampTaxRate, ')
          ..write('transferFeeRate: $transferFeeRate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    deviceId,
    name,
    broker,
    commissionRate,
    minCommission,
    stampTaxRate,
    transferFeeRate,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Account &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.deviceId == this.deviceId &&
          other.name == this.name &&
          other.broker == this.broker &&
          other.commissionRate == this.commissionRate &&
          other.minCommission == this.minCommission &&
          other.stampTaxRate == this.stampTaxRate &&
          other.transferFeeRate == this.transferFeeRate);
}

class AccountsCompanion extends UpdateCompanion<Account> {
  final Value<String> id;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<String> deviceId;
  final Value<String> name;
  final Value<String?> broker;
  final Value<double> commissionRate;
  final Value<double> minCommission;
  final Value<double> stampTaxRate;
  final Value<double> transferFeeRate;
  final Value<int> rowid;
  const AccountsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.name = const Value.absent(),
    this.broker = const Value.absent(),
    this.commissionRate = const Value.absent(),
    this.minCommission = const Value.absent(),
    this.stampTaxRate = const Value.absent(),
    this.transferFeeRate = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AccountsCompanion.insert({
    required String id,
    required int createdAt,
    required int updatedAt,
    this.deletedAt = const Value.absent(),
    required String deviceId,
    required String name,
    this.broker = const Value.absent(),
    this.commissionRate = const Value.absent(),
    this.minCommission = const Value.absent(),
    this.stampTaxRate = const Value.absent(),
    this.transferFeeRate = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       deviceId = Value(deviceId),
       name = Value(name);
  static Insertable<Account> custom({
    Expression<String>? id,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<String>? deviceId,
    Expression<String>? name,
    Expression<String>? broker,
    Expression<double>? commissionRate,
    Expression<double>? minCommission,
    Expression<double>? stampTaxRate,
    Expression<double>? transferFeeRate,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (deviceId != null) 'device_id': deviceId,
      if (name != null) 'name': name,
      if (broker != null) 'broker': broker,
      if (commissionRate != null) 'commission_rate': commissionRate,
      if (minCommission != null) 'min_commission': minCommission,
      if (stampTaxRate != null) 'stamp_tax_rate': stampTaxRate,
      if (transferFeeRate != null) 'transfer_fee_rate': transferFeeRate,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AccountsCompanion copyWith({
    Value<String>? id,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int?>? deletedAt,
    Value<String>? deviceId,
    Value<String>? name,
    Value<String?>? broker,
    Value<double>? commissionRate,
    Value<double>? minCommission,
    Value<double>? stampTaxRate,
    Value<double>? transferFeeRate,
    Value<int>? rowid,
  }) {
    return AccountsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      deviceId: deviceId ?? this.deviceId,
      name: name ?? this.name,
      broker: broker ?? this.broker,
      commissionRate: commissionRate ?? this.commissionRate,
      minCommission: minCommission ?? this.minCommission,
      stampTaxRate: stampTaxRate ?? this.stampTaxRate,
      transferFeeRate: transferFeeRate ?? this.transferFeeRate,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (broker.present) {
      map['broker'] = Variable<String>(broker.value);
    }
    if (commissionRate.present) {
      map['commission_rate'] = Variable<double>(commissionRate.value);
    }
    if (minCommission.present) {
      map['min_commission'] = Variable<double>(minCommission.value);
    }
    if (stampTaxRate.present) {
      map['stamp_tax_rate'] = Variable<double>(stampTaxRate.value);
    }
    if (transferFeeRate.present) {
      map['transfer_fee_rate'] = Variable<double>(transferFeeRate.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AccountsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('name: $name, ')
          ..write('broker: $broker, ')
          ..write('commissionRate: $commissionRate, ')
          ..write('minCommission: $minCommission, ')
          ..write('stampTaxRate: $stampTaxRate, ')
          ..write('transferFeeRate: $transferFeeRate, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TradesTable extends Trades with TableInfo<$TradesTable, Trade> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TradesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
    'account_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _instrumentCodeMeta = const VerificationMeta(
    'instrumentCode',
  );
  @override
  late final GeneratedColumn<String> instrumentCode = GeneratedColumn<String>(
    'instrument_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sideMeta = const VerificationMeta('side');
  @override
  late final GeneratedColumn<String> side = GeneratedColumn<String>(
    'side',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tsMeta = const VerificationMeta('ts');
  @override
  late final GeneratedColumn<int> ts = GeneratedColumn<int>(
    'ts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _priceMeta = const VerificationMeta('price');
  @override
  late final GeneratedColumn<double> price = GeneratedColumn<double>(
    'price',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _qtyMeta = const VerificationMeta('qty');
  @override
  late final GeneratedColumn<int> qty = GeneratedColumn<int>(
    'qty',
    aliasedName,
    false,
    type: DriftSqlType.int,
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
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _stampTaxMeta = const VerificationMeta(
    'stampTax',
  );
  @override
  late final GeneratedColumn<double> stampTax = GeneratedColumn<double>(
    'stamp_tax',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _transferFeeMeta = const VerificationMeta(
    'transferFee',
  );
  @override
  late final GeneratedColumn<double> transferFee = GeneratedColumn<double>(
    'transfer_fee',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _entryIdMeta = const VerificationMeta(
    'entryId',
  );
  @override
  late final GeneratedColumn<String> entryId = GeneratedColumn<String>(
    'entry_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _importBatchIdMeta = const VerificationMeta(
    'importBatchId',
  );
  @override
  late final GeneratedColumn<String> importBatchId = GeneratedColumn<String>(
    'import_batch_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _revisionCountMeta = const VerificationMeta(
    'revisionCount',
  );
  @override
  late final GeneratedColumn<int> revisionCount = GeneratedColumn<int>(
    'revision_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    deviceId,
    accountId,
    instrumentCode,
    side,
    ts,
    price,
    qty,
    amount,
    commission,
    stampTax,
    transferFee,
    entryId,
    source,
    importBatchId,
    note,
    revisionCount,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'trades';
  @override
  VerificationContext validateIntegrity(
    Insertable<Trade> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('instrument_code')) {
      context.handle(
        _instrumentCodeMeta,
        instrumentCode.isAcceptableOrUnknown(
          data['instrument_code']!,
          _instrumentCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_instrumentCodeMeta);
    }
    if (data.containsKey('side')) {
      context.handle(
        _sideMeta,
        side.isAcceptableOrUnknown(data['side']!, _sideMeta),
      );
    } else if (isInserting) {
      context.missing(_sideMeta);
    }
    if (data.containsKey('ts')) {
      context.handle(_tsMeta, ts.isAcceptableOrUnknown(data['ts']!, _tsMeta));
    } else if (isInserting) {
      context.missing(_tsMeta);
    }
    if (data.containsKey('price')) {
      context.handle(
        _priceMeta,
        price.isAcceptableOrUnknown(data['price']!, _priceMeta),
      );
    } else if (isInserting) {
      context.missing(_priceMeta);
    }
    if (data.containsKey('qty')) {
      context.handle(
        _qtyMeta,
        qty.isAcceptableOrUnknown(data['qty']!, _qtyMeta),
      );
    } else if (isInserting) {
      context.missing(_qtyMeta);
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
    if (data.containsKey('stamp_tax')) {
      context.handle(
        _stampTaxMeta,
        stampTax.isAcceptableOrUnknown(data['stamp_tax']!, _stampTaxMeta),
      );
    }
    if (data.containsKey('transfer_fee')) {
      context.handle(
        _transferFeeMeta,
        transferFee.isAcceptableOrUnknown(
          data['transfer_fee']!,
          _transferFeeMeta,
        ),
      );
    }
    if (data.containsKey('entry_id')) {
      context.handle(
        _entryIdMeta,
        entryId.isAcceptableOrUnknown(data['entry_id']!, _entryIdMeta),
      );
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('import_batch_id')) {
      context.handle(
        _importBatchIdMeta,
        importBatchId.isAcceptableOrUnknown(
          data['import_batch_id']!,
          _importBatchIdMeta,
        ),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('revision_count')) {
      context.handle(
        _revisionCountMeta,
        revisionCount.isAcceptableOrUnknown(
          data['revision_count']!,
          _revisionCountMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Trade map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Trade(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_id'],
      )!,
      instrumentCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}instrument_code'],
      )!,
      side: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}side'],
      )!,
      ts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ts'],
      )!,
      price: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}price'],
      )!,
      qty: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}qty'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      commission: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}commission'],
      )!,
      stampTax: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}stamp_tax'],
      )!,
      transferFee: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}transfer_fee'],
      )!,
      entryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entry_id'],
      ),
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      importBatchId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}import_batch_id'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      revisionCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revision_count'],
      )!,
    );
  }

  @override
  $TradesTable createAlias(String alias) {
    return $TradesTable(attachedDatabase, alias);
  }
}

class Trade extends DataClass implements Insertable<Trade> {
  final String id;
  final int createdAt;
  final int updatedAt;
  final int? deletedAt;
  final String deviceId;
  final String accountId;
  final String instrumentCode;

  /// buy | sell | dividend | bonus | subscribe ...
  final String side;
  final int ts;
  final double price;
  final int qty;
  final double amount;
  final double commission;
  final double stampTax;
  final double transferFee;
  final String? entryId;

  /// manual | image | table
  final String source;
  final String? importBatchId;
  final String? note;
  final int revisionCount;
  const Trade({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.deviceId,
    required this.accountId,
    required this.instrumentCode,
    required this.side,
    required this.ts,
    required this.price,
    required this.qty,
    required this.amount,
    required this.commission,
    required this.stampTax,
    required this.transferFee,
    this.entryId,
    required this.source,
    this.importBatchId,
    this.note,
    required this.revisionCount,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['device_id'] = Variable<String>(deviceId);
    map['account_id'] = Variable<String>(accountId);
    map['instrument_code'] = Variable<String>(instrumentCode);
    map['side'] = Variable<String>(side);
    map['ts'] = Variable<int>(ts);
    map['price'] = Variable<double>(price);
    map['qty'] = Variable<int>(qty);
    map['amount'] = Variable<double>(amount);
    map['commission'] = Variable<double>(commission);
    map['stamp_tax'] = Variable<double>(stampTax);
    map['transfer_fee'] = Variable<double>(transferFee);
    if (!nullToAbsent || entryId != null) {
      map['entry_id'] = Variable<String>(entryId);
    }
    map['source'] = Variable<String>(source);
    if (!nullToAbsent || importBatchId != null) {
      map['import_batch_id'] = Variable<String>(importBatchId);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['revision_count'] = Variable<int>(revisionCount);
    return map;
  }

  TradesCompanion toCompanion(bool nullToAbsent) {
    return TradesCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      deviceId: Value(deviceId),
      accountId: Value(accountId),
      instrumentCode: Value(instrumentCode),
      side: Value(side),
      ts: Value(ts),
      price: Value(price),
      qty: Value(qty),
      amount: Value(amount),
      commission: Value(commission),
      stampTax: Value(stampTax),
      transferFee: Value(transferFee),
      entryId: entryId == null && nullToAbsent
          ? const Value.absent()
          : Value(entryId),
      source: Value(source),
      importBatchId: importBatchId == null && nullToAbsent
          ? const Value.absent()
          : Value(importBatchId),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      revisionCount: Value(revisionCount),
    );
  }

  factory Trade.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Trade(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      accountId: serializer.fromJson<String>(json['accountId']),
      instrumentCode: serializer.fromJson<String>(json['instrumentCode']),
      side: serializer.fromJson<String>(json['side']),
      ts: serializer.fromJson<int>(json['ts']),
      price: serializer.fromJson<double>(json['price']),
      qty: serializer.fromJson<int>(json['qty']),
      amount: serializer.fromJson<double>(json['amount']),
      commission: serializer.fromJson<double>(json['commission']),
      stampTax: serializer.fromJson<double>(json['stampTax']),
      transferFee: serializer.fromJson<double>(json['transferFee']),
      entryId: serializer.fromJson<String?>(json['entryId']),
      source: serializer.fromJson<String>(json['source']),
      importBatchId: serializer.fromJson<String?>(json['importBatchId']),
      note: serializer.fromJson<String?>(json['note']),
      revisionCount: serializer.fromJson<int>(json['revisionCount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'deviceId': serializer.toJson<String>(deviceId),
      'accountId': serializer.toJson<String>(accountId),
      'instrumentCode': serializer.toJson<String>(instrumentCode),
      'side': serializer.toJson<String>(side),
      'ts': serializer.toJson<int>(ts),
      'price': serializer.toJson<double>(price),
      'qty': serializer.toJson<int>(qty),
      'amount': serializer.toJson<double>(amount),
      'commission': serializer.toJson<double>(commission),
      'stampTax': serializer.toJson<double>(stampTax),
      'transferFee': serializer.toJson<double>(transferFee),
      'entryId': serializer.toJson<String?>(entryId),
      'source': serializer.toJson<String>(source),
      'importBatchId': serializer.toJson<String?>(importBatchId),
      'note': serializer.toJson<String?>(note),
      'revisionCount': serializer.toJson<int>(revisionCount),
    };
  }

  Trade copyWith({
    String? id,
    int? createdAt,
    int? updatedAt,
    Value<int?> deletedAt = const Value.absent(),
    String? deviceId,
    String? accountId,
    String? instrumentCode,
    String? side,
    int? ts,
    double? price,
    int? qty,
    double? amount,
    double? commission,
    double? stampTax,
    double? transferFee,
    Value<String?> entryId = const Value.absent(),
    String? source,
    Value<String?> importBatchId = const Value.absent(),
    Value<String?> note = const Value.absent(),
    int? revisionCount,
  }) => Trade(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    deviceId: deviceId ?? this.deviceId,
    accountId: accountId ?? this.accountId,
    instrumentCode: instrumentCode ?? this.instrumentCode,
    side: side ?? this.side,
    ts: ts ?? this.ts,
    price: price ?? this.price,
    qty: qty ?? this.qty,
    amount: amount ?? this.amount,
    commission: commission ?? this.commission,
    stampTax: stampTax ?? this.stampTax,
    transferFee: transferFee ?? this.transferFee,
    entryId: entryId.present ? entryId.value : this.entryId,
    source: source ?? this.source,
    importBatchId: importBatchId.present
        ? importBatchId.value
        : this.importBatchId,
    note: note.present ? note.value : this.note,
    revisionCount: revisionCount ?? this.revisionCount,
  );
  Trade copyWithCompanion(TradesCompanion data) {
    return Trade(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      instrumentCode: data.instrumentCode.present
          ? data.instrumentCode.value
          : this.instrumentCode,
      side: data.side.present ? data.side.value : this.side,
      ts: data.ts.present ? data.ts.value : this.ts,
      price: data.price.present ? data.price.value : this.price,
      qty: data.qty.present ? data.qty.value : this.qty,
      amount: data.amount.present ? data.amount.value : this.amount,
      commission: data.commission.present
          ? data.commission.value
          : this.commission,
      stampTax: data.stampTax.present ? data.stampTax.value : this.stampTax,
      transferFee: data.transferFee.present
          ? data.transferFee.value
          : this.transferFee,
      entryId: data.entryId.present ? data.entryId.value : this.entryId,
      source: data.source.present ? data.source.value : this.source,
      importBatchId: data.importBatchId.present
          ? data.importBatchId.value
          : this.importBatchId,
      note: data.note.present ? data.note.value : this.note,
      revisionCount: data.revisionCount.present
          ? data.revisionCount.value
          : this.revisionCount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Trade(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('accountId: $accountId, ')
          ..write('instrumentCode: $instrumentCode, ')
          ..write('side: $side, ')
          ..write('ts: $ts, ')
          ..write('price: $price, ')
          ..write('qty: $qty, ')
          ..write('amount: $amount, ')
          ..write('commission: $commission, ')
          ..write('stampTax: $stampTax, ')
          ..write('transferFee: $transferFee, ')
          ..write('entryId: $entryId, ')
          ..write('source: $source, ')
          ..write('importBatchId: $importBatchId, ')
          ..write('note: $note, ')
          ..write('revisionCount: $revisionCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    deviceId,
    accountId,
    instrumentCode,
    side,
    ts,
    price,
    qty,
    amount,
    commission,
    stampTax,
    transferFee,
    entryId,
    source,
    importBatchId,
    note,
    revisionCount,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Trade &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.deviceId == this.deviceId &&
          other.accountId == this.accountId &&
          other.instrumentCode == this.instrumentCode &&
          other.side == this.side &&
          other.ts == this.ts &&
          other.price == this.price &&
          other.qty == this.qty &&
          other.amount == this.amount &&
          other.commission == this.commission &&
          other.stampTax == this.stampTax &&
          other.transferFee == this.transferFee &&
          other.entryId == this.entryId &&
          other.source == this.source &&
          other.importBatchId == this.importBatchId &&
          other.note == this.note &&
          other.revisionCount == this.revisionCount);
}

class TradesCompanion extends UpdateCompanion<Trade> {
  final Value<String> id;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<String> deviceId;
  final Value<String> accountId;
  final Value<String> instrumentCode;
  final Value<String> side;
  final Value<int> ts;
  final Value<double> price;
  final Value<int> qty;
  final Value<double> amount;
  final Value<double> commission;
  final Value<double> stampTax;
  final Value<double> transferFee;
  final Value<String?> entryId;
  final Value<String> source;
  final Value<String?> importBatchId;
  final Value<String?> note;
  final Value<int> revisionCount;
  final Value<int> rowid;
  const TradesCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.accountId = const Value.absent(),
    this.instrumentCode = const Value.absent(),
    this.side = const Value.absent(),
    this.ts = const Value.absent(),
    this.price = const Value.absent(),
    this.qty = const Value.absent(),
    this.amount = const Value.absent(),
    this.commission = const Value.absent(),
    this.stampTax = const Value.absent(),
    this.transferFee = const Value.absent(),
    this.entryId = const Value.absent(),
    this.source = const Value.absent(),
    this.importBatchId = const Value.absent(),
    this.note = const Value.absent(),
    this.revisionCount = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TradesCompanion.insert({
    required String id,
    required int createdAt,
    required int updatedAt,
    this.deletedAt = const Value.absent(),
    required String deviceId,
    required String accountId,
    required String instrumentCode,
    required String side,
    required int ts,
    required double price,
    required int qty,
    required double amount,
    this.commission = const Value.absent(),
    this.stampTax = const Value.absent(),
    this.transferFee = const Value.absent(),
    this.entryId = const Value.absent(),
    required String source,
    this.importBatchId = const Value.absent(),
    this.note = const Value.absent(),
    this.revisionCount = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       deviceId = Value(deviceId),
       accountId = Value(accountId),
       instrumentCode = Value(instrumentCode),
       side = Value(side),
       ts = Value(ts),
       price = Value(price),
       qty = Value(qty),
       amount = Value(amount),
       source = Value(source);
  static Insertable<Trade> custom({
    Expression<String>? id,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<String>? deviceId,
    Expression<String>? accountId,
    Expression<String>? instrumentCode,
    Expression<String>? side,
    Expression<int>? ts,
    Expression<double>? price,
    Expression<int>? qty,
    Expression<double>? amount,
    Expression<double>? commission,
    Expression<double>? stampTax,
    Expression<double>? transferFee,
    Expression<String>? entryId,
    Expression<String>? source,
    Expression<String>? importBatchId,
    Expression<String>? note,
    Expression<int>? revisionCount,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (deviceId != null) 'device_id': deviceId,
      if (accountId != null) 'account_id': accountId,
      if (instrumentCode != null) 'instrument_code': instrumentCode,
      if (side != null) 'side': side,
      if (ts != null) 'ts': ts,
      if (price != null) 'price': price,
      if (qty != null) 'qty': qty,
      if (amount != null) 'amount': amount,
      if (commission != null) 'commission': commission,
      if (stampTax != null) 'stamp_tax': stampTax,
      if (transferFee != null) 'transfer_fee': transferFee,
      if (entryId != null) 'entry_id': entryId,
      if (source != null) 'source': source,
      if (importBatchId != null) 'import_batch_id': importBatchId,
      if (note != null) 'note': note,
      if (revisionCount != null) 'revision_count': revisionCount,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TradesCompanion copyWith({
    Value<String>? id,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int?>? deletedAt,
    Value<String>? deviceId,
    Value<String>? accountId,
    Value<String>? instrumentCode,
    Value<String>? side,
    Value<int>? ts,
    Value<double>? price,
    Value<int>? qty,
    Value<double>? amount,
    Value<double>? commission,
    Value<double>? stampTax,
    Value<double>? transferFee,
    Value<String?>? entryId,
    Value<String>? source,
    Value<String?>? importBatchId,
    Value<String?>? note,
    Value<int>? revisionCount,
    Value<int>? rowid,
  }) {
    return TradesCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      deviceId: deviceId ?? this.deviceId,
      accountId: accountId ?? this.accountId,
      instrumentCode: instrumentCode ?? this.instrumentCode,
      side: side ?? this.side,
      ts: ts ?? this.ts,
      price: price ?? this.price,
      qty: qty ?? this.qty,
      amount: amount ?? this.amount,
      commission: commission ?? this.commission,
      stampTax: stampTax ?? this.stampTax,
      transferFee: transferFee ?? this.transferFee,
      entryId: entryId ?? this.entryId,
      source: source ?? this.source,
      importBatchId: importBatchId ?? this.importBatchId,
      note: note ?? this.note,
      revisionCount: revisionCount ?? this.revisionCount,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (instrumentCode.present) {
      map['instrument_code'] = Variable<String>(instrumentCode.value);
    }
    if (side.present) {
      map['side'] = Variable<String>(side.value);
    }
    if (ts.present) {
      map['ts'] = Variable<int>(ts.value);
    }
    if (price.present) {
      map['price'] = Variable<double>(price.value);
    }
    if (qty.present) {
      map['qty'] = Variable<int>(qty.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (commission.present) {
      map['commission'] = Variable<double>(commission.value);
    }
    if (stampTax.present) {
      map['stamp_tax'] = Variable<double>(stampTax.value);
    }
    if (transferFee.present) {
      map['transfer_fee'] = Variable<double>(transferFee.value);
    }
    if (entryId.present) {
      map['entry_id'] = Variable<String>(entryId.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (importBatchId.present) {
      map['import_batch_id'] = Variable<String>(importBatchId.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (revisionCount.present) {
      map['revision_count'] = Variable<int>(revisionCount.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TradesCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('accountId: $accountId, ')
          ..write('instrumentCode: $instrumentCode, ')
          ..write('side: $side, ')
          ..write('ts: $ts, ')
          ..write('price: $price, ')
          ..write('qty: $qty, ')
          ..write('amount: $amount, ')
          ..write('commission: $commission, ')
          ..write('stampTax: $stampTax, ')
          ..write('transferFee: $transferFee, ')
          ..write('entryId: $entryId, ')
          ..write('source: $source, ')
          ..write('importBatchId: $importBatchId, ')
          ..write('note: $note, ')
          ..write('revisionCount: $revisionCount, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PositionSnapshotsTable extends PositionSnapshots
    with TableInfo<$PositionSnapshotsTable, PositionSnapshot> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PositionSnapshotsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
    'account_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _instrumentCodeMeta = const VerificationMeta(
    'instrumentCode',
  );
  @override
  late final GeneratedColumn<String> instrumentCode = GeneratedColumn<String>(
    'instrument_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _qtyMeta = const VerificationMeta('qty');
  @override
  late final GeneratedColumn<int> qty = GeneratedColumn<int>(
    'qty',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _costPriceMeta = const VerificationMeta(
    'costPrice',
  );
  @override
  late final GeneratedColumn<double> costPrice = GeneratedColumn<double>(
    'cost_price',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _revisionCountMeta = const VerificationMeta(
    'revisionCount',
  );
  @override
  late final GeneratedColumn<int> revisionCount = GeneratedColumn<int>(
    'revision_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    deviceId,
    accountId,
    instrumentCode,
    date,
    qty,
    costPrice,
    source,
    revisionCount,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'position_snapshots';
  @override
  VerificationContext validateIntegrity(
    Insertable<PositionSnapshot> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('instrument_code')) {
      context.handle(
        _instrumentCodeMeta,
        instrumentCode.isAcceptableOrUnknown(
          data['instrument_code']!,
          _instrumentCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_instrumentCodeMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('qty')) {
      context.handle(
        _qtyMeta,
        qty.isAcceptableOrUnknown(data['qty']!, _qtyMeta),
      );
    } else if (isInserting) {
      context.missing(_qtyMeta);
    }
    if (data.containsKey('cost_price')) {
      context.handle(
        _costPriceMeta,
        costPrice.isAcceptableOrUnknown(data['cost_price']!, _costPriceMeta),
      );
    } else if (isInserting) {
      context.missing(_costPriceMeta);
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('revision_count')) {
      context.handle(
        _revisionCountMeta,
        revisionCount.isAcceptableOrUnknown(
          data['revision_count']!,
          _revisionCountMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PositionSnapshot map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PositionSnapshot(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_id'],
      )!,
      instrumentCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}instrument_code'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      )!,
      qty: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}qty'],
      )!,
      costPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}cost_price'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      revisionCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revision_count'],
      )!,
    );
  }

  @override
  $PositionSnapshotsTable createAlias(String alias) {
    return $PositionSnapshotsTable(attachedDatabase, alias);
  }
}

class PositionSnapshot extends DataClass
    implements Insertable<PositionSnapshot> {
  final String id;
  final int createdAt;
  final int updatedAt;
  final int? deletedAt;
  final String deviceId;
  final String accountId;
  final String instrumentCode;
  final String date;
  final int qty;
  final double costPrice;
  final String source;
  final int revisionCount;
  const PositionSnapshot({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.deviceId,
    required this.accountId,
    required this.instrumentCode,
    required this.date,
    required this.qty,
    required this.costPrice,
    required this.source,
    required this.revisionCount,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['device_id'] = Variable<String>(deviceId);
    map['account_id'] = Variable<String>(accountId);
    map['instrument_code'] = Variable<String>(instrumentCode);
    map['date'] = Variable<String>(date);
    map['qty'] = Variable<int>(qty);
    map['cost_price'] = Variable<double>(costPrice);
    map['source'] = Variable<String>(source);
    map['revision_count'] = Variable<int>(revisionCount);
    return map;
  }

  PositionSnapshotsCompanion toCompanion(bool nullToAbsent) {
    return PositionSnapshotsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      deviceId: Value(deviceId),
      accountId: Value(accountId),
      instrumentCode: Value(instrumentCode),
      date: Value(date),
      qty: Value(qty),
      costPrice: Value(costPrice),
      source: Value(source),
      revisionCount: Value(revisionCount),
    );
  }

  factory PositionSnapshot.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PositionSnapshot(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      accountId: serializer.fromJson<String>(json['accountId']),
      instrumentCode: serializer.fromJson<String>(json['instrumentCode']),
      date: serializer.fromJson<String>(json['date']),
      qty: serializer.fromJson<int>(json['qty']),
      costPrice: serializer.fromJson<double>(json['costPrice']),
      source: serializer.fromJson<String>(json['source']),
      revisionCount: serializer.fromJson<int>(json['revisionCount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'deviceId': serializer.toJson<String>(deviceId),
      'accountId': serializer.toJson<String>(accountId),
      'instrumentCode': serializer.toJson<String>(instrumentCode),
      'date': serializer.toJson<String>(date),
      'qty': serializer.toJson<int>(qty),
      'costPrice': serializer.toJson<double>(costPrice),
      'source': serializer.toJson<String>(source),
      'revisionCount': serializer.toJson<int>(revisionCount),
    };
  }

  PositionSnapshot copyWith({
    String? id,
    int? createdAt,
    int? updatedAt,
    Value<int?> deletedAt = const Value.absent(),
    String? deviceId,
    String? accountId,
    String? instrumentCode,
    String? date,
    int? qty,
    double? costPrice,
    String? source,
    int? revisionCount,
  }) => PositionSnapshot(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    deviceId: deviceId ?? this.deviceId,
    accountId: accountId ?? this.accountId,
    instrumentCode: instrumentCode ?? this.instrumentCode,
    date: date ?? this.date,
    qty: qty ?? this.qty,
    costPrice: costPrice ?? this.costPrice,
    source: source ?? this.source,
    revisionCount: revisionCount ?? this.revisionCount,
  );
  PositionSnapshot copyWithCompanion(PositionSnapshotsCompanion data) {
    return PositionSnapshot(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      instrumentCode: data.instrumentCode.present
          ? data.instrumentCode.value
          : this.instrumentCode,
      date: data.date.present ? data.date.value : this.date,
      qty: data.qty.present ? data.qty.value : this.qty,
      costPrice: data.costPrice.present ? data.costPrice.value : this.costPrice,
      source: data.source.present ? data.source.value : this.source,
      revisionCount: data.revisionCount.present
          ? data.revisionCount.value
          : this.revisionCount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PositionSnapshot(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('accountId: $accountId, ')
          ..write('instrumentCode: $instrumentCode, ')
          ..write('date: $date, ')
          ..write('qty: $qty, ')
          ..write('costPrice: $costPrice, ')
          ..write('source: $source, ')
          ..write('revisionCount: $revisionCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    deviceId,
    accountId,
    instrumentCode,
    date,
    qty,
    costPrice,
    source,
    revisionCount,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PositionSnapshot &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.deviceId == this.deviceId &&
          other.accountId == this.accountId &&
          other.instrumentCode == this.instrumentCode &&
          other.date == this.date &&
          other.qty == this.qty &&
          other.costPrice == this.costPrice &&
          other.source == this.source &&
          other.revisionCount == this.revisionCount);
}

class PositionSnapshotsCompanion extends UpdateCompanion<PositionSnapshot> {
  final Value<String> id;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<String> deviceId;
  final Value<String> accountId;
  final Value<String> instrumentCode;
  final Value<String> date;
  final Value<int> qty;
  final Value<double> costPrice;
  final Value<String> source;
  final Value<int> revisionCount;
  final Value<int> rowid;
  const PositionSnapshotsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.accountId = const Value.absent(),
    this.instrumentCode = const Value.absent(),
    this.date = const Value.absent(),
    this.qty = const Value.absent(),
    this.costPrice = const Value.absent(),
    this.source = const Value.absent(),
    this.revisionCount = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PositionSnapshotsCompanion.insert({
    required String id,
    required int createdAt,
    required int updatedAt,
    this.deletedAt = const Value.absent(),
    required String deviceId,
    required String accountId,
    required String instrumentCode,
    required String date,
    required int qty,
    required double costPrice,
    required String source,
    this.revisionCount = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       deviceId = Value(deviceId),
       accountId = Value(accountId),
       instrumentCode = Value(instrumentCode),
       date = Value(date),
       qty = Value(qty),
       costPrice = Value(costPrice),
       source = Value(source);
  static Insertable<PositionSnapshot> custom({
    Expression<String>? id,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<String>? deviceId,
    Expression<String>? accountId,
    Expression<String>? instrumentCode,
    Expression<String>? date,
    Expression<int>? qty,
    Expression<double>? costPrice,
    Expression<String>? source,
    Expression<int>? revisionCount,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (deviceId != null) 'device_id': deviceId,
      if (accountId != null) 'account_id': accountId,
      if (instrumentCode != null) 'instrument_code': instrumentCode,
      if (date != null) 'date': date,
      if (qty != null) 'qty': qty,
      if (costPrice != null) 'cost_price': costPrice,
      if (source != null) 'source': source,
      if (revisionCount != null) 'revision_count': revisionCount,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PositionSnapshotsCompanion copyWith({
    Value<String>? id,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int?>? deletedAt,
    Value<String>? deviceId,
    Value<String>? accountId,
    Value<String>? instrumentCode,
    Value<String>? date,
    Value<int>? qty,
    Value<double>? costPrice,
    Value<String>? source,
    Value<int>? revisionCount,
    Value<int>? rowid,
  }) {
    return PositionSnapshotsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      deviceId: deviceId ?? this.deviceId,
      accountId: accountId ?? this.accountId,
      instrumentCode: instrumentCode ?? this.instrumentCode,
      date: date ?? this.date,
      qty: qty ?? this.qty,
      costPrice: costPrice ?? this.costPrice,
      source: source ?? this.source,
      revisionCount: revisionCount ?? this.revisionCount,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (instrumentCode.present) {
      map['instrument_code'] = Variable<String>(instrumentCode.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (qty.present) {
      map['qty'] = Variable<int>(qty.value);
    }
    if (costPrice.present) {
      map['cost_price'] = Variable<double>(costPrice.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (revisionCount.present) {
      map['revision_count'] = Variable<int>(revisionCount.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PositionSnapshotsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('accountId: $accountId, ')
          ..write('instrumentCode: $instrumentCode, ')
          ..write('date: $date, ')
          ..write('qty: $qty, ')
          ..write('costPrice: $costPrice, ')
          ..write('source: $source, ')
          ..write('revisionCount: $revisionCount, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ImportBatchesTable extends ImportBatches
    with TableInfo<$ImportBatchesTable, ImportBatch> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ImportBatchesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fileNameMeta = const VerificationMeta(
    'fileName',
  );
  @override
  late final GeneratedColumn<String> fileName = GeneratedColumn<String>(
    'file_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _mappingIdMeta = const VerificationMeta(
    'mappingId',
  );
  @override
  late final GeneratedColumn<String> mappingId = GeneratedColumn<String>(
    'mapping_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tsMeta = const VerificationMeta('ts');
  @override
  late final GeneratedColumn<int> ts = GeneratedColumn<int>(
    'ts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rowCountMeta = const VerificationMeta(
    'rowCount',
  );
  @override
  late final GeneratedColumn<int> rowCount = GeneratedColumn<int>(
    'row_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    deviceId,
    kind,
    fileName,
    mappingId,
    ts,
    rowCount,
    status,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'import_batches';
  @override
  VerificationContext validateIntegrity(
    Insertable<ImportBatch> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('file_name')) {
      context.handle(
        _fileNameMeta,
        fileName.isAcceptableOrUnknown(data['file_name']!, _fileNameMeta),
      );
    }
    if (data.containsKey('mapping_id')) {
      context.handle(
        _mappingIdMeta,
        mappingId.isAcceptableOrUnknown(data['mapping_id']!, _mappingIdMeta),
      );
    }
    if (data.containsKey('ts')) {
      context.handle(_tsMeta, ts.isAcceptableOrUnknown(data['ts']!, _tsMeta));
    } else if (isInserting) {
      context.missing(_tsMeta);
    }
    if (data.containsKey('row_count')) {
      context.handle(
        _rowCountMeta,
        rowCount.isAcceptableOrUnknown(data['row_count']!, _rowCountMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ImportBatch map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ImportBatch(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      fileName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_name'],
      ),
      mappingId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mapping_id'],
      ),
      ts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ts'],
      )!,
      rowCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}row_count'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
    );
  }

  @override
  $ImportBatchesTable createAlias(String alias) {
    return $ImportBatchesTable(attachedDatabase, alias);
  }
}

class ImportBatch extends DataClass implements Insertable<ImportBatch> {
  final String id;
  final int createdAt;
  final int updatedAt;
  final int? deletedAt;
  final String deviceId;

  /// image | table
  final String kind;
  final String? fileName;
  final String? mappingId;
  final int ts;
  final int rowCount;
  final String status;
  const ImportBatch({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.deviceId,
    required this.kind,
    this.fileName,
    this.mappingId,
    required this.ts,
    required this.rowCount,
    required this.status,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['device_id'] = Variable<String>(deviceId);
    map['kind'] = Variable<String>(kind);
    if (!nullToAbsent || fileName != null) {
      map['file_name'] = Variable<String>(fileName);
    }
    if (!nullToAbsent || mappingId != null) {
      map['mapping_id'] = Variable<String>(mappingId);
    }
    map['ts'] = Variable<int>(ts);
    map['row_count'] = Variable<int>(rowCount);
    map['status'] = Variable<String>(status);
    return map;
  }

  ImportBatchesCompanion toCompanion(bool nullToAbsent) {
    return ImportBatchesCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      deviceId: Value(deviceId),
      kind: Value(kind),
      fileName: fileName == null && nullToAbsent
          ? const Value.absent()
          : Value(fileName),
      mappingId: mappingId == null && nullToAbsent
          ? const Value.absent()
          : Value(mappingId),
      ts: Value(ts),
      rowCount: Value(rowCount),
      status: Value(status),
    );
  }

  factory ImportBatch.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ImportBatch(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      kind: serializer.fromJson<String>(json['kind']),
      fileName: serializer.fromJson<String?>(json['fileName']),
      mappingId: serializer.fromJson<String?>(json['mappingId']),
      ts: serializer.fromJson<int>(json['ts']),
      rowCount: serializer.fromJson<int>(json['rowCount']),
      status: serializer.fromJson<String>(json['status']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'deviceId': serializer.toJson<String>(deviceId),
      'kind': serializer.toJson<String>(kind),
      'fileName': serializer.toJson<String?>(fileName),
      'mappingId': serializer.toJson<String?>(mappingId),
      'ts': serializer.toJson<int>(ts),
      'rowCount': serializer.toJson<int>(rowCount),
      'status': serializer.toJson<String>(status),
    };
  }

  ImportBatch copyWith({
    String? id,
    int? createdAt,
    int? updatedAt,
    Value<int?> deletedAt = const Value.absent(),
    String? deviceId,
    String? kind,
    Value<String?> fileName = const Value.absent(),
    Value<String?> mappingId = const Value.absent(),
    int? ts,
    int? rowCount,
    String? status,
  }) => ImportBatch(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    deviceId: deviceId ?? this.deviceId,
    kind: kind ?? this.kind,
    fileName: fileName.present ? fileName.value : this.fileName,
    mappingId: mappingId.present ? mappingId.value : this.mappingId,
    ts: ts ?? this.ts,
    rowCount: rowCount ?? this.rowCount,
    status: status ?? this.status,
  );
  ImportBatch copyWithCompanion(ImportBatchesCompanion data) {
    return ImportBatch(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      kind: data.kind.present ? data.kind.value : this.kind,
      fileName: data.fileName.present ? data.fileName.value : this.fileName,
      mappingId: data.mappingId.present ? data.mappingId.value : this.mappingId,
      ts: data.ts.present ? data.ts.value : this.ts,
      rowCount: data.rowCount.present ? data.rowCount.value : this.rowCount,
      status: data.status.present ? data.status.value : this.status,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ImportBatch(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('kind: $kind, ')
          ..write('fileName: $fileName, ')
          ..write('mappingId: $mappingId, ')
          ..write('ts: $ts, ')
          ..write('rowCount: $rowCount, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    deviceId,
    kind,
    fileName,
    mappingId,
    ts,
    rowCount,
    status,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ImportBatch &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.deviceId == this.deviceId &&
          other.kind == this.kind &&
          other.fileName == this.fileName &&
          other.mappingId == this.mappingId &&
          other.ts == this.ts &&
          other.rowCount == this.rowCount &&
          other.status == this.status);
}

class ImportBatchesCompanion extends UpdateCompanion<ImportBatch> {
  final Value<String> id;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<String> deviceId;
  final Value<String> kind;
  final Value<String?> fileName;
  final Value<String?> mappingId;
  final Value<int> ts;
  final Value<int> rowCount;
  final Value<String> status;
  final Value<int> rowid;
  const ImportBatchesCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.kind = const Value.absent(),
    this.fileName = const Value.absent(),
    this.mappingId = const Value.absent(),
    this.ts = const Value.absent(),
    this.rowCount = const Value.absent(),
    this.status = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ImportBatchesCompanion.insert({
    required String id,
    required int createdAt,
    required int updatedAt,
    this.deletedAt = const Value.absent(),
    required String deviceId,
    required String kind,
    this.fileName = const Value.absent(),
    this.mappingId = const Value.absent(),
    required int ts,
    this.rowCount = const Value.absent(),
    required String status,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       deviceId = Value(deviceId),
       kind = Value(kind),
       ts = Value(ts),
       status = Value(status);
  static Insertable<ImportBatch> custom({
    Expression<String>? id,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<String>? deviceId,
    Expression<String>? kind,
    Expression<String>? fileName,
    Expression<String>? mappingId,
    Expression<int>? ts,
    Expression<int>? rowCount,
    Expression<String>? status,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (deviceId != null) 'device_id': deviceId,
      if (kind != null) 'kind': kind,
      if (fileName != null) 'file_name': fileName,
      if (mappingId != null) 'mapping_id': mappingId,
      if (ts != null) 'ts': ts,
      if (rowCount != null) 'row_count': rowCount,
      if (status != null) 'status': status,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ImportBatchesCompanion copyWith({
    Value<String>? id,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int?>? deletedAt,
    Value<String>? deviceId,
    Value<String>? kind,
    Value<String?>? fileName,
    Value<String?>? mappingId,
    Value<int>? ts,
    Value<int>? rowCount,
    Value<String>? status,
    Value<int>? rowid,
  }) {
    return ImportBatchesCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      deviceId: deviceId ?? this.deviceId,
      kind: kind ?? this.kind,
      fileName: fileName ?? this.fileName,
      mappingId: mappingId ?? this.mappingId,
      ts: ts ?? this.ts,
      rowCount: rowCount ?? this.rowCount,
      status: status ?? this.status,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (fileName.present) {
      map['file_name'] = Variable<String>(fileName.value);
    }
    if (mappingId.present) {
      map['mapping_id'] = Variable<String>(mappingId.value);
    }
    if (ts.present) {
      map['ts'] = Variable<int>(ts.value);
    }
    if (rowCount.present) {
      map['row_count'] = Variable<int>(rowCount.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ImportBatchesCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('kind: $kind, ')
          ..write('fileName: $fileName, ')
          ..write('mappingId: $mappingId, ')
          ..write('ts: $ts, ')
          ..write('rowCount: $rowCount, ')
          ..write('status: $status, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ColumnMappingsTable extends ColumnMappings
    with TableInfo<$ColumnMappingsTable, ColumnMapping> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ColumnMappingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _brokerMeta = const VerificationMeta('broker');
  @override
  late final GeneratedColumn<String> broker = GeneratedColumn<String>(
    'broker',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Map<String, dynamic>, String>
  mapping = GeneratedColumn<String>(
    'mapping',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<Map<String, dynamic>>($ColumnMappingsTable.$convertermapping);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    deviceId,
    name,
    broker,
    mapping,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'column_mappings';
  @override
  VerificationContext validateIntegrity(
    Insertable<ColumnMapping> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('broker')) {
      context.handle(
        _brokerMeta,
        broker.isAcceptableOrUnknown(data['broker']!, _brokerMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ColumnMapping map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ColumnMapping(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      broker: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}broker'],
      ),
      mapping: $ColumnMappingsTable.$convertermapping.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}mapping'],
        )!,
      ),
    );
  }

  @override
  $ColumnMappingsTable createAlias(String alias) {
    return $ColumnMappingsTable(attachedDatabase, alias);
  }

  static TypeConverter<Map<String, dynamic>, String> $convertermapping =
      const JsonMapConverter();
}

class ColumnMapping extends DataClass implements Insertable<ColumnMapping> {
  final String id;
  final int createdAt;
  final int updatedAt;
  final int? deletedAt;
  final String deviceId;
  final String name;
  final String? broker;
  final Map<String, dynamic> mapping;
  const ColumnMapping({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.deviceId,
    required this.name,
    this.broker,
    required this.mapping,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['device_id'] = Variable<String>(deviceId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || broker != null) {
      map['broker'] = Variable<String>(broker);
    }
    {
      map['mapping'] = Variable<String>(
        $ColumnMappingsTable.$convertermapping.toSql(mapping),
      );
    }
    return map;
  }

  ColumnMappingsCompanion toCompanion(bool nullToAbsent) {
    return ColumnMappingsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      deviceId: Value(deviceId),
      name: Value(name),
      broker: broker == null && nullToAbsent
          ? const Value.absent()
          : Value(broker),
      mapping: Value(mapping),
    );
  }

  factory ColumnMapping.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ColumnMapping(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      name: serializer.fromJson<String>(json['name']),
      broker: serializer.fromJson<String?>(json['broker']),
      mapping: serializer.fromJson<Map<String, dynamic>>(json['mapping']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'deviceId': serializer.toJson<String>(deviceId),
      'name': serializer.toJson<String>(name),
      'broker': serializer.toJson<String?>(broker),
      'mapping': serializer.toJson<Map<String, dynamic>>(mapping),
    };
  }

  ColumnMapping copyWith({
    String? id,
    int? createdAt,
    int? updatedAt,
    Value<int?> deletedAt = const Value.absent(),
    String? deviceId,
    String? name,
    Value<String?> broker = const Value.absent(),
    Map<String, dynamic>? mapping,
  }) => ColumnMapping(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    deviceId: deviceId ?? this.deviceId,
    name: name ?? this.name,
    broker: broker.present ? broker.value : this.broker,
    mapping: mapping ?? this.mapping,
  );
  ColumnMapping copyWithCompanion(ColumnMappingsCompanion data) {
    return ColumnMapping(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      name: data.name.present ? data.name.value : this.name,
      broker: data.broker.present ? data.broker.value : this.broker,
      mapping: data.mapping.present ? data.mapping.value : this.mapping,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ColumnMapping(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('name: $name, ')
          ..write('broker: $broker, ')
          ..write('mapping: $mapping')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    deviceId,
    name,
    broker,
    mapping,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ColumnMapping &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.deviceId == this.deviceId &&
          other.name == this.name &&
          other.broker == this.broker &&
          other.mapping == this.mapping);
}

class ColumnMappingsCompanion extends UpdateCompanion<ColumnMapping> {
  final Value<String> id;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<String> deviceId;
  final Value<String> name;
  final Value<String?> broker;
  final Value<Map<String, dynamic>> mapping;
  final Value<int> rowid;
  const ColumnMappingsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.name = const Value.absent(),
    this.broker = const Value.absent(),
    this.mapping = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ColumnMappingsCompanion.insert({
    required String id,
    required int createdAt,
    required int updatedAt,
    this.deletedAt = const Value.absent(),
    required String deviceId,
    required String name,
    this.broker = const Value.absent(),
    required Map<String, dynamic> mapping,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       deviceId = Value(deviceId),
       name = Value(name),
       mapping = Value(mapping);
  static Insertable<ColumnMapping> custom({
    Expression<String>? id,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<String>? deviceId,
    Expression<String>? name,
    Expression<String>? broker,
    Expression<String>? mapping,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (deviceId != null) 'device_id': deviceId,
      if (name != null) 'name': name,
      if (broker != null) 'broker': broker,
      if (mapping != null) 'mapping': mapping,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ColumnMappingsCompanion copyWith({
    Value<String>? id,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int?>? deletedAt,
    Value<String>? deviceId,
    Value<String>? name,
    Value<String?>? broker,
    Value<Map<String, dynamic>>? mapping,
    Value<int>? rowid,
  }) {
    return ColumnMappingsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      deviceId: deviceId ?? this.deviceId,
      name: name ?? this.name,
      broker: broker ?? this.broker,
      mapping: mapping ?? this.mapping,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (broker.present) {
      map['broker'] = Variable<String>(broker.value);
    }
    if (mapping.present) {
      map['mapping'] = Variable<String>(
        $ColumnMappingsTable.$convertermapping.toSql(mapping.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ColumnMappingsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('name: $name, ')
          ..write('broker: $broker, ')
          ..write('mapping: $mapping, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AgentThreadsTable extends AgentThreads
    with TableInfo<$AgentThreadsTable, AgentThread> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AgentThreadsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _summaryMeta = const VerificationMeta(
    'summary',
  );
  @override
  late final GeneratedColumn<String> summary = GeneratedColumn<String>(
    'summary',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _summaryUptoMessageIdMeta =
      const VerificationMeta('summaryUptoMessageId');
  @override
  late final GeneratedColumn<String> summaryUptoMessageId =
      GeneratedColumn<String>(
        'summary_upto_message_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _lastMessageAtMeta = const VerificationMeta(
    'lastMessageAt',
  );
  @override
  late final GeneratedColumn<int> lastMessageAt = GeneratedColumn<int>(
    'last_message_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pinnedMeta = const VerificationMeta('pinned');
  @override
  late final GeneratedColumn<bool> pinned = GeneratedColumn<bool>(
    'pinned',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("pinned" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    deviceId,
    title,
    summary,
    summaryUptoMessageId,
    lastMessageAt,
    pinned,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'agent_threads';
  @override
  VerificationContext validateIntegrity(
    Insertable<AgentThread> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('summary')) {
      context.handle(
        _summaryMeta,
        summary.isAcceptableOrUnknown(data['summary']!, _summaryMeta),
      );
    }
    if (data.containsKey('summary_upto_message_id')) {
      context.handle(
        _summaryUptoMessageIdMeta,
        summaryUptoMessageId.isAcceptableOrUnknown(
          data['summary_upto_message_id']!,
          _summaryUptoMessageIdMeta,
        ),
      );
    }
    if (data.containsKey('last_message_at')) {
      context.handle(
        _lastMessageAtMeta,
        lastMessageAt.isAcceptableOrUnknown(
          data['last_message_at']!,
          _lastMessageAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastMessageAtMeta);
    }
    if (data.containsKey('pinned')) {
      context.handle(
        _pinnedMeta,
        pinned.isAcceptableOrUnknown(data['pinned']!, _pinnedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AgentThread map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AgentThread(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      summary: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}summary'],
      ),
      summaryUptoMessageId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}summary_upto_message_id'],
      ),
      lastMessageAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_message_at'],
      )!,
      pinned: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}pinned'],
      )!,
    );
  }

  @override
  $AgentThreadsTable createAlias(String alias) {
    return $AgentThreadsTable(attachedDatabase, alias);
  }
}

class AgentThread extends DataClass implements Insertable<AgentThread> {
  final String id;
  final int createdAt;
  final int updatedAt;
  final int? deletedAt;
  final String deviceId;
  final String title;

  /// 早期消息压缩后的滚动摘要
  final String? summary;
  final String? summaryUptoMessageId;
  final int lastMessageAt;
  final bool pinned;
  const AgentThread({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.deviceId,
    required this.title,
    this.summary,
    this.summaryUptoMessageId,
    required this.lastMessageAt,
    required this.pinned,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['device_id'] = Variable<String>(deviceId);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || summary != null) {
      map['summary'] = Variable<String>(summary);
    }
    if (!nullToAbsent || summaryUptoMessageId != null) {
      map['summary_upto_message_id'] = Variable<String>(summaryUptoMessageId);
    }
    map['last_message_at'] = Variable<int>(lastMessageAt);
    map['pinned'] = Variable<bool>(pinned);
    return map;
  }

  AgentThreadsCompanion toCompanion(bool nullToAbsent) {
    return AgentThreadsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      deviceId: Value(deviceId),
      title: Value(title),
      summary: summary == null && nullToAbsent
          ? const Value.absent()
          : Value(summary),
      summaryUptoMessageId: summaryUptoMessageId == null && nullToAbsent
          ? const Value.absent()
          : Value(summaryUptoMessageId),
      lastMessageAt: Value(lastMessageAt),
      pinned: Value(pinned),
    );
  }

  factory AgentThread.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AgentThread(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      title: serializer.fromJson<String>(json['title']),
      summary: serializer.fromJson<String?>(json['summary']),
      summaryUptoMessageId: serializer.fromJson<String?>(
        json['summaryUptoMessageId'],
      ),
      lastMessageAt: serializer.fromJson<int>(json['lastMessageAt']),
      pinned: serializer.fromJson<bool>(json['pinned']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'deviceId': serializer.toJson<String>(deviceId),
      'title': serializer.toJson<String>(title),
      'summary': serializer.toJson<String?>(summary),
      'summaryUptoMessageId': serializer.toJson<String?>(summaryUptoMessageId),
      'lastMessageAt': serializer.toJson<int>(lastMessageAt),
      'pinned': serializer.toJson<bool>(pinned),
    };
  }

  AgentThread copyWith({
    String? id,
    int? createdAt,
    int? updatedAt,
    Value<int?> deletedAt = const Value.absent(),
    String? deviceId,
    String? title,
    Value<String?> summary = const Value.absent(),
    Value<String?> summaryUptoMessageId = const Value.absent(),
    int? lastMessageAt,
    bool? pinned,
  }) => AgentThread(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    deviceId: deviceId ?? this.deviceId,
    title: title ?? this.title,
    summary: summary.present ? summary.value : this.summary,
    summaryUptoMessageId: summaryUptoMessageId.present
        ? summaryUptoMessageId.value
        : this.summaryUptoMessageId,
    lastMessageAt: lastMessageAt ?? this.lastMessageAt,
    pinned: pinned ?? this.pinned,
  );
  AgentThread copyWithCompanion(AgentThreadsCompanion data) {
    return AgentThread(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      title: data.title.present ? data.title.value : this.title,
      summary: data.summary.present ? data.summary.value : this.summary,
      summaryUptoMessageId: data.summaryUptoMessageId.present
          ? data.summaryUptoMessageId.value
          : this.summaryUptoMessageId,
      lastMessageAt: data.lastMessageAt.present
          ? data.lastMessageAt.value
          : this.lastMessageAt,
      pinned: data.pinned.present ? data.pinned.value : this.pinned,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AgentThread(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('title: $title, ')
          ..write('summary: $summary, ')
          ..write('summaryUptoMessageId: $summaryUptoMessageId, ')
          ..write('lastMessageAt: $lastMessageAt, ')
          ..write('pinned: $pinned')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    deviceId,
    title,
    summary,
    summaryUptoMessageId,
    lastMessageAt,
    pinned,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AgentThread &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.deviceId == this.deviceId &&
          other.title == this.title &&
          other.summary == this.summary &&
          other.summaryUptoMessageId == this.summaryUptoMessageId &&
          other.lastMessageAt == this.lastMessageAt &&
          other.pinned == this.pinned);
}

class AgentThreadsCompanion extends UpdateCompanion<AgentThread> {
  final Value<String> id;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<String> deviceId;
  final Value<String> title;
  final Value<String?> summary;
  final Value<String?> summaryUptoMessageId;
  final Value<int> lastMessageAt;
  final Value<bool> pinned;
  final Value<int> rowid;
  const AgentThreadsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.title = const Value.absent(),
    this.summary = const Value.absent(),
    this.summaryUptoMessageId = const Value.absent(),
    this.lastMessageAt = const Value.absent(),
    this.pinned = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AgentThreadsCompanion.insert({
    required String id,
    required int createdAt,
    required int updatedAt,
    this.deletedAt = const Value.absent(),
    required String deviceId,
    required String title,
    this.summary = const Value.absent(),
    this.summaryUptoMessageId = const Value.absent(),
    required int lastMessageAt,
    this.pinned = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       deviceId = Value(deviceId),
       title = Value(title),
       lastMessageAt = Value(lastMessageAt);
  static Insertable<AgentThread> custom({
    Expression<String>? id,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<String>? deviceId,
    Expression<String>? title,
    Expression<String>? summary,
    Expression<String>? summaryUptoMessageId,
    Expression<int>? lastMessageAt,
    Expression<bool>? pinned,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (deviceId != null) 'device_id': deviceId,
      if (title != null) 'title': title,
      if (summary != null) 'summary': summary,
      if (summaryUptoMessageId != null)
        'summary_upto_message_id': summaryUptoMessageId,
      if (lastMessageAt != null) 'last_message_at': lastMessageAt,
      if (pinned != null) 'pinned': pinned,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AgentThreadsCompanion copyWith({
    Value<String>? id,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int?>? deletedAt,
    Value<String>? deviceId,
    Value<String>? title,
    Value<String?>? summary,
    Value<String?>? summaryUptoMessageId,
    Value<int>? lastMessageAt,
    Value<bool>? pinned,
    Value<int>? rowid,
  }) {
    return AgentThreadsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      deviceId: deviceId ?? this.deviceId,
      title: title ?? this.title,
      summary: summary ?? this.summary,
      summaryUptoMessageId: summaryUptoMessageId ?? this.summaryUptoMessageId,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      pinned: pinned ?? this.pinned,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (summary.present) {
      map['summary'] = Variable<String>(summary.value);
    }
    if (summaryUptoMessageId.present) {
      map['summary_upto_message_id'] = Variable<String>(
        summaryUptoMessageId.value,
      );
    }
    if (lastMessageAt.present) {
      map['last_message_at'] = Variable<int>(lastMessageAt.value);
    }
    if (pinned.present) {
      map['pinned'] = Variable<bool>(pinned.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AgentThreadsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('title: $title, ')
          ..write('summary: $summary, ')
          ..write('summaryUptoMessageId: $summaryUptoMessageId, ')
          ..write('lastMessageAt: $lastMessageAt, ')
          ..write('pinned: $pinned, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AgentMessagesTable extends AgentMessages
    with TableInfo<$AgentMessagesTable, AgentMessage> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AgentMessagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _threadIdMeta = const VerificationMeta(
    'threadId',
  );
  @override
  late final GeneratedColumn<String> threadId = GeneratedColumn<String>(
    'thread_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _toolCallsMeta = const VerificationMeta(
    'toolCalls',
  );
  @override
  late final GeneratedColumn<String> toolCalls = GeneratedColumn<String>(
    'tool_calls',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _toolCallIdMeta = const VerificationMeta(
    'toolCallId',
  );
  @override
  late final GeneratedColumn<String> toolCallId = GeneratedColumn<String>(
    'tool_call_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tsMeta = const VerificationMeta('ts');
  @override
  late final GeneratedColumn<int> ts = GeneratedColumn<int>(
    'ts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tokensMeta = const VerificationMeta('tokens');
  @override
  late final GeneratedColumn<int> tokens = GeneratedColumn<int>(
    'tokens',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    deviceId,
    threadId,
    role,
    content,
    toolCalls,
    toolCallId,
    ts,
    tokens,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'agent_messages';
  @override
  VerificationContext validateIntegrity(
    Insertable<AgentMessage> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('thread_id')) {
      context.handle(
        _threadIdMeta,
        threadId.isAcceptableOrUnknown(data['thread_id']!, _threadIdMeta),
      );
    } else if (isInserting) {
      context.missing(_threadIdMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('tool_calls')) {
      context.handle(
        _toolCallsMeta,
        toolCalls.isAcceptableOrUnknown(data['tool_calls']!, _toolCallsMeta),
      );
    }
    if (data.containsKey('tool_call_id')) {
      context.handle(
        _toolCallIdMeta,
        toolCallId.isAcceptableOrUnknown(
          data['tool_call_id']!,
          _toolCallIdMeta,
        ),
      );
    }
    if (data.containsKey('ts')) {
      context.handle(_tsMeta, ts.isAcceptableOrUnknown(data['ts']!, _tsMeta));
    } else if (isInserting) {
      context.missing(_tsMeta);
    }
    if (data.containsKey('tokens')) {
      context.handle(
        _tokensMeta,
        tokens.isAcceptableOrUnknown(data['tokens']!, _tokensMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AgentMessage map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AgentMessage(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      threadId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}thread_id'],
      )!,
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      toolCalls: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tool_calls'],
      ),
      toolCallId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tool_call_id'],
      ),
      ts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ts'],
      )!,
      tokens: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tokens'],
      ),
    );
  }

  @override
  $AgentMessagesTable createAlias(String alias) {
    return $AgentMessagesTable(attachedDatabase, alias);
  }
}

class AgentMessage extends DataClass implements Insertable<AgentMessage> {
  final String id;
  final int createdAt;
  final int updatedAt;
  final int? deletedAt;
  final String deviceId;
  final String threadId;

  /// user | assistant | tool
  final String role;
  final String content;
  final String? toolCalls;
  final String? toolCallId;
  final int ts;
  final int? tokens;
  const AgentMessage({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.deviceId,
    required this.threadId,
    required this.role,
    required this.content,
    this.toolCalls,
    this.toolCallId,
    required this.ts,
    this.tokens,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['device_id'] = Variable<String>(deviceId);
    map['thread_id'] = Variable<String>(threadId);
    map['role'] = Variable<String>(role);
    map['content'] = Variable<String>(content);
    if (!nullToAbsent || toolCalls != null) {
      map['tool_calls'] = Variable<String>(toolCalls);
    }
    if (!nullToAbsent || toolCallId != null) {
      map['tool_call_id'] = Variable<String>(toolCallId);
    }
    map['ts'] = Variable<int>(ts);
    if (!nullToAbsent || tokens != null) {
      map['tokens'] = Variable<int>(tokens);
    }
    return map;
  }

  AgentMessagesCompanion toCompanion(bool nullToAbsent) {
    return AgentMessagesCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      deviceId: Value(deviceId),
      threadId: Value(threadId),
      role: Value(role),
      content: Value(content),
      toolCalls: toolCalls == null && nullToAbsent
          ? const Value.absent()
          : Value(toolCalls),
      toolCallId: toolCallId == null && nullToAbsent
          ? const Value.absent()
          : Value(toolCallId),
      ts: Value(ts),
      tokens: tokens == null && nullToAbsent
          ? const Value.absent()
          : Value(tokens),
    );
  }

  factory AgentMessage.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AgentMessage(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      threadId: serializer.fromJson<String>(json['threadId']),
      role: serializer.fromJson<String>(json['role']),
      content: serializer.fromJson<String>(json['content']),
      toolCalls: serializer.fromJson<String?>(json['toolCalls']),
      toolCallId: serializer.fromJson<String?>(json['toolCallId']),
      ts: serializer.fromJson<int>(json['ts']),
      tokens: serializer.fromJson<int?>(json['tokens']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'deviceId': serializer.toJson<String>(deviceId),
      'threadId': serializer.toJson<String>(threadId),
      'role': serializer.toJson<String>(role),
      'content': serializer.toJson<String>(content),
      'toolCalls': serializer.toJson<String?>(toolCalls),
      'toolCallId': serializer.toJson<String?>(toolCallId),
      'ts': serializer.toJson<int>(ts),
      'tokens': serializer.toJson<int?>(tokens),
    };
  }

  AgentMessage copyWith({
    String? id,
    int? createdAt,
    int? updatedAt,
    Value<int?> deletedAt = const Value.absent(),
    String? deviceId,
    String? threadId,
    String? role,
    String? content,
    Value<String?> toolCalls = const Value.absent(),
    Value<String?> toolCallId = const Value.absent(),
    int? ts,
    Value<int?> tokens = const Value.absent(),
  }) => AgentMessage(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    deviceId: deviceId ?? this.deviceId,
    threadId: threadId ?? this.threadId,
    role: role ?? this.role,
    content: content ?? this.content,
    toolCalls: toolCalls.present ? toolCalls.value : this.toolCalls,
    toolCallId: toolCallId.present ? toolCallId.value : this.toolCallId,
    ts: ts ?? this.ts,
    tokens: tokens.present ? tokens.value : this.tokens,
  );
  AgentMessage copyWithCompanion(AgentMessagesCompanion data) {
    return AgentMessage(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      threadId: data.threadId.present ? data.threadId.value : this.threadId,
      role: data.role.present ? data.role.value : this.role,
      content: data.content.present ? data.content.value : this.content,
      toolCalls: data.toolCalls.present ? data.toolCalls.value : this.toolCalls,
      toolCallId: data.toolCallId.present
          ? data.toolCallId.value
          : this.toolCallId,
      ts: data.ts.present ? data.ts.value : this.ts,
      tokens: data.tokens.present ? data.tokens.value : this.tokens,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AgentMessage(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('threadId: $threadId, ')
          ..write('role: $role, ')
          ..write('content: $content, ')
          ..write('toolCalls: $toolCalls, ')
          ..write('toolCallId: $toolCallId, ')
          ..write('ts: $ts, ')
          ..write('tokens: $tokens')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    deviceId,
    threadId,
    role,
    content,
    toolCalls,
    toolCallId,
    ts,
    tokens,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AgentMessage &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.deviceId == this.deviceId &&
          other.threadId == this.threadId &&
          other.role == this.role &&
          other.content == this.content &&
          other.toolCalls == this.toolCalls &&
          other.toolCallId == this.toolCallId &&
          other.ts == this.ts &&
          other.tokens == this.tokens);
}

class AgentMessagesCompanion extends UpdateCompanion<AgentMessage> {
  final Value<String> id;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<String> deviceId;
  final Value<String> threadId;
  final Value<String> role;
  final Value<String> content;
  final Value<String?> toolCalls;
  final Value<String?> toolCallId;
  final Value<int> ts;
  final Value<int?> tokens;
  final Value<int> rowid;
  const AgentMessagesCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.threadId = const Value.absent(),
    this.role = const Value.absent(),
    this.content = const Value.absent(),
    this.toolCalls = const Value.absent(),
    this.toolCallId = const Value.absent(),
    this.ts = const Value.absent(),
    this.tokens = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AgentMessagesCompanion.insert({
    required String id,
    required int createdAt,
    required int updatedAt,
    this.deletedAt = const Value.absent(),
    required String deviceId,
    required String threadId,
    required String role,
    required String content,
    this.toolCalls = const Value.absent(),
    this.toolCallId = const Value.absent(),
    required int ts,
    this.tokens = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       deviceId = Value(deviceId),
       threadId = Value(threadId),
       role = Value(role),
       content = Value(content),
       ts = Value(ts);
  static Insertable<AgentMessage> custom({
    Expression<String>? id,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<String>? deviceId,
    Expression<String>? threadId,
    Expression<String>? role,
    Expression<String>? content,
    Expression<String>? toolCalls,
    Expression<String>? toolCallId,
    Expression<int>? ts,
    Expression<int>? tokens,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (deviceId != null) 'device_id': deviceId,
      if (threadId != null) 'thread_id': threadId,
      if (role != null) 'role': role,
      if (content != null) 'content': content,
      if (toolCalls != null) 'tool_calls': toolCalls,
      if (toolCallId != null) 'tool_call_id': toolCallId,
      if (ts != null) 'ts': ts,
      if (tokens != null) 'tokens': tokens,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AgentMessagesCompanion copyWith({
    Value<String>? id,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int?>? deletedAt,
    Value<String>? deviceId,
    Value<String>? threadId,
    Value<String>? role,
    Value<String>? content,
    Value<String?>? toolCalls,
    Value<String?>? toolCallId,
    Value<int>? ts,
    Value<int?>? tokens,
    Value<int>? rowid,
  }) {
    return AgentMessagesCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      deviceId: deviceId ?? this.deviceId,
      threadId: threadId ?? this.threadId,
      role: role ?? this.role,
      content: content ?? this.content,
      toolCalls: toolCalls ?? this.toolCalls,
      toolCallId: toolCallId ?? this.toolCallId,
      ts: ts ?? this.ts,
      tokens: tokens ?? this.tokens,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (threadId.present) {
      map['thread_id'] = Variable<String>(threadId.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (toolCalls.present) {
      map['tool_calls'] = Variable<String>(toolCalls.value);
    }
    if (toolCallId.present) {
      map['tool_call_id'] = Variable<String>(toolCallId.value);
    }
    if (ts.present) {
      map['ts'] = Variable<int>(ts.value);
    }
    if (tokens.present) {
      map['tokens'] = Variable<int>(tokens.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AgentMessagesCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('threadId: $threadId, ')
          ..write('role: $role, ')
          ..write('content: $content, ')
          ..write('toolCalls: $toolCalls, ')
          ..write('toolCallId: $toolCallId, ')
          ..write('ts: $ts, ')
          ..write('tokens: $tokens, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AgentMemoriesTable extends AgentMemories
    with TableInfo<$AgentMemoriesTable, AgentMemory> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AgentMemoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceThreadIdMeta = const VerificationMeta(
    'sourceThreadId',
  );
  @override
  late final GeneratedColumn<String> sourceThreadId = GeneratedColumn<String>(
    'source_thread_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _importanceMeta = const VerificationMeta(
    'importance',
  );
  @override
  late final GeneratedColumn<int> importance = GeneratedColumn<int>(
    'importance',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(3),
  );
  static const VerificationMeta _pinnedMeta = const VerificationMeta('pinned');
  @override
  late final GeneratedColumn<bool> pinned = GeneratedColumn<bool>(
    'pinned',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("pinned" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _lastUsedAtMeta = const VerificationMeta(
    'lastUsedAt',
  );
  @override
  late final GeneratedColumn<int> lastUsedAt = GeneratedColumn<int>(
    'last_used_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    deviceId,
    kind,
    content,
    status,
    sourceThreadId,
    importance,
    pinned,
    lastUsedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'agent_memories';
  @override
  VerificationContext validateIntegrity(
    Insertable<AgentMemory> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('source_thread_id')) {
      context.handle(
        _sourceThreadIdMeta,
        sourceThreadId.isAcceptableOrUnknown(
          data['source_thread_id']!,
          _sourceThreadIdMeta,
        ),
      );
    }
    if (data.containsKey('importance')) {
      context.handle(
        _importanceMeta,
        importance.isAcceptableOrUnknown(data['importance']!, _importanceMeta),
      );
    }
    if (data.containsKey('pinned')) {
      context.handle(
        _pinnedMeta,
        pinned.isAcceptableOrUnknown(data['pinned']!, _pinnedMeta),
      );
    }
    if (data.containsKey('last_used_at')) {
      context.handle(
        _lastUsedAtMeta,
        lastUsedAt.isAcceptableOrUnknown(
          data['last_used_at']!,
          _lastUsedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AgentMemory map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AgentMemory(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      sourceThreadId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_thread_id'],
      ),
      importance: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}importance'],
      )!,
      pinned: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}pinned'],
      )!,
      lastUsedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_used_at'],
      ),
    );
  }

  @override
  $AgentMemoriesTable createAlias(String alias) {
    return $AgentMemoriesTable(attachedDatabase, alias);
  }
}

class AgentMemory extends DataClass implements Insertable<AgentMemory> {
  final String id;
  final int createdAt;
  final int updatedAt;
  final int? deletedAt;
  final String deviceId;

  /// style | rule | preference | lesson | watch | fact
  final String kind;
  final String content;

  /// active | candidate（待用户确认）
  final String status;
  final String? sourceThreadId;
  final int importance;
  final bool pinned;
  final int? lastUsedAt;
  const AgentMemory({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.deviceId,
    required this.kind,
    required this.content,
    required this.status,
    this.sourceThreadId,
    required this.importance,
    required this.pinned,
    this.lastUsedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['device_id'] = Variable<String>(deviceId);
    map['kind'] = Variable<String>(kind);
    map['content'] = Variable<String>(content);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || sourceThreadId != null) {
      map['source_thread_id'] = Variable<String>(sourceThreadId);
    }
    map['importance'] = Variable<int>(importance);
    map['pinned'] = Variable<bool>(pinned);
    if (!nullToAbsent || lastUsedAt != null) {
      map['last_used_at'] = Variable<int>(lastUsedAt);
    }
    return map;
  }

  AgentMemoriesCompanion toCompanion(bool nullToAbsent) {
    return AgentMemoriesCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      deviceId: Value(deviceId),
      kind: Value(kind),
      content: Value(content),
      status: Value(status),
      sourceThreadId: sourceThreadId == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceThreadId),
      importance: Value(importance),
      pinned: Value(pinned),
      lastUsedAt: lastUsedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastUsedAt),
    );
  }

  factory AgentMemory.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AgentMemory(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      kind: serializer.fromJson<String>(json['kind']),
      content: serializer.fromJson<String>(json['content']),
      status: serializer.fromJson<String>(json['status']),
      sourceThreadId: serializer.fromJson<String?>(json['sourceThreadId']),
      importance: serializer.fromJson<int>(json['importance']),
      pinned: serializer.fromJson<bool>(json['pinned']),
      lastUsedAt: serializer.fromJson<int?>(json['lastUsedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'deviceId': serializer.toJson<String>(deviceId),
      'kind': serializer.toJson<String>(kind),
      'content': serializer.toJson<String>(content),
      'status': serializer.toJson<String>(status),
      'sourceThreadId': serializer.toJson<String?>(sourceThreadId),
      'importance': serializer.toJson<int>(importance),
      'pinned': serializer.toJson<bool>(pinned),
      'lastUsedAt': serializer.toJson<int?>(lastUsedAt),
    };
  }

  AgentMemory copyWith({
    String? id,
    int? createdAt,
    int? updatedAt,
    Value<int?> deletedAt = const Value.absent(),
    String? deviceId,
    String? kind,
    String? content,
    String? status,
    Value<String?> sourceThreadId = const Value.absent(),
    int? importance,
    bool? pinned,
    Value<int?> lastUsedAt = const Value.absent(),
  }) => AgentMemory(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    deviceId: deviceId ?? this.deviceId,
    kind: kind ?? this.kind,
    content: content ?? this.content,
    status: status ?? this.status,
    sourceThreadId: sourceThreadId.present
        ? sourceThreadId.value
        : this.sourceThreadId,
    importance: importance ?? this.importance,
    pinned: pinned ?? this.pinned,
    lastUsedAt: lastUsedAt.present ? lastUsedAt.value : this.lastUsedAt,
  );
  AgentMemory copyWithCompanion(AgentMemoriesCompanion data) {
    return AgentMemory(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      kind: data.kind.present ? data.kind.value : this.kind,
      content: data.content.present ? data.content.value : this.content,
      status: data.status.present ? data.status.value : this.status,
      sourceThreadId: data.sourceThreadId.present
          ? data.sourceThreadId.value
          : this.sourceThreadId,
      importance: data.importance.present
          ? data.importance.value
          : this.importance,
      pinned: data.pinned.present ? data.pinned.value : this.pinned,
      lastUsedAt: data.lastUsedAt.present
          ? data.lastUsedAt.value
          : this.lastUsedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AgentMemory(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('kind: $kind, ')
          ..write('content: $content, ')
          ..write('status: $status, ')
          ..write('sourceThreadId: $sourceThreadId, ')
          ..write('importance: $importance, ')
          ..write('pinned: $pinned, ')
          ..write('lastUsedAt: $lastUsedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    deviceId,
    kind,
    content,
    status,
    sourceThreadId,
    importance,
    pinned,
    lastUsedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AgentMemory &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.deviceId == this.deviceId &&
          other.kind == this.kind &&
          other.content == this.content &&
          other.status == this.status &&
          other.sourceThreadId == this.sourceThreadId &&
          other.importance == this.importance &&
          other.pinned == this.pinned &&
          other.lastUsedAt == this.lastUsedAt);
}

class AgentMemoriesCompanion extends UpdateCompanion<AgentMemory> {
  final Value<String> id;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<String> deviceId;
  final Value<String> kind;
  final Value<String> content;
  final Value<String> status;
  final Value<String?> sourceThreadId;
  final Value<int> importance;
  final Value<bool> pinned;
  final Value<int?> lastUsedAt;
  final Value<int> rowid;
  const AgentMemoriesCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.kind = const Value.absent(),
    this.content = const Value.absent(),
    this.status = const Value.absent(),
    this.sourceThreadId = const Value.absent(),
    this.importance = const Value.absent(),
    this.pinned = const Value.absent(),
    this.lastUsedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AgentMemoriesCompanion.insert({
    required String id,
    required int createdAt,
    required int updatedAt,
    this.deletedAt = const Value.absent(),
    required String deviceId,
    required String kind,
    required String content,
    required String status,
    this.sourceThreadId = const Value.absent(),
    this.importance = const Value.absent(),
    this.pinned = const Value.absent(),
    this.lastUsedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       deviceId = Value(deviceId),
       kind = Value(kind),
       content = Value(content),
       status = Value(status);
  static Insertable<AgentMemory> custom({
    Expression<String>? id,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<String>? deviceId,
    Expression<String>? kind,
    Expression<String>? content,
    Expression<String>? status,
    Expression<String>? sourceThreadId,
    Expression<int>? importance,
    Expression<bool>? pinned,
    Expression<int>? lastUsedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (deviceId != null) 'device_id': deviceId,
      if (kind != null) 'kind': kind,
      if (content != null) 'content': content,
      if (status != null) 'status': status,
      if (sourceThreadId != null) 'source_thread_id': sourceThreadId,
      if (importance != null) 'importance': importance,
      if (pinned != null) 'pinned': pinned,
      if (lastUsedAt != null) 'last_used_at': lastUsedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AgentMemoriesCompanion copyWith({
    Value<String>? id,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int?>? deletedAt,
    Value<String>? deviceId,
    Value<String>? kind,
    Value<String>? content,
    Value<String>? status,
    Value<String?>? sourceThreadId,
    Value<int>? importance,
    Value<bool>? pinned,
    Value<int?>? lastUsedAt,
    Value<int>? rowid,
  }) {
    return AgentMemoriesCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      deviceId: deviceId ?? this.deviceId,
      kind: kind ?? this.kind,
      content: content ?? this.content,
      status: status ?? this.status,
      sourceThreadId: sourceThreadId ?? this.sourceThreadId,
      importance: importance ?? this.importance,
      pinned: pinned ?? this.pinned,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (sourceThreadId.present) {
      map['source_thread_id'] = Variable<String>(sourceThreadId.value);
    }
    if (importance.present) {
      map['importance'] = Variable<int>(importance.value);
    }
    if (pinned.present) {
      map['pinned'] = Variable<bool>(pinned.value);
    }
    if (lastUsedAt.present) {
      map['last_used_at'] = Variable<int>(lastUsedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AgentMemoriesCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('kind: $kind, ')
          ..write('content: $content, ')
          ..write('status: $status, ')
          ..write('sourceThreadId: $sourceThreadId, ')
          ..write('importance: $importance, ')
          ..write('pinned: $pinned, ')
          ..write('lastUsedAt: $lastUsedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $AppMetaTable appMeta = $AppMetaTable(this);
  late final $InstrumentsTable instruments = $InstrumentsTable(this);
  late final $TradingDaysTable tradingDays = $TradingDaysTable(this);
  late final $KlineCacheTable klineCache = $KlineCacheTable(this);
  late final $JournalEntriesTable journalEntries = $JournalEntriesTable(this);
  late final $MarketSnapshotsTable marketSnapshots = $MarketSnapshotsTable(
    this,
  );
  late final $AttachmentsTable attachments = $AttachmentsTable(this);
  late final $QuickPhrasesTable quickPhrases = $QuickPhrasesTable(this);
  late final $EntryTemplatesTable entryTemplates = $EntryTemplatesTable(this);
  late final $PredictionsTable predictions = $PredictionsTable(this);
  late final $PredictionResultsTable predictionResults =
      $PredictionResultsTable(this);
  late final $ReviewNotesTable reviewNotes = $ReviewNotesTable(this);
  late final $ThresholdRulesTable thresholdRules = $ThresholdRulesTable(this);
  late final $RevisionsTable revisions = $RevisionsTable(this);
  late final $AiAnalysesTable aiAnalyses = $AiAnalysesTable(this);
  late final $AccountsTable accounts = $AccountsTable(this);
  late final $TradesTable trades = $TradesTable(this);
  late final $PositionSnapshotsTable positionSnapshots =
      $PositionSnapshotsTable(this);
  late final $ImportBatchesTable importBatches = $ImportBatchesTable(this);
  late final $ColumnMappingsTable columnMappings = $ColumnMappingsTable(this);
  late final $AgentThreadsTable agentThreads = $AgentThreadsTable(this);
  late final $AgentMessagesTable agentMessages = $AgentMessagesTable(this);
  late final $AgentMemoriesTable agentMemories = $AgentMemoriesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    appMeta,
    instruments,
    tradingDays,
    klineCache,
    journalEntries,
    marketSnapshots,
    attachments,
    quickPhrases,
    entryTemplates,
    predictions,
    predictionResults,
    reviewNotes,
    thresholdRules,
    revisions,
    aiAnalyses,
    accounts,
    trades,
    positionSnapshots,
    importBatches,
    columnMappings,
    agentThreads,
    agentMessages,
    agentMemories,
  ];
}

typedef $$AppMetaTableCreateCompanionBuilder = AppMetaCompanion Function({
  required String key,
  required String value,
  Value<int> rowid,
});
typedef $$AppMetaTableUpdateCompanionBuilder = AppMetaCompanion Function({
  Value<String> key,
  Value<String> value,
  Value<int> rowid,
});

class $$AppMetaTableFilterComposer
    extends Composer<_$AppDatabase, $AppMetaTable> {
  $$AppMetaTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppMetaTableOrderingComposer
    extends Composer<_$AppDatabase, $AppMetaTable> {
  $$AppMetaTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppMetaTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppMetaTable> {
  $$AppMetaTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$AppMetaTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppMetaTable,
          AppMetaRow,
          $$AppMetaTableFilterComposer,
          $$AppMetaTableOrderingComposer,
          $$AppMetaTableAnnotationComposer,
          $$AppMetaTableCreateCompanionBuilder,
          $$AppMetaTableUpdateCompanionBuilder,
          (
            AppMetaRow,
            BaseReferences<_$AppDatabase, $AppMetaTable, AppMetaRow>,
          ),
          AppMetaRow,
          PrefetchHooks Function()
        > {
  $$AppMetaTableTableManager(_$AppDatabase db, $AppMetaTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppMetaTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppMetaTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppMetaTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => AppMetaCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback: ({
            required String key,
            required String value,
            Value<int> rowid = const Value.absent(),
          }) => AppMetaCompanion.insert(key: key, value: value, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AppMetaTable, AppMetaRow>(table),
                  BaseReferences<_$AppDatabase, $AppMetaTable, AppMetaRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppMetaTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppMetaTable,
      AppMetaRow,
      $$AppMetaTableFilterComposer,
      $$AppMetaTableOrderingComposer,
      $$AppMetaTableAnnotationComposer,
      $$AppMetaTableCreateCompanionBuilder,
      $$AppMetaTableUpdateCompanionBuilder,
      (AppMetaRow, BaseReferences<_$AppDatabase, $AppMetaTable, AppMetaRow>),
      AppMetaRow,
      PrefetchHooks Function()
    >;
typedef $$InstrumentsTableCreateCompanionBuilder =
    InstrumentsCompanion Function({
      required String code,
      required String name,
      required String type,
      Value<String?> exchange,
      Value<String?> pinyin,
      Value<String?> listDate,
      Value<Map<String, dynamic>?> extra,
      Value<int> rowid,
    });
typedef $$InstrumentsTableUpdateCompanionBuilder =
    InstrumentsCompanion Function({
      Value<String> code,
      Value<String> name,
      Value<String> type,
      Value<String?> exchange,
      Value<String?> pinyin,
      Value<String?> listDate,
      Value<Map<String, dynamic>?> extra,
      Value<int> rowid,
    });

class $$InstrumentsTableFilterComposer
    extends Composer<_$AppDatabase, $InstrumentsTable> {
  $$InstrumentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get exchange => $composableBuilder(
    column: $table.exchange,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pinyin => $composableBuilder(
    column: $table.pinyin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get listDate => $composableBuilder(
    column: $table.listDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<
    Map<String, dynamic>?,
    Map<String, dynamic>,
    String
  >
  get extra => $composableBuilder(
    column: $table.extra,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );
}

class $$InstrumentsTableOrderingComposer
    extends Composer<_$AppDatabase, $InstrumentsTable> {
  $$InstrumentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get exchange => $composableBuilder(
    column: $table.exchange,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pinyin => $composableBuilder(
    column: $table.pinyin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get listDate => $composableBuilder(
    column: $table.listDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get extra => $composableBuilder(
    column: $table.extra,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$InstrumentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $InstrumentsTable> {
  $$InstrumentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get exchange =>
      $composableBuilder(column: $table.exchange, builder: (column) => column);

  GeneratedColumn<String> get pinyin =>
      $composableBuilder(column: $table.pinyin, builder: (column) => column);

  GeneratedColumn<String> get listDate =>
      $composableBuilder(column: $table.listDate, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Map<String, dynamic>?, String> get extra =>
      $composableBuilder(column: $table.extra, builder: (column) => column);
}

class $$InstrumentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $InstrumentsTable,
          Instrument,
          $$InstrumentsTableFilterComposer,
          $$InstrumentsTableOrderingComposer,
          $$InstrumentsTableAnnotationComposer,
          $$InstrumentsTableCreateCompanionBuilder,
          $$InstrumentsTableUpdateCompanionBuilder,
          (
            Instrument,
            BaseReferences<_$AppDatabase, $InstrumentsTable, Instrument>,
          ),
          Instrument,
          PrefetchHooks Function()
        > {
  $$InstrumentsTableTableManager(_$AppDatabase db, $InstrumentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InstrumentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InstrumentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InstrumentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> code = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String?> exchange = const Value.absent(),
                Value<String?> pinyin = const Value.absent(),
                Value<String?> listDate = const Value.absent(),
                Value<Map<String, dynamic>?> extra = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InstrumentsCompanion(
                code: code,
                name: name,
                type: type,
                exchange: exchange,
                pinyin: pinyin,
                listDate: listDate,
                extra: extra,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String code,
                required String name,
                required String type,
                Value<String?> exchange = const Value.absent(),
                Value<String?> pinyin = const Value.absent(),
                Value<String?> listDate = const Value.absent(),
                Value<Map<String, dynamic>?> extra = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InstrumentsCompanion.insert(
                code: code,
                name: name,
                type: type,
                exchange: exchange,
                pinyin: pinyin,
                listDate: listDate,
                extra: extra,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$InstrumentsTable, Instrument>(table),
                  BaseReferences<_$AppDatabase, $InstrumentsTable, Instrument>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$InstrumentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $InstrumentsTable,
      Instrument,
      $$InstrumentsTableFilterComposer,
      $$InstrumentsTableOrderingComposer,
      $$InstrumentsTableAnnotationComposer,
      $$InstrumentsTableCreateCompanionBuilder,
      $$InstrumentsTableUpdateCompanionBuilder,
      (
        Instrument,
        BaseReferences<_$AppDatabase, $InstrumentsTable, Instrument>,
      ),
      Instrument,
      PrefetchHooks Function()
    >;
typedef $$TradingDaysTableCreateCompanionBuilder =
    TradingDaysCompanion Function({
      required String date,
      required bool isOpen,
      Value<String?> note,
      Value<int> rowid,
    });
typedef $$TradingDaysTableUpdateCompanionBuilder =
    TradingDaysCompanion Function({
      Value<String> date,
      Value<bool> isOpen,
      Value<String?> note,
      Value<int> rowid,
    });

class $$TradingDaysTableFilterComposer
    extends Composer<_$AppDatabase, $TradingDaysTable> {
  $$TradingDaysTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isOpen => $composableBuilder(
    column: $table.isOpen,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TradingDaysTableOrderingComposer
    extends Composer<_$AppDatabase, $TradingDaysTable> {
  $$TradingDaysTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isOpen => $composableBuilder(
    column: $table.isOpen,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TradingDaysTableAnnotationComposer
    extends Composer<_$AppDatabase, $TradingDaysTable> {
  $$TradingDaysTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<bool> get isOpen =>
      $composableBuilder(column: $table.isOpen, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);
}

class $$TradingDaysTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TradingDaysTable,
          TradingDay,
          $$TradingDaysTableFilterComposer,
          $$TradingDaysTableOrderingComposer,
          $$TradingDaysTableAnnotationComposer,
          $$TradingDaysTableCreateCompanionBuilder,
          $$TradingDaysTableUpdateCompanionBuilder,
          (
            TradingDay,
            BaseReferences<_$AppDatabase, $TradingDaysTable, TradingDay>,
          ),
          TradingDay,
          PrefetchHooks Function()
        > {
  $$TradingDaysTableTableManager(_$AppDatabase db, $TradingDaysTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TradingDaysTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TradingDaysTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TradingDaysTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> date = const Value.absent(),
                Value<bool> isOpen = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TradingDaysCompanion(
                date: date,
                isOpen: isOpen,
                note: note,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String date,
                required bool isOpen,
                Value<String?> note = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TradingDaysCompanion.insert(
                date: date,
                isOpen: isOpen,
                note: note,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TradingDaysTable, TradingDay>(table),
                  BaseReferences<_$AppDatabase, $TradingDaysTable, TradingDay>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TradingDaysTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TradingDaysTable,
      TradingDay,
      $$TradingDaysTableFilterComposer,
      $$TradingDaysTableOrderingComposer,
      $$TradingDaysTableAnnotationComposer,
      $$TradingDaysTableCreateCompanionBuilder,
      $$TradingDaysTableUpdateCompanionBuilder,
      (
        TradingDay,
        BaseReferences<_$AppDatabase, $TradingDaysTable, TradingDay>,
      ),
      TradingDay,
      PrefetchHooks Function()
    >;
typedef $$KlineCacheTableCreateCompanionBuilder = KlineCacheCompanion Function({
  required String code,
  required String period,
  required String date,
  required double open,
  required double high,
  required double low,
  required double close,
  Value<double?> volume,
  Value<double?> amount,
  Value<int> rowid,
});
typedef $$KlineCacheTableUpdateCompanionBuilder = KlineCacheCompanion Function({
  Value<String> code,
  Value<String> period,
  Value<String> date,
  Value<double> open,
  Value<double> high,
  Value<double> low,
  Value<double> close,
  Value<double?> volume,
  Value<double?> amount,
  Value<int> rowid,
});

class $$KlineCacheTableFilterComposer
    extends Composer<_$AppDatabase, $KlineCacheTable> {
  $$KlineCacheTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get period => $composableBuilder(
    column: $table.period,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get open => $composableBuilder(
    column: $table.open,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get high => $composableBuilder(
    column: $table.high,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get low => $composableBuilder(
    column: $table.low,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get close => $composableBuilder(
    column: $table.close,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get volume => $composableBuilder(
    column: $table.volume,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );
}

class $$KlineCacheTableOrderingComposer
    extends Composer<_$AppDatabase, $KlineCacheTable> {
  $$KlineCacheTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get period => $composableBuilder(
    column: $table.period,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get open => $composableBuilder(
    column: $table.open,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get high => $composableBuilder(
    column: $table.high,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get low => $composableBuilder(
    column: $table.low,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get close => $composableBuilder(
    column: $table.close,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get volume => $composableBuilder(
    column: $table.volume,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$KlineCacheTableAnnotationComposer
    extends Composer<_$AppDatabase, $KlineCacheTable> {
  $$KlineCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get period =>
      $composableBuilder(column: $table.period, builder: (column) => column);

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<double> get open =>
      $composableBuilder(column: $table.open, builder: (column) => column);

  GeneratedColumn<double> get high =>
      $composableBuilder(column: $table.high, builder: (column) => column);

  GeneratedColumn<double> get low =>
      $composableBuilder(column: $table.low, builder: (column) => column);

  GeneratedColumn<double> get close =>
      $composableBuilder(column: $table.close, builder: (column) => column);

  GeneratedColumn<double> get volume =>
      $composableBuilder(column: $table.volume, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);
}

class $$KlineCacheTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $KlineCacheTable,
          KlineBar,
          $$KlineCacheTableFilterComposer,
          $$KlineCacheTableOrderingComposer,
          $$KlineCacheTableAnnotationComposer,
          $$KlineCacheTableCreateCompanionBuilder,
          $$KlineCacheTableUpdateCompanionBuilder,
          (KlineBar, BaseReferences<_$AppDatabase, $KlineCacheTable, KlineBar>),
          KlineBar,
          PrefetchHooks Function()
        > {
  $$KlineCacheTableTableManager(_$AppDatabase db, $KlineCacheTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$KlineCacheTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$KlineCacheTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$KlineCacheTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> code = const Value.absent(),
                Value<String> period = const Value.absent(),
                Value<String> date = const Value.absent(),
                Value<double> open = const Value.absent(),
                Value<double> high = const Value.absent(),
                Value<double> low = const Value.absent(),
                Value<double> close = const Value.absent(),
                Value<double?> volume = const Value.absent(),
                Value<double?> amount = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => KlineCacheCompanion(
                code: code,
                period: period,
                date: date,
                open: open,
                high: high,
                low: low,
                close: close,
                volume: volume,
                amount: amount,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String code,
                required String period,
                required String date,
                required double open,
                required double high,
                required double low,
                required double close,
                Value<double?> volume = const Value.absent(),
                Value<double?> amount = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => KlineCacheCompanion.insert(
                code: code,
                period: period,
                date: date,
                open: open,
                high: high,
                low: low,
                close: close,
                volume: volume,
                amount: amount,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$KlineCacheTable, KlineBar>(table),
                  BaseReferences<_$AppDatabase, $KlineCacheTable, KlineBar>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$KlineCacheTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $KlineCacheTable,
      KlineBar,
      $$KlineCacheTableFilterComposer,
      $$KlineCacheTableOrderingComposer,
      $$KlineCacheTableAnnotationComposer,
      $$KlineCacheTableCreateCompanionBuilder,
      $$KlineCacheTableUpdateCompanionBuilder,
      (KlineBar, BaseReferences<_$AppDatabase, $KlineCacheTable, KlineBar>),
      KlineBar,
      PrefetchHooks Function()
    >;
typedef $$JournalEntriesTableCreateCompanionBuilder =
    JournalEntriesCompanion Function({
      required String id,
      required int createdAt,
      required int updatedAt,
      Value<int?> deletedAt,
      required String deviceId,
      required String tradeDate,
      required String session,
      required int ts,
      required String content,
      Value<String?> category,
      Value<String?> subcategory,
      Value<String?> stance,
      Value<String?> action,
      Value<String?> horizon,
      Value<String?> emotion,
      Value<List<String>> tags,
      Value<List<String>> instrumentCodes,
      Value<String?> snapshotId,
      Value<String?> templateId,
      Value<int> revisionCount,
      Value<int> rowid,
    });
typedef $$JournalEntriesTableUpdateCompanionBuilder =
    JournalEntriesCompanion Function({
      Value<String> id,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int?> deletedAt,
      Value<String> deviceId,
      Value<String> tradeDate,
      Value<String> session,
      Value<int> ts,
      Value<String> content,
      Value<String?> category,
      Value<String?> subcategory,
      Value<String?> stance,
      Value<String?> action,
      Value<String?> horizon,
      Value<String?> emotion,
      Value<List<String>> tags,
      Value<List<String>> instrumentCodes,
      Value<String?> snapshotId,
      Value<String?> templateId,
      Value<int> revisionCount,
      Value<int> rowid,
    });

class $$JournalEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $JournalEntriesTable> {
  $$JournalEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tradeDate => $composableBuilder(
    column: $table.tradeDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get session => $composableBuilder(
    column: $table.session,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ts => $composableBuilder(
    column: $table.ts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get subcategory => $composableBuilder(
    column: $table.subcategory,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get stance => $composableBuilder(
    column: $table.stance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get horizon => $composableBuilder(
    column: $table.horizon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get emotion => $composableBuilder(
    column: $table.emotion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<List<String>, List<String>, String> get tags =>
      $composableBuilder(
        column: $table.tags,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<List<String>, List<String>, String>
  get instrumentCodes => $composableBuilder(
    column: $table.instrumentCodes,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get snapshotId => $composableBuilder(
    column: $table.snapshotId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get templateId => $composableBuilder(
    column: $table.templateId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get revisionCount => $composableBuilder(
    column: $table.revisionCount,
    builder: (column) => ColumnFilters(column),
  );
}

class $$JournalEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $JournalEntriesTable> {
  $$JournalEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tradeDate => $composableBuilder(
    column: $table.tradeDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get session => $composableBuilder(
    column: $table.session,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ts => $composableBuilder(
    column: $table.ts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subcategory => $composableBuilder(
    column: $table.subcategory,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stance => $composableBuilder(
    column: $table.stance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get horizon => $composableBuilder(
    column: $table.horizon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get emotion => $composableBuilder(
    column: $table.emotion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get instrumentCodes => $composableBuilder(
    column: $table.instrumentCodes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get snapshotId => $composableBuilder(
    column: $table.snapshotId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get templateId => $composableBuilder(
    column: $table.templateId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get revisionCount => $composableBuilder(
    column: $table.revisionCount,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$JournalEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $JournalEntriesTable> {
  $$JournalEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get tradeDate =>
      $composableBuilder(column: $table.tradeDate, builder: (column) => column);

  GeneratedColumn<String> get session =>
      $composableBuilder(column: $table.session, builder: (column) => column);

  GeneratedColumn<int> get ts =>
      $composableBuilder(column: $table.ts, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get subcategory => $composableBuilder(
    column: $table.subcategory,
    builder: (column) => column,
  );

  GeneratedColumn<String> get stance =>
      $composableBuilder(column: $table.stance, builder: (column) => column);

  GeneratedColumn<String> get action =>
      $composableBuilder(column: $table.action, builder: (column) => column);

  GeneratedColumn<String> get horizon =>
      $composableBuilder(column: $table.horizon, builder: (column) => column);

  GeneratedColumn<String> get emotion =>
      $composableBuilder(column: $table.emotion, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<String>, String> get tags =>
      $composableBuilder(column: $table.tags, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<String>, String> get instrumentCodes =>
      $composableBuilder(
        column: $table.instrumentCodes,
        builder: (column) => column,
      );

  GeneratedColumn<String> get snapshotId => $composableBuilder(
    column: $table.snapshotId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get templateId => $composableBuilder(
    column: $table.templateId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get revisionCount => $composableBuilder(
    column: $table.revisionCount,
    builder: (column) => column,
  );
}

class $$JournalEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $JournalEntriesTable,
          JournalEntry,
          $$JournalEntriesTableFilterComposer,
          $$JournalEntriesTableOrderingComposer,
          $$JournalEntriesTableAnnotationComposer,
          $$JournalEntriesTableCreateCompanionBuilder,
          $$JournalEntriesTableUpdateCompanionBuilder,
          (
            JournalEntry,
            BaseReferences<_$AppDatabase, $JournalEntriesTable, JournalEntry>,
          ),
          JournalEntry,
          PrefetchHooks Function()
        > {
  $$JournalEntriesTableTableManager(
    _$AppDatabase db,
    $JournalEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$JournalEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$JournalEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$JournalEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<String> tradeDate = const Value.absent(),
                Value<String> session = const Value.absent(),
                Value<int> ts = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<String?> category = const Value.absent(),
                Value<String?> subcategory = const Value.absent(),
                Value<String?> stance = const Value.absent(),
                Value<String?> action = const Value.absent(),
                Value<String?> horizon = const Value.absent(),
                Value<String?> emotion = const Value.absent(),
                Value<List<String>> tags = const Value.absent(),
                Value<List<String>> instrumentCodes = const Value.absent(),
                Value<String?> snapshotId = const Value.absent(),
                Value<String?> templateId = const Value.absent(),
                Value<int> revisionCount = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => JournalEntriesCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                deviceId: deviceId,
                tradeDate: tradeDate,
                session: session,
                ts: ts,
                content: content,
                category: category,
                subcategory: subcategory,
                stance: stance,
                action: action,
                horizon: horizon,
                emotion: emotion,
                tags: tags,
                instrumentCodes: instrumentCodes,
                snapshotId: snapshotId,
                templateId: templateId,
                revisionCount: revisionCount,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int createdAt,
                required int updatedAt,
                Value<int?> deletedAt = const Value.absent(),
                required String deviceId,
                required String tradeDate,
                required String session,
                required int ts,
                required String content,
                Value<String?> category = const Value.absent(),
                Value<String?> subcategory = const Value.absent(),
                Value<String?> stance = const Value.absent(),
                Value<String?> action = const Value.absent(),
                Value<String?> horizon = const Value.absent(),
                Value<String?> emotion = const Value.absent(),
                Value<List<String>> tags = const Value.absent(),
                Value<List<String>> instrumentCodes = const Value.absent(),
                Value<String?> snapshotId = const Value.absent(),
                Value<String?> templateId = const Value.absent(),
                Value<int> revisionCount = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => JournalEntriesCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                deviceId: deviceId,
                tradeDate: tradeDate,
                session: session,
                ts: ts,
                content: content,
                category: category,
                subcategory: subcategory,
                stance: stance,
                action: action,
                horizon: horizon,
                emotion: emotion,
                tags: tags,
                instrumentCodes: instrumentCodes,
                snapshotId: snapshotId,
                templateId: templateId,
                revisionCount: revisionCount,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$JournalEntriesTable, JournalEntry>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $JournalEntriesTable,
                    JournalEntry
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$JournalEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $JournalEntriesTable,
      JournalEntry,
      $$JournalEntriesTableFilterComposer,
      $$JournalEntriesTableOrderingComposer,
      $$JournalEntriesTableAnnotationComposer,
      $$JournalEntriesTableCreateCompanionBuilder,
      $$JournalEntriesTableUpdateCompanionBuilder,
      (
        JournalEntry,
        BaseReferences<_$AppDatabase, $JournalEntriesTable, JournalEntry>,
      ),
      JournalEntry,
      PrefetchHooks Function()
    >;
typedef $$MarketSnapshotsTableCreateCompanionBuilder =
    MarketSnapshotsCompanion Function({
      required String id,
      required int createdAt,
      required int updatedAt,
      Value<int?> deletedAt,
      required String deviceId,
      required int ts,
      required Map<String, dynamic> indices,
      Value<Map<String, dynamic>?> breadth,
      Value<double?> turnover,
      Value<Map<String, dynamic>?> extra,
      Value<bool> isBackfilled,
      Value<int> rowid,
    });
typedef $$MarketSnapshotsTableUpdateCompanionBuilder =
    MarketSnapshotsCompanion Function({
      Value<String> id,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int?> deletedAt,
      Value<String> deviceId,
      Value<int> ts,
      Value<Map<String, dynamic>> indices,
      Value<Map<String, dynamic>?> breadth,
      Value<double?> turnover,
      Value<Map<String, dynamic>?> extra,
      Value<bool> isBackfilled,
      Value<int> rowid,
    });

class $$MarketSnapshotsTableFilterComposer
    extends Composer<_$AppDatabase, $MarketSnapshotsTable> {
  $$MarketSnapshotsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ts => $composableBuilder(
    column: $table.ts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<
    Map<String, dynamic>,
    Map<String, dynamic>,
    String
  >
  get indices => $composableBuilder(
    column: $table.indices,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<
    Map<String, dynamic>?,
    Map<String, dynamic>,
    String
  >
  get breadth => $composableBuilder(
    column: $table.breadth,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<double> get turnover => $composableBuilder(
    column: $table.turnover,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<
    Map<String, dynamic>?,
    Map<String, dynamic>,
    String
  >
  get extra => $composableBuilder(
    column: $table.extra,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<bool> get isBackfilled => $composableBuilder(
    column: $table.isBackfilled,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MarketSnapshotsTableOrderingComposer
    extends Composer<_$AppDatabase, $MarketSnapshotsTable> {
  $$MarketSnapshotsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ts => $composableBuilder(
    column: $table.ts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get indices => $composableBuilder(
    column: $table.indices,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get breadth => $composableBuilder(
    column: $table.breadth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get turnover => $composableBuilder(
    column: $table.turnover,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get extra => $composableBuilder(
    column: $table.extra,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isBackfilled => $composableBuilder(
    column: $table.isBackfilled,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MarketSnapshotsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MarketSnapshotsTable> {
  $$MarketSnapshotsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<int> get ts =>
      $composableBuilder(column: $table.ts, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Map<String, dynamic>, String> get indices =>
      $composableBuilder(column: $table.indices, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Map<String, dynamic>?, String> get breadth =>
      $composableBuilder(column: $table.breadth, builder: (column) => column);

  GeneratedColumn<double> get turnover =>
      $composableBuilder(column: $table.turnover, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Map<String, dynamic>?, String> get extra =>
      $composableBuilder(column: $table.extra, builder: (column) => column);

  GeneratedColumn<bool> get isBackfilled => $composableBuilder(
    column: $table.isBackfilled,
    builder: (column) => column,
  );
}

class $$MarketSnapshotsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MarketSnapshotsTable,
          MarketSnapshot,
          $$MarketSnapshotsTableFilterComposer,
          $$MarketSnapshotsTableOrderingComposer,
          $$MarketSnapshotsTableAnnotationComposer,
          $$MarketSnapshotsTableCreateCompanionBuilder,
          $$MarketSnapshotsTableUpdateCompanionBuilder,
          (
            MarketSnapshot,
            BaseReferences<
              _$AppDatabase,
              $MarketSnapshotsTable,
              MarketSnapshot
            >,
          ),
          MarketSnapshot,
          PrefetchHooks Function()
        > {
  $$MarketSnapshotsTableTableManager(
    _$AppDatabase db,
    $MarketSnapshotsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MarketSnapshotsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MarketSnapshotsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MarketSnapshotsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<int> ts = const Value.absent(),
                Value<Map<String, dynamic>> indices = const Value.absent(),
                Value<Map<String, dynamic>?> breadth = const Value.absent(),
                Value<double?> turnover = const Value.absent(),
                Value<Map<String, dynamic>?> extra = const Value.absent(),
                Value<bool> isBackfilled = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MarketSnapshotsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                deviceId: deviceId,
                ts: ts,
                indices: indices,
                breadth: breadth,
                turnover: turnover,
                extra: extra,
                isBackfilled: isBackfilled,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int createdAt,
                required int updatedAt,
                Value<int?> deletedAt = const Value.absent(),
                required String deviceId,
                required int ts,
                required Map<String, dynamic> indices,
                Value<Map<String, dynamic>?> breadth = const Value.absent(),
                Value<double?> turnover = const Value.absent(),
                Value<Map<String, dynamic>?> extra = const Value.absent(),
                Value<bool> isBackfilled = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MarketSnapshotsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                deviceId: deviceId,
                ts: ts,
                indices: indices,
                breadth: breadth,
                turnover: turnover,
                extra: extra,
                isBackfilled: isBackfilled,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MarketSnapshotsTable, MarketSnapshot>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $MarketSnapshotsTable,
                    MarketSnapshot
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MarketSnapshotsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MarketSnapshotsTable,
      MarketSnapshot,
      $$MarketSnapshotsTableFilterComposer,
      $$MarketSnapshotsTableOrderingComposer,
      $$MarketSnapshotsTableAnnotationComposer,
      $$MarketSnapshotsTableCreateCompanionBuilder,
      $$MarketSnapshotsTableUpdateCompanionBuilder,
      (
        MarketSnapshot,
        BaseReferences<_$AppDatabase, $MarketSnapshotsTable, MarketSnapshot>,
      ),
      MarketSnapshot,
      PrefetchHooks Function()
    >;
typedef $$AttachmentsTableCreateCompanionBuilder =
    AttachmentsCompanion Function({
      required String id,
      required int createdAt,
      required int updatedAt,
      Value<int?> deletedAt,
      required String deviceId,
      required String entryId,
      required String localPath,
      required String mime,
      required int size,
      Value<int> rowid,
    });
typedef $$AttachmentsTableUpdateCompanionBuilder =
    AttachmentsCompanion Function({
      Value<String> id,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int?> deletedAt,
      Value<String> deviceId,
      Value<String> entryId,
      Value<String> localPath,
      Value<String> mime,
      Value<int> size,
      Value<int> rowid,
    });

class $$AttachmentsTableFilterComposer
    extends Composer<_$AppDatabase, $AttachmentsTable> {
  $$AttachmentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entryId => $composableBuilder(
    column: $table.entryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mime => $composableBuilder(
    column: $table.mime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get size => $composableBuilder(
    column: $table.size,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AttachmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $AttachmentsTable> {
  $$AttachmentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entryId => $composableBuilder(
    column: $table.entryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mime => $composableBuilder(
    column: $table.mime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get size => $composableBuilder(
    column: $table.size,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AttachmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AttachmentsTable> {
  $$AttachmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get entryId =>
      $composableBuilder(column: $table.entryId, builder: (column) => column);

  GeneratedColumn<String> get localPath =>
      $composableBuilder(column: $table.localPath, builder: (column) => column);

  GeneratedColumn<String> get mime =>
      $composableBuilder(column: $table.mime, builder: (column) => column);

  GeneratedColumn<int> get size =>
      $composableBuilder(column: $table.size, builder: (column) => column);
}

class $$AttachmentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AttachmentsTable,
          Attachment,
          $$AttachmentsTableFilterComposer,
          $$AttachmentsTableOrderingComposer,
          $$AttachmentsTableAnnotationComposer,
          $$AttachmentsTableCreateCompanionBuilder,
          $$AttachmentsTableUpdateCompanionBuilder,
          (
            Attachment,
            BaseReferences<_$AppDatabase, $AttachmentsTable, Attachment>,
          ),
          Attachment,
          PrefetchHooks Function()
        > {
  $$AttachmentsTableTableManager(_$AppDatabase db, $AttachmentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AttachmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AttachmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AttachmentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<String> entryId = const Value.absent(),
                Value<String> localPath = const Value.absent(),
                Value<String> mime = const Value.absent(),
                Value<int> size = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AttachmentsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                deviceId: deviceId,
                entryId: entryId,
                localPath: localPath,
                mime: mime,
                size: size,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int createdAt,
                required int updatedAt,
                Value<int?> deletedAt = const Value.absent(),
                required String deviceId,
                required String entryId,
                required String localPath,
                required String mime,
                required int size,
                Value<int> rowid = const Value.absent(),
              }) => AttachmentsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                deviceId: deviceId,
                entryId: entryId,
                localPath: localPath,
                mime: mime,
                size: size,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AttachmentsTable, Attachment>(table),
                  BaseReferences<_$AppDatabase, $AttachmentsTable, Attachment>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AttachmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AttachmentsTable,
      Attachment,
      $$AttachmentsTableFilterComposer,
      $$AttachmentsTableOrderingComposer,
      $$AttachmentsTableAnnotationComposer,
      $$AttachmentsTableCreateCompanionBuilder,
      $$AttachmentsTableUpdateCompanionBuilder,
      (
        Attachment,
        BaseReferences<_$AppDatabase, $AttachmentsTable, Attachment>,
      ),
      Attachment,
      PrefetchHooks Function()
    >;
typedef $$QuickPhrasesTableCreateCompanionBuilder =
    QuickPhrasesCompanion Function({
      required String id,
      required int createdAt,
      required int updatedAt,
      Value<int?> deletedAt,
      required String deviceId,
      required String phrase,
      Value<String?> category,
      Value<int> sort,
      Value<int> rowid,
    });
typedef $$QuickPhrasesTableUpdateCompanionBuilder =
    QuickPhrasesCompanion Function({
      Value<String> id,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int?> deletedAt,
      Value<String> deviceId,
      Value<String> phrase,
      Value<String?> category,
      Value<int> sort,
      Value<int> rowid,
    });

class $$QuickPhrasesTableFilterComposer
    extends Composer<_$AppDatabase, $QuickPhrasesTable> {
  $$QuickPhrasesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phrase => $composableBuilder(
    column: $table.phrase,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sort => $composableBuilder(
    column: $table.sort,
    builder: (column) => ColumnFilters(column),
  );
}

class $$QuickPhrasesTableOrderingComposer
    extends Composer<_$AppDatabase, $QuickPhrasesTable> {
  $$QuickPhrasesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phrase => $composableBuilder(
    column: $table.phrase,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sort => $composableBuilder(
    column: $table.sort,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$QuickPhrasesTableAnnotationComposer
    extends Composer<_$AppDatabase, $QuickPhrasesTable> {
  $$QuickPhrasesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get phrase =>
      $composableBuilder(column: $table.phrase, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<int> get sort =>
      $composableBuilder(column: $table.sort, builder: (column) => column);
}

class $$QuickPhrasesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $QuickPhrasesTable,
          QuickPhrase,
          $$QuickPhrasesTableFilterComposer,
          $$QuickPhrasesTableOrderingComposer,
          $$QuickPhrasesTableAnnotationComposer,
          $$QuickPhrasesTableCreateCompanionBuilder,
          $$QuickPhrasesTableUpdateCompanionBuilder,
          (
            QuickPhrase,
            BaseReferences<_$AppDatabase, $QuickPhrasesTable, QuickPhrase>,
          ),
          QuickPhrase,
          PrefetchHooks Function()
        > {
  $$QuickPhrasesTableTableManager(_$AppDatabase db, $QuickPhrasesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$QuickPhrasesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$QuickPhrasesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$QuickPhrasesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<String> phrase = const Value.absent(),
                Value<String?> category = const Value.absent(),
                Value<int> sort = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => QuickPhrasesCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                deviceId: deviceId,
                phrase: phrase,
                category: category,
                sort: sort,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int createdAt,
                required int updatedAt,
                Value<int?> deletedAt = const Value.absent(),
                required String deviceId,
                required String phrase,
                Value<String?> category = const Value.absent(),
                Value<int> sort = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => QuickPhrasesCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                deviceId: deviceId,
                phrase: phrase,
                category: category,
                sort: sort,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$QuickPhrasesTable, QuickPhrase>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $QuickPhrasesTable,
                    QuickPhrase
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$QuickPhrasesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $QuickPhrasesTable,
      QuickPhrase,
      $$QuickPhrasesTableFilterComposer,
      $$QuickPhrasesTableOrderingComposer,
      $$QuickPhrasesTableAnnotationComposer,
      $$QuickPhrasesTableCreateCompanionBuilder,
      $$QuickPhrasesTableUpdateCompanionBuilder,
      (
        QuickPhrase,
        BaseReferences<_$AppDatabase, $QuickPhrasesTable, QuickPhrase>,
      ),
      QuickPhrase,
      PrefetchHooks Function()
    >;
typedef $$EntryTemplatesTableCreateCompanionBuilder =
    EntryTemplatesCompanion Function({
      required String id,
      required int createdAt,
      required int updatedAt,
      Value<int?> deletedAt,
      required String deviceId,
      required String name,
      required Map<String, dynamic> fields,
      Value<int> rowid,
    });
typedef $$EntryTemplatesTableUpdateCompanionBuilder =
    EntryTemplatesCompanion Function({
      Value<String> id,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int?> deletedAt,
      Value<String> deviceId,
      Value<String> name,
      Value<Map<String, dynamic>> fields,
      Value<int> rowid,
    });

class $$EntryTemplatesTableFilterComposer
    extends Composer<_$AppDatabase, $EntryTemplatesTable> {
  $$EntryTemplatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<
    Map<String, dynamic>,
    Map<String, dynamic>,
    String
  >
  get fields => $composableBuilder(
    column: $table.fields,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );
}

class $$EntryTemplatesTableOrderingComposer
    extends Composer<_$AppDatabase, $EntryTemplatesTable> {
  $$EntryTemplatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fields => $composableBuilder(
    column: $table.fields,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EntryTemplatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $EntryTemplatesTable> {
  $$EntryTemplatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Map<String, dynamic>, String> get fields =>
      $composableBuilder(column: $table.fields, builder: (column) => column);
}

class $$EntryTemplatesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EntryTemplatesTable,
          EntryTemplate,
          $$EntryTemplatesTableFilterComposer,
          $$EntryTemplatesTableOrderingComposer,
          $$EntryTemplatesTableAnnotationComposer,
          $$EntryTemplatesTableCreateCompanionBuilder,
          $$EntryTemplatesTableUpdateCompanionBuilder,
          (
            EntryTemplate,
            BaseReferences<_$AppDatabase, $EntryTemplatesTable, EntryTemplate>,
          ),
          EntryTemplate,
          PrefetchHooks Function()
        > {
  $$EntryTemplatesTableTableManager(
    _$AppDatabase db,
    $EntryTemplatesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EntryTemplatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EntryTemplatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EntryTemplatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<Map<String, dynamic>> fields = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EntryTemplatesCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                deviceId: deviceId,
                name: name,
                fields: fields,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int createdAt,
                required int updatedAt,
                Value<int?> deletedAt = const Value.absent(),
                required String deviceId,
                required String name,
                required Map<String, dynamic> fields,
                Value<int> rowid = const Value.absent(),
              }) => EntryTemplatesCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                deviceId: deviceId,
                name: name,
                fields: fields,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$EntryTemplatesTable, EntryTemplate>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $EntryTemplatesTable,
                    EntryTemplate
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$EntryTemplatesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EntryTemplatesTable,
      EntryTemplate,
      $$EntryTemplatesTableFilterComposer,
      $$EntryTemplatesTableOrderingComposer,
      $$EntryTemplatesTableAnnotationComposer,
      $$EntryTemplatesTableCreateCompanionBuilder,
      $$EntryTemplatesTableUpdateCompanionBuilder,
      (
        EntryTemplate,
        BaseReferences<_$AppDatabase, $EntryTemplatesTable, EntryTemplate>,
      ),
      EntryTemplate,
      PrefetchHooks Function()
    >;
typedef $$PredictionsTableCreateCompanionBuilder =
    PredictionsCompanion Function({
      required String id,
      required int createdAt,
      required int updatedAt,
      Value<int?> deletedAt,
      required String deviceId,
      Value<String?> entryId,
      required String source,
      Value<String?> analysisId,
      required String targetCode,
      required String direction,
      required String horizonType,
      required String dueDate,
      Value<double?> basePrice,
      Value<double?> targetPrice,
      Value<double?> stopPrice,
      Value<double?> rangeLow,
      Value<double?> rangeHigh,
      Value<double?> thresholdPct,
      Value<int> confidence,
      Value<int> revisionCount,
      Value<bool> modifiedBeforeDue,
      Value<int> rowid,
    });
typedef $$PredictionsTableUpdateCompanionBuilder =
    PredictionsCompanion Function({
      Value<String> id,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int?> deletedAt,
      Value<String> deviceId,
      Value<String?> entryId,
      Value<String> source,
      Value<String?> analysisId,
      Value<String> targetCode,
      Value<String> direction,
      Value<String> horizonType,
      Value<String> dueDate,
      Value<double?> basePrice,
      Value<double?> targetPrice,
      Value<double?> stopPrice,
      Value<double?> rangeLow,
      Value<double?> rangeHigh,
      Value<double?> thresholdPct,
      Value<int> confidence,
      Value<int> revisionCount,
      Value<bool> modifiedBeforeDue,
      Value<int> rowid,
    });

class $$PredictionsTableFilterComposer
    extends Composer<_$AppDatabase, $PredictionsTable> {
  $$PredictionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entryId => $composableBuilder(
    column: $table.entryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get analysisId => $composableBuilder(
    column: $table.analysisId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get targetCode => $composableBuilder(
    column: $table.targetCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get direction => $composableBuilder(
    column: $table.direction,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get horizonType => $composableBuilder(
    column: $table.horizonType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get basePrice => $composableBuilder(
    column: $table.basePrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get targetPrice => $composableBuilder(
    column: $table.targetPrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get stopPrice => $composableBuilder(
    column: $table.stopPrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get rangeLow => $composableBuilder(
    column: $table.rangeLow,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get rangeHigh => $composableBuilder(
    column: $table.rangeHigh,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get thresholdPct => $composableBuilder(
    column: $table.thresholdPct,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get revisionCount => $composableBuilder(
    column: $table.revisionCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get modifiedBeforeDue => $composableBuilder(
    column: $table.modifiedBeforeDue,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PredictionsTableOrderingComposer
    extends Composer<_$AppDatabase, $PredictionsTable> {
  $$PredictionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entryId => $composableBuilder(
    column: $table.entryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get analysisId => $composableBuilder(
    column: $table.analysisId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get targetCode => $composableBuilder(
    column: $table.targetCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get direction => $composableBuilder(
    column: $table.direction,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get horizonType => $composableBuilder(
    column: $table.horizonType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get basePrice => $composableBuilder(
    column: $table.basePrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get targetPrice => $composableBuilder(
    column: $table.targetPrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get stopPrice => $composableBuilder(
    column: $table.stopPrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get rangeLow => $composableBuilder(
    column: $table.rangeLow,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get rangeHigh => $composableBuilder(
    column: $table.rangeHigh,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get thresholdPct => $composableBuilder(
    column: $table.thresholdPct,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get revisionCount => $composableBuilder(
    column: $table.revisionCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get modifiedBeforeDue => $composableBuilder(
    column: $table.modifiedBeforeDue,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PredictionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PredictionsTable> {
  $$PredictionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get entryId =>
      $composableBuilder(column: $table.entryId, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get analysisId => $composableBuilder(
    column: $table.analysisId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get targetCode => $composableBuilder(
    column: $table.targetCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get direction =>
      $composableBuilder(column: $table.direction, builder: (column) => column);

  GeneratedColumn<String> get horizonType => $composableBuilder(
    column: $table.horizonType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumn<double> get basePrice =>
      $composableBuilder(column: $table.basePrice, builder: (column) => column);

  GeneratedColumn<double> get targetPrice => $composableBuilder(
    column: $table.targetPrice,
    builder: (column) => column,
  );

  GeneratedColumn<double> get stopPrice =>
      $composableBuilder(column: $table.stopPrice, builder: (column) => column);

  GeneratedColumn<double> get rangeLow =>
      $composableBuilder(column: $table.rangeLow, builder: (column) => column);

  GeneratedColumn<double> get rangeHigh =>
      $composableBuilder(column: $table.rangeHigh, builder: (column) => column);

  GeneratedColumn<double> get thresholdPct => $composableBuilder(
    column: $table.thresholdPct,
    builder: (column) => column,
  );

  GeneratedColumn<int> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => column,
  );

  GeneratedColumn<int> get revisionCount => $composableBuilder(
    column: $table.revisionCount,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get modifiedBeforeDue => $composableBuilder(
    column: $table.modifiedBeforeDue,
    builder: (column) => column,
  );
}

class $$PredictionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PredictionsTable,
          Prediction,
          $$PredictionsTableFilterComposer,
          $$PredictionsTableOrderingComposer,
          $$PredictionsTableAnnotationComposer,
          $$PredictionsTableCreateCompanionBuilder,
          $$PredictionsTableUpdateCompanionBuilder,
          (
            Prediction,
            BaseReferences<_$AppDatabase, $PredictionsTable, Prediction>,
          ),
          Prediction,
          PrefetchHooks Function()
        > {
  $$PredictionsTableTableManager(_$AppDatabase db, $PredictionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PredictionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PredictionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PredictionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<String?> entryId = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String?> analysisId = const Value.absent(),
                Value<String> targetCode = const Value.absent(),
                Value<String> direction = const Value.absent(),
                Value<String> horizonType = const Value.absent(),
                Value<String> dueDate = const Value.absent(),
                Value<double?> basePrice = const Value.absent(),
                Value<double?> targetPrice = const Value.absent(),
                Value<double?> stopPrice = const Value.absent(),
                Value<double?> rangeLow = const Value.absent(),
                Value<double?> rangeHigh = const Value.absent(),
                Value<double?> thresholdPct = const Value.absent(),
                Value<int> confidence = const Value.absent(),
                Value<int> revisionCount = const Value.absent(),
                Value<bool> modifiedBeforeDue = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PredictionsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                deviceId: deviceId,
                entryId: entryId,
                source: source,
                analysisId: analysisId,
                targetCode: targetCode,
                direction: direction,
                horizonType: horizonType,
                dueDate: dueDate,
                basePrice: basePrice,
                targetPrice: targetPrice,
                stopPrice: stopPrice,
                rangeLow: rangeLow,
                rangeHigh: rangeHigh,
                thresholdPct: thresholdPct,
                confidence: confidence,
                revisionCount: revisionCount,
                modifiedBeforeDue: modifiedBeforeDue,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int createdAt,
                required int updatedAt,
                Value<int?> deletedAt = const Value.absent(),
                required String deviceId,
                Value<String?> entryId = const Value.absent(),
                required String source,
                Value<String?> analysisId = const Value.absent(),
                required String targetCode,
                required String direction,
                required String horizonType,
                required String dueDate,
                Value<double?> basePrice = const Value.absent(),
                Value<double?> targetPrice = const Value.absent(),
                Value<double?> stopPrice = const Value.absent(),
                Value<double?> rangeLow = const Value.absent(),
                Value<double?> rangeHigh = const Value.absent(),
                Value<double?> thresholdPct = const Value.absent(),
                Value<int> confidence = const Value.absent(),
                Value<int> revisionCount = const Value.absent(),
                Value<bool> modifiedBeforeDue = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PredictionsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                deviceId: deviceId,
                entryId: entryId,
                source: source,
                analysisId: analysisId,
                targetCode: targetCode,
                direction: direction,
                horizonType: horizonType,
                dueDate: dueDate,
                basePrice: basePrice,
                targetPrice: targetPrice,
                stopPrice: stopPrice,
                rangeLow: rangeLow,
                rangeHigh: rangeHigh,
                thresholdPct: thresholdPct,
                confidence: confidence,
                revisionCount: revisionCount,
                modifiedBeforeDue: modifiedBeforeDue,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PredictionsTable, Prediction>(table),
                  BaseReferences<_$AppDatabase, $PredictionsTable, Prediction>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PredictionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PredictionsTable,
      Prediction,
      $$PredictionsTableFilterComposer,
      $$PredictionsTableOrderingComposer,
      $$PredictionsTableAnnotationComposer,
      $$PredictionsTableCreateCompanionBuilder,
      $$PredictionsTableUpdateCompanionBuilder,
      (
        Prediction,
        BaseReferences<_$AppDatabase, $PredictionsTable, Prediction>,
      ),
      Prediction,
      PrefetchHooks Function()
    >;
typedef $$PredictionResultsTableCreateCompanionBuilder =
    PredictionResultsCompanion Function({
      required String id,
      required int createdAt,
      required int updatedAt,
      Value<int?> deletedAt,
      required String deviceId,
      required String predictionId,
      required String status,
      Value<double?> actualClose,
      Value<double?> changePct,
      Value<double?> mfe,
      Value<double?> mae,
      required int decidedAt,
      Value<bool> isManual,
      Value<int> ruleVersion,
      Value<int> rowid,
    });
typedef $$PredictionResultsTableUpdateCompanionBuilder =
    PredictionResultsCompanion Function({
      Value<String> id,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int?> deletedAt,
      Value<String> deviceId,
      Value<String> predictionId,
      Value<String> status,
      Value<double?> actualClose,
      Value<double?> changePct,
      Value<double?> mfe,
      Value<double?> mae,
      Value<int> decidedAt,
      Value<bool> isManual,
      Value<int> ruleVersion,
      Value<int> rowid,
    });

class $$PredictionResultsTableFilterComposer
    extends Composer<_$AppDatabase, $PredictionResultsTable> {
  $$PredictionResultsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get predictionId => $composableBuilder(
    column: $table.predictionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get actualClose => $composableBuilder(
    column: $table.actualClose,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get changePct => $composableBuilder(
    column: $table.changePct,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get mfe => $composableBuilder(
    column: $table.mfe,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get mae => $composableBuilder(
    column: $table.mae,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get decidedAt => $composableBuilder(
    column: $table.decidedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isManual => $composableBuilder(
    column: $table.isManual,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ruleVersion => $composableBuilder(
    column: $table.ruleVersion,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PredictionResultsTableOrderingComposer
    extends Composer<_$AppDatabase, $PredictionResultsTable> {
  $$PredictionResultsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get predictionId => $composableBuilder(
    column: $table.predictionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get actualClose => $composableBuilder(
    column: $table.actualClose,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get changePct => $composableBuilder(
    column: $table.changePct,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get mfe => $composableBuilder(
    column: $table.mfe,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get mae => $composableBuilder(
    column: $table.mae,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get decidedAt => $composableBuilder(
    column: $table.decidedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isManual => $composableBuilder(
    column: $table.isManual,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ruleVersion => $composableBuilder(
    column: $table.ruleVersion,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PredictionResultsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PredictionResultsTable> {
  $$PredictionResultsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get predictionId => $composableBuilder(
    column: $table.predictionId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<double> get actualClose => $composableBuilder(
    column: $table.actualClose,
    builder: (column) => column,
  );

  GeneratedColumn<double> get changePct =>
      $composableBuilder(column: $table.changePct, builder: (column) => column);

  GeneratedColumn<double> get mfe =>
      $composableBuilder(column: $table.mfe, builder: (column) => column);

  GeneratedColumn<double> get mae =>
      $composableBuilder(column: $table.mae, builder: (column) => column);

  GeneratedColumn<int> get decidedAt =>
      $composableBuilder(column: $table.decidedAt, builder: (column) => column);

  GeneratedColumn<bool> get isManual =>
      $composableBuilder(column: $table.isManual, builder: (column) => column);

  GeneratedColumn<int> get ruleVersion => $composableBuilder(
    column: $table.ruleVersion,
    builder: (column) => column,
  );
}

class $$PredictionResultsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PredictionResultsTable,
          PredictionResult,
          $$PredictionResultsTableFilterComposer,
          $$PredictionResultsTableOrderingComposer,
          $$PredictionResultsTableAnnotationComposer,
          $$PredictionResultsTableCreateCompanionBuilder,
          $$PredictionResultsTableUpdateCompanionBuilder,
          (
            PredictionResult,
            BaseReferences<
              _$AppDatabase,
              $PredictionResultsTable,
              PredictionResult
            >,
          ),
          PredictionResult,
          PrefetchHooks Function()
        > {
  $$PredictionResultsTableTableManager(
    _$AppDatabase db,
    $PredictionResultsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PredictionResultsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PredictionResultsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PredictionResultsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<String> predictionId = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<double?> actualClose = const Value.absent(),
                Value<double?> changePct = const Value.absent(),
                Value<double?> mfe = const Value.absent(),
                Value<double?> mae = const Value.absent(),
                Value<int> decidedAt = const Value.absent(),
                Value<bool> isManual = const Value.absent(),
                Value<int> ruleVersion = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PredictionResultsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                deviceId: deviceId,
                predictionId: predictionId,
                status: status,
                actualClose: actualClose,
                changePct: changePct,
                mfe: mfe,
                mae: mae,
                decidedAt: decidedAt,
                isManual: isManual,
                ruleVersion: ruleVersion,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int createdAt,
                required int updatedAt,
                Value<int?> deletedAt = const Value.absent(),
                required String deviceId,
                required String predictionId,
                required String status,
                Value<double?> actualClose = const Value.absent(),
                Value<double?> changePct = const Value.absent(),
                Value<double?> mfe = const Value.absent(),
                Value<double?> mae = const Value.absent(),
                required int decidedAt,
                Value<bool> isManual = const Value.absent(),
                Value<int> ruleVersion = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PredictionResultsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                deviceId: deviceId,
                predictionId: predictionId,
                status: status,
                actualClose: actualClose,
                changePct: changePct,
                mfe: mfe,
                mae: mae,
                decidedAt: decidedAt,
                isManual: isManual,
                ruleVersion: ruleVersion,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PredictionResultsTable, PredictionResult>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $PredictionResultsTable,
                    PredictionResult
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PredictionResultsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PredictionResultsTable,
      PredictionResult,
      $$PredictionResultsTableFilterComposer,
      $$PredictionResultsTableOrderingComposer,
      $$PredictionResultsTableAnnotationComposer,
      $$PredictionResultsTableCreateCompanionBuilder,
      $$PredictionResultsTableUpdateCompanionBuilder,
      (
        PredictionResult,
        BaseReferences<
          _$AppDatabase,
          $PredictionResultsTable,
          PredictionResult
        >,
      ),
      PredictionResult,
      PrefetchHooks Function()
    >;
typedef $$ReviewNotesTableCreateCompanionBuilder =
    ReviewNotesCompanion Function({
      required String id,
      required int createdAt,
      required int updatedAt,
      Value<int?> deletedAt,
      required String deviceId,
      Value<String?> predictionId,
      Value<String?> entryId,
      required String content,
      Value<List<String>> reasons,
      Value<int> rowid,
    });
typedef $$ReviewNotesTableUpdateCompanionBuilder =
    ReviewNotesCompanion Function({
      Value<String> id,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int?> deletedAt,
      Value<String> deviceId,
      Value<String?> predictionId,
      Value<String?> entryId,
      Value<String> content,
      Value<List<String>> reasons,
      Value<int> rowid,
    });

class $$ReviewNotesTableFilterComposer
    extends Composer<_$AppDatabase, $ReviewNotesTable> {
  $$ReviewNotesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get predictionId => $composableBuilder(
    column: $table.predictionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entryId => $composableBuilder(
    column: $table.entryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<List<String>, List<String>, String>
  get reasons => $composableBuilder(
    column: $table.reasons,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );
}

class $$ReviewNotesTableOrderingComposer
    extends Composer<_$AppDatabase, $ReviewNotesTable> {
  $$ReviewNotesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get predictionId => $composableBuilder(
    column: $table.predictionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entryId => $composableBuilder(
    column: $table.entryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reasons => $composableBuilder(
    column: $table.reasons,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ReviewNotesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReviewNotesTable> {
  $$ReviewNotesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get predictionId => $composableBuilder(
    column: $table.predictionId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entryId =>
      $composableBuilder(column: $table.entryId, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<String>, String> get reasons =>
      $composableBuilder(column: $table.reasons, builder: (column) => column);
}

class $$ReviewNotesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReviewNotesTable,
          ReviewNote,
          $$ReviewNotesTableFilterComposer,
          $$ReviewNotesTableOrderingComposer,
          $$ReviewNotesTableAnnotationComposer,
          $$ReviewNotesTableCreateCompanionBuilder,
          $$ReviewNotesTableUpdateCompanionBuilder,
          (
            ReviewNote,
            BaseReferences<_$AppDatabase, $ReviewNotesTable, ReviewNote>,
          ),
          ReviewNote,
          PrefetchHooks Function()
        > {
  $$ReviewNotesTableTableManager(_$AppDatabase db, $ReviewNotesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReviewNotesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReviewNotesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReviewNotesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<String?> predictionId = const Value.absent(),
                Value<String?> entryId = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<List<String>> reasons = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReviewNotesCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                deviceId: deviceId,
                predictionId: predictionId,
                entryId: entryId,
                content: content,
                reasons: reasons,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int createdAt,
                required int updatedAt,
                Value<int?> deletedAt = const Value.absent(),
                required String deviceId,
                Value<String?> predictionId = const Value.absent(),
                Value<String?> entryId = const Value.absent(),
                required String content,
                Value<List<String>> reasons = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReviewNotesCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                deviceId: deviceId,
                predictionId: predictionId,
                entryId: entryId,
                content: content,
                reasons: reasons,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ReviewNotesTable, ReviewNote>(table),
                  BaseReferences<_$AppDatabase, $ReviewNotesTable, ReviewNote>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ReviewNotesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReviewNotesTable,
      ReviewNote,
      $$ReviewNotesTableFilterComposer,
      $$ReviewNotesTableOrderingComposer,
      $$ReviewNotesTableAnnotationComposer,
      $$ReviewNotesTableCreateCompanionBuilder,
      $$ReviewNotesTableUpdateCompanionBuilder,
      (
        ReviewNote,
        BaseReferences<_$AppDatabase, $ReviewNotesTable, ReviewNote>,
      ),
      ReviewNote,
      PrefetchHooks Function()
    >;
typedef $$ThresholdRulesTableCreateCompanionBuilder =
    ThresholdRulesCompanion Function({
      required String id,
      required int createdAt,
      required int updatedAt,
      Value<int?> deletedAt,
      required String deviceId,
      required String scope,
      Value<String?> instrumentType,
      Value<String?> horizonType,
      required double pct,
      Value<int> rowid,
    });
typedef $$ThresholdRulesTableUpdateCompanionBuilder =
    ThresholdRulesCompanion Function({
      Value<String> id,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int?> deletedAt,
      Value<String> deviceId,
      Value<String> scope,
      Value<String?> instrumentType,
      Value<String?> horizonType,
      Value<double> pct,
      Value<int> rowid,
    });

class $$ThresholdRulesTableFilterComposer
    extends Composer<_$AppDatabase, $ThresholdRulesTable> {
  $$ThresholdRulesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get scope => $composableBuilder(
    column: $table.scope,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get instrumentType => $composableBuilder(
    column: $table.instrumentType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get horizonType => $composableBuilder(
    column: $table.horizonType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get pct => $composableBuilder(
    column: $table.pct,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ThresholdRulesTableOrderingComposer
    extends Composer<_$AppDatabase, $ThresholdRulesTable> {
  $$ThresholdRulesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scope => $composableBuilder(
    column: $table.scope,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get instrumentType => $composableBuilder(
    column: $table.instrumentType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get horizonType => $composableBuilder(
    column: $table.horizonType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get pct => $composableBuilder(
    column: $table.pct,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ThresholdRulesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ThresholdRulesTable> {
  $$ThresholdRulesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get scope =>
      $composableBuilder(column: $table.scope, builder: (column) => column);

  GeneratedColumn<String> get instrumentType => $composableBuilder(
    column: $table.instrumentType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get horizonType => $composableBuilder(
    column: $table.horizonType,
    builder: (column) => column,
  );

  GeneratedColumn<double> get pct =>
      $composableBuilder(column: $table.pct, builder: (column) => column);
}

class $$ThresholdRulesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ThresholdRulesTable,
          ThresholdRule,
          $$ThresholdRulesTableFilterComposer,
          $$ThresholdRulesTableOrderingComposer,
          $$ThresholdRulesTableAnnotationComposer,
          $$ThresholdRulesTableCreateCompanionBuilder,
          $$ThresholdRulesTableUpdateCompanionBuilder,
          (
            ThresholdRule,
            BaseReferences<_$AppDatabase, $ThresholdRulesTable, ThresholdRule>,
          ),
          ThresholdRule,
          PrefetchHooks Function()
        > {
  $$ThresholdRulesTableTableManager(
    _$AppDatabase db,
    $ThresholdRulesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ThresholdRulesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ThresholdRulesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ThresholdRulesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<String> scope = const Value.absent(),
                Value<String?> instrumentType = const Value.absent(),
                Value<String?> horizonType = const Value.absent(),
                Value<double> pct = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ThresholdRulesCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                deviceId: deviceId,
                scope: scope,
                instrumentType: instrumentType,
                horizonType: horizonType,
                pct: pct,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int createdAt,
                required int updatedAt,
                Value<int?> deletedAt = const Value.absent(),
                required String deviceId,
                required String scope,
                Value<String?> instrumentType = const Value.absent(),
                Value<String?> horizonType = const Value.absent(),
                required double pct,
                Value<int> rowid = const Value.absent(),
              }) => ThresholdRulesCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                deviceId: deviceId,
                scope: scope,
                instrumentType: instrumentType,
                horizonType: horizonType,
                pct: pct,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ThresholdRulesTable, ThresholdRule>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $ThresholdRulesTable,
                    ThresholdRule
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ThresholdRulesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ThresholdRulesTable,
      ThresholdRule,
      $$ThresholdRulesTableFilterComposer,
      $$ThresholdRulesTableOrderingComposer,
      $$ThresholdRulesTableAnnotationComposer,
      $$ThresholdRulesTableCreateCompanionBuilder,
      $$ThresholdRulesTableUpdateCompanionBuilder,
      (
        ThresholdRule,
        BaseReferences<_$AppDatabase, $ThresholdRulesTable, ThresholdRule>,
      ),
      ThresholdRule,
      PrefetchHooks Function()
    >;
typedef $$RevisionsTableCreateCompanionBuilder = RevisionsCompanion Function({
  required String id,
  required int createdAt,
  required int updatedAt,
  Value<int?> deletedAt,
  required String deviceId,
  required String entityType,
  required String entityId,
  required int revisionNo,
  required Map<String, dynamic> before,
  required List<String> changedFields,
  required int ts,
  Value<int> rowid,
});
typedef $$RevisionsTableUpdateCompanionBuilder = RevisionsCompanion Function({
  Value<String> id,
  Value<int> createdAt,
  Value<int> updatedAt,
  Value<int?> deletedAt,
  Value<String> deviceId,
  Value<String> entityType,
  Value<String> entityId,
  Value<int> revisionNo,
  Value<Map<String, dynamic>> before,
  Value<List<String>> changedFields,
  Value<int> ts,
  Value<int> rowid,
});

class $$RevisionsTableFilterComposer
    extends Composer<_$AppDatabase, $RevisionsTable> {
  $$RevisionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get revisionNo => $composableBuilder(
    column: $table.revisionNo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<
    Map<String, dynamic>,
    Map<String, dynamic>,
    String
  >
  get before => $composableBuilder(
    column: $table.before,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<List<String>, List<String>, String>
  get changedFields => $composableBuilder(
    column: $table.changedFields,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get ts => $composableBuilder(
    column: $table.ts,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RevisionsTableOrderingComposer
    extends Composer<_$AppDatabase, $RevisionsTable> {
  $$RevisionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get revisionNo => $composableBuilder(
    column: $table.revisionNo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get before => $composableBuilder(
    column: $table.before,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get changedFields => $composableBuilder(
    column: $table.changedFields,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ts => $composableBuilder(
    column: $table.ts,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RevisionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RevisionsTable> {
  $$RevisionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<int> get revisionNo => $composableBuilder(
    column: $table.revisionNo,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<Map<String, dynamic>, String> get before =>
      $composableBuilder(column: $table.before, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<String>, String> get changedFields =>
      $composableBuilder(
        column: $table.changedFields,
        builder: (column) => column,
      );

  GeneratedColumn<int> get ts =>
      $composableBuilder(column: $table.ts, builder: (column) => column);
}

class $$RevisionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RevisionsTable,
          Revision,
          $$RevisionsTableFilterComposer,
          $$RevisionsTableOrderingComposer,
          $$RevisionsTableAnnotationComposer,
          $$RevisionsTableCreateCompanionBuilder,
          $$RevisionsTableUpdateCompanionBuilder,
          (Revision, BaseReferences<_$AppDatabase, $RevisionsTable, Revision>),
          Revision,
          PrefetchHooks Function()
        > {
  $$RevisionsTableTableManager(_$AppDatabase db, $RevisionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RevisionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RevisionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RevisionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<String> entityType = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<int> revisionNo = const Value.absent(),
                Value<Map<String, dynamic>> before = const Value.absent(),
                Value<List<String>> changedFields = const Value.absent(),
                Value<int> ts = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RevisionsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                deviceId: deviceId,
                entityType: entityType,
                entityId: entityId,
                revisionNo: revisionNo,
                before: before,
                changedFields: changedFields,
                ts: ts,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int createdAt,
                required int updatedAt,
                Value<int?> deletedAt = const Value.absent(),
                required String deviceId,
                required String entityType,
                required String entityId,
                required int revisionNo,
                required Map<String, dynamic> before,
                required List<String> changedFields,
                required int ts,
                Value<int> rowid = const Value.absent(),
              }) => RevisionsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                deviceId: deviceId,
                entityType: entityType,
                entityId: entityId,
                revisionNo: revisionNo,
                before: before,
                changedFields: changedFields,
                ts: ts,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RevisionsTable, Revision>(table),
                  BaseReferences<_$AppDatabase, $RevisionsTable, Revision>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RevisionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RevisionsTable,
      Revision,
      $$RevisionsTableFilterComposer,
      $$RevisionsTableOrderingComposer,
      $$RevisionsTableAnnotationComposer,
      $$RevisionsTableCreateCompanionBuilder,
      $$RevisionsTableUpdateCompanionBuilder,
      (Revision, BaseReferences<_$AppDatabase, $RevisionsTable, Revision>),
      Revision,
      PrefetchHooks Function()
    >;
typedef $$AiAnalysesTableCreateCompanionBuilder = AiAnalysesCompanion Function({
  required String id,
  required int createdAt,
  required int updatedAt,
  Value<int?> deletedAt,
  required String deviceId,
  required int ts,
  required String trigger,
  required String provider,
  required String model,
  required String promptVersion,
  Value<String?> inputDigest,
  Value<Map<String, dynamic>?> output,
  Value<String?> rawText,
  Value<int?> tokensIn,
  Value<int?> tokensOut,
  Value<int> rowid,
});
typedef $$AiAnalysesTableUpdateCompanionBuilder = AiAnalysesCompanion Function({
  Value<String> id,
  Value<int> createdAt,
  Value<int> updatedAt,
  Value<int?> deletedAt,
  Value<String> deviceId,
  Value<int> ts,
  Value<String> trigger,
  Value<String> provider,
  Value<String> model,
  Value<String> promptVersion,
  Value<String?> inputDigest,
  Value<Map<String, dynamic>?> output,
  Value<String?> rawText,
  Value<int?> tokensIn,
  Value<int?> tokensOut,
  Value<int> rowid,
});

class $$AiAnalysesTableFilterComposer
    extends Composer<_$AppDatabase, $AiAnalysesTable> {
  $$AiAnalysesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ts => $composableBuilder(
    column: $table.ts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get trigger => $composableBuilder(
    column: $table.trigger,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get provider => $composableBuilder(
    column: $table.provider,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get model => $composableBuilder(
    column: $table.model,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get promptVersion => $composableBuilder(
    column: $table.promptVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get inputDigest => $composableBuilder(
    column: $table.inputDigest,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<
    Map<String, dynamic>?,
    Map<String, dynamic>,
    String
  >
  get output => $composableBuilder(
    column: $table.output,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get rawText => $composableBuilder(
    column: $table.rawText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get tokensIn => $composableBuilder(
    column: $table.tokensIn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get tokensOut => $composableBuilder(
    column: $table.tokensOut,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AiAnalysesTableOrderingComposer
    extends Composer<_$AppDatabase, $AiAnalysesTable> {
  $$AiAnalysesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ts => $composableBuilder(
    column: $table.ts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get trigger => $composableBuilder(
    column: $table.trigger,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get provider => $composableBuilder(
    column: $table.provider,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get model => $composableBuilder(
    column: $table.model,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get promptVersion => $composableBuilder(
    column: $table.promptVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get inputDigest => $composableBuilder(
    column: $table.inputDigest,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get output => $composableBuilder(
    column: $table.output,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rawText => $composableBuilder(
    column: $table.rawText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get tokensIn => $composableBuilder(
    column: $table.tokensIn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get tokensOut => $composableBuilder(
    column: $table.tokensOut,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AiAnalysesTableAnnotationComposer
    extends Composer<_$AppDatabase, $AiAnalysesTable> {
  $$AiAnalysesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<int> get ts =>
      $composableBuilder(column: $table.ts, builder: (column) => column);

  GeneratedColumn<String> get trigger =>
      $composableBuilder(column: $table.trigger, builder: (column) => column);

  GeneratedColumn<String> get provider =>
      $composableBuilder(column: $table.provider, builder: (column) => column);

  GeneratedColumn<String> get model =>
      $composableBuilder(column: $table.model, builder: (column) => column);

  GeneratedColumn<String> get promptVersion => $composableBuilder(
    column: $table.promptVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get inputDigest => $composableBuilder(
    column: $table.inputDigest,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<Map<String, dynamic>?, String> get output =>
      $composableBuilder(column: $table.output, builder: (column) => column);

  GeneratedColumn<String> get rawText =>
      $composableBuilder(column: $table.rawText, builder: (column) => column);

  GeneratedColumn<int> get tokensIn =>
      $composableBuilder(column: $table.tokensIn, builder: (column) => column);

  GeneratedColumn<int> get tokensOut =>
      $composableBuilder(column: $table.tokensOut, builder: (column) => column);
}

class $$AiAnalysesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AiAnalysesTable,
          AiAnalysis,
          $$AiAnalysesTableFilterComposer,
          $$AiAnalysesTableOrderingComposer,
          $$AiAnalysesTableAnnotationComposer,
          $$AiAnalysesTableCreateCompanionBuilder,
          $$AiAnalysesTableUpdateCompanionBuilder,
          (
            AiAnalysis,
            BaseReferences<_$AppDatabase, $AiAnalysesTable, AiAnalysis>,
          ),
          AiAnalysis,
          PrefetchHooks Function()
        > {
  $$AiAnalysesTableTableManager(_$AppDatabase db, $AiAnalysesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AiAnalysesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AiAnalysesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AiAnalysesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<int> ts = const Value.absent(),
                Value<String> trigger = const Value.absent(),
                Value<String> provider = const Value.absent(),
                Value<String> model = const Value.absent(),
                Value<String> promptVersion = const Value.absent(),
                Value<String?> inputDigest = const Value.absent(),
                Value<Map<String, dynamic>?> output = const Value.absent(),
                Value<String?> rawText = const Value.absent(),
                Value<int?> tokensIn = const Value.absent(),
                Value<int?> tokensOut = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AiAnalysesCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                deviceId: deviceId,
                ts: ts,
                trigger: trigger,
                provider: provider,
                model: model,
                promptVersion: promptVersion,
                inputDigest: inputDigest,
                output: output,
                rawText: rawText,
                tokensIn: tokensIn,
                tokensOut: tokensOut,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int createdAt,
                required int updatedAt,
                Value<int?> deletedAt = const Value.absent(),
                required String deviceId,
                required int ts,
                required String trigger,
                required String provider,
                required String model,
                required String promptVersion,
                Value<String?> inputDigest = const Value.absent(),
                Value<Map<String, dynamic>?> output = const Value.absent(),
                Value<String?> rawText = const Value.absent(),
                Value<int?> tokensIn = const Value.absent(),
                Value<int?> tokensOut = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AiAnalysesCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                deviceId: deviceId,
                ts: ts,
                trigger: trigger,
                provider: provider,
                model: model,
                promptVersion: promptVersion,
                inputDigest: inputDigest,
                output: output,
                rawText: rawText,
                tokensIn: tokensIn,
                tokensOut: tokensOut,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AiAnalysesTable, AiAnalysis>(table),
                  BaseReferences<_$AppDatabase, $AiAnalysesTable, AiAnalysis>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AiAnalysesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AiAnalysesTable,
      AiAnalysis,
      $$AiAnalysesTableFilterComposer,
      $$AiAnalysesTableOrderingComposer,
      $$AiAnalysesTableAnnotationComposer,
      $$AiAnalysesTableCreateCompanionBuilder,
      $$AiAnalysesTableUpdateCompanionBuilder,
      (AiAnalysis, BaseReferences<_$AppDatabase, $AiAnalysesTable, AiAnalysis>),
      AiAnalysis,
      PrefetchHooks Function()
    >;
typedef $$AccountsTableCreateCompanionBuilder = AccountsCompanion Function({
  required String id,
  required int createdAt,
  required int updatedAt,
  Value<int?> deletedAt,
  required String deviceId,
  required String name,
  Value<String?> broker,
  Value<double> commissionRate,
  Value<double> minCommission,
  Value<double> stampTaxRate,
  Value<double> transferFeeRate,
  Value<int> rowid,
});
typedef $$AccountsTableUpdateCompanionBuilder = AccountsCompanion Function({
  Value<String> id,
  Value<int> createdAt,
  Value<int> updatedAt,
  Value<int?> deletedAt,
  Value<String> deviceId,
  Value<String> name,
  Value<String?> broker,
  Value<double> commissionRate,
  Value<double> minCommission,
  Value<double> stampTaxRate,
  Value<double> transferFeeRate,
  Value<int> rowid,
});

class $$AccountsTableFilterComposer
    extends Composer<_$AppDatabase, $AccountsTable> {
  $$AccountsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get broker => $composableBuilder(
    column: $table.broker,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get commissionRate => $composableBuilder(
    column: $table.commissionRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get minCommission => $composableBuilder(
    column: $table.minCommission,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get stampTaxRate => $composableBuilder(
    column: $table.stampTaxRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get transferFeeRate => $composableBuilder(
    column: $table.transferFeeRate,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AccountsTableOrderingComposer
    extends Composer<_$AppDatabase, $AccountsTable> {
  $$AccountsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get broker => $composableBuilder(
    column: $table.broker,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get commissionRate => $composableBuilder(
    column: $table.commissionRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get minCommission => $composableBuilder(
    column: $table.minCommission,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get stampTaxRate => $composableBuilder(
    column: $table.stampTaxRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get transferFeeRate => $composableBuilder(
    column: $table.transferFeeRate,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AccountsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AccountsTable> {
  $$AccountsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get broker =>
      $composableBuilder(column: $table.broker, builder: (column) => column);

  GeneratedColumn<double> get commissionRate => $composableBuilder(
    column: $table.commissionRate,
    builder: (column) => column,
  );

  GeneratedColumn<double> get minCommission => $composableBuilder(
    column: $table.minCommission,
    builder: (column) => column,
  );

  GeneratedColumn<double> get stampTaxRate => $composableBuilder(
    column: $table.stampTaxRate,
    builder: (column) => column,
  );

  GeneratedColumn<double> get transferFeeRate => $composableBuilder(
    column: $table.transferFeeRate,
    builder: (column) => column,
  );
}

class $$AccountsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AccountsTable,
          Account,
          $$AccountsTableFilterComposer,
          $$AccountsTableOrderingComposer,
          $$AccountsTableAnnotationComposer,
          $$AccountsTableCreateCompanionBuilder,
          $$AccountsTableUpdateCompanionBuilder,
          (Account, BaseReferences<_$AppDatabase, $AccountsTable, Account>),
          Account,
          PrefetchHooks Function()
        > {
  $$AccountsTableTableManager(_$AppDatabase db, $AccountsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AccountsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AccountsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AccountsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> broker = const Value.absent(),
                Value<double> commissionRate = const Value.absent(),
                Value<double> minCommission = const Value.absent(),
                Value<double> stampTaxRate = const Value.absent(),
                Value<double> transferFeeRate = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AccountsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                deviceId: deviceId,
                name: name,
                broker: broker,
                commissionRate: commissionRate,
                minCommission: minCommission,
                stampTaxRate: stampTaxRate,
                transferFeeRate: transferFeeRate,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int createdAt,
                required int updatedAt,
                Value<int?> deletedAt = const Value.absent(),
                required String deviceId,
                required String name,
                Value<String?> broker = const Value.absent(),
                Value<double> commissionRate = const Value.absent(),
                Value<double> minCommission = const Value.absent(),
                Value<double> stampTaxRate = const Value.absent(),
                Value<double> transferFeeRate = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AccountsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                deviceId: deviceId,
                name: name,
                broker: broker,
                commissionRate: commissionRate,
                minCommission: minCommission,
                stampTaxRate: stampTaxRate,
                transferFeeRate: transferFeeRate,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AccountsTable, Account>(table),
                  BaseReferences<_$AppDatabase, $AccountsTable, Account>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AccountsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AccountsTable,
      Account,
      $$AccountsTableFilterComposer,
      $$AccountsTableOrderingComposer,
      $$AccountsTableAnnotationComposer,
      $$AccountsTableCreateCompanionBuilder,
      $$AccountsTableUpdateCompanionBuilder,
      (Account, BaseReferences<_$AppDatabase, $AccountsTable, Account>),
      Account,
      PrefetchHooks Function()
    >;
typedef $$TradesTableCreateCompanionBuilder = TradesCompanion Function({
  required String id,
  required int createdAt,
  required int updatedAt,
  Value<int?> deletedAt,
  required String deviceId,
  required String accountId,
  required String instrumentCode,
  required String side,
  required int ts,
  required double price,
  required int qty,
  required double amount,
  Value<double> commission,
  Value<double> stampTax,
  Value<double> transferFee,
  Value<String?> entryId,
  required String source,
  Value<String?> importBatchId,
  Value<String?> note,
  Value<int> revisionCount,
  Value<int> rowid,
});
typedef $$TradesTableUpdateCompanionBuilder = TradesCompanion Function({
  Value<String> id,
  Value<int> createdAt,
  Value<int> updatedAt,
  Value<int?> deletedAt,
  Value<String> deviceId,
  Value<String> accountId,
  Value<String> instrumentCode,
  Value<String> side,
  Value<int> ts,
  Value<double> price,
  Value<int> qty,
  Value<double> amount,
  Value<double> commission,
  Value<double> stampTax,
  Value<double> transferFee,
  Value<String?> entryId,
  Value<String> source,
  Value<String?> importBatchId,
  Value<String?> note,
  Value<int> revisionCount,
  Value<int> rowid,
});

class $$TradesTableFilterComposer
    extends Composer<_$AppDatabase, $TradesTable> {
  $$TradesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get instrumentCode => $composableBuilder(
    column: $table.instrumentCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get side => $composableBuilder(
    column: $table.side,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ts => $composableBuilder(
    column: $table.ts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get price => $composableBuilder(
    column: $table.price,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get qty => $composableBuilder(
    column: $table.qty,
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

  ColumnFilters<double> get stampTax => $composableBuilder(
    column: $table.stampTax,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get transferFee => $composableBuilder(
    column: $table.transferFee,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entryId => $composableBuilder(
    column: $table.entryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get importBatchId => $composableBuilder(
    column: $table.importBatchId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get revisionCount => $composableBuilder(
    column: $table.revisionCount,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TradesTableOrderingComposer
    extends Composer<_$AppDatabase, $TradesTable> {
  $$TradesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get instrumentCode => $composableBuilder(
    column: $table.instrumentCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get side => $composableBuilder(
    column: $table.side,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ts => $composableBuilder(
    column: $table.ts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get price => $composableBuilder(
    column: $table.price,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get qty => $composableBuilder(
    column: $table.qty,
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

  ColumnOrderings<double> get stampTax => $composableBuilder(
    column: $table.stampTax,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get transferFee => $composableBuilder(
    column: $table.transferFee,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entryId => $composableBuilder(
    column: $table.entryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get importBatchId => $composableBuilder(
    column: $table.importBatchId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get revisionCount => $composableBuilder(
    column: $table.revisionCount,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TradesTableAnnotationComposer
    extends Composer<_$AppDatabase, $TradesTable> {
  $$TradesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get accountId =>
      $composableBuilder(column: $table.accountId, builder: (column) => column);

  GeneratedColumn<String> get instrumentCode => $composableBuilder(
    column: $table.instrumentCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get side =>
      $composableBuilder(column: $table.side, builder: (column) => column);

  GeneratedColumn<int> get ts =>
      $composableBuilder(column: $table.ts, builder: (column) => column);

  GeneratedColumn<double> get price =>
      $composableBuilder(column: $table.price, builder: (column) => column);

  GeneratedColumn<int> get qty =>
      $composableBuilder(column: $table.qty, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<double> get commission => $composableBuilder(
    column: $table.commission,
    builder: (column) => column,
  );

  GeneratedColumn<double> get stampTax =>
      $composableBuilder(column: $table.stampTax, builder: (column) => column);

  GeneratedColumn<double> get transferFee => $composableBuilder(
    column: $table.transferFee,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entryId =>
      $composableBuilder(column: $table.entryId, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get importBatchId => $composableBuilder(
    column: $table.importBatchId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<int> get revisionCount => $composableBuilder(
    column: $table.revisionCount,
    builder: (column) => column,
  );
}

class $$TradesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TradesTable,
          Trade,
          $$TradesTableFilterComposer,
          $$TradesTableOrderingComposer,
          $$TradesTableAnnotationComposer,
          $$TradesTableCreateCompanionBuilder,
          $$TradesTableUpdateCompanionBuilder,
          (Trade, BaseReferences<_$AppDatabase, $TradesTable, Trade>),
          Trade,
          PrefetchHooks Function()
        > {
  $$TradesTableTableManager(_$AppDatabase db, $TradesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TradesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TradesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TradesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<String> accountId = const Value.absent(),
                Value<String> instrumentCode = const Value.absent(),
                Value<String> side = const Value.absent(),
                Value<int> ts = const Value.absent(),
                Value<double> price = const Value.absent(),
                Value<int> qty = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<double> commission = const Value.absent(),
                Value<double> stampTax = const Value.absent(),
                Value<double> transferFee = const Value.absent(),
                Value<String?> entryId = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String?> importBatchId = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int> revisionCount = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TradesCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                deviceId: deviceId,
                accountId: accountId,
                instrumentCode: instrumentCode,
                side: side,
                ts: ts,
                price: price,
                qty: qty,
                amount: amount,
                commission: commission,
                stampTax: stampTax,
                transferFee: transferFee,
                entryId: entryId,
                source: source,
                importBatchId: importBatchId,
                note: note,
                revisionCount: revisionCount,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int createdAt,
                required int updatedAt,
                Value<int?> deletedAt = const Value.absent(),
                required String deviceId,
                required String accountId,
                required String instrumentCode,
                required String side,
                required int ts,
                required double price,
                required int qty,
                required double amount,
                Value<double> commission = const Value.absent(),
                Value<double> stampTax = const Value.absent(),
                Value<double> transferFee = const Value.absent(),
                Value<String?> entryId = const Value.absent(),
                required String source,
                Value<String?> importBatchId = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int> revisionCount = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TradesCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                deviceId: deviceId,
                accountId: accountId,
                instrumentCode: instrumentCode,
                side: side,
                ts: ts,
                price: price,
                qty: qty,
                amount: amount,
                commission: commission,
                stampTax: stampTax,
                transferFee: transferFee,
                entryId: entryId,
                source: source,
                importBatchId: importBatchId,
                note: note,
                revisionCount: revisionCount,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TradesTable, Trade>(table),
                  BaseReferences<_$AppDatabase, $TradesTable, Trade>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TradesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TradesTable,
      Trade,
      $$TradesTableFilterComposer,
      $$TradesTableOrderingComposer,
      $$TradesTableAnnotationComposer,
      $$TradesTableCreateCompanionBuilder,
      $$TradesTableUpdateCompanionBuilder,
      (Trade, BaseReferences<_$AppDatabase, $TradesTable, Trade>),
      Trade,
      PrefetchHooks Function()
    >;
typedef $$PositionSnapshotsTableCreateCompanionBuilder =
    PositionSnapshotsCompanion Function({
      required String id,
      required int createdAt,
      required int updatedAt,
      Value<int?> deletedAt,
      required String deviceId,
      required String accountId,
      required String instrumentCode,
      required String date,
      required int qty,
      required double costPrice,
      required String source,
      Value<int> revisionCount,
      Value<int> rowid,
    });
typedef $$PositionSnapshotsTableUpdateCompanionBuilder =
    PositionSnapshotsCompanion Function({
      Value<String> id,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int?> deletedAt,
      Value<String> deviceId,
      Value<String> accountId,
      Value<String> instrumentCode,
      Value<String> date,
      Value<int> qty,
      Value<double> costPrice,
      Value<String> source,
      Value<int> revisionCount,
      Value<int> rowid,
    });

class $$PositionSnapshotsTableFilterComposer
    extends Composer<_$AppDatabase, $PositionSnapshotsTable> {
  $$PositionSnapshotsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get instrumentCode => $composableBuilder(
    column: $table.instrumentCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get qty => $composableBuilder(
    column: $table.qty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get costPrice => $composableBuilder(
    column: $table.costPrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get revisionCount => $composableBuilder(
    column: $table.revisionCount,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PositionSnapshotsTableOrderingComposer
    extends Composer<_$AppDatabase, $PositionSnapshotsTable> {
  $$PositionSnapshotsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get instrumentCode => $composableBuilder(
    column: $table.instrumentCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get qty => $composableBuilder(
    column: $table.qty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get costPrice => $composableBuilder(
    column: $table.costPrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get revisionCount => $composableBuilder(
    column: $table.revisionCount,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PositionSnapshotsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PositionSnapshotsTable> {
  $$PositionSnapshotsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get accountId =>
      $composableBuilder(column: $table.accountId, builder: (column) => column);

  GeneratedColumn<String> get instrumentCode => $composableBuilder(
    column: $table.instrumentCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<int> get qty =>
      $composableBuilder(column: $table.qty, builder: (column) => column);

  GeneratedColumn<double> get costPrice =>
      $composableBuilder(column: $table.costPrice, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<int> get revisionCount => $composableBuilder(
    column: $table.revisionCount,
    builder: (column) => column,
  );
}

class $$PositionSnapshotsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PositionSnapshotsTable,
          PositionSnapshot,
          $$PositionSnapshotsTableFilterComposer,
          $$PositionSnapshotsTableOrderingComposer,
          $$PositionSnapshotsTableAnnotationComposer,
          $$PositionSnapshotsTableCreateCompanionBuilder,
          $$PositionSnapshotsTableUpdateCompanionBuilder,
          (
            PositionSnapshot,
            BaseReferences<
              _$AppDatabase,
              $PositionSnapshotsTable,
              PositionSnapshot
            >,
          ),
          PositionSnapshot,
          PrefetchHooks Function()
        > {
  $$PositionSnapshotsTableTableManager(
    _$AppDatabase db,
    $PositionSnapshotsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PositionSnapshotsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PositionSnapshotsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PositionSnapshotsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<String> accountId = const Value.absent(),
                Value<String> instrumentCode = const Value.absent(),
                Value<String> date = const Value.absent(),
                Value<int> qty = const Value.absent(),
                Value<double> costPrice = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<int> revisionCount = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PositionSnapshotsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                deviceId: deviceId,
                accountId: accountId,
                instrumentCode: instrumentCode,
                date: date,
                qty: qty,
                costPrice: costPrice,
                source: source,
                revisionCount: revisionCount,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int createdAt,
                required int updatedAt,
                Value<int?> deletedAt = const Value.absent(),
                required String deviceId,
                required String accountId,
                required String instrumentCode,
                required String date,
                required int qty,
                required double costPrice,
                required String source,
                Value<int> revisionCount = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PositionSnapshotsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                deviceId: deviceId,
                accountId: accountId,
                instrumentCode: instrumentCode,
                date: date,
                qty: qty,
                costPrice: costPrice,
                source: source,
                revisionCount: revisionCount,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PositionSnapshotsTable, PositionSnapshot>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $PositionSnapshotsTable,
                    PositionSnapshot
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PositionSnapshotsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PositionSnapshotsTable,
      PositionSnapshot,
      $$PositionSnapshotsTableFilterComposer,
      $$PositionSnapshotsTableOrderingComposer,
      $$PositionSnapshotsTableAnnotationComposer,
      $$PositionSnapshotsTableCreateCompanionBuilder,
      $$PositionSnapshotsTableUpdateCompanionBuilder,
      (
        PositionSnapshot,
        BaseReferences<
          _$AppDatabase,
          $PositionSnapshotsTable,
          PositionSnapshot
        >,
      ),
      PositionSnapshot,
      PrefetchHooks Function()
    >;
typedef $$ImportBatchesTableCreateCompanionBuilder =
    ImportBatchesCompanion Function({
      required String id,
      required int createdAt,
      required int updatedAt,
      Value<int?> deletedAt,
      required String deviceId,
      required String kind,
      Value<String?> fileName,
      Value<String?> mappingId,
      required int ts,
      Value<int> rowCount,
      required String status,
      Value<int> rowid,
    });
typedef $$ImportBatchesTableUpdateCompanionBuilder =
    ImportBatchesCompanion Function({
      Value<String> id,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int?> deletedAt,
      Value<String> deviceId,
      Value<String> kind,
      Value<String?> fileName,
      Value<String?> mappingId,
      Value<int> ts,
      Value<int> rowCount,
      Value<String> status,
      Value<int> rowid,
    });

class $$ImportBatchesTableFilterComposer
    extends Composer<_$AppDatabase, $ImportBatchesTable> {
  $$ImportBatchesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fileName => $composableBuilder(
    column: $table.fileName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mappingId => $composableBuilder(
    column: $table.mappingId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ts => $composableBuilder(
    column: $table.ts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rowCount => $composableBuilder(
    column: $table.rowCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ImportBatchesTableOrderingComposer
    extends Composer<_$AppDatabase, $ImportBatchesTable> {
  $$ImportBatchesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fileName => $composableBuilder(
    column: $table.fileName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mappingId => $composableBuilder(
    column: $table.mappingId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ts => $composableBuilder(
    column: $table.ts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rowCount => $composableBuilder(
    column: $table.rowCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ImportBatchesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ImportBatchesTable> {
  $$ImportBatchesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get fileName =>
      $composableBuilder(column: $table.fileName, builder: (column) => column);

  GeneratedColumn<String> get mappingId =>
      $composableBuilder(column: $table.mappingId, builder: (column) => column);

  GeneratedColumn<int> get ts =>
      $composableBuilder(column: $table.ts, builder: (column) => column);

  GeneratedColumn<int> get rowCount =>
      $composableBuilder(column: $table.rowCount, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);
}

class $$ImportBatchesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ImportBatchesTable,
          ImportBatch,
          $$ImportBatchesTableFilterComposer,
          $$ImportBatchesTableOrderingComposer,
          $$ImportBatchesTableAnnotationComposer,
          $$ImportBatchesTableCreateCompanionBuilder,
          $$ImportBatchesTableUpdateCompanionBuilder,
          (
            ImportBatch,
            BaseReferences<_$AppDatabase, $ImportBatchesTable, ImportBatch>,
          ),
          ImportBatch,
          PrefetchHooks Function()
        > {
  $$ImportBatchesTableTableManager(_$AppDatabase db, $ImportBatchesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ImportBatchesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ImportBatchesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ImportBatchesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String?> fileName = const Value.absent(),
                Value<String?> mappingId = const Value.absent(),
                Value<int> ts = const Value.absent(),
                Value<int> rowCount = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ImportBatchesCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                deviceId: deviceId,
                kind: kind,
                fileName: fileName,
                mappingId: mappingId,
                ts: ts,
                rowCount: rowCount,
                status: status,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int createdAt,
                required int updatedAt,
                Value<int?> deletedAt = const Value.absent(),
                required String deviceId,
                required String kind,
                Value<String?> fileName = const Value.absent(),
                Value<String?> mappingId = const Value.absent(),
                required int ts,
                Value<int> rowCount = const Value.absent(),
                required String status,
                Value<int> rowid = const Value.absent(),
              }) => ImportBatchesCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                deviceId: deviceId,
                kind: kind,
                fileName: fileName,
                mappingId: mappingId,
                ts: ts,
                rowCount: rowCount,
                status: status,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ImportBatchesTable, ImportBatch>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $ImportBatchesTable,
                    ImportBatch
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ImportBatchesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ImportBatchesTable,
      ImportBatch,
      $$ImportBatchesTableFilterComposer,
      $$ImportBatchesTableOrderingComposer,
      $$ImportBatchesTableAnnotationComposer,
      $$ImportBatchesTableCreateCompanionBuilder,
      $$ImportBatchesTableUpdateCompanionBuilder,
      (
        ImportBatch,
        BaseReferences<_$AppDatabase, $ImportBatchesTable, ImportBatch>,
      ),
      ImportBatch,
      PrefetchHooks Function()
    >;
typedef $$ColumnMappingsTableCreateCompanionBuilder =
    ColumnMappingsCompanion Function({
      required String id,
      required int createdAt,
      required int updatedAt,
      Value<int?> deletedAt,
      required String deviceId,
      required String name,
      Value<String?> broker,
      required Map<String, dynamic> mapping,
      Value<int> rowid,
    });
typedef $$ColumnMappingsTableUpdateCompanionBuilder =
    ColumnMappingsCompanion Function({
      Value<String> id,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int?> deletedAt,
      Value<String> deviceId,
      Value<String> name,
      Value<String?> broker,
      Value<Map<String, dynamic>> mapping,
      Value<int> rowid,
    });

class $$ColumnMappingsTableFilterComposer
    extends Composer<_$AppDatabase, $ColumnMappingsTable> {
  $$ColumnMappingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get broker => $composableBuilder(
    column: $table.broker,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<
    Map<String, dynamic>,
    Map<String, dynamic>,
    String
  >
  get mapping => $composableBuilder(
    column: $table.mapping,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );
}

class $$ColumnMappingsTableOrderingComposer
    extends Composer<_$AppDatabase, $ColumnMappingsTable> {
  $$ColumnMappingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get broker => $composableBuilder(
    column: $table.broker,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mapping => $composableBuilder(
    column: $table.mapping,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ColumnMappingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ColumnMappingsTable> {
  $$ColumnMappingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get broker =>
      $composableBuilder(column: $table.broker, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Map<String, dynamic>, String> get mapping =>
      $composableBuilder(column: $table.mapping, builder: (column) => column);
}

class $$ColumnMappingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ColumnMappingsTable,
          ColumnMapping,
          $$ColumnMappingsTableFilterComposer,
          $$ColumnMappingsTableOrderingComposer,
          $$ColumnMappingsTableAnnotationComposer,
          $$ColumnMappingsTableCreateCompanionBuilder,
          $$ColumnMappingsTableUpdateCompanionBuilder,
          (
            ColumnMapping,
            BaseReferences<_$AppDatabase, $ColumnMappingsTable, ColumnMapping>,
          ),
          ColumnMapping,
          PrefetchHooks Function()
        > {
  $$ColumnMappingsTableTableManager(
    _$AppDatabase db,
    $ColumnMappingsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ColumnMappingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ColumnMappingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ColumnMappingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> broker = const Value.absent(),
                Value<Map<String, dynamic>> mapping = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ColumnMappingsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                deviceId: deviceId,
                name: name,
                broker: broker,
                mapping: mapping,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int createdAt,
                required int updatedAt,
                Value<int?> deletedAt = const Value.absent(),
                required String deviceId,
                required String name,
                Value<String?> broker = const Value.absent(),
                required Map<String, dynamic> mapping,
                Value<int> rowid = const Value.absent(),
              }) => ColumnMappingsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                deviceId: deviceId,
                name: name,
                broker: broker,
                mapping: mapping,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ColumnMappingsTable, ColumnMapping>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $ColumnMappingsTable,
                    ColumnMapping
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ColumnMappingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ColumnMappingsTable,
      ColumnMapping,
      $$ColumnMappingsTableFilterComposer,
      $$ColumnMappingsTableOrderingComposer,
      $$ColumnMappingsTableAnnotationComposer,
      $$ColumnMappingsTableCreateCompanionBuilder,
      $$ColumnMappingsTableUpdateCompanionBuilder,
      (
        ColumnMapping,
        BaseReferences<_$AppDatabase, $ColumnMappingsTable, ColumnMapping>,
      ),
      ColumnMapping,
      PrefetchHooks Function()
    >;
typedef $$AgentThreadsTableCreateCompanionBuilder =
    AgentThreadsCompanion Function({
      required String id,
      required int createdAt,
      required int updatedAt,
      Value<int?> deletedAt,
      required String deviceId,
      required String title,
      Value<String?> summary,
      Value<String?> summaryUptoMessageId,
      required int lastMessageAt,
      Value<bool> pinned,
      Value<int> rowid,
    });
typedef $$AgentThreadsTableUpdateCompanionBuilder =
    AgentThreadsCompanion Function({
      Value<String> id,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int?> deletedAt,
      Value<String> deviceId,
      Value<String> title,
      Value<String?> summary,
      Value<String?> summaryUptoMessageId,
      Value<int> lastMessageAt,
      Value<bool> pinned,
      Value<int> rowid,
    });

class $$AgentThreadsTableFilterComposer
    extends Composer<_$AppDatabase, $AgentThreadsTable> {
  $$AgentThreadsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get summary => $composableBuilder(
    column: $table.summary,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get summaryUptoMessageId => $composableBuilder(
    column: $table.summaryUptoMessageId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastMessageAt => $composableBuilder(
    column: $table.lastMessageAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get pinned => $composableBuilder(
    column: $table.pinned,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AgentThreadsTableOrderingComposer
    extends Composer<_$AppDatabase, $AgentThreadsTable> {
  $$AgentThreadsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get summary => $composableBuilder(
    column: $table.summary,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get summaryUptoMessageId => $composableBuilder(
    column: $table.summaryUptoMessageId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastMessageAt => $composableBuilder(
    column: $table.lastMessageAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get pinned => $composableBuilder(
    column: $table.pinned,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AgentThreadsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AgentThreadsTable> {
  $$AgentThreadsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get summary =>
      $composableBuilder(column: $table.summary, builder: (column) => column);

  GeneratedColumn<String> get summaryUptoMessageId => $composableBuilder(
    column: $table.summaryUptoMessageId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastMessageAt => $composableBuilder(
    column: $table.lastMessageAt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get pinned =>
      $composableBuilder(column: $table.pinned, builder: (column) => column);
}

class $$AgentThreadsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AgentThreadsTable,
          AgentThread,
          $$AgentThreadsTableFilterComposer,
          $$AgentThreadsTableOrderingComposer,
          $$AgentThreadsTableAnnotationComposer,
          $$AgentThreadsTableCreateCompanionBuilder,
          $$AgentThreadsTableUpdateCompanionBuilder,
          (
            AgentThread,
            BaseReferences<_$AppDatabase, $AgentThreadsTable, AgentThread>,
          ),
          AgentThread,
          PrefetchHooks Function()
        > {
  $$AgentThreadsTableTableManager(_$AppDatabase db, $AgentThreadsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AgentThreadsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AgentThreadsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AgentThreadsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> summary = const Value.absent(),
                Value<String?> summaryUptoMessageId = const Value.absent(),
                Value<int> lastMessageAt = const Value.absent(),
                Value<bool> pinned = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AgentThreadsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                deviceId: deviceId,
                title: title,
                summary: summary,
                summaryUptoMessageId: summaryUptoMessageId,
                lastMessageAt: lastMessageAt,
                pinned: pinned,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int createdAt,
                required int updatedAt,
                Value<int?> deletedAt = const Value.absent(),
                required String deviceId,
                required String title,
                Value<String?> summary = const Value.absent(),
                Value<String?> summaryUptoMessageId = const Value.absent(),
                required int lastMessageAt,
                Value<bool> pinned = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AgentThreadsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                deviceId: deviceId,
                title: title,
                summary: summary,
                summaryUptoMessageId: summaryUptoMessageId,
                lastMessageAt: lastMessageAt,
                pinned: pinned,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AgentThreadsTable, AgentThread>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $AgentThreadsTable,
                    AgentThread
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AgentThreadsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AgentThreadsTable,
      AgentThread,
      $$AgentThreadsTableFilterComposer,
      $$AgentThreadsTableOrderingComposer,
      $$AgentThreadsTableAnnotationComposer,
      $$AgentThreadsTableCreateCompanionBuilder,
      $$AgentThreadsTableUpdateCompanionBuilder,
      (
        AgentThread,
        BaseReferences<_$AppDatabase, $AgentThreadsTable, AgentThread>,
      ),
      AgentThread,
      PrefetchHooks Function()
    >;
typedef $$AgentMessagesTableCreateCompanionBuilder =
    AgentMessagesCompanion Function({
      required String id,
      required int createdAt,
      required int updatedAt,
      Value<int?> deletedAt,
      required String deviceId,
      required String threadId,
      required String role,
      required String content,
      Value<String?> toolCalls,
      Value<String?> toolCallId,
      required int ts,
      Value<int?> tokens,
      Value<int> rowid,
    });
typedef $$AgentMessagesTableUpdateCompanionBuilder =
    AgentMessagesCompanion Function({
      Value<String> id,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int?> deletedAt,
      Value<String> deviceId,
      Value<String> threadId,
      Value<String> role,
      Value<String> content,
      Value<String?> toolCalls,
      Value<String?> toolCallId,
      Value<int> ts,
      Value<int?> tokens,
      Value<int> rowid,
    });

class $$AgentMessagesTableFilterComposer
    extends Composer<_$AppDatabase, $AgentMessagesTable> {
  $$AgentMessagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get threadId => $composableBuilder(
    column: $table.threadId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get toolCalls => $composableBuilder(
    column: $table.toolCalls,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get toolCallId => $composableBuilder(
    column: $table.toolCallId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ts => $composableBuilder(
    column: $table.ts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get tokens => $composableBuilder(
    column: $table.tokens,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AgentMessagesTableOrderingComposer
    extends Composer<_$AppDatabase, $AgentMessagesTable> {
  $$AgentMessagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get threadId => $composableBuilder(
    column: $table.threadId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get toolCalls => $composableBuilder(
    column: $table.toolCalls,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get toolCallId => $composableBuilder(
    column: $table.toolCallId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ts => $composableBuilder(
    column: $table.ts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get tokens => $composableBuilder(
    column: $table.tokens,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AgentMessagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $AgentMessagesTable> {
  $$AgentMessagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get threadId =>
      $composableBuilder(column: $table.threadId, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<String> get toolCalls =>
      $composableBuilder(column: $table.toolCalls, builder: (column) => column);

  GeneratedColumn<String> get toolCallId => $composableBuilder(
    column: $table.toolCallId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get ts =>
      $composableBuilder(column: $table.ts, builder: (column) => column);

  GeneratedColumn<int> get tokens =>
      $composableBuilder(column: $table.tokens, builder: (column) => column);
}

class $$AgentMessagesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AgentMessagesTable,
          AgentMessage,
          $$AgentMessagesTableFilterComposer,
          $$AgentMessagesTableOrderingComposer,
          $$AgentMessagesTableAnnotationComposer,
          $$AgentMessagesTableCreateCompanionBuilder,
          $$AgentMessagesTableUpdateCompanionBuilder,
          (
            AgentMessage,
            BaseReferences<_$AppDatabase, $AgentMessagesTable, AgentMessage>,
          ),
          AgentMessage,
          PrefetchHooks Function()
        > {
  $$AgentMessagesTableTableManager(_$AppDatabase db, $AgentMessagesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AgentMessagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AgentMessagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AgentMessagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<String> threadId = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<String?> toolCalls = const Value.absent(),
                Value<String?> toolCallId = const Value.absent(),
                Value<int> ts = const Value.absent(),
                Value<int?> tokens = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AgentMessagesCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                deviceId: deviceId,
                threadId: threadId,
                role: role,
                content: content,
                toolCalls: toolCalls,
                toolCallId: toolCallId,
                ts: ts,
                tokens: tokens,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int createdAt,
                required int updatedAt,
                Value<int?> deletedAt = const Value.absent(),
                required String deviceId,
                required String threadId,
                required String role,
                required String content,
                Value<String?> toolCalls = const Value.absent(),
                Value<String?> toolCallId = const Value.absent(),
                required int ts,
                Value<int?> tokens = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AgentMessagesCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                deviceId: deviceId,
                threadId: threadId,
                role: role,
                content: content,
                toolCalls: toolCalls,
                toolCallId: toolCallId,
                ts: ts,
                tokens: tokens,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AgentMessagesTable, AgentMessage>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $AgentMessagesTable,
                    AgentMessage
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AgentMessagesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AgentMessagesTable,
      AgentMessage,
      $$AgentMessagesTableFilterComposer,
      $$AgentMessagesTableOrderingComposer,
      $$AgentMessagesTableAnnotationComposer,
      $$AgentMessagesTableCreateCompanionBuilder,
      $$AgentMessagesTableUpdateCompanionBuilder,
      (
        AgentMessage,
        BaseReferences<_$AppDatabase, $AgentMessagesTable, AgentMessage>,
      ),
      AgentMessage,
      PrefetchHooks Function()
    >;
typedef $$AgentMemoriesTableCreateCompanionBuilder =
    AgentMemoriesCompanion Function({
      required String id,
      required int createdAt,
      required int updatedAt,
      Value<int?> deletedAt,
      required String deviceId,
      required String kind,
      required String content,
      required String status,
      Value<String?> sourceThreadId,
      Value<int> importance,
      Value<bool> pinned,
      Value<int?> lastUsedAt,
      Value<int> rowid,
    });
typedef $$AgentMemoriesTableUpdateCompanionBuilder =
    AgentMemoriesCompanion Function({
      Value<String> id,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int?> deletedAt,
      Value<String> deviceId,
      Value<String> kind,
      Value<String> content,
      Value<String> status,
      Value<String?> sourceThreadId,
      Value<int> importance,
      Value<bool> pinned,
      Value<int?> lastUsedAt,
      Value<int> rowid,
    });

class $$AgentMemoriesTableFilterComposer
    extends Composer<_$AppDatabase, $AgentMemoriesTable> {
  $$AgentMemoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceThreadId => $composableBuilder(
    column: $table.sourceThreadId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get importance => $composableBuilder(
    column: $table.importance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get pinned => $composableBuilder(
    column: $table.pinned,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastUsedAt => $composableBuilder(
    column: $table.lastUsedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AgentMemoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $AgentMemoriesTable> {
  $$AgentMemoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceThreadId => $composableBuilder(
    column: $table.sourceThreadId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get importance => $composableBuilder(
    column: $table.importance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get pinned => $composableBuilder(
    column: $table.pinned,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastUsedAt => $composableBuilder(
    column: $table.lastUsedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AgentMemoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $AgentMemoriesTable> {
  $$AgentMemoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get sourceThreadId => $composableBuilder(
    column: $table.sourceThreadId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get importance => $composableBuilder(
    column: $table.importance,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get pinned =>
      $composableBuilder(column: $table.pinned, builder: (column) => column);

  GeneratedColumn<int> get lastUsedAt => $composableBuilder(
    column: $table.lastUsedAt,
    builder: (column) => column,
  );
}

class $$AgentMemoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AgentMemoriesTable,
          AgentMemory,
          $$AgentMemoriesTableFilterComposer,
          $$AgentMemoriesTableOrderingComposer,
          $$AgentMemoriesTableAnnotationComposer,
          $$AgentMemoriesTableCreateCompanionBuilder,
          $$AgentMemoriesTableUpdateCompanionBuilder,
          (
            AgentMemory,
            BaseReferences<_$AppDatabase, $AgentMemoriesTable, AgentMemory>,
          ),
          AgentMemory,
          PrefetchHooks Function()
        > {
  $$AgentMemoriesTableTableManager(_$AppDatabase db, $AgentMemoriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AgentMemoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AgentMemoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AgentMemoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> sourceThreadId = const Value.absent(),
                Value<int> importance = const Value.absent(),
                Value<bool> pinned = const Value.absent(),
                Value<int?> lastUsedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AgentMemoriesCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                deviceId: deviceId,
                kind: kind,
                content: content,
                status: status,
                sourceThreadId: sourceThreadId,
                importance: importance,
                pinned: pinned,
                lastUsedAt: lastUsedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int createdAt,
                required int updatedAt,
                Value<int?> deletedAt = const Value.absent(),
                required String deviceId,
                required String kind,
                required String content,
                required String status,
                Value<String?> sourceThreadId = const Value.absent(),
                Value<int> importance = const Value.absent(),
                Value<bool> pinned = const Value.absent(),
                Value<int?> lastUsedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AgentMemoriesCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                deviceId: deviceId,
                kind: kind,
                content: content,
                status: status,
                sourceThreadId: sourceThreadId,
                importance: importance,
                pinned: pinned,
                lastUsedAt: lastUsedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AgentMemoriesTable, AgentMemory>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $AgentMemoriesTable,
                    AgentMemory
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AgentMemoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AgentMemoriesTable,
      AgentMemory,
      $$AgentMemoriesTableFilterComposer,
      $$AgentMemoriesTableOrderingComposer,
      $$AgentMemoriesTableAnnotationComposer,
      $$AgentMemoriesTableCreateCompanionBuilder,
      $$AgentMemoriesTableUpdateCompanionBuilder,
      (
        AgentMemory,
        BaseReferences<_$AppDatabase, $AgentMemoriesTable, AgentMemory>,
      ),
      AgentMemory,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$AppMetaTableTableManager get appMeta =>
      $$AppMetaTableTableManager(_db, _db.appMeta);
  $$InstrumentsTableTableManager get instruments =>
      $$InstrumentsTableTableManager(_db, _db.instruments);
  $$TradingDaysTableTableManager get tradingDays =>
      $$TradingDaysTableTableManager(_db, _db.tradingDays);
  $$KlineCacheTableTableManager get klineCache =>
      $$KlineCacheTableTableManager(_db, _db.klineCache);
  $$JournalEntriesTableTableManager get journalEntries =>
      $$JournalEntriesTableTableManager(_db, _db.journalEntries);
  $$MarketSnapshotsTableTableManager get marketSnapshots =>
      $$MarketSnapshotsTableTableManager(_db, _db.marketSnapshots);
  $$AttachmentsTableTableManager get attachments =>
      $$AttachmentsTableTableManager(_db, _db.attachments);
  $$QuickPhrasesTableTableManager get quickPhrases =>
      $$QuickPhrasesTableTableManager(_db, _db.quickPhrases);
  $$EntryTemplatesTableTableManager get entryTemplates =>
      $$EntryTemplatesTableTableManager(_db, _db.entryTemplates);
  $$PredictionsTableTableManager get predictions =>
      $$PredictionsTableTableManager(_db, _db.predictions);
  $$PredictionResultsTableTableManager get predictionResults =>
      $$PredictionResultsTableTableManager(_db, _db.predictionResults);
  $$ReviewNotesTableTableManager get reviewNotes =>
      $$ReviewNotesTableTableManager(_db, _db.reviewNotes);
  $$ThresholdRulesTableTableManager get thresholdRules =>
      $$ThresholdRulesTableTableManager(_db, _db.thresholdRules);
  $$RevisionsTableTableManager get revisions =>
      $$RevisionsTableTableManager(_db, _db.revisions);
  $$AiAnalysesTableTableManager get aiAnalyses =>
      $$AiAnalysesTableTableManager(_db, _db.aiAnalyses);
  $$AccountsTableTableManager get accounts =>
      $$AccountsTableTableManager(_db, _db.accounts);
  $$TradesTableTableManager get trades =>
      $$TradesTableTableManager(_db, _db.trades);
  $$PositionSnapshotsTableTableManager get positionSnapshots =>
      $$PositionSnapshotsTableTableManager(_db, _db.positionSnapshots);
  $$ImportBatchesTableTableManager get importBatches =>
      $$ImportBatchesTableTableManager(_db, _db.importBatches);
  $$ColumnMappingsTableTableManager get columnMappings =>
      $$ColumnMappingsTableTableManager(_db, _db.columnMappings);
  $$AgentThreadsTableTableManager get agentThreads =>
      $$AgentThreadsTableTableManager(_db, _db.agentThreads);
  $$AgentMessagesTableTableManager get agentMessages =>
      $$AgentMessagesTableTableManager(_db, _db.agentMessages);
  $$AgentMemoriesTableTableManager get agentMemories =>
      $$AgentMemoriesTableTableManager(_db, _db.agentMemories);
}
