class WeeklyCheckup {
  final String id;
  final String userId;
  final DateTime date;
  final double currentWeight;
  final String weightUnit;
  final double? weightChange;
  final double? weightChangePercent;
  final List<String> sideEffects;
  final double overallSideEffectSeverity;
  final String dosageRecommendation;
  final String recommendationReason;
  final Map<String, dynamic> bayesianFactors;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  WeeklyCheckup({
    required this.id,
    required this.userId,
    required this.date,
    required this.currentWeight,
    required this.weightUnit,
    this.weightChange,
    this.weightChangePercent,
    required this.sideEffects,
    required this.overallSideEffectSeverity,
    required this.dosageRecommendation,
    required this.recommendationReason,
    required this.bayesianFactors,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory WeeklyCheckup.fromJson(Map<String, dynamic> json) {
    return WeeklyCheckup(
      id: json['id'] ?? json['_id'] ?? '',
      userId: json['userId'] ?? '',
      date: DateTime.parse(json['date']),
      currentWeight: (json['currentWeight'] ?? 0).toDouble(),
      weightUnit: json['weightUnit'] ?? 'lbs',
      weightChange: json['weightChange']?.toDouble(),
      weightChangePercent: json['weightChangePercent']?.toDouble(),
      sideEffects: List<String>.from(json['sideEffects'] ?? []),
      overallSideEffectSeverity: (json['overallSideEffectSeverity'] ?? 0).toDouble(),
      dosageRecommendation: json['dosageRecommendation'] ?? 'continue',
      recommendationReason: json['recommendationReason'] ?? '',
      bayesianFactors: Map<String, dynamic>.from(json['bayesianFactors'] ?? {}),
      notes: json['notes'],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'date': date.toIso8601String(),
      'currentWeight': currentWeight,
      'weightUnit': weightUnit,
      if (weightChange != null) 'weightChange': weightChange,
      if (weightChangePercent != null) 'weightChangePercent': weightChangePercent,
      'sideEffects': sideEffects,
      'overallSideEffectSeverity': overallSideEffectSeverity,
      'dosageRecommendation': dosageRecommendation,
      'recommendationReason': recommendationReason,
      'bayesianFactors': bayesianFactors,
      if (notes != null) 'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class WeeklyCheckupRequest {
  final DateTime? date;
  final double currentWeight;
  final String weightUnit;
  final List<String> sideEffects;
  final double overallSideEffectSeverity;
  final String? notes;

  WeeklyCheckupRequest({
    this.date,
    required this.currentWeight,
    required this.weightUnit,
    required this.sideEffects,
    required this.overallSideEffectSeverity,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      if (date != null) 'date': date!.toIso8601String(),
      'currentWeight': currentWeight,
      'weightUnit': weightUnit,
      'sideEffects': sideEffects,
      'overallSideEffectSeverity': overallSideEffectSeverity,
      if (notes != null && notes!.isNotEmpty) 'notes': notes,
    };
  }
}

enum DosageRecommendation {
  continueCurrent,
  increaseDose,
  decreaseDose,
  pauseTreatment,
  consultDoctor,
}

extension DosageRecommendationExtension on DosageRecommendation {
  String get displayName {
    switch (this) {
      case DosageRecommendation.continueCurrent:
        return 'Continue Current Dose';
      case DosageRecommendation.increaseDose:
        return 'Increase Dose';
      case DosageRecommendation.decreaseDose:
        return 'Decrease Dose';
      case DosageRecommendation.pauseTreatment:
        return 'Pause Treatment';
      case DosageRecommendation.consultDoctor:
        return 'Consult Doctor';
    }
  }

  String get description {
    switch (this) {
      case DosageRecommendation.continueCurrent:
        return 'Your current dosage appears to be working well. Continue with your current treatment plan.';
      case DosageRecommendation.increaseDose:
        return 'Based on your weight loss progress and side effect profile, consider increasing your dose under medical supervision.';
      case DosageRecommendation.decreaseDose:
        return 'Your side effects suggest the current dose may be too high. Consider reducing your dose.';
      case DosageRecommendation.pauseTreatment:
        return 'Severe side effects indicate you should pause treatment and consult your healthcare provider immediately.';
      case DosageRecommendation.consultDoctor:
        return 'Your symptoms require immediate medical attention. Please consult your healthcare provider.';
    }
  }
}

class BayesianDosingFactors {
  final double priorProbability;
  final double likelihood;
  final double posteriorProbability;
  final Map<String, double> individualFactors;
  final String confidenceLevel;

  BayesianDosingFactors({
    required this.priorProbability,
    required this.likelihood,
    required this.posteriorProbability,
    required this.individualFactors,
    required this.confidenceLevel,
  });

  factory BayesianDosingFactors.fromJson(Map<String, dynamic> json) {
    return BayesianDosingFactors(
      priorProbability: (json['priorProbability'] ?? 0).toDouble(),
      likelihood: (json['likelihood'] ?? 0).toDouble(),
      posteriorProbability: (json['posteriorProbability'] ?? 0).toDouble(),
      individualFactors: Map<String, double>.from(
        (json['individualFactors'] as Map<String, dynamic>? ?? {})
            .map((key, value) => MapEntry(key, (value as num).toDouble())),
      ),
      confidenceLevel: json['confidenceLevel'] ?? 'low',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'priorProbability': priorProbability,
      'likelihood': likelihood,
      'posteriorProbability': posteriorProbability,
      'individualFactors': individualFactors,
      'confidenceLevel': confidenceLevel,
    };
  }
}
