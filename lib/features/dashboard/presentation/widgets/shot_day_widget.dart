import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/providers/shot_day_tasks_provider.dart';

class ShotDayWidget extends StatefulWidget {
  final DateTime? date; // Optional date parameter for historical view
  
  const ShotDayWidget({
    super.key,
    this.date,
  });

  @override
  State<ShotDayWidget> createState() => _ShotDayWidgetState();
}

class _ShotDayWidgetState extends State<ShotDayWidget> {
  bool _isExpanded = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTasks();
    });
  }

  Future<void> _loadTasks() async {
    final provider = Provider.of<ShotDayTasksProvider>(context, listen: false);
    await provider.loadTasks(date: widget.date);
  }

  Future<void> _resetAllTasks() async {
    final provider = Provider.of<ShotDayTasksProvider>(context, listen: false);
    await provider.resetAllTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ShotDayTasksProvider>(
      builder: (context, provider, child) {
        final today = DateTime.now();
        final todayWeekday = today.weekday; // 1=Monday, 7=Sunday

        // Check if today is a shot day
        if (!provider.selectedDays.contains(todayWeekday)) {
          return const SizedBox.shrink(); // Don't show if not a shot day
        }

        if (provider.isLoading) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: AppConstants.spacing16),
            padding: const EdgeInsets.all(20),
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        final tasks = provider.tasks;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.spacing16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey[300]!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
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
                Row(
                  children: [
                    GestureDetector(
                      onTap: _resetAllTasks,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Reset',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
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
              ],
            ),
          ),
          
          // Tasks List
          if (_isExpanded) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                children: tasks.asMap().entries.map((entry) {
                  return _buildTaskItem(entry.value, entry.key, provider);
                }).toList(),
              ),
            ),
          ],
        ],
      ),
        );
      },
    );
  }

  Widget _buildTaskItem(Map<String, dynamic> task, int index, ShotDayTasksProvider provider) {
    final isMainTask = task['isMainTask'] == true;
    
    return GestureDetector(
      onTap: () {
        provider.toggleTask(index);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            // Checkbox
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: task['completed'] 
                    ? Colors.grey[400] 
                    : Colors.transparent,
                border: Border.all(
                  color: Colors.grey[400]!,
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(6),
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
                      color: task['completed'] 
                          ? Colors.grey[500] 
                          : Colors.grey[700],
                      height: 1.3,
                      decoration: task['completed'] 
                          ? TextDecoration.lineThrough 
                          : null,
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
      ),
    );
  }
}

class ShotDaySelector extends StatefulWidget {
  const ShotDaySelector({
    super.key,
  });

  @override
  State<ShotDaySelector> createState() => _ShotDaySelectorState();
}

class _ShotDaySelectorState extends State<ShotDaySelector> {
  final List<String> _dayLabels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
  final List<String> _dayNames = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSelectedDays();
    });
  }

  Future<void> _loadSelectedDays() async {
    final provider = Provider.of<ShotDayTasksProvider>(context, listen: false);
    await provider.loadTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ShotDayTasksProvider>(
      builder: (context, provider, child) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: AppConstants.spacing16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(7, (index) {
              final dayOfWeek = index + 1; // 1=Monday, 7=Sunday
              final isSelected = provider.selectedDays.contains(dayOfWeek);
              final isToday = DateTime.now().weekday == dayOfWeek;
              
              return GestureDetector(
                onTap: () {
                  final newSelectedDays = List<int>.from(provider.selectedDays);
                  if (isSelected) {
                    newSelectedDays.remove(dayOfWeek);
                  } else {
                    newSelectedDays.add(dayOfWeek);
                  }
                  provider.updateSelectedDays(newSelectedDays);
                },
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isSelected 
                    ? AppColors.primary 
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(22),
                border: !isSelected
                    ? Border.all(
                        color: Colors.grey[300]!,
                        width: 1.5,
                      )
                    : null,
                boxShadow: isSelected ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ] : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _dayLabels[index],
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isSelected 
                          ? Colors.white 
                          : Colors.grey[600],
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
      },
    );
  }
}
