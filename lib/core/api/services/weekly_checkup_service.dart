import 'package:dio/dio.dart';
import '../models/weekly_checkup_model.dart';

class WeeklyCheckupService {
  final Dio _dio;

  WeeklyCheckupService(this._dio);

  /// Create a new weekly checkup
  Future<Map<String, dynamic>> createWeeklyCheckup(WeeklyCheckupRequest request, [Map<String, dynamic>? additionalData]) async {
    try {
      final data = request.toJson();
      
      // Add additional data if provided
      if (additionalData != null) {
        data.addAll(additionalData);
      }
      
      final response = await _dio.post(
        '/api/treatments/weekly-checkup',
        data: data,
      );

      return response.data;
    } catch (e) {
      throw Exception('Failed to create weekly checkup: ${e.toString()}');
    }
  }

  /// Get weekly checkup history
  Future<Map<String, dynamic>> getWeeklyCheckups({
    DateTime? startDate,
    DateTime? endDate,
    int limit = 50,
    int page = 1,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'limit': limit,
        'page': page,
        if (startDate != null) 'startDate': startDate.toIso8601String(),
        if (endDate != null) 'endDate': endDate.toIso8601String(),
      };

      final response = await _dio.get(
        '/api/treatments/weekly-checkup',
        queryParameters: queryParams,
      );

      return response.data;
    } catch (e) {
      throw Exception('Failed to get weekly checkups: ${e.toString()}');
    }
  }

  /// Get the latest weekly checkup
  Future<Map<String, dynamic>> getLatestWeeklyCheckup() async {
    try {
      final response = await _dio.get('/api/treatments/weekly-checkup/latest');

      return response.data;
    } catch (e) {
      throw Exception('Failed to get latest weekly checkup: ${e.toString()}');
    }
  }

  /// Get weekly checkup analytics
  Future<Map<String, dynamic>> getWeeklyCheckupAnalytics({
    int weeks = 12,
  }) async {
    try {
      final response = await _dio.get(
        '/api/treatments/weekly-checkup/analytics',
        queryParameters: {'weeks': weeks},
      );

      return response.data;
    } catch (e) {
      throw Exception('Failed to get weekly checkup analytics: ${e.toString()}');
    }
  }

  /// Update a weekly checkup
  Future<Map<String, dynamic>> updateWeeklyCheckup(
    String checkupId,
    WeeklyCheckupRequest request,
  ) async {
    try {
      final response = await _dio.put(
        '/api/treatments/weekly-checkup/$checkupId',
        data: request.toJson(),
      );

      return response.data;
    } catch (e) {
      throw Exception('Failed to update weekly checkup: ${e.toString()}');
    }
  }

  /// Delete a weekly checkup
  Future<Map<String, dynamic>> deleteWeeklyCheckup(String checkupId) async {
    try {
      final response = await _dio.delete('/api/treatments/weekly-checkup/$checkupId');

      return response.data;
    } catch (e) {
      throw Exception('Failed to delete weekly checkup: ${e.toString()}');
    }
  }
}
