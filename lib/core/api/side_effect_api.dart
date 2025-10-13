import 'package:dio/dio.dart';

class SideEffectApi {
  final Dio _dio;

  SideEffectApi(this._dio);

  /// Log new side effects
  Future<Map<String, dynamic>> logSideEffects({
    DateTime? date,
    required List<Map<String, dynamic>> effects,
    required double overallSeverity,
    String? notes,
    bool? relatedToShot,
    String? shotId,
  }) async {
    try {
      final data = {
        if (date != null) 'date': date.toIso8601String(),
        'effects': effects,
        'overallSeverity': overallSeverity,
        if (notes != null) 'notes': notes,
        if (relatedToShot != null) 'relatedToShot': relatedToShot,
        if (shotId != null) 'shotId': shotId,
      };

      final response = await _dio.post(
        '/api/treatments/side-effects',
        data: data,
      );

      return response.data;
    } catch (e) {
      throw Exception('Failed to log side effects: ${e.toString()}');
    }
  }

  /// Get side effect history with filters
  Future<Map<String, dynamic>> getSideEffects({
    DateTime? startDate,
    DateTime? endDate,
    int limit = 50,
    int page = 1,
    int? severity,
    bool? active,
    bool? relatedToShot,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'limit': limit,
        'page': page,
        if (startDate != null) 'startDate': startDate.toIso8601String(),
        if (endDate != null) 'endDate': endDate.toIso8601String(),
        if (severity != null) 'severity': severity,
        if (active != null) 'active': active,
        if (relatedToShot != null) 'relatedToShot': relatedToShot,
      };

      final response = await _dio.get(
        '/api/treatments/side-effects',
        queryParameters: queryParams,
      );

      return response.data;
    } catch (e) {
      throw Exception('Failed to get side effects: ${e.toString()}');
    }
  }

  /// Get side effect analytics and trends
  Future<Map<String, dynamic>> getSideEffectAnalytics({
    int days = 30,
    String groupBy = 'day',
  }) async {
    try {
      final queryParams = {
        'days': days,
        'groupBy': groupBy,
      };

      final response = await _dio.get(
        '/api/treatments/side-effects/analytics',
        queryParameters: queryParams,
      );

      return response.data;
    } catch (e) {
      throw Exception('Failed to get side effect analytics: ${e.toString()}');
    }
  }

  /// Get current active side effects
  Future<Map<String, dynamic>> getCurrentSideEffects() async {
    try {
      final response = await _dio.get(
        '/api/treatments/side-effects/current',
      );

      return response.data;
    } catch (e) {
      throw Exception('Failed to get current side effects: ${e.toString()}');
    }
  }

  /// Update side effect log entry
  Future<Map<String, dynamic>> updateSideEffect({
    required String id,
    DateTime? date,
    List<Map<String, dynamic>>? effects,
    double? overallSeverity,
    String? notes,
    bool? relatedToShot,
    String? shotId,
    bool? isActive,
  }) async {
    try {
      final data = <String, dynamic>{
        if (date != null) 'date': date.toIso8601String(),
        if (effects != null) 'effects': effects,
        if (overallSeverity != null) 'overallSeverity': overallSeverity,
        if (notes != null) 'notes': notes,
        if (relatedToShot != null) 'relatedToShot': relatedToShot,
        if (shotId != null) 'shotId': shotId,
        if (isActive != null) 'isActive': isActive,
      };

      final response = await _dio.put(
        '/api/treatments/side-effects/$id',
        data: data,
      );

      return response.data;
    } catch (e) {
      throw Exception('Failed to update side effect: ${e.toString()}');
    }
  }

  /// Delete side effect log entry
  Future<Map<String, dynamic>> deleteSideEffect(String id) async {
    try {
      final response = await _dio.delete(
        '/api/treatments/side-effects/$id',
      );

      return response.data;
    } catch (e) {
      throw Exception('Failed to delete side effect: ${e.toString()}');
    }
  }
}
