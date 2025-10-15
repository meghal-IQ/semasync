// Use this configuration if you're running Flutter on iOS Simulator
class ApiConfig {
  // Base URL for the API - Production backend server
  static const String baseUrl = 'http://13.53.200.189:5000';
  
  // API endpoints
  static const String authEndpoint = '$baseUrl/api/auth';
  
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
}
