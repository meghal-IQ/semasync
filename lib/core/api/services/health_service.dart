import '../api_client.dart';
import '../models/api_response.dart';
import '../models/weight_log_model.dart';
import '../models/side_effect_log_model.dart';

class HealthService {
  final ApiClient _apiClient = ApiClient();

  // ============================================================================
  // WEIGHT TRACKING
  // ============================================================================

  Future<ApiResponse<WeightLog>> logWeight(WeightLogRequest request) async {
    try {
      final response = await _apiClient.post(
        '/api/health/weight',
        data: request.toJson(),
      );

      if (response.data['success'] == true && response.data['data'] != null) {
        final weightLog = WeightLog.fromJson(response.data['data']);
        return ApiResponse<WeightLog>(
          success: true,
          message: response.data['message'] ?? 'Weight logged successfully',
          data: weightLog,
        );
      }

      return ApiResponse<WeightLog>(
        success: false,
        message: response.data['message'] ?? 'Failed to log weight',
      );
    } catch (e) {
      return ApiResponse<WeightLog>(
        success: false,
        message: e.toString(),
      );
    }
  }

  Future<ApiResponse<WeightHistoryResponse>> getWeightHistory({
    DateTime? startDate,
    DateTime? endDate,
    int limit = 50,
    int page = 1,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'limit': limit.toString(),
        'page': page.toString(),
      };

      if (startDate != null) queryParams['startDate'] = startDate.toIso8601String();
      if (endDate != null) queryParams['endDate'] = endDate.toIso8601String();

      final response = await _apiClient.get(
        '/api/health/weight',
        queryParameters: queryParams,
      );

      if (response.data['success'] == true && response.data['data'] != null) {
        final historyResponse = WeightHistoryResponse.fromJson(response.data['data']);
        return ApiResponse<WeightHistoryResponse>(
          success: true,
          message: 'Weight history retrieved',
          data: historyResponse,
        );
      }

      return ApiResponse<WeightHistoryResponse>(
        success: false,
        message: response.data['message'] ?? 'Failed to get weight history',
      );
    } catch (e) {
      return ApiResponse<WeightHistoryResponse>(
        success: false,
        message: e.toString(),
      );
    }
  }

  Future<ApiResponse<WeightStats>> getWeightStats() async {
    try {
      final response = await _apiClient.get('/api/health/weight/stats');

      if (response.data['success'] == true && response.data['data'] != null) {
        final stats = WeightStats.fromJson(response.data['data']);
        return ApiResponse<WeightStats>(
          success: true,
          message: 'Statistics retrieved',
          data: stats,
        );
      }

      return ApiResponse<WeightStats>(
        success: false,
        message: response.data['message'] ?? 'Failed to get statistics',
      );
    } catch (e) {
      return ApiResponse<WeightStats>(
        success: false,
        message: e.toString(),
      );
    }
  }

  Future<ApiResponse<void>> deleteWeight(String weightId) async {
    try {
      final response = await _apiClient.delete('/api/health/weight/$weightId');

      return ApiResponse<void>(
        success: response.data['success'] ?? false,
        message: response.data['message'] ?? 'Weight deleted',
      );
    } catch (e) {
      return ApiResponse<void>(
        success: false,
        message: e.toString(),
      );
    }
  }

  // ============================================================================
  // SIDE EFFECTS TRACKING
  // ============================================================================

  Future<ApiResponse<SideEffectLog>> logSideEffects(SideEffectLogRequest request) async {
    try {
      final response = await _apiClient.post(
        '/api/health/side-effects',
        data: request.toJson(),
      );

      if (response.data['success'] == true && response.data['data'] != null) {
        final log = SideEffectLog.fromJson(response.data['data']);
        return ApiResponse<SideEffectLog>(
          success: true,
          message: response.data['message'] ?? 'Side effects logged',
          data: log,
        );
      }

      return ApiResponse<SideEffectLog>(
        success: false,
        message: response.data['message'] ?? 'Failed to log side effects',
      );
    } catch (e) {
      return ApiResponse<SideEffectLog>(
        success: false,
        message: e.toString(),
      );
    }
  }

  Future<ApiResponse<List<SideEffectLog>>> getSideEffects({
    int limit = 50,
    int page = 1,
  }) async {
    try {
      final response = await _apiClient.get(
        '/api/health/side-effects',
        queryParameters: {
          'limit': limit.toString(),
          'page': page.toString(),
        },
      );

      if (response.data['success'] == true && response.data['data'] != null) {
        final logs = (response.data['data']['sideEffects'] as List)
            .map((e) => SideEffectLog.fromJson(e))
            .toList();
        return ApiResponse<List<SideEffectLog>>(
          success: true,
          message: 'Side effects retrieved',
          data: logs,
        );
      }

      return ApiResponse<List<SideEffectLog>>(
        success: false,
        message: response.data['message'] ?? 'Failed to get side effects',
      );
    } catch (e) {
      return ApiResponse<List<SideEffectLog>>(
        success: false,
        message: e.toString(),
      );
    }
  }

  Future<ApiResponse<SideEffectTrends>> getSideEffectTrends() async {
    try {
      final response = await _apiClient.get('/api/health/side-effects/trends');

      if (response.data['success'] == true && response.data['data'] != null) {
        final trends = SideEffectTrends.fromJson(response.data['data']);
        return ApiResponse<SideEffectTrends>(
          success: true,
          message: 'Trends retrieved',
          data: trends,
        );
      }

      return ApiResponse<SideEffectTrends>(
        success: false,
        message: response.data['message'] ?? 'Failed to get trends',
      );
    } catch (e) {
      return ApiResponse<SideEffectTrends>(
        success: false,
        message: e.toString(),
      );
    }
  }
}