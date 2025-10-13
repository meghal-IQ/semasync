import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/providers/activity_provider.dart';
import '../../../../core/api/models/activity_log_model.dart';

class ActivityLoggingScreen extends StatefulWidget {
  const ActivityLoggingScreen({super.key});

  @override
  State<ActivityLoggingScreen> createState() => _ActivityLoggingScreenState();
}

class _ActivityLoggingScreenState extends State<ActivityLoggingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _selectedDate = DateTime.now();
  String _notes = '';

  // Steps tracking
  int _steps = 5000;
  int _stepGoal = 10000;
  double _stepDistance = 0.0;
  double _stepCalories = 0.0;
  bool _isSavingSteps = false;

  // Workout tracking
  String _workoutType = 'Cardio';
  int _duration = 30; // minutes
  double _intensity = 5.0; // 1-10 scale
  int _caloriesBurned = 0;
  bool _isSavingWorkout = false;

  final List<String> _workoutTypes = [
    'Cardio',
    'Strength Training',
    'Yoga',
    'Swimming',
    'Cycling',
    'Running',
    'Walking',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _calculateCalories();
    _calculateStepMetrics();
  }

  void _calculateStepMetrics() {
    setState(() {
      _stepDistance = (_steps * 0.0008);
      _stepCalories = (_steps * 0.05);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _calculateCalories() {
    // Simple calorie calculation based on workout type and duration
    double baseCaloriesPerMinute = 8.0; // Base calories per minute
    double intensityMultiplier = _intensity / 5.0; // Scale intensity to multiplier
    
    switch (_workoutType) {
      case 'Cardio':
        baseCaloriesPerMinute = 10.0;
        break;
      case 'Strength Training':
        baseCaloriesPerMinute = 6.0;
        break;
      case 'Yoga':
        baseCaloriesPerMinute = 4.0;
        break;
      case 'Swimming':
        baseCaloriesPerMinute = 12.0;
        break;
      case 'Cycling':
        baseCaloriesPerMinute = 9.0;
        break;
      case 'Running':
        baseCaloriesPerMinute = 11.0;
        break;
      case 'Walking':
        baseCaloriesPerMinute = 5.0;
        break;
    }
    
    _caloriesBurned = (baseCaloriesPerMinute * _duration * intensityMultiplier).round();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Activity'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              if (_tabController.index == 0) {
                _saveSteps();
              } else {
                _saveWorkout();
              }
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Steps'),
            Tab(text: 'Workout'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildStepsTab(),
          _buildWorkoutTab(),
        ],
      ),
    );
  }

  Widget _buildStepsTab() {
    final progress = (_steps / _stepGoal * 100).clamp(0, 100);
    
    return ListView(
      padding: const EdgeInsets.all(AppConstants.spacing16),
      children: [
        _buildDateSelector(),
        const SizedBox(height: AppConstants.spacing24),
        _buildStepCountDisplay(progress),
        const SizedBox(height: AppConstants.spacing24),
        // _buildStepAdjustmentButtons(),
        // const SizedBox(height: AppConstants.spacing16),
        // _buildStepsSlider(),
        // const SizedBox(height: AppConstants.spacing24),
        // _buildStepsGoal(),
        // const SizedBox(height: AppConstants.spacing24),
        _buildStepMetrics(),
        const SizedBox(height: AppConstants.spacing24),
        _buildNotesField(),
        const SizedBox(height: AppConstants.spacing32),
        _buildSaveStepsButton(),
      ],
    );
  }

  Widget _buildWorkoutTab() {
    return ListView(
      padding: const EdgeInsets.all(AppConstants.spacing16),
      children: [
        _buildDateSelector(),
        const SizedBox(height: AppConstants.spacing16),
        _buildWorkoutTypeSelector(),
        const SizedBox(height: AppConstants.spacing16),
        _buildDurationSelector(),
        const SizedBox(height: AppConstants.spacing16),
        _buildIntensitySlider(),
        const SizedBox(height: AppConstants.spacing16),
        _buildCaloriesDisplay(),
        const SizedBox(height: AppConstants.spacing24),
        _buildNotesField(),
        const SizedBox(height: AppConstants.spacing32),
        _buildSaveButton(),
      ],
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

  Widget _buildStepCountDisplay( progress) {
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
                    color: AppColors.activityRed,
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
            ClipRRect(
              borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
              child: LinearProgressIndicator(
                value: progress / 100,
                minHeight: 8,
                backgroundColor: AppColors.divider,
                valueColor: AlwaysStoppedAnimation<Color>(
                  progress >= 100 ? AppColors.success : AppColors.activityRed,
                ),
              ),
            ),
            const SizedBox(height: AppConstants.spacing8),
            Text(
              '${progress.toStringAsFixed(0)}% of goal',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: progress >= 100 ? AppColors.success : AppColors.activityRed,
              ),
            ),
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

  Widget _buildStepAdjustmentButtons() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Adjust Steps',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: AppConstants.spacing16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildAdjustButton(
                  icon: Icons.remove_circle_outline,
                  label: '-1000',
                  onPressed: () {
                    setState(() {
                      _steps = (_steps - 1000).clamp(0, 100000);
                      _calculateStepMetrics();
                    });
                  },
                ),
                _buildAdjustButton(
                  icon: Icons.remove,
                  label: '-100',
                  onPressed: () {
                    setState(() {
                      _steps = (_steps - 100).clamp(0, 100000);
                      _calculateStepMetrics();
                    });
                  },
                ),
                _buildAdjustButton(
                  icon: Icons.add,
                  label: '+100',
                  onPressed: () {
                    setState(() {
                      _steps = (_steps + 100).clamp(0, 100000);
                      _calculateStepMetrics();
                    });
                  },
                ),
                _buildAdjustButton(
                  icon: Icons.add_circle_outline,
                  label: '+1000',
                  onPressed: () {
                    setState(() {
                      _steps = (_steps + 1000).clamp(0, 100000);
                      _calculateStepMetrics();
                    });
                  },
                ),
              ],
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
          color: AppColors.activityRed,
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

  Widget _buildStepsSlider() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Fine Tune',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            Slider(
              value: _steps.toDouble(),
              min: 0,
              max: 30000,
              divisions: 300,
              label: _steps.toString(),
              activeColor: AppColors.activityRed,
              onChanged: (value) {
                setState(() {
                  _steps = value.round();
                  _calculateStepMetrics();
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepMetrics() {
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
                    value: '${_stepDistance.toStringAsFixed(2)} km',
                    color: AppColors.activityRed,
                  ),
                ),
                const SizedBox(width: AppConstants.spacing12),
                Expanded(
                  child: _buildMetricItem(
                    icon: Icons.local_fire_department,
                    label: 'Calories',
                    value: '${_stepCalories.toStringAsFixed(0)} kcal',
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

  Widget _buildOldStepsCounter() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacing16),
        child: Column(
          children: [
            const Text(
              'Steps Today',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppConstants.spacing20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStepButton(-1000, '-1k'),
                _buildStepButton(-100, '-100'),
                Container(
                  padding: const EdgeInsets.all(AppConstants.spacing16),
                  decoration: BoxDecoration(
                    color: AppColors.activityRed.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    _steps.toString(),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.activityRed,
                    ),
                  ),
                ),
                _buildStepButton(100, '+100'),
                _buildStepButton(1000, '+1k'),
              ],
            ),
            const SizedBox(height: AppConstants.spacing20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _setSteps(0),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reset'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.textSecondary,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _syncWithDevice,
                  icon: const Icon(Icons.sync),
                  label: const Text('Sync'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.activityRed,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepButton(int change, String label) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _steps = (_steps + change).clamp(0, 50000);
        });
      },
      child: Container(
        padding: const EdgeInsets.all(AppConstants.spacing12),
        decoration: BoxDecoration(
          color: AppColors.activityRed.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.activityRed,
          ),
        ),
      ),
    );
  }

  Widget _buildStepsGoal() {
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
                  selectedColor: AppColors.activityRed.withOpacity(0.2),
                  checkmarkColor: AppColors.activityRed,
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

  Widget _buildWorkoutTypeSelector() {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.fitness_center, color: AppColors.primary),
        title: const Text('Workout Type'),
        subtitle: Text(_workoutType),
        trailing: const Icon(Icons.chevron_right),
        onTap: _selectWorkoutType,
      ),
    );
  }

  Widget _buildDurationSelector() {
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
                  'Duration',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '$_duration minutes',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacing16),
            Slider(
              value: _duration.toDouble(),
              min: 5,
              max: 180,
              divisions: 35,
              activeColor: AppColors.primary,
              onChanged: (value) {
                setState(() {
                  _duration = value.round();
                  _calculateCalories();
                });
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '5 min',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                Text(
                  '180 min',
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

  Widget _buildIntensitySlider() {
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
                  'Intensity',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${_intensity.toInt()}/10',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacing16),
            Slider(
              value: _intensity,
              min: 1,
              max: 10,
              divisions: 9,
              activeColor: AppColors.primary,
              onChanged: (value) {
                setState(() {
                  _intensity = value;
                  _calculateCalories();
                });
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Light',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                Text(
                  'Intense',
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

  Widget _buildCaloriesDisplay() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacing16),
        child: Column(
          children: [
            const Text(
              'Estimated Calories Burned',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppConstants.spacing12),
            Text(
              '$_caloriesBurned',
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: AppColors.activityRed,
              ),
            ),
            const Text(
              'calories',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
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
                hintText: 'Add any notes about your activity...',
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

  Widget _buildSaveStepsButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSavingSteps ? null : _saveSteps,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.activityRed,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: AppConstants.spacing16),
        ),
        child: _isSavingSteps
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

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSavingWorkout ? null : _saveWorkout,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.activityRed,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: AppConstants.spacing16),
        ),
        child: _isSavingWorkout
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                'Log Workout',
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
      firstDate: DateTime.now().subtract(const Duration(days: 7)),
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

  Future<void> _selectWorkoutType() async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Workout Type'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _workoutTypes.map((type) => ListTile(
            title: Text(type),
            onTap: () => Navigator.pop(context, type),
          )).toList(),
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _workoutType = result;
        _calculateCalories();
      });
    }
  }

  void _setSteps(int steps) {
    setState(() {
      _steps = steps;
    });
  }

  void _syncWithDevice() {
    // TODO: Sync with fitness device
  }

  Future<void> _saveSteps() async {
    if (_isSavingSteps) return;

    setState(() {
      _isSavingSteps = true;
    });

    final stepLog = StepLog(
      id: '',
      userId: '',
      date: _selectedDate,
      steps: _steps,
      goal: _stepGoal,
      distance: _stepDistance,
      caloriesBurned: _stepCalories,
      notes: _notes.isNotEmpty ? _notes : null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final provider = context.read<ActivityProvider>();
    final success = await provider.logSteps(stepLog);

    setState(() {
      _isSavingSteps = false;
    });

    if (success && mounted) {
      Navigator.pop(context);
    }
  }

  Future<void> _saveWorkout() async {
    if (_isSavingWorkout) return;

    setState(() {
      _isSavingWorkout = true;
    });

    final workoutLog = WorkoutLog(
      id: '',
      userId: '',
      date: _selectedDate,
      type: _workoutType,
      duration: _duration,
      intensity: _intensity.round(),
      caloriesBurned: _caloriesBurned.toDouble(),
      notes: _notes.isNotEmpty ? _notes : null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final provider = context.read<ActivityProvider>();
    final success = await provider.logWorkout(workoutLog);

    setState(() {
      _isSavingWorkout = false;
    });

    if (success && mounted) {
      Navigator.pop(context);
    }
  }
}

