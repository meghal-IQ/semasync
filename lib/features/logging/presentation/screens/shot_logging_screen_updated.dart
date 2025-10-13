import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/providers/treatment_provider.dart';
import '../../../../core/api/models/shot_log_model.dart';

class ShotLoggingScreenUpdated extends StatefulWidget {
  final ShotLog? existingShot;
  
  const ShotLoggingScreenUpdated({super.key, this.existingShot});

  @override
  State<ShotLoggingScreenUpdated> createState() => _ShotLoggingScreenUpdatedState();
}

class _ShotLoggingScreenUpdatedState extends State<ShotLoggingScreenUpdated> {
  late DateTime _selectedDate;
  late String _selectedMedication;
  late String _selectedDosage;
  String _selectedLocation = 'Left Thigh';
  double _painLevel = 0.0;
  List<String> _selectedSideEffects = ['None'];
  String _notes = '';
  bool _isSaving = false;

  final List<String> _medications = [
    'Ozempic®',
    'Wegovy®',
    'Mounjaro®',
    'Zepbound®',
    'Trulicity®',
    'Compounded Semaglutide',
    'Compounded Tirzepatide',
  ];

  final List<String> _dosages = [
    '0.25mg',
    '0.5mg',
    '0.7mg',
    '1.0mg',
    '1.5mg',
    '1.7mg',
    '2.0mg',
    '2.4mg',
  ];

  final List<String> _injectionSites = [
    'Left Thigh',
    'Right Thigh',
    'Left Arm',
    'Right Arm',
    'Left Abdomen',
    'Right Abdomen',
    'Left Buttock',
    'Right Buttock',
  ];

  final List<String> _sideEffectOptions = [
    'None',
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
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    
    // Initialize from existing shot or defaults
    if (widget.existingShot != null) {
      _selectedDate = widget.existingShot!.date;
      _selectedMedication = widget.existingShot!.medication;
      _selectedDosage = widget.existingShot!.dosage;
      _selectedLocation = widget.existingShot!.injectionSite;
      _painLevel = widget.existingShot!.painLevel.toDouble();
      _selectedSideEffects = List.from(widget.existingShot!.sideEffects);
      _notes = widget.existingShot!.notes ?? '';
    } else {
      _selectedDate = DateTime.now();
      _selectedMedication = 'Ozempic®';
      _selectedDosage = '0.5mg';
    }
    
    _loadRecommendations();
  }

  Future<void> _loadRecommendations() async {
    final treatmentProvider = context.read<TreatmentProvider>();
    await treatmentProvider.loadSiteRecommendations();
    
    // If we have recommendations and no existing shot, suggest the first one
    if (widget.existingShot == null &&
        treatmentProvider.siteRecommendations != null &&
        treatmentProvider.siteRecommendations!.recommendedSites.isNotEmpty) {
      setState(() {
        _selectedLocation = treatmentProvider.siteRecommendations!.recommendedSites.first;
      });
    }
  }

