import '../api_client.dart';

class InsightsApiService {
  InsightsApiService({required ApiClient apiClient}) : _api = apiClient;

  final ApiClient _api;

  Future<Map<String, dynamic>> getDashboard() async {
    final response = await _api.get<Map<String, dynamic>>('/dashboard/');
    return response.data!;
  }

  Future<Map<String, dynamic>> getStatistics({
    String? dateFrom,
    String? dateTo,
  }) async {
    final queryParams = <String, dynamic>{};
    if (dateFrom != null) queryParams['date_from'] = dateFrom;
    if (dateTo != null) queryParams['date_to'] = dateTo;

    final response = await _api.get<Map<String, dynamic>>(
      '/statistics/',
      queryParameters: queryParams,
    );
    return response.data!;
  }

  Future<Map<String, dynamic>> getInsights() async {
    final response = await _api.get<Map<String, dynamic>>('/insights/');
    return response.data!;
  }
}
