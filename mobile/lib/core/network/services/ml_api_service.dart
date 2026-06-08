import '../api_client.dart';

class MlApiService {
  MlApiService({required ApiClient apiClient}) : _api = apiClient;

  final ApiClient _api;

  Future<Map<String, dynamic>> predictCategory({
    required String inputText,
  }) async {
    final response = await _api.post<Map<String, dynamic>>(
      '/ml/category-predictions/',
      data: {'input_text': inputText},
    );
    return response.data!;
  }

  Future<Map<String, dynamic>> sendFeedback({
    required String inputText,
    required String selectedCategoryCode,
    String? predictedCategoryCode,
    double? predictedConfidence,
    String? predictedStatus,
    String? predictionStrategy,
    String? classifierVersion,
    int? transactionId,
  }) async {
    final data = <String, dynamic>{
      'input_text': inputText,
      'selected_category_code': selectedCategoryCode,
    };
    if (predictedCategoryCode != null) {
      data['predicted_category_code'] = predictedCategoryCode;
    }
    if (predictedConfidence != null) {
      data['predicted_confidence'] = predictedConfidence.toStringAsFixed(2);
    }
    if (predictedStatus != null && predictedStatus.isNotEmpty) {
      data['predicted_status'] = predictedStatus;
    }
    if (predictionStrategy != null && predictionStrategy.isNotEmpty) {
      data['prediction_strategy'] = predictionStrategy;
    }
    if (classifierVersion != null && classifierVersion.isNotEmpty) {
      data['classifier_version'] = classifierVersion;
    }
    if (transactionId != null) {
      data['transaction_id'] = transactionId;
    }
    final response = await _api.post<Map<String, dynamic>>(
      '/ml/category-feedback/',
      data: data,
    );
    return response.data!;
  }
}
