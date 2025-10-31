import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/api/api_client.dart';

class ShotDayWidget extends StatefulWidget {
  final DateTime selectedDate; // The date selected in the dashboard header
  
  const ShotDayWidget({
    super.key,
    required this.selectedDate,
  });

  @override
  State<ShotDayWidget> createState() => _ShotDayWidgetState();
}

class _ShotDayWidgetState extends State<ShotDayWidget> {
  bool _isExpanded = true;
  bool _isLoading = false;
  
  List<Map<String, dynamic>> _shotDayTasks = [
    {
      'title': 'High-Protein Meal/Drink',
      'time': '7:00 PM',
      'completed': false,
    },
    {
      'title': 'Drink lots of Water (+electrolytes)',
      'time': '7:00 PM',
      'completed': false,
    },
    {
      'title': 'Load Syringe and let come to room temp',
      'time': '7:15 PM',
      'completed': false,
    },
    {
      'title': 'Take Shot',
      'time': '8:00 PM',
      'completed': false,
      'isMainTask': true,
    },
    {
      'title': 'Another High Protein Meal/Drink',
      'time': '9:00 PM',
      'completed': false,
    },
  ];

  final ApiClient _apiClient = ApiClient();

  @override
  void initState() {
    super.initState();
    _loadTaskStates();
  }


  @override
  void didUpdateWidget(ShotDayWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    print('didUpdateWidget called - Old date: ${oldWidget.selectedDate.toIso8601String().split('T')[0]}, New date: ${widget.selectedDate.toIso8601String().split('T')[0]}');
    if (oldWidget.selectedDate != widget.selectedDate) {
      print('Date changed, reloading tasks...');
      _loadTaskStates(); // Reload tasks when date changes
    }
  }

  Future<void> _loadTaskStates() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final dateString = widget.selectedDate.toIso8601String().split('T')[0];
      print('Loading tasks for date: $dateString');
      
      final response = await _apiClient.get(
        '/api/shot-day-tasks',
        queryParameters: {'date': dateString},
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final tasks = response.data['data']['tasks'] as List<dynamic>;
        print('Found saved tasks for this date: ${tasks.length} tasks');
        setState(() {
          _shotDayTasks = tasks.map((task) => Map<String, dynamic>.from(task)).toList();
        });
      } else {
        print('No saved tasks for this date, using default state');
        // Keep the default tasks as they are
      }
    } catch (e) {
      print('Error loading task states: $e');
      // Keep the default tasks on error
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveTaskStates() async {
    try {
      final dateString = widget.selectedDate.toIso8601String().split('T')[0];
      print('Saving tasks for date: $dateString');
      
      final response = await _apiClient.put(
        '/api/shot-day-tasks',
        data: {
          'date': dateString,
          'tasks': _shotDayTasks,
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        print('Tasks saved successfully to database');
      } else {
        print('Failed to save tasks: ${response.data['message']}');
      }
    } catch (e) {
      print('Error saving task states: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.user;
        if (user == null) return const SizedBox.shrink();
        
        // Get shot days from user's injection days
        final injectionDays = user.glp1Journey.injectionDays ?? [];
        if (injectionDays.isEmpty) return const SizedBox.shrink();
        
        // Convert day names to weekday numbers (1=Monday, 7=Sunday)
        final shotDays = <int>[];
        for (final dayName in injectionDays) {
          switch (dayName.toLowerCase()) {
            case 'monday':
              shotDays.add(1);
              break;
            case 'tuesday':
              shotDays.add(2);
              break;
            case 'wednesday':
              shotDays.add(3);
              break;
            case 'thursday':
              shotDays.add(4);
              break;
            case 'friday':
              shotDays.add(5);
              break;
            case 'saturday':
              shotDays.add(6);
              break;
            case 'sunday':
              shotDays.add(7);
              break;
          }
        }
        
        // Check if the selected date is a shot day
        final selectedWeekday = widget.selectedDate.weekday; // 1=Monday, 7=Sunday
        
        if (!shotDays.contains(selectedWeekday)) {
          return const SizedBox.shrink(); // Don't show if not a shot day
        }

    return Container(
      // margin: const EdgeInsets.symmetric(horizontal: AppConstants.spacing16),
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
                  child: Text(
                    'Shot Day',
                    style: const TextStyle(
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
                      onTap: () async {
                        setState(() {
                          for (var task in _shotDayTasks) {
                            task['completed'] = false;
                          }
                        });
                        await _saveTaskStates(); // Save state after reset
                      },
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
                children: _shotDayTasks.asMap().entries.map((entry) {
                  return _buildTaskItem(entry.value, entry.key);
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

  Widget _buildTaskItem(Map<String, dynamic> task, int index) {
    final isMainTask = task['isMainTask'] == true;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _shotDayTasks[index]['completed'] = !_shotDayTasks[index]['completed'];
        });
        _saveTaskStates(); // Save state after each toggle
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

