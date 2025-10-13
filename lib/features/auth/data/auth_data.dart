class AuthData {
  String? email;
  String? password;
  String? firstName;
  String? lastName;
  DateTime? dateOfBirth;
  String? gender;
  double? height;
  double? weight;
  String? medication;
  String? startingDose;
  String? frequency;
  List<String> injectionDays = [];
  DateTime? startDate;
  String? motivation;
  List<String> concerns = [];
  double? targetWeight;
  DateTime? targetDate;
  String? primaryGoal;
  List<String> secondaryGoals = [];
  String? weightUnit;
  String? heightUnit;
  String? distanceUnit;

  AuthData();

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'firstName': firstName,
      'lastName': lastName,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'gender': gender,
      'height': height,
      'weight': weight,
      'preferredUnits': {
        'weight': weightUnit ?? 'lbs',
        'height': heightUnit ?? 'ft',
        'distance': distanceUnit ?? 'miles',
      },
      'glp1Journey': {
        'medication': medication,
        'startingDose': startingDose,
        'frequency': frequency,
        'injectionDays': injectionDays ?? [],
        'startDate': startDate?.toIso8601String(),
      },
      'motivation': motivation,
      'concerns': concerns ?? [],
      'goals': {
        'targetWeight': targetWeight,
        'targetDate': targetDate?.toIso8601String(),
        'primaryGoal': primaryGoal ?? 'Weight loss',
        'secondaryGoals': secondaryGoals ?? [],
      },
    };
  }

  void clear() {
    email = null;
    password = null;
    firstName = null;
    lastName = null;
    dateOfBirth = null;
    gender = null;
    height = null;
    weight = null;
    medication = null;
    startingDose = null;
    frequency = null;
    injectionDays.clear();
    startDate = null;
    motivation = null;
    concerns.clear();
    targetWeight = null;
    targetDate = null;
    primaryGoal = null;
    secondaryGoals.clear();
    weightUnit = null;
    heightUnit = null;
    distanceUnit = null;
  }
}

// Global auth data instance
final AuthData authData = AuthData();
