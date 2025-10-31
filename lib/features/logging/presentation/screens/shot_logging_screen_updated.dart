import 'dart:math';
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
    'Upper Left Abdomen',
    'Upper Right Abdomen',
    'Lower Left Abdomen',
    'Lower Right Abdomen',
    'Left Groin',
    'Right Groin',
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        titleTextStyle: TextStyle(fontWeight: FontWeight.w500, color: Colors.black, fontSize: 20),
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
      color: AppColors.lightGrey,
      elevation: 0,
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
      color: AppColors.lightGrey,
      elevation: 0,
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
      color: AppColors.lightGrey,
      elevation: 0,
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
          color: AppColors.lightGrey,
          elevation: 0,
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
      color: AppColors.lightGrey,
      elevation: 0,
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
      color: AppColors.lightGrey,
      elevation: 0,
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
                  backgroundColor: AppColors.background,
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
      color: AppColors.lightGrey,
      elevation: 0,
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
      firstDate: DateTime(1970), // Allow historical data entry from 1970
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
    String? result = _selectedLocation;
    
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => _InjectionSiteSelector(
        initialSelection: _selectedLocation,
        onSiteSelected: (site) {
          result = site;
        },
      ),
    );

    if (result != null && result != _selectedLocation) {
      setState(() {
        _selectedLocation = result!;
      });
    }
  }
}

// Widget for injection site selection with body outline
class _InjectionSiteSelector extends StatefulWidget {
  final String initialSelection;
  final Function(String) onSiteSelected;

  const _InjectionSiteSelector({
    required this.initialSelection,
    required this.onSiteSelected,
  });

  @override
  State<_InjectionSiteSelector> createState() => _InjectionSiteSelectorState();
}

class _InjectionSiteSelectorState extends State<_InjectionSiteSelector> {
  late String _selectedSite;
  bool _isSiteSelected = false;

  // Define injection sites with their positions as fractional coordinates (0.0 to 1.0)
  // Positions carefully tuned to match the actual PNG image asset locations
  // Based on body diagram: head at top, torso in middle, legs at bottom
  final List<_InjectionSite> _injectionSites = const [
    _InjectionSite(name: 'Left Arm', x: 0.20, y: 0.28),           // Upper left shoulder/arm
    _InjectionSite(name: 'Right Arm', x: 0.80, y: 0.28),          // Upper right shoulder/arm
    _InjectionSite(name: 'Upper Left Abdomen', x: 0.38, y: 0.40),  // Upper chest/abdomen left
    _InjectionSite(name: 'Upper Right Abdomen', x: 0.62, y: 0.40), // Upper chest/abdomen right
    _InjectionSite(name: 'Left Groin', x: 0.32, y: 0.62),         // Left groin/upper thigh area (where selection is)
    _InjectionSite(name: 'Right Groin', x: 0.68, y: 0.62),       // Right groin/upper thigh area
    _InjectionSite(name: 'Lower Left Abdomen', x: 0.40, y: 0.75), // Lower abdomen/thigh left
    _InjectionSite(name: 'Lower Right Abdomen', x: 0.60, y: 0.75), // Lower abdomen/thigh right
  ];
  
  @override
  void initState() {
    super.initState();
    // Map initial selection to visual name if needed
    _selectedSite = _mapStandardToVisual(widget.initialSelection);
    // If we have a valid initial selection, mark as selected
    _isSiteSelected = _injectionSites.any((site) => site.name == _selectedSite);
  }
  
  // Map standard API names back to visual names (for initial selection)
  String _mapStandardToVisual(String standardName) {
    // Find matching visual site - prefer upper positions for initial selection
    if (standardName == 'Left Abdomen') {
      return 'Upper Left Abdomen';
    }
    if (standardName == 'Right Abdomen') {
      return 'Upper Right Abdomen';
    }
    if (standardName == 'Left Thigh') {
      return 'Left Groin';
    }
    if (standardName == 'Right Thigh') {
      return 'Right Groin';
    }
    // For arms, return as-is
    return standardName;
  }
  
