// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $LocalCategoriesTable extends LocalCategories
    with TableInfo<$LocalCategoriesTable, LocalCategory> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalCategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _defaultLabelMeta = const VerificationMeta(
    'defaultLabel',
  );
  @override
  late final GeneratedColumn<String> defaultLabel = GeneratedColumn<String>(
    'default_label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iconKeyMeta = const VerificationMeta(
    'iconKey',
  );
  @override
  late final GeneratedColumn<String> iconKey = GeneratedColumn<String>(
    'icon_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
    'color',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
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
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    code,
    defaultLabel,
    label,
    iconKey,
    color,
    sortOrder,
    isActive,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalCategory> instance, {
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
    if (data.containsKey('default_label')) {
      context.handle(
        _defaultLabelMeta,
        defaultLabel.isAcceptableOrUnknown(
          data['default_label']!,
          _defaultLabelMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_defaultLabelMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('icon_key')) {
      context.handle(
        _iconKeyMeta,
        iconKey.isAcceptableOrUnknown(data['icon_key']!, _iconKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_iconKeyMeta);
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    } else if (isInserting) {
      context.missing(_colorMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    } else if (isInserting) {
      context.missing(_sortOrderMeta);
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {code};
  @override
  LocalCategory map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalCategory(
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      )!,
      defaultLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}default_label'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      iconKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon_key'],
      )!,
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $LocalCategoriesTable createAlias(String alias) {
    return $LocalCategoriesTable(attachedDatabase, alias);
  }
}

class LocalCategory extends DataClass implements Insertable<LocalCategory> {
  final String code;
  final String defaultLabel;
  final String label;
  final String iconKey;
  final String color;
  final int sortOrder;
  final bool isActive;
  final DateTime updatedAt;
  const LocalCategory({
    required this.code,
    required this.defaultLabel,
    required this.label,
    required this.iconKey,
    required this.color,
    required this.sortOrder,
    required this.isActive,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['code'] = Variable<String>(code);
    map['default_label'] = Variable<String>(defaultLabel);
    map['label'] = Variable<String>(label);
    map['icon_key'] = Variable<String>(iconKey);
    map['color'] = Variable<String>(color);
    map['sort_order'] = Variable<int>(sortOrder);
    map['is_active'] = Variable<bool>(isActive);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  LocalCategoriesCompanion toCompanion(bool nullToAbsent) {
    return LocalCategoriesCompanion(
      code: Value(code),
      defaultLabel: Value(defaultLabel),
      label: Value(label),
      iconKey: Value(iconKey),
      color: Value(color),
      sortOrder: Value(sortOrder),
      isActive: Value(isActive),
      updatedAt: Value(updatedAt),
    );
  }

  factory LocalCategory.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalCategory(
      code: serializer.fromJson<String>(json['code']),
      defaultLabel: serializer.fromJson<String>(json['defaultLabel']),
      label: serializer.fromJson<String>(json['label']),
      iconKey: serializer.fromJson<String>(json['iconKey']),
      color: serializer.fromJson<String>(json['color']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'code': serializer.toJson<String>(code),
      'defaultLabel': serializer.toJson<String>(defaultLabel),
      'label': serializer.toJson<String>(label),
      'iconKey': serializer.toJson<String>(iconKey),
      'color': serializer.toJson<String>(color),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'isActive': serializer.toJson<bool>(isActive),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  LocalCategory copyWith({
    String? code,
    String? defaultLabel,
    String? label,
    String? iconKey,
    String? color,
    int? sortOrder,
    bool? isActive,
    DateTime? updatedAt,
  }) => LocalCategory(
    code: code ?? this.code,
    defaultLabel: defaultLabel ?? this.defaultLabel,
    label: label ?? this.label,
    iconKey: iconKey ?? this.iconKey,
    color: color ?? this.color,
    sortOrder: sortOrder ?? this.sortOrder,
    isActive: isActive ?? this.isActive,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  LocalCategory copyWithCompanion(LocalCategoriesCompanion data) {
    return LocalCategory(
      code: data.code.present ? data.code.value : this.code,
      defaultLabel: data.defaultLabel.present
          ? data.defaultLabel.value
          : this.defaultLabel,
      label: data.label.present ? data.label.value : this.label,
      iconKey: data.iconKey.present ? data.iconKey.value : this.iconKey,
      color: data.color.present ? data.color.value : this.color,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalCategory(')
          ..write('code: $code, ')
          ..write('defaultLabel: $defaultLabel, ')
          ..write('label: $label, ')
          ..write('iconKey: $iconKey, ')
          ..write('color: $color, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('isActive: $isActive, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    code,
    defaultLabel,
    label,
    iconKey,
    color,
    sortOrder,
    isActive,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalCategory &&
          other.code == this.code &&
          other.defaultLabel == this.defaultLabel &&
          other.label == this.label &&
          other.iconKey == this.iconKey &&
          other.color == this.color &&
          other.sortOrder == this.sortOrder &&
          other.isActive == this.isActive &&
          other.updatedAt == this.updatedAt);
}

class LocalCategoriesCompanion extends UpdateCompanion<LocalCategory> {
  final Value<String> code;
  final Value<String> defaultLabel;
  final Value<String> label;
  final Value<String> iconKey;
  final Value<String> color;
  final Value<int> sortOrder;
  final Value<bool> isActive;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const LocalCategoriesCompanion({
    this.code = const Value.absent(),
    this.defaultLabel = const Value.absent(),
    this.label = const Value.absent(),
    this.iconKey = const Value.absent(),
    this.color = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.isActive = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalCategoriesCompanion.insert({
    required String code,
    required String defaultLabel,
    required String label,
    required String iconKey,
    required String color,
    required int sortOrder,
    this.isActive = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : code = Value(code),
       defaultLabel = Value(defaultLabel),
       label = Value(label),
       iconKey = Value(iconKey),
       color = Value(color),
       sortOrder = Value(sortOrder),
       updatedAt = Value(updatedAt);
  static Insertable<LocalCategory> custom({
    Expression<String>? code,
    Expression<String>? defaultLabel,
    Expression<String>? label,
    Expression<String>? iconKey,
    Expression<String>? color,
    Expression<int>? sortOrder,
    Expression<bool>? isActive,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (code != null) 'code': code,
      if (defaultLabel != null) 'default_label': defaultLabel,
      if (label != null) 'label': label,
      if (iconKey != null) 'icon_key': iconKey,
      if (color != null) 'color': color,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (isActive != null) 'is_active': isActive,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalCategoriesCompanion copyWith({
    Value<String>? code,
    Value<String>? defaultLabel,
    Value<String>? label,
    Value<String>? iconKey,
    Value<String>? color,
    Value<int>? sortOrder,
    Value<bool>? isActive,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return LocalCategoriesCompanion(
      code: code ?? this.code,
      defaultLabel: defaultLabel ?? this.defaultLabel,
      label: label ?? this.label,
      iconKey: iconKey ?? this.iconKey,
      color: color ?? this.color,
      sortOrder: sortOrder ?? this.sortOrder,
      isActive: isActive ?? this.isActive,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (defaultLabel.present) {
      map['default_label'] = Variable<String>(defaultLabel.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (iconKey.present) {
      map['icon_key'] = Variable<String>(iconKey.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalCategoriesCompanion(')
          ..write('code: $code, ')
          ..write('defaultLabel: $defaultLabel, ')
          ..write('label: $label, ')
          ..write('iconKey: $iconKey, ')
          ..write('color: $color, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('isActive: $isActive, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalTransactionsTable extends LocalTransactions
    with TableInfo<$LocalTransactionsTable, LocalTransaction> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalTransactionsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _serverIdMeta = const VerificationMeta(
    'serverId',
  );
  @override
  late final GeneratedColumn<int> serverId = GeneratedColumn<int>(
    'server_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _clientIdMeta = const VerificationMeta(
    'clientId',
  );
  @override
  late final GeneratedColumn<String> clientId = GeneratedColumn<String>(
    'client_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryCodeMeta = const VerificationMeta(
    'categoryCode',
  );
  @override
  late final GeneratedColumn<String> categoryCode = GeneratedColumn<String>(
    'category_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES local_categories (code)',
    ),
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _originalAmountMeta = const VerificationMeta(
    'originalAmount',
  );
  @override
  late final GeneratedColumn<double> originalAmount = GeneratedColumn<double>(
    'original_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _originalCurrencyMeta = const VerificationMeta(
    'originalCurrency',
  );
  @override
  late final GeneratedColumn<String> originalCurrency = GeneratedColumn<String>(
    'original_currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _baseAmountMeta = const VerificationMeta(
    'baseAmount',
  );
  @override
  late final GeneratedColumn<double> baseAmount = GeneratedColumn<double>(
    'base_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _baseCurrencyMeta = const VerificationMeta(
    'baseCurrency',
  );
  @override
  late final GeneratedColumn<String> baseCurrency = GeneratedColumn<String>(
    'base_currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _transactionDateMeta = const VerificationMeta(
    'transactionDate',
  );
  @override
  late final GeneratedColumn<DateTime> transactionDate =
      GeneratedColumn<DateTime>(
        'transaction_date',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
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
    requiredDuringInsert: true,
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
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isSyncedMeta = const VerificationMeta(
    'isSynced',
  );
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
    'is_synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _pendingActionMeta = const VerificationMeta(
    'pendingAction',
  );
  @override
  late final GeneratedColumn<String> pendingAction = GeneratedColumn<String>(
    'pending_action',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    serverId,
    clientId,
    categoryCode,
    description,
    originalAmount,
    originalCurrency,
    baseAmount,
    baseCurrency,
    transactionDate,
    createdAt,
    updatedAt,
    isSynced,
    pendingAction,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_transactions';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalTransaction> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('server_id')) {
      context.handle(
        _serverIdMeta,
        serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta),
      );
    }
    if (data.containsKey('client_id')) {
      context.handle(
        _clientIdMeta,
        clientId.isAcceptableOrUnknown(data['client_id']!, _clientIdMeta),
      );
    } else if (isInserting) {
      context.missing(_clientIdMeta);
    }
    if (data.containsKey('category_code')) {
      context.handle(
        _categoryCodeMeta,
        categoryCode.isAcceptableOrUnknown(
          data['category_code']!,
          _categoryCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_categoryCodeMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('original_amount')) {
      context.handle(
        _originalAmountMeta,
        originalAmount.isAcceptableOrUnknown(
          data['original_amount']!,
          _originalAmountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_originalAmountMeta);
    }
    if (data.containsKey('original_currency')) {
      context.handle(
        _originalCurrencyMeta,
        originalCurrency.isAcceptableOrUnknown(
          data['original_currency']!,
          _originalCurrencyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_originalCurrencyMeta);
    }
    if (data.containsKey('base_amount')) {
      context.handle(
        _baseAmountMeta,
        baseAmount.isAcceptableOrUnknown(data['base_amount']!, _baseAmountMeta),
      );
    } else if (isInserting) {
      context.missing(_baseAmountMeta);
    }
    if (data.containsKey('base_currency')) {
      context.handle(
        _baseCurrencyMeta,
        baseCurrency.isAcceptableOrUnknown(
          data['base_currency']!,
          _baseCurrencyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_baseCurrencyMeta);
    }
    if (data.containsKey('transaction_date')) {
      context.handle(
        _transactionDateMeta,
        transactionDate.isAcceptableOrUnknown(
          data['transaction_date']!,
          _transactionDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_transactionDateMeta);
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
    if (data.containsKey('is_synced')) {
      context.handle(
        _isSyncedMeta,
        isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta),
      );
    }
    if (data.containsKey('pending_action')) {
      context.handle(
        _pendingActionMeta,
        pendingAction.isAcceptableOrUnknown(
          data['pending_action']!,
          _pendingActionMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalTransaction map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalTransaction(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      serverId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_id'],
      ),
      clientId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}client_id'],
      )!,
      categoryCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_code'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      originalAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}original_amount'],
      )!,
      originalCurrency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}original_currency'],
      )!,
      baseAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}base_amount'],
      )!,
      baseCurrency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}base_currency'],
      )!,
      transactionDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}transaction_date'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      isSynced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_synced'],
      )!,
      pendingAction: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pending_action'],
      ),
    );
  }

  @override
  $LocalTransactionsTable createAlias(String alias) {
    return $LocalTransactionsTable(attachedDatabase, alias);
  }
}

class LocalTransaction extends DataClass
    implements Insertable<LocalTransaction> {
  final int id;
  final int? serverId;
  final String clientId;
  final String categoryCode;
  final String description;
  final double originalAmount;
  final String originalCurrency;
  final double baseAmount;
  final String baseCurrency;
  final DateTime transactionDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isSynced;
  final String? pendingAction;
  const LocalTransaction({
    required this.id,
    this.serverId,
    required this.clientId,
    required this.categoryCode,
    required this.description,
    required this.originalAmount,
    required this.originalCurrency,
    required this.baseAmount,
    required this.baseCurrency,
    required this.transactionDate,
    required this.createdAt,
    required this.updatedAt,
    required this.isSynced,
    this.pendingAction,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<int>(serverId);
    }
    map['client_id'] = Variable<String>(clientId);
    map['category_code'] = Variable<String>(categoryCode);
    map['description'] = Variable<String>(description);
    map['original_amount'] = Variable<double>(originalAmount);
    map['original_currency'] = Variable<String>(originalCurrency);
    map['base_amount'] = Variable<double>(baseAmount);
    map['base_currency'] = Variable<String>(baseCurrency);
    map['transaction_date'] = Variable<DateTime>(transactionDate);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_synced'] = Variable<bool>(isSynced);
    if (!nullToAbsent || pendingAction != null) {
      map['pending_action'] = Variable<String>(pendingAction);
    }
    return map;
  }

  LocalTransactionsCompanion toCompanion(bool nullToAbsent) {
    return LocalTransactionsCompanion(
      id: Value(id),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      clientId: Value(clientId),
      categoryCode: Value(categoryCode),
      description: Value(description),
      originalAmount: Value(originalAmount),
      originalCurrency: Value(originalCurrency),
      baseAmount: Value(baseAmount),
      baseCurrency: Value(baseCurrency),
      transactionDate: Value(transactionDate),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isSynced: Value(isSynced),
      pendingAction: pendingAction == null && nullToAbsent
          ? const Value.absent()
          : Value(pendingAction),
    );
  }

  factory LocalTransaction.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalTransaction(
      id: serializer.fromJson<int>(json['id']),
      serverId: serializer.fromJson<int?>(json['serverId']),
      clientId: serializer.fromJson<String>(json['clientId']),
      categoryCode: serializer.fromJson<String>(json['categoryCode']),
      description: serializer.fromJson<String>(json['description']),
      originalAmount: serializer.fromJson<double>(json['originalAmount']),
      originalCurrency: serializer.fromJson<String>(json['originalCurrency']),
      baseAmount: serializer.fromJson<double>(json['baseAmount']),
      baseCurrency: serializer.fromJson<String>(json['baseCurrency']),
      transactionDate: serializer.fromJson<DateTime>(json['transactionDate']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
      pendingAction: serializer.fromJson<String?>(json['pendingAction']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'serverId': serializer.toJson<int?>(serverId),
      'clientId': serializer.toJson<String>(clientId),
      'categoryCode': serializer.toJson<String>(categoryCode),
      'description': serializer.toJson<String>(description),
      'originalAmount': serializer.toJson<double>(originalAmount),
      'originalCurrency': serializer.toJson<String>(originalCurrency),
      'baseAmount': serializer.toJson<double>(baseAmount),
      'baseCurrency': serializer.toJson<String>(baseCurrency),
      'transactionDate': serializer.toJson<DateTime>(transactionDate),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isSynced': serializer.toJson<bool>(isSynced),
      'pendingAction': serializer.toJson<String?>(pendingAction),
    };
  }

  LocalTransaction copyWith({
    int? id,
    Value<int?> serverId = const Value.absent(),
    String? clientId,
    String? categoryCode,
    String? description,
    double? originalAmount,
    String? originalCurrency,
    double? baseAmount,
    String? baseCurrency,
    DateTime? transactionDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSynced,
    Value<String?> pendingAction = const Value.absent(),
  }) => LocalTransaction(
    id: id ?? this.id,
    serverId: serverId.present ? serverId.value : this.serverId,
    clientId: clientId ?? this.clientId,
    categoryCode: categoryCode ?? this.categoryCode,
    description: description ?? this.description,
    originalAmount: originalAmount ?? this.originalAmount,
    originalCurrency: originalCurrency ?? this.originalCurrency,
    baseAmount: baseAmount ?? this.baseAmount,
    baseCurrency: baseCurrency ?? this.baseCurrency,
    transactionDate: transactionDate ?? this.transactionDate,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    isSynced: isSynced ?? this.isSynced,
    pendingAction: pendingAction.present
        ? pendingAction.value
        : this.pendingAction,
  );
  LocalTransaction copyWithCompanion(LocalTransactionsCompanion data) {
    return LocalTransaction(
      id: data.id.present ? data.id.value : this.id,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      clientId: data.clientId.present ? data.clientId.value : this.clientId,
      categoryCode: data.categoryCode.present
          ? data.categoryCode.value
          : this.categoryCode,
      description: data.description.present
          ? data.description.value
          : this.description,
      originalAmount: data.originalAmount.present
          ? data.originalAmount.value
          : this.originalAmount,
      originalCurrency: data.originalCurrency.present
          ? data.originalCurrency.value
          : this.originalCurrency,
      baseAmount: data.baseAmount.present
          ? data.baseAmount.value
          : this.baseAmount,
      baseCurrency: data.baseCurrency.present
          ? data.baseCurrency.value
          : this.baseCurrency,
      transactionDate: data.transactionDate.present
          ? data.transactionDate.value
          : this.transactionDate,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
      pendingAction: data.pendingAction.present
          ? data.pendingAction.value
          : this.pendingAction,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalTransaction(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('clientId: $clientId, ')
          ..write('categoryCode: $categoryCode, ')
          ..write('description: $description, ')
          ..write('originalAmount: $originalAmount, ')
          ..write('originalCurrency: $originalCurrency, ')
          ..write('baseAmount: $baseAmount, ')
          ..write('baseCurrency: $baseCurrency, ')
          ..write('transactionDate: $transactionDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isSynced: $isSynced, ')
          ..write('pendingAction: $pendingAction')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    serverId,
    clientId,
    categoryCode,
    description,
    originalAmount,
    originalCurrency,
    baseAmount,
    baseCurrency,
    transactionDate,
    createdAt,
    updatedAt,
    isSynced,
    pendingAction,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalTransaction &&
          other.id == this.id &&
          other.serverId == this.serverId &&
          other.clientId == this.clientId &&
          other.categoryCode == this.categoryCode &&
          other.description == this.description &&
          other.originalAmount == this.originalAmount &&
          other.originalCurrency == this.originalCurrency &&
          other.baseAmount == this.baseAmount &&
          other.baseCurrency == this.baseCurrency &&
          other.transactionDate == this.transactionDate &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isSynced == this.isSynced &&
          other.pendingAction == this.pendingAction);
}

class LocalTransactionsCompanion extends UpdateCompanion<LocalTransaction> {
  final Value<int> id;
  final Value<int?> serverId;
  final Value<String> clientId;
  final Value<String> categoryCode;
  final Value<String> description;
  final Value<double> originalAmount;
  final Value<String> originalCurrency;
  final Value<double> baseAmount;
  final Value<String> baseCurrency;
  final Value<DateTime> transactionDate;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> isSynced;
  final Value<String?> pendingAction;
  const LocalTransactionsCompanion({
    this.id = const Value.absent(),
    this.serverId = const Value.absent(),
    this.clientId = const Value.absent(),
    this.categoryCode = const Value.absent(),
    this.description = const Value.absent(),
    this.originalAmount = const Value.absent(),
    this.originalCurrency = const Value.absent(),
    this.baseAmount = const Value.absent(),
    this.baseCurrency = const Value.absent(),
    this.transactionDate = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.pendingAction = const Value.absent(),
  });
  LocalTransactionsCompanion.insert({
    this.id = const Value.absent(),
    this.serverId = const Value.absent(),
    required String clientId,
    required String categoryCode,
    this.description = const Value.absent(),
    required double originalAmount,
    required String originalCurrency,
    required double baseAmount,
    required String baseCurrency,
    required DateTime transactionDate,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.isSynced = const Value.absent(),
    this.pendingAction = const Value.absent(),
  }) : clientId = Value(clientId),
       categoryCode = Value(categoryCode),
       originalAmount = Value(originalAmount),
       originalCurrency = Value(originalCurrency),
       baseAmount = Value(baseAmount),
       baseCurrency = Value(baseCurrency),
       transactionDate = Value(transactionDate),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<LocalTransaction> custom({
    Expression<int>? id,
    Expression<int>? serverId,
    Expression<String>? clientId,
    Expression<String>? categoryCode,
    Expression<String>? description,
    Expression<double>? originalAmount,
    Expression<String>? originalCurrency,
    Expression<double>? baseAmount,
    Expression<String>? baseCurrency,
    Expression<DateTime>? transactionDate,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isSynced,
    Expression<String>? pendingAction,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (serverId != null) 'server_id': serverId,
      if (clientId != null) 'client_id': clientId,
      if (categoryCode != null) 'category_code': categoryCode,
      if (description != null) 'description': description,
      if (originalAmount != null) 'original_amount': originalAmount,
      if (originalCurrency != null) 'original_currency': originalCurrency,
      if (baseAmount != null) 'base_amount': baseAmount,
      if (baseCurrency != null) 'base_currency': baseCurrency,
      if (transactionDate != null) 'transaction_date': transactionDate,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isSynced != null) 'is_synced': isSynced,
      if (pendingAction != null) 'pending_action': pendingAction,
    });
  }

  LocalTransactionsCompanion copyWith({
    Value<int>? id,
    Value<int?>? serverId,
    Value<String>? clientId,
    Value<String>? categoryCode,
    Value<String>? description,
    Value<double>? originalAmount,
    Value<String>? originalCurrency,
    Value<double>? baseAmount,
    Value<String>? baseCurrency,
    Value<DateTime>? transactionDate,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<bool>? isSynced,
    Value<String?>? pendingAction,
  }) {
    return LocalTransactionsCompanion(
      id: id ?? this.id,
      serverId: serverId ?? this.serverId,
      clientId: clientId ?? this.clientId,
      categoryCode: categoryCode ?? this.categoryCode,
      description: description ?? this.description,
      originalAmount: originalAmount ?? this.originalAmount,
      originalCurrency: originalCurrency ?? this.originalCurrency,
      baseAmount: baseAmount ?? this.baseAmount,
      baseCurrency: baseCurrency ?? this.baseCurrency,
      transactionDate: transactionDate ?? this.transactionDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
      pendingAction: pendingAction ?? this.pendingAction,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<int>(serverId.value);
    }
    if (clientId.present) {
      map['client_id'] = Variable<String>(clientId.value);
    }
    if (categoryCode.present) {
      map['category_code'] = Variable<String>(categoryCode.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (originalAmount.present) {
      map['original_amount'] = Variable<double>(originalAmount.value);
    }
    if (originalCurrency.present) {
      map['original_currency'] = Variable<String>(originalCurrency.value);
    }
    if (baseAmount.present) {
      map['base_amount'] = Variable<double>(baseAmount.value);
    }
    if (baseCurrency.present) {
      map['base_currency'] = Variable<String>(baseCurrency.value);
    }
    if (transactionDate.present) {
      map['transaction_date'] = Variable<DateTime>(transactionDate.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (pendingAction.present) {
      map['pending_action'] = Variable<String>(pendingAction.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalTransactionsCompanion(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('clientId: $clientId, ')
          ..write('categoryCode: $categoryCode, ')
          ..write('description: $description, ')
          ..write('originalAmount: $originalAmount, ')
          ..write('originalCurrency: $originalCurrency, ')
          ..write('baseAmount: $baseAmount, ')
          ..write('baseCurrency: $baseCurrency, ')
          ..write('transactionDate: $transactionDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isSynced: $isSynced, ')
          ..write('pendingAction: $pendingAction')
          ..write(')'))
        .toString();
  }
}

class $LocalUserSettingsTable extends LocalUserSettings
    with TableInfo<$LocalUserSettingsTable, LocalUserSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalUserSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _preferredLanguageMeta = const VerificationMeta(
    'preferredLanguage',
  );
  @override
  late final GeneratedColumn<String> preferredLanguage =
      GeneratedColumn<String>(
        'preferred_language',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('en'),
      );
  static const VerificationMeta _preferredCurrencyMeta = const VerificationMeta(
    'preferredCurrency',
  );
  @override
  late final GeneratedColumn<String> preferredCurrency =
      GeneratedColumn<String>(
        'preferred_currency',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('PLN'),
      );
  static const VerificationMeta _monthlyBudgetMeta = const VerificationMeta(
    'monthlyBudget',
  );
  @override
  late final GeneratedColumn<double> monthlyBudget = GeneratedColumn<double>(
    'monthly_budget',
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
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isDirtyMeta = const VerificationMeta(
    'isDirty',
  );
  @override
  late final GeneratedColumn<bool> isDirty = GeneratedColumn<bool>(
    'is_dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_dirty" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    preferredLanguage,
    preferredCurrency,
    monthlyBudget,
    updatedAt,
    isDirty,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_user_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalUserSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('preferred_language')) {
      context.handle(
        _preferredLanguageMeta,
        preferredLanguage.isAcceptableOrUnknown(
          data['preferred_language']!,
          _preferredLanguageMeta,
        ),
      );
    }
    if (data.containsKey('preferred_currency')) {
      context.handle(
        _preferredCurrencyMeta,
        preferredCurrency.isAcceptableOrUnknown(
          data['preferred_currency']!,
          _preferredCurrencyMeta,
        ),
      );
    }
    if (data.containsKey('monthly_budget')) {
      context.handle(
        _monthlyBudgetMeta,
        monthlyBudget.isAcceptableOrUnknown(
          data['monthly_budget']!,
          _monthlyBudgetMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('is_dirty')) {
      context.handle(
        _isDirtyMeta,
        isDirty.isAcceptableOrUnknown(data['is_dirty']!, _isDirtyMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalUserSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalUserSetting(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      preferredLanguage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}preferred_language'],
      )!,
      preferredCurrency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}preferred_currency'],
      )!,
      monthlyBudget: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}monthly_budget'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      isDirty: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_dirty'],
      )!,
    );
  }

  @override
  $LocalUserSettingsTable createAlias(String alias) {
    return $LocalUserSettingsTable(attachedDatabase, alias);
  }
}

class LocalUserSetting extends DataClass
    implements Insertable<LocalUserSetting> {
  final int id;
  final String preferredLanguage;
  final String preferredCurrency;
  final double monthlyBudget;
  final DateTime updatedAt;
  final bool isDirty;
  const LocalUserSetting({
    required this.id,
    required this.preferredLanguage,
    required this.preferredCurrency,
    required this.monthlyBudget,
    required this.updatedAt,
    required this.isDirty,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['preferred_language'] = Variable<String>(preferredLanguage);
    map['preferred_currency'] = Variable<String>(preferredCurrency);
    map['monthly_budget'] = Variable<double>(monthlyBudget);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_dirty'] = Variable<bool>(isDirty);
    return map;
  }

  LocalUserSettingsCompanion toCompanion(bool nullToAbsent) {
    return LocalUserSettingsCompanion(
      id: Value(id),
      preferredLanguage: Value(preferredLanguage),
      preferredCurrency: Value(preferredCurrency),
      monthlyBudget: Value(monthlyBudget),
      updatedAt: Value(updatedAt),
      isDirty: Value(isDirty),
    );
  }

  factory LocalUserSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalUserSetting(
      id: serializer.fromJson<int>(json['id']),
      preferredLanguage: serializer.fromJson<String>(json['preferredLanguage']),
      preferredCurrency: serializer.fromJson<String>(json['preferredCurrency']),
      monthlyBudget: serializer.fromJson<double>(json['monthlyBudget']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      isDirty: serializer.fromJson<bool>(json['isDirty']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'preferredLanguage': serializer.toJson<String>(preferredLanguage),
      'preferredCurrency': serializer.toJson<String>(preferredCurrency),
      'monthlyBudget': serializer.toJson<double>(monthlyBudget),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isDirty': serializer.toJson<bool>(isDirty),
    };
  }

  LocalUserSetting copyWith({
    int? id,
    String? preferredLanguage,
    String? preferredCurrency,
    double? monthlyBudget,
    DateTime? updatedAt,
    bool? isDirty,
  }) => LocalUserSetting(
    id: id ?? this.id,
    preferredLanguage: preferredLanguage ?? this.preferredLanguage,
    preferredCurrency: preferredCurrency ?? this.preferredCurrency,
    monthlyBudget: monthlyBudget ?? this.monthlyBudget,
    updatedAt: updatedAt ?? this.updatedAt,
    isDirty: isDirty ?? this.isDirty,
  );
  LocalUserSetting copyWithCompanion(LocalUserSettingsCompanion data) {
    return LocalUserSetting(
      id: data.id.present ? data.id.value : this.id,
      preferredLanguage: data.preferredLanguage.present
          ? data.preferredLanguage.value
          : this.preferredLanguage,
      preferredCurrency: data.preferredCurrency.present
          ? data.preferredCurrency.value
          : this.preferredCurrency,
      monthlyBudget: data.monthlyBudget.present
          ? data.monthlyBudget.value
          : this.monthlyBudget,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isDirty: data.isDirty.present ? data.isDirty.value : this.isDirty,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalUserSetting(')
          ..write('id: $id, ')
          ..write('preferredLanguage: $preferredLanguage, ')
          ..write('preferredCurrency: $preferredCurrency, ')
          ..write('monthlyBudget: $monthlyBudget, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDirty: $isDirty')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    preferredLanguage,
    preferredCurrency,
    monthlyBudget,
    updatedAt,
    isDirty,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalUserSetting &&
          other.id == this.id &&
          other.preferredLanguage == this.preferredLanguage &&
          other.preferredCurrency == this.preferredCurrency &&
          other.monthlyBudget == this.monthlyBudget &&
          other.updatedAt == this.updatedAt &&
          other.isDirty == this.isDirty);
}

class LocalUserSettingsCompanion extends UpdateCompanion<LocalUserSetting> {
  final Value<int> id;
  final Value<String> preferredLanguage;
  final Value<String> preferredCurrency;
  final Value<double> monthlyBudget;
  final Value<DateTime> updatedAt;
  final Value<bool> isDirty;
  const LocalUserSettingsCompanion({
    this.id = const Value.absent(),
    this.preferredLanguage = const Value.absent(),
    this.preferredCurrency = const Value.absent(),
    this.monthlyBudget = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDirty = const Value.absent(),
  });
  LocalUserSettingsCompanion.insert({
    this.id = const Value.absent(),
    this.preferredLanguage = const Value.absent(),
    this.preferredCurrency = const Value.absent(),
    this.monthlyBudget = const Value.absent(),
    required DateTime updatedAt,
    this.isDirty = const Value.absent(),
  }) : updatedAt = Value(updatedAt);
  static Insertable<LocalUserSetting> custom({
    Expression<int>? id,
    Expression<String>? preferredLanguage,
    Expression<String>? preferredCurrency,
    Expression<double>? monthlyBudget,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isDirty,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (preferredLanguage != null) 'preferred_language': preferredLanguage,
      if (preferredCurrency != null) 'preferred_currency': preferredCurrency,
      if (monthlyBudget != null) 'monthly_budget': monthlyBudget,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isDirty != null) 'is_dirty': isDirty,
    });
  }

  LocalUserSettingsCompanion copyWith({
    Value<int>? id,
    Value<String>? preferredLanguage,
    Value<String>? preferredCurrency,
    Value<double>? monthlyBudget,
    Value<DateTime>? updatedAt,
    Value<bool>? isDirty,
  }) {
    return LocalUserSettingsCompanion(
      id: id ?? this.id,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      preferredCurrency: preferredCurrency ?? this.preferredCurrency,
      monthlyBudget: monthlyBudget ?? this.monthlyBudget,
      updatedAt: updatedAt ?? this.updatedAt,
      isDirty: isDirty ?? this.isDirty,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (preferredLanguage.present) {
      map['preferred_language'] = Variable<String>(preferredLanguage.value);
    }
    if (preferredCurrency.present) {
      map['preferred_currency'] = Variable<String>(preferredCurrency.value);
    }
    if (monthlyBudget.present) {
      map['monthly_budget'] = Variable<double>(monthlyBudget.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isDirty.present) {
      map['is_dirty'] = Variable<bool>(isDirty.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalUserSettingsCompanion(')
          ..write('id: $id, ')
          ..write('preferredLanguage: $preferredLanguage, ')
          ..write('preferredCurrency: $preferredCurrency, ')
          ..write('monthlyBudget: $monthlyBudget, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDirty: $isDirty')
          ..write(')'))
        .toString();
  }
}

class $SyncMetadataTable extends SyncMetadata
    with TableInfo<$SyncMetadataTable, SyncMetadataData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncMetadataTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _lastSyncTimestampMeta = const VerificationMeta(
    'lastSyncTimestamp',
  );
  @override
  late final GeneratedColumn<DateTime> lastSyncTimestamp =
      GeneratedColumn<DateTime>(
        'last_sync_timestamp',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [id, lastSyncTimestamp];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_metadata';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncMetadataData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('last_sync_timestamp')) {
      context.handle(
        _lastSyncTimestampMeta,
        lastSyncTimestamp.isAcceptableOrUnknown(
          data['last_sync_timestamp']!,
          _lastSyncTimestampMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncMetadataData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncMetadataData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      lastSyncTimestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_sync_timestamp'],
      ),
    );
  }

  @override
  $SyncMetadataTable createAlias(String alias) {
    return $SyncMetadataTable(attachedDatabase, alias);
  }
}

class SyncMetadataData extends DataClass
    implements Insertable<SyncMetadataData> {
  final int id;
  final DateTime? lastSyncTimestamp;
  const SyncMetadataData({required this.id, this.lastSyncTimestamp});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || lastSyncTimestamp != null) {
      map['last_sync_timestamp'] = Variable<DateTime>(lastSyncTimestamp);
    }
    return map;
  }

  SyncMetadataCompanion toCompanion(bool nullToAbsent) {
    return SyncMetadataCompanion(
      id: Value(id),
      lastSyncTimestamp: lastSyncTimestamp == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncTimestamp),
    );
  }

  factory SyncMetadataData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncMetadataData(
      id: serializer.fromJson<int>(json['id']),
      lastSyncTimestamp: serializer.fromJson<DateTime?>(
        json['lastSyncTimestamp'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'lastSyncTimestamp': serializer.toJson<DateTime?>(lastSyncTimestamp),
    };
  }

  SyncMetadataData copyWith({
    int? id,
    Value<DateTime?> lastSyncTimestamp = const Value.absent(),
  }) => SyncMetadataData(
    id: id ?? this.id,
    lastSyncTimestamp: lastSyncTimestamp.present
        ? lastSyncTimestamp.value
        : this.lastSyncTimestamp,
  );
  SyncMetadataData copyWithCompanion(SyncMetadataCompanion data) {
    return SyncMetadataData(
      id: data.id.present ? data.id.value : this.id,
      lastSyncTimestamp: data.lastSyncTimestamp.present
          ? data.lastSyncTimestamp.value
          : this.lastSyncTimestamp,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncMetadataData(')
          ..write('id: $id, ')
          ..write('lastSyncTimestamp: $lastSyncTimestamp')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, lastSyncTimestamp);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncMetadataData &&
          other.id == this.id &&
          other.lastSyncTimestamp == this.lastSyncTimestamp);
}

class SyncMetadataCompanion extends UpdateCompanion<SyncMetadataData> {
  final Value<int> id;
  final Value<DateTime?> lastSyncTimestamp;
  const SyncMetadataCompanion({
    this.id = const Value.absent(),
    this.lastSyncTimestamp = const Value.absent(),
  });
  SyncMetadataCompanion.insert({
    this.id = const Value.absent(),
    this.lastSyncTimestamp = const Value.absent(),
  });
  static Insertable<SyncMetadataData> custom({
    Expression<int>? id,
    Expression<DateTime>? lastSyncTimestamp,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (lastSyncTimestamp != null) 'last_sync_timestamp': lastSyncTimestamp,
    });
  }

  SyncMetadataCompanion copyWith({
    Value<int>? id,
    Value<DateTime?>? lastSyncTimestamp,
  }) {
    return SyncMetadataCompanion(
      id: id ?? this.id,
      lastSyncTimestamp: lastSyncTimestamp ?? this.lastSyncTimestamp,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (lastSyncTimestamp.present) {
      map['last_sync_timestamp'] = Variable<DateTime>(lastSyncTimestamp.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncMetadataCompanion(')
          ..write('id: $id, ')
          ..write('lastSyncTimestamp: $lastSyncTimestamp')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $LocalCategoriesTable localCategories = $LocalCategoriesTable(
    this,
  );
  late final $LocalTransactionsTable localTransactions =
      $LocalTransactionsTable(this);
  late final $LocalUserSettingsTable localUserSettings =
      $LocalUserSettingsTable(this);
  late final $SyncMetadataTable syncMetadata = $SyncMetadataTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    localCategories,
    localTransactions,
    localUserSettings,
    syncMetadata,
  ];
}

typedef $$LocalCategoriesTableCreateCompanionBuilder =
    LocalCategoriesCompanion Function({
      required String code,
      required String defaultLabel,
      required String label,
      required String iconKey,
      required String color,
      required int sortOrder,
      Value<bool> isActive,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$LocalCategoriesTableUpdateCompanionBuilder =
    LocalCategoriesCompanion Function({
      Value<String> code,
      Value<String> defaultLabel,
      Value<String> label,
      Value<String> iconKey,
      Value<String> color,
      Value<int> sortOrder,
      Value<bool> isActive,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$LocalCategoriesTableReferences
    extends
        BaseReferences<_$AppDatabase, $LocalCategoriesTable, LocalCategory> {
  $$LocalCategoriesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$LocalTransactionsTable, List<LocalTransaction>>
  _localTransactionsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.localTransactions,
        aliasName: $_aliasNameGenerator(
          db.localCategories.code,
          db.localTransactions.categoryCode,
        ),
      );

  $$LocalTransactionsTableProcessedTableManager get localTransactionsRefs {
    final manager =
        $$LocalTransactionsTableTableManager(
          $_db,
          $_db.localTransactions,
        ).filter(
          (f) => f.categoryCode.code.sqlEquals($_itemColumn<String>('code')!),
        );

    final cache = $_typedResult.readTableOrNull(
      _localTransactionsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$LocalCategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $LocalCategoriesTable> {
  $$LocalCategoriesTableFilterComposer({
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

  ColumnFilters<String> get defaultLabel => $composableBuilder(
    column: $table.defaultLabel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get iconKey => $composableBuilder(
    column: $table.iconKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> localTransactionsRefs(
    Expression<bool> Function($$LocalTransactionsTableFilterComposer f) f,
  ) {
    final $$LocalTransactionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.code,
      referencedTable: $db.localTransactions,
      getReferencedColumn: (t) => t.categoryCode,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalTransactionsTableFilterComposer(
            $db: $db,
            $table: $db.localTransactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$LocalCategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalCategoriesTable> {
  $$LocalCategoriesTableOrderingComposer({
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

  ColumnOrderings<String> get defaultLabel => $composableBuilder(
    column: $table.defaultLabel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get iconKey => $composableBuilder(
    column: $table.iconKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalCategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalCategoriesTable> {
  $$LocalCategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get defaultLabel => $composableBuilder(
    column: $table.defaultLabel,
    builder: (column) => column,
  );

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<String> get iconKey =>
      $composableBuilder(column: $table.iconKey, builder: (column) => column);

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> localTransactionsRefs<T extends Object>(
    Expression<T> Function($$LocalTransactionsTableAnnotationComposer a) f,
  ) {
    final $$LocalTransactionsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.code,
          referencedTable: $db.localTransactions,
          getReferencedColumn: (t) => t.categoryCode,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$LocalTransactionsTableAnnotationComposer(
                $db: $db,
                $table: $db.localTransactions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$LocalCategoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalCategoriesTable,
          LocalCategory,
          $$LocalCategoriesTableFilterComposer,
          $$LocalCategoriesTableOrderingComposer,
          $$LocalCategoriesTableAnnotationComposer,
          $$LocalCategoriesTableCreateCompanionBuilder,
          $$LocalCategoriesTableUpdateCompanionBuilder,
          (LocalCategory, $$LocalCategoriesTableReferences),
          LocalCategory,
          PrefetchHooks Function({bool localTransactionsRefs})
        > {
  $$LocalCategoriesTableTableManager(
    _$AppDatabase db,
    $LocalCategoriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalCategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalCategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalCategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> code = const Value.absent(),
                Value<String> defaultLabel = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<String> iconKey = const Value.absent(),
                Value<String> color = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalCategoriesCompanion(
                code: code,
                defaultLabel: defaultLabel,
                label: label,
                iconKey: iconKey,
                color: color,
                sortOrder: sortOrder,
                isActive: isActive,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String code,
                required String defaultLabel,
                required String label,
                required String iconKey,
                required String color,
                required int sortOrder,
                Value<bool> isActive = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => LocalCategoriesCompanion.insert(
                code: code,
                defaultLabel: defaultLabel,
                label: label,
                iconKey: iconKey,
                color: color,
                sortOrder: sortOrder,
                isActive: isActive,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$LocalCategoriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({localTransactionsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (localTransactionsRefs) db.localTransactions,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (localTransactionsRefs)
                    await $_getPrefetchedData<
                      LocalCategory,
                      $LocalCategoriesTable,
                      LocalTransaction
                    >(
                      currentTable: table,
                      referencedTable: $$LocalCategoriesTableReferences
                          ._localTransactionsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$LocalCategoriesTableReferences(
                            db,
                            table,
                            p0,
                          ).localTransactionsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.categoryCode == item.code,
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

typedef $$LocalCategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalCategoriesTable,
      LocalCategory,
      $$LocalCategoriesTableFilterComposer,
      $$LocalCategoriesTableOrderingComposer,
      $$LocalCategoriesTableAnnotationComposer,
      $$LocalCategoriesTableCreateCompanionBuilder,
      $$LocalCategoriesTableUpdateCompanionBuilder,
      (LocalCategory, $$LocalCategoriesTableReferences),
      LocalCategory,
      PrefetchHooks Function({bool localTransactionsRefs})
    >;
typedef $$LocalTransactionsTableCreateCompanionBuilder =
    LocalTransactionsCompanion Function({
      Value<int> id,
      Value<int?> serverId,
      required String clientId,
      required String categoryCode,
      Value<String> description,
      required double originalAmount,
      required String originalCurrency,
      required double baseAmount,
      required String baseCurrency,
      required DateTime transactionDate,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<bool> isSynced,
      Value<String?> pendingAction,
    });
typedef $$LocalTransactionsTableUpdateCompanionBuilder =
    LocalTransactionsCompanion Function({
      Value<int> id,
      Value<int?> serverId,
      Value<String> clientId,
      Value<String> categoryCode,
      Value<String> description,
      Value<double> originalAmount,
      Value<String> originalCurrency,
      Value<double> baseAmount,
      Value<String> baseCurrency,
      Value<DateTime> transactionDate,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<bool> isSynced,
      Value<String?> pendingAction,
    });

final class $$LocalTransactionsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $LocalTransactionsTable,
          LocalTransaction
        > {
  $$LocalTransactionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $LocalCategoriesTable _categoryCodeTable(_$AppDatabase db) =>
      db.localCategories.createAlias(
        $_aliasNameGenerator(
          db.localTransactions.categoryCode,
          db.localCategories.code,
        ),
      );

  $$LocalCategoriesTableProcessedTableManager get categoryCode {
    final $_column = $_itemColumn<String>('category_code')!;

    final manager = $$LocalCategoriesTableTableManager(
      $_db,
      $_db.localCategories,
    ).filter((f) => f.code.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryCodeTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$LocalTransactionsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalTransactionsTable> {
  $$LocalTransactionsTableFilterComposer({
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

  ColumnFilters<int> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get clientId => $composableBuilder(
    column: $table.clientId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get originalAmount => $composableBuilder(
    column: $table.originalAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get originalCurrency => $composableBuilder(
    column: $table.originalCurrency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get baseAmount => $composableBuilder(
    column: $table.baseAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get baseCurrency => $composableBuilder(
    column: $table.baseCurrency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get transactionDate => $composableBuilder(
    column: $table.transactionDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pendingAction => $composableBuilder(
    column: $table.pendingAction,
    builder: (column) => ColumnFilters(column),
  );

  $$LocalCategoriesTableFilterComposer get categoryCode {
    final $$LocalCategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryCode,
      referencedTable: $db.localCategories,
      getReferencedColumn: (t) => t.code,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalCategoriesTableFilterComposer(
            $db: $db,
            $table: $db.localCategories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LocalTransactionsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalTransactionsTable> {
  $$LocalTransactionsTableOrderingComposer({
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

  ColumnOrderings<int> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get clientId => $composableBuilder(
    column: $table.clientId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get originalAmount => $composableBuilder(
    column: $table.originalAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get originalCurrency => $composableBuilder(
    column: $table.originalCurrency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get baseAmount => $composableBuilder(
    column: $table.baseAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get baseCurrency => $composableBuilder(
    column: $table.baseCurrency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get transactionDate => $composableBuilder(
    column: $table.transactionDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pendingAction => $composableBuilder(
    column: $table.pendingAction,
    builder: (column) => ColumnOrderings(column),
  );

  $$LocalCategoriesTableOrderingComposer get categoryCode {
    final $$LocalCategoriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryCode,
      referencedTable: $db.localCategories,
      getReferencedColumn: (t) => t.code,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalCategoriesTableOrderingComposer(
            $db: $db,
            $table: $db.localCategories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LocalTransactionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalTransactionsTable> {
  $$LocalTransactionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<String> get clientId =>
      $composableBuilder(column: $table.clientId, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<double> get originalAmount => $composableBuilder(
    column: $table.originalAmount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get originalCurrency => $composableBuilder(
    column: $table.originalCurrency,
    builder: (column) => column,
  );

  GeneratedColumn<double> get baseAmount => $composableBuilder(
    column: $table.baseAmount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get baseCurrency => $composableBuilder(
    column: $table.baseCurrency,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get transactionDate => $composableBuilder(
    column: $table.transactionDate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  GeneratedColumn<String> get pendingAction => $composableBuilder(
    column: $table.pendingAction,
    builder: (column) => column,
  );

  $$LocalCategoriesTableAnnotationComposer get categoryCode {
    final $$LocalCategoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryCode,
      referencedTable: $db.localCategories,
      getReferencedColumn: (t) => t.code,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalCategoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.localCategories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LocalTransactionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalTransactionsTable,
          LocalTransaction,
          $$LocalTransactionsTableFilterComposer,
          $$LocalTransactionsTableOrderingComposer,
          $$LocalTransactionsTableAnnotationComposer,
          $$LocalTransactionsTableCreateCompanionBuilder,
          $$LocalTransactionsTableUpdateCompanionBuilder,
          (LocalTransaction, $$LocalTransactionsTableReferences),
          LocalTransaction,
          PrefetchHooks Function({bool categoryCode})
        > {
  $$LocalTransactionsTableTableManager(
    _$AppDatabase db,
    $LocalTransactionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalTransactionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalTransactionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalTransactionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> serverId = const Value.absent(),
                Value<String> clientId = const Value.absent(),
                Value<String> categoryCode = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<double> originalAmount = const Value.absent(),
                Value<String> originalCurrency = const Value.absent(),
                Value<double> baseAmount = const Value.absent(),
                Value<String> baseCurrency = const Value.absent(),
                Value<DateTime> transactionDate = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
                Value<String?> pendingAction = const Value.absent(),
              }) => LocalTransactionsCompanion(
                id: id,
                serverId: serverId,
                clientId: clientId,
                categoryCode: categoryCode,
                description: description,
                originalAmount: originalAmount,
                originalCurrency: originalCurrency,
                baseAmount: baseAmount,
                baseCurrency: baseCurrency,
                transactionDate: transactionDate,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isSynced: isSynced,
                pendingAction: pendingAction,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> serverId = const Value.absent(),
                required String clientId,
                required String categoryCode,
                Value<String> description = const Value.absent(),
                required double originalAmount,
                required String originalCurrency,
                required double baseAmount,
                required String baseCurrency,
                required DateTime transactionDate,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<bool> isSynced = const Value.absent(),
                Value<String?> pendingAction = const Value.absent(),
              }) => LocalTransactionsCompanion.insert(
                id: id,
                serverId: serverId,
                clientId: clientId,
                categoryCode: categoryCode,
                description: description,
                originalAmount: originalAmount,
                originalCurrency: originalCurrency,
                baseAmount: baseAmount,
                baseCurrency: baseCurrency,
                transactionDate: transactionDate,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isSynced: isSynced,
                pendingAction: pendingAction,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$LocalTransactionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({categoryCode = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
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
                    if (categoryCode) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.categoryCode,
                                referencedTable:
                                    $$LocalTransactionsTableReferences
                                        ._categoryCodeTable(db),
                                referencedColumn:
                                    $$LocalTransactionsTableReferences
                                        ._categoryCodeTable(db)
                                        .code,
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

typedef $$LocalTransactionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalTransactionsTable,
      LocalTransaction,
      $$LocalTransactionsTableFilterComposer,
      $$LocalTransactionsTableOrderingComposer,
      $$LocalTransactionsTableAnnotationComposer,
      $$LocalTransactionsTableCreateCompanionBuilder,
      $$LocalTransactionsTableUpdateCompanionBuilder,
      (LocalTransaction, $$LocalTransactionsTableReferences),
      LocalTransaction,
      PrefetchHooks Function({bool categoryCode})
    >;
typedef $$LocalUserSettingsTableCreateCompanionBuilder =
    LocalUserSettingsCompanion Function({
      Value<int> id,
      Value<String> preferredLanguage,
      Value<String> preferredCurrency,
      Value<double> monthlyBudget,
      required DateTime updatedAt,
      Value<bool> isDirty,
    });
typedef $$LocalUserSettingsTableUpdateCompanionBuilder =
    LocalUserSettingsCompanion Function({
      Value<int> id,
      Value<String> preferredLanguage,
      Value<String> preferredCurrency,
      Value<double> monthlyBudget,
      Value<DateTime> updatedAt,
      Value<bool> isDirty,
    });

class $$LocalUserSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalUserSettingsTable> {
  $$LocalUserSettingsTableFilterComposer({
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

  ColumnFilters<String> get preferredLanguage => $composableBuilder(
    column: $table.preferredLanguage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get preferredCurrency => $composableBuilder(
    column: $table.preferredCurrency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get monthlyBudget => $composableBuilder(
    column: $table.monthlyBudget,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDirty => $composableBuilder(
    column: $table.isDirty,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalUserSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalUserSettingsTable> {
  $$LocalUserSettingsTableOrderingComposer({
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

  ColumnOrderings<String> get preferredLanguage => $composableBuilder(
    column: $table.preferredLanguage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get preferredCurrency => $composableBuilder(
    column: $table.preferredCurrency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get monthlyBudget => $composableBuilder(
    column: $table.monthlyBudget,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDirty => $composableBuilder(
    column: $table.isDirty,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalUserSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalUserSettingsTable> {
  $$LocalUserSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get preferredLanguage => $composableBuilder(
    column: $table.preferredLanguage,
    builder: (column) => column,
  );

  GeneratedColumn<String> get preferredCurrency => $composableBuilder(
    column: $table.preferredCurrency,
    builder: (column) => column,
  );

  GeneratedColumn<double> get monthlyBudget => $composableBuilder(
    column: $table.monthlyBudget,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDirty =>
      $composableBuilder(column: $table.isDirty, builder: (column) => column);
}

class $$LocalUserSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalUserSettingsTable,
          LocalUserSetting,
          $$LocalUserSettingsTableFilterComposer,
          $$LocalUserSettingsTableOrderingComposer,
          $$LocalUserSettingsTableAnnotationComposer,
          $$LocalUserSettingsTableCreateCompanionBuilder,
          $$LocalUserSettingsTableUpdateCompanionBuilder,
          (
            LocalUserSetting,
            BaseReferences<
              _$AppDatabase,
              $LocalUserSettingsTable,
              LocalUserSetting
            >,
          ),
          LocalUserSetting,
          PrefetchHooks Function()
        > {
  $$LocalUserSettingsTableTableManager(
    _$AppDatabase db,
    $LocalUserSettingsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalUserSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalUserSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalUserSettingsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> preferredLanguage = const Value.absent(),
                Value<String> preferredCurrency = const Value.absent(),
                Value<double> monthlyBudget = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> isDirty = const Value.absent(),
              }) => LocalUserSettingsCompanion(
                id: id,
                preferredLanguage: preferredLanguage,
                preferredCurrency: preferredCurrency,
                monthlyBudget: monthlyBudget,
                updatedAt: updatedAt,
                isDirty: isDirty,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> preferredLanguage = const Value.absent(),
                Value<String> preferredCurrency = const Value.absent(),
                Value<double> monthlyBudget = const Value.absent(),
                required DateTime updatedAt,
                Value<bool> isDirty = const Value.absent(),
              }) => LocalUserSettingsCompanion.insert(
                id: id,
                preferredLanguage: preferredLanguage,
                preferredCurrency: preferredCurrency,
                monthlyBudget: monthlyBudget,
                updatedAt: updatedAt,
                isDirty: isDirty,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalUserSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalUserSettingsTable,
      LocalUserSetting,
      $$LocalUserSettingsTableFilterComposer,
      $$LocalUserSettingsTableOrderingComposer,
      $$LocalUserSettingsTableAnnotationComposer,
      $$LocalUserSettingsTableCreateCompanionBuilder,
      $$LocalUserSettingsTableUpdateCompanionBuilder,
      (
        LocalUserSetting,
        BaseReferences<
          _$AppDatabase,
          $LocalUserSettingsTable,
          LocalUserSetting
        >,
      ),
      LocalUserSetting,
      PrefetchHooks Function()
    >;
typedef $$SyncMetadataTableCreateCompanionBuilder =
    SyncMetadataCompanion Function({
      Value<int> id,
      Value<DateTime?> lastSyncTimestamp,
    });
typedef $$SyncMetadataTableUpdateCompanionBuilder =
    SyncMetadataCompanion Function({
      Value<int> id,
      Value<DateTime?> lastSyncTimestamp,
    });

class $$SyncMetadataTableFilterComposer
    extends Composer<_$AppDatabase, $SyncMetadataTable> {
  $$SyncMetadataTableFilterComposer({
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

  ColumnFilters<DateTime> get lastSyncTimestamp => $composableBuilder(
    column: $table.lastSyncTimestamp,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncMetadataTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncMetadataTable> {
  $$SyncMetadataTableOrderingComposer({
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

  ColumnOrderings<DateTime> get lastSyncTimestamp => $composableBuilder(
    column: $table.lastSyncTimestamp,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncMetadataTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncMetadataTable> {
  $$SyncMetadataTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncTimestamp => $composableBuilder(
    column: $table.lastSyncTimestamp,
    builder: (column) => column,
  );
}

class $$SyncMetadataTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncMetadataTable,
          SyncMetadataData,
          $$SyncMetadataTableFilterComposer,
          $$SyncMetadataTableOrderingComposer,
          $$SyncMetadataTableAnnotationComposer,
          $$SyncMetadataTableCreateCompanionBuilder,
          $$SyncMetadataTableUpdateCompanionBuilder,
          (
            SyncMetadataData,
            BaseReferences<_$AppDatabase, $SyncMetadataTable, SyncMetadataData>,
          ),
          SyncMetadataData,
          PrefetchHooks Function()
        > {
  $$SyncMetadataTableTableManager(_$AppDatabase db, $SyncMetadataTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncMetadataTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncMetadataTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncMetadataTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime?> lastSyncTimestamp = const Value.absent(),
              }) => SyncMetadataCompanion(
                id: id,
                lastSyncTimestamp: lastSyncTimestamp,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime?> lastSyncTimestamp = const Value.absent(),
              }) => SyncMetadataCompanion.insert(
                id: id,
                lastSyncTimestamp: lastSyncTimestamp,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncMetadataTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncMetadataTable,
      SyncMetadataData,
      $$SyncMetadataTableFilterComposer,
      $$SyncMetadataTableOrderingComposer,
      $$SyncMetadataTableAnnotationComposer,
      $$SyncMetadataTableCreateCompanionBuilder,
      $$SyncMetadataTableUpdateCompanionBuilder,
      (
        SyncMetadataData,
        BaseReferences<_$AppDatabase, $SyncMetadataTable, SyncMetadataData>,
      ),
      SyncMetadataData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$LocalCategoriesTableTableManager get localCategories =>
      $$LocalCategoriesTableTableManager(_db, _db.localCategories);
  $$LocalTransactionsTableTableManager get localTransactions =>
      $$LocalTransactionsTableTableManager(_db, _db.localTransactions);
  $$LocalUserSettingsTableTableManager get localUserSettings =>
      $$LocalUserSettingsTableTableManager(_db, _db.localUserSettings);
  $$SyncMetadataTableTableManager get syncMetadata =>
      $$SyncMetadataTableTableManager(_db, _db.syncMetadata);
}
