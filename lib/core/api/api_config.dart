import 'dart:io';

class ApiConfig {
  // Your computer's IP address for physical device testing
  static const String _computerIp = '192.168.1.36';
  
  // Base URL for the API - dynamically determined based on platform
  static String get baseUrl {
    // Production backend server
    return 'http://13.53.200.189:5000';
    
    // Alternative URLs (uncomment to use):
    // ngrok URL - Backend accessible from anywhere! (Updated)
    // return 'https://807d27122274.ngrok-free.app';
    
    // Local development (uncomment to use local backend)
    // if (Platform.isAndroid) {
    //   return 'http://$_computerIp:5000';
    // } else if (Platform.isIOS) {
    //   return 'http://$_computerIp:5000';
    // } else {
    //   return 'http://localhost:5000';
    // }
  }
  
  // Alternative method to detect if running on emulator/simulator
  static String get baseUrlForDevice {
    // You can manually switch between these URLs based on your testing needs:
    // For emulator/simulator: return 'http://10.0.2.2:5000'; // Android emulator
    // For emulator/simulator: return 'http://localhost:5000'; // iOS simulator
    // For physical device: return 'http://$_computerIp:5000';
    
    return 'http://$_computerIp:5000'; // Currently set for physical device
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
    print('   Platform: ${Platform.operatingSystem}');
    print('   Base URL: $baseUrl');
    print('   Auth Endpoint: $authEndpoint');
  }
}
