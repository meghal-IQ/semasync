// Meal Log Model
class MealLog {
  final String id;
  final String userId;
  final DateTime date;
  final String mealType;
  final List<Food> foods;
  final double totalCalories;
  final double totalProtein;
  final double totalCarbs;
  final double totalFat;
  final double totalFiber;
  final String? notes;
  final String? photoUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  MealLog({
    required this.id,
    required this.userId,
    required this.date,
    required this.mealType,
    required this.foods,
    required this.totalCalories,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFat,
    required this.totalFiber,
    this.notes,
    this.photoUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MealLog.fromJson(Map<String, dynamic> json) {
    return MealLog(
      id: json['id'] ?? json['_id'] ?? '',
      userId: json['userId'] ?? '',
      date: DateTime.parse(json['date']),
      mealType: json['mealType'] ?? 'snack',
      foods: (json['foods'] as List).map((e) => Food.fromJson(e)).toList(),
      totalCalories: (json['totalCalories'] ?? 0).toDouble(),
      totalProtein: (json['totalProtein'] ?? 0).toDouble(),
      totalCarbs: (json['totalCarbs'] ?? 0).toDouble(),
      totalFat: (json['totalFat'] ?? 0).toDouble(),
      totalFiber: (json['totalFiber'] ?? 0).toDouble(),
      notes: json['notes'],
      photoUrl: json['photoUrl'],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}

class Food {
  final String name;
  final String portion;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double? fiber;

  Food({
    required this.name,
    required this.portion,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.fiber,
  });

  factory Food.fromJson(Map<String, dynamic> json) {
    return Food(
      name: json['name'] ?? '',
      portion: json['portion'] ?? '',
      calories: (json['calories'] ?? 0).toDouble(),
      protein: (json['protein'] ?? 0).toDouble(),
      carbs: (json['carbs'] ?? 0).toDouble(),
      fat: (json['fat'] ?? 0).toDouble(),
      fiber: json['fiber']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'portion': portion,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      if (fiber != null) 'fiber': fiber,
    };
  }
}

class MealLogRequest {
  final DateTime? date;
  final String mealType;
  final List<Food> foods;
  final String? notes;
  final String? photoUrl;

  MealLogRequest({
    this.date,
    required this.mealType,
    required this.foods,
    this.notes,
    this.photoUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      if (date != null) 'date': date!.toIso8601String(),
      'mealType': mealType,
      'foods': foods.map((f) => f.toJson()).toList(),
      if (notes != null && notes!.isNotEmpty) 'notes': notes,
      if (photoUrl != null && photoUrl!.isNotEmpty) 'photoUrl': photoUrl,
    };
  }
}

// Water Log Model
class WaterLog {
  final String id;
  final String userId;
  final DateTime date;
  final int amount;
  final int goal;
  final List<WaterEntry> entries;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  WaterLog({
    required this.id,
    required this.userId,
    required this.date,
    required this.amount,
    required this.goal,
    required this.entries,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory WaterLog.fromJson(Map<String, dynamic> json) {
    return WaterLog(
      id: json['id'] ?? json['_id'] ?? '',
      userId: json['userId'] ?? '',
      date: DateTime.parse(json['date']),
      amount: json['amount'] ?? 0,
      goal: json['goal'] ?? 2500,
      entries: (json['entries'] as List).map((e) => WaterEntry.fromJson(e)).toList(),
      notes: json['notes'],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  double get progressPercentage => (amount / goal * 100).clamp(0, 100);
  bool get goalReached => amount >= goal;
}

class WaterEntry {
  final String time;
  final int amount;
  final String type;

  WaterEntry({
    required this.time,
    required this.amount,
    required this.type,
  });

  factory WaterEntry.fromJson(Map<String, dynamic> json) {
    return WaterEntry(
      time: json['time'] ?? '',
      amount: json['amount'] ?? 0,
      type: json['type'] ?? 'Glass',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'time': time,
      'amount': amount,
      'type': type,
    };
  }
}

class WaterLogRequest {
  final DateTime? date;
  final List<WaterEntry> entries;
  final int? goal;
  final String? notes;

  WaterLogRequest({
    this.date,
    required this.entries,
    this.goal,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      if (date != null) 'date': date!.toIso8601String(),
      'entries': entries.map((e) => e.toJson()).toList(),
      if (goal != null) 'goal': goal,
      if (notes != null && notes!.isNotEmpty) 'notes': notes,
    };
  }
}

class DailyNutritionSummary {
  final String date;
  final int totalMeals;
  final int calories;
  final int protein;
  final int carbs;
  final int fat;
  final int fiber;
  final int water;
  final int waterGoal;

  DailyNutritionSummary({
    required this.date,
    required this.totalMeals,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.fiber,
    required this.water,
    required this.waterGoal,
  });

  factory DailyNutritionSummary.fromJson(Map<String, dynamic> json) {
    return DailyNutritionSummary(
      date: json['date'] ?? '',
      totalMeals: json['totalMeals'] ?? 0,
      calories: json['calories'] ?? 0,
      protein: json['protein'] ?? 0,
      carbs: json['carbs'] ?? 0,
      fat: json['fat'] ?? 0,
      fiber: json['fiber'] ?? 0,
      water: json['water'] ?? 0,
      waterGoal: json['waterGoal'] ?? 2500,
    );
  }

  double get waterProgress => (water / waterGoal * 100).clamp(0, 100);
}
