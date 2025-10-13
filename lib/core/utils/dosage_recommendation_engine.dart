import '../api/models/weekly_checkup_model.dart';
import '../api/models/weight_log_model.dart';
import '../api/models/shot_log_model.dart';
import 'dart:math';

class DosageRecommendationEngine {
  /// Calculate dosage recommendation based on weight and side effects
  static DosageRecommendation calculateRecommendation({
    required double currentWeight,
    required double? previousWeight,
    required List<String> sideEffects,
    required double overallSideEffectSeverity,
    required String currentDose,
    required String medication,
    required int daysOnCurrentDose,
    required int totalTreatmentDays,
  }) {
    // Bayesian factors calculation
    final bayesianFactors = _calculateBayesianFactors(
      currentWeight: currentWeight,
      previousWeight: previousWeight,
      sideEffects: sideEffects,
      overallSideEffectSeverity: overallSideEffectSeverity,
      currentDose: currentDose,
      medication: medication,
      daysOnCurrentDose: daysOnCurrentDose,
      totalTreatmentDays: totalTreatmentDays,
    );

    // Weight-based factors
    final weightChangeFactor = _calculateWeightChangeFactor(currentWeight, previousWeight);
    final sideEffectFactor = _calculateSideEffectFactor(sideEffects, overallSideEffectSeverity);
    final timeFactor = _calculateTimeFactor(daysOnCurrentDose, totalTreatmentDays);

    // Bayesian posterior probability for dose adjustment
    final posteriorProbability = bayesianFactors.posteriorProbability;

    // Check if current dose is at minimum
    final isAtMinimumDose = _isAtMinimumDose(currentDose);
    final isAtMaximumDose = _isAtMaximumDose(currentDose);

    // Decision logic based on Bayesian analysis
    if (overallSideEffectSeverity >= 8 || _hasSevereSideEffects(sideEffects)) {
      return DosageRecommendation.consultDoctor;
    } else if (overallSideEffectSeverity >= 6 || _hasModerateSevereSideEffects(sideEffects)) {
      // Only recommend decrease if not already at minimum dose
      if (isAtMinimumDose) {
        return DosageRecommendation.consultDoctor; // Can't decrease further
      }
      return DosageRecommendation.decreaseDose;
    } else if (overallSideEffectSeverity >= 4) {
      return DosageRecommendation.continueCurrent;
    } else if (weightChangeFactor > 0.05 && sideEffectFactor < 0.3 && posteriorProbability > 0.7) {
      // Good weight loss, low side effects, high confidence
      // Only recommend increase if not already at maximum dose
      if (isAtMaximumDose) {
        return DosageRecommendation.continueCurrent; // Already at max
      }
      return DosageRecommendation.increaseDose;
    } else if (weightChangeFactor < -0.02 && sideEffectFactor > 0.5) {
      // Weight gain and high side effects
      // Only recommend decrease if not already at minimum dose
      if (isAtMinimumDose) {
        return DosageRecommendation.consultDoctor; // Can't decrease further
      }
      return DosageRecommendation.decreaseDose;
    } else if (timeFactor > 0.8 && weightChangeFactor < 0.02) {
      // Been on dose long enough with minimal weight loss
      // Only recommend increase if not already at maximum dose
      if (isAtMaximumDose) {
        return DosageRecommendation.continueCurrent; // Already at max
      }
      return DosageRecommendation.increaseDose;
    } else {
      return DosageRecommendation.continueCurrent;
    }
  }

  /// Calculate Bayesian factors for dosage recommendation
  static BayesianDosingFactors _calculateBayesianFactors({
    required double currentWeight,
    required double? previousWeight,
    required List<String> sideEffects,
    required double overallSideEffectSeverity,
    required String currentDose,
    required String medication,
    required int daysOnCurrentDose,
    required int totalTreatmentDays,
  }) {
    // Prior probability based on population data for GLP-1 medications
    final priorProbability = _getPriorProbability(medication, currentDose);

    // Likelihood based on individual patient data
    final likelihood = _calculateLikelihood(
      weightChange: previousWeight != null ? (previousWeight - currentWeight) / previousWeight : 0,
      sideEffectSeverity: overallSideEffectSeverity,
      daysOnCurrentDose: daysOnCurrentDose,
      sideEffectTypes: sideEffects,
    );

    // Bayesian update: P(dose_effective|data) = P(data|dose_effective) * P(dose_effective) / P(data)
    final posteriorProbability = (likelihood * priorProbability) / 
        (likelihood * priorProbability + (1 - likelihood) * (1 - priorProbability));

    // Individual factors contributing to the decision
    final individualFactors = <String, double>{
      'weightLossRate': _calculateWeightLossRate(currentWeight, previousWeight),
      'sideEffectTolerance': _calculateSideEffectTolerance(sideEffects, overallSideEffectSeverity),
      'treatmentDuration': _calculateTreatmentDurationFactor(totalTreatmentDays),
      'doseStability': _calculateDoseStabilityFactor(daysOnCurrentDose),
      'medicationResponse': _calculateMedicationResponseFactor(medication, currentDose),
    };

    // Confidence level based on data quality and consistency
    final confidenceLevel = _calculateConfidenceLevel(
      posteriorProbability,
      individualFactors,
      daysOnCurrentDose,
    );

    return BayesianDosingFactors(
      priorProbability: priorProbability,
      likelihood: likelihood,
      posteriorProbability: posteriorProbability,
      individualFactors: individualFactors,
      confidenceLevel: confidenceLevel,
    );
  }

