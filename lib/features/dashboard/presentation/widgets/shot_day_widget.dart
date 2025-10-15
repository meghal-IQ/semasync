import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';

class ShotDayWidget extends StatefulWidget {
  final List<int> selectedDays; // 1=Monday, 2=Tuesday, etc.
  final VoidCallback? onToggleDay;
  
  const ShotDayWidget({
    super.key,
    required this.selectedDays,
    this.onToggleDay,
  });

  @override
  State<ShotDayWidget> createState() => _ShotDayWidgetState();
}

class _ShotDayWidgetState extends State<ShotDayWidget> {
  bool _isExpanded = true;
  
  final List<Map<String, dynamic>> _shotDayTasks = [
    {
      'title': 'High-Protein Meal/Drink',
      'time': '7:00 PM',
      'completed': true,
    },
    {
      'title': 'Drink lots of Water (+electrolytes)',
      'time': '7:00 PM',
      'completed': true,
    },
    {
      'title': 'Load Syringe and let come to room temp',
      'time': '7:15 PM',
      'completed': true,
    },
    {
      'title': 'Take Shot',
      'time': '8:00 PM',
      'completed': true,
      'isMainTask': true,
    },
    {
      'title': 'Another High Protein Meal/Drink',
      'time': '9:00 PM',
      'completed': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final todayWeekday = today.weekday; // 1=Monday, 7=Sunday
    
    // Check if today is a shot day
    if (!widget.selectedDays.contains(todayWeekday)) {
      return const SizedBox.shrink(); // Don't show if not a shot day
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.spacing16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey[300]!,
          width: 1,
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [
                      Color(0xFF8B5CF6), // Light purple
                      Color(0xFFA855F7), // Medium purple
                    ],
                  ).createShader(bounds),
                  child: const Text(
                    'Shot Day',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
                  child: Text(
                    _isExpanded ? 'See Less' : 'See More',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Tasks List
          if (_isExpanded) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                children: _shotDayTasks.map((task) => _buildTaskItem(task)).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTaskItem(Map<String, dynamic> task) {
    final isMainTask = task['isMainTask'] == true;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          // Checkbox
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: task['completed'] 
                  ? Colors.grey[300] 
                  : Colors.transparent,
              border: Border.all(
                color: Colors.grey[400]!,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            child: task['completed']
                ? const Icon(
                    Icons.check,
                    size: 16,
                    color: Colors.white,
                  )
                : null,
          ),
          
          const SizedBox(width: 12),
          
          // Task content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task['title'],
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  task['time'],
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isMainTask 
                        ? const Color(0xFF3B82F6) // Blue for main task
                        : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ShotDaySelector extends StatefulWidget {
  final List<int> selectedDays;
  final Function(List<int>) onDaysChanged;
  
  const ShotDaySelector({
    super.key,
    required this.selectedDays,
    required this.onDaysChanged,
  });

  @override
  State<ShotDaySelector> createState() => _ShotDaySelectorState();
}

class _ShotDaySelectorState extends State<ShotDaySelector> {
  final List<String> _dayLabels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
  final List<String> _dayNames = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.spacing16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(7, (index) {
          final dayOfWeek = index + 1; // 1=Monday, 7=Sunday
          final isSelected = widget.selectedDays.contains(dayOfWeek);
          final isToday = DateTime.now().weekday == dayOfWeek;
          
          return GestureDetector(
            onTap: () {
              setState(() {
                if (isSelected) {
                  widget.selectedDays.remove(dayOfWeek);
                } else {
                  widget.selectedDays.add(dayOfWeek);
                }
                widget.onDaysChanged(List.from(widget.selectedDays));
              });
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected 
                    ? AppColors.primary 
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: !isSelected
                    ? Border.all(
                        color: Colors.grey[300]!,
                        width: 1,
                        style: BorderStyle.solid,
                      )
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _dayLabels[index],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isSelected 
                          ? Colors.white 
                          : Colors.grey[500],
                    ),
                  ),
                  if (isSelected || isToday) ...[
                    const SizedBox(height: 2),
                    Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? Colors.white 
                            : AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
