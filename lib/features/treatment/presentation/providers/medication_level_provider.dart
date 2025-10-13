import 'package:flutter/foundation.dart';
import '../../domain/models/medication_level.dart';
import '../../../../core/api/medication_level_api.dart';

class MedicationLevelProvider with ChangeNotifier {
  final MedicationLevelApi _medicationLevelApi;

  MedicationLevelProvider(this._medicationLevelApi);

  // Current medication level data
  Map<String, dynamic>? _currentLevel;
  MedicationLevelData? _historicalData;
  MedicationLevelTrends? _trends;
  
  // State management
  bool _isLoading = false;
  String? _error;

  // Getters
  Map<String, dynamic>? get currentLevel => _currentLevel;
  MedicationLevelData? get historicalData => _historicalData;
  MedicationLevelTrends? get trends => _trends;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Get current level percentage
  double get currentLevelPercentage {
    if (_currentLevel == null) {
      debugPrint('📊 currentLevelPercentage: _currentLevel is null, returning 0.0');
      return 0.0;
    }
    final level = (_currentLevel!['data']?['currentLevel'] ?? 0.0).toDouble();
    debugPrint('📊 currentLevelPercentage: returning $level from data: ${_currentLevel!['data']}');
    return level;
  }

  // Get current status
  String get currentStatus {
    if (_currentLevel == null) return 'optimal';
    return _currentLevel!['data']?['status'] ?? 'optimal';
  }

  // Get countdown string
  String get countdownString {
    if (_currentLevel == null) return '';
    return _currentLevel!['data']?['countdown'] ?? '';
  }

  // Get hours until next dose
  double get hoursUntilNextDose {
    if (_currentLevel == null) return 0.0;
    return (_currentLevel!['data']?['hoursUntilNextDose'] ?? 0.0).toDouble();
  }

  // Get is overdue
  bool get isOverdue {
    if (_currentLevel == null) return false;
    return _currentLevel!['data']?['isOverdue'] ?? false;
  }