  /// Get prior probability based on medication and dose
  static double _getPriorProbability(String medication, String currentDose) {
    // Population-based probabilities for dose effectiveness
    final doseProbabilities = {
      '0.25mg': 0.3,  // Starting dose, lower effectiveness
      '0.5mg': 0.5,   // Early titration
      '1.0mg': 0.7,   // Standard therapeutic dose
      '1.7mg': 0.8,   // Higher therapeutic dose
      '2.4mg': 0.85,  // Maximum dose
    };

    return doseProbabilities[currentDose] ?? 0.5;
  }

  /// Calculate likelihood based on patient response
  static double _calculateLikelihood({
    required double weightChange,
    required double sideEffectSeverity,
    required int daysOnCurrentDose,
    required List<String> sideEffectTypes,
  }) {
    // Weight loss factor (positive weight change = weight loss)
    final weightLossFactor = weightChange > 0 ? weightChange * 2 : 0;
    
    // Side effect factor (inverse relationship)
    final sideEffectFactor = sideEffectSeverity > 0 ? (10 - sideEffectSeverity) / 10 : 1.0;
    
    // Time factor (longer on dose = more data)
    final timeFactor = daysOnCurrentDose > 14 ? 1.0 : daysOnCurrentDose / 14.0;
    
    // Side effect type factor
    final sideEffectTypeFactor = _calculateSideEffectTypeFactor(sideEffectTypes);

    // Combined likelihood
    return (weightLossFactor * 0.4 + sideEffectFactor * 0.3 + timeFactor * 0.2 + sideEffectTypeFactor * 0.1)
        .clamp(0.0, 1.0);
  }

  /// Calculate weight change factor
  static double _calculateWeightChangeFactor(double currentWeight, double? previousWeight) {
    if (previousWeight == null) return 0.0;
    return (previousWeight - currentWeight) / previousWeight;
  }

  /// Calculate side effect factor
  static double _calculateSideEffectFactor(List<String> sideEffects, double overallSeverity) {
    if (sideEffects.isEmpty) return 0.0;
    
    // Normalize severity (0-1 scale)
    final normalizedSeverity = overallSeverity / 10.0;
    
    // Count of side effects factor
    final countFactor = sideEffects.length / 10.0;
    
    return (normalizedSeverity + countFactor) / 2.0;
  }

  /// Calculate time factor
  static double _calculateTimeFactor(int daysOnCurrentDose, int totalTreatmentDays) {
    // Factor based on how long patient has been on current dose
    final doseStabilityFactor = daysOnCurrentDose > 28 ? 1.0 : daysOnCurrentDose / 28.0;
    
    // Factor based on total treatment duration
    final treatmentDurationFactor = totalTreatmentDays > 90 ? 1.0 : totalTreatmentDays / 90.0;
    
    return (doseStabilityFactor + treatmentDurationFactor) / 2.0;
  }

  /// Calculate weight loss rate
  static double _calculateWeightLossRate(double currentWeight, double? previousWeight) {
    if (previousWeight == null) return 0.0;
    return (previousWeight - currentWeight) / previousWeight;
  }

  /// Calculate side effect tolerance
  static double _calculateSideEffectTolerance(List<String> sideEffects, double overallSeverity) {
    if (sideEffects.isEmpty) return 1.0;
    return (10 - overallSeverity) / 10.0;
  }

  /// Calculate treatment duration factor
  static double _calculateTreatmentDurationFactor(int totalTreatmentDays) {
    return totalTreatmentDays > 180 ? 1.0 : totalTreatmentDays / 180.0;
  }

  /// Calculate dose stability factor
  static double _calculateDoseStabilityFactor(int daysOnCurrentDose) {
    return daysOnCurrentDose > 21 ? 1.0 : daysOnCurrentDose / 21.0;
  }

  /// Calculate medication response factor
  static double _calculateMedicationResponseFactor(String medication, String currentDose) {
    // Different medications have different response profiles
    final medicationFactors = {
      'Zepbound®': 0.9,
      'Mounjaro®': 0.9,
      'Ozempic®': 0.8,
      'Wegovy®': 0.8,
      'Trulicity®': 0.7,
      'Compounded Semaglutide': 0.75,
      'Compounded Tirzepatide': 0.85,
    };

    return medicationFactors[medication] ?? 0.8;
  }

