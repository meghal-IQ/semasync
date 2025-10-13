import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
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

  // Available side effects
  final List<String> _availableSideEffects = [
    'Nausea',
    'Vomiting',
    'Diarrhea',
    'Constipation',
    'Fatigue',
    'Headache',
    'Dizziness',
    'Abdominal Pain',
    'Decreased Appetite',
    'Injection Site Reaction',
    'Heartburn',
    'Bloating',
    'Hair Loss',
    'Muscle Loss',
    'Low Blood Sugar',
    'Mood Changes',
    'Sleep Disturbances',
    'Dry Mouth',
    'Sulfur Burps',
    'Food Noise',
    'Loose Skin',
    'Injection Anxiety',
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
      appBar: AppBar(
        title: const Text('Weekly Checkup'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
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
        color: AppColors.primary.withOpacity(0.1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacing16),
        child: Row(
          children: [
            Icon(
              Icons.medical_services,
              color: AppColors.primary,
              size: 32,
            ),
            const SizedBox(width: AppConstants.spacing16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Weekly Health Checkup',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacing4),
                  Text(
                    'Track your progress and get personalized dosage recommendations based on your weight and side effects.',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
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
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
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
                  color: AppColors.primary,
                  size: 24,
                ),
                const SizedBox(width: AppConstants.spacing8),
                const Text(
                  'Current Weight',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacing16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _weightController,
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      hintText: 'Enter your current weight',
                      border: const OutlineInputBorder(),
                      suffixText: _weightUnit,
                      prefixIcon: const Icon(Icons.scale),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your weight';
                      }
                      final weight = double.tryParse(value);
                      if (weight == null) {
                        return 'Please enter a valid weight';
                      }
                      // Adjust validation based on unit
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
                const SizedBox(width: AppConstants.spacing12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacing12),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.textSecondary),
                  ),
                  child: DropdownButton<String>(
                    value: _weightUnit,
                    underline: const SizedBox(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          // Convert weight when changing units
                          final currentWeight = double.tryParse(_weightController.text);
                          if (currentWeight != null) {
                            if (_weightUnit == 'lbs' && newValue == 'kg') {
                              // Convert lbs to kg
                              _weightController.text = (currentWeight * 0.453592).toStringAsFixed(1);
                            } else if (_weightUnit == 'kg' && newValue == 'lbs') {
                              // Convert kg to lbs
                              _weightController.text = (currentWeight * 2.20462).toStringAsFixed(1);
                            }
                          }
                          _weightUnit = newValue;
                        });
                      }
                    },
                    items: <String>['lbs', 'kg'].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSideEffectsSection() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.warning_amber,
                  color: AppColors.warning,
                  size: 24,
                ),
                const SizedBox(width: AppConstants.spacing8),
                const Text(
                  'Side Effects',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacing16),
            
            // Side effect selection
            const Text(
              'Select any side effects you\'re experiencing:',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppConstants.spacing12),
            
            Wrap(
              spacing: AppConstants.spacing8,
              runSpacing: AppConstants.spacing8,
              children: _availableSideEffects.map((effect) {
                final isSelected = _selectedSideEffects.contains(effect);
                return FilterChip(
                  label: Text(effect),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedSideEffects.add(effect);
                      } else {
                        _selectedSideEffects.remove(effect);
                      }
                    });
                  },
                  selectedColor: AppColors.primary.withOpacity(0.2),
                  checkmarkColor: AppColors.primary,
                );
              }).toList(),
            ),
            
            const SizedBox(height: AppConstants.spacing24),
            
            // Overall severity slider
            const Text(
              'Overall Severity (0-10)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppConstants.spacing8),
            
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: _overallSeverity,
                    min: 0,
                    max: 10,
                    divisions: 10,
                    label: _overallSeverity.toStringAsFixed(1),
                    onChanged: (value) {
                      setState(() {
                        _overallSeverity = value;
                      });
                    },
                    activeColor: _getSeverityColor(_overallSeverity),
                  ),
                ),
                Container(
                  width: 60,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.spacing8,
                    vertical: AppConstants.spacing4,
                  ),
                  decoration: BoxDecoration(
                    color: _getSeverityColor(_overallSeverity).withOpacity(0.1),
                    border: Border.all(
                      color: _getSeverityColor(_overallSeverity).withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    _overallSeverity.toStringAsFixed(1),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _getSeverityColor(_overallSeverity),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            
            // Severity description
            Text(
              _getSeverityDescription(_overallSeverity),
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesSection() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.note_alt,
                  color: AppColors.textSecondary,
                  size: 24,
                ),
                const SizedBox(width: AppConstants.spacing8),
                const Text(
                  'Additional Notes (Optional)',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacing16),
            TextFormField(
              controller: _notesController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Any additional observations or concerns...',
                border: OutlineInputBorder(),
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
      child: ElevatedButton.icon(
        onPressed: _isSubmitting ? null : _submitCheckup,
        icon: _isSubmitting
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Icon(Icons.medical_services),
        label: Text(_isSubmitting ? 'Submitting...' : 'Submit Weekly Checkup'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: AppConstants.spacing16),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Color _getSeverityColor(double severity) {
    if (severity <= 2) return AppColors.success;
    if (severity <= 4) return AppColors.warning;
    if (severity <= 6) return Colors.orange;
    return AppColors.error;
  }

  String _getSeverityDescription(double severity) {
    if (severity == 0) return 'No side effects';
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
          // Refresh data before navigating back
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