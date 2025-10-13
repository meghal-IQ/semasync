import 'package:flutter/foundation.dart';
import '../api/services/dashboard_service.dart';
import '../api/models/user_model.dart';

class DashboardProvider extends ChangeNotifier {
  final DashboardService _dashboardService = DashboardService();

  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Getters for dashboard data
  double get currentWeight => _user?.weight ?? 0.0;
  double get medicationLevel => _user?.glp1Journey.currentDose != null 
      ? double.tryParse(_user!.glp1Journey.currentDose!.replaceAll('mg', '')) ?? 0.0 
      : 0.0;
  String get medicationName => _user?.glp1Journey.medication ?? 'Unknown';

  // Nutrition data (these would typically come from a separate nutrition tracking system)
  double get fiberIntake => 0.0; // TODO: Implement nutrition tracking
  double get waterIntake => 0.0; // TODO: Implement nutrition tracking
  double get proteinIntake => 0.0; // TODO: Implement nutrition tracking

  // Goals
  double get targetWeight => _user?.goals.targetWeight ?? 0.0;
  double get targetDate => _user?.goals.targetDate?.millisecondsSinceEpoch.toDouble() ?? 0.0;

  /// Load dashboard data
  Future<void> loadDashboardData() async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _dashboardService.getDashboardData();
      
      if (response.success && response.data != null) {
        _user = response.data;
      } else {
        _setError(response.message);
      }
    } catch (e) {
      _setError('Failed to load dashboard data: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Update medication level
  Future<bool> updateMedicationLevel(double level) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _dashboardService.updateMedicationLevel(level);
      
      if (response.success) {
        // Reload data to get updated values
        await loadDashboardData();
        return true;
      } else {
        _setError(response.message);
        return false;
      }
    } catch (e) {
      _setError('Failed to update medication level: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Update nutrition tracking
  Future<bool> updateNutrition({
    required double fiber,
    required double water,
    required double protein,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _dashboardService.updateNutrition(
        fiber: fiber,
        water: water,
        protein: protein,
      );
      
      if (response.success) {
        // Reload data to get updated values
        await loadDashboardData();
        return true;
      } else {
        _setError(response.message);
        return false;
      }
    } catch (e) {
      _setError('Failed to update nutrition: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Update weight
  Future<bool> updateWeight(double weight) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _dashboardService.updateWeight(weight);
      
      if (response.success) {
        // Reload data to get updated values
        await loadDashboardData();
        return true;
      } else {
        _setError(response.message);
        return false;
      }
    } catch (e) {
      _setError('Failed to update weight: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }
}



