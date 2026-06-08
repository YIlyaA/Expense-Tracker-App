import '../api_client.dart';

class SettingsApiService {
  SettingsApiService({required ApiClient apiClient}) : _api = apiClient;

  final ApiClient _api;

  Future<Map<String, dynamic>> getSettings() async {
    final response = await _api.get<Map<String, dynamic>>('/settings/me/');
    return response.data!;
  }

  Future<Map<String, dynamic>> updateSettings({
    String? language,
    String? currency,
  }) async {
    final data = <String, dynamic>{};
    if (language != null) data['preferred_language'] = language;
    if (currency != null) data['preferred_currency'] = currency;

    final response = await _api.patch<Map<String, dynamic>>(
      '/settings/me/',
      data: data,
    );
    return response.data!;
  }
}
