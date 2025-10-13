import 'package:flutter/foundation.dart';

class FoodItem {
  final String id;
  final String name;
  final String? barcode;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double fiber;
  final String servingSize;
  final String? brand;
  final String category;
  
  // Additional nutritional information
  final double saturatedFat;
  final double polyunsaturatedFat;
  final double monounsaturatedFat;
  final double transFat;
  final double cholesterol;
  final double sodium;
  final double totalSugars;
  final double addedSugar;
  final double potassium;
  final double calcium;
  final double iron;
  final double vitaminA;
  final double vitaminC;
  final double vitaminD;

  FoodItem({
    required this.id,
    required this.name,
    this.barcode,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.fiber,
    required this.servingSize,
    this.brand,
    required this.category,
    this.saturatedFat = 0,
    this.polyunsaturatedFat = 0,
    this.monounsaturatedFat = 0,
    this.transFat = 0,
    this.cholesterol = 0,
    this.sodium = 0,
    this.totalSugars = 0,
    this.addedSugar = 0,
    this.potassium = 0,
    this.calcium = 0,
    this.iron = 0,
    this.vitaminA = 0,
    this.vitaminC = 0,
    this.vitaminD = 0,
  });

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      barcode: json['barcode'],
      calories: (json['calories'] ?? 0).toDouble(),
      protein: (json['protein'] ?? 0).toDouble(),
      carbs: (json['carbs'] ?? 0).toDouble(),
      fat: (json['fat'] ?? 0).toDouble(),
      fiber: (json['fiber'] ?? 0).toDouble(),
      servingSize: json['servingSize'] ?? '100g',
      brand: json['brand'],
      category: json['category'] ?? 'Unknown',
      saturatedFat: (json['saturatedFat'] ?? 0).toDouble(),
      polyunsaturatedFat: (json['polyunsaturatedFat'] ?? 0).toDouble(),
      monounsaturatedFat: (json['monounsaturatedFat'] ?? 0).toDouble(),
      transFat: (json['transFat'] ?? 0).toDouble(),
      cholesterol: (json['cholesterol'] ?? 0).toDouble(),
      sodium: (json['sodium'] ?? 0).toDouble(),
      totalSugars: (json['totalSugars'] ?? 0).toDouble(),
      addedSugar: (json['addedSugar'] ?? 0).toDouble(),
      potassium: (json['potassium'] ?? 0).toDouble(),
      calcium: (json['calcium'] ?? 0).toDouble(),
      iron: (json['iron'] ?? 0).toDouble(),
      vitaminA: (json['vitaminA'] ?? 0).toDouble(),
      vitaminC: (json['vitaminC'] ?? 0).toDouble(),
      vitaminD: (json['vitaminD'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'barcode': barcode,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'fiber': fiber,
      'servingSize': servingSize,
      'brand': brand,
      'category': category,
      'saturatedFat': saturatedFat,
      'polyunsaturatedFat': polyunsaturatedFat,
      'monounsaturatedFat': monounsaturatedFat,
      'transFat': transFat,
      'cholesterol': cholesterol,
      'sodium': sodium,
      'totalSugars': totalSugars,
      'addedSugar': addedSugar,
      'potassium': potassium,
      'calcium': calcium,
      'iron': iron,
      'vitaminA': vitaminA,
      'vitaminC': vitaminC,
      'vitaminD': vitaminD,
    };
  }
}

