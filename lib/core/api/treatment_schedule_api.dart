import 'package:dio/dio.dart';

class TreatmentScheduleApi {
  final Dio _dio;

  TreatmentScheduleApi(this._dio);

  /// Create or update treatment schedule
  Future<Map<String, dynamic>> createOrUpdateSchedule({
    required String medication,
    required String dosage,
    required String frequency,
    String? preferredTime,
    String? specificTime,
    int? customInterval,
    Map<String, dynamic>? reminders,
  }) async {
    try {
      final data = {
        'medication': medication,
        'dosage': dosage,
        'frequency': frequency,
        if (preferredTime != null) 'preferredTime': preferredTime,
        if (specificTime != null) 'specificTime': specificTime,
        if (customInterval != null) 'customInterval': customInterval,
        if (reminders != null) 'reminders': reminders,
      };

      final response = await _dio.post('/api/treatment-schedule', data: data);
      return response.data;
    } catch (e) {
      throw Exception('Failed to create/update treatment schedule: ${e.toString()}');
    }
  }

  /// Get current treatment schedule
  Future<Map<String, dynamic>> getCurrentSchedule() async {
    try {
      final response = await _dio.get('/api/treatment-schedule');
      return response.data;
    } catch (e) {
      throw Exception('Failed to get treatment schedule: ${e.toString()}');
    }
  }

  /// Update specific treatment schedule
  Future<Map<String, dynamic>> updateSchedule({
    required String scheduleId,
    String? medication,
    String? dosage,
    String? frequency,
    String? preferredTime,
    String? specificTime,
    int? customInterval,
    bool? isActive,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (medication != null) data['medication'] = medication;
      if (dosage != null) data['dosage'] = dosage;
      if (frequency != null) data['frequency'] = frequency;
      if (preferredTime != null) data['preferredTime'] = preferredTime;
      if (specificTime != null) data['specificTime'] = specificTime;
      if (customInterval != null) data['customInterval'] = customInterval;
      if (isActive != null) data['isActive'] = isActive;

      final response = await _dio.put(
        '/api/treatment-schedule/$scheduleId',
        data: data,
      );
      return response.data;
    } catch (e) {
      throw Exception('Failed to update treatment schedule: ${e.toString()}');
    }
  }

  /// Get adherence analytics
  Future<Map<String, dynamic>> getAdherenceAnalytics({
    int days = 30,
  }) async {
    try {
      final response = await _dio.get(
        '/api/treatment-schedule/adherence',
        queryParameters: {'days': days},
      );
      return response.data;
    } catch (e) {
      throw Exception('Failed to get adherence analytics: ${e.toString()}');
    }
  }

  /// Get treatment schedule calendar view
  Future<Map<String, dynamic>> getCalendarView({
    int? month,
    int? year,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (month != null) queryParams['month'] = month;
      if (year != null) queryParams['year'] = year;

      final response = await _dio.get(
        '/api/treatment-schedule/calendar',
        queryParameters: queryParams,
      );
      return response.data;
    } catch (e) {
      throw Exception('Failed to get calendar view: ${e.toString()}');
    }
  }

  /// Test reminder functionality
  Future<Map<String, dynamic>> testReminder({
    required String type,
    required int hours,
  }) async {
    try {
      final data = {
        'type': type,
        'hours': hours,
      };

      final response = await _dio.post(
        '/api/treatment-schedule/reminders/test',
        data: data,
      );
      return response.data;
    } catch (e) {
      throw Exception('Failed to test reminder: ${e.toString()}');
    }
  }
}
