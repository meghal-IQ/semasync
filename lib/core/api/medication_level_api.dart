import 'package:dio/dio.dart';

class MedicationLevelApi {
  final Dio _dio;

  MedicationLevelApi(this._dio);

  /// Get current medication level
  Future<Map<String, dynamic>> getCurrentMedicationLevel() async {
    try {
      final response = await _dio.get('/api/treatments/medication-level');
      return response.data;
    } catch (e) {
      throw Exception('Failed to get current medication level: ${e.toString()}');
    }
  }

  /// Get historical medication level data for visualization
  Future<Map<String, dynamic>> getMedicationLevelHistory({
    int days = 30,
    String groupBy = 'day',
    bool includePredictions = false,
  }) async {
    try {
      final queryParams = {
        'days': days,
        'groupBy': groupBy,
        'includePredictions': includePredictions,
      };

      final response = await _dio.get(
        '/api/treatments/medication-level/history',
        queryParameters: queryParams,
      );

      return response.data;
    } catch (e) {
      throw Exception('Failed to get medication level history: ${e.toString()}');
    }
  }

  /// Get medication level trends and analytics
  Future<Map<String, dynamic>> getMedicationLevelTrends({
    int days = 30,
    String? medication,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'days': days,
        if (medication != null) 'medication': medication,
      };

      final response = await _dio.get(
        '/api/treatments/medication-level/trends',
        queryParameters: queryParams,
      );

      return response.data;
    } catch (e) {
      throw Exception('Failed to get medication level trends: ${e.toString()}');
    }
  }

  /// Calculate and store current medication level
  Future<Map<String, dynamic>> calculateMedicationLevel() async {
    try {
      final response = await _dio.post('/api/treatments/medication-level/calculate');
      return response.data;
    } catch (e) {
      throw Exception('Failed to calculate medication level: ${e.toString()}');
    }
  }

  /// Get next shot due date and countdown
  Future<Map<String, dynamic>> getNextShotInfo() async {
    try {
      final response = await _dio.get('/api/treatments/shots/next');
      return response.data;
    } catch (e) {
      throw Exception('Failed to get next shot info: ${e.toString()}');
    }
  }
}