class FoodDatabaseService {
  // Mock food database for demonstration
  static final List<FoodItem> _mockFoodDatabase = [
    FoodItem(
      id: '1',
      name: 'Chicken Breast',
      barcode: '123456789',
      calories: 165,
      protein: 31,
      carbs: 0,
      fat: 3.6,
      fiber: 0,
      servingSize: '100g',
      brand: 'Generic',
      category: 'Protein',
    ),
    FoodItem(
      id: '2',
      name: 'Salmon Fillet',
      barcode: '123456790',
      calories: 208,
      protein: 25,
      carbs: 0,
      fat: 12,
      fiber: 0,
      servingSize: '100g',
      brand: 'Generic',
      category: 'Protein',
    ),
    FoodItem(
      id: '3',
      name: 'Greek Yogurt',
      barcode: '123456793',
      calories: 100,
      protein: 17,
      carbs: 6,
      fat: 0,
      fiber: 0,
      servingSize: '100g',
      brand: 'Generic',
      category: 'Dairy',
    ),
    FoodItem(
      id: '4',
      name: 'Brown Rice',
      barcode: '123456795',
      calories: 111,
      protein: 2.6,
      carbs: 23,
      fat: 0.9,
      fiber: 1.8,
      servingSize: '100g',
      brand: 'Generic',
      category: 'Grains',
    ),
    FoodItem(
      id: '5',
      name: 'Banana',
      barcode: '123456799',
      calories: 89,
      protein: 1.1,
      carbs: 23,
      fat: 0.3,
      fiber: 2.6,
      servingSize: '100g',
      brand: 'Generic',
      category: 'Fruits',
    ),
    FoodItem(
      id: '6',
      name: 'Broccoli',
      barcode: '123456801',
      calories: 34,
      protein: 2.8,
      carbs: 7,
      fat: 0.4,
      fiber: 2.6,
      servingSize: '100g',
      brand: 'Generic',
      category: 'Vegetables',
    ),
    FoodItem(
      id: '7',
      name: 'Almonds',
      barcode: '123456805',
      calories: 579,
      protein: 21,
      carbs: 22,
      fat: 50,
      fiber: 12,
      servingSize: '100g',
      brand: 'Generic',
      category: 'Nuts',
    ),
    FoodItem(
      id: '8',
      name: 'Grilled Chicken Salad',
      barcode: '123456809',
      calories: 250,
      protein: 30,
      carbs: 15,
      fat: 8,
      fiber: 3,
      servingSize: '1 serving',
      brand: 'Generic',
      category: 'Meal',
    ),
    
    // Indian Foods
    FoodItem(
      id: 'indian_1',
      name: 'Pav Bhaji',
      barcode: null,
      calories: 523,
      protein: 14,
      carbs: 91,
      fat: 14,
      fiber: 11,
      servingSize: '1 plate',
      brand: 'Homemade',
      category: 'Indian Street Food',
      saturatedFat: 3,
      polyunsaturatedFat: 2,
      monounsaturatedFat: 4,
      transFat: 0,
      cholesterol: 0,
      sodium: 806,
      totalSugars: 8,
      addedSugar: 0,
      potassium: 860,
      calcium: 76,
      iron: 3,
      vitaminA: 500,
      vitaminC: 42,
      vitaminD: 0,
    ),
    FoodItem(
      id: 'indian_2',
      name: 'Dal Makhani',
      barcode: null,
      calories: 280,
      protein: 15,
      carbs: 35,
      fat: 8,
      fiber: 12,
      servingSize: '1 bowl (250g)',
      brand: 'Homemade',
      category: 'Indian Curry',
    ),
    FoodItem(
      id: 'indian_3',
      name: 'Biryani',
      barcode: null,
      calories: 450,
      protein: 20,
      carbs: 55,
      fat: 15,
      fiber: 3,
      servingSize: '1 plate (400g)',
      brand: 'Homemade',
      category: 'Indian Rice',
    ),
    FoodItem(
      id: 'indian_4',
      name: 'Samosa',
      barcode: null,
      calories: 180,
      protein: 4,
      carbs: 22,
      fat: 8,
      fiber: 2,
      servingSize: '1 piece (50g)',
      brand: 'Homemade',
      category: 'Indian Snack',
    ),
    FoodItem(
      id: 'indian_5',
      name: 'Chole Bhature',
      barcode: null,
      calories: 520,
      protein: 18,
      carbs: 65,
      fat: 20,
      fiber: 10,
      servingSize: '1 plate (400g)',
      brand: 'Homemade',
      category: 'Indian Breakfast',
    ),
    FoodItem(
      id: 'indian_6',
      name: 'Masala Dosa',
      barcode: null,
      calories: 320,
      protein: 8,
      carbs: 45,
      fat: 10,
      fiber: 6,
      servingSize: '1 dosa (200g)',
      brand: 'Homemade',
      category: 'South Indian',
    ),
    FoodItem(
      id: 'indian_7',
      name: 'Rajma Chawal',
      barcode: null,
      calories: 380,
      protein: 16,
      carbs: 60,
      fat: 8,
      fiber: 15,
      servingSize: '1 plate (350g)',
      brand: 'Homemade',
      category: 'Indian Curry',
    ),
    FoodItem(
      id: 'indian_8',
      name: 'Idli Sambar',
      barcode: null,
      calories: 180,
      protein: 6,
      carbs: 35,
      fat: 2,
      fiber: 4,
      servingSize: '2 idlis + sambar (200g)',
      brand: 'Homemade',
      category: 'South Indian',
    ),
    FoodItem(
      id: 'indian_9',
      name: 'Butter Chicken',
      barcode: null,
      calories: 420,
      protein: 25,
      carbs: 20,
      fat: 25,
      fiber: 2,
      servingSize: '1 plate (350g)',
      brand: 'Homemade',
      category: 'Indian Curry',
    ),
    FoodItem(
      id: 'indian_10',
      name: 'Palak Paneer',
      barcode: null,
      calories: 280,
      protein: 18,
      carbs: 15,
      fat: 18,
      fiber: 4,
      servingSize: '1 plate (250g)',
      brand: 'Homemade',
      category: 'Indian Curry',
    ),
  ];

