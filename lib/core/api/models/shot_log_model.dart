class ShotLog {
  final String id;
  final String userId;
  final DateTime date;
  final String medication;
  final String dosage;
  final String injectionSite;
  final int painLevel;
  final List<String> sideEffects;
  final String? notes;
  final DateTime nextDueDate;
  final String? photoUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  ShotLog({
    required this.id,
    required this.userId,
    required this.date,
    required this.medication,
    required this.dosage,
    required this.injectionSite,
    required this.painLevel,
    required this.sideEffects,
    this.notes,
    required this.nextDueDate,
    this.photoUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ShotLog.fromJson(Map<String, dynamic> json) {
    return ShotLog(
      id: json['id'] ?? json['_id'] ?? '',
      userId: json['userId'] ?? '',
      date: DateTime.parse(json['date']),
      medication: json['medication'] ?? '',
      dosage: json['dosage'] ?? '',
      injectionSite: json['injectionSite'] ?? '',
      painLevel: json['painLevel'] ?? 0,
      sideEffects: List<String>.from(json['sideEffects'] ?? []),
      notes: json['notes'],
      nextDueDate: DateTime.parse(json['nextDueDate']),
      photoUrl: json['photoUrl'],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'date': date.toIso8601String(),
      'medication': medication,
      'dosage': dosage,
      'injectionSite': injectionSite,
      'painLevel': painLevel,
      'sideEffects': sideEffects,
      'notes': notes,
      'nextDueDate': nextDueDate.toIso8601String(),
      'photoUrl': photoUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class ShotLogRequest {
  final DateTime? date;
  final String medication;
  final String dosage;
  final String injectionSite;
  final int painLevel;
  final List<String> sideEffects;
  final String? notes;
  final String? photoUrl;

  ShotLogRequest({
    this.date,
    required this.medication,
    required this.dosage,
    required this.injectionSite,
    required this.painLevel,
    required this.sideEffects,
    this.notes,
    this.photoUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      if (date != null) 'date': date!.toIso8601String(),
      'medication': medication,
      'dosage': dosage,
      'injectionSite': injectionSite,
      'painLevel': painLevel,
      'sideEffects': sideEffects,
      if (notes != null && notes!.isNotEmpty) 'notes': notes,
      if (photoUrl != null && photoUrl!.isNotEmpty) 'photoUrl': photoUrl,
    };
  }
}

class MedicationLevel {
  final double currentLevel;
  final double percentageOfPeak;
  final double daysUntilNextDose;
  final double hoursUntilNextDose;
  final bool isOverdue;
  final String status;
  final String? medication;
  final String? dosage;
  final DateTime? lastShotDate;

  MedicationLevel({
    required this.currentLevel,
    required this.percentageOfPeak,
    required this.daysUntilNextDose,
    required this.hoursUntilNextDose,
    required this.isOverdue,
    required this.status,
    this.medication,
    this.dosage,
    this.lastShotDate,
  });

  factory MedicationLevel.fromJson(Map<String, dynamic> json) {
    return MedicationLevel(
      currentLevel: (json['currentLevel'] ?? 0).toDouble(),
      percentageOfPeak: (json['percentageOfPeak'] ?? 0).toDouble(),
      daysUntilNextDose: (json['daysUntilNextDose'] ?? 0).toDouble(),
      hoursUntilNextDose: (json['hoursUntilNextDose'] ?? 0).toDouble(),
      isOverdue: json['isOverdue'] ?? false,
      status: json['status'] ?? 'no_data',
      medication: json['medication'],
      dosage: json['dosage'],
      lastShotDate: json['lastShotDate'] != null 
          ? DateTime.parse(json['lastShotDate'])
          : null,
    );
  }

  String get statusDisplay {
    switch (status) {
      case 'optimal':
        return 'Optimal';
      case 'declining':
        return 'Declining';
      case 'low':
        return 'Low';
      case 'overdue':
        return 'Overdue';
      default:
        return 'Unknown';
    }
  }
}

class NextShotInfo {
  final bool hasShots;
  final DateTime? nextDueDate;
  final String? countdown;
  final bool isOverdue;
  final double hoursUntilNext;
  final double daysUntilNext;
  final String? message;

  NextShotInfo({
    required this.hasShots,
    this.nextDueDate,
    this.countdown,
    required this.isOverdue,
    required this.hoursUntilNext,
    required this.daysUntilNext,
    this.message,
  });

  factory NextShotInfo.fromJson(Map<String, dynamic> json) {
    return NextShotInfo(
      hasShots: json['hasShots'] ?? false,
      nextDueDate: json['nextDueDate'] != null 
          ? DateTime.parse(json['nextDueDate'])
          : null,
      countdown: json['countdown'],
      isOverdue: json['isOverdue'] ?? false,
      hoursUntilNext: (json['hoursUntilNext'] ?? 0).toDouble(),
      daysUntilNext: (json['daysUntilNext'] ?? 0).toDouble(),
      message: json['message'],
    );
  }
}

class TreatmentStats {
  final int totalShots;
  final int expectedShots;
  final int adherenceRate;
  final int daysSinceStart;
  final DateTime? firstShotDate;
  final DateTime? latestShotDate;
  final String? currentDose;
  final String? startingDose;
  final double averagePainLevel;
  final String? mostUsedInjectionSite;
  final List<SideEffectCount> commonSideEffects;

  TreatmentStats({
    required this.totalShots,
    required this.expectedShots,
    required this.adherenceRate,
    required this.daysSinceStart,
    this.firstShotDate,
    this.latestShotDate,
    this.currentDose,
    this.startingDose,
    required this.averagePainLevel,
    this.mostUsedInjectionSite,
    required this.commonSideEffects,
  });

  factory TreatmentStats.fromJson(Map<String, dynamic> json) {
    List<SideEffectCount> sideEffects = [];
    if (json['commonSideEffects'] != null) {
      sideEffects = (json['commonSideEffects'] as List)
          .map((e) => SideEffectCount.fromJson(e))
          .toList();
    }

    return TreatmentStats(
      totalShots: json['totalShots'] ?? 0,
      expectedShots: json['expectedShots'] ?? 0,
      adherenceRate: json['adherenceRate'] ?? 0,
      daysSinceStart: json['daysSinceStart'] ?? 0,
      firstShotDate: json['firstShotDate'] != null 
          ? DateTime.parse(json['firstShotDate'])
          : null,
      latestShotDate: json['latestShotDate'] != null 
          ? DateTime.parse(json['latestShotDate'])
          : null,
      currentDose: json['currentDose'],
      startingDose: json['startingDose'],
      averagePainLevel: (json['averagePainLevel'] ?? 0).toDouble(),
      mostUsedInjectionSite: json['mostUsedInjectionSite'],
      commonSideEffects: sideEffects,
    );
  }
}

class SideEffectCount {
  final String effect;
  final int count;

  SideEffectCount({
    required this.effect,
    required this.count,
  });

  factory SideEffectCount.fromJson(Map<String, dynamic> json) {
    return SideEffectCount(
      effect: json['effect'] ?? '',
      count: json['count'] ?? 0,
    );
  }
}

class InjectionSiteRecommendation {
  final List<String> recommendedSites;
  final List<String> recentSites;
  final String message;

  InjectionSiteRecommendation({
    required this.recommendedSites,
    required this.recentSites,
    required this.message,
  });

  factory InjectionSiteRecommendation.fromJson(Map<String, dynamic> json) {
    return InjectionSiteRecommendation(
      recommendedSites: List<String>.from(json['recommendedSites'] ?? []),
      recentSites: List<String>.from(json['recentSites'] ?? []),
      message: json['message'] ?? '',
    );
  }
}

class ShotHistoryResponse {
  final List<ShotLog> shots;
  final PaginationInfo pagination;

  ShotHistoryResponse({
    required this.shots,
    required this.pagination,
  });

  factory ShotHistoryResponse.fromJson(Map<String, dynamic> json) {
    return ShotHistoryResponse(
      shots: (json['shots'] as List)
          .map((e) => ShotLog.fromJson(e))
          .toList(),
      pagination: PaginationInfo.fromJson(json['pagination']),
    );
  }
}

class PaginationInfo {
  final int total;
  final int page;
  final int limit;
  final int pages;

  PaginationInfo({
    required this.total,
    required this.page,
    required this.limit,
    required this.pages,
  });

  factory PaginationInfo.fromJson(Map<String, dynamic> json) {
    return PaginationInfo(
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 50,
      pages: json['pages'] ?? 1,
    );
  }
}
