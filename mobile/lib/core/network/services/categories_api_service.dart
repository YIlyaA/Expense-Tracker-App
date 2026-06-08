import '../api_client.dart';

class CategoriesApiService {
  CategoriesApiService({required ApiClient apiClient}) : _api = apiClient;

  final ApiClient _api;

  Future<List<dynamic>> getCategories() async {
    final response = await _api.get<List<dynamic>>('/categories/');
    return response.data!;
  }
}
