import 'package:flutter/foundation.dart';
import '../api/models/nutrition_log_model.dart';
import '../api/models/todays_log_model.dart';
import '../api/services/nutrition_service.dart';

class NutritionProvider extends ChangeNotifier {
  final NutritionService _nutritionService = NutritionService();

  // State
  bool _isLoading = false;
  String? _errorMessage;

  // Meal data
  List<MealLog> _mealHistory = [];
  DailyNutritionSummary? _dailySummary;

  // Water data
  List<WaterLog> _waterHistory = [];

  // Today's log data
  TodaysLogResponse? _todaysLog;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<MealLog> get mealHistory => _mealHistory;
  DailyNutritionSummary? get dailySummary => _dailySummary;
  List<WaterLog> get waterHistory => _waterHistory;
  TodaysLogResponse? get todaysLog => _todaysLog;

  // ============================================================================
  // MEAL TRACKING
  // ============================================================================

  Future<bool> logMeal(MealLogRequest request) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _nutritionService.logMeal(request);

      if (response.success) {
        await loadNutritionData();
        await loadTodaysLog(); // Refresh Today's Log
        _setLoading(false);
        return true;
      } else {
        _setError(response.message);
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Failed to log meal: $e');
      _setLoading(false);
      return false;
    }
  }

  // ============================================================================
  // WATER TRACKING
  // ============================================================================

  Future<bool> logWater(WaterLogRequest request) async {
    print('=== NutritionProvider.logWater START ===');
    print('Request entries:'+request.entries.length.toString());
    request.entries.forEach((entry) {
      print('  Entry: ${entry.time} - ${entry.amount}ml (${entry.type})');
    });

    _setLoading(true);
    _clearError();

    try {
      print('Calling nutritionService.logWater...');
      final response = await _nutritionService.logWater(request);
      print('API response success:'+ response.success.toString());
      print('API response message:'+ response.message);

      if (response.success) {
        print('API call successful, reloading data...');
        // Reload nutrition data to get updated totals
        await loadNutritionData();
        print('loadNutritionData completed');
        // Also refresh daily summary specifically
        await loadDailySummary();
        print('loadDailySummary completed');
        // Refresh Today's Log
        await loadTodaysLog();
        print('loadTodaysLog completed');
        _setLoading(false);
        print('=== NutritionProvider.logWater SUCCESS ===');
        return true;
      } else {
        print('API call failed:'+ response.message);
        _setError(response.message);
        _setLoading(false);
        return false;
      }
    } catch (e) {
      print('Exception in logWater:'+ e.toString());
      _setError('Failed to log water: $e');
      _setLoading(false);
      return false;
    }
  }

  // ============================================================================
  // DATA LOADING
  // ============================================================================

  Future<void> loadNutritionData() async {
    _setLoading(true);

    try {
      final results = await Future.wait([
        _nutritionService.getMealHistory(),
        _nutritionService.getWaterHistory(),
        _nutritionService.getDailySummary(),
      ]);

      if (results[0].success && results[0].data != null) {
        _mealHistory = results[0].data as List<MealLog>;
      }

      if (results[1].success && results[1].data != null) {
        _waterHistory = results[1].data as List<WaterLog>;
      }

      if (results[2].success && results[2].data != null) {
        _dailySummary = results[2].data as DailyNutritionSummary;
      }

      _setLoading(false);
      notifyListeners(); // Ensure UI updates after data loading
    } catch (e) {
      _setError('Failed to load nutrition data: $e');
      _setLoading(false);
    }
  }

  Future<void> loadDailySummary({String? date}) async {
    print('=== loadDailySummary START ===');
    try {
      final response = await _nutritionService.getDailySummary(date: date);
      print('Daily summary API response success:'+ response.success.toString());

        if (response.success && response.data != null) {
          print('Old daily summary water: ${_dailySummary?.water ?? 'null'}');
          _dailySummary = response.data;
          print('New daily summary water: ${_dailySummary?.water ?? 'null'}');
          notifyListeners();
          print('notifyListeners() called');
        } else {
          print('Daily summary API failed or no data');
        }
    } catch (e) {
      print('Error loading daily summary: $e');
    }
    print('=== loadDailySummary END ===');
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
    _mealHistory = [];
    _waterHistory = [];
    _dailySummary = null;
    _todaysLog = null;
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }

  // ============================================================================
  // TODAY'S LOG
  // ============================================================================

  Future<void> loadTodaysLog() async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _nutritionService.getTodaysLog();
      
      if (response.success && response.data != null) {
        _todaysLog = response.data;
        _setLoading(false);
        notifyListeners();
      } else {
        _setError(response.message);
        _setLoading(false);
      }
    } catch (e) {
      _setError('Failed to load today\'s log: $e');
      _setLoading(false);
    }
  }
}
