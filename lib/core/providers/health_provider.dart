import 'package:flutter/foundation.dart';
import '../api/models/weight_log_model.dart';
import '../api/models/side_effect_log_model.dart';
import '../api/services/health_service.dart';

class HealthProvider extends ChangeNotifier {
  final HealthService _healthService = HealthService();

  // State
  bool _isLoading = false;
  String? _errorMessage;

  // Weight data
  List<WeightLog> _weightHistory = [];
  WeightStats? _weightStats;

  // Side effects data
  List<SideEffectLog> _sideEffects = [];
  SideEffectTrends? _sideEffectTrends;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<WeightLog> get weightHistory => _weightHistory;
  WeightStats? get weightStats => _weightStats;
  List<SideEffectLog> get sideEffects => _sideEffects;
  SideEffectTrends? get sideEffectTrends => _sideEffectTrends;

  // ============================================================================
  // WEIGHT TRACKING
  // ============================================================================

  Future<bool> logWeight(WeightLogRequest request) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _healthService.logWeight(request);

      if (response.success) {
        await loadWeightData();
        _setLoading(false);
        return true;
      } else {
        _setError(response.message);
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Failed to log weight: $e');
      _setLoading(false);
      return false;
    }
  }

  Future<void> loadWeightData() async {
    try {
      final results = await Future.wait([
        _healthService.getWeightHistory(),
        _healthService.getWeightStats(),
      ]);

      final historyResponse = results[0];
      final statsResponse = results[1];

      if (historyResponse.success && historyResponse.data != null) {
        _weightHistory = (historyResponse.data as WeightHistoryResponse).weights;
      }

      if (statsResponse.success && statsResponse.data != null) {
        _weightStats = statsResponse.data as WeightStats;
      }

      notifyListeners();
    } catch (e) {
      print('Error loading weight data: $e');
    }
  }

  Future<bool> deleteWeight(String weightId) async {
    _setLoading(true);

    try {
      final response = await _healthService.deleteWeight(weightId);

      if (response.success) {
        await loadWeightData();
        _setLoading(false);
        return true;
      } else {
        _setError(response.message);
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Failed to delete weight: $e');
      _setLoading(false);
      return false;
    }
  }

  // ============================================================================
  // SIDE EFFECTS TRACKING
  // ============================================================================

  Future<bool> logSideEffects(SideEffectLogRequest request) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _healthService.logSideEffects(request);

      if (response.success) {
        await loadSideEffectsData();
        _setLoading(false);
        return true;
      } else {
        _setError(response.message);
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Failed to log side effects: $e');
      _setLoading(false);
      return false;
    }
  }

  Future<void> loadSideEffectsData() async {
    try {
      final results = await Future.wait([
        _healthService.getSideEffects(),
        _healthService.getSideEffectTrends(),
      ]);

      final historyResponse = results[0];
      final trendsResponse = results[1];

      if (historyResponse.success && historyResponse.data != null) {
        _sideEffects = historyResponse.data as List<SideEffectLog>;
      }

      if (trendsResponse.success && trendsResponse.data != null) {
        _sideEffectTrends = trendsResponse.data as SideEffectTrends;
      }

      notifyListeners();
    } catch (e) {
      print('Error loading side effects data: $e');
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
    _weightHistory = [];
    _weightStats = null;
    _sideEffects = [];
    _sideEffectTrends = null;
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }
}
