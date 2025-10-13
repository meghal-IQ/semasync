class SideEffectLog {
  final String id;
  final String userId;
  final DateTime date;
  final List<SideEffect> effects;
  final int overallSeverity;
  final String? notes;
  final bool relatedToShot;
  final int? daysSinceShot;
  final DateTime createdAt;
  final DateTime updatedAt;

  SideEffectLog({
    required this.id,
    required this.userId,
    required this.date,
    required this.effects,
    required this.overallSeverity,
    this.notes,
    required this.relatedToShot,
    this.daysSinceShot,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SideEffectLog.fromJson(Map<String, dynamic> json) {
    return SideEffectLog(
      id: json['id'] ?? json['_id'] ?? '',
      userId: json['userId'] ?? '',
      date: DateTime.parse(json['date']),
      effects: (json['effects'] as List)
          .map((e) => SideEffect.fromJson(e))
          .toList(),
      overallSeverity: json['overallSeverity'] ?? 0,
      notes: json['notes'],
      relatedToShot: json['relatedToShot'] ?? false,
      daysSinceShot: json['daysSinceShot'],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}

class SideEffect {
  final String name;
  final int severity;
  final String? description;

  SideEffect({
    required this.name,
    required this.severity,
    this.description,
  });

  factory SideEffect.fromJson(Map<String, dynamic> json) {
    return SideEffect(
      name: json['name'] ?? '',
      severity: json['severity'] ?? 0,
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'severity': severity,
      if (description != null) 'description': description,
    };
  }
}

class SideEffectLogRequest {
  final DateTime? date;
  final List<SideEffect> effects;
  final int overallSeverity;
  final bool? relatedToShot;
  final int? daysSinceShot;
  final String? notes;

  SideEffectLogRequest({
    this.date,
    required this.effects,
    required this.overallSeverity,
    this.relatedToShot,
    this.daysSinceShot,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      if (date != null) 'date': date!.toIso8601String(),
      'effects': effects.map((e) => e.toJson()).toList(),
      'overallSeverity': overallSeverity,
      if (relatedToShot != null) 'relatedToShot': relatedToShot,
      if (daysSinceShot != null) 'daysSinceShot': daysSinceShot,
      if (notes != null && notes!.isNotEmpty) 'notes': notes,
    };
  }
}

class SideEffectTrends {
  final int totalLogs;
  final List<EffectCount> mostCommonEffects;
  final double averageSeverity;
  final int shotRelatedPercentage;
  final String? message;

  SideEffectTrends({
    required this.totalLogs,
    required this.mostCommonEffects,
    required this.averageSeverity,
    required this.shotRelatedPercentage,
    this.message,
  });

  factory SideEffectTrends.fromJson(Map<String, dynamic> json) {
    return SideEffectTrends(
      totalLogs: json['totalLogs'] ?? 0,
      mostCommonEffects: (json['mostCommonEffects'] as List? ?? [])
          .map((e) => EffectCount.fromJson(e))
          .toList(),
      averageSeverity: (json['averageSeverity'] ?? 0).toDouble(),
      shotRelatedPercentage: json['shotRelatedPercentage'] ?? 0,
      message: json['message'],
    );
  }
}

class EffectCount {
  final String effect;
  final int count;

  EffectCount({
    required this.effect,
    required this.count,
  });

  factory EffectCount.fromJson(Map<String, dynamic> json) {
    return EffectCount(
      effect: json['effect'] ?? '',
      count: json['count'] ?? 0,
    );
  }
}
