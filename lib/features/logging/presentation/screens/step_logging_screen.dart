import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/providers/activity_provider.dart';
import '../../../../core/api/models/activity_log_model.dart';

class StepLoggingScreen extends StatefulWidget {
  const StepLoggingScreen({super.key});

  @override
  State<StepLoggingScreen> createState() => _StepLoggingScreenState();
}

class _StepLoggingScreenState extends State<StepLoggingScreen> {
  DateTime _selectedDate = DateTime.now();
  int _steps = 5000;
  int _stepGoal = 10000;
  double _distance = 0.0;
  double _caloriesBurned = 0.0;
  String _notes = '';
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _calculateMetrics();
  }

  void _calculateMetrics() {
    // Rough calculation: 1000 steps ≈ 0.8 km, burns ~50 calories
    setState(() {
      _distance = (_steps * 0.0008);
      _caloriesBurned = (_steps * 0.05);
    });
  }

  Future<void> _saveSteps() async {
    if (_isSaving) return;

    setState(() {
      _isSaving = true;
    });

    final stepLog = StepLog(
      id: '',
      userId: '',
      date: _selectedDate,
      steps: _steps,
      goal: _stepGoal,
      distance: _distance,
      caloriesBurned: _caloriesBurned,
      notes: _notes.isNotEmpty ? _notes : null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final provider = context.read<ActivityProvider>();
    final success = await provider.logSteps(stepLog);

    setState(() {
      _isSaving = false;
    });

    if (success && mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_steps / _stepGoal * 100).clamp(0, 100);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Steps'),
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
              onPressed: _saveSteps,
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.spacing16),
        children: [
          // Date Selector
          _buildDateSelector(),
          
          const SizedBox(height: AppConstants.spacing24),
          
          // Step Count Display
          _buildStepCountDisplay(progress),
          
          const SizedBox(height: AppConstants.spacing24),
          
          // Step Counter
          _buildStepCounter(),
          
          const SizedBox(height: AppConstants.spacing24),
          
          // Goal Selector
          _buildGoalSelector(),
          
          const SizedBox(height: AppConstants.spacing24),
          
          // Metrics Display
          _buildMetricsCard(),
          
          const SizedBox(height: AppConstants.spacing24),
          
          // Notes Field
          _buildNotesField(),
          
          const SizedBox(height: AppConstants.spacing32),
          
          // Save Button
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

  Widget _buildStepCountDisplay(progress) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacing24),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  _steps.toString(),
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '/ $_stepGoal',
                  style: const TextStyle(
                    fontSize: 24,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacing8),
            const Text(
              'steps',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppConstants.spacing16),
            
            // Progress Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
              child: LinearProgressIndicator(
                value: progress / 100,
                minHeight: 8,
                backgroundColor: AppColors.divider,
                valueColor: AlwaysStoppedAnimation<Color>(
                  progress >= 100 ? AppColors.success : AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: AppConstants.spacing8),
            Text(
              '${progress.toStringAsFixed(0)}% of goal',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: progress >= 100 ? AppColors.success : AppColors.primary,
              ),
            ),
            
            // Goal Achievement Badge
            if (progress >= 100)
              Container(
                margin: const EdgeInsets.only(top: AppConstants.spacing12),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.spacing12,
                  vertical: AppConstants.spacing4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.emoji_events, color: AppColors.success, size: 16),
                    SizedBox(width: 4),
                    Text(
                      'Goal Reached!',
                      style: TextStyle(
                        color: AppColors.success,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
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

  Widget _buildStepCounter() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // const Text(
            //   'Adjust Steps',
            //   style: TextStyle(
            //     fontSize: 16,
            //     fontWeight: FontWeight.w500,
            //   ),
            // ),
            const SizedBox(height: AppConstants.spacing16),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Decrease by 1000
                _buildAdjustButton(
                  icon: Icons.remove_circle_outline,
                  label: '-1000',
                  onPressed: () {
                    setState(() {
                      _steps = (_steps - 1000).clamp(0, 100000);
                      _calculateMetrics();
                    });
                  },
                ),
                
                // Decrease by 100
                _buildAdjustButton(
                  icon: Icons.remove,
                  label: '-100',
                  onPressed: () {
                    setState(() {
                      _steps = (_steps - 100).clamp(0, 100000);
                      _calculateMetrics();
                    });
                  },
                ),
                
                // Increase by 100
                _buildAdjustButton(
                  icon: Icons.add,
                  label: '+100',
                  onPressed: () {
                    setState(() {
                      _steps = (_steps + 100).clamp(0, 100000);
                      _calculateMetrics();
                    });
                  },
                ),
                
                // Increase by 1000
                _buildAdjustButton(
                  icon: Icons.add_circle_outline,
                  label: '+1000',
                  onPressed: () {
                    setState(() {
                      _steps = (_steps + 1000).clamp(0, 100000);
                      _calculateMetrics();
                    });
                  },
                ),
              ],
            ),
            
            const SizedBox(height: AppConstants.spacing16),
            
            // Slider for fine-tuning
            Slider(
              value: _steps.toDouble(),
              min: 0,
              max: 30000,
              divisions: 300,
              label: _steps.toString(),
              onChanged: (value) {
                setState(() {
                  _steps = value.round();
                  _calculateMetrics();
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdjustButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Column(
      children: [
        IconButton(
          icon: Icon(icon),
          onPressed: onPressed,
          color: AppColors.primary,
          iconSize: 32,
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildGoalSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Daily Goal',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: AppConstants.spacing12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [5000, 8000, 10000, 12000, 15000].map((goal) {
                final isSelected = _stepGoal == goal;
                return FilterChip(
                  label: Text('${goal ~/ 1000}k'),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _stepGoal = goal;
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

  Widget _buildMetricsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Estimated Metrics',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: AppConstants.spacing16),
            Row(
              children: [
                Expanded(
                  child: _buildMetricItem(
                    icon: Icons.route,
                    label: 'Distance',
                    value: '${_distance.toStringAsFixed(2)} km',
                    color: AppColors.activityRed,
                  ),
                ),
                const SizedBox(width: AppConstants.spacing12),
                Expanded(
                  child: _buildMetricItem(
                    icon: Icons.local_fire_department,
                    label: 'Calories',
                    value: '${_caloriesBurned.toStringAsFixed(0)} kcal',
                    color: AppColors.proteinOrange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacing12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: AppConstants.spacing4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
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
              maxLines: 3,
              maxLength: 500,
              decoration: const InputDecoration(
                hintText: 'Add notes about your activity...',
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
        onPressed: _isSaving ? null : _saveSteps,
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
                'Log Steps',
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
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }
}
