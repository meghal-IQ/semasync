import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../data/auth_data.dart';
import 'concerns_selection_screen.dart';

class MotivationSelectionScreen extends StatefulWidget {
  const MotivationSelectionScreen({super.key});

  @override
  State<MotivationSelectionScreen> createState() => _MotivationSelectionScreenState();
}

class _MotivationSelectionScreenState extends State<MotivationSelectionScreen> {
  int _selectedMotivation = -1;
  
  final List<String> _motivations = [
    'I want to feel more confident in my own skin.',
    'I\'m just ready for a fresh start.',
    'I want to boost my energy and strength.',
    'To improve my health and manage PCOS.',
    'I want to show up for the people I love.',
    'I have a special event or milestone coming up.',
    'To feel good wearing the clothes I love again.',
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
                      'What\'s driving you to reach your goal?',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    
                    const SizedBox(height: AppConstants.spacing12),
                    
                    // Subtitle
                    const Text(
                      'I want to do this because...',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    
                    const SizedBox(height: AppConstants.spacing32),
                    
                    // Motivation Options
                    Expanded(
                      child: ListView.builder(
                        itemCount: _motivations.length,
                        itemBuilder: (context, index) {
                          return _buildMotivationOption(_motivations[index], index);
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
                  onPressed: _selectedMotivation != -1 ? _onContinue : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedMotivation != -1 ? Colors.black : AppColors.divider,
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
                widthFactor: 0.7, // 70% progress
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

  Widget _buildMotivationOption(String motivation, int index) {
    final isSelected = _selectedMotivation == index;
    
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.spacing12),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedMotivation = index;
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
            motivation,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }

  void _onContinue() {
    // Save motivation to authData
    final motivations = [
      'I want to feel more confident in my own skin.',
      'I\'m just ready for a fresh start.',
      'I want to boost my energy and strength.',
      'To improve my health and manage PCOS.',
      'I want to show up for the people I love.',
      'I have a special event or milestone coming up.',
      'To feel good wearing the clothes I love again.',
    ];
    
    authData.motivation = motivations[_selectedMotivation];
    
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ConcernsSelectionScreen()),
    );
  }
}
