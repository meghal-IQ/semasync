class MedicationLevelHistory {
  final String id;
  final DateTime date;
  final String medication;
  final String dosage;
  final double calculatedLevel;
  final double percentageOfPeak;
  final String? shotId;
  final int? daysSinceLastShot;
  final int? hoursSinceLastShot;
  final DateTime? nextDueDate;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  MedicationLevelHistory({
    required this.id,
    required this.date,
    required this.medication,
    required this.dosage,
    required this.calculatedLevel,
    required this.percentageOfPeak,
    this.shotId,
    this.daysSinceLastShot,
    this.hoursSinceLastShot,
    this.nextDueDate,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MedicationLevelHistory.fromJson(Map<String, dynamic> json) {
    return MedicationLevelHistory(
      id: json['id'] ?? json['_id'] ?? '',
      date: DateTime.parse(json['date']),
      medication: json['medication'] ?? '',
      dosage: json['dosage'] ?? '',
      calculatedLevel: (json['calculatedLevel'] ?? 0).toDouble(),
      percentageOfPeak: (json['percentageOfPeak'] ?? 0).toDouble(),
      shotId: json['shotId'],
      daysSinceLastShot: json['daysSinceLastShot'],
      hoursSinceLastShot: json['hoursSinceLastShot'],
      nextDueDate: json['nextDueDate'] != null 
          ? DateTime.parse(json['nextDueDate']) 
          : null,
      status: json['status'] ?? 'optimal',
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'medication': medication,
      'dosage': dosage,
      'calculatedLevel': calculatedLevel,
      'percentageOfPeak': percentageOfPeak,
      'shotId': shotId,
      'daysSinceLastShot': daysSinceLastShot,
      'hoursSinceLastShot': hoursSinceLastShot,
      'nextDueDate': nextDueDate?.toIso8601String(),
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class MedicationLevelData {
  final List<MedicationLevelPoint> historicalLevels;
  final List<ShotEvent> shotEvents;
  final List<MedicationLevelPoint>? predictions;

  MedicationLevelData({
    required this.historicalLevels,
    required this.shotEvents,
    this.predictions,
  });

  factory MedicationLevelData.fromJson(Map<String, dynamic> json) {
    return MedicationLevelData(
      historicalLevels: (json['historicalLevels'] as List<dynamic>)
          .map((e) => MedicationLevelPoint.fromJson(e))
          .toList(),
      shotEvents: (json['shotEvents'] as List<dynamic>)
          .map((e) => ShotEvent.fromJson(e))
          .toList(),
      predictions: json['predictions'] != null
          ? (json['predictions'] as List<dynamic>)
              .map((e) => MedicationLevelPoint.fromJson(e))
              .toList()
          : null,
    );
  }
}

class MedicationLevelPoint {
  final DateTime date;
  final double level;
  final double percentage;
  final String? status;
  final String? medication;
  final String? dosage;
  final int? daysSinceShot;
  final int? hoursSinceShot;
  final String? type;

  MedicationLevelPoint({
    required this.date,
    required this.level,
    required this.percentage,
    this.status,
    this.medication,
    this.dosage,
    this.daysSinceShot,
    this.hoursSinceShot,
    this.type,
  });

  factory MedicationLevelPoint.fromJson(Map<String, dynamic> json) {
    return MedicationLevelPoint(
      date: DateTime.parse(json['date']),
      level: (json['level'] ?? 0).toDouble(),
      percentage: (json['percentage'] ?? 0).toDouble(),
      status: json['status'],
      medication: json['medication'],
      dosage: json['dosage'],
      daysSinceShot: json['daysSinceShot'],
      hoursSinceShot: json['hoursSinceShot'],
      type: json['type'],
    );
  }
}

class ShotEvent {
  final DateTime date;
  final String medication;
  final String dosage;
  final String injectionSite;
  final String type;

  ShotEvent({
    required this.date,
    required this.medication,
    required this.dosage,
    required this.injectionSite,
    required this.type,
  });

  factory ShotEvent.fromJson(Map<String, dynamic> json) {
    return ShotEvent(
      date: DateTime.parse(json['date']),
      medication: json['medication'] ?? '',
      dosage: json['dosage'] ?? '',
      injectionSite: json['injectionSite'] ?? '',
      type: json['type'] ?? 'shot',
    );
  }
}

class MedicationLevelTrends {
  final MedicationLevelAnalytics analytics;
  final List<MedicationLevelPoint> rawData;

  MedicationLevelTrends({
    required this.analytics,
    required this.rawData,
  });

  factory MedicationLevelTrends.fromJson(Map<String, dynamic> json) {
    return MedicationLevelTrends(
      analytics: MedicationLevelAnalytics.fromJson(json['analytics']),
      rawData: (json['rawData'] as List<dynamic>)
          .map((e) => MedicationLevelPoint.fromJson(e))
          .toList(),
    );
  }
}

class MedicationLevelAnalytics {
  final double averageLevel;
  final double minLevel;
  final double maxLevel;
  final double timeInOptimal;
  final double timeInDeclining;
  final double timeInLow;
  final double timeOverdue;
  final double levelStability;
  final String trendDirection;
  final List<WeeklyAverage> weeklyAverages;
  final StatusDistribution statusDistribution;

  MedicationLevelAnalytics({
    required this.averageLevel,
    required this.minLevel,
    required this.maxLevel,
    required this.timeInOptimal,
    required this.timeInDeclining,
    required this.timeInLow,
    required this.timeOverdue,
    required this.levelStability,
    required this.trendDirection,
    required this.weeklyAverages,
    required this.statusDistribution,
  });

  factory MedicationLevelAnalytics.fromJson(Map<String, dynamic> json) {
    return MedicationLevelAnalytics(
      averageLevel: (json['averageLevel'] ?? 0).toDouble(),
      minLevel: (json['minLevel'] ?? 0).toDouble(),
      maxLevel: (json['maxLevel'] ?? 0).toDouble(),
      timeInOptimal: (json['timeInOptimal'] ?? 0).toDouble(),
      timeInDeclining: (json['timeInDeclining'] ?? 0).toDouble(),
      timeInLow: (json['timeInLow'] ?? 0).toDouble(),
      timeOverdue: (json['timeOverdue'] ?? 0).toDouble(),
      levelStability: (json['levelStability'] ?? 0).toDouble(),
      trendDirection: json['trendDirection'] ?? 'stable',
      weeklyAverages: (json['weeklyAverages'] as List<dynamic>)
          .map((e) => WeeklyAverage.fromJson(e))
          .toList(),
      statusDistribution: StatusDistribution.fromJson(json['statusDistribution']),
    );
  }
}

class WeeklyAverage {
  final String week;
  final double average;

  WeeklyAverage({
    required this.week,
    required this.average,
  });

  factory WeeklyAverage.fromJson(Map<String, dynamic> json) {
    return WeeklyAverage(
      week: json['week'] ?? '',
      average: (json['average'] ?? 0).toDouble(),
    );
  }
}

class StatusDistribution {
  final int optimal;
  final int declining;
  final int low;
  final int overdue;

  StatusDistribution({
    required this.optimal,
    required this.declining,
    required this.low,
    required this.overdue,
  });

  factory StatusDistribution.fromJson(Map<String, dynamic> json) {
    return StatusDistribution(
      optimal: json['optimal'] ?? 0,
      declining: json['declining'] ?? 0,
      low: json['low'] ?? 0,
      overdue: json['overdue'] ?? 0,
    );
  }
}

// Medication level status enum
enum MedicationLevelStatus {
  optimal,
  declining,
  low,
  overdue;

  String get displayName {
    switch (this) {
      case MedicationLevelStatus.optimal:
        return 'Optimal';
      case MedicationLevelStatus.declining:
        return 'Declining';
      case MedicationLevelStatus.low:
        return 'Low';
      case MedicationLevelStatus.overdue:
        return 'Overdue';
    }
  }

  static MedicationLevelStatus fromString(String value) {
    return MedicationLevelStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => MedicationLevelStatus.optimal,
    );
  }
}
