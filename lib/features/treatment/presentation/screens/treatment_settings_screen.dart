import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';

class TreatmentSettingsScreen extends StatefulWidget {
  const TreatmentSettingsScreen({super.key});

  @override
  State<TreatmentSettingsScreen> createState() => _TreatmentSettingsScreenState();
}

class _TreatmentSettingsScreenState extends State<TreatmentSettingsScreen> {
  // Mock data - in real app this would come from a provider or API
  String _medication = 'Mounjaro®';
  String _schedule = 'Wed';
  String _dosage = '0.25mg';
  String _location = 'Stomach - Upper Left';
  String _time = '8:00 PM';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Treatment',
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
      ),
      body: ListView(
        children: [
          _buildSettingsItem(
            icon: Icons.medication,
            label: 'Medication',
            value: _medication,
            onTap: () => _showMedicationDialog(),
          ),
          _buildDivider(),
          _buildSettingsItem(
            icon: Icons.calendar_today,
            label: 'Schedule',
            value: _schedule,
            onTap: () => _showScheduleDialog(),
          ),
          _buildDivider(),
          _buildSettingsItem(
            icon: Icons.medical_services,
            label: 'Dosage',
            value: _dosage,
            onTap: () => _showDosageDialog(),
          ),
          _buildDivider(),
          _buildSettingsItem(
            icon: Icons.location_on,
            label: 'Location',
            value: _location,
            onTap: () => _showLocationDialog(),
          ),
          _buildDivider(),
          _buildSettingsItem(
            icon: Icons.access_time,
            label: 'Time',
            value: _time,
            onTap: () => _showTimeDialog(),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacing16,
          vertical: AppConstants.spacing20,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.surface,
              ),
              child: Icon(
                icon,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: AppConstants.spacing16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacing4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.spacing16),
      height: 1,
      color: AppColors.border,
    );
  }

  void _showMedicationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Medication'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildMedicationOption('Mounjaro®', 'Mounjaro®'),
            _buildMedicationOption('Ozempic®', 'Ozempic®'),
            _buildMedicationOption('Wegovy®', 'Wegovy®'),
            _buildMedicationOption('Trulicity®', 'Trulicity®'),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicationOption(String title, String value) {
    return ListTile(
      title: Text(title),
      onTap: () {
        setState(() {
          _medication = value;
        });
        Navigator.pop(context);
      },
      trailing: _medication == value ? const Icon(Icons.check, color: AppColors.primary) : null,
    );
  }

  void _showScheduleDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Schedule'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildScheduleOption('Daily', 'Daily'),
            _buildScheduleOption('Weekly - Monday', 'Mon'),
            _buildScheduleOption('Weekly - Tuesday', 'Tue'),
            _buildScheduleOption('Weekly - Wednesday', 'Wed'),
            _buildScheduleOption('Weekly - Thursday', 'Thu'),
            _buildScheduleOption('Weekly - Friday', 'Fri'),
            _buildScheduleOption('Weekly - Saturday', 'Sat'),
            _buildScheduleOption('Weekly - Sunday', 'Sun'),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleOption(String title, String value) {
    return ListTile(
      title: Text(title),
      onTap: () {
        setState(() {
          _schedule = value;
        });
        Navigator.pop(context);
      },
      trailing: _schedule == value ? const Icon(Icons.check, color: AppColors.primary) : null,
    );
  }

  void _showDosageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Dosage'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDosageOption('0.25mg'),
            _buildDosageOption('0.5mg'),
            _buildDosageOption('1.0mg'),
            _buildDosageOption('1.5mg'),
            _buildDosageOption('2.0mg'),
            _buildDosageOption('2.5mg'),
          ],
        ),
      ),
    );
  }

  Widget _buildDosageOption(String dosage) {
    return ListTile(
      title: Text(dosage),
      onTap: () {
        setState(() {
          _dosage = dosage;
        });
        Navigator.pop(context);
      },
      trailing: _dosage == dosage ? const Icon(Icons.check, color: AppColors.primary) : null,
    );
  }

  void _showLocationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Injection Site'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLocationOption('Stomach - Upper Left', 'Stomach - Upper Left'),
            _buildLocationOption('Stomach - Upper Right', 'Stomach - Upper Right'),
            _buildLocationOption('Stomach - Lower Left', 'Stomach - Lower Left'),
            _buildLocationOption('Stomach - Lower Right', 'Stomach - Lower Right'),
            _buildLocationOption('Thigh - Left', 'Thigh - Left'),
            _buildLocationOption('Thigh - Right', 'Thigh - Right'),
            _buildLocationOption('Arm - Left', 'Arm - Left'),
            _buildLocationOption('Arm - Right', 'Arm - Right'),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationOption(String title, String value) {
    return ListTile(
      title: Text(title),
      onTap: () {
        setState(() {
          _location = value;
        });
        Navigator.pop(context);
      },
      trailing: _location == value ? const Icon(Icons.check, color: AppColors.primary) : null,
    );
  }

  void _showTimeDialog() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time != null) {
      setState(() {
        _time = time.format(context);
      });
    }
  }
}

