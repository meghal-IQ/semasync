import 'package:shared_preferences/shared_preferences.dart';
import '../api_client.dart';
import '../models/api_response.dart';
import '../models/shot_log_model.dart';

class TreatmentService {
  final ApiClient _apiClient = ApiClient();

  /// Log a new shot/injection
  Future<ApiResponse<ShotLog>> logShot(ShotLogRequest request) async {
    try {
      final response = await _apiClient.post(
        '/api/treatments/shots',
        data: request.toJson(),
      );

      if (response.data['success'] == true && response.data['data'] != null) {
        final shotLog = ShotLog.fromJson(response.data['data']['shotLog']);
        return ApiResponse<ShotLog>(
          success: true,
          message: response.data['message'] ?? 'Shot logged successfully',
          data: shotLog,
        );
      }

      return ApiResponse<ShotLog>(
        success: false,
        message: response.data['message'] ?? 'Failed to log shot',
      );
    } catch (e) {
      return ApiResponse<ShotLog>(
        success: false,
        message: e.toString(),
      );
    }
  }

  /// Get shot history with optional filters
  Future<ApiResponse<ShotHistoryResponse>> getShotHistory({
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

      if (startDate != null) {
        queryParams['startDate'] = startDate.toIso8601String();
      }
      if (endDate != null) {
        queryParams['endDate'] = endDate.toIso8601String();
      }

      final response = await _apiClient.get(
        '/api/treatments/shots',
        queryParameters: queryParams,
      );

      if (response.data['success'] == true && response.data['data'] != null) {
        final historyResponse = ShotHistoryResponse.fromJson(response.data['data']);
        return ApiResponse<ShotHistoryResponse>(
          success: true,
          message: 'Shot history retrieved successfully',
          data: historyResponse,
        );
      }

      return ApiResponse<ShotHistoryResponse>(
        success: false,
        message: response.data['message'] ?? 'Failed to get shot history',
      );
    } catch (e) {
      return ApiResponse<ShotHistoryResponse>(
        success: false,
        message: e.toString(),
      );
    }
  }

  /// Get the latest shot
  Future<ApiResponse<Map<String, dynamic>>> getLatestShot() async {
    try {
      final response = await _apiClient.get('/api/treatments/shots/latest');

      if (response.data['success'] == true && response.data['data'] != null) {
        final data = response.data['data'];
        return ApiResponse<Map<String, dynamic>>(
          success: true,
          message: 'Latest shot retrieved successfully',
          data: {
            'shot': ShotLog.fromJson(data['shot']),
            'medicationLevel': MedicationLevel.fromJson(data['medicationLevel']),
            'countdown': data['countdown'],
          },
        );
      }

      return ApiResponse<Map<String, dynamic>>(
        success: false,
        message: response.data['message'] ?? 'No shots found',
      );
    } catch (e) {
      return ApiResponse<Map<String, dynamic>>(
        success: false,
        message: e.toString(),
      );
    }
  }

  /// Get next shot due date and countdown
  Future<ApiResponse<NextShotInfo>> getNextShotInfo() async {
    try {
      final response = await _apiClient.get('/api/treatments/shots/next');

      if (response.data['success'] == true && response.data['data'] != null) {
        final nextShotInfo = NextShotInfo.fromJson(response.data['data']);
        return ApiResponse<NextShotInfo>(
          success: true,
          message: 'Next shot info retrieved successfully',
          data: nextShotInfo,
        );
      }

      return ApiResponse<NextShotInfo>(
        success: false,
        message: response.data['message'] ?? 'Failed to get next shot info',
      );
    } catch (e) {
      return ApiResponse<NextShotInfo>(
        success: false,
        message: e.toString(),
      );
    }
  }

  /// Get current medication level
  Future<ApiResponse<MedicationLevel>> getMedicationLevel() async {
    try {
      final response = await _apiClient.get('/api/treatments/medication-level');

      if (response.data['success'] == true && response.data['data'] != null) {
        final medicationLevel = MedicationLevel.fromJson(response.data['data']);
        return ApiResponse<MedicationLevel>(
          success: true,
          message: 'Medication level retrieved successfully',
          data: medicationLevel,
        );
      }

      return ApiResponse<MedicationLevel>(
        success: false,
        message: response.data['message'] ?? 'Failed to get medication level',
      );
    } catch (e) {
      return ApiResponse<MedicationLevel>(
        success: false,
        message: e.toString(),
      );
    }
  }

  /// Get recommended injection sites
  Future<ApiResponse<InjectionSiteRecommendation>> getRecommendedSites() async {
    try {
      final response = await _apiClient.get('/api/treatments/injection-sites/recommend');

      if (response.data['success'] == true && response.data['data'] != null) {
        final recommendation = InjectionSiteRecommendation.fromJson(response.data['data']);
        return ApiResponse<InjectionSiteRecommendation>(
          success: true,
          message: 'Recommendations retrieved successfully',
          data: recommendation,
        );
      }

      return ApiResponse<InjectionSiteRecommendation>(
        success: false,
        message: response.data['message'] ?? 'Failed to get recommendations',
      );
    } catch (e) {
      return ApiResponse<InjectionSiteRecommendation>(
        success: false,
        message: e.toString(),
      );
    }
  }

  /// Get treatment statistics
  Future<ApiResponse<TreatmentStats>> getStats() async {
    try {
      final response = await _apiClient.get('/api/treatments/stats');

      if (response.data['success'] == true && response.data['data'] != null) {
        final stats = TreatmentStats.fromJson(response.data['data']);
        return ApiResponse<TreatmentStats>(
          success: true,
          message: 'Statistics retrieved successfully',
          data: stats,
        );
      }

      return ApiResponse<TreatmentStats>(
        success: false,
        message: response.data['message'] ?? 'Failed to get statistics',
      );
    } catch (e) {
      return ApiResponse<TreatmentStats>(
        success: false,
        message: e.toString(),
      );
    }
  }

  /// Update a shot log
  Future<ApiResponse<ShotLog>> updateShot(String shotId, ShotLogRequest request) async {
    try {
      final response = await _apiClient.put(
        '/api/treatments/shots/$shotId',
        data: request.toJson(),
      );

      if (response.data['success'] == true && response.data['data'] != null) {
        final shotLog = ShotLog.fromJson(response.data['data']);
        return ApiResponse<ShotLog>(
          success: true,
          message: response.data['message'] ?? 'Shot updated successfully',
          data: shotLog,
        );
      }

      return ApiResponse<ShotLog>(
        success: false,
        message: response.data['message'] ?? 'Failed to update shot',
      );
    } catch (e) {
      return ApiResponse<ShotLog>(
        success: false,
        message: e.toString(),
      );
    }
  }

  /// Delete a shot log
  Future<ApiResponse<void>> deleteShot(String shotId) async {
    try {
      final response = await _apiClient.delete('/api/treatments/shots/$shotId');

      if (response.data['success'] == true) {
        return ApiResponse<void>(
          success: true,
          message: response.data['message'] ?? 'Shot deleted successfully',
        );
      }

      return ApiResponse<void>(
        success: false,
        message: response.data['message'] ?? 'Failed to delete shot',
      );
    } catch (e) {
      return ApiResponse<void>(
        success: false,
        message: e.toString(),
      );
    }
  }
}
