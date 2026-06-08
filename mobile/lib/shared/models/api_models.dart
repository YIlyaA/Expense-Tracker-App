
class TokenPair {
  const TokenPair({required this.access, required this.refresh});

  final String access;
  final String refresh;

  factory TokenPair.fromJson(Map<String, dynamic> json) => TokenPair(
        access: json['access'] as String,
        refresh: json['refresh'] as String,
      );

  Map<String, dynamic> toJson() => {'access': access, 'refresh': refresh};
}

class UserSettingsDto {
  const UserSettingsDto({
    required this.preferredLanguage,
    required this.preferredCurrency,
  });

  final String preferredLanguage;
  final String preferredCurrency;

  factory UserSettingsDto.fromJson(Map<String, dynamic> json) =>
      UserSettingsDto(
        preferredLanguage: json['preferred_language'] as String,
        preferredCurrency: json['preferred_currency'] as String,
      );

  Map<String, dynamic> toJson() => {
        'preferred_language': preferredLanguage,
        'preferred_currency': preferredCurrency,
      };
}

class UserProfile {
  const UserProfile({
    required this.id,
    required this.email,
    required this.settings,
    required this.dateJoined,
  });

  final int id;
  final String email;
  final UserSettingsDto settings;
  final DateTime dateJoined;

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        id: json['id'] as int,
        email: json['email'] as String,
        settings:
            UserSettingsDto.fromJson(json['settings'] as Map<String, dynamic>),
        dateJoined: DateTime.parse(json['date_joined'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'settings': settings.toJson(),
        'date_joined': dateJoined.toIso8601String(),
      };
}

class AuthResponse {
  const AuthResponse({required this.user, required this.tokens});

  final UserProfile user;
  final TokenPair tokens;

  factory AuthResponse.fromJson(Map<String, dynamic> json) => AuthResponse(
        user: UserProfile.fromJson(json['user'] as Map<String, dynamic>),
        tokens: TokenPair.fromJson(json['tokens'] as Map<String, dynamic>),
      );

  Map<String, dynamic> toJson() => {
        'user': user.toJson(),
        'tokens': tokens.toJson(),
      };
}


class CategoryDto {
  const CategoryDto({
    required this.code,
    required this.defaultLabel,
    required this.label,
    required this.iconKey,
    required this.color,
    required this.sortOrder,
    required this.isActive,
  });

  final String code;
  final String defaultLabel;
  final String label;
  final String iconKey;
  final String color;
  final int sortOrder;
  final bool isActive;

  factory CategoryDto.fromJson(Map<String, dynamic> json) => CategoryDto(
        code: json['code'] as String,
        defaultLabel: json['default_label'] as String,
        label: json['label'] as String,
        iconKey: json['icon_key'] as String,
        color: json['color'] as String,
        sortOrder: json['sort_order'] as int,
        isActive: json['is_active'] as bool,
      );

