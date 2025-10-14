import '../api_client.dart';
import '../models/api_response.dart';
import '../models/nutrition_log_model.dart';

class HistoricalDataService {
  final ApiClient _apiClient = ApiClient();

  /// Get historical nutrition data for a specific date
  Future<ApiResponse<Map<String, dynamic>>> getHistoricalNutritionData(DateTime date) async {
    try {
      final dateString = date.toIso8601String().split('T')[0]; // YYYY-MM-DD format
      
      final response = await _apiClient.get(
        '/api/nutrition/daily-summary',
        queryParameters: {'date': dateString},
      );

      if (response.data['success'] == true && response.data['data'] != null) {
        return ApiResponse<Map<String, dynamic>>(
          success: true,
          message: response.data['message'] ?? 'Historical nutrition data retrieved',
          data: response.data['data'],
        );
      }

      return ApiResponse<Map<String, dynamic>>(
        success: false,
        message: response.data['message'] ?? 'Failed to retrieve historical nutrition data',
      );
    } catch (e) {
      return ApiResponse<Map<String, dynamic>>(
        success: false,
        message: e.toString(),
      );
    }
  }

  /// Get historical log entries for a specific date
  Future<ApiResponse<List<Map<String, dynamic>>>> getHistoricalLogEntries(DateTime date) async {
    try {
      final dateString = date.toIso8601String().split('T')[0]; // YYYY-MM-DD format
      
      final response = await _apiClient.get(
        '/api/nutrition/todays-log',
        queryParameters: {'date': dateString},
      );

      if (response.data['success'] == true && response.data['data'] != null) {
        final logs = (response.data['data']['logs'] as List)
            .map((log) => Map<String, dynamic>.from(log))
            .toList();
        
        return ApiResponse<List<Map<String, dynamic>>>(
          success: true,
          message: response.data['message'] ?? 'Historical log entries retrieved',
          data: logs,
        );
      }

      return ApiResponse<List<Map<String, dynamic>>>(
        success: false,
        message: response.data['message'] ?? 'Failed to retrieve historical log entries',
      );
    } catch (e) {
      return ApiResponse<List<Map<String, dynamic>>>(
        success: false,
        message: e.toString(),
      );
    }
  }

  /// Get historical treatment data for a specific date
  Future<ApiResponse<List<Map<String, dynamic>>>> getHistoricalTreatmentData(DateTime date) async {
    try {
      final dateString = date.toIso8601String().split('T')[0]; // YYYY-MM-DD format
      
      final response = await _apiClient.get(
        '/api/treatments/shots',
        queryParameters: {'date': dateString},
      );

      if (response.data['success'] == true && response.data['data'] != null) {
        final shots = (response.data['data']['shots'] as List)
            .map((shot) => Map<String, dynamic>.from(shot))
            .toList();
        
        return ApiResponse<List<Map<String, dynamic>>>(
          success: true,
          message: response.data['message'] ?? 'Historical treatment data retrieved',
          data: shots,
        );
      }

      return ApiResponse<List<Map<String, dynamic>>>(
        success: false,
        message: response.data['message'] ?? 'Failed to retrieve historical treatment data',
      );
    } catch (e) {
      return ApiResponse<List<Map<String, dynamic>>>(
        success: false,
        message: e.toString(),
      );
    }
  }

  /// Get historical weight data for a specific date
  Future<ApiResponse<List<Map<String, dynamic>>>> getHistoricalWeightData(DateTime date) async {
    try {
      final dateString = date.toIso8601String().split('T')[0]; // YYYY-MM-DD format
      
      final response = await _apiClient.get(
        '/api/health/weight',
        queryParameters: {'date': dateString},
      );

      if (response.data['success'] == true && response.data['data'] != null) {
        final weights = (response.data['data']['weights'] as List)
            .map((weight) => Map<String, dynamic>.from(weight))
            .toList();
        
        return ApiResponse<List<Map<String, dynamic>>>(
          success: true,
          message: response.data['message'] ?? 'Historical weight data retrieved',
          data: weights,
        );
      }

      return ApiResponse<List<Map<String, dynamic>>>(
        success: false,
        message: response.data['message'] ?? 'Failed to retrieve historical weight data',
      );
    } catch (e) {
      return ApiResponse<List<Map<String, dynamic>>>(
        success: false,
        message: e.toString(),
      );
    }
  }

  /// Get comprehensive historical data for a specific date
  Future<ApiResponse<Map<String, dynamic>>> getHistoricalDashboardData(DateTime date) async {
    try {
      final dateString = date.toIso8601String().split('T')[0]; // YYYY-MM-DD format
      
      // Fetch all historical data in parallel
      final results = await Future.wait([
        getHistoricalNutritionData(date),
        getHistoricalLogEntries(date),
        getHistoricalTreatmentData(date),
        getHistoricalWeightData(date),
      ]);

      final nutritionData = results[0].data ?? {};
      final logEntries = results[1].data ?? [];
      final treatmentData = results[2].data ?? [];
      final weightData = results[3].data ?? [];

      // Check if any requests failed
      final hasErrors = results.any((result) => !result.success);
      if (hasErrors) {
        return ApiResponse<Map<String, dynamic>>(
          success: false,
          message: 'Some historical data could not be retrieved',
          data: {
            'nutrition': nutritionData,
            'logs': logEntries,
            'treatments': treatmentData,
            'weights': weightData,
            'date': dateString,
          },
        );
      }

      return ApiResponse<Map<String, dynamic>>(
        success: true,
        message: 'Historical dashboard data retrieved successfully',
        data: {
          'nutrition': nutritionData,
          'logs': logEntries,
          'treatments': treatmentData,
          'weights': weightData,
          'date': dateString,
        },
      );
    } catch (e) {
      return ApiResponse<Map<String, dynamic>>(
        success: false,
        message: e.toString(),
      );
    }
  }
}
