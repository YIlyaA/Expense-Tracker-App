import '../api_client.dart';

class SyncApiService {
  SyncApiService({required ApiClient apiClient}) : _api = apiClient;

  final ApiClient _api;

  Future<Map<String, dynamic>> pull({DateTime? since}) async {
    final queryParams = <String, dynamic>{};
    if (since != null) queryParams['since'] = since.toUtc().toIso8601String();

    final response = await _api.get<Map<String, dynamic>>(
      '/sync/pull/',
      queryParameters: queryParams,
    );
    return response.data!;
  }

  Future<Map<String, dynamic>> push(Map<String, dynamic> request) async {
    final response = await _api.post<Map<String, dynamic>>(
      '/sync/push/',
      data: request,
    );
    return response.data!;
  }
}
