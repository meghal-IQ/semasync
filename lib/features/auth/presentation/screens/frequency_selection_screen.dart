import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/auth_data.dart';
import 'shot_day_selection_screen.dart';
import 'birthday_input_screen.dart';

class FrequencySelectionScreen extends StatefulWidget {
  const FrequencySelectionScreen({super.key});

  @override
  State<FrequencySelectionScreen> createState() => _FrequencySelectionScreenState();
}

class _FrequencySelectionScreenState extends State<FrequencySelectionScreen> {
  int _selectedFrequency = -1;
  
  final List<String> _frequencies = [
    'Every day',
    'Every 7 days (most common)',
    'Every 14 days',
    'Custom',
    'Not sure, still figuring it out',
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
                    Text(
                      'How often will you take your shots?',
                      style: AppTextStyles.title(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    
                    const SizedBox(height: AppConstants.spacing12),
                    
                    // Subtitle
                    Text(
                      'Pick not sure, if you don\'t know yet, you\'ll be able to edit this later.',
                      style: AppTextStyles.title(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    
                    const SizedBox(height: AppConstants.spacing32),
                    
                    // Frequency Options
                    Expanded(
                      child: ListView.builder(
                        itemCount: _frequencies.length,
                        itemBuilder: (context, index) {
                          return _buildFrequencyOption(_frequencies[index], index);
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
                  onPressed: _selectedFrequency != -1 ? _onContinue : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedFrequency != -1 ? AppColors.continueButton : AppColors.divider,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: AppConstants.spacing16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                    ),
                  ),
                  child: Text(
                    'Continue',
                    style: AppTextStyles.title(
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
                widthFactor: 0.4, // 40% progress
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

  Widget _buildFrequencyOption(String frequency, int index) {
    final isSelected = _selectedFrequency == index;
    
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.spacing12),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedFrequency = index;
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
            frequency,
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
    // Save frequency to authData
    final frequencies = [
      'Every day',
      'Every 7 days (most common)',
      'Every 14 days',
      'Custom',
      'Not sure, still figuring it out',
    ];
    
    authData.frequency = frequencies[_selectedFrequency];
    
    // If "Not sure" is selected, skip shot day selection and go to birthday
    if (authData.frequency == 'Not sure, still figuring it out') {
      // Set default injection days for "not sure" users
      authData.injectionDays = ['Monday']; // Default to Monday
      authData.startDate = DateTime.now();
      
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const BirthdayInputScreen()),
      );
    } else {
      // Navigate to shot day selection screen for other frequencies
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ShotDaySelectionScreen(
            frequency: authData.frequency!,
          ),
        ),
      );
    }
  }
}