  /// Calculate side effect type factor
  static double _calculateSideEffectTypeFactor(List<String> sideEffectTypes) {
    if (sideEffectTypes.isEmpty) return 1.0;

    // More concerning side effects reduce likelihood
    final concerningEffects = [
      'Vomiting',
      'Severe Nausea',
      'Low Blood Sugar',
      'Severe Abdominal Pain',
      'Severe Dizziness',
    ];

    final concerningCount = sideEffectTypes.where((effect) => concerningEffects.contains(effect)).length;
    return (sideEffectTypes.length - concerningCount) / sideEffectTypes.length;
  }

  /// Calculate confidence level
  static String _calculateConfidenceLevel(
    double posteriorProbability,
    Map<String, double> individualFactors,
    int daysOnCurrentDose,
  ) {
    // Calculate variance in individual factors
    final factorValues = individualFactors.values.toList();
    final mean = factorValues.reduce((a, b) => a + b) / factorValues.length;
    final variance = factorValues.map((x) => (x - mean) * (x - mean)).reduce((a, b) => a + b) / factorValues.length;
    final standardDeviation = sqrt(variance);

    // Confidence based on posterior probability and data consistency
    final consistencyFactor = 1.0 - (standardDeviation / mean).clamp(0.0, 1.0);
    final dataQualityFactor = daysOnCurrentDose > 14 ? 1.0 : daysOnCurrentDose / 14.0;
    
    final confidenceScore = (posteriorProbability * 0.5 + consistencyFactor * 0.3 + dataQualityFactor * 0.2);

    if (confidenceScore >= 0.8) return 'high';
    if (confidenceScore >= 0.6) return 'medium';
    return 'low';
  }

  /// Check for severe side effects
  static bool _hasSevereSideEffects(List<String> sideEffects) {
    final severeEffects = [
      'Severe Nausea',
      'Vomiting',
      'Severe Abdominal Pain',
      'Severe Dizziness',
      'Low Blood Sugar',
      'Severe Fatigue',
    ];
    
    return sideEffects.any((effect) => severeEffects.contains(effect));
  }

  /// Check for moderate to severe side effects
  static bool _hasModerateSevereSideEffects(List<String> sideEffects) {
    final moderateSevereEffects = [
      'Nausea',
      'Abdominal Pain',
      'Dizziness',
      'Fatigue',
      'Headache',
      'Diarrhea',
    ];
    
    return sideEffects.any((effect) => moderateSevereEffects.contains(effect));
  }

  /// Check if current dose is at minimum
  static bool _isAtMinimumDose(String currentDose) {
    const minimumDoses = ['0.25mg', '0.25'];
    return minimumDoses.contains(currentDose);
  }

  /// Check if current dose is at maximum
  static bool _isAtMaximumDose(String currentDose) {
    const maximumDoses = ['2.4mg', '2.4', '2.5mg', '2.5'];
    return maximumDoses.contains(currentDose);
  }

  /// Generate recommendation reason
  static String generateRecommendationReason(
    DosageRecommendation recommendation,
    BayesianDosingFactors bayesianFactors,
    double weightChangeFactor,
    double sideEffectFactor,
    String? currentDose,
  ) {
    final confidence = bayesianFactors.confidenceLevel;
    final posteriorProb = bayesianFactors.posteriorProbability;

    switch (recommendation) {
      case DosageRecommendation.continueCurrent:
        return 'Based on Bayesian analysis (${(posteriorProb * 100).toStringAsFixed(1)}% confidence), your current dose appears optimal. Weight change: ${(weightChangeFactor * 100).toStringAsFixed(1)}%, Side effects: ${(sideEffectFactor * 10).toStringAsFixed(1)}/10.';

      case DosageRecommendation.increaseDose:
        return 'Bayesian analysis suggests dose increase may be beneficial (${(posteriorProb * 100).toStringAsFixed(1)}% confidence). Good weight loss progress with manageable side effects. Consider discussing with your healthcare provider.';

      case DosageRecommendation.decreaseDose:
        final isAtMin = currentDose != null && _isAtMinimumDose(currentDose);
        if (isAtMin) {
          return 'Side effects suggest current dose may be too high (${(posteriorProb * 100).toStringAsFixed(1)}% confidence), but you\'re already at the minimum dose (${currentDose}). Please consult your healthcare provider for alternative approaches.';
        }
        return 'Side effects suggest current dose may be too high (${(posteriorProb * 100).toStringAsFixed(1)}% confidence). Consider reducing dose to improve tolerability while maintaining effectiveness.';

      case DosageRecommendation.pauseTreatment:
        return 'Severe side effects detected. Bayesian analysis indicates high risk (${(posteriorProb * 100).toStringAsFixed(1)}% confidence). Pause treatment and consult healthcare provider immediately.';

      case DosageRecommendation.consultDoctor:
        return 'Complex symptoms require medical evaluation. Bayesian analysis shows ${confidence} confidence level. Please consult your healthcare provider for personalized assessment.';
    }
  }
}
