import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/providers/weekly_checkup_provider.dart';
import '../../../../core/providers/health_provider.dart';
import '../../../../core/providers/treatment_provider.dart';

class WeeklyCheckupScreen extends StatefulWidget {
  const WeeklyCheckupScreen({super.key});

  @override
  State<WeeklyCheckupScreen> createState() => _WeeklyCheckupScreenState();
}

class _WeeklyCheckupScreenState extends State<WeeklyCheckupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController();
  final _notesController = TextEditingController();
  
  double _overallSeverity = 0.0;
  final List<String> _selectedSideEffects = [];
  String _weightUnit = 'lbs';
  
  bool _isSubmitting = false;

  // Available side effects - matching the design
  final List<String> _availableSideEffects = [
    'Nausea',
    'Vomiting',
    'Constipation',
    'Abdominal Pain',
    'Decreased Appetite',
    'Fatigue',
    'Diarrhea',
    'Dizziness',
    'Headache',
    'Bloating',
    'Heartburn',
    'Mood Changes',
    'Muscle Loss',
    'Loose Skin',
    'Hair Loss',
  ];

  @override
  void initState() {
    super.initState();
    _loadCurrentData();
  }

  void _loadCurrentData() {
    final weeklyCheckupProvider = Provider.of<WeeklyCheckupProvider>(context, listen: false);
    final healthProvider = Provider.of<HealthProvider>(context, listen: false);
    
    // Prefer weight from latest weekly checkup, fallback to health provider
    if (weeklyCheckupProvider.latestCheckup != null) {
      _weightController.text = weeklyCheckupProvider.latestCheckup!.currentWeight.toStringAsFixed(1);
      _weightUnit = weeklyCheckupProvider.latestCheckup!.weightUnit;
    } else if (healthProvider.weightStats?.currentWeight != null) {
      _weightController.text = healthProvider.weightStats!.currentWeight!.toStringAsFixed(1);
      _weightUnit = 'kg'; // Health provider stores in kg
    }
  }

  @override
  void dispose() {
    _weightController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Weekly Checkup',
          style: AppTextStyles.title(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.spacing16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderCard(),
              const SizedBox(height: AppConstants.spacing24),
              _buildWeightSection(),
              const SizedBox(height: AppConstants.spacing24),
              _buildSideEffectsSection(),
              const SizedBox(height: AppConstants.spacing24),
              _buildNotesSection(),
              const SizedBox(height: AppConstants.spacing32),
              _buildSubmitButton(),
              const SizedBox(height: AppConstants.spacing16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        color: AppColors.primarylight,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Weekly Health Checkup',
              style: AppTextStyles.title(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppConstants.spacing8),
            Text(
              'Track your progress and get personalized dosage recommendations based on your weight and side effects.',
              style: AppTextStyles.text(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeightSection() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.lightGrey,
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.monitor_weight,
                  color: AppColors.darkGrey,
                  size: 20,
                ),
                const SizedBox(width: AppConstants.spacing8),
                Text(
                  'Current Weight',
                  style: AppTextStyles.title(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacing16),
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.primary),
                      borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                    ),
                    child: TextFormField(
                      controller: _weightController,
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      style: AppTextStyles.text(
                        fontSize: 16,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Enter weight',
                        border: InputBorder.none,
                        prefixIcon: const Icon(Icons.scale, color: AppColors.primary),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppConstants.spacing12,
                          vertical: AppConstants.spacing16,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your weight';
                        }
                        final weight = double.tryParse(value);
                        if (weight == null) {
                          return 'Please enter a valid weight';
                        }
                        if (_weightUnit == 'lbs') {
                          if (weight < 50 || weight > 500) {
                            return 'Please enter a valid weight (50-500 lbs)';
                          }
                        } else {
                          if (weight < 20 || weight > 250) {
                            return 'Please enter a valid weight (20-250 kg)';
                          }
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                const SizedBox(width: AppConstants.spacing8),
                // Unit toggle buttons
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildUnitButton('lbs', _weightUnit == 'lbs'),
                    const SizedBox(width: AppConstants.spacing4),
                    _buildUnitButton('kg', _weightUnit == 'kg'),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnitButton(String unit, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          final currentWeight = double.tryParse(_weightController.text);
          if (currentWeight != null) {
            if (_weightUnit == 'lbs' && unit == 'kg') {
              _weightController.text = (currentWeight * 0.453592).toStringAsFixed(1);
            } else if (_weightUnit == 'kg' && unit == 'lbs') {
              _weightController.text = (currentWeight * 2.20462).toStringAsFixed(1);
            }
          }
          _weightUnit = unit;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacing16,
          vertical: AppConstants.spacing12,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.darkGrey,
          ),
        ),
        child: Text(
          unit,
          style: AppTextStyles.text(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildSideEffectsSection() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.lightGrey,
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.person_outline,
                  color: AppColors.darkGrey,
                  size: 20,
                ),
                const SizedBox(width: AppConstants.spacing8),
                Text(
                  'Side Effects',
                  style: AppTextStyles.title(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacing12),
            Text(
              'Select any side effects you\'re experiencing',
              style: AppTextStyles.text(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppConstants.spacing16),
            
            // Side effect grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 3.5,
                crossAxisSpacing: AppConstants.spacing8,
                mainAxisSpacing: AppConstants.spacing8,
              ),
              itemCount: _availableSideEffects.length,
              itemBuilder: (context, index) {
                final effect = _availableSideEffects[index];
                final isSelected = _selectedSideEffects.contains(effect);
                return _buildSideEffectButton(effect, isSelected);
              },
            ),
            
            const SizedBox(height: AppConstants.spacing24),
            
            // Overall severity slider
            Text(
              'Overall Severity (0-10)',
              style: AppTextStyles.title(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: AppConstants.spacing12),
            
            Row(
              children: [
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: AppColors.primary,
                      inactiveTrackColor: AppColors.darkGrey,
                      thumbColor: AppColors.primary,
                      overlayColor: AppColors.primary.withOpacity(0.1),
                      trackHeight: 4,
                    ),
                    child: Slider(
                      value: _overallSeverity,
                      min: 0,
                      max: 10,
                      divisions: 10,
                      onChanged: (value) {
                        setState(() {
                          _overallSeverity = value;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(width: AppConstants.spacing8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.spacing12,
                    vertical: AppConstants.spacing6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                  ),
                  child: Text(
                    _overallSeverity.toStringAsFixed(0),
                    style: AppTextStyles.text(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: AppConstants.spacing4),
            Text(
              _getSeverityDescription(_overallSeverity),
              style: AppTextStyles.text(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSideEffectButton(String effect, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedSideEffects.remove(effect);
          } else {
            _selectedSideEffects.add(effect);
          }
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.darkGrey,
          ),
        ),
        child: Center(
          child: Text(
            effect,
            style: AppTextStyles.text(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isSelected ? Colors.white : AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildNotesSection() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.lightGrey,
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.description_outlined,
                  color: AppColors.darkGrey,
                  size: 20,
                ),
                const SizedBox(width: AppConstants.spacing8),
                Text(
                  'Additional Notes',
                  style: AppTextStyles.title(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacing16),
            TextFormField(
              controller: _notesController,
              maxLines: 4,
              style: AppTextStyles.text(
                fontSize: 14,
              ),
              decoration: InputDecoration(
                hintText: 'Any additional Observations or concerns....',
                hintStyle: AppTextStyles.text(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                  borderSide: BorderSide(color: AppColors.darkGrey),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                  borderSide: BorderSide(color: AppColors.darkGrey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                  borderSide: BorderSide(color: AppColors.primary),
                ),
                contentPadding: const EdgeInsets.all(AppConstants.spacing12),
                alignLabelWithHint: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitCheckup,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: AppConstants.spacing16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          ),
          elevation: 0,
        ),
        child: _isSubmitting
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                'Submit Weekly Checkup',
                style: AppTextStyles.text(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }


  String _getSeverityDescription(double severity) {
    if (severity == 0) return 'No Side Effects';
    if (severity <= 2) return 'Mild - barely noticeable';
    if (severity <= 4) return 'Moderate - noticeable but manageable';
    if (severity <= 6) return 'Moderate to severe - affecting daily activities';
    if (severity <= 8) return 'Severe - significantly impacting daily life';
    return 'Very severe - requires immediate attention';
  }

  Future<void> _submitCheckup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final checkupProvider = Provider.of<WeeklyCheckupProvider>(context, listen: false);
      final healthProvider = Provider.of<HealthProvider>(context, listen: false);
      final treatmentProvider = Provider.of<TreatmentProvider>(context, listen: false);

      final currentWeight = double.parse(_weightController.text);
      
      // Use previous weekly checkup weight as previous weight
      double? previousWeight;
      if (checkupProvider.latestCheckup != null) {
        // Use the current weight from the latest checkup as the previous weight
        previousWeight = checkupProvider.latestCheckup!.currentWeight;
      } else {
        // Fallback to health provider if no previous checkup
        previousWeight = healthProvider.weightStats?.currentWeight;
      }
      
      final currentDose = treatmentProvider.latestShot?.dosage;
      final medication = treatmentProvider.latestShot?.medication;

      final success = await checkupProvider.createWeeklyCheckup(
        currentWeight: currentWeight,
        weightUnit: _weightUnit,
        sideEffects: _selectedSideEffects,
        overallSideEffectSeverity: _overallSeverity,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
        previousWeight: previousWeight,
        currentDose: currentDose,
        medication: medication,
        daysOnCurrentDose: 7, // TODO: Calculate from shot history
        totalTreatmentDays: 30, // TODO: Calculate from treatment start date
        healthProvider: healthProvider,
      );

      if (mounted) {
        if (success) {
          await checkupProvider.loadLatestWeeklyCheckup();
          await checkupProvider.loadWeeklyCheckups();
          await healthProvider.loadWeightData();
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Weekly checkup completed successfully!'),
              backgroundColor: AppColors.success,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(checkupProvider.errorMessage ?? 'Failed to submit checkup'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}