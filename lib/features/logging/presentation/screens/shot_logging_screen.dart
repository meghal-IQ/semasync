import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/api/services/treatment_service.dart';
import '../../../../core/api/models/shot_log_model.dart';

class ShotLoggingScreen extends StatefulWidget {
  const ShotLoggingScreen({super.key});

  @override
  State<ShotLoggingScreen> createState() => _ShotLoggingScreenState();
}

class _ShotLoggingScreenState extends State<ShotLoggingScreen> {
  final TreatmentService _treatmentService = TreatmentService();
  DateTime _selectedDate = DateTime.now();
  String _selectedMedication = 'Ozempic®';
  String _selectedDosage = '0.5mg';
  String _selectedLocation = 'Left Thigh';
  double _painLevel = 2.0;
  List<String> _selectedSideEffects = ['None'];
  String _notes = '';
  bool _isSaving = false;

  final List<String> _medications = [
    'Ozempic®',
    'Wegovy®',
    'Mounjaro®',
    'Zepbound®',
    'Trulicity®',
  ];

  final List<String> _dosages = [
    '0.25mg',
    '0.5mg',
    '0.7mg',
    '1.0mg',
    '1.5mg',
    '2.0mg',
  ];

  final List<String> _injectionSites = [
    'Left Thigh',
    'Right Thigh',
    'Left Arm',
    'Right Arm',
    'Left Abdomen',
    'Right Abdomen',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Shot'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save_outlined),
            onPressed: _saveShot,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.spacing16),
        children: [
          _buildDateSelector(),
          const SizedBox(height: AppConstants.spacing24),
          _buildMedicationSelector(),
          const SizedBox(height: AppConstants.spacing16),
          _buildDosageSelector(),
          const SizedBox(height: AppConstants.spacing16),
          _buildLocationSelector(),
          const SizedBox(height: AppConstants.spacing24),
          _buildPainLevelSlider(),
          const SizedBox(height: AppConstants.spacing24),
          _buildNotesField(),
          const SizedBox(height: AppConstants.spacing32),
          _buildSaveButton(),
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
        leading: const Icon(Icons.medication, color: AppColors.primary),
        title: const Text('Dosage'),
        subtitle: Text(_selectedDosage),
        trailing: const Icon(Icons.chevron_right),
        onTap: _selectDosage,
      ),
    );
  }

  Widget _buildLocationSelector() {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.location_on, color: AppColors.primary),
        title: const Text('Injection Site'),
        subtitle: Text(_selectedLocation),
        trailing: const Icon(Icons.chevron_right),
        onTap: _selectLocation,
      ),
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
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${_painLevel.toInt()}/10',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacing16),
            Slider(
              value: _painLevel,
              min: 0,
              max: 10,
              divisions: 10,
              activeColor: AppColors.primary,
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
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                Text(
                  'Severe Pain',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
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
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppConstants.spacing12),
            TextField(
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Add any notes about your injection...',
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
        onPressed: _saveShot,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(vertical: AppConstants.spacing16),
        ),
        child: const Text(
          'Log Shot',
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

  Future<void> _selectMedication() async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Medication'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _medications.map((med) => ListTile(
            title: Text(med),
            onTap: () => Navigator.pop(context, med),
          )).toList(),
        ),
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
      builder: (context) => AlertDialog(
        title: const Text('Select Dosage'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _dosages.map((dose) => ListTile(
            title: Text(dose),
            onTap: () => Navigator.pop(context, dose),
          )).toList(),
        ),
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
      builder: (context) => AlertDialog(
        title: const Text('Select Injection Site'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _injectionSites.map((site) => ListTile(
            title: Text(site),
            onTap: () => Navigator.pop(context, site),
          )).toList(),
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _selectedLocation = result;
      });
    }
  }

  Future<void> _saveShot() async {
    setState(() {
      _isSaving = true;
    });

    try {
      final request = ShotLogRequest(
        date: _selectedDate,
        medication: _selectedMedication,
        dosage: _selectedDosage,
        injectionSite: _selectedLocation,
        painLevel: _painLevel.toInt(),
        sideEffects: _selectedSideEffects,
        notes: _notes.isNotEmpty ? _notes : null,
      );

      final response = await _treatmentService.logShot(request);

      if (mounted) {
        if (response.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Shot logged successfully!'),
              backgroundColor: AppColors.success,
            ),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to log shot: ${response.message}'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }
}

