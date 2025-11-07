import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/providers/activity_provider.dart';
import '../../../../core/providers/historical_data_provider.dart';
import '../../../../core/api/models/activity_log_model.dart';
import '../../../../core/theme/app_text_styles.dart';

class ActivityLoggingScreen extends StatefulWidget {
  const ActivityLoggingScreen({super.key});

  @override
  State<ActivityLoggingScreen> createState() => _ActivityLoggingScreenState();
}

class _ActivityLoggingScreenState extends State<ActivityLoggingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _selectedDate = DateTime.now();
  int _selectedDayIndex = 4; // Index 4 is today (showing 10 days: 5 past, today, 4 future)
  String _notes = '';

  // Steps tracking
  int _steps = 5000;
  int _stepGoal = 10000;
  double _stepDistance = 0.0;
  double _stepCalories = 0.0;
  bool _isSavingSteps = false;

  // Workout tracking
  String _workoutType = 'Cardio';
  int _duration = 30;
  double _intensity = 5.0;
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
    // Load data when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDataForSelectedDate();
    });
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
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Custom Header
            _buildCustomHeader(),
            
            // Modern Tab Bar
            _buildModernTabBar(),
            
            // Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildStepsTab(),
                  _buildWorkoutTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomHeader() {
    final now = DateTime.now();
    final isToday = _selectedDate.year == now.year &&
                    _selectedDate.month == now.month &&
                    _selectedDate.day == now.day;
    
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Text(
              'Log Activity',
              textAlign: TextAlign.center,
              style: AppTextStyles.title(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                isToday ? 'Today' : '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              GestureDetector(
                onTap: () {
                  if (_tabController.index == 0) {
                    _saveSteps();
                  } else {
                    _saveWorkout();
                  }
                },
                child: Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Save',
                    style: AppTextStyles.title(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModernTabBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(12),
        ),
        child: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(12),
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          labelColor: Colors.white,
          unselectedLabelColor: const Color(0xFF6B7280),
          labelStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          tabs: const [
            Tab(text: 'Steps'),
            Tab(text: 'Workout'),
          ],
        ),
      ),
    );
  }

  Widget _buildStepsTab() {
    final progress = (_steps / _stepGoal * 100).clamp(0, 100);
    
    return ListView(
      padding: const EdgeInsets.only(top: 24, left: 20, right: 20, bottom: 20),
      children: [
        _buildDayPicker(),
        const SizedBox(height: 24),
        _buildStepCountDisplay(progress),
        const SizedBox(height: 24),
        _buildStepAdjustmentButtons(),
        const SizedBox(height: 24),
        // _buildStepsSlider(),
        // const SizedBox(height: 24),
        _buildStepMetrics(),
        const SizedBox(height: 24),
        _buildNotesField(),
        const SizedBox(height: 32),
        _buildSaveStepsButton(),
      ],
    );
  }

  Widget _buildWorkoutTab() {
    return ListView(
      padding: const EdgeInsets.only(top: 24, left: 20, right: 20, bottom: 20),
      children: [
        _buildDayPicker(),
        const SizedBox(height: 24),
        _buildWorkoutTypeSelector(),
        const SizedBox(height: 24),
        _buildDurationSelector(),
        const SizedBox(height: 24),
        _buildIntensitySlider(),
        const SizedBox(height: 24),
        _buildCaloriesDisplay(),
        const SizedBox(height: 24),
        _buildNotesField(),
        const SizedBox(height: 32),
        _buildSaveButton(),
      ],
    );
  }

  Widget _buildDayPicker() {
    final now = DateTime.now();
    final List<DateTime> dates = [];
    final List<String> dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    
    // Generate 10 days: 5 days ago, today, 4 days ahead
    for (int i = -5; i <= 4; i++) {
      dates.add(now.add(Duration(days: i)));
    }
    
    return SizedBox(
      height: 80,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: dates.length,
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final date = dates[index];
          final isSelected = index == _selectedDayIndex;
          final dayOfWeek = dayLabels[date.weekday - 1];
          final dayNumber = date.day;
          final monthAbbr = _getMonthAbbr(date.month);
          
          if (isSelected) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedDayIndex = index;
                  _selectedDate = DateTime(
                    date.year,
                    date.month,
                    date.day,
                    _selectedDate.hour,
                    _selectedDate.minute,
                  );
                });
                _loadDataForSelectedDate();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(
                          color: AppColors.primary,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '$dayNumber',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dayOfWeek,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      monthAbbr,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else {
            final isToday = date.year == now.year &&
                           date.month == now.month &&
                           date.day == now.day;
            
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedDayIndex = index;
                  _selectedDate = DateTime(
                    date.year,
                    date.month,
                    date.day,
                    _selectedDate.hour,
                    _selectedDate.minute,
                  );
                });
                _loadDataForSelectedDate();
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isToday 
                          ? AppColors.primary.withOpacity(0.1)
                          : AppColors.lightGrey,
                    ),
                    child: Center(
                      child: Text(
                        '$dayNumber',
                        style: AppTextStyles.title(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isToday 
                              ? AppColors.primary
                              : const Color(0xFF6B7280),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dayOfWeek,
                    style: AppTextStyles.title(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isToday 
                          ? AppColors.primary
                          : const Color(0xFF6B7280),
                    ),
                  ),
                  Text(
                    monthAbbr,
                    style: AppTextStyles.title(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  String _getMonthAbbr(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  Widget _buildStepCountDisplay( progress) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.lightGrey,
        borderRadius: BorderRadius.circular(12),
      ),
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
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'steps',
            style: AppTextStyles.title(
              fontSize: 16,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: LinearProgressIndicator(
              value: progress / 100,
              minHeight: 12,
              backgroundColor: const Color(0xFFE5E7EB),
              valueColor: AlwaysStoppedAnimation<Color>(
                progress >= 100 ? AppColors.success : AppColors.activityRed,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${progress.toStringAsFixed(0)}% of goal',
                style: AppTextStyles.title(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: progress >= 100 ? AppColors.success : AppColors.activityRed,
                ),
              ),
              if (progress >= 100) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.emoji_events, color: AppColors.success, size: 16),
                      SizedBox(width: 4),
                      Text(
                        'Goal Reached!',
                        style: AppTextStyles.title(
                          color: AppColors.success,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepAdjustmentButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.lightGrey,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Adjust Steps',
            style: AppTextStyles.title(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
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
          /*Row(
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
          ),*/
        ],
      ),
    );
  }

  Widget _buildAdjustButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 60,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.activityRed, size: 28),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.activityRed,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepsSlider() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Fine Tune',
              style: AppTextStyles.title(
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
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.lightGrey,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Estimated Metrics',
            style: AppTextStyles.title(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
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
              const SizedBox(width: 12),
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
    );
  }

  Widget _buildMetricItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.title(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF6B7280),
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
            Text(
              'Steps Today',
              style: AppTextStyles.title(
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
                  label: Text('Reset'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.textSecondary,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _syncWithDevice,
                  icon: const Icon(Icons.sync),
                  label: Text('Sync'),
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
            Text(
              'Daily Goal',
              style: AppTextStyles.title(
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
    return GestureDetector(
      onTap: _selectWorkoutType,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.lightGrey,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.fitness_center, color: AppColors.primary, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Workout Type',
                    style: AppTextStyles.title(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _workoutType,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFF6B7280)),
          ],
        ),
      ),
    );
  }

  Widget _buildDurationSelector() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.lightGrey,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Duration',
                style: AppTextStyles.title(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              Text(
                '$_duration minutes',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
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
                style: AppTextStyles.title(
                  color: Color(0xFF6B7280),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '180 min',
                style: AppTextStyles.title(
                  color: Color(0xFF6B7280),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIntensitySlider() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.lightGrey,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Intensity',
                style: AppTextStyles.title(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              Text(
                '${_intensity.toInt()}/10',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
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
                style: AppTextStyles.title(
                  color: Color(0xFF6B7280),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'Intense',
                style: AppTextStyles.title(
                  color: Color(0xFF6B7280),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCaloriesDisplay() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.lightGrey,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            'Estimated Calories Burned',
            style: AppTextStyles.title(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '$_caloriesBurned',
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: AppColors.activityRed,
            ),
          ),
          Text(
            'calories',
            style: AppTextStyles.title(
              fontSize: 16,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesField() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.lightGrey,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Notes (Optional)',
            style: AppTextStyles.title(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Add any notes about your activity...',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.primary, width: 2),
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
            onChanged: (value) {
              setState(() {
                _notes = value;
              });
            },
          ),
        ],
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
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
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
            : Text(
                'Log Steps',
                style: AppTextStyles.title(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
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
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
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
            : Text(
                'Log Workout',
          style: AppTextStyles.title(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Future<void> _selectDateTime() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(now.year - 2, now.month, now.day),
      lastDate: DateTime(now.year + 2, now.month, now.day),
    );

    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDate),
      );

      if (time != null) {
        final newDate = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );
        setState(() {
          _selectedDate = newDate;
        });
        _loadDataForSelectedDate();
      } else if (date != null) {
        // If time picker is cancelled but date was selected, still update date
        final newDate = DateTime(
          date.year,
          date.month,
          date.day,
          _selectedDate.hour,
          _selectedDate.minute,
        );
        setState(() {
          _selectedDate = newDate;
        });
        _loadDataForSelectedDate();
      }
    }
  }

  void _loadDataForSelectedDate() {
    final now = DateTime.now();
    final isToday = _selectedDate.year == now.year &&
                    _selectedDate.month == now.month &&
                    _selectedDate.day == now.day;
    
    if (isToday) {
      // Load current day data
      context.read<ActivityProvider>().loadActivityData();
    } else {
      // Load historical data
      context.read<HistoricalDataProvider>().loadHistoricalData(_selectedDate);
      // Also load activity data to get steps/workouts for the selected date
      context.read<ActivityProvider>().loadActivityData();
    }
    
    // Load existing steps/workout for the selected date
    _loadExistingActivityData();
  }

  void _loadExistingActivityData() {
    final activityProvider = context.read<ActivityProvider>();
    
    // Find steps for selected date
    final selectedDateOnly = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
    final stepsForDate = activityProvider.stepsHistory.where((step) {
      final stepDate = DateTime(step.date.year, step.date.month, step.date.day);
      return stepDate.year == selectedDateOnly.year &&
             stepDate.month == selectedDateOnly.month &&
             stepDate.day == selectedDateOnly.day;
    }).toList();
    
    if (stepsForDate.isNotEmpty) {
      final stepLog = stepsForDate.first;
      setState(() {
        _steps = stepLog.steps;
        _stepGoal = stepLog.goal;
        _notes = stepLog.notes ?? '';
        _calculateStepMetrics();
      });
    } else {
      setState(() {
        _steps = 0;
        _stepGoal = 10000;
        _notes = '';
        _calculateStepMetrics();
      });
    }
    
    // Find workout for selected date
    final workoutsForDate = activityProvider.workoutsHistory.where((workout) {
      final workoutDate = DateTime(workout.date.year, workout.date.month, workout.date.day);
      return workoutDate.year == selectedDateOnly.year &&
             workoutDate.month == selectedDateOnly.month &&
             workoutDate.day == selectedDateOnly.day;
    }).toList();
    
    if (workoutsForDate.isNotEmpty) {
      final workoutLog = workoutsForDate.first;
      setState(() {
        _workoutType = workoutLog.type;
        _duration = workoutLog.duration;
        _intensity = workoutLog.intensity.toDouble();
        _caloriesBurned = workoutLog.caloriesBurned.toInt();
        _notes = workoutLog.notes ?? '';
        _calculateCalories();
      });
    } else {
      setState(() {
        _workoutType = 'Cardio';
        _duration = 30;
        _intensity = 5.0;
        _caloriesBurned = 0;
        _notes = '';
        _calculateCalories();
      });
    }
  }

  Future<void> _selectWorkoutType() async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select Workout Type'),
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

