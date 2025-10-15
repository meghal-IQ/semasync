// Use this configuration for Android Emulator
import 'dart:io';

class ApiConfig {
  // Your computer's IP address for physical device testing
  static const String _computerIp = '192.168.1.36';
  
  // Base URL for the API - Android emulator special IP
  static String get baseUrl {
    // Production backend server
    return 'http://13.53.200.189:5000';
    
    // Alternative URLs (uncomment to use):
    // For physical Android devices, use your computer's IP
    // return 'http://$_computerIp:5000';
    // For Android emulator, use 10.0.2.2
    // return 'http://10.0.2.2:5000';
  }
  
  // API endpoints
  static String get authEndpoint => '$baseUrl/api/auth';
  
  // Timeout configurations
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);
  
  // Headers
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  
  // Environment-specific configurations
  static bool get isProduction => const bool.fromEnvironment('dart.vm.product');
  static bool get isDevelopment => !isProduction;
  
  // Debug mode
  static bool get debugMode => isDevelopment;
  
  // Print current configuration for debugging
  static void printConfig() {
    print('🔧 API Config:');
    print('   Platform: Android (Physical Device)');
    print('   Base URL: $baseUrl');
    print('   Auth Endpoint: $authEndpoint');
  }
}

