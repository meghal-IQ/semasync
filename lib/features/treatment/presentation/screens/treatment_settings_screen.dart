import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';

class TreatmentSettingsScreen extends StatefulWidget {
  const TreatmentSettingsScreen({super.key});

  @override
  State<TreatmentSettingsScreen> createState() => _TreatmentSettingsScreenState();
}

class _TreatmentSettingsScreenState extends State<TreatmentSettingsScreen> {
  // Mock data - in real app this would come from a provider or API
  String _medication = 'Ozempic';
  String _schedule = 'Wed';
  String _dosage = '0.25mg';
  String _location = 'Left Abdomen';
  String _time = '8:00 PM';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Treatment',
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
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.spacing16),
        children: [
          _buildSettingsItem(
            imagePath: 'assets/images/injection.png',
            label: 'Medication',
            value: _medication,
            onTap: () => _showMedicationDialog(),
          ),
          const SizedBox(height: AppConstants.spacing12),
          _buildSettingsItem(
            imagePath: 'assets/images/calender.png',
            label: 'Schedule',
            value: _schedule,
            onTap: () => _showScheduleDialog(),
          ),
          const SizedBox(height: AppConstants.spacing12),
          _buildSettingsItem(
            imagePath: 'assets/images/dosage.png',
            label: 'Dosage',
            value: _dosage,
            onTap: () => _showDosageDialog(),
          ),
          const SizedBox(height: AppConstants.spacing12),
          _buildSettingsItem(
            imagePath: 'assets/images/injection_site.png',
            label: 'Injection site',
            value: _location,
            onTap: () => _showLocationDialog(),
          ),
          const SizedBox(height: AppConstants.spacing12),
          _buildSettingsItem(
            imagePath: 'assets/images/time.png',
            label: 'Time',
            value: _time,
            onTap: () => _showTimeDialog(),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem({
    required String imagePath,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.lightGrey,
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        ),
        padding: const EdgeInsets.all(AppConstants.spacing16),
        child: Row(
          children: [
            Image.asset(
              imagePath,
              width: 24,
              height: 24,
              color: AppColors.textPrimary,
            ),
            const SizedBox(width: AppConstants.spacing16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTextStyles.text(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacing4),
                  Text(
                    value,
                    style: AppTextStyles.title(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
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

  void _showMedicationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Select Medication',
          style: AppTextStyles.title(),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildMedicationOption('Ozempic', 'Ozempic'),
            _buildMedicationOption('Mounjaro®', 'Mounjaro®'),
            _buildMedicationOption('Wegovy®', 'Wegovy®'),
            _buildMedicationOption('Trulicity®', 'Trulicity®'),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicationOption(String title, String value) {
    return ListTile(
      title: Text(title, style: AppTextStyles.text()),
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
        title: Text(
          'Select Schedule',
          style: AppTextStyles.title(),
        ),
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
      title: Text(title, style: AppTextStyles.text()),
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
        title: Text(
          'Select Dosage',
          style: AppTextStyles.title(),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDosageOption('0.25mg'),
            _buildDosageOption('0.5mg'),
            _buildDosageOption('0.7mg'),
            _buildDosageOption('1.0mg'),
            _buildDosageOption('1.5mg'),
            _buildDosageOption('1.7mg'),
            _buildDosageOption('2.0mg'),
            _buildDosageOption('2.4mg'),
          ],
        ),
      ),
    );
  }

  Widget _buildDosageOption(String dosage) {
    return ListTile(
      title: Text(dosage, style: AppTextStyles.text()),
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
        title: Text(
          'Select Injection Site',
          style: AppTextStyles.title(),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLocationOption('Left Abdomen', 'Left Abdomen'),
            _buildLocationOption('Right Abdomen', 'Right Abdomen'),
            _buildLocationOption('Upper Left Abdomen', 'Upper Left Abdomen'),
            _buildLocationOption('Upper Right Abdomen', 'Upper Right Abdomen'),
            _buildLocationOption('Lower Left Abdomen', 'Lower Left Abdomen'),
            _buildLocationOption('Lower Right Abdomen', 'Lower Right Abdomen'),
            _buildLocationOption('Left Thigh', 'Left Thigh'),
            _buildLocationOption('Right Thigh', 'Right Thigh'),
            _buildLocationOption('Left Arm', 'Left Arm'),
            _buildLocationOption('Right Arm', 'Right Arm'),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationOption(String title, String value) {
    return ListTile(
      title: Text(title, style: AppTextStyles.text()),
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