  Future<void> _saveShot() async {
    if (_isSaving) return;

    setState(() {
      _isSaving = true;
    });

    final request = ShotLogRequest(
      date: _selectedDate,
      medication: _selectedMedication,
      dosage: _selectedDosage,
      injectionSite: _selectedLocation,
      painLevel: _painLevel.round(),
      sideEffects: _selectedSideEffects,
      notes: _notes.isNotEmpty ? _notes : null,
    );

    final treatmentProvider = context.read<TreatmentProvider>();
    bool success;
    
    if (widget.existingShot != null) {
      // Update existing shot
      success = await treatmentProvider.updateShot(widget.existingShot!.id, request);
    } else {
      // Log new shot
      success = await treatmentProvider.logShot(request);
    }

    setState(() {
      _isSaving = false;
    });

    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.existingShot != null ? 'Shot updated successfully!' : 'Shot logged successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context, true);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(treatmentProvider.errorMessage ?? 'Failed to save shot'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingShot != null ? 'Edit Shot' : 'Log Shot'),
        actions: [
          if (_isSaving)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _saveShot,
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.spacing16),
        children: [
          _buildDateSelector(),
          const SizedBox(height: AppConstants.spacing16),
          _buildMedicationSelector(),
          const SizedBox(height: AppConstants.spacing16),
          _buildDosageSelector(),
          const SizedBox(height: AppConstants.spacing16),
          _buildLocationSelector(),
          const SizedBox(height: AppConstants.spacing24),
          _buildPainLevelSlider(),
          const SizedBox(height: AppConstants.spacing24),
          _buildSideEffectsSection(),
          const SizedBox(height: AppConstants.spacing24),
          _buildNotesField(),
          const SizedBox(height: AppConstants.spacing32),
          _buildSaveButton(),
          const SizedBox(height: AppConstants.spacing32),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.calendar_today, color: AppColors.primary),
        title: const Text('Date & Time'),
        subtitle: Text(
          '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year} at ${_selectedDate.hour}:${_selectedDate.minute.toString().padLeft(2, '0')}',
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: _selectDateTime,
      ),
    );
  }

  Widget _buildMedicationSelector() {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.medical_services, color: AppColors.primary),
        title: const Text('Medication'),
        subtitle: Text(_selectedMedication),
        trailing: const Icon(Icons.chevron_right),
        onTap: _selectMedication,
      ),
    );
  }

  Widget _buildDosageSelector() {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.science_outlined, color: AppColors.primary),
        title: const Text('Dosage'),
        subtitle: Text(_selectedDosage),
        trailing: const Icon(Icons.chevron_right),
        onTap: _selectDosage,
      ),
    );
  }

  Widget _buildLocationSelector() {
    return Consumer<TreatmentProvider>(
      builder: (context, provider, child) {
        final hasRecommendations = provider.siteRecommendations != null &&
            provider.siteRecommendations!.recommendedSites.isNotEmpty;

        return Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.location_on_outlined, color: AppColors.primary),
                title: const Text('Injection Site'),
                subtitle: Text(_selectedLocation),
                trailing: const Icon(Icons.chevron_right),
                onTap: _selectLocation,
              ),
              if (hasRecommendations)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, size: 16, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Recommended: ${provider.siteRecommendations!.recommendedSites.join(", ")}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPainLevelSlider() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Pain Level',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${_painLevel.round()}/10',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacing8),
            Slider(
              value: _painLevel,
              min: 0,
              max: 10,
              divisions: 10,
              label: _painLevel.round().toString(),
              onChanged: (value) {
                setState(() {
                  _painLevel = value;
                });
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'No Pain',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  'Severe',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Side Effects',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: AppConstants.spacing12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _sideEffectOptions.map((effect) {
                final isSelected = _selectedSideEffects.contains(effect);
                final isNone = effect == 'None';
                
                return FilterChip(
                  label: Text(effect),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (isNone) {
                        // If None is selected, clear all others
                        _selectedSideEffects = ['None'];
                      } else {
                        // Remove None if selecting any other effect
                        _selectedSideEffects.remove('None');
                        
                        if (selected) {
                          _selectedSideEffects.add(effect);
                        } else {
                          _selectedSideEffects.remove(effect);
                        }
                        
                        // If no effects selected, default to None
                        if (_selectedSideEffects.isEmpty) {
                          _selectedSideEffects = ['None'];
                        }
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesField() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Notes (Optional)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: AppConstants.spacing8),
            TextField(
              maxLines: 4,
              maxLength: 500,
              decoration: const InputDecoration(
                hintText: 'Add any additional notes about this shot...',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _notes = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSaving ? null : _saveShot,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isSaving
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                'Save Shot Log',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Future<void> _selectDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDate),
      );

      if (time != null) {
        setState(() {
          _selectedDate = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _selectMedication() async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Select Medication'),
        children: _medications.map((medication) {
          return SimpleDialogOption(
            onPressed: () => Navigator.pop(context, medication),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                medication,
                style: TextStyle(
                  color: medication == _selectedMedication
                      ? AppColors.primary
                      : AppColors.textPrimary,
                  fontWeight: medication == _selectedMedication
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );

    if (result != null) {
      setState(() {
        _selectedMedication = result;
      });
    }
  }

  Future<void> _selectDosage() async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Select Dosage'),
        children: _dosages.map((dosage) {
          return SimpleDialogOption(
            onPressed: () => Navigator.pop(context, dosage),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                dosage,
                style: TextStyle(
                  color: dosage == _selectedDosage
                      ? AppColors.primary
                      : AppColors.textPrimary,
                  fontWeight: dosage == _selectedDosage
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );

    if (result != null) {
      setState(() {
        _selectedDosage = result;
      });
    }
  }

  Future<void> _selectLocation() async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Select Injection Site'),
        children: _injectionSites.map((site) {
          final provider = context.read<TreatmentProvider>();
          final isRecommended = provider.siteRecommendations?.recommendedSites.contains(site) ?? false;
          
          return SimpleDialogOption(
            onPressed: () => Navigator.pop(context, site),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  if (isRecommended)
                    const Icon(
                      Icons.check_circle,
                      color: AppColors.success,
                      size: 20,
                    ),
                  if (isRecommended) const SizedBox(width: 8),
                  Text(
                    site,
                    style: TextStyle(
                      color: site == _selectedLocation
                          ? AppColors.primary
                          : AppColors.textPrimary,
                      fontWeight: site == _selectedLocation
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );

    if (result != null) {
      setState(() {
        _selectedLocation = result;
      });
    }
  }
}