  static Future<FoodItem?> getFoodByBarcode(String barcode) async {
    try {
      // Simulate API delay
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Search in mock database
      final food = _mockFoodDatabase.firstWhere(
        (item) => item.barcode == barcode,
        orElse: () => throw Exception('Food not found'),
      );
      
      return food;
    } catch (e) {
      debugPrint('Error getting food by barcode: $e');
      return null;
    }
  }

  static Future<List<FoodItem>> searchFood(String query) async {
    try {
      // Simulate API delay
      await Future.delayed(const Duration(milliseconds: 300));
      
      if (query.isEmpty) {
        return _mockFoodDatabase.take(10).toList();
      }
      
      final results = _mockFoodDatabase.where((item) =>
        item.name.toLowerCase().contains(query.toLowerCase()) ||
        (item.brand?.toLowerCase().contains(query.toLowerCase()) ?? false)
      ).toList();
      
      return results.take(20).toList();
    } catch (e) {
      debugPrint('Error searching food: $e');
      return [];
    }
  }

  static Future<List<FoodItem>> getFoodByCategory(String category) async {
    try {
      await Future.delayed(const Duration(milliseconds: 200));
      
      return _mockFoodDatabase.where((item) => 
        item.category.toLowerCase() == category.toLowerCase()
      ).toList();
    } catch (e) {
      debugPrint('Error getting food by category: $e');
      return [];
    }
  }

  static Future<List<FoodItem>> getAllFoods() async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      return _mockFoodDatabase;
    } catch (e) {
      debugPrint('Error getting all foods: $e');
      return [];
    }
  }

  // Future implementation with real APIs
  static Future<FoodItem?> getFoodByBarcodeFromAPI(String barcode) async {
    try {
      // This would integrate with USDA FoodData Central API
      // For now, return null to use mock data
      return null;
    } catch (e) {
      debugPrint('API error: $e');
      return null;
    }
  }

  static Future<List<FoodItem>> searchFoodFromAPI(String query) async {
    try {
      // This would integrate with USDA FoodData Central API
      // For now, return empty list to use mock data
      return [];
    } catch (e) {
      debugPrint('API error: $e');
      return [];
    }
  }
}
