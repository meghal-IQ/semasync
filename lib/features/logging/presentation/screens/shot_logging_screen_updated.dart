import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/providers/treatment_provider.dart';
import '../../../../core/providers/auth_provider.dart';
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
      _selectedMedication = _medications.first; // Default, will be updated in didChangeDependencies
      _selectedDosage = '0.5mg';
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Get medication from user's registration data if not already set from existing shot
    if (widget.existingShot == null) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userMedication = authProvider.user?.glp1Journey.medication;
      if (userMedication != null && _medications.contains(userMedication)) {
        _selectedMedication = userMedication;
      }
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
      body: SafeArea(
        child: Column(
          children: [
            // Custom Header
            _buildHeader(),
            
            // Scrollable Content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                children: [
                  _buildDateSelector(),
                  const SizedBox(height: 16),
                  _buildMedicationSelector(),
                  const SizedBox(height: 16),
                  _buildDosageSelector(),
                  const SizedBox(height: 16),
                  _buildLocationSelector(),
                  const SizedBox(height: 24),
                  _buildPainLevelSlider(),
                  const SizedBox(height: 24),
                  _buildSideEffectsSection(),
                ],
              ),
            ),
            
            // Log Shot Button
            _buildLogShotButton(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      child: Row(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => Navigator.pop(context),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Icon(
                  Icons.arrow_back_ios_new,
                  size: 20,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                'Log Shot',
                style: AppTextStyles.subtitle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.2,
                ),
              ),
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    final formattedDate = '${_formatDay(_selectedDate.day)} ${_formatMonth(_selectedDate.month)}, ${_selectedDate.year} at ${_selectedDate.hour.toString().padLeft(2, '0')}:${_selectedDate.minute.toString().padLeft(2, '0')}';
    
    return _buildInputCard(
      icon: Icons.calendar_today_outlined,
      label: 'Date & Time',
      value: formattedDate,
      onTap: _selectDateTime,
    );
  }
  
  String _formatDay(int day) {
    return day.toString();
  }
  
  String _formatMonth(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }
  
  Widget _buildInputCard({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        decoration: BoxDecoration(
          color: AppColors.lightGrey,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 22,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                      letterSpacing: -0.1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicationSelector() {
    return _buildInputCard(
      icon: Icons.vaccines,
      label: 'Medication',
      value: _selectedMedication,
      onTap: _selectMedication,
    );
  }

  Widget _buildDosageSelector() {
    return _buildInputCard(
      icon: Icons.add_circle_outline,
      label: 'Dosage',
      value: _selectedDosage,
      onTap: _selectDosage,
    );
  }

  Widget _buildLocationSelector() {
    return _buildInputCard(
      icon: Icons.person_outline,
      label: 'Injection Site',
      value: _selectedLocation,
      onTap: _selectLocation,
    );
  }

  Widget _buildPainLevelSlider() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.lightGrey,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.brightness_low_outlined,
                size: 22,
              ),
              const SizedBox(width: 12),
              Text(
                'Pain Level',
                style: AppTextStyles.subtitle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: AppColors.divider,
              thumbColor: AppColors.primary,
              overlayColor: AppColors.primary.withOpacity(0.18),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
              trackHeight: 4,
            ),
            child: Slider(
              value: _painLevel,
              min: 0,
              max: 10,
              divisions: 10,
              onChanged: (value) {
                setState(() {
                  _painLevel = value;
                });
              },
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'No Pain',
                style: AppTextStyles.subtitle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                'Severe',
                style: AppTextStyles.subtitle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSideEffectsSection() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.lightGrey,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 2, bottom: 12),
            child: Text(
              'Side Effects',
              style: AppTextStyles.subtitle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _sideEffectOptions.map((effect) {
              final isSelected = _selectedSideEffects.contains(effect);
              final isNone = effect == 'None';
              
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isNone) {
                      // If None is selected, clear all others
                      _selectedSideEffects = ['None'];
                    } else {
                      // Remove None if selecting any other effect
                      _selectedSideEffects.remove('None');
                      
                      if (isSelected) {
                        _selectedSideEffects.remove(effect);
                      } else {
                        _selectedSideEffects.add(effect);
                      }
                      
                      // If no effects selected, default to None
                      if (_selectedSideEffects.isEmpty) {
                        _selectedSideEffects = ['None'];
                      }
                    }
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary
                        : Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.divider,
                      width: 1.2,
                    ),
                  ),
                  child: Text(
                    effect,
                    style: AppTextStyles.subtitle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? Colors.white
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }


  Widget _buildLogShotButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _isSaving ? null : _saveShot,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            disabledBackgroundColor: AppColors.primary.withOpacity(0.35),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 18),
            elevation: 0,
            shape: const StadiumBorder(),
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
              :  Text(
                  'Log Shot',
                  style: AppTextStyles.subtitle(
                    fontSize: 17,
                    color: AppColors.background,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.1,
                  ),
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
                style: AppTextStyles.subtitle(
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
                style: AppTextStyles.subtitle(
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
    
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
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
  String? _selectedSiteId;
  _InjectionRegion? _selectedRegion;

  // Define injection sites with their positions as fractional coordinates (0.0 - 1.0)
  // Coordinates are tuned to align with the `body.png` asset injection indicators.
  final List<_InjectionSite> _injectionSites = const [
    _InjectionSite(
      id: 'left_arm_outer',
      region: _InjectionRegion.leftArm,
      x: 0.18,
      y: 0.30,
    ),
    _InjectionSite(
      id: 'right_arm_outer',
      region: _InjectionRegion.rightArm,
      x: 0.82,
      y: 0.30,
    ),
    _InjectionSite(
      id: 'left_abdomen_upper',
      region: _InjectionRegion.leftAbdomen,
      x: 0.41,
      y: 0.44,
    ),
    _InjectionSite(
      id: 'right_abdomen_upper',
      region: _InjectionRegion.rightAbdomen,
      x: 0.59,
      y: 0.44,
    ),
    _InjectionSite(
      id: 'left_abdomen_mid',
      region: _InjectionRegion.leftAbdomen,
      x: 0.41,
      y: 0.52,
    ),
    _InjectionSite(
      id: 'right_abdomen_mid',
      region: _InjectionRegion.rightAbdomen,
      x: 0.59,
      y: 0.52,
    ),
    _InjectionSite(
      id: 'left_abdomen_lower',
      region: _InjectionRegion.leftAbdomen,
      x: 0.41,
      y: 0.60,
    ),
    _InjectionSite(
      id: 'right_abdomen_lower',
      region: _InjectionRegion.rightAbdomen,
      x: 0.59,
      y: 0.60,
    ),
    _InjectionSite(
      id: 'left_thigh_upper',
      region: _InjectionRegion.leftThigh,
      x: 0.38,
      y: 0.74,
    ),
    _InjectionSite(
      id: 'left_thigh_lower',
      region: _InjectionRegion.leftThigh,
      x: 0.34,
      y: 0.82,
    ),
    _InjectionSite(
      id: 'right_thigh_upper',
      region: _InjectionRegion.rightThigh,
      x: 0.62,
      y: 0.74,
    ),
    _InjectionSite(
      id: 'right_thigh_lower',
      region: _InjectionRegion.rightThigh,
      x: 0.66,
      y: 0.82,
    ),
  ];
  
  @override
  void initState() {
    super.initState();
    final initialRegion = _regionFromStandard(widget.initialSelection);
    if (initialRegion != null) {
      _selectedRegion = initialRegion;
      _selectedSiteId = _preferredSiteIdForRegion(initialRegion);
    }
  }

  bool get _hasSelection => _selectedRegion != null && _selectedSiteId != null;

  String _regionLabel(_InjectionRegion region) {
    switch (region) {
      case _InjectionRegion.leftArm:
        return 'Left Arm';
      case _InjectionRegion.rightArm:
        return 'Right Arm';
      case _InjectionRegion.leftAbdomen:
        return 'Left Abdomen';
      case _InjectionRegion.rightAbdomen:
        return 'Right Abdomen';
      case _InjectionRegion.leftThigh:
        return 'Left Thigh';
      case _InjectionRegion.rightThigh:
        return 'Right Thigh';
    }
  }

  String _standardNameForRegion(_InjectionRegion region) => _regionLabel(region);

  _InjectionRegion? _regionFromStandard(String? name) {
    if (name == null || name.isEmpty) {
      return null;
    }
    final normalized = name.trim();
    switch (normalized) {
      case 'Left Arm':
        return _InjectionRegion.leftArm;
      case 'Right Arm':
        return _InjectionRegion.rightArm;
      case 'Left Abdomen':
      case 'Upper Left Abdomen':
      case 'Lower Left Abdomen':
        return _InjectionRegion.leftAbdomen;
      case 'Right Abdomen':
      case 'Upper Right Abdomen':
      case 'Lower Right Abdomen':
        return _InjectionRegion.rightAbdomen;
      case 'Left Thigh':
      case 'Left Groin':
        return _InjectionRegion.leftThigh;
      case 'Right Thigh':
      case 'Right Groin':
        return _InjectionRegion.rightThigh;
    }
    return null;
  }

  String? _preferredSiteIdForRegion(_InjectionRegion region) {
    for (final site in _injectionSites) {
      if (site.region == region) {
        return site.id;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      child: Column(
        children: [
          // Title - "Log Shot" on left, X button on right
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Log Shot',
                  style: AppTextStyles.subtitle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.textPrimary),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          
          // Body with human figure and injection sites
          Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Center(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final double containerWidth = constraints.maxWidth ;
                      final double containerHeight = constraints.maxHeight;
                    
                      // Body diagram approximate aspect ratio (width/height)
                      const double bodyAspectRatio = 274 / 344;
                    
                      // Calculate figure dimensions
                      double figureWidth, figureHeight, figureOffsetX, figureOffsetY;
                    
                      if (containerWidth / containerHeight > bodyAspectRatio) {
                        figureHeight = containerHeight;
                        figureWidth = figureHeight * bodyAspectRatio;
                        figureOffsetX = (containerWidth - figureWidth) / 2;
                        figureOffsetY = 0;
                      } else {
                        figureWidth = containerWidth;
                        figureHeight = figureWidth / bodyAspectRatio;
                        figureOffsetX = 0;
                        figureOffsetY = (containerHeight - figureHeight) / 2;
                      }

                      return SizedBox(
                        width: containerWidth,
                        height: containerHeight,
                        child: Stack(
                          children: [
                            // Human figure outline
                            Center(
                              child: SizedBox(
                                width: figureWidth,
                                height: figureHeight,
                                child: Image.asset(
                                  'assets/images/body.png',
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            // Injection sites - positioned relative to figure bounds
                            ..._injectionSites.map((site) {
                              final isSelected = site.id == _selectedSiteId;
                              return Positioned(
                                left: figureOffsetX + (figureWidth * site.x) - 16,
                                top: figureOffsetY + (figureHeight * site.y) - 16,
                                child: _InjectionPoint(
                                  selected: isSelected,
                                  onTap: () {
                                    setState(() {
                                      _selectedSiteId = site.id;
                                      _selectedRegion = site.region;
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
          ),
          
          // Selected site label - always show if a site is selected
          if (_hasSelection)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                _regionLabel(_selectedRegion!),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          
          // Save button
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _hasSelection
                    ? () {
                        widget.onSiteSelected(_standardNameForRegion(_selectedRegion!));
                        Navigator.pop(context);
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _hasSelection ? AppColors.primary : Colors.grey.shade300,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: const StadiumBorder(),
                  elevation: 0,
                ),
                child: Text(
                  'Save',
                  style: AppTextStyles.subtitle(
                    fontSize: 16,
                    color: AppColors.background,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          ],
        ),
      );
  }
}

enum _InjectionRegion {
  leftArm,
  rightArm,
  leftAbdomen,
  rightAbdomen,
  leftThigh,
  rightThigh,
}

class _InjectionSite {
  final String id;
  final _InjectionRegion region;
  final double x; // Position as percentage (0.0 to 1.0)
  final double y; // Position as percentage (0.0 to 1.0)

  const _InjectionSite({
    required this.id,
    required this.region,
    required this.x,
    required this.y,
  });
}

// Injection point widget - light gray with dotted outline when unselected,
// solid purple when selected
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
      child: SizedBox(
        width: 32,
        height: 32,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(
              size: const Size(28, 28),
              painter: _DashedCirclePainter(
                color: selected
                    ? AppColors.primary.withOpacity(0.65)
                    : const Color(0xFFCBD2E1),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              width: selected ? 18 : 10,
              height: selected ? 18 : 10,
              decoration: BoxDecoration(
                color: selected ? AppColors.primary : const Color(0xFFE8ECF5),
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? Colors.white : const Color(0xFFE8ECF5),
                  width: selected ? 3 : 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom painter for dashed circle border (for unselected sites)
class _DashedCirclePainter extends CustomPainter {
  final Color color;

  const _DashedCirclePainter({this.color = const Color(0xFF9CA3AF)});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 1;

    // Draw dashed circle
    const dashWidth = 3.0;
    const dashCount = 20;
    final angleStep = (2 * 3.14159) / dashCount;

    for (int i = 0; i < dashCount; i++) {
      if (i % 2 == 0) {
        final startAngle = i * angleStep;
        final dashAngle = dashWidth / radius;
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          startAngle,
          dashAngle,
          false,
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedCirclePainter oldDelegate) => oldDelegate.color != color;
}

