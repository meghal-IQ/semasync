import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';

class WaterLoggingScreen extends StatefulWidget {
  const WaterLoggingScreen({super.key});

  @override
  State<WaterLoggingScreen> createState() => _WaterLoggingScreenState();
}

class _WaterLoggingScreenState extends State<WaterLoggingScreen> {
  DateTime _selectedDate = DateTime.now();
  int _waterIntake = 0; // ml
  int _waterGoal = 2500; // ml
  String _notes = '';

  final List<Map<String, dynamic>> _waterEntries = [
    {'amount': 250, 'time': '8:00 AM', 'type': 'Glass'},
    {'amount': 500, 'time': '10:30 AM', 'type': 'Bottle'},
    {'amount': 250, 'time': '1:00 PM', 'type': 'Glass'},
    {'amount': 500, 'time': '3:30 PM', 'type': 'Bottle'},
  ];

  final List<Map<String, dynamic>> _quickAmounts = [
    {'amount': 250, 'label': 'Glass', 'icon': Icons.local_drink},
    {'amount': 500, 'label': 'Bottle', 'icon': Icons.water_drop},
    {'amount': 1000, 'label': 'Liter', 'icon': Icons.local_fire_department},
    {'amount': 1500, 'label': 'Large Bottle', 'icon': Icons.water},
  ];

  @override
  void initState() {
    super.initState();
    _calculateTotalIntake();
  }

  void _calculateTotalIntake() {
    _waterIntake = _waterEntries.fold(0, (sum, entry) => sum + (entry['amount'] as int));
  }

  @override
  Widget build(BuildContext context) {
    final progress = _waterIntake / _waterGoal;
    final remaining = _waterGoal - _waterIntake;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Water'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save_outlined),
            onPressed: _saveWater,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.spacing16),
        children: [
          _buildDateSelector(),
          const SizedBox(height: AppConstants.spacing24),
          _buildWaterProgress(),
          const SizedBox(height: AppConstants.spacing24),
          _buildQuickAddButtons(),
          const SizedBox(height: AppConstants.spacing24),
          _buildWaterEntries(),
          const SizedBox(height: AppConstants.spacing24),
          _buildCustomAmount(),
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
        title: const Text('Date'),
        subtitle: Text(
          '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: _selectDate,
      ),
    );
  }

  Widget _buildWaterProgress() {
    final progress = _waterIntake / _waterGoal;
    final remaining = _waterGoal - _waterIntake;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacing16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Water Intake',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${(progress * 100).toInt()}%',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.waterBlue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacing20),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: CircularProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    strokeWidth: 12,
                    backgroundColor: AppColors.waterBlue.withOpacity(0.2),
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.waterBlue),
                  ),
                ),
                Column(
                  children: [
                    Text(
                      '${(_waterIntake / 1000).toStringAsFixed(1)}L',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.waterBlue,
                      ),
                    ),
                    Text(
                      'of ${(_waterGoal / 1000).toStringAsFixed(1)}L',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacing20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppConstants.spacing12),
              decoration: BoxDecoration(
                color: remaining > 0 
                    ? AppColors.waterBlue.withOpacity(0.1)
                    : AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
              ),
              child: Row(
                children: [
                  Icon(
                    remaining > 0 ? Icons.info_outline : Icons.check_circle,
                    color: remaining > 0 ? AppColors.waterBlue : AppColors.success,
                    size: 20,
                  ),
                  const SizedBox(width: AppConstants.spacing8),
                  Expanded(
                    child: Text(
                      remaining > 0 
                          ? '${remaining}ml more to reach your goal!'
                          : 'Great job! You\'ve reached your daily water goal!',
                      style: TextStyle(
                        color: remaining > 0 ? AppColors.waterBlue : AppColors.success,
                        fontWeight: FontWeight.w500,
                      ),
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

  Widget _buildQuickAddButtons() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quick Add',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppConstants.spacing16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: _quickAmounts.map((item) => _buildQuickAddButton(item)).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAddButton(Map<String, dynamic> item) {
    return GestureDetector(
      onTap: () => _addWaterEntry(item['amount']),
      child: Container(
        padding: const EdgeInsets.all(AppConstants.spacing12),
        decoration: BoxDecoration(
          color: AppColors.waterBlue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
        ),
        child: Column(
          children: [
            Icon(
              item['icon'],
              color: AppColors.waterBlue,
              size: 24,
            ),
            const SizedBox(height: AppConstants.spacing4),
            Text(
              '${item['amount']}ml',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              item['label'],
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWaterEntries() {
    if (_waterEntries.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spacing16),
          child: Column(
            children: [
              Icon(
                Icons.water_drop_outlined,
                size: 48,
                color: AppColors.textSecondary,
              ),
              const SizedBox(height: AppConstants.spacing12),
              Text(
                'No water logged yet',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: AppConstants.spacing8),
              Text(
                'Start logging your water intake',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Today\'s Entries',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppConstants.spacing12),
            ..._waterEntries.map((entry) => _buildWaterEntryTile(entry)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildWaterEntryTile(Map<String, dynamic> entry) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.spacing8),
      padding: const EdgeInsets.all(AppConstants.spacing12),
      decoration: BoxDecoration(
        color: AppColors.waterBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
      ),
      child: Row(
        children: [
          Icon(
            Icons.water_drop,
            color: AppColors.waterBlue,
            size: 20,
          ),
          const SizedBox(width: AppConstants.spacing12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${entry['amount']}ml',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${entry['type']} • ${entry['time']}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.remove_circle, color: AppColors.error),
            onPressed: () => _removeWaterEntry(entry),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomAmount() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Custom Amount',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppConstants.spacing12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: 'Enter amount (ml)',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      // Handle custom amount input
                    },
                  ),
                ),
                const SizedBox(width: AppConstants.spacing12),
                ElevatedButton(
                  onPressed: () {
                    // TODO: Add custom amount
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.waterBlue,
                  ),
                  child: const Text('Add'),
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
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Add any notes about your water intake...',
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
        onPressed: _saveWater,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.waterBlue,
          padding: const EdgeInsets.symmetric(vertical: AppConstants.spacing16),
        ),
        child: const Text(
          'Log Water',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 7)),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  void _addWaterEntry(int amount) {
    final now = DateTime.now();
    final timeString = '${now.hour}:${now.minute.toString().padLeft(2, '0')}';
    
    setState(() {
      _waterEntries.add({
        'amount': amount,
        'time': timeString,
        'type': _getWaterType(amount),
      });
      _calculateTotalIntake();
    });
  }

  void _removeWaterEntry(Map<String, dynamic> entry) {
    setState(() {
      _waterEntries.remove(entry);
      _calculateTotalIntake();
    });
  }

  String _getWaterType(int amount) {
    if (amount <= 250) return 'Glass';
    if (amount <= 500) return 'Bottle';
    if (amount <= 1000) return 'Liter';
    return 'Large Bottle';
  }

  void _saveWater() {
    // TODO: Save water data
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Water logged successfully!'),
        backgroundColor: AppColors.success,
      ),
    );
    Navigator.pop(context);
  }
}