  /// Load current medication level
  Future<void> loadCurrentMedicationLevel({bool forceRefresh = false}) async {
    if (_isLoading && !forceRefresh) return;

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      debugPrint('🔄 Loading current medication level...');
      final response = await _medicationLevelApi.getCurrentMedicationLevel();
      debugPrint('📊 Medication level response: $response');

      if (response['success'] == true) {
        _currentLevel = response;
        debugPrint('✅ Medication level loaded successfully');
        debugPrint('📊 Current level data: ${response['data']}');
      } else {
        _error = response['message'] ?? 'Failed to load current medication level';
        debugPrint('❌ Medication level failed: $_error');
      }
    } catch (e) {
      _error = 'Failed to load current medication level: ${e.toString()}';
      debugPrint('❌ Error loading current medication level: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load historical medication level data
  Future<void> loadHistoricalData({
    int days = 30,
    String groupBy = 'day',
    bool includePredictions = false,
    bool forceRefresh = false,
  }) async {
    if (_isLoading && !forceRefresh) return;

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _medicationLevelApi.getMedicationLevelHistory(
        days: days,
        groupBy: groupBy,
        includePredictions: includePredictions,
      );

      if (response['success'] == true) {
        final data = response['data'];
        _historicalData = MedicationLevelData.fromJson(data);
      } else {
        _error = response['message'] ?? 'Failed to load historical data';
      }
    } catch (e) {
      _error = 'Failed to load historical data: ${e.toString()}';
      debugPrint('Error loading historical data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load medication level trends
  Future<void> loadTrends({
    int days = 30,
    String? medication,
    bool forceRefresh = false,
  }) async {
    if (_isLoading && !forceRefresh) return;

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _medicationLevelApi.getMedicationLevelTrends(
        days: days,
        medication: medication,
      );

      if (response['success'] == true) {
        final data = response['data'];
        _trends = MedicationLevelTrends.fromJson(data);
      } else {
        _error = response['message'] ?? 'Failed to load trends';
      }
    } catch (e) {
      _error = 'Failed to load trends: ${e.toString()}';
      debugPrint('Error loading trends: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Calculate and store current medication level
  Future<bool> calculateAndStoreMedicationLevel() async {
    return await calculateMedicationLevel();
  }

  /// Calculate current medication level
  Future<bool> calculateMedicationLevel() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      debugPrint('🧮 Calculating medication level...');
      final response = await _medicationLevelApi.calculateMedicationLevel();
      debugPrint('📊 Calculate response: $response');

      if (response['success'] == true) {
        _currentLevel = response;
        debugPrint('✅ Medication level calculated successfully');
        
        // Refresh historical data and trends
        await loadHistoricalData(forceRefresh: true);
        await loadTrends(forceRefresh: true);
        
        return true;
      } else {
        _error = response['message'] ?? 'Failed to calculate medication level';
        debugPrint('❌ Calculate failed: $_error');
        return false;
      }
    } catch (e) {
      _error = 'Failed to calculate medication level: ${e.toString()}';
      debugPrint('❌ Error calculating medication level: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get medication level data for chart visualization
  List<Map<String, dynamic>> getChartData() {
    if (_historicalData == null) return [];

    final List<Map<String, dynamic>> chartData = [];

    // Add historical levels
    for (final point in _historicalData!.historicalLevels) {
      chartData.add({
        'x': point.date.millisecondsSinceEpoch,
        'y': point.level,
        'type': 'historical',
        'status': point.status,
        'medication': point.medication,
        'dosage': point.dosage,
      });
    }

    // Add predictions if available
    if (_historicalData!.predictions != null) {
      for (final point in _historicalData!.predictions!) {
        chartData.add({
          'x': point.date.millisecondsSinceEpoch,
          'y': point.level,
          'type': 'prediction',
          'status': point.status,
        });
      }
    }

    // Sort by date
    chartData.sort((a, b) => (a['x'] as int).compareTo(b['x'] as int));

    return chartData;
  }

  /// Get shot events for chart markers
  List<Map<String, dynamic>> getShotEvents() {
    if (_historicalData == null) return [];

    return _historicalData!.shotEvents.map((event) => ({
      'x': event.date.millisecondsSinceEpoch,
      'y': 100, // Always show at top
      'medication': event.medication,
      'dosage': event.dosage,
      'injectionSite': event.injectionSite,
    })).toList();
  }

  /// Get trend direction icon
  String getTrendIcon() {
    if (_trends == null) return '→';
    
    switch (_trends!.analytics.trendDirection) {
      case 'increasing':
        return '↗';
      case 'decreasing':
        return '↘';
      case 'stable':
      default:
        return '→';
    }
  }

  /// Get trend color
  String getTrendColor() {
    if (_trends == null) return 'stable';
    
    switch (_trends!.analytics.trendDirection) {
      case 'increasing':
        return 'success';
      case 'decreasing':
        return 'warning';
      case 'stable':
      default:
        return 'neutral';
    }
  }

  /// Get status color
  String getStatusColor(String status) {
    switch (status) {
      case 'optimal':
        return 'success';
      case 'declining':
        return 'warning';
      case 'low':
        return 'error';
      case 'overdue':
        return 'error';
      default:
        return 'neutral';
    }
  }

  /// Get level status based on percentage
  String getLevelStatus(double percentage) {
    if (percentage >= 60) return 'optimal';
    if (percentage >= 30) return 'declining';
    if (percentage > 0) return 'low';
    return 'overdue';
  }

  /// Clear error state
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Clear all data
  void clearData() {
    _currentLevel = null;
    _historicalData = null;
    _trends = null;
    _error = null;
    notifyListeners();
  }

  /// Refresh all data
  Future<void> refreshAll() async {
    await Future.wait([
      loadCurrentMedicationLevel(forceRefresh: true),
      loadHistoricalData(forceRefresh: true),
      loadTrends(forceRefresh: true),
    ]);
  }

  /// Force refresh current medication level
  Future<void> forceRefreshCurrentLevel() async {
    _currentLevel = null;
    await loadCurrentMedicationLevel(forceRefresh: true);
  }
}
