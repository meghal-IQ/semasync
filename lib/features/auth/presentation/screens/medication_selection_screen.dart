import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../data/auth_data.dart';
import 'dose_selection_screen.dart';

class MedicationSelectionScreen extends StatefulWidget {
  const MedicationSelectionScreen({super.key});

  @override
  State<MedicationSelectionScreen> createState() => _MedicationSelectionScreenState();
}

class _MedicationSelectionScreenState extends State<MedicationSelectionScreen> {
  int _selectedMedication = -1;
  
  final List<String> _medications = [
    'Zepbound®',
    'Mounjaro®',
    'Ozempic®',
    'Wegovy®',
    'Trulicity®',
    'Compounded Semaglutide',
    'Compounded Tirzepatide',
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
                      'Which GLP-1 medication do you plan to use?',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    
                    const SizedBox(height: AppConstants.spacing12),
                    
                    // Subtitle
                    const Text(
                      'If you\'re not sure, pick your best guess — you can always change it later.',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    
                    const SizedBox(height: AppConstants.spacing32),
                    
                    // Medication Options
                    Expanded(
                      child: ListView.builder(
                        itemCount: _medications.length,
                        itemBuilder: (context, index) {
                          return _buildMedicationOption(
                            _medications[index],
                            index,
                          );
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
                  onPressed: _selectedMedication != -1 ? _onContinue : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedMedication != -1 ? Colors.black : AppColors.divider,
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
                widthFactor: 0.2, // 20% progress
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

  Widget _buildMedicationOption(String medication, int index) {
    final isSelected = _selectedMedication == index;
    
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.spacing12),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedMedication = index;
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
            medication,
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
    // Save medication to authData
    final medications = [
      'Zepbound®',
      'Mounjaro®',
      'Ozempic®',
      'Wegovy®',
      'Trulicity®',
      'Compounded Semaglutide',
      'Compounded Tirzepatide',
    ];
    
    authData.medication = medications[_selectedMedication];
    
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const DoseSelectionScreen()),
    );
  }
}
