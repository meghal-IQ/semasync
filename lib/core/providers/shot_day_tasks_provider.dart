import 'package:flutter/foundation.dart';
import '../api/shot_day_tasks_api.dart';
import '../services/api_client.dart';

class ShotDayTasksProvider with ChangeNotifier {
  final ShotDayTasksApi _api = ShotDayTasksApi(ApiClient().dio);

  List<Map<String, dynamic>> _tasks = [];
  List<int> _selectedDays = [];
  bool _isLoading = false;
  String? _error;
  DateTime _currentDate = DateTime.now();

  List<Map<String, dynamic>> get tasks => _tasks;
  List<int> get selectedDays => _selectedDays;
  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTime get currentDate => _currentDate;

  // Load tasks for a specific date
  Future<void> loadTasks({DateTime? date}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final targetDate = date ?? DateTime.now();
      _currentDate = targetDate;
      
      final dateString = targetDate.toIso8601String().split('T')[0];
      final response = await _api.getShotDayTasks(date: dateString);

      if (response['success'] == true && response['data'] != null) {
        final data = response['data'];
        _tasks = List<Map<String, dynamic>>.from(
          (data['tasks'] as List).map((task) => Map<String, dynamic>.from(task))
        );
        _selectedDays = List<int>.from(data['selectedDays'] ?? []);
      }
    } catch (e) {
      _error = e.toString();
      print('Error loading shot day tasks: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Toggle a task
  Future<void> toggleTask(int taskIndex) async {
    if (taskIndex < 0 || taskIndex >= _tasks.length) return;

    try {
      // Optimistic update
      _tasks[taskIndex]['completed'] = !_tasks[taskIndex]['completed'];
      notifyListeners();

      final dateString = _currentDate.toIso8601String().split('T')[0];
      final response = await _api.toggleTask(
        date: dateString,
        taskIndex: taskIndex,
      );

      if (response['success'] == true && response['data'] != null) {
        // Update with server response
        final data = response['data'];
        _tasks = List<Map<String, dynamic>>.from(
          (data['tasks'] as List).map((task) => Map<String, dynamic>.from(task))
        );
        notifyListeners();
      }
    } catch (e) {
      // Revert on error
      _tasks[taskIndex]['completed'] = !_tasks[taskIndex]['completed'];
      _error = e.toString();
      print('Error toggling task: $e');
      notifyListeners();
    }
  }

  // Update all tasks
  Future<void> updateTasks(List<Map<String, dynamic>> tasks) async {
    try {
      _tasks = tasks;
      notifyListeners();

      final dateString = _currentDate.toIso8601String().split('T')[0];
      await _api.updateShotDayTasks(
        date: dateString,
        tasks: tasks,
        selectedDays: _selectedDays,
      );
    } catch (e) {
      _error = e.toString();
      print('Error updating tasks: $e');
      notifyListeners();
    }
  }

  // Update selected days
  Future<void> updateSelectedDays(List<int> days) async {
    try {
      _selectedDays = days;
      notifyListeners();

      await _api.updateSelectedDays(selectedDays: days);
    } catch (e) {
      _error = e.toString();
      print('Error updating selected days: $e');
      notifyListeners();
    }
  }

  // Reset all tasks to unchecked
  Future<void> resetAllTasks() async {
    try {
      for (var task in _tasks) {
        task['completed'] = false;
      }
      notifyListeners();

      final dateString = _currentDate.toIso8601String().split('T')[0];
      await _api.updateShotDayTasks(
        date: dateString,
        tasks: _tasks,
        selectedDays: _selectedDays,
      );
    } catch (e) {
      _error = e.toString();
      print('Error resetting tasks: $e');
      notifyListeners();
    }
  }

  // Check if today is a shot day
  bool isShotDay() {
    final today = DateTime.now().weekday;
    return _selectedDays.contains(today);
  }
}

