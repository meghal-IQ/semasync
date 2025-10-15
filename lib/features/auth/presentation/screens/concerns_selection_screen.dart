import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../data/auth_data.dart';
import 'auth_loading_screen.dart';

class ConcernsSelectionScreen extends StatefulWidget {
  const ConcernsSelectionScreen({super.key});

  @override
  State<ConcernsSelectionScreen> createState() => _ConcernsSelectionScreenState();
}

class _ConcernsSelectionScreenState extends State<ConcernsSelectionScreen> {
  Set<int> _selectedConcerns = {};
  
  final List<String> _concerns = [
    'Nausea',
    'Fatigue',
    'Hair Loss',
    'Muscle Loss',
    'Injection Anxiety',
    'Loose Skin',
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
                      'What side effects are you most concerned about?',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    
                    const SizedBox(height: AppConstants.spacing12),
                    
                    // Subtitle
                    const Text(
                      'Share what\'s on your mind — we\'ll tailor support to your needs.',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    
                    const SizedBox(height: AppConstants.spacing32),
                    
                    // Concern Options
                    Expanded(
                      child: ListView.builder(
                        itemCount: _concerns.length,
                        itemBuilder: (context, index) {
                          return _buildConcernOption(_concerns[index], index);
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
                  onPressed: _selectedConcerns.isNotEmpty ? _onContinue : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedConcerns.isNotEmpty ? Colors.black : AppColors.divider,
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
                widthFactor: 0.8, // 80% progress
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

  Widget _buildConcernOption(String concern, int index) {
    final isSelected = _selectedConcerns.contains(index);
    
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.spacing12),
      child: GestureDetector(
        onTap: () {
          setState(() {
            if (isSelected) {
              _selectedConcerns.remove(index);
            } else {
              _selectedConcerns.add(index);
            }
          });
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppConstants.spacing20),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary.withOpacity(0.1) : AppColors.surface,
            borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.divider,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Text(
            concern,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isSelected ? AppColors.primary : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }

  void _onContinue() {
    // Save concerns to authData
    authData.concerns = _selectedConcerns.map((index) => _concerns[index]).toList();
    
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AuthLoadingScreen()),
    );
  }
}
