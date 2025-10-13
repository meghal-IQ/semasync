import 'package:flutter/foundation.dart';
import '../api/models/weekly_checkup_model.dart';
import '../api/services/weekly_checkup_service.dart';
import '../utils/dosage_recommendation_engine.dart';
import '../api/models/weight_log_model.dart';
import '../api/models/shot_log_model.dart';
import 'health_provider.dart';

class WeeklyCheckupProvider extends ChangeNotifier {
  final WeeklyCheckupService _weeklyCheckupService;

  WeeklyCheckupProvider(this._weeklyCheckupService);

  // State
  bool _isLoading = false;
  String? _errorMessage;
  List<WeeklyCheckup> _checkups = [];
  WeeklyCheckup? _latestCheckup;
  Map<String, dynamic>? _analytics;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<WeeklyCheckup> get checkups => _checkups;
  WeeklyCheckup? get latestCheckup => _latestCheckup;
  Map<String, dynamic>? get analytics => _analytics;

  // ============================================================================
  // WEEKLY CHECKUP MANAGEMENT
  // ============================================================================

  /// Create a new weekly checkup with automatic dosage recommendation
  Future<bool> createWeeklyCheckup({
    required double currentWeight,
    required String weightUnit,
    required List<String> sideEffects,
    required double overallSideEffectSeverity,
    String? notes,
    double? previousWeight,
    String? currentDose,
    String? medication,
    int? daysOnCurrentDose,
    int? totalTreatmentDays,
    HealthProvider? healthProvider,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      // Calculate dosage recommendation using Bayesian engine
      final recommendation = DosageRecommendationEngine.calculateRecommendation(
        currentWeight: currentWeight,
        previousWeight: previousWeight,
        sideEffects: sideEffects,
        overallSideEffectSeverity: overallSideEffectSeverity,
        currentDose: currentDose ?? '0.25mg',
        medication: medication ?? 'Ozempic®',
        daysOnCurrentDose: daysOnCurrentDose ?? 7,
        totalTreatmentDays: totalTreatmentDays ?? 30,
      );

      // Always calculate weight change if we have any previous weight data
      double? actualPreviousWeight = previousWeight;
      
      // If no previous weight provided, try to get it from latest checkup
      if (actualPreviousWeight == null && _latestCheckup != null) {
        actualPreviousWeight = _latestCheckup!.currentWeight;
      }
      
      // If still no previous weight, try to get it from health provider
      if (actualPreviousWeight == null && healthProvider?.weightStats?.currentWeight != null) {
        actualPreviousWeight = healthProvider!.weightStats!.currentWeight!;
      }

      // Calculate Bayesian factors using a simplified approach
      final bayesianFactors = BayesianDosingFactors(
        priorProbability: 0.7, // Default prior
        likelihood: 0.8, // Default likelihood
        posteriorProbability: 0.75, // Default posterior
        individualFactors: {
          'weightLossRate': actualPreviousWeight != null ? _calculateWeightChangeFactor(actualPreviousWeight, currentWeight, weightUnit) : 0.0,
          'sideEffectTolerance': (10 - overallSideEffectSeverity) / 10.0,
          'treatmentDuration': (totalTreatmentDays ?? 30) / 90.0,
          'doseStability': (daysOnCurrentDose ?? 7) / 21.0,
          'medicationResponse': 0.8,
        },
        confidenceLevel: 'medium',
      );

      // Generate recommendation reason
      final weightChangeFactor = actualPreviousWeight != null 
          ? _calculateWeightChangeFactor(actualPreviousWeight, currentWeight, weightUnit)
          : 0.0;
      final sideEffectFactor = sideEffects.isEmpty 
          ? 0.0 
          : overallSideEffectSeverity / 10.0;

      final recommendationReason = DosageRecommendationEngine.generateRecommendationReason(
        recommendation,
        bayesianFactors,
        weightChangeFactor,
        sideEffectFactor,
        currentDose,
      );

      // Create checkup request with all required fields
      final request = WeeklyCheckupRequest(
        currentWeight: currentWeight,
        weightUnit: weightUnit,
        sideEffects: sideEffects,
        overallSideEffectSeverity: overallSideEffectSeverity,
        notes: notes,
      );

      // Add calculated fields to request data
      final requestData = request.toJson();
      requestData['dosageRecommendation'] = recommendation.name;
      requestData['recommendationReason'] = recommendationReason;
      requestData['bayesianFactors'] = bayesianFactors.toJson();
      
      if (actualPreviousWeight != null) {
        // Convert previous weight to the same unit as current weight for accurate calculation
        double previousWeightInCurrentUnit = actualPreviousWeight;
        
        // Handle unit conversion based on the source of previous weight
        if (_latestCheckup != null && _latestCheckup!.weightUnit != weightUnit) {
          // Convert from latest checkup unit to current unit
          if (_latestCheckup!.weightUnit == 'kg' && weightUnit == 'lbs') {
            previousWeightInCurrentUnit = actualPreviousWeight * 2.20462; // Convert kg to lbs
          } else if (_latestCheckup!.weightUnit == 'lbs' && weightUnit == 'kg') {
            previousWeightInCurrentUnit = actualPreviousWeight * 0.453592; // Convert lbs to kg
          }
        } else if (_latestCheckup == null && healthProvider?.weightStats?.unit != null && healthProvider!.weightStats!.unit != weightUnit) {
          // Convert from health provider unit to current unit
          if (healthProvider.weightStats!.unit == 'kg' && weightUnit == 'lbs') {
            previousWeightInCurrentUnit = actualPreviousWeight * 2.20462; // Convert kg to lbs
          } else if (healthProvider.weightStats!.unit == 'lbs' && weightUnit == 'kg') {
            previousWeightInCurrentUnit = actualPreviousWeight * 0.453592; // Convert lbs to kg
          }
        }
        
        final weightChange = currentWeight - previousWeightInCurrentUnit;
        final weightChangePercent = (weightChange / previousWeightInCurrentUnit) * 100;
        
        requestData['weightChange'] = weightChange;
        requestData['weightChangePercent'] = weightChangePercent;
      }

      // Create a new request with all the data
      final fullRequest = WeeklyCheckupRequest(
        currentWeight: currentWeight,
        weightUnit: weightUnit,
        sideEffects: sideEffects,
        overallSideEffectSeverity: overallSideEffectSeverity,
        notes: notes,
      );

      final response = await _weeklyCheckupService.createWeeklyCheckup(fullRequest, requestData);

      if (response['success'] == true) {
        await loadLatestWeeklyCheckup();
        await loadWeeklyCheckups();
        _setLoading(false);
        return true;
      } else {
        _setError(response['message'] ?? 'Failed to create weekly checkup');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Failed to create weekly checkup: $e');
      _setLoading(false);
      return false;
    }
  }

  /// Load weekly checkup history
  Future<void> loadWeeklyCheckups({
    DateTime? startDate,
    DateTime? endDate,
    int limit = 50,
    int page = 1,
  }) async {
    try {
      final response = await _weeklyCheckupService.getWeeklyCheckups(
        startDate: startDate,
        endDate: endDate,
        limit: limit,
        page: page,
      );

      if (response['success'] == true && response['data'] != null) {
        final data = response['data'];
        _checkups = (data['checkups'] as List)
            .map((e) => WeeklyCheckup.fromJson(e))
            .toList();
        notifyListeners();
      }
    } catch (e) {
      print('Error loading weekly checkups: $e');
    }
  }

  /// Load latest weekly checkup
  Future<void> loadLatestWeeklyCheckup() async {
    try {
      final response = await _weeklyCheckupService.getLatestWeeklyCheckup();

      if (response['success'] == true && response['data'] != null) {
        _latestCheckup = WeeklyCheckup.fromJson(response['data']);
        notifyListeners();
      }
    } catch (e) {
      print('Error loading latest weekly checkup: $e');
    }
  }

  /// Load weekly checkup analytics
  Future<void> loadWeeklyCheckupAnalytics({int weeks = 12}) async {
    try {
      final response = await _weeklyCheckupService.getWeeklyCheckupAnalytics(weeks: weeks);

      if (response['success'] == true && response['data'] != null) {
        _analytics = response['data'];
        notifyListeners();
      }
    } catch (e) {
      print('Error loading weekly checkup analytics: $e');
    }
  }

  /// Update a weekly checkup
  Future<bool> updateWeeklyCheckup(
    String checkupId,
    WeeklyCheckupRequest request,
  ) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _weeklyCheckupService.updateWeeklyCheckup(checkupId, request);

      if (response['success'] == true) {
        await loadWeeklyCheckups();
        _setLoading(false);
        return true;
      } else {
        _setError(response['message'] ?? 'Failed to update weekly checkup');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Failed to update weekly checkup: $e');
      _setLoading(false);
      return false;
    }
  }

