import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/barcode_scanner_service.dart';
import '../../../../core/services/food_database_service.dart';
import '../../../logging/presentation/screens/meal_logging_screen.dart';

class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  bool _isLoading = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Barcode'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppConstants.spacing16),
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppConstants.spacing20),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.qr_code_scanner,
                    size: 48,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: AppConstants.spacing12),
                  const Text(
                    'Scan Product Barcode',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacing8),
                  Text(
                    'Point your camera at a product barcode to automatically identify and log nutrition information.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: AppConstants.spacing24),
            
            // Scan Button
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(60),
                        border: Border.all(color: AppColors.primary, width: 2),
                      ),
                      child: IconButton(
                        onPressed: _isLoading ? null : _scanBarcode,
                        icon: _isLoading
                            ? const SizedBox(
                                width: 40,
                                height: 40,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                                ),
                              )
                            : Icon(
                                Icons.qr_code_scanner,
                                size: 48,
                                color: AppColors.primary,
                              ),
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacing16),
                    Text(
                      _isLoading ? 'Scanning...' : 'Tap to Scan',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: _isLoading ? Colors.grey[600] : AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacing8),
                    Text(
                      'Position the barcode within the camera view',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Error Message
            if (_errorMessage != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppConstants.spacing12),
                margin: const EdgeInsets.only(bottom: AppConstants.spacing16),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                  border: Border.all(color: AppColors.error.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: AppColors.error, size: 20),
                    const SizedBox(width: AppConstants.spacing8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: AppColors.error, fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            
            // Manual Entry Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MealLoggingScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.search),
                label: const Text('Search Food Manually'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: BorderSide(color: AppColors.primary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _scanBarcode() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final barcode = await BarcodeScannerService.scanBarcode(context);
      
      if (barcode != null) {
        final foodItem = await FoodDatabaseService.getFoodByBarcode(barcode);
        
        if (foodItem != null) {
          _navigateToMealLogging(foodItem);
        } else {
          setState(() {
            _errorMessage = 'Food not found in database. Try manual search instead.';
          });
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to scan barcode. Please try again.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _navigateToMealLogging(FoodItem foodItem) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MealLoggingScreen(
          preselectedFood: foodItem,
        ),
      ),
    );
  }
}