  // Map visual site names to standard API names
  String _mapSiteToStandard(String visualName) {
    if (visualName.contains('Upper Left Abdomen') || visualName.contains('Lower Left Abdomen')) {
      return 'Left Abdomen';
    }
    if (visualName.contains('Upper Right Abdomen') || visualName.contains('Lower Right Abdomen')) {
      return 'Right Abdomen';
    }
    if (visualName.contains('Left Groin')) {
      return 'Left Thigh';
    }
    if (visualName.contains('Right Groin')) {
      return 'Right Thigh';
    }
    return visualName;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.8,
        width: MediaQuery.of(context).size.width * 0.9,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          children: [
            // Title
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Log Shot',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            
            // Body with PNG image and precisely positioned points
            Expanded(
              child: Center(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // Use a fixed aspect ratio approach for consistent positioning
                    // The body diagram is typically taller than wide
                    final double containerWidth = constraints.maxWidth * 0.85;
                    final double containerHeight = constraints.maxHeight * 0.85;
                    
                    // Body diagram approximate aspect ratio (width/height)
                    const double bodyAspectRatio = 0.65;
                    
                    // Calculate how the image will actually render with BoxFit.contain
                    double imageWidth, imageHeight, imageOffsetX, imageOffsetY;
                    
                    if (containerWidth / containerHeight > bodyAspectRatio) {
                      // Container is wider - height is the limiting factor
                      imageHeight = containerHeight;
                      imageWidth = imageHeight * bodyAspectRatio;
                      imageOffsetX = (containerWidth - imageWidth) / 2;
                      imageOffsetY = 0;
                    } else {
                      // Container is taller - width is the limiting factor
                      imageWidth = containerWidth;
                      imageHeight = imageWidth / bodyAspectRatio;
                      imageOffsetX = 0;
                      imageOffsetY = (containerHeight - imageHeight) / 2;
                    }
                    
                    return SizedBox(
                      width: containerWidth,
                      height: containerHeight,
                      child: Stack(
                        children: [
                          // Body outline PNG image
                          Center(
                            child: SizedBox(
                              width: imageWidth,
                              height: imageHeight,
                              child: Image.asset(
                                'assets/images/injection_body.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          // Points overlay - positioned relative to actual image bounds
                          ..._injectionSites.map((site) {
                            return Positioned(
                              left: imageOffsetX + (imageWidth * site.x) - 14,
                              top: imageOffsetY + (imageHeight * site.y) - 14,
                              child: _InjectionPoint(
                                selected: _selectedSite == site.name,
                                onTap: () {
                                  setState(() {
                                    _selectedSite = site.name;
                                    _isSiteSelected = true;
                                  });
                                },
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            
            // Selected site label
            if (_isSiteSelected)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  _selectedSite,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            
            // Save button
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSiteSelected ? () {
                    // Map visual name to standard name before returning
                    widget.onSiteSelected(_mapSiteToStandard(_selectedSite));
                    Navigator.pop(context);
                  } : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isSiteSelected ? AppColors.primary : Colors.grey,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Save',
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
}

class _InjectionSite {
  final String name;
  final double x; // Position as percentage (0.0 to 1.0)
  final double y; // Position as percentage (0.0 to 1.0)

  const _InjectionSite({
    required this.name,
    required this.x,
    required this.y,
  });
}

// Simple circular point widget to match the design (filled purple when selected,
// outlined circle when not selected).
class _InjectionPoint extends StatelessWidget {
  final bool selected;
  final VoidCallback onTap;

  const _InjectionPoint({
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.transparent,
          shape: BoxShape.circle,
          border: Border.all(
            color: selected ? AppColors.primary : Colors.grey[400]!,
            width: selected ? 0 : 2,
            style: BorderStyle.solid,
          ),
        ),
      ),
    );
  }
}

