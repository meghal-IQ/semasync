// Script to update API configuration after backend deployment
// Run this script with: dart update_api_config.dart YOUR_BACKEND_URL

import 'dart:io';

void main(List<String> arguments) {
  if (arguments.isEmpty) {
    print('❌ Please provide your backend URL');
    print('Usage: dart update_api_config.dart https://your-backend-url.com');
    exit(1);
  }

  final backendUrl = arguments.first;
  
  // Validate URL format
  if (!backendUrl.startsWith('http')) {
    print('❌ URL must start with http:// or https://');
    exit(1);
  }

  final apiConfigPath = '../lib/core/api/api_config.dart';
  
  try {
    // Read current file
    final file = File(apiConfigPath);
    String content = file.readAsStringSync();
    
    // Replace the baseUrl method
    final newBaseUrlMethod = '''
  // Base URL for the API - dynamically determined based on platform
  static String get baseUrl {
    // Production backend URL
    return '$backendUrl';
  }''';
    
    // Find and replace the baseUrl getter
    final baseUrlPattern = RegExp(
      r'static String get baseUrl \{[^}]+\}',
      multiLine: true,
      dotAll: true,
    );
    
    if (baseUrlPattern.hasMatch(content)) {
      content = content.replaceFirst(baseUrlPattern, newBaseUrlMethod);
      
      // Also update the baseUrlForDevice method
      final baseUrlForDevicePattern = RegExp(
        r'static String get baseUrlForDevice \{[^}]+\}',
        multiLine: true,
        dotAll: true,
      );
      
      final newBaseUrlForDeviceMethod = '''
  // Alternative method to detect if running on emulator/simulator
  static String get baseUrlForDevice {
    // Production backend URL
    return '$backendUrl';
  }''';
      
      if (baseUrlForDevicePattern.hasMatch(content)) {
        content = content.replaceFirst(baseUrlForDevicePattern, newBaseUrlForDeviceMethod);
      }
      
      // Write updated content
      file.writeAsStringSync(content);
      
      print('✅ API configuration updated successfully!');
      print('   Backend URL: $backendUrl');
      print('   File: $apiConfigPath');
      print('');
      print('📱 Next steps:');
      print('   1. Run: flutter clean');
      print('   2. Run: flutter pub get');
      print('   3. Run: flutter run');
      print('');
      print('🧪 Test your API connection:');
      print('   curl $backendUrl/health');
      
    } else {
      print('❌ Could not find baseUrl method in API config file');
      exit(1);
    }
    
  } catch (e) {
    print('❌ Error updating API configuration: $e');
    exit(1);
  }
}
