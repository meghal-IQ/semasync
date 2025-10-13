import 'package:flutter/foundation.dart';
import '../../domain/models/side_effect.dart';
import '../../../../core/api/side_effect_api.dart';

class SideEffectProvider with ChangeNotifier {
  final SideEffectApi _sideEffectApi;

  SideEffectProvider(this._sideEffectApi);

  List<SideEffect> _sideEffects = [];
  List<SideEffect> _currentSideEffects = [];
  SideEffectAnalytics? _analytics;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<SideEffect> get sideEffects => _sideEffects;
  List<SideEffect> get currentSideEffects => _currentSideEffects;
  SideEffectAnalytics? get analytics => _analytics;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Get active side effects count
  int get activeSideEffectsCount => _currentSideEffects.length;

  // Get most recent side effects
  List<SideEffect> get recentSideEffects {
    final now = DateTime.now();
    final last7Days = now.subtract(const Duration(days: 7));
    return _sideEffects.where((effect) => effect.date.isAfter(last7Days)).toList();
  }

  // Get severity distribution for recent effects
  Map<String, int> get recentSeverityDistribution {
    final recent = recentSideEffects;
    final distribution = <String, int>{
      'mild': 0,    // 0-3
      'moderate': 0, // 4-6
      'severe': 0,   // 7-10
    };

    for (final effect in recent) {
      if (effect.overallSeverity <= 3) {
        distribution['mild'] = (distribution['mild'] ?? 0) + 1;
      } else if (effect.overallSeverity <= 6) {
        distribution['moderate'] = (distribution['moderate'] ?? 0) + 1;
      } else {
        distribution['severe'] = (distribution['severe'] ?? 0) + 1;
      }
    }

    return distribution;
  }

