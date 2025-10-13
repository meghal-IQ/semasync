import 'dart:convert';
import 'package:http/http.dart' as http;

import 'food_database_service.dart';

class USDAFoodService {
  static const String _baseUrl = 'https://api.nal.usda.gov/fdc/v1';
  static const String _apiKey = 'IvCAizCwBdFm32jOaSpX02Dec4whJW8aJo0LmIjF';

  /// Search for food by name
  static Future<List<FoodItem>> searchFood(String query) async {
    try {
      print('🔍 USDA: Searching for "$query"');
      
      final url = Uri.parse('$_baseUrl/foods/search?query=${Uri.encodeComponent(query)}&api_key=$_apiKey&pageSize=10');
      
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final foods = data['foods'] as List? ?? [];
        
        print('✅ USDA: Found ${foods.length} results');
        
        final results = <FoodItem>[];
        for (final food in foods) {
          final foodItem = _convertToFoodItem(food);
          if (foodItem != null) {
            results.add(foodItem);
          }
        }
        
        return results;
      } else {
        print('❌ USDA API error: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print('❌ USDA search failed: $e');
      return [];
    }
  }

  /// Get food details by FDC ID
  static Future<FoodItem?> getFoodById(int fdcId) async {
    try {
      print('🔍 USDA: Getting food by ID $fdcId');
      
      final url = Uri.parse('$_baseUrl/food/$fdcId?api_key=$_apiKey');
      
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return _convertToFoodItem(data);
      } else {
        print('❌ USDA API error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('❌ USDA get by ID failed: $e');
      return null;
    }
  }

  /// Convert USDA data to FoodItem
  static FoodItem? _convertToFoodItem(Map<String, dynamic> data) {
    try {
      print('🔍 USDA: Converting food item: ${data['description']}');
      final foodNutrients = data['foodNutrients'] as List? ?? [];
      print('🔍 USDA: Found ${foodNutrients.length} nutrients');
      
      // Extract nutrients
      double calories = 0;
      double protein = 0;
      double carbs = 0;
      double fat = 0;
      double fiber = 0;
      double saturatedFat = 0;
      double sodium = 0;
      double sugars = 0;
      double calcium = 0;
      double iron = 0;
      double potassium = 0;
      double vitaminA = 0;
      double vitaminC = 0;
      double vitaminD = 0;

      for (int i = 0; i < foodNutrients.length; i++) {
        try {
          final nutrient = foodNutrients[i];
          
          // Debug first nutrient
          if (i == 0) {
            print('🔍 USDA: First nutrient structure: $nutrient');
          }
          
          // Handle USDA nutrient structure
          if (nutrient is! Map<String, dynamic>) {
            continue;
          }

          // Handle both string and numeric values
          dynamic rawValue = nutrient['value'];
          double value = 0.0;
          
          if (rawValue is String) {
            // Extract numeric part from string like "270.0 G"
            final numericPart = rawValue.replaceAll(RegExp(r'[^\d.-]'), '');
            value = double.tryParse(numericPart) ?? 0.0;
          } else if (rawValue is num) {
            value = rawValue.toDouble();
          }
          
          final name = nutrient['nutrientName']?.toString().toLowerCase() ?? '';
          final unit = nutrient['unitName']?.toString() ?? '';

          print('🔍 USDA: Found nutrient: $name = $value $unit');
          
          switch (name) {
          case 'energy':
          case 'energy (kcal)':
            calories = value;
            break;
          case 'protein':
            protein = value;
            break;
          case 'carbohydrate, by difference':
          case 'carbohydrates':
            carbs = value;
            break;
          case 'total lipid (fat)':
          case 'fat':
            fat = value;
            break;
          case 'fiber, total dietary':
          case 'dietary fiber':
            fiber = value;
            break;
          case 'fatty acids, total saturated':
          case 'saturated fat':
            saturatedFat = value;
            break;
          case 'sodium, na':
          case 'sodium':
            sodium = value;
            break;
          case 'sugars, total including nlea':
          case 'total sugars':
            sugars = value;
            break;
          case 'calcium, ca':
          case 'calcium':
            calcium = value;
            break;
          case 'iron, fe':
          case 'iron':
            iron = value;
            break;
          case 'potassium, k':
          case 'potassium':
            potassium = value;
            break;
          case 'vitamin a, rae':
          case 'vitamin a':
            vitaminA = value;
            break;
          case 'vitamin c, total ascorbic acid':
          case 'vitamin c':
            vitaminC = value;
            break;
          case 'vitamin d (d2 + d3)':
          case 'vitamin d':
            vitaminD = value;
            break;
          }
        } catch (e) {
          // Skip problematic nutrient entries
          continue;
        }
      }

      // Get food name and description
      String name = data['description'] ?? 'Unknown Food';
      String brand = data['brandOwner'] ?? 'Generic';
      String category = _determineCategory(data['foodCategory']?['description'] ?? '');
      
      // Clean up the name
      name = name.replaceAll(RegExp(r'\s+'), ' ').trim();
      if (name.length > 50) {
        name = name.substring(0, 50) + '...';
      }

      return FoodItem(
        id: 'usda_${data['fdcId']}',
        name: name,
        barcode: data['gtinUpc']?.toString(),
        calories: calories,
        protein: protein,
        carbs: carbs,
        fat: fat,
        fiber: fiber,
        servingSize: '100g',
        brand: brand,
        category: category,
        saturatedFat: saturatedFat,
        polyunsaturatedFat: 0, // Not commonly available in USDA data
        monounsaturatedFat: 0, // Not commonly available in USDA data
        transFat: 0, // Not commonly available in USDA data
        cholesterol: 0, // Would need to extract separately
        sodium: sodium,
        totalSugars: sugars,
        addedSugar: 0, // Not commonly available in USDA data
        potassium: potassium,
        calcium: calcium,
        iron: iron,
        vitaminA: vitaminA,
        vitaminC: vitaminC,
        vitaminD: vitaminD,
      );
    } catch (e) {
      print('❌ Error converting USDA data: $e');
      return null;
    }
  }

  /// Determine food category from USDA category
  static String _determineCategory(String usdaCategory) {
    final category = usdaCategory.toLowerCase();
    
    if (category.contains('vegetable') || category.contains('legume')) {
      return 'Vegetables';
    } else if (category.contains('fruit')) {
      return 'Fruits';
    } else if (category.contains('grain') || category.contains('cereal')) {
      return 'Grains';
    } else if (category.contains('dairy') || category.contains('milk') || category.contains('cheese')) {
      return 'Dairy';
    } else if (category.contains('meat') || category.contains('poultry') || category.contains('fish')) {
      return 'Protein';
    } else if (category.contains('snack') || category.contains('sweet')) {
      return 'Snacks';
    } else if (category.contains('beverage') || category.contains('drink')) {
      return 'Beverages';
    } else if (category.contains('oil') || category.contains('fat')) {
      return 'Fats & Oils';
    } else {
      return 'Other';
    }
  }
}
