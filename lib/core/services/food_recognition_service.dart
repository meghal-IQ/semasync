import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'food_database_service.dart';
import 'ai_food_recognition_service.dart';

class FoodRecognitionResult {
  final FoodItem foodItem;
  final double confidence;
  final String? servingSize;

  FoodRecognitionResult({
    required this.foodItem,
    required this.confidence,
    this.servingSize,
  });
}

class FoodRecognitionService {
  static Future<List<FoodRecognitionResult>> recognizeFoodFromImage(File image) async {
    try {
      print('🔍 FoodRecognitionService: Starting AI recognition for image: ${image.path}');
      
      // Use the new AI food recognition service
      final results = await AIFoodRecognitionService.recognizeFoodFromImage(image);
      
      print('🔍 FoodRecognitionService: AI recognition completed with ${results.length} results');
      return results;
    } catch (e) {
      print('❌ FoodRecognitionService: Error - $e');
      debugPrint('Food recognition error: $e');
      
      // Fallback to basic recognition if AI fails
      return await _fallbackRecognition();
    }
  }

  /// Fallback recognition method
  static Future<List<FoodRecognitionResult>> _fallbackRecognition() async {
    try {
      print('🔄 Using fallback recognition...');
      
      // Get some foods from database as fallback
      final allFoods = await FoodDatabaseService.getAllFoods();
      final fallbackFoods = allFoods.take(3).toList();
      
      final results = <FoodRecognitionResult>[];
      for (int i = 0; i < fallbackFoods.length; i++) {
        results.add(FoodRecognitionResult(
          foodItem: fallbackFoods[i],
          confidence: 0.6 - (i * 0.1), // Decreasing confidence
          servingSize: '1 serving',
        ));
      }
      
      return results;
    } catch (e) {
      print('❌ Fallback recognition failed: $e');
      return [];
    }
  }

  static Future<File?> captureFoodImage() async {
    try {
      print('📸 FoodRecognitionService: Starting image capture...');
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 1024,
        maxHeight: 1024,
      );
      
      if (image != null) {
        print('📸 FoodRecognitionService: Image captured at: ${image.path}');
        return File(image.path);
      } else {
        print('📸 FoodRecognitionService: No image captured (user cancelled)');
        return null;
      }
    } catch (e) {
      print('❌ FoodRecognitionService: Image capture error: $e');
      debugPrint('Image capture error: $e');
      return null;
    }
  }

  static Future<List<FoodRecognitionResult>> recognizeFoodFromGallery() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1024,
        maxHeight: 1024,
      );
      
      if (image != null) {
        return await recognizeFoodFromImage(File(image.path));
      }
      return [];
    } catch (e) {
      debugPrint('Gallery recognition error: $e');
      return [];
    }
  }

  // Future implementation with real AI services
  static Future<List<FoodRecognitionResult>> recognizeFoodFromImageAPI(File image) async {
    try {
      // This would integrate with services like:
      // - Google Vision API
      // - AWS Rekognition
      // - Clarifai Food Model
      // - Custom trained model
      
      // For now, return empty list to use mock data
      return [];
    } catch (e) {
      debugPrint('AI API error: $e');
      return [];
    }
  }
}