  Map<String, dynamic> toJson() => {
        'code': code,
        'default_label': defaultLabel,
        'label': label,
        'icon_key': iconKey,
        'color': color,
        'sort_order': sortOrder,
        'is_active': isActive,
      };
}


class TransactionDto {
  const TransactionDto({
    required this.id,
    required this.category,
    required this.categoryCode,
    required this.description,
    required this.originalAmount,
    required this.originalCurrency,
    required this.baseAmount,
    required this.baseCurrency,
    required this.displayAmount,
    required this.displayCurrency,
    required this.transactionDate,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final CategoryDto category;
  final String categoryCode;
  final String description;
  final String originalAmount;
  final String originalCurrency;
  final String baseAmount;
  final String baseCurrency;
  final String displayAmount;
  final String displayCurrency;
  final DateTime transactionDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory TransactionDto.fromJson(Map<String, dynamic> json) => TransactionDto(
        id: json['id'] as int,
        category:
            CategoryDto.fromJson(json['category'] as Map<String, dynamic>),
        categoryCode: json['category_code'] as String,
        description: json['description'] as String,
        originalAmount: json['original_amount'] as String,
        originalCurrency: json['original_currency'] as String,
        baseAmount: json['base_amount'] as String,
        baseCurrency: json['base_currency'] as String,
        displayAmount: json['display_amount'] as String,
        displayCurrency: json['display_currency'] as String,
        transactionDate:
            DateTime.parse(json['transaction_date'] as String),
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: DateTime.parse(json['updated_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'category': category.toJson(),
        'category_code': categoryCode,
        'description': description,
        'original_amount': originalAmount,
        'original_currency': originalCurrency,
        'base_amount': baseAmount,
        'base_currency': baseCurrency,
        'display_amount': displayAmount,
        'display_currency': displayCurrency,
        'transaction_date':
            '${transactionDate.year}-${_pad(transactionDate.month)}-${_pad(transactionDate.day)}',
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
}

class PaginatedTransactions {
  const PaginatedTransactions({
    required this.count,
    required this.results,
    this.next,
    this.previous,
  });

  final int count;
  final String? next;
  final String? previous;
  final List<TransactionDto> results;

  factory PaginatedTransactions.fromJson(Map<String, dynamic> json) =>
      PaginatedTransactions(
        count: json['count'] as int,
        next: json['next'] as String?,
        previous: json['previous'] as String?,
        results: (json['results'] as List<dynamic>)
            .map((e) => TransactionDto.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}


class CurrencyContext {
  const CurrencyContext({
    required this.baseCurrency,
    required this.displayCurrency,
    required this.conversionSource,
  });

  final String baseCurrency;
  final String displayCurrency;
  final String conversionSource;

  factory CurrencyContext.fromJson(Map<String, dynamic> json) =>
      CurrencyContext(
        baseCurrency: json['base_currency'] as String,
        displayCurrency: json['display_currency'] as String,
        conversionSource: json['conversion_source'] as String,
      );

  Map<String, dynamic> toJson() => {
        'base_currency': baseCurrency,
        'display_currency': displayCurrency,
        'conversion_source': conversionSource,
      };
}

class Period {
  const Period({
    required this.kind,
    required this.dateFrom,
    required this.dateTo,
  });

  final String kind;
  final DateTime dateFrom;
  final DateTime dateTo;

  factory Period.fromJson(Map<String, dynamic> json) => Period(
        kind: json['kind'] as String,
        dateFrom: DateTime.parse(json['date_from'] as String),
        dateTo: DateTime.parse(json['date_to'] as String),
      );

  Map<String, dynamic> toJson() => {
        'kind': kind,
        'date_from':
            '${dateFrom.year}-${_pad(dateFrom.month)}-${_pad(dateFrom.day)}',
        'date_to':
            '${dateTo.year}-${_pad(dateTo.month)}-${_pad(dateTo.day)}',
      };
}

class AmountSummary {
  const AmountSummary({
    required this.baseAmount,
    required this.displayAmount,
  });

  final String baseAmount;
  final String displayAmount;

  factory AmountSummary.fromJson(Map<String, dynamic> json) => AmountSummary(
        baseAmount: json['base_amount'] as String,
        displayAmount: json['display_amount'] as String,
      );

  Map<String, dynamic> toJson() => {
        'base_amount': baseAmount,
        'display_amount': displayAmount,
      };
}

class CategoryAggregate {
  const CategoryAggregate({
    required this.categoryCode,
    required this.category,
    required this.transactionCount,
    required this.totalBaseAmount,
    required this.totalDisplayAmount,
  });

  final String categoryCode;
  final CategoryDto category;
  final int transactionCount;
  final String totalBaseAmount;
  final String totalDisplayAmount;

  factory CategoryAggregate.fromJson(Map<String, dynamic> json) =>
      CategoryAggregate(
        categoryCode: json['category_code'] as String,
        category:
            CategoryDto.fromJson(json['category'] as Map<String, dynamic>),
        transactionCount: json['transaction_count'] as int,
        totalBaseAmount: json['total_base_amount'] as String,
        totalDisplayAmount: json['total_display_amount'] as String,
      );

  Map<String, dynamic> toJson() => {
        'category_code': categoryCode,
        'category': category.toJson(),
        'transaction_count': transactionCount,
        'total_base_amount': totalBaseAmount,
        'total_display_amount': totalDisplayAmount,
      };
}

class RecentTransaction {
  const RecentTransaction({
    required this.id,
    required this.categoryCode,
    required this.category,
    required this.description,
    required this.originalAmount,
    required this.originalCurrency,
    required this.baseAmount,
    required this.baseCurrency,
    required this.displayAmount,
    required this.transactionDate,
    required this.createdAt,
  });

  final int id;
  final String categoryCode;
  final CategoryDto category;
  final String description;
  final String originalAmount;
  final String originalCurrency;
  final String baseAmount;
  final String baseCurrency;
  final String displayAmount;
  final DateTime transactionDate;
  final DateTime createdAt;

  factory RecentTransaction.fromJson(Map<String, dynamic> json) =>
      RecentTransaction(
        id: json['id'] as int,
        categoryCode: json['category_code'] as String,
        category:
            CategoryDto.fromJson(json['category'] as Map<String, dynamic>),
        description: json['description'] as String,
        originalAmount: json['original_amount'] as String,
        originalCurrency: json['original_currency'] as String,
        baseAmount: json['base_amount'] as String,
        baseCurrency: json['base_currency'] as String,
        displayAmount: json['display_amount'] as String,
        transactionDate:
            DateTime.parse(json['transaction_date'] as String),
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'category_code': categoryCode,
        'category': category.toJson(),
        'description': description,
        'original_amount': originalAmount,
        'original_currency': originalCurrency,
        'base_amount': baseAmount,
        'base_currency': baseCurrency,
        'display_amount': displayAmount,
        'transaction_date':
            '${transactionDate.year}-${_pad(transactionDate.month)}-${_pad(transactionDate.day)}',
        'created_at': createdAt.toIso8601String(),
      };
}

class DashboardData {
  const DashboardData({
    required this.currencyContext,
    required this.period,
    required this.currentMonthTotal,
    required this.recentTransactions,
    required this.topCategories,
  });

  final CurrencyContext currencyContext;
  final Period period;
  final AmountSummary currentMonthTotal;
  final List<RecentTransaction> recentTransactions;
  final List<CategoryAggregate> topCategories;

  factory DashboardData.fromJson(Map<String, dynamic> json) => DashboardData(
        currencyContext: CurrencyContext.fromJson(
            json['currency_context'] as Map<String, dynamic>),
        period: Period.fromJson(json['period'] as Map<String, dynamic>),
        currentMonthTotal: AmountSummary.fromJson(
            json['current_month_total'] as Map<String, dynamic>),
        recentTransactions: (json['recent_transactions'] as List<dynamic>)
            .map(
                (e) => RecentTransaction.fromJson(e as Map<String, dynamic>))
            .toList(),
        topCategories: (json['top_categories'] as List<dynamic>)
            .map((e) =>
                CategoryAggregate.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'currency_context': currencyContext.toJson(),
        'period': period.toJson(),
        'current_month_total': currentMonthTotal.toJson(),
        'recent_transactions':
            recentTransactions.map((e) => e.toJson()).toList(),
        'top_categories': topCategories.map((e) => e.toJson()).toList(),
      };
}


class MonthlyTotal {
  const MonthlyTotal({
    required this.month,
    required this.totalBaseAmount,
    required this.totalDisplayAmount,
  });

  final String month;
  final String totalBaseAmount;
  final String totalDisplayAmount;

  factory MonthlyTotal.fromJson(Map<String, dynamic> json) => MonthlyTotal(
        month: json['month'] as String,
        totalBaseAmount: json['total_base_amount'] as String,
        totalDisplayAmount: json['total_display_amount'] as String,
      );

  Map<String, dynamic> toJson() => {
        'month': month,
        'total_base_amount': totalBaseAmount,
        'total_display_amount': totalDisplayAmount,
      };
}

class StatisticsData {
  const StatisticsData({
    required this.currencyContext,
    required this.period,
    required this.totalSpent,
    required this.categoryBreakdown,
    required this.monthlyTotals,
  });

  final CurrencyContext currencyContext;
  final Period period;
  final AmountSummary totalSpent;
  final List<CategoryAggregate> categoryBreakdown;
  final List<MonthlyTotal> monthlyTotals;

  factory StatisticsData.fromJson(Map<String, dynamic> json) => StatisticsData(
        currencyContext: CurrencyContext.fromJson(
            json['currency_context'] as Map<String, dynamic>),
        period: Period.fromJson(json['period'] as Map<String, dynamic>),
        totalSpent: AmountSummary.fromJson(
            json['total_spent'] as Map<String, dynamic>),
        categoryBreakdown: (json['category_breakdown'] as List<dynamic>)
            .map((e) =>
                CategoryAggregate.fromJson(e as Map<String, dynamic>))
            .toList(),
        monthlyTotals: (json['monthly_totals'] as List<dynamic>)
            .map((e) => MonthlyTotal.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'currency_context': currencyContext.toJson(),
        'period': period.toJson(),
        'total_spent': totalSpent.toJson(),
        'category_breakdown':
            categoryBreakdown.map((e) => e.toJson()).toList(),
        'monthly_totals': monthlyTotals.map((e) => e.toJson()).toList(),
      };
}


class InsightCard {
  const InsightCard({
    required this.code,
    required this.title,
    required this.message,
    required this.severity,
    this.relatedCategoryCode,
    this.relatedCategory,
    this.period,
    required this.metadata,
  });

  final String code;
  final String title;
  final String message;
  final String severity;
  final String? relatedCategoryCode;
  final CategoryDto? relatedCategory;
  final Period? period;
  final Map<String, dynamic> metadata;

  factory InsightCard.fromJson(Map<String, dynamic> json) => InsightCard(
        code: json['code'] as String,
        title: json['title'] as String,
        message: json['message'] as String,
        severity: json['severity'] as String,
        relatedCategoryCode: json['related_category_code'] as String?,
        relatedCategory: json['related_category'] != null
            ? CategoryDto.fromJson(
                json['related_category'] as Map<String, dynamic>)
            : null,
        period: json['period'] != null
            ? Period.fromJson(json['period'] as Map<String, dynamic>)
            : null,
        metadata: json['metadata'] as Map<String, dynamic>,
      );

  Map<String, dynamic> toJson() => {
        'code': code,
        'title': title,
        'message': message,
        'severity': severity,
        'related_category_code': relatedCategoryCode,
        'related_category': relatedCategory?.toJson(),
        'period': period?.toJson(),
        'metadata': metadata,
      };
}

class InsightsData {
  const InsightsData({
    required this.generator,
    required this.messageLocale,
    required this.currencyContext,
    required this.insights,
  });

  final String generator;
  final String messageLocale;
  final CurrencyContext currencyContext;
  final List<InsightCard> insights;

  factory InsightsData.fromJson(Map<String, dynamic> json) => InsightsData(
        generator: json['generator'] as String,
        messageLocale: json['message_locale'] as String,
        currencyContext: CurrencyContext.fromJson(
            json['currency_context'] as Map<String, dynamic>),
        insights: (json['insights'] as List<dynamic>)
            .map((e) => InsightCard.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'generator': generator,
        'message_locale': messageLocale,
        'currency_context': currencyContext.toJson(),
        'insights': insights.map((e) => e.toJson()).toList(),
      };
}


class SyncCategory {
  const SyncCategory({
    required this.code,
    required this.defaultLabel,
    required this.iconKey,
    required this.color,
    required this.sortOrder,
    required this.isActive,
    required this.updatedAt,
  });

  final String code;
  final String defaultLabel;
  final String iconKey;
  final String color;
  final int sortOrder;
  final bool isActive;
  final DateTime updatedAt;

  factory SyncCategory.fromJson(Map<String, dynamic> json) => SyncCategory(
        code: json['code'] as String,
        defaultLabel: json['default_label'] as String,
        iconKey: json['icon_key'] as String,
        color: json['color'] as String,
        sortOrder: json['sort_order'] as int,
        isActive: json['is_active'] as bool,
        updatedAt: DateTime.parse(json['updated_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'code': code,
        'default_label': defaultLabel,
        'icon_key': iconKey,
        'color': color,
        'sort_order': sortOrder,
        'is_active': isActive,
        'updated_at': updatedAt.toIso8601String(),
      };
}

class SyncTransaction {
  const SyncTransaction({
    required this.id,
    required this.categoryCode,
    required this.description,
    required this.originalAmount,
    required this.originalCurrency,
    required this.baseAmount,
    required this.baseCurrency,
    required this.transactionDate,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final String categoryCode;
  final String description;
  final String originalAmount;
  final String originalCurrency;
  final String baseAmount;
  final String baseCurrency;
  final DateTime transactionDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory SyncTransaction.fromJson(Map<String, dynamic> json) =>
      SyncTransaction(
        id: json['id'] as int,
        categoryCode: json['category_code'] as String,
        description: json['description'] as String,
        originalAmount: json['original_amount'] as String,
        originalCurrency: json['original_currency'] as String,
        baseAmount: json['base_amount'] as String,
        baseCurrency: json['base_currency'] as String,
        transactionDate:
            DateTime.parse(json['transaction_date'] as String),
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: DateTime.parse(json['updated_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'category_code': categoryCode,
        'description': description,
        'original_amount': originalAmount,
        'original_currency': originalCurrency,
        'base_amount': baseAmount,
        'base_currency': baseCurrency,
        'transaction_date':
            '${transactionDate.year}-${_pad(transactionDate.month)}-${_pad(transactionDate.day)}',
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
}

class SyncSettings {
  const SyncSettings({
    required this.preferredLanguage,
    required this.preferredCurrency,
    required this.updatedAt,
  });

  final String preferredLanguage;
  final String preferredCurrency;
  final DateTime updatedAt;

  factory SyncSettings.fromJson(Map<String, dynamic> json) => SyncSettings(
        preferredLanguage: json['preferred_language'] as String,
        preferredCurrency: json['preferred_currency'] as String,
        updatedAt: DateTime.parse(json['updated_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'preferred_language': preferredLanguage,
        'preferred_currency': preferredCurrency,
        'updated_at': updatedAt.toIso8601String(),
      };
}

class SyncPullTransactions {
  const SyncPullTransactions({
    required this.upserted,
    required this.deletedIds,
  });

  final List<SyncTransaction> upserted;
  final List<int> deletedIds;

  factory SyncPullTransactions.fromJson(Map<String, dynamic> json) =>
      SyncPullTransactions(
        upserted: (json['upserted'] as List<dynamic>)
            .map((e) => SyncTransaction.fromJson(e as Map<String, dynamic>))
            .toList(),
        deletedIds: (json['deleted_ids'] as List<dynamic>)
            .map((e) => e as int)
            .toList(),
      );
}

class SyncPullResponse {
  const SyncPullResponse({
    required this.serverTimestamp,
    required this.categories,
    required this.transactions,
    this.settings,
  });

  final DateTime serverTimestamp;
  final List<SyncCategory> categories;
  final SyncPullTransactions transactions;
  final SyncSettings? settings;

  factory SyncPullResponse.fromJson(Map<String, dynamic> json) =>
      SyncPullResponse(
        serverTimestamp:
            DateTime.parse(json['server_timestamp'] as String),
        categories: (json['categories'] as List<dynamic>)
            .map((e) => SyncCategory.fromJson(e as Map<String, dynamic>))
            .toList(),
        transactions: SyncPullTransactions.fromJson(
            json['transactions'] as Map<String, dynamic>),
        settings: json['settings'] != null
            ? SyncSettings.fromJson(
                json['settings'] as Map<String, dynamic>)
            : null,
      );
}

class SyncPushTransactionCreate {
  const SyncPushTransactionCreate({
    required this.clientId,
    required this.categoryCode,
    required this.description,
    required this.originalAmount,
    required this.originalCurrency,
    required this.transactionDate,
  });

  final String clientId;
  final String categoryCode;
  final String description;
  final String originalAmount;
  final String originalCurrency;
  final DateTime transactionDate;

  Map<String, dynamic> toJson() => {
        'client_id': clientId,
        'category_code': categoryCode,
        'description': description,
        'original_amount': originalAmount,
        'original_currency': originalCurrency,
        'transaction_date':
            '${transactionDate.year}-${_pad(transactionDate.month)}-${_pad(transactionDate.day)}',
      };
}

class SyncPushTransactionUpdate {
  const SyncPushTransactionUpdate({
    required this.id,
    this.categoryCode,
    this.description,
    this.originalAmount,
    this.originalCurrency,
    this.transactionDate,
    required this.updatedAt,
  });

  final int id;
  final String? categoryCode;
  final String? description;
  final String? originalAmount;
  final String? originalCurrency;
  final DateTime? transactionDate;
  final DateTime updatedAt;

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'id': id,
      'updated_at': updatedAt.toUtc().toIso8601String(),
    };
    if (categoryCode != null) json['category_code'] = categoryCode;
    if (description != null) json['description'] = description;
    if (originalAmount != null) json['original_amount'] = originalAmount;
    if (originalCurrency != null) json['original_currency'] = originalCurrency;
    if (transactionDate != null) {
      json['transaction_date'] =
          '${transactionDate!.year}-${_pad(transactionDate!.month)}-${_pad(transactionDate!.day)}';
    }
    return json;
  }
}

class SyncPushTransactionDelete {
  const SyncPushTransactionDelete({required this.id});

  final int id;

  Map<String, dynamic> toJson() => {'id': id};
}

class SyncPushTransactions {
  const SyncPushTransactions({
    this.created = const [],
    this.updated = const [],
    this.deleted = const [],
  });

  final List<SyncPushTransactionCreate> created;
  final List<SyncPushTransactionUpdate> updated;
  final List<SyncPushTransactionDelete> deleted;

  Map<String, dynamic> toJson() => {
        'created': created.map((e) => e.toJson()).toList(),
        'updated': updated.map((e) => e.toJson()).toList(),
        'deleted': deleted.map((e) => e.toJson()).toList(),
      };
}

class SyncPushSettings {
  const SyncPushSettings({
    this.preferredLanguage,
    this.preferredCurrency,
    this.updatedAt,
  });

  final String? preferredLanguage;
  final String? preferredCurrency;

  final DateTime? updatedAt;

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (preferredLanguage != null) {
      json['preferred_language'] = preferredLanguage;
    }
    if (preferredCurrency != null) {
      json['preferred_currency'] = preferredCurrency;
    }
    if (updatedAt != null) {
      json['updated_at'] = updatedAt!.toUtc().toIso8601String();
    }
    return json;
  }
}

class SyncPushRequest {
  const SyncPushRequest({this.transactions, this.settings});

  final SyncPushTransactions? transactions;
  final SyncPushSettings? settings;

  Map<String, dynamic> toJson() => {
        'transactions': transactions?.toJson() ?? {},
        'settings': settings?.toJson(),
      };
}

class SyncIdMapping {
  const SyncIdMapping({required this.clientId, required this.serverId});

  final String clientId;
  final int serverId;

  factory SyncIdMapping.fromJson(Map<String, dynamic> json) => SyncIdMapping(
        clientId: json['client_id'] as String,
        serverId: json['server_id'] as int,
      );
}

class SyncConflict {
  const SyncConflict({required this.id, required this.serverVersion});

  final int id;
  final SyncTransaction serverVersion;

  factory SyncConflict.fromJson(Map<String, dynamic> json) => SyncConflict(
        id: json['id'] as int,
        serverVersion: SyncTransaction.fromJson(
            json['server_version'] as Map<String, dynamic>),
      );
}

class SyncPushResponse {
  const SyncPushResponse({
    required this.serverTimestamp,
    required this.idMappings,
    required this.conflicts,
    this.settings,
  });

  final DateTime serverTimestamp;
  final List<SyncIdMapping> idMappings;
  final List<SyncConflict> conflicts;
  final SyncSettings? settings;

  factory SyncPushResponse.fromJson(Map<String, dynamic> json) =>
      SyncPushResponse(
        serverTimestamp:
            DateTime.parse(json['server_timestamp'] as String),
        idMappings: (json['id_mappings'] as List<dynamic>)
            .map((e) => SyncIdMapping.fromJson(e as Map<String, dynamic>))
            .toList(),
        conflicts: (json['conflicts'] as List<dynamic>)
            .map((e) => SyncConflict.fromJson(e as Map<String, dynamic>))
            .toList(),
        settings: json['settings'] != null
            ? SyncSettings.fromJson(
                json['settings'] as Map<String, dynamic>)
            : null,
      );
}


class CategoryPrediction {
  const CategoryPrediction({
    required this.inputText,
    required this.status,
    required this.confidence,
    required this.classifierVersion,
    required this.strategy,
    this.predictedCategoryCode,
    this.predictedCategory,
  });

  /// 'predicted' | 'uncertain' | 'no_match'
  final String status;
  final String inputText;

  /// 0.0 - 1.0
  final double confidence;
  final String classifierVersion;
  final String strategy;
  final String? predictedCategoryCode;
  final CategoryDto? predictedCategory;

  bool get hasConfidentPrediction =>
      predictedCategoryCode != null && status == 'predicted';

  factory CategoryPrediction.fromJson(Map<String, dynamic> json) =>
      CategoryPrediction(
        inputText: json['input_text'] as String,
        status: json['status'] as String,
        confidence: double.parse((json['confidence']).toString()),
        classifierVersion: json['classifier_version'] as String,
        strategy: json['strategy'] as String,
        predictedCategoryCode: json['predicted_category_code'] as String?,
        predictedCategory: json['predicted_category'] != null
            ? CategoryDto.fromJson(
                json['predicted_category'] as Map<String, dynamic>)
            : null,
      );
}


String _pad(int n) => n.toString().padLeft(2, '0');
