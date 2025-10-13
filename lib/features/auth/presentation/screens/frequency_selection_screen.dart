import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../data/auth_data.dart';
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
                    const Text(
                      'How often will you take your shots?',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    
                    const SizedBox(height: AppConstants.spacing12),
                    
                    // Subtitle
                    const Text(
                      'Pick not sure, if you don\'t know yet, you\'ll be able to edit this later.',
                      style: TextStyle(
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
                    backgroundColor: _selectedFrequency != -1 ? Colors.black : AppColors.divider,
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
    
    // Set default injection days based on frequency
    if (authData.frequency == 'Every 7 days (most common)') {
      authData.injectionDays = ['Monday'];
    } else if (authData.frequency == 'Every day') {
      authData.injectionDays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    } else {
      authData.injectionDays = ['Monday']; // Default for other frequencies
    }
    
    // Set default start date to today
    authData.startDate = DateTime.now();
    
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const BirthdayInputScreen()),
    );
  }
}
