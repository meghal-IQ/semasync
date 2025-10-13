/// Utility class for converting between different units
class UnitConverter {
  // Weight conversions
  static const double kgToLbsRatio = 2.20462;
  static const double lbsToKgRatio = 0.453592;

  /// Convert weight from kg to the target unit
  static double convertWeight(double weightKg, String targetUnit) {
    if (targetUnit.toLowerCase() == 'lbs') {
      return weightKg * kgToLbsRatio;
    }
    return weightKg; // Already in kg
  }

  /// Convert weight to kg (for API)
  static double convertWeightToKg(double weight, String fromUnit) {
    if (fromUnit.toLowerCase() == 'lbs') {
      return weight * lbsToKgRatio;
    }
    return weight; // Already in kg
  }

  /// Format weight with unit
  static String formatWeight(double weightKg, String unit, {int decimals = 1}) {
    final converted = convertWeight(weightKg, unit);
    return '${converted.toStringAsFixed(decimals)}$unit';
  }

  // Height conversions
  static const double cmToInchRatio = 0.393701;
  static const double inchToCmRatio = 2.54;

  /// Convert height from cm to the target unit
  static double convertHeight(double heightCm, String targetUnit) {
    if (targetUnit.toLowerCase() == 'ft' || targetUnit.toLowerCase() == 'ft/in') {
      return heightCm * cmToInchRatio;
    }
    return heightCm; // Already in cm
  }

  /// Convert height to cm (for API)
  static double convertHeightToCm(double height, String fromUnit) {
    if (fromUnit.toLowerCase() == 'ft' || fromUnit.toLowerCase() == 'ft/in') {
      return height * inchToCmRatio;
    }
    return height; // Already in cm
  }

  /// Format height as feet and inches
  static String formatHeightFeetInches(double heightCm) {
    final totalInches = heightCm * cmToInchRatio;
    final feet = totalInches ~/ 12;
    final inches = (totalInches % 12).round();
    return '$feet\'$inches"';
  }

  // Water conversions
  static const double mlToOzRatio = 0.033814;
  static const double ozToMlRatio = 29.5735;

  /// Convert water from ml to the target unit
  static double convertWater(double waterMl, String targetUnit) {
    if (targetUnit.toLowerCase() == 'oz') {
      return waterMl * mlToOzRatio;
    }
    return waterMl; // Already in ml
  }

  /// Convert water to ml (for API)
  static double convertWaterToMl(double water, String fromUnit) {
    if (fromUnit.toLowerCase() == 'oz') {
      return water * ozToMlRatio;
    }
    return water; // Already in ml
  }

  /// Format water with unit
  static String formatWater(double waterMl, String unit, {int decimals = 0}) {
    final converted = convertWater(waterMl, unit);
    return '${converted.toStringAsFixed(decimals)}$unit';
  }
}