  /// Load side effects with optional filters
  Future<void> loadSideEffects({
    DateTime? startDate,
    DateTime? endDate,
    int limit = 50,
    int page = 1,
    int? severity,
    bool? active,
    bool? relatedToShot,
    bool forceRefresh = false,
  }) async {
    if (_isLoading && !forceRefresh) return;

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _sideEffectApi.getSideEffects(
        startDate: startDate,
        endDate: endDate,
        limit: limit,
        page: page,
        severity: severity,
        active: active,
        relatedToShot: relatedToShot,
      );

      if (response['success'] == true) {
        final data = response['data'];
        final sideEffectsData = data['sideEffects'] as List<dynamic>;
        
        _sideEffects = sideEffectsData
            .map((json) => SideEffect.fromJson(json))
            .toList();
      } else {
        _error = response['message'] ?? 'Failed to load side effects';
      }
    } catch (e) {
      _error = 'Failed to load side effects: ${e.toString()}';
      debugPrint('Error loading side effects: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load current active side effects
  Future<void> loadCurrentSideEffects({bool forceRefresh = false}) async {
    if (_isLoading && !forceRefresh) return;

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _sideEffectApi.getCurrentSideEffects();

      if (response['success'] == true) {
        final data = response['data'];
        final currentEffectsData = data['activeSideEffects'] as List<dynamic>;
        
        _currentSideEffects = currentEffectsData
            .map((json) => SideEffect.fromJson(json))
            .toList();
      } else {
        _error = response['message'] ?? 'Failed to load current side effects';
      }
    } catch (e) {
      _error = 'Failed to load current side effects: ${e.toString()}';
      debugPrint('Error loading current side effects: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load side effect analytics
  Future<void> loadAnalytics({
    int days = 30,
    String groupBy = 'day',
    bool forceRefresh = false,
  }) async {
    if (_isLoading && !forceRefresh) return;

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _sideEffectApi.getSideEffectAnalytics(
        days: days,
        groupBy: groupBy,
      );

      if (response['success'] == true) {
        final data = response['data'];
        _analytics = SideEffectAnalytics.fromJson(data);
      } else {
        _error = response['message'] ?? 'Failed to load analytics';
      }
    } catch (e) {
      _error = 'Failed to load analytics: ${e.toString()}';
      debugPrint('Error loading analytics: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Log new side effects
  Future<bool> logSideEffects({
    DateTime? date,
    required List<SideEffectDetail> effects,
    required double overallSeverity,
    String? notes,
    bool? relatedToShot,
    String? shotId,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final effectsJson = effects.map((e) => e.toJson()).toList();

      final response = await _sideEffectApi.logSideEffects(
        date: date,
        effects: effectsJson,
        overallSeverity: overallSeverity,
        notes: notes,
        relatedToShot: relatedToShot,
        shotId: shotId,
      );

      if (response['success'] == true) {
        // Refresh data
        await loadSideEffects(forceRefresh: true);
        await loadCurrentSideEffects(forceRefresh: true);
        await loadAnalytics(forceRefresh: true);
        return true;
      } else {
        _error = response['message'] ?? 'Failed to log side effects';
        return false;
      }
    } catch (e) {
      _error = 'Failed to log side effects: ${e.toString()}';
      debugPrint('Error logging side effects: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update side effect log entry
  Future<bool> updateSideEffect({
    required String id,
    DateTime? date,
    List<SideEffectDetail>? effects,
    double? overallSeverity,
    String? notes,
    bool? relatedToShot,
    String? shotId,
    bool? isActive,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final effectsJson = effects?.map((e) => e.toJson()).toList();

      final response = await _sideEffectApi.updateSideEffect(
        id: id,
        date: date,
        effects: effectsJson,
        overallSeverity: overallSeverity,
        notes: notes,
        relatedToShot: relatedToShot,
        shotId: shotId,
        isActive: isActive,
      );

      if (response['success'] == true) {
        // Refresh data
        await loadSideEffects(forceRefresh: true);
        await loadCurrentSideEffects(forceRefresh: true);
        await loadAnalytics(forceRefresh: true);
        return true;
      } else {
        _error = response['message'] ?? 'Failed to update side effect';
        return false;
      }
    } catch (e) {
      _error = 'Failed to update side effect: ${e.toString()}';
      debugPrint('Error updating side effect: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Delete side effect log entry
  Future<bool> deleteSideEffect(String id) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _sideEffectApi.deleteSideEffect(id);

      if (response['success'] == true) {
        // Remove from local lists
        _sideEffects.removeWhere((effect) => effect.id == id);
        _currentSideEffects.removeWhere((effect) => effect.id == id);
        
        // Refresh data
        await loadSideEffects(forceRefresh: true);
        await loadCurrentSideEffects(forceRefresh: true);
        await loadAnalytics(forceRefresh: true);
        return true;
      } else {
        _error = response['message'] ?? 'Failed to delete side effect';
        return false;
      }
    } catch (e) {
      _error = 'Failed to delete side effect: ${e.toString()}';
      debugPrint('Error deleting side effect: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Mark side effect as resolved
  Future<bool> resolveSideEffect(String id) async {
    return await updateSideEffect(id: id, isActive: false);
  }

  /// Get side effects for a specific date range
  List<SideEffect> getSideEffectsForDateRange(DateTime start, DateTime end) {
    return _sideEffects.where((effect) {
      return effect.date.isAfter(start.subtract(const Duration(days: 1))) &&
             effect.date.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }

  /// Get side effects by severity level
  List<SideEffect> getSideEffectsBySeverity(String level) {
    switch (level) {
      case 'mild':
        return _sideEffects.where((effect) => effect.overallSeverity <= 3).toList();
      case 'moderate':
        return _sideEffects.where((effect) => 
          effect.overallSeverity > 3 && effect.overallSeverity <= 6).toList();
      case 'severe':
        return _sideEffects.where((effect) => effect.overallSeverity > 6).toList();
      default:
        return _sideEffects;
    }
  }

  /// Clear error state
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Clear all data
  void clearData() {
    _sideEffects.clear();
    _currentSideEffects.clear();
    _analytics = null;
    _error = null;
    notifyListeners();
  }
}
