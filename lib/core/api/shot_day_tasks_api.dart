import 'package:dio/dio.dart';
import '../services/api_client.dart';

class ShotDayTasksApi {
  final Dio _dio;

  ShotDayTasksApi(this._dio);

  // Get shot day tasks for a specific date
  Future<Map<String, dynamic>> getShotDayTasks({String? date}) async {
    try {
      final queryParams = date != null ? {'date': date} : null;
      final response = await _dio.get(
        '/api/shot-day-tasks',
        queryParameters: queryParams,
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  // Update shot day tasks
  Future<Map<String, dynamic>> updateShotDayTasks({
    required String date,
    required List<Map<String, dynamic>> tasks,
    List<int>? selectedDays,
  }) async {
    try {
      final response = await _dio.put(
        '/api/shot-day-tasks',
        data: {
          'date': date,
          'tasks': tasks,
          if (selectedDays != null) 'selectedDays': selectedDays,
        },
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  // Update selected shot days (days of week)
  Future<Map<String, dynamic>> updateSelectedDays({
    required List<int> selectedDays,
  }) async {
    try {
      final response = await _dio.put(
        '/api/shot-day-tasks/selected-days',
        data: {
          'selectedDays': selectedDays,
        },
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  // Toggle a specific task
  Future<Map<String, dynamic>> toggleTask({
    required String date,
    required int taskIndex,
  }) async {
    try {
      final response = await _dio.patch(
        '/api/shot-day-tasks/toggle-task',
        data: {
          'date': date,
          'taskIndex': taskIndex,
        },
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }
}

