import '../api_client.dart';
import '../models/api_response.dart';
import '../models/activity_log_model.dart';

class ActivityService {
  final ApiClient _apiClient = ApiClient();

  // ============================================================================
  // STEPS TRACKING
  // ============================================================================

  Future<ApiResponse<StepLog>> logSteps(StepLog stepLog) async {
    try {
      final response = await _apiClient.post(
        '/api/activity/steps',
        data: stepLog.toJson(),
      );

      if (response.data['success'] == true && response.data['data'] != null) {
        final log = StepLog.fromJson(response.data['data']);
        return ApiResponse<StepLog>(
          success: true,
          message: response.data['message'] ?? 'Steps logged successfully',
          data: log,
        );
      }

      return ApiResponse<StepLog>(
        success: false,
        message: response.data['message'] ?? 'Failed to log steps',
      );
    } catch (e) {
      return ApiResponse<StepLog>(
        success: false,
        message: e.toString(),
      );
    }
  }

  Future<ApiResponse<List<StepLog>>> getStepsHistory({
    int limit = 30,
    int page = 1,
  }) async {
    try {
      final response = await _apiClient.get(
        '/api/activity/steps',
        queryParameters: {
          'limit': limit.toString(),
          'page': page.toString(),
        },
      );

      if (response.data['success'] == true && response.data['data'] != null) {
        final logs = (response.data['data']['steps'] as List)
            .map((e) => StepLog.fromJson(e))
            .toList();
        return ApiResponse<List<StepLog>>(
          success: true,
          message: 'Steps history retrieved',
          data: logs,
        );
      }

      return ApiResponse<List<StepLog>>(
        success: false,
        message: response.data['message'] ?? 'Failed to get steps',
      );
    } catch (e) {
      return ApiResponse<List<StepLog>>(
        success: false,
        message: e.toString(),
      );
    }
  }

  Future<ApiResponse<StepStats>> getStepsStats() async {
    try {
      final response = await _apiClient.get('/api/activity/steps/stats');

      if (response.data['success'] == true && response.data['data'] != null) {
        final stats = StepStats.fromJson(response.data['data']);
        return ApiResponse<StepStats>(
          success: true,
          message: 'Statistics retrieved',
          data: stats,
        );
      }

      return ApiResponse<StepStats>(
        success: false,
        message: response.data['message'] ?? 'Failed to get statistics',
      );
    } catch (e) {
      return ApiResponse<StepStats>(
        success: false,
        message: e.toString(),
      );
    }
  }

  // ============================================================================
  // WORKOUT TRACKING
  // ============================================================================

  Future<ApiResponse<WorkoutLog>> logWorkout(WorkoutLog workout) async {
    try {
      final response = await _apiClient.post(
        '/api/activity/workouts',
        data: workout.toJson(),
      );

      if (response.data['success'] == true && response.data['data'] != null) {
        final log = WorkoutLog.fromJson(response.data['data']);
        return ApiResponse<WorkoutLog>(
          success: true,
          message: response.data['message'] ?? 'Workout logged successfully',
          data: log,
        );
      }

      return ApiResponse<WorkoutLog>(
        success: false,
        message: response.data['message'] ?? 'Failed to log workout',
      );
    } catch (e) {
      return ApiResponse<WorkoutLog>(
        success: false,
        message: e.toString(),
      );
    }
  }

  Future<ApiResponse<List<WorkoutLog>>> getWorkoutsHistory({
    int limit = 30,
    int page = 1,
  }) async {
    try {
      final response = await _apiClient.get(
        '/api/activity/workouts',
        queryParameters: {
          'limit': limit.toString(),
          'page': page.toString(),
        },
      );

      if (response.data['success'] == true && response.data['data'] != null) {
        final logs = (response.data['data']['workouts'] as List)
            .map((e) => WorkoutLog.fromJson(e))
            .toList();
        return ApiResponse<List<WorkoutLog>>(
          success: true,
          message: 'Workouts retrieved',
          data: logs,
        );
      }

      return ApiResponse<List<WorkoutLog>>(
        success: false,
        message: response.data['message'] ?? 'Failed to get workouts',
      );
    } catch (e) {
      return ApiResponse<List<WorkoutLog>>(
        success: false,
        message: e.toString(),
      );
    }
  }

  Future<ApiResponse<WorkoutStats>> getWorkoutStats() async {
    try {
      final response = await _apiClient.get('/api/activity/workouts/stats');

      if (response.data['success'] == true && response.data['data'] != null) {
        final stats = WorkoutStats.fromJson(response.data['data']);
        return ApiResponse<WorkoutStats>(
          success: true,
          message: 'Statistics retrieved',
          data: stats,
        );
      }

      return ApiResponse<WorkoutStats>(
        success: false,
        message: response.data['message'] ?? 'Failed to get statistics',
      );
    } catch (e) {
      return ApiResponse<WorkoutStats>(
        success: false,
        message: e.toString(),
      );
    }
  }

  Future<ApiResponse<ActivitySummary>> getActivitySummary() async {
    try {
      final response = await _apiClient.get('/api/activity/summary');

      if (response.data['success'] == true && response.data['data'] != null) {
        final summary = ActivitySummary.fromJson(response.data['data']);
        return ApiResponse<ActivitySummary>(
          success: true,
          message: 'Summary retrieved',
          data: summary,
        );
      }

      return ApiResponse<ActivitySummary>(
        success: false,
        message: response.data['message'] ?? 'Failed to get summary',
      );
    } catch (e) {
      return ApiResponse<ActivitySummary>(
        success: false,
        message: e.toString(),
      );
    }
  }
}
