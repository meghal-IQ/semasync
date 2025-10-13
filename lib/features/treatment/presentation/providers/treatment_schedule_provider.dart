import 'package:flutter/foundation.dart';
import '../../domain/models/treatment_schedule.dart';
import '../../../../core/api/treatment_schedule_api.dart';

class TreatmentScheduleProvider with ChangeNotifier {
  final TreatmentScheduleApi _treatmentScheduleApi;

  TreatmentScheduleProvider(this._treatmentScheduleApi);

  // Current schedule data
  TreatmentSchedule? _currentSchedule;
  TreatmentScheduleData? _scheduleData;
  AdherenceAnalytics? _adherenceAnalytics;
  CalendarData? _calendarData;
  
  // State management
  bool _isLoading = false;
  String? _error;

  // Getters
  TreatmentSchedule? get currentSchedule => _currentSchedule;
  TreatmentScheduleData? get scheduleData => _scheduleData;
  AdherenceAnalytics? get adherenceAnalytics => _adherenceAnalytics;
  CalendarData? get calendarData => _calendarData;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Convenience getters
  bool get hasActiveSchedule => _currentSchedule?.isActive ?? false;
  String get currentMedication => _currentSchedule?.medication ?? '';
  String get currentDosage => _currentSchedule?.dosage ?? '';
  String get currentFrequency => _currentSchedule?.frequency ?? '';
  int get adherencePercentage => _adherenceAnalytics?.adherence.adherencePercentage ?? 100;
  int get currentStreak => _adherenceAnalytics?.adherence.currentStreak ?? 0;
  int get longestStreak => _adherenceAnalytics?.adherence.longestStreak ?? 0;
  DateTime? get nextDueDate => _scheduleData?.nextDueDate;

