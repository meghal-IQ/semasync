import '../models/auth_models.dart';
import '../models/user_model.dart';

class RegistrationHelper {
  /// Build a RegisterRequest from form data
  static RegisterRequest buildRegisterRequest({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required DateTime dateOfBirth,
    required String gender,
    required double height,
    required double weight,
    required String medication,
    required String startingDose,
    required String frequency,
    List<String>? injectionDays,
    DateTime? startDate,
    required String motivation,
    List<String>? concerns,
    double? targetWeight,
    DateTime? targetDate,
    String? primaryGoal,
    List<String>? secondaryGoals,
    String? weightUnit,
    String? heightUnit,
    String? distanceUnit,
  }) {
    return RegisterRequest(
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
      dateOfBirth: dateOfBirth,
      gender: gender,
      height: height,
      weight: weight,
      preferredUnits: PreferredUnits(
        weight: weightUnit ?? 'lbs',
        height: heightUnit ?? 'ft',
        distance: distanceUnit ?? 'miles',
      ),
      glp1Journey: Glp1Journey(
        medication: medication,
        startingDose: startingDose,
        frequency: frequency,
        injectionDays: injectionDays ?? [],
        startDate: startDate,
        isActive: true,
      ),
      motivation: motivation,
      concerns: concerns ?? [],
      goals: UserGoals(
        targetWeight: targetWeight,
        targetDate: targetDate,
        primaryGoal: primaryGoal ?? 'Weight loss',
        secondaryGoals: secondaryGoals ?? [],
      ),
    );
  }

  /// Validate registration data
  static List<String> validateRegistrationData({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required DateTime dateOfBirth,
    required String gender,
    required double height,
    required double weight,
    required String medication,
    required String startingDose,
    required String frequency,
    required String motivation,
  }) {
    List<String> errors = [];

    // Email validation
    if (email.isEmpty) {
      errors.add('Email is required');
    } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      errors.add('Please enter a valid email address');
    }

    // Password validation
    if (password.isEmpty) {
      errors.add('Password is required');
    } else if (password.length < 6) {
      errors.add('Password must be at least 6 characters long');
    }

    // Name validation
    if (firstName.isEmpty) {
      errors.add('First name is required');
    }
    if (lastName.isEmpty) {
      errors.add('Last name is required');
    }

    // Date of birth validation
    if (dateOfBirth.isAfter(DateTime.now())) {
      errors.add('Date of birth cannot be in the future');
    }
    final age = DateTime.now().difference(dateOfBirth).inDays / 365;
    if (age < 13) {
      errors.add('You must be at least 13 years old');
    }

    // Gender validation
    if (!['male', 'female', 'other'].contains(gender.toLowerCase())) {
      errors.add('Please select a valid gender');
    }

    // Height validation (in cm)
    if (height <= 0) {
      errors.add('Height must be greater than 0');
    } else if (height < 50 || height > 300) {
      errors.add('Height must be between 50 and 300 cm');
    }

    // Weight validation (in kg)
    if (weight <= 0) {
      errors.add('Weight must be greater than 0');
    } else if (weight < 20 || weight > 500) {
      errors.add('Weight must be between 20 and 500 kg');
    }

    // Medication validation
    final validMedications = [
      'Zepbound®',
      'Mounjaro®',
      'Ozempic®',
      'Wegovy®',
      'Trulicity®',
      'Compounded Semaglutide',
      'Compounded Tirzepatide'
    ];
    if (!validMedications.contains(medication)) {
      errors.add('Please select a valid medication');
    }

    // Starting dose validation
    final validDoses = ['0.25mg', '0.5mg', '1.0mg', '1.7mg', '2.4mg'];
    if (!validDoses.contains(startingDose)) {
      errors.add('Please select a valid starting dose');
    }

    // Frequency validation
    final validFrequencies = [
      'Every day',
      'Every 7 days (most common)',
      'Every 14 days',
      'Custom',
      'Not sure, still figuring it out'
    ];
    if (!validFrequencies.contains(frequency)) {
      errors.add('Please select a valid frequency');
    }

    // Motivation validation
    final validMotivations = [
      'I want to feel more confident in my own skin.',
      'I\'m just ready for a fresh start.',
      'I want to boost my energy and strength.',
      'To improve my health and manage PCOS.',
      'I want to show up for the people I love.',
      'I have a special event or milestone coming up.',
      'To feel good wearing the clothes I love again.'
    ];
    if (!validMotivations.contains(motivation)) {
      errors.add('Please select a valid motivation');
    }

    return errors;
  }

  /// Convert height from feet/inches to cm
  static double convertHeightToCm(double feet, double inches) {
    return (feet * 12 + inches) * 2.54;
  }

  /// Convert height from cm to feet/inches
  static Map<String, double> convertHeightFromCm(double cm) {
    final totalInches = cm / 2.54;
    final feet = (totalInches / 12).floor();
    final inches = totalInches % 12;
    return {'feet': feet.toDouble(), 'inches': inches};
  }

  /// Convert weight from lbs to kg
  static double convertWeightToKg(double lbs) {
    return lbs * 0.453592;
  }

  /// Convert weight from kg to lbs
  static double convertWeightFromKg(double kg) {
    return kg / 0.453592;
  }
}
