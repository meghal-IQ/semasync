// Step Log Model
class StepLog {
  final String id;
  final String userId;
  final DateTime date;
  final int steps;
  final int goal;
  final double? distance;
  final double? caloriesBurned;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  StepLog({
    required this.id,
    required this.userId,
    required this.date,
    required this.steps,
    required this.goal,
    this.distance,
    this.caloriesBurned,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory StepLog.fromJson(Map<String, dynamic> json) {
    return StepLog(
      id: json['id'] ?? json['_id'] ?? '',
      userId: json['userId'] ?? '',
      date: DateTime.parse(json['date']),
      steps: json['steps'] ?? 0,
      goal: json['goal'] ?? 10000,
      distance: json['distance']?.toDouble(),
      caloriesBurned: json['caloriesBurned']?.toDouble(),
      notes: json['notes'],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'steps': steps,
      'goal': goal,
      if (distance != null) 'distance': distance,
      if (caloriesBurned != null) 'caloriesBurned': caloriesBurned,
      if (notes != null) 'notes': notes,
    };
  }

  double get progressPercentage => (steps / goal * 100).clamp(0, 100);
  bool get goalReached => steps >= goal;
}

// Workout Log Model
class WorkoutLog {
  final String id;
  final String userId;
  final DateTime date;
  final String type;
  final int duration;
  final int intensity;
  final double caloriesBurned;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  WorkoutLog({
    required this.id,
    required this.userId,
    required this.date,
    required this.type,
    required this.duration,
    required this.intensity,
    required this.caloriesBurned,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory WorkoutLog.fromJson(Map<String, dynamic> json) {
    return WorkoutLog(
      id: json['id'] ?? json['_id'] ?? '',
      userId: json['userId'] ?? '',
      date: DateTime.parse(json['date']),
      type: json['type'] ?? 'Other',
      duration: json['duration'] ?? 0,
      intensity: json['intensity'] ?? 5,
      caloriesBurned: (json['caloriesBurned'] ?? 0).toDouble(),
      notes: json['notes'],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'type': type,
      'duration': duration,
      'intensity': intensity,
      'caloriesBurned': caloriesBurned,
      if (notes != null) 'notes': notes,
    };
  }
}

// Activity Stats Models
class StepStats {
  final int totalDays;
  final int totalSteps;
  final int averageSteps;
  final int goalsReached;
  final int achievementRate;
  final int currentGoal;
  final String? message;

  StepStats({
    required this.totalDays,
    required this.totalSteps,
    required this.averageSteps,
    required this.goalsReached,
    required this.achievementRate,
    required this.currentGoal,
    this.message,
  });

  factory StepStats.fromJson(Map<String, dynamic> json) {
    return StepStats(
      totalDays: json['totalDays'] ?? 0,
      totalSteps: json['totalSteps'] ?? 0,
      averageSteps: json['averageSteps'] ?? 0,
      goalsReached: json['goalsReached'] ?? 0,
      achievementRate: json['achievementRate'] ?? 0,
      currentGoal: json['currentGoal'] ?? 10000,
      message: json['message'],
    );
  }
}

class WorkoutStats {
  final int totalWorkouts;
  final int totalDuration;
  final int totalCalories;
  final double averageIntensity;
  final String? favoriteWorkoutType;
  final Map<String, int> workoutTypeBreakdown;
  final String? message;

  WorkoutStats({
    required this.totalWorkouts,
    required this.totalDuration,
    required this.totalCalories,
    required this.averageIntensity,
    this.favoriteWorkoutType,
    required this.workoutTypeBreakdown,
    this.message,
  });

  factory WorkoutStats.fromJson(Map<String, dynamic> json) {
    return WorkoutStats(
      totalWorkouts: json['totalWorkouts'] ?? 0,
      totalDuration: json['totalDuration'] ?? 0,
      totalCalories: json['totalCalories'] ?? 0,
      averageIntensity: (json['averageIntensity'] ?? 0).toDouble(),
      favoriteWorkoutType: json['favoriteWorkoutType'],
      workoutTypeBreakdown: Map<String, int>.from(json['workoutTypeBreakdown'] ?? {}),
      message: json['message'],
    );
  }
}

class ActivitySummary {
  final int todaySteps;
  final int stepsGoal;
  final int weeklyWorkouts;
  final int weeklyCalories;

  ActivitySummary({
    required this.todaySteps,
    required this.stepsGoal,
    required this.weeklyWorkouts,
    required this.weeklyCalories,
  });

  factory ActivitySummary.fromJson(Map<String, dynamic> json) {
    return ActivitySummary(
      todaySteps: json['todaySteps'] ?? 0,
      stepsGoal: json['stepsGoal'] ?? 10000,
      weeklyWorkouts: json['weeklyWorkouts'] ?? 0,
      weeklyCalories: json['weeklyCalories'] ?? 0,
    );
  }

  double get stepsProgress => (todaySteps / stepsGoal * 100).clamp(0, 100);
}
