import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'food_database_service.dart';
import '../config/api_keys.dart';
import 'food_recognition_service.dart';

class ClarifaiFoodService {
  // Use the food-item-recognition model
  static const String _modelId = 'food-item-recognition';
  static const String _baseUrl = 'https://api.clarifai.com/v2/models/$_modelId/outputs';
  static const String _pat = ApiKeys.clarifaiPat;
  static const String _userId = ApiKeys.clarifaiUserId;
  static const String _appId = ApiKeys.clarifaiAppId;
  
  /// Check if API key is configured
  static bool get isConfigured => _pat.isNotEmpty && _pat != 'YOUR_CLARIFAI_API_KEY_HERE';
  
  /// Recognize food items from image URL using Clarifai (like the Node.js example)
  static Future<List<FoodRecognitionResult>> recognizeFoodFromImageUrl(String imageUrl) async {
    try {
      if (!isConfigured) {
        print('❌ Clarifai API key not configured.');
        return [];
      }

      print('🔍 Clarifai: Starting food recognition from URL...');
      print('🔍 Clarifai: Image URL: $imageUrl');

      // Prepare request body for URL-based prediction
      final requestBody = {
        'inputs': [
          {
            'data': {
              'image': {
                'url': imageUrl
              }
            }
          }
        ]
      };

      // Make API request to the correct endpoint
      final url = _baseUrl;
      print('🔍 Clarifai: Making request to: $url');
      print('🔍 Clarifai: Model ID: $_modelId');
      print('🔍 Clarifai: Request body: ${jsonEncode(requestBody)}');
      
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Key $_pat',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      print('🔍 Clarifai: Response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('🔍 Clarifai: Response data: $data');
        return _parseClarifaiResponse(data);
      } else {
        print('❌ Clarifai API error: ${response.statusCode} - ${response.body}');
        if (response.statusCode == 404) {
          print('❌ Model not found. Using food-item-recognition model: $_modelId');
        } else if (response.statusCode == 401) {
          print('❌ Authentication failed. Check your PAT (API key)');
        }
        return [];
      }
    } catch (e) {
      print('❌ Error calling Clarifai API: $e');
      return [];
    }
  }

  /// Recognize food items from image using Clarifai
  static Future<List<FoodRecognitionResult>> recognizeFoodFromImage(File imageFile) async {
    try {
      print('🔍 Clarifai: Starting food recognition...');
      
      if (!isConfigured) {
        print('❌ Clarifai API key not configured.');
        return [];
      }

      // Convert image to base64
      final imageBytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(imageBytes);
      
      // Prepare request body
      final requestBody = {
        'inputs': [
          {
            'data': {
              'image': {
                'base64': base64Image
              }
            }
          }
        ]
      };

      // Make API request to the correct endpoint
      final url = '$_baseUrl';
      print('🔍 Clarifai: Making request to: $url');
      print('🔍 Clarifai: User ID: $_userId, App ID: $_appId');
      print('🔍 Clarifai: Request body: ${jsonEncode(requestBody)}');
      
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Key $_pat',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      print('🔍 Clarifai: Response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('🔍 Clarifai: Response data: $data');
        return _parseClarifaiResponse(data);
      } else {
        print('❌ Clarifai API error: ${response.statusCode} - ${response.body}');
        if (response.statusCode == 404) {
          print('❌ Model not found. Using public General model: $_modelId');
        } else if (response.statusCode == 401) {
          print('❌ Authentication failed. Check your PAT (API key)');
        }
        return [];
      }
    } catch (e) {
      print('❌ Error calling Clarifai API: $e');
      return [];
    }
  }

  /// Parse Clarifai API response and convert to food recognition results
  static List<FoodRecognitionResult> _parseClarifaiResponse(Map<String, dynamic> data) {
    try {
      final List<FoodRecognitionResult> results = [];
      
      // Extract concepts from the response
      final outputs = data['outputs'] as List? ?? [];
      
      for (final output in outputs) {
        final data = output['data'] as Map<String, dynamic>? ?? {};
        final concepts = data['concepts'] as List? ?? [];
        
        for (final concept in concepts) {
          final name = concept['name'] as String? ?? '';
          final value = (concept['value'] as num? ?? 0.0).toDouble();
          
          // Filter for food-related concepts with high confidence
          if (_isFoodRelated(name) && value > 0.7) {
            print('🔍 Clarifai: Found food concept: $name (${(value * 100).toInt()}%)');
            
            // Try to find matching food in our database
            final foodItem = _findMatchingFood(name);
            if (foodItem != null) {
              results.add(FoodRecognitionResult(
                foodItem: foodItem,
                confidence: value,
                servingSize: foodItem.servingSize,
              ));
            }
          }
        }
      }
      
      // Sort by confidence and limit to top 3
      results.sort((a, b) => b.confidence.compareTo(a.confidence));
      final topResults = results.take(3).toList();
      
      print('✅ Clarifai: Found ${topResults.length} food items');
      return topResults;
      
    } catch (e) {
      print('❌ Error parsing Clarifai response: $e');
      return [];
    }
  }

  /// Check if a concept is food-related
  static bool _isFoodRelated(String concept) {
    final foodKeywords = [
      'food', 'dish', 'meal', 'cuisine', 'cooking', 'recipe', 'ingredient',
      'pizza', 'burger', 'sandwich', 'pasta', 'spaghetti', 'lasagna', 'ravioli',
      'rice', 'biryani', 'fried rice', 'risotto', 'paella', 'pilaf', 'couscous',
      'chicken', 'beef', 'pork', 'lamb', 'fish', 'salmon', 'tuna', 'shrimp',
      'vegetable', 'fruit', 'bread', 'meat', 'curry', 'salad', 'soup',
      'cheese', 'milk', 'yogurt', 'egg', 'butter', 'oil', 'sugar', 'salt',
      'spice', 'herb', 'nut', 'grain', 'cereal', 'snack', 'dessert',
      'drink', 'beverage', 'sauce', 'dressing', 'marinade', 'glaze',
      'apple', 'banana', 'orange', 'tomato', 'potato', 'onion', 'carrot',
      'broccoli', 'lettuce', 'spinach', 'corn', 'pepper', 'mushroom',
      'cucumber', 'avocado', 'lemon', 'lime', 'grape', 'strawberry',
      'blueberry', 'peach', 'pear', 'cherry', 'watermelon', 'pineapple',
      'mango', 'kiwi', 'coconut', 'almond', 'walnut', 'peanut', 'cashew',
      'pistachio', 'hazelnut', 'pecan', 'macadamia', 'sunflower', 'pumpkin',
      'sesame', 'flax', 'chia', 'quinoa', 'oats', 'barley', 'wheat', 'rye',
      'buckwheat', 'millet', 'sorghum', 'amaranth', 'teff', 'spelt', 'kamut',
      'farro', 'bulgur', 'noodles', 'cooked', 'baked', 'fried', 'grilled',
      'boiled', 'steamed', 'roasted', 'sautéed', 'stir-fried', 'marinated',
      'seasoned', 'flavored', 'spiced', 'herbed', 'garlic', 'ginger', 'chili',
      'hot', 'spicy', 'sweet', 'sour', 'bitter', 'salty', 'umami', 'savory',
      'tasty', 'delicious', 'yummy', 'appetizing', 'mouthwatering', 'flavorful',
      'aromatic', 'fragrant', 'fresh', 'raw', 'organic', 'healthy', 'nutrition',
      'calorie', 'protein', 'carb', 'fat', 'fiber', 'vitamin', 'mineral'
    ];
    
    final conceptLower = concept.toLowerCase();
    return foodKeywords.any((keyword) => conceptLower.contains(keyword));
  }

  /// Find matching food item in our database
  static FoodItem? _findMatchingFood(String concept) {
    // This is a simplified matching - in a real app, you'd have a more sophisticated matching algorithm
    final conceptLower = concept.toLowerCase();
    
    // Map common concepts to food items
    if (conceptLower.contains('pizza')) {
      return _createFoodItem(
        'Pizza (Margherita)',
        266.0, 11.0, 33.0, 10.0, 2.5,
        '1 slice', 'Generic', 'Fast Food',
        4.5, 0, 0, 0, 0, 590.0, 0, 0, 0, 150.0, 180.0, 1.8, 148.0, 9.2
      );
    } else if (conceptLower.contains('burger') || conceptLower.contains('sandwich')) {
      return _createFoodItem(
        'Sandwich (Turkey & Cheese)',
        250.0, 15.0, 28.0, 9.0, 3.0,
        '1 sandwich', 'Generic', 'Fast Food',
        3.2, 2.0, 3.0, 0, 40.0, 680.0, 4.2, 1.0, 0, 220.0, 120.0, 2.1, 45.0, 2.5
      );
    } else if (conceptLower.contains('rice') || conceptLower.contains('biryani')) {
      return _createFoodItem(
        'Chicken Biryani',
        320.0, 18.0, 45.0, 8.0, 2.5,
        '1 plate', 'Homemade', 'Indian Main Course',
        2.8, 1.5, 2.0, 0, 60.0, 520.0, 3.5, 0, 0, 380.0, 65.0, 2.2, 85.0, 12.0
      );
    } else if (conceptLower.contains('chicken')) {
      return _createFoodItem(
        'Chicken Breast (Cooked)',
        165.0, 31.0, 0.0, 3.6, 0.0,
        '100g', 'Generic', 'Meat',
        1.0, 0.8, 1.1, 0, 85.0, 74.0, 0, 0, 0, 255.0, 11.0, 1.0, 0, 0
      );
    } else if (conceptLower.contains('bread')) {
      return _createFoodItem(
        'Bread (White)',
        265.0, 9.0, 49.0, 3.2, 2.7,
        '100g', 'Generic', 'Bakery',
        0.7, 1.3, 0.6, 0, 0, 494.0, 5.5, 3.0, 0, 100.0, 100.0, 3.6, 0, 0
      );
    }
    
    // Default fallback
    return _createFoodItem(
      'Mixed Food Item',
      200.0, 10.0, 25.0, 8.0, 3.0,
      '1 serving', 'Generic', 'Mixed',
      2.0, 1.0, 2.0, 0, 30.0, 400.0, 5.0, 2.0, 0, 200.0, 50.0, 1.5, 50.0, 10.0
    );
  }

  /// Helper method to create FoodItem
  static FoodItem _createFoodItem(
    String name,
    double calories,
    double protein,
    double carbs,
    double fat,
    double fiber,
    String servingSize,
    String brand,
    String category,
    double saturatedFat,
    double polyunsaturatedFat,
    double monounsaturatedFat,
    double transFat,
    double cholesterol,
    double sodium,
    double totalSugars,
    double addedSugar,
    double potassium,
    double calcium,
    double iron,
    double vitaminA,
    double vitaminC,
    double vitaminD,
  ) {
    return FoodItem(
      id: 'clarifai_${name.toLowerCase().replaceAll(' ', '_')}',
      name: name,
      calories: calories,
      protein: protein,
      carbs: carbs,
      fat: fat,
      fiber: fiber,
      servingSize: servingSize,
      brand: brand,
      category: category,
      saturatedFat: saturatedFat,
      polyunsaturatedFat: polyunsaturatedFat,
      monounsaturatedFat: monounsaturatedFat,
      transFat: transFat,
      cholesterol: cholesterol,
      sodium: sodium,
      totalSugars: totalSugars,
      addedSugar: addedSugar,
      potassium: potassium,
      calcium: calcium,
      iron: iron,
      vitaminA: vitaminA,
      vitaminC: vitaminC,
      vitaminD: vitaminD,
    );
  }
}
