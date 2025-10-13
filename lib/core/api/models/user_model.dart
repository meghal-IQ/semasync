class UserModel {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final DateTime dateOfBirth;
  final String gender;
  final double height;
  final double weight;
  final PreferredUnits preferredUnits;
  final Glp1Journey glp1Journey;
  final String motivation;
  final List<String> concerns;
  final UserGoals goals;
  final bool isEmailVerified;
  final bool isPhoneVerified;
  final String accountStatus;
  final DateTime? lastLogin;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.dateOfBirth,
    required this.gender,
    required this.height,
    required this.weight,
    required this.preferredUnits,
    required this.glp1Journey,
    required this.motivation,
    required this.concerns,
    required this.goals,
    required this.isEmailVerified,
    required this.isPhoneVerified,
    required this.accountStatus,
    this.lastLogin,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? '',
      email: json['email'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      dateOfBirth: DateTime.parse(json['dateOfBirth'] ?? DateTime.now().toIso8601String()),
      gender: json['gender'] ?? '',
      height: (json['height'] ?? 0).toDouble(),
      weight: (json['weight'] ?? 0).toDouble(),
      preferredUnits: PreferredUnits.fromJson(json['preferredUnits'] ?? {}),
      glp1Journey: Glp1Journey.fromJson(json['glp1Journey'] ?? {}),
      motivation: json['motivation'] ?? '',
      concerns: List<String>.from(json['concerns'] ?? []),
      goals: UserGoals.fromJson(json['goals'] ?? {}),
      isEmailVerified: json['isEmailVerified'] ?? false,
      isPhoneVerified: json['isPhoneVerified'] ?? false,
      accountStatus: json['accountStatus'] ?? 'active',
      lastLogin: json['lastLogin'] != null ? DateTime.parse(json['lastLogin']) : null,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'gender': gender,
      'height': height,
      'weight': weight,
      'preferredUnits': preferredUnits.toJson(),
      'glp1Journey': glp1Journey.toJson(),
      'motivation': motivation,
      'concerns': concerns,
      'goals': goals.toJson(),
      'isEmailVerified': isEmailVerified,
      'isPhoneVerified': isPhoneVerified,
      'accountStatus': accountStatus,
      'lastLogin': lastLogin?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class PreferredUnits {
  final String weight;
  final String height;
  final String distance;

  PreferredUnits({
    required this.weight,
    required this.height,
    required this.distance,
  });

  factory PreferredUnits.fromJson(Map<String, dynamic> json) {
    return PreferredUnits(
      weight: json['weight'] ?? 'lbs',
      height: json['height'] ?? 'ft',
      distance: json['distance'] ?? 'miles',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'weight': weight,
      'height': height,
      'distance': distance,
    };
  }
}

class Glp1Journey {
  final String medication;
  final String startingDose;
  final String frequency;
  final List<String> injectionDays;
  final DateTime? startDate;
  final String? currentDose;
  final bool isActive;

  Glp1Journey({
    required this.medication,
    required this.startingDose,
    required this.frequency,
    required this.injectionDays,
    this.startDate,
    this.currentDose,
    required this.isActive,
  });

  factory Glp1Journey.fromJson(Map<String, dynamic> json) {
    return Glp1Journey(
      medication: json['medication'] ?? '',
      startingDose: json['startingDose'] ?? '',
      frequency: json['frequency'] ?? '',
      injectionDays: List<String>.from(json['injectionDays'] ?? []),
      startDate: json['startDate'] != null ? DateTime.parse(json['startDate']) : null,
      currentDose: json['currentDose'],
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'medication': medication,
      'startingDose': startingDose,
      'frequency': frequency,
      'injectionDays': injectionDays,
      'startDate': startDate?.toIso8601String(),
      'currentDose': currentDose,
      'isActive': isActive,
    };
  }
}

class UserGoals {
  final double? targetWeight;
  final DateTime? targetDate;
  final String primaryGoal;
  final List<String> secondaryGoals;

  UserGoals({
    this.targetWeight,
    this.targetDate,
    required this.primaryGoal,
    required this.secondaryGoals,
  });

  factory UserGoals.fromJson(Map<String, dynamic> json) {
    return UserGoals(
      targetWeight: json['targetWeight']?.toDouble(),
      targetDate: json['targetDate'] != null ? DateTime.parse(json['targetDate']) : null,
      primaryGoal: json['primaryGoal'] ?? 'Weight loss',
      secondaryGoals: List<String>.from(json['secondaryGoals'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'targetWeight': targetWeight,
      'targetDate': targetDate?.toIso8601String(),
      'primaryGoal': primaryGoal,
      'secondaryGoals': secondaryGoals,
    };
  }
}
