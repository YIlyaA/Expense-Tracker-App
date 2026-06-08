enum AppTab { dashboard, transactions, statistics, insights, settings }

enum CategoryType {
  food,
  transport,
  phone,
  sport,
  household,
  health,
  documents,
  clothes,
  subscriptions,
  topUps,
  other;

  static const _codeMap = {
    'food': CategoryType.food,
    'transport': CategoryType.transport,
    'phone': CategoryType.phone,
    'sport': CategoryType.sport,
    'household': CategoryType.household,
    'health': CategoryType.health,
    'documents': CategoryType.documents,
    'clothes': CategoryType.clothes,
    'subscriptions': CategoryType.subscriptions,
    'top_ups': CategoryType.topUps,
    'other': CategoryType.other,
  };

  static CategoryType fromCode(String code) =>
      _codeMap[code] ?? CategoryType.other;

  String toCode() => _codeMap.entries
      .firstWhere((e) => e.value == this, orElse: () => const MapEntry('other', CategoryType.other))
      .key;
}

enum CurrencyOption { pln, usd, eur }

class TransactionEntry {
  const TransactionEntry({
    required this.id,
    required this.title,
    required this.category,
    required this.amount,
    required this.date,
    this.isSynced = true,
    this.localId,
  });

  final String id;

  final int? localId;

  final String title;
  final CategoryType category;
  final double amount;
  final DateTime date;
  final bool isSynced;
}

class MonthPoint {
  const MonthPoint({required this.month, required this.total});

  final DateTime month;
  final double total;
}
