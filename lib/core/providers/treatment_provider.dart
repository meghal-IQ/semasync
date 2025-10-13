import 'dart:ui';

import 'package:flutter/foundation.dart';
import '../api/models/shot_log_model.dart';
import '../api/services/treatment_service.dart';

class TreatmentProvider extends ChangeNotifier {
  final TreatmentService _treatmentService = TreatmentService();

  // State
  bool _isLoading = false;
  String? _errorMessage;
  
  // Shot data
  ShotLog? _latestShot;
  List<ShotLog> _shotHistory = [];
  MedicationLevel? _medicationLevel;
  NextShotInfo? _nextShotInfo;
  TreatmentStats? _stats;
  InjectionSiteRecommendation? _siteRecommendations;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  ShotLog? get latestShot => _latestShot;
  List<ShotLog> get shotHistory => _shotHistory;
  MedicationLevel? get medicationLevel => _medicationLevel;
  NextShotInfo? get nextShotInfo => _nextShotInfo;
  TreatmentStats? get stats => _stats;
  InjectionSiteRecommendation? get siteRecommendations => _siteRecommendations;

  /// Log a new shot
  Future<bool> logShot(ShotLogRequest request) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _treatmentService.logShot(request);

      if (response.success && response.data != null) {
        _latestShot = response.data;
        
        // Refresh all treatment data
        await loadTreatmentData();
        
        _setLoading(false);
        return true;
      } else {
        _setError(response.message);
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Failed to log shot: $e');
      _setLoading(false);
      return false;
    }
  }

  /// Load all treatment data
  Future<void> loadTreatmentData() async {
    _setLoading(true);
    _clearError();

    try {
      // Load all data in parallel
      final results = await Future.wait([
        _loadLatestShot(),
        _loadMedicationLevel(),
        _loadNextShotInfo(),
        _loadStats(),
        _loadShotHistory(),
      ]);

      // Check if any failed
      final failed = results.any((result) => !result);
      if (failed) {
        _setError('Some data failed to load');
      }

      _setLoading(false);
    } catch (e) {
      _setError('Failed to load treatment data: $e');
      _setLoading(false);
    }
  }

  /// Load latest shot
  Future<bool> _loadLatestShot() async {
    try {
      final response = await _treatmentService.getLatestShot();
      
      if (response.success) {
        if (response.data != null) {
          _latestShot = response.data!['shot'] as ShotLog?;
          _medicationLevel = response.data!['medicationLevel'] as MedicationLevel?;
        } else {
          // No shots - clear the data
          _latestShot = null;
          _medicationLevel = null;
        }
        notifyListeners();
        return true;
      } else {
        // Request failed - clear data
        _latestShot = null;
        _medicationLevel = null;
        notifyListeners();
        return false;
      }
    } catch (e) {
      print('Error loading latest shot: $e');
      // On error, clear data
      _latestShot = null;
      _medicationLevel = null;
      notifyListeners();
      return false;
    }
  }

  /// Load medication level
  Future<bool> _loadMedicationLevel() async {
    try {
      final response = await _treatmentService.getMedicationLevel();
      
      if (response.success) {
        _medicationLevel = response.data; // Can be null if no shots
        notifyListeners();
        return true;
      } else {
        _medicationLevel = null;
        notifyListeners();
        return false;
      }
    } catch (e) {
      print('Error loading medication level: $e');
      _medicationLevel = null;
      notifyListeners();
      return false;
    }
  }

  /// Load next shot info
  Future<bool> _loadNextShotInfo() async {
    try {
      final response = await _treatmentService.getNextShotInfo();
      
      if (response.success) {
        _nextShotInfo = response.data; // Can be null if no shots
        notifyListeners();
        return true;
      } else {
        _nextShotInfo = null;
        notifyListeners();
        return false;
      }
    } catch (e) {
      print('Error loading next shot info: $e');
      _nextShotInfo = null;
      notifyListeners();
      return false;
    }
  }

  /// Load treatment statistics
  Future<bool> _loadStats() async {
    try {
      final response = await _treatmentService.getStats();
      
      if (response.success && response.data != null) {
        _stats = response.data;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Error loading stats: $e');
      return false;
    }
  }

  /// Load shot history
  Future<bool> _loadShotHistory({int limit = 50, int page = 1}) async {
    try {
      final response = await _treatmentService.getShotHistory(
        limit: limit,
        page: page,
      );
      
      if (response.success && response.data != null) {
        _shotHistory = response.data!.shots;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Error loading shot history: $e');
      return false;
    }
  }

  /// Load injection site recommendations
  Future<void> loadSiteRecommendations() async {
    try {
      final response = await _treatmentService.getRecommendedSites();
      
      if (response.success && response.data != null) {
        _siteRecommendations = response.data;
        notifyListeners();
      }
    } catch (e) {
      print('Error loading site recommendations: $e');
    }
  }

  /// Update a shot
  Future<bool> updateShot(String shotId, ShotLogRequest request) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _treatmentService.updateShot(shotId, request);

      if (response.success) {
        // Refresh data
        await loadTreatmentData();
        _setLoading(false);
        return true;
      } else {
        _setError(response.message);
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Failed to update shot: $e');
      _setLoading(false);
      return false;
    }
  }

  /// Delete a shot
  Future<bool> deleteShot(String shotId) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _treatmentService.deleteShot(shotId);

      if (response.success) {
        // Refresh data
        await loadTreatmentData();
        _setLoading(false);
        return true;
      } else {
        _setError(response.message);
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Failed to delete shot: $e');
      _setLoading(false);
      return false;
    }
  }

  /// Get medication level status color
  Color getMedicationLevelColor() {
    if (_medicationLevel == null) return const Color(0xFF9E9E9E);
    
    switch (_medicationLevel!.status) {
      case 'optimal':
        return const Color(0xFF4CAF50); // Green
      case 'declining':
        return const Color(0xFFFF9800); // Orange
      case 'low':
        return const Color(0xFFF44336); // Red
      case 'overdue':
        return const Color(0xFFD32F2F); // Dark Red
      default:
        return const Color(0xFF9E9E9E); // Grey
    }
  }

  /// Helper methods
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

  /// Clear all data (for logout)
  void clear() {
    _latestShot = null;
    _shotHistory = [];
    _medicationLevel = null;
    _nextShotInfo = null;
    _stats = null;
    _siteRecommendations = null;
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }
}
