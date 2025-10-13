import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../domain/models/side_effect.dart';
import '../providers/side_effect_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/utils/unit_converter.dart';

class SideEffectLoggingScreen extends StatefulWidget {
  const SideEffectLoggingScreen({super.key});

  @override
  State<SideEffectLoggingScreen> createState() => _SideEffectLoggingScreenState();
}

class _SideEffectLoggingScreenState extends State<SideEffectLoggingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  final _startWeightController = TextEditingController();
  final _goalWeightController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now();
  List<SideEffectDetail> _effects = [];
  double _overallSeverity = 0.0;
  bool _relatedToShot = false;

  // Available side effects
  final List<String> _availableEffects = [
    'Injection Anxiety',
    'Loose Skin',
    'Constipation',
    'Bloating',
    'Sulfur Burps',
    'Heartburn',
    'Food Noise',
    'Nausea',
    'Vomiting',
    'Diarrhea',
    'Fatigue',
    'Headache',
    'Dizziness',
    'Abdominal Pain',
    'Decreased Appetite',
    'Injection Site Reaction',
    'Hair Loss',
    'Muscle Loss',
    'Low Blood Sugar',
    'Mood Changes',
    'Sleep Disturbances',
    'Dry Mouth',
  ];

  // Selected effects with their severities
  Map<String, double> _selectedEffects = {};

  @override
  void initState() {
    super.initState();
    // Initialize with some default effects from the image
    _selectedEffects = {
      'Injection Anxiety': 0.0,
      'Loose Skin': 0.0,
      'Constipation': 0.0,
      'Bloating': 0.0,
      'Sulfur Burps': 0.0,
      'Heartburn': 0.0,
      'Food Noise': 0.0,
    };
    _updateOverallSeverity();

    // Load user weight data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadWeightData();
    });
  }

  void _loadWeightData() {
    final user = context.read<AuthProvider>().user;
    if (user != null) {
      final preferredUnit = user.preferredUnits.weight;
      
      // Convert from kg to preferred unit
      final startWeight = UnitConverter.convertWeight(user.weight, preferredUnit);
      final goalWeight = user.goals.targetWeight != null 
          ? UnitConverter.convertWeight(user.goals.targetWeight!, preferredUnit)
          : 0.0;
      
      setState(() {
        _startWeightController.text = startWeight.toStringAsFixed(1);
        _goalWeightController.text = goalWeight > 0 ? goalWeight.toStringAsFixed(1) : '';
      });
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    _startWeightController.dispose();
    _goalWeightController.dispose();
    super.dispose();
  }

  void _updateOverallSeverity() {
    final values = _selectedEffects.values.where((v) => v > 0).toList();
    if (values.isNotEmpty) {
      setState(() {
        _overallSeverity = values.reduce((a, b) => a + b) / values.length;
      });
    } else {
      setState(() {
        _overallSeverity = 0.0;
      });
    }
  }

  Future<void> _saveSideEffects() async {
    if (!_formKey.currentState!.validate()) return;

    // Filter out effects with 0 severity
    final activeEffects = _selectedEffects.entries
        .where((entry) => entry.value > 0)
        .map((entry) => SideEffectDetail(
              name: entry.key,
              severity: entry.value,
              description: '${entry.key} - Severity: ${entry.value.toInt()}/10',
              triggers: [], // Empty array instead of null
              remedies: [], // Empty array instead of null
            ))
        .toList();

    if (activeEffects.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one side effect with severity > 0'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final provider = Provider.of<SideEffectProvider>(context, listen: false);
    
    final success = await provider.logSideEffects(
      date: _selectedDate,
      effects: activeEffects,
      overallSeverity: _overallSeverity,
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      relatedToShot: _relatedToShot,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Side effects logged successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? 'Failed to log side effects'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Side Effects Log',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune, color: Colors.black),
            onPressed: _showCustomizeDialog,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // Date selector
            _buildDateSelector(),
            
            // Side effects list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacing16),
                itemCount: _selectedEffects.length,
                itemBuilder: (context, index) {
                  final effectName = _selectedEffects.keys.elementAt(index);
                  final severity = _selectedEffects[effectName]!;
                  return _buildSideEffectItem(effectName, severity);
                },
              ),
            ),
            
            // Log button
            Container(
              padding: const EdgeInsets.all(AppConstants.spacing16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveSideEffects,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: AppConstants.spacing16),
                    shape: RoundedRectangleBorder(),
                  ),
                  child: const Text(
                    'Log Side Effect',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
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

  Widget _buildDateSelector() {
    final dateFormatter = DateFormat('EEE, d MMM, h:mm a');
    
    return Container(
      margin: const EdgeInsets.all(AppConstants.spacing16),
      padding: const EdgeInsets.all(AppConstants.spacing16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(
            Icons.calendar_today,
            color: AppColors.primary,
            size: 20,
          ),
          const SizedBox(width: AppConstants.spacing12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Date',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppConstants.spacing4),
                Text(
                  dateFormatter.format(_selectedDate),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: _selectDate,
            child: const Text(
              'Change',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSideEffectItem(String effectName, double severity) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.spacing16),
      padding: const EdgeInsets.all(AppConstants.spacing16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                effectName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '${severity.toInt()}/10',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _getSeverityColor(severity),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacing12),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: AppColors.primary.withOpacity(0.2),
              thumbColor: AppColors.primary,
              overlayColor: AppColors.primary.withOpacity(0.1),
              valueIndicatorColor: AppColors.primary,
              valueIndicatorTextStyle: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            child: Slider(
              value: severity,
              min: 0,
              max: 10,
              divisions: 10,
              label: severity.toInt().toString(),
              onChanged: (value) {
                setState(() {
                  _selectedEffects[effectName] = value;
                  _updateOverallSeverity();
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Color _getSeverityColor(double severity) {
    if (severity == 0) return Colors.grey;
    if (severity <= 3) return Colors.green;
    if (severity <= 6) return Colors.orange;
    return Colors.red;
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now(),
    );

    if (date != null) {
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

  void _showCustomizeDialog() {
    // Create a local copy to track changes in the dialog
    Map<String, double> tempSelectedEffects = Map.from(_selectedEffects);
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text(
              'Customize Side Effects',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            content: SizedBox(
              width: double.maxFinite,
              height: 400,
              child: Column(
                children: [
                  const Text(
                    'Select side effects to track:',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacing8),
                  Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _availableEffects.length,
                      itemBuilder: (context, index) {
                        final effect = _availableEffects[index];
                        final isSelected = tempSelectedEffects.containsKey(effect);
                        return CheckboxListTile(
                          title: Text(effect),
                          value: isSelected,
                          activeColor: AppColors.primary,
                          onChanged: (checked) {
                            setDialogState(() {
                              if (checked == true) {
                                tempSelectedEffects[effect] = 0.0;
                              } else {
                                tempSelectedEffects.remove(effect);
                              }
                            });
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _selectedEffects = tempSelectedEffects;
                    _updateOverallSeverity();
                  });
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }
}
