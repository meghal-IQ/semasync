import 'package:flutter/foundation.dart';
import '../api/services/historical_data_service.dart';

class HistoricalDataProvider extends ChangeNotifier {
  final HistoricalDataService _historicalDataService = HistoricalDataService();
  
  Map<String, dynamic>? _historicalData;
  DateTime? _selectedDate;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  Map<String, dynamic>? get historicalData => _historicalData;
  DateTime? get selectedDate => _selectedDate;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Load historical data for a specific date
  Future<void> loadHistoricalData(DateTime date) async {
    _isLoading = true;
    _errorMessage = null;
    _selectedDate = date;
    notifyListeners();

    try {
      final response = await _historicalDataService.getHistoricalDashboardData(date);
      
      if (response.success && response.data != null) {
        _historicalData = response.data;
        _errorMessage = null;
      } else {
        _errorMessage = response.message;
        _historicalData = null;
      }
    } catch (e) {
      _errorMessage = 'Failed to load historical data: $e';
      _historicalData = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get nutrition data for the selected date
  Map<String, dynamic>? get nutritionData {
    return _historicalData?['nutrition'];
  }

  /// Get log entries for the selected date
  List<Map<String, dynamic>> get logEntries {
    final logs = _historicalData?['logs'];
    if (logs is List) {
      return logs.cast<Map<String, dynamic>>();
    }
    return [];
  }

  /// Get treatment data for the selected date
  List<Map<String, dynamic>> get treatmentData {
    final treatments = _historicalData?['treatments'];
    if (treatments is List) {
      return treatments.cast<Map<String, dynamic>>();
    }
    return [];
  }

  /// Get weight data for the selected date
  List<Map<String, dynamic>> get weightData {
    final weights = _historicalData?['weights'];
    if (weights is List) {
      return weights.cast<Map<String, dynamic>>();
    }
    return [];
  }

  /// Check if there's data for the selected date
  bool get hasData {
    return _historicalData != null && 
           (logEntries.isNotEmpty || 
            treatmentData.isNotEmpty || 
            weightData.isNotEmpty ||
            (nutritionData != null && nutritionData!.isNotEmpty));
  }

  /// Get formatted date string
  String get formattedDate {
    if (_selectedDate == null) return '';
    
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    
    return '${months[_selectedDate!.month - 1]} ${_selectedDate!.day}, ${_selectedDate!.year}';
  }

  /// Check if selected date is today
  bool get isToday {
    if (_selectedDate == null) return false;
    
    final now = DateTime.now();
    return _selectedDate!.year == now.year &&
           _selectedDate!.month == now.month &&
           _selectedDate!.day == now.day;
  }

  /// Clear historical data
  void clearData() {
    _historicalData = null;
    _selectedDate = null;
    _errorMessage = null;
    notifyListeners();
  }

  /// Refresh current data
  Future<void> refresh() async {
    if (_selectedDate != null) {
      await loadHistoricalData(_selectedDate!);
    }
  }
}