  /// Delete a weekly checkup
  Future<bool> deleteWeeklyCheckup(String checkupId) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _weeklyCheckupService.deleteWeeklyCheckup(checkupId);

      if (response['success'] == true) {
        await loadWeeklyCheckups();
        _setLoading(false);
        return true;
      } else {
        _setError(response['message'] ?? 'Failed to delete weekly checkup');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Failed to delete weekly checkup: $e');
      _setLoading(false);
      return false;
    }
  }

  /// Check if user is due for a weekly checkup
  bool isDueForWeeklyCheckup() {
    if (_latestCheckup == null) return true;
    
    final lastCheckupDate = _latestCheckup!.date;
    final now = DateTime.now();
    final daysSinceLastCheckup = now.difference(lastCheckupDate).inDays;
    
    return daysSinceLastCheckup >= 7;
  }

  /// Get days since last checkup
  int getDaysSinceLastCheckup() {
    if (_latestCheckup == null) return 0;
    
    final lastCheckupDate = _latestCheckup!.date;
    final now = DateTime.now();
    
    return now.difference(lastCheckupDate).inDays;
  }

  /// Get recommendation trend over time
  List<Map<String, dynamic>> getRecommendationTrend() {
    return _checkups.map((checkup) => {
      'date': checkup.date,
      'recommendation': checkup.dosageRecommendation,
      'confidence': checkup.bayesianFactors['confidenceLevel'],
      'posteriorProbability': checkup.bayesianFactors['posteriorProbability'],
    }).toList();
  }

  /// Get weight change trend
  List<Map<String, dynamic>> getWeightChangeTrend() {
    return _checkups.where((checkup) => checkup.weightChange != null).map((checkup) => {
      'date': checkup.date,
      'weight': checkup.currentWeight,
      'change': checkup.weightChange,
      'changePercent': checkup.weightChangePercent,
    }).toList();
  }

  /// Get side effect trend
  List<Map<String, dynamic>> getSideEffectTrend() {
    return _checkups.map((checkup) => {
      'date': checkup.date,
      'severity': checkup.overallSideEffectSeverity,
      'effects': checkup.sideEffects,
      'count': checkup.sideEffects.length,
    }).toList();
  }

  // ============================================================================
  // HELPER METHODS
  // ============================================================================

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  /// Calculate weight change factor with proper unit conversion
  double _calculateWeightChangeFactor(double previousWeight, double currentWeight, String currentUnit) {
    // Convert previous weight to the same unit as current weight
    double previousWeightInCurrentUnit = previousWeight;
    
    // The health provider stores weight in kg, so if current unit is lbs, convert previous weight
    if (currentUnit == 'lbs') {
      previousWeightInCurrentUnit = previousWeight * 2.20462; // Convert kg to lbs
    }
    // If current unit is kg, previous weight is already in kg (no conversion needed)
    
    return (previousWeightInCurrentUnit - currentWeight) / previousWeightInCurrentUnit;
  }
}
