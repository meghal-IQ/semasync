class TreatmentSchedule {
  final String id;
  final String userId;
  final String medication;
  final String dosage;
  final String frequency;
  final int? customInterval;
  final String preferredTime;
  final String? specificTime;
  final String timeZone;
  final bool isActive;
  final DateTime startDate;
  final DateTime? endDate;
  final ReminderSettings reminders;
  final AdherenceMetrics adherence;
  final List<ScheduleAdjustment> adjustments;
  final DateTime createdAt;
  final DateTime updatedAt;

  TreatmentSchedule({
    required this.id,
    required this.userId,
    required this.medication,
    required this.dosage,
    required this.frequency,
    this.customInterval,
    required this.preferredTime,
    this.specificTime,
    required this.timeZone,
    required this.isActive,
    required this.startDate,
    this.endDate,
    required this.reminders,
    required this.adherence,
    required this.adjustments,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TreatmentSchedule.fromJson(Map<String, dynamic> json) {
    return TreatmentSchedule(
      id: json['id'] ?? json['_id'] ?? '',
      userId: json['userId'] ?? '',
      medication: json['medication'] ?? '',
      dosage: json['dosage'] ?? '',
      frequency: json['frequency'] ?? '',
      customInterval: json['customInterval'],
      preferredTime: json['preferredTime'] ?? 'Any time',
      specificTime: json['specificTime'],
      timeZone: json['timeZone'] ?? 'UTC',
      isActive: json['isActive'] ?? true,
      startDate: DateTime.parse(json['startDate']),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      reminders: ReminderSettings.fromJson(json['reminders'] ?? {}),
      adherence: AdherenceMetrics.fromJson(json['adherence'] ?? {}),
      adjustments: (json['adjustments'] as List<dynamic>?)
          ?.map((adj) => ScheduleAdjustment.fromJson(adj))
          .toList() ?? [],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'medication': medication,
      'dosage': dosage,
      'frequency': frequency,
      'customInterval': customInterval,
      'preferredTime': preferredTime,
      'specificTime': specificTime,
      'timeZone': timeZone,
      'isActive': isActive,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'reminders': reminders.toJson(),
      'adherence': adherence.toJson(),
      'adjustments': adjustments.map((adj) => adj.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class ReminderSettings {
  final bool enabled;
  final List<int> preDoseHours;
  final List<int> postDoseHours;
  final List<int> missedDoseHours;
  final bool escalationEnabled;

  ReminderSettings({
    required this.enabled,
    required this.preDoseHours,
    required this.postDoseHours,
    required this.missedDoseHours,
    required this.escalationEnabled,
  });

  factory ReminderSettings.fromJson(Map<String, dynamic> json) {
    return ReminderSettings(
      enabled: json['enabled'] ?? true,
      preDoseHours: List<int>.from(json['preDoseHours'] ?? [24, 2]),
      postDoseHours: List<int>.from(json['postDoseHours'] ?? [2]),
      missedDoseHours: List<int>.from(json['missedDoseHours'] ?? [24, 72]),
      escalationEnabled: json['escalationEnabled'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'preDoseHours': preDoseHours,
      'postDoseHours': postDoseHours,
      'missedDoseHours': missedDoseHours,
      'escalationEnabled': escalationEnabled,
    };
  }
}

class AdherenceMetrics {
  final int totalScheduledDoses;
  final int totalTakenDoses;
  final int totalMissedDoses;
  final int currentStreak;
  final int longestStreak;
  final int adherencePercentage;
  final DateTime lastCalculated;

  AdherenceMetrics({
    required this.totalScheduledDoses,
    required this.totalTakenDoses,
    required this.totalMissedDoses,
    required this.currentStreak,
    required this.longestStreak,
    required this.adherencePercentage,
    required this.lastCalculated,
  });

  factory AdherenceMetrics.fromJson(Map<String, dynamic> json) {
    return AdherenceMetrics(
      totalScheduledDoses: json['totalScheduledDoses'] ?? 0,
      totalTakenDoses: json['totalTakenDoses'] ?? 0,
      totalMissedDoses: json['totalMissedDoses'] ?? 0,
      currentStreak: json['currentStreak'] ?? 0,
      longestStreak: json['longestStreak'] ?? 0,
      adherencePercentage: json['adherencePercentage'] ?? 100,
      lastCalculated: DateTime.parse(json['lastCalculated'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalScheduledDoses': totalScheduledDoses,
      'totalTakenDoses': totalTakenDoses,
      'totalMissedDoses': totalMissedDoses,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'adherencePercentage': adherencePercentage,
      'lastCalculated': lastCalculated.toIso8601String(),
    };
  }
}

class ScheduleAdjustment {
  final DateTime date;
  final String reason;
  final dynamic oldValue;
  final dynamic newValue;
  final String? notes;

  ScheduleAdjustment({
    required this.date,
    required this.reason,
    required this.oldValue,
    required this.newValue,
    this.notes,
  });

  factory ScheduleAdjustment.fromJson(Map<String, dynamic> json) {
    return ScheduleAdjustment(
      date: DateTime.parse(json['date']),
      reason: json['reason'] ?? '',
      oldValue: json['oldValue'],
      newValue: json['newValue'],
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'reason': reason,
      'oldValue': oldValue,
      'newValue': newValue,
      'notes': notes,
    };
  }
}

class WeeklyAdherence {
  final String week;
  final int expected;
  final int actual;
  final int adherence;

  WeeklyAdherence({
    required this.week,
    required this.expected,
    required this.actual,
    required this.adherence,
  });

  factory WeeklyAdherence.fromJson(Map<String, dynamic> json) {
    return WeeklyAdherence(
      week: json['week'] ?? '',
      expected: json['expected'] ?? 0,
      actual: json['actual'] ?? 0,
      adherence: json['adherence'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'week': week,
      'expected': expected,
      'actual': actual,
      'adherence': adherence,
    };
  }
}

class CalendarDose {
  final DateTime date;
  final String medication;
  final String dosage;
  final String status; // 'scheduled', 'taken', 'overdue'
  final String? shotId;
  final DateTime? actualDate;
  final String? injectionSite;
  final List<String>? sideEffects;

  CalendarDose({
    required this.date,
    required this.medication,
    required this.dosage,
    required this.status,
    this.shotId,
    this.actualDate,
    this.injectionSite,
    this.sideEffects,
  });

  factory CalendarDose.fromJson(Map<String, dynamic> json) {
    return CalendarDose(
      date: DateTime.parse(json['date']),
      medication: json['medication'] ?? '',
      dosage: json['dosage'] ?? '',
      status: json['status'] ?? 'scheduled',
      shotId: json['shotId'],
      actualDate: json['actualDate'] != null ? DateTime.parse(json['actualDate']) : null,
      injectionSite: json['injectionSite'],
      sideEffects: json['sideEffects'] != null ? List<String>.from(json['sideEffects']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'medication': medication,
      'dosage': dosage,
      'status': status,
      'shotId': shotId,
      'actualDate': actualDate?.toIso8601String(),
      'injectionSite': injectionSite,
      'sideEffects': sideEffects,
    };
  }
}

class TreatmentScheduleData {
  final TreatmentSchedule? schedule;
  final DateTime? nextDueDate;
  final bool hasShots;

  TreatmentScheduleData({
    this.schedule,
    this.nextDueDate,
    required this.hasShots,
  });

  factory TreatmentScheduleData.fromJson(Map<String, dynamic> json) {
    return TreatmentScheduleData(
      schedule: json['schedule'] != null ? TreatmentSchedule.fromJson(json['schedule']) : null,
      nextDueDate: json['nextDueDate'] != null ? DateTime.parse(json['nextDueDate']) : null,
      hasShots: json['hasShots'] ?? false,
    );
  }
}

class AdherenceAnalytics {
  final AdherenceMetrics adherence;
  final List<WeeklyAdherence> weeklyBreakdown;
  final int shotsInPeriod;
  final DateTime startDate;
  final DateTime endDate;
  final int days;

  AdherenceAnalytics({
    required this.adherence,
    required this.weeklyBreakdown,
    required this.shotsInPeriod,
    required this.startDate,
    required this.endDate,
    required this.days,
  });

  factory AdherenceAnalytics.fromJson(Map<String, dynamic> json) {
    return AdherenceAnalytics(
      adherence: AdherenceMetrics.fromJson(json['adherence'] ?? {}),
      weeklyBreakdown: (json['weeklyBreakdown'] as List<dynamic>?)
          ?.map((week) => WeeklyAdherence.fromJson(week))
          .toList() ?? [],
      shotsInPeriod: json['shotsInPeriod'] ?? 0,
      startDate: DateTime.parse(json['period']['startDate']),
      endDate: DateTime.parse(json['period']['endDate']),
      days: json['period']['days'] ?? 30,
    );
  }
}

class CalendarData {
  final List<CalendarDose> calendar;
  final int month;
  final int year;
  final Map<String, dynamic> schedule;

  CalendarData({
    required this.calendar,
    required this.month,
    required this.year,
    required this.schedule,
  });

  factory CalendarData.fromJson(Map<String, dynamic> json) {
    return CalendarData(
      calendar: (json['calendar'] as List<dynamic>?)
          ?.map((dose) => CalendarDose.fromJson(dose))
          .toList() ?? [],
      month: json['month'] ?? DateTime.now().month,
      year: json['year'] ?? DateTime.now().year,
      schedule: json['schedule'] ?? {},
    );
  }
}
