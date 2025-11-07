import 'package:flutter/foundation.dart';
import '../api/models/activity_log_model.dart';
import '../api/services/activity_service.dart';

class ActivityProvider extends ChangeNotifier {
  final ActivityService _activityService = ActivityService();

  // State
  bool _isLoading = false;
  String? _errorMessage;

  // Steps data
  List<StepLog> _stepsHistory = [];
  StepStats? _stepsStats;

  // Workout data
  List<WorkoutLog> _workoutsHistory = [];
  WorkoutStats? _workoutStats;

  // Summary
  ActivitySummary? _activitySummary;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<StepLog> get stepsHistory => _stepsHistory;
  StepStats? get stepsStats => _stepsStats;
  List<WorkoutLog> get workoutsHistory => _workoutsHistory;
  WorkoutStats? get workoutStats => _workoutStats;
  ActivitySummary? get activitySummary => _activitySummary;

  // ============================================================================
  // STEPS TRACKING
  // ============================================================================

  Future<bool> logSteps(StepLog stepLog) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _activityService.logSteps(stepLog);

      if (response.success) {
        await loadActivityData();
        _setLoading(false);
        return true;
      } else {
        _setError(response.message);
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Failed to log steps: $e');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> deleteStepLog(String id) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _activityService.deleteStepLog(id);

      if (response.success) {
        // Clear error before reloading
        _clearError();
        // Remove the deleted step log from local list immediately
        _stepsHistory.removeWhere((log) => log.id == id);
        notifyListeners();
        // Then reload data in background
        loadActivityData().catchError((e) {
          // Silently handle reload errors after deletion
          print('Error reloading after deletion: $e');
        });
        _setLoading(false);
        return true;
      } else {
        _setError(response.message);
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Failed to delete step log: $e');
      _setLoading(false);
      return false;
    }
  }

  // ============================================================================
  // WORKOUT TRACKING
  // ============================================================================

  Future<bool> logWorkout(WorkoutLog workout) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _activityService.logWorkout(workout);

      if (response.success) {
        await loadActivityData();
        _setLoading(false);
        return true;
      } else {
        _setError(response.message);
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Failed to log workout: $e');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> deleteWorkoutLog(String id) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _activityService.deleteWorkoutLog(id);

      if (response.success) {
        // Clear error before reloading
        _clearError();
        // Remove the deleted workout from local list immediately
        _workoutsHistory.removeWhere((log) => log.id == id);
        notifyListeners();
        // Then reload data in background
        loadActivityData().catchError((e) {
          // Silently handle reload errors after deletion
          print('Error reloading after deletion: $e');
        });
        _setLoading(false);
        return true;
      } else {
        _setError(response.message);
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Failed to delete workout log: $e');
      _setLoading(false);
      return false;
    }
  }

  // ============================================================================
  // DATA LOADING
  // ============================================================================

  Future<void> loadActivityData() async {
    _setLoading(true);
    _clearError(); // Clear any previous errors before loading

    try {
      final results = await Future.wait([
        _activityService.getStepsHistory(),
        _activityService.getStepsStats(),
        _activityService.getWorkoutsHistory(),
        _activityService.getWorkoutStats(),
        _activityService.getActivitySummary(),
      ]);

      // Update data only if requests succeeded
      if (results[0].success && results[0].data != null) {
        _stepsHistory = results[0].data as List<StepLog>;
      }

      if (results[1].success && results[1].data != null) {
        _stepsStats = results[1].data as StepStats;
      }

      if (results[2].success && results[2].data != null) {
        _workoutsHistory = results[2].data as List<WorkoutLog>;
      } else if (!results[2].success) {
        // If workout history fails, check if it's a 404 (route not found)
        final errorMsg = results[2].message.toLowerCase();
        if (errorMsg.contains('route not found') || errorMsg.contains('404')) {
          // If route doesn't exist, just set empty list instead of showing error
          _workoutsHistory = [];
        } else {
          // Only set error for non-404 errors
          _setError(results[2].message);
        }
      }

      if (results[3].success && results[3].data != null) {
        _workoutStats = results[3].data as WorkoutStats;
      }

      if (results[4].success && results[4].data != null) {
        _activitySummary = results[4].data as ActivitySummary;
      }

      _setLoading(false);
    } catch (e) {
      final errorMsg = e.toString().toLowerCase();
      // Only show error if it's not a 404 or route not found
      if (!errorMsg.contains('route not found') && !errorMsg.contains('404')) {
        _setError('Failed to load activity data: $e');
      } else {
        // For 404 errors, just set empty lists
        _workoutsHistory = [];
        _stepsHistory = [];
      }
      _setLoading(false);
    }
  }

  // ============================================================================
  // HELPER METHODS
  // ============================================================================

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  void clear() {
    _stepsHistory = [];
    _stepsStats = null;
    _workoutsHistory = [];
    _workoutStats = null;
    _activitySummary = null;
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }
}
