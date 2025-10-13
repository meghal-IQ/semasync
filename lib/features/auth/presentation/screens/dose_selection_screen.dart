import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../data/auth_data.dart';
import 'frequency_selection_screen.dart';

class DoseSelectionScreen extends StatefulWidget {
  const DoseSelectionScreen({super.key});

  @override
  State<DoseSelectionScreen> createState() => _DoseSelectionScreenState();
}

class _DoseSelectionScreenState extends State<DoseSelectionScreen> {
  int _selectedDose = -1;
  
  final List<String> _doses = [
    '0.25mg',
    '0.5mg',
    '1.0mg',
    '1.7mg',
    '2.4mg',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Progress Bar
            _buildProgressBar(),
            
            // Main Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.spacing24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    const Text(
                      'Do you know your recommended starting dose?',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    
                    const SizedBox(height: AppConstants.spacing12),
                    
                    // Subtitle
                    const Text(
                      'It\'s okay if you\'re not sure!',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    
                    const SizedBox(height: AppConstants.spacing32),
                    
                    // Dose Options
                    Expanded(
                      child: ListView.builder(
                        itemCount: _doses.length,
                        itemBuilder: (context, index) {
                          return _buildDoseOption(_doses[index], index);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Continue Button
            Padding(
              padding: const EdgeInsets.all(AppConstants.spacing24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _selectedDose != -1 ? _onContinue : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedDose != -1 ? Colors.black : AppColors.divider,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: AppConstants.spacing16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                    ),
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.spacing16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          ),
          Expanded(
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: 0.3, // 30% progress
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoseOption(String dose, int index) {
    final isSelected = _selectedDose == index;
    
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.spacing12),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedDose = index;
          });
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppConstants.spacing20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.divider,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Text(
            dose,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  void _onContinue() {
    // Save starting dose to authData
    final doses = [
      '0.25mg',
      '0.5mg',
      '1.0mg',
      '1.7mg',
      '2.4mg',
    ];
    
    authData.startingDose = doses[_selectedDose];
    
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FrequencySelectionScreen()),
    );
  }
}
