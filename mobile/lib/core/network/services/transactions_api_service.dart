import '../api_client.dart';

class TransactionsApiService {
  TransactionsApiService({required ApiClient apiClient}) : _api = apiClient;

  final ApiClient _api;

  Future<Map<String, dynamic>> getTransactions({
    String? category,
    String? dateFrom,
    String? dateTo,
    int? page,
  }) async {
    final queryParams = <String, dynamic>{};
    if (category != null) queryParams['category'] = category;
    if (dateFrom != null) queryParams['date_from'] = dateFrom;
    if (dateTo != null) queryParams['date_to'] = dateTo;
    if (page != null) queryParams['page'] = page;

    final response = await _api.get<Map<String, dynamic>>(
      '/transactions/',
      queryParameters: queryParams,
    );
    return response.data!;
  }

  Future<Map<String, dynamic>> createTransaction({
    required String categoryCode,
    required String description,
    required String originalAmount,
    required String originalCurrency,
    required String transactionDate,
  }) async {
    final response = await _api.post<Map<String, dynamic>>(
      '/transactions/',
      data: {
        'category_code': categoryCode,
        'description': description,
        'original_amount': originalAmount,
        'original_currency': originalCurrency,
        'transaction_date': transactionDate,
      },
    );
    return response.data!;
  }

  Future<Map<String, dynamic>> updateTransaction(
    int id, {
    String? categoryCode,
    String? description,
    String? originalAmount,
    String? originalCurrency,
    String? transactionDate,
  }) async {
    final data = <String, dynamic>{};
    if (categoryCode != null) data['category_code'] = categoryCode;
    if (description != null) data['description'] = description;
    if (originalAmount != null) data['original_amount'] = originalAmount;
    if (originalCurrency != null) data['original_currency'] = originalCurrency;
    if (transactionDate != null) data['transaction_date'] = transactionDate;

    final response = await _api.patch<Map<String, dynamic>>(
      '/transactions/$id/',
      data: data,
    );
    return response.data!;
  }

  Future<void> deleteTransaction(int id) async {
    await _api.delete('/transactions/$id/');
  }
}