  /// Load current treatment schedule
  Future<void> loadCurrentSchedule({bool forceRefresh = false}) async {
    if (_isLoading && !forceRefresh) return;

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      debugPrint('📅 Loading treatment schedule...');
      final response = await _treatmentScheduleApi.getCurrentSchedule();
      debugPrint('📊 Schedule response: $response');

      if (response['success'] == true) {
        _scheduleData = TreatmentScheduleData.fromJson(response['data'] ?? {});
        _currentSchedule = _scheduleData?.schedule;
        debugPrint('✅ Schedule loaded successfully');
      } else {
        _error = response['message'] ?? 'Failed to load treatment schedule';
        debugPrint('❌ Schedule failed: $_error');
      }
    } catch (e) {
      _error = 'Failed to load treatment schedule: ${e.toString()}';
      debugPrint('❌ Error loading schedule: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Create or update treatment schedule
  Future<bool> createOrUpdateSchedule({
    required String medication,
    required String dosage,
    required String frequency,
    String? preferredTime,
    String? specificTime,
    int? customInterval,
    Map<String, dynamic>? reminders,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      debugPrint('💾 Creating/updating treatment schedule...');
      final response = await _treatmentScheduleApi.createOrUpdateSchedule(
        medication: medication,
        dosage: dosage,
        frequency: frequency,
        preferredTime: preferredTime,
        specificTime: specificTime,
        customInterval: customInterval,
        reminders: reminders,
      );

      debugPrint('📊 Create/update response: $response');

      if (response['success'] == true) {
        _currentSchedule = TreatmentSchedule.fromJson(response['data']);
        debugPrint('✅ Schedule saved successfully');
        
        // Refresh schedule data
        await loadCurrentSchedule(forceRefresh: true);
        
        return true;
      } else {
        _error = response['message'] ?? 'Failed to save treatment schedule';
        debugPrint('❌ Save failed: $_error');
        return false;
      }
    } catch (e) {
      _error = 'Failed to save treatment schedule: ${e.toString()}';
      debugPrint('❌ Error saving schedule: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load adherence analytics
  Future<void> loadAdherenceAnalytics({
    int days = 30,
    bool forceRefresh = false,
  }) async {
    if (_isLoading && !forceRefresh) return;

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      debugPrint('📈 Loading adherence analytics...');
      final response = await _treatmentScheduleApi.getAdherenceAnalytics(days: days);
      debugPrint('📊 Adherence response: $response');

      if (response['success'] == true) {
        _adherenceAnalytics = AdherenceAnalytics.fromJson(response['data']);
        debugPrint('✅ Adherence analytics loaded successfully');
      } else {
        _error = response['message'] ?? 'Failed to load adherence analytics';
        debugPrint('❌ Adherence failed: $_error');
      }
    } catch (e) {
      _error = 'Failed to load adherence analytics: ${e.toString()}';
      debugPrint('❌ Error loading adherence: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load calendar view
  Future<void> loadCalendarView({
    int? month,
    int? year,
    bool forceRefresh = false,
  }) async {
    if (_isLoading && !forceRefresh) return;

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      debugPrint('📅 Loading calendar view...');
      final response = await _treatmentScheduleApi.getCalendarView(
        month: month,
        year: year,
      );
      debugPrint('📊 Calendar response: $response');

      if (response['success'] == true) {
        _calendarData = CalendarData.fromJson(response['data']);
        debugPrint('✅ Calendar view loaded successfully');
      } else {
        _error = response['message'] ?? 'Failed to load calendar view';
        debugPrint('❌ Calendar failed: $_error');
      }
    } catch (e) {
      _error = 'Failed to load calendar view: ${e.toString()}';
      debugPrint('❌ Error loading calendar: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Test reminder functionality
  Future<bool> testReminder({
    required String type,
    required int hours,
  }) async {
    try {
      debugPrint('🔔 Testing reminder...');
      final response = await _treatmentScheduleApi.testReminder(
        type: type,
        hours: hours,
      );

      if (response['success'] == true) {
        debugPrint('✅ Reminder test successful');
        return true;
      } else {
        _error = response['message'] ?? 'Failed to test reminder';
        debugPrint('❌ Reminder test failed: $_error');
        return false;
      }
    } catch (e) {
      _error = 'Failed to test reminder: ${e.toString()}';
      debugPrint('❌ Error testing reminder: $e');
      return false;
    }
  }

  /// Get adherence status color
  String getAdherenceStatusColor() {
    final percentage = adherencePercentage;
    if (percentage >= 90) return 'success';
    if (percentage >= 70) return 'warning';
    return 'error';
  }

  /// Get adherence status label
  String getAdherenceStatusLabel() {
    final percentage = adherencePercentage;
    if (percentage >= 90) return 'Excellent';
    if (percentage >= 70) return 'Good';
    if (percentage >= 50) return 'Fair';
    return 'Needs Improvement';
  }

  /// Get streak status
  String getStreakStatus() {
    final streak = currentStreak;
    if (streak >= 7) return 'On Fire!';
    if (streak >= 4) return 'Great Streak';
    if (streak >= 2) return 'Building Momentum';
    if (streak >= 1) return 'Getting Started';
    return 'Start Your Streak';
  }

  /// Get next dose countdown
  String getNextDoseCountdown() {
    if (nextDueDate == null) return 'No schedule';
    
    final now = DateTime.now();
    final difference = nextDueDate!.difference(now);
    
    if (difference.isNegative) {
      final overdue = now.difference(nextDueDate!);
      final days = overdue.inDays;
      final hours = overdue.inHours % 24;
      return 'Overdue by ${days}d ${hours}h';
    } else {
      final days = difference.inDays;
      final hours = difference.inHours % 24;
      return '${days}d ${hours}h';
    }
  }

  /// Get calendar doses for a specific date
  List<CalendarDose> getDosesForDate(DateTime date) {
    if (_calendarData == null) return [];
    
    return _calendarData!.calendar.where((dose) {
      return dose.date.year == date.year &&
             dose.date.month == date.month &&
             dose.date.day == date.day;
    }).toList();
  }

  /// Get weekly adherence data for charts
  List<Map<String, dynamic>> getWeeklyAdherenceChartData() {
    if (_adherenceAnalytics == null) return [];
    
    return _adherenceAnalytics!.weeklyBreakdown.map((week) => {
      'week': week.week,
      'adherence': week.adherence,
      'expected': week.expected,
      'actual': week.actual,
    }).toList();
  }

  /// Get adherence trend direction
  String getAdherenceTrendDirection() {
    if (_adherenceAnalytics == null || _adherenceAnalytics!.weeklyBreakdown.length < 2) {
      return 'stable';
    }
    
    final weeks = _adherenceAnalytics!.weeklyBreakdown;
    final recent = weeks.take(2).map((w) => w.adherence).toList();
    
    if (recent[0] > recent[1]) return 'increasing';
    if (recent[0] < recent[1]) return 'decreasing';
    return 'stable';
  }

  /// Clear error state
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Clear all data
  void clearData() {
    _currentSchedule = null;
    _scheduleData = null;
    _adherenceAnalytics = null;
    _calendarData = null;
    _error = null;
    notifyListeners();
  }

  /// Refresh all data
  Future<void> refreshAll() async {
    await Future.wait([
      loadCurrentSchedule(forceRefresh: true),
      loadAdherenceAnalytics(forceRefresh: true),
      loadCalendarView(forceRefresh: true),
    ]);
  }
}
