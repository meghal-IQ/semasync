class SideEffect {
  final String id;
  final DateTime date;
  final List<SideEffectDetail> effects;
  final double overallSeverity;
  final String? notes;
  final bool relatedToShot;
  final String? shotId;
  final int? daysSinceShot;
  final bool isActive;
  final DateTime? resolvedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  SideEffect({
    required this.id,
    required this.date,
    required this.effects,
    required this.overallSeverity,
    this.notes,
    required this.relatedToShot,
    this.shotId,
    this.daysSinceShot,
    required this.isActive,
    this.resolvedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SideEffect.fromJson(Map<String, dynamic> json) {
    return SideEffect(
      id: json['id'] ?? json['_id'] ?? '',
      date: DateTime.parse(json['date']),
      effects: (json['effects'] as List<dynamic>)
          .map((e) => SideEffectDetail.fromJson(e))
          .toList(),
      overallSeverity: (json['overallSeverity'] ?? 0).toDouble(),
      notes: json['notes'],
      relatedToShot: json['relatedToShot'] ?? false,
      shotId: json['shotId'],
      daysSinceShot: json['daysSinceShot'],
      isActive: json['isActive'] ?? true,
      resolvedAt: json['resolvedAt'] != null 
          ? DateTime.parse(json['resolvedAt']) 
          : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'effects': effects.map((e) => e.toJson()).toList(),
      'overallSeverity': overallSeverity,
      'notes': notes,
      'relatedToShot': relatedToShot,
      'shotId': shotId,
      'daysSinceShot': daysSinceShot,
      'isActive': isActive,
      'resolvedAt': resolvedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  SideEffect copyWith({
    String? id,
    DateTime? date,
    List<SideEffectDetail>? effects,
    double? overallSeverity,
    String? notes,
    bool? relatedToShot,
    String? shotId,
    int? daysSinceShot,
    bool? isActive,
    DateTime? resolvedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SideEffect(
      id: id ?? this.id,
      date: date ?? this.date,
      effects: effects ?? this.effects,
      overallSeverity: overallSeverity ?? this.overallSeverity,
      notes: notes ?? this.notes,
      relatedToShot: relatedToShot ?? this.relatedToShot,
      shotId: shotId ?? this.shotId,
      daysSinceShot: daysSinceShot ?? this.daysSinceShot,
      isActive: isActive ?? this.isActive,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class SideEffectDetail {
  final String name;
  final double severity;
  final String? description;
  final double? duration;
  final List<String>? triggers;
  final List<String>? remedies;

  SideEffectDetail({
    required this.name,
    required this.severity,
    this.description,
    this.duration,
    this.triggers,
    this.remedies,
  });

  factory SideEffectDetail.fromJson(Map<String, dynamic> json) {
    return SideEffectDetail(
      name: json['name'] ?? '',
      severity: (json['severity'] ?? 0).toDouble(),
      description: json['description'],
      duration: json['duration']?.toDouble(),
      triggers: json['triggers'] != null 
          ? List<String>.from(json['triggers']) 
          : null,
      remedies: json['remedies'] != null 
          ? List<String>.from(json['remedies']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'name': name,
      'severity': severity,
    };
    
    if (description != null) json['description'] = description;
    if (duration != null) json['duration'] = duration;
    if (triggers != null) json['triggers'] = triggers;
    if (remedies != null) json['remedies'] = remedies;
    
    return json;
  }

  SideEffectDetail copyWith({
    String? name,
    double? severity,
    String? description,
    double? duration,
    List<String>? triggers,
    List<String>? remedies,
  }) {
    return SideEffectDetail(
      name: name ?? this.name,
      severity: severity ?? this.severity,
      description: description ?? this.description,
      duration: duration ?? this.duration,
      triggers: triggers ?? this.triggers,
      remedies: remedies ?? this.remedies,
    );
  }
}

class SideEffectAnalytics {
  final int totalEntries;
  final double averageSeverity;
  final List<CommonSideEffect> mostCommonEffects;
  final List<SeverityTrend> severityTrends;
  final int activeEffects;
  final int resolvedEffects;
  final SeverityDistribution effectsBySeverity;

  SideEffectAnalytics({
    required this.totalEntries,
    required this.averageSeverity,
    required this.mostCommonEffects,
    required this.severityTrends,
    required this.activeEffects,
    required this.resolvedEffects,
    required this.effectsBySeverity,
  });

  factory SideEffectAnalytics.fromJson(Map<String, dynamic> json) {
    return SideEffectAnalytics(
      totalEntries: json['totalEntries'] ?? 0,
      averageSeverity: (json['averageSeverity'] ?? 0).toDouble(),
      mostCommonEffects: (json['mostCommonEffects'] as List<dynamic>)
          .map((e) => CommonSideEffect.fromJson(e))
          .toList(),
      severityTrends: (json['severityTrends'] as List<dynamic>)
          .map((e) => SeverityTrend.fromJson(e))
          .toList(),
      activeEffects: json['activeEffects'] ?? 0,
      resolvedEffects: json['resolvedEffects'] ?? 0,
      effectsBySeverity: SeverityDistribution.fromJson(json['effectsBySeverity']),
    );
  }
}

class CommonSideEffect {
  final String name;
  final int count;
  final double avgSeverity;

  CommonSideEffect({
    required this.name,
    required this.count,
    required this.avgSeverity,
  });

  factory CommonSideEffect.fromJson(Map<String, dynamic> json) {
    return CommonSideEffect(
      name: json['name'] ?? '',
      count: json['count'] ?? 0,
      avgSeverity: (json['avgSeverity'] ?? 0).toDouble(),
    );
  }
}

class SeverityTrend {
  final String date;
  final double avgSeverity;
  final int count;

  SeverityTrend({
    required this.date,
    required this.avgSeverity,
    required this.count,
  });

  factory SeverityTrend.fromJson(Map<String, dynamic> json) {
    return SeverityTrend(
      date: json['date'] ?? '',
      avgSeverity: (json['avgSeverity'] ?? 0).toDouble(),
      count: json['count'] ?? 0,
    );
  }
}

class SeverityDistribution {
  final int mild;
  final int moderate;
  final int severe;

  SeverityDistribution({
    required this.mild,
    required this.moderate,
    required this.severe,
  });

  factory SeverityDistribution.fromJson(Map<String, dynamic> json) {
    return SeverityDistribution(
      mild: json['mild'] ?? 0,
      moderate: json['moderate'] ?? 0,
      severe: json['severe'] ?? 0,
    );
  }
}

// Side effect types enum
enum SideEffectType {
  nausea,
  vomiting,
  diarrhea,
  constipation,
  fatigue,
  headache,
  dizziness,
  abdominalPain,
  decreasedAppetite,
  injectionSiteReaction,
  heartburn,
  bloating,
  hairLoss,
  muscleLoss,
  lowBloodSugar,
  moodChanges,
  sleepDisturbances,
  dryMouth,
  other;

  String get displayName {
    switch (this) {
      case SideEffectType.nausea:
        return 'Nausea';
      case SideEffectType.vomiting:
        return 'Vomiting';
      case SideEffectType.diarrhea:
        return 'Diarrhea';
      case SideEffectType.constipation:
        return 'Constipation';
      case SideEffectType.fatigue:
        return 'Fatigue';
      case SideEffectType.headache:
        return 'Headache';
      case SideEffectType.dizziness:
        return 'Dizziness';
      case SideEffectType.abdominalPain:
        return 'Abdominal Pain';
      case SideEffectType.decreasedAppetite:
        return 'Decreased Appetite';
      case SideEffectType.injectionSiteReaction:
        return 'Injection Site Reaction';
      case SideEffectType.heartburn:
        return 'Heartburn';
      case SideEffectType.bloating:
        return 'Bloating';
      case SideEffectType.hairLoss:
        return 'Hair Loss';
      case SideEffectType.muscleLoss:
        return 'Muscle Loss';
      case SideEffectType.lowBloodSugar:
        return 'Low Blood Sugar';
      case SideEffectType.moodChanges:
        return 'Mood Changes';
      case SideEffectType.sleepDisturbances:
        return 'Sleep Disturbances';
      case SideEffectType.dryMouth:
        return 'Dry Mouth';
      case SideEffectType.other:
        return 'Other';
    }
  }

  static SideEffectType fromString(String value) {
    return SideEffectType.values.firstWhere(
      (type) => type.displayName == value,
      orElse: () => SideEffectType.other,
    );
  }
}

// Trigger types enum
enum TriggerType {
  medicationDose,
  foodIntake,
  stress,
  exercise,
  weatherChanges,
  sleepDisruption,
  otherMedications,
  unknown;

  String get displayName {
    switch (this) {
      case TriggerType.medicationDose:
        return 'Medication dose';
      case TriggerType.foodIntake:
        return 'Food intake';
      case TriggerType.stress:
        return 'Stress';
      case TriggerType.exercise:
        return 'Exercise';
      case TriggerType.weatherChanges:
        return 'Weather changes';
      case TriggerType.sleepDisruption:
        return 'Sleep disruption';
      case TriggerType.otherMedications:
        return 'Other medications';
      case TriggerType.unknown:
        return 'Unknown';
    }
  }

  static TriggerType fromString(String value) {
    return TriggerType.values.firstWhere(
      (type) => type.displayName == value,
      orElse: () => TriggerType.unknown,
    );
  }
}

// Remedy types enum
enum RemedyType {
  rest,
  hydration,
  lightMeal,
  ginger,
  peppermint,
  overTheCounterMedication,
  prescriptionMedication,
  deepBreathing,
  other;

  String get displayName {
    switch (this) {
      case RemedyType.rest:
        return 'Rest';
      case RemedyType.hydration:
        return 'Hydration';
      case RemedyType.lightMeal:
        return 'Light meal';
      case RemedyType.ginger:
        return 'Ginger';
      case RemedyType.peppermint:
        return 'Peppermint';
      case RemedyType.overTheCounterMedication:
        return 'Over-the-counter medication';
      case RemedyType.prescriptionMedication:
        return 'Prescription medication';
      case RemedyType.deepBreathing:
        return 'Deep breathing';
      case RemedyType.other:
        return 'Other';
    }
  }

  static RemedyType fromString(String value) {
    return RemedyType.values.firstWhere(
      (type) => type.displayName == value,
      orElse: () => RemedyType.other,
    );
  }
}
