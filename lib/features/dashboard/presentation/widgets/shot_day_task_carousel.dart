import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/api/api_client.dart';

class ShotDayTaskCarousel extends StatefulWidget {
  final DateTime selectedDate;
  
  const ShotDayTaskCarousel({
    super.key,
    required this.selectedDate,
  });

  @override
  State<ShotDayTaskCarousel> createState() => _ShotDayTaskCarouselState();
}

class _ShotDayTaskCarouselState extends State<ShotDayTaskCarousel> {
  int _currentIndex = 0;
  bool _isExpanded = true;
  bool _isLoading = false;
  final PageController _pageController = PageController();
  final ApiClient _apiClient = ApiClient();

  List<Map<String, dynamic>> _tasks = [
    {'title': 'High-Protein Meal/Drink', 'time': '7:00 PM', 'completed': false},
    {'title': 'Drink lots of Water (+electrolytes)', 'time': '7:00 PM', 'completed': false},
    {'title': 'Load Syringe and let come to room temp', 'time': '7:15 PM', 'completed': false},
    {'title': 'Take Shot', 'time': '8:00 PM', 'completed': false, 'isMainTask': true},
    {'title': 'Another High Protein Meal/Drink', 'time': '9:00 PM', 'completed': false},
  ];

  @override
  void initState() {
    super.initState();
    _loadTaskStates();
  }

  @override
  void didUpdateWidget(ShotDayTaskCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedDate != widget.selectedDate) {
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
          _tasks = tasks.map((task) => Map<String, dynamic>.from(task)).toList();
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
          'tasks': _tasks,
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

  TextStyle _montserrat({
    required double fontSize,
    FontWeight fontWeight = FontWeight.w400,
    Color color = Colors.black,
  }) {
    return GoogleFonts.montserrat(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 5, left: 5, right: 5),
      decoration: BoxDecoration(
        color: Color(0xffeae3fb),
        borderRadius: BorderRadius.circular(20),
      ),
      child: _isExpanded ? _buildExpandedView() : _buildCollapsedView(),
    );
  }

  Widget _buildCollapsedView() {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Color(0xffffffff),
          ),
          child: Column(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.07,
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  itemCount: _tasks.length,
                  itemBuilder: (context, index) {
                    final task = _tasks[index];
                    return InkWell(
                      onTap: () {
                        setState(() {
                          _tasks[index]['completed'] = !_tasks[index]['completed'];
                        });
                        _saveTaskStates(); // Save to database
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        // margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            _buildCircleOutline(index),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    task['title'] as String,
                                    style: _montserrat(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                      color: task['completed'] == true ? Colors.grey : Colors.black,
                                    ).copyWith(
                                      decoration: task['completed'] == true 
                                          ? TextDecoration.lineThrough 
                                          : TextDecoration.none,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    task['time'] as String,
                                    style: _montserrat(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                      color: task['isMainTask'] == true 
                                          ? const Color(0xFF8B5CF6) 
                                          : const Color(0xFF6B7280),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // _buildCircleOutline(),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Pagination Dots (5 dots)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_tasks.length, (index) {
                    return GestureDetector(
                      onTap: () {
                        _pageController.animateToPage(
                          index,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: Container(
                        width: 7,
                        height: 7,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: index == _currentIndex
                              ? const Color(0xFF8B5CF6)
                              : Colors.grey[300],
                          shape: BoxShape.circle,
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),

        // const SizedBox(height: 10),

        // Shot Day Button
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () {
              setState(() {
                _isExpanded = true;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color:  Color(0xff6745bf), // Purple
                borderRadius: BorderRadius.circular(14), // More rounded
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Shot Day',
                    style: _montserrat(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.white,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExpandedView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [

        // Tasks List in white card
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: List.generate(_tasks.length, (index) {
              final task = _tasks[index];
              return InkWell(
                onTap: () {
                  setState(() {
                    _tasks[index]['completed'] = !_tasks[index]['completed'];
                  });
                  _saveTaskStates(); // Save to database
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  child: Row(
                    children: [
                      // Toggleable checkbox
                      /*Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _taskChecked[index] 
                              ? const Color(0xFF8B5CF6)
                              : Colors.white,
                          border: Border.all(
                            color: const Color(0xFF8B5CF6),
                            width: 2.5,
                          ),
                        ),
                        child: _taskChecked[index]
                            ? const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 18,
                              )
                            : null,
                      ),*/

                      _buildCircleOutline(index),
                      const SizedBox(width: 14),
                      // Task text
                      Expanded(
                        child: Text(
                          task['title'] as String,
                          style: _montserrat(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: task['completed'] == true ? Colors.grey : Colors.black,
                          ).copyWith(
                            decoration: task['completed'] == true 
                                ? TextDecoration.lineThrough 
                                : TextDecoration.none,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Time
                      Text(
                        task['time'] as String,
                        style: _montserrat(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: task['isMainTask'] == true 
                              ? const Color(0xFF8B5CF6) 
                              : const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),

        // const SizedBox(height: 3),

        // Shot Day Button (Collapse)
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () {
              setState(() {
                _isExpanded = false;
              });
            },
            child:  Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color:  Color(0xff6745bf), // Purple
                borderRadius: BorderRadius.circular(14), // More rounded
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Shot Day',
                    style: _montserrat(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.keyboard_arrow_up,
                    color: Colors.white,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCircleOutline(int index) {
    final task = _tasks[index];
    final isCompleted = task['completed'] == true;
    
    return DottedBorder(
      options: CircularDottedBorderOptions(
        dashPattern: [10, 2],
        strokeWidth: 2,
        color: isCompleted ? AppColors.primary : AppColors.primary,
        // padding: EdgeInsets.all(4),
      ),
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isCompleted ? AppColors.primary : AppColors.primarylight,
          border: Border.all(
            color: isCompleted ? const Color(0xFF8B5CF6) : Colors.white,
            // width: 2.5,
          ),
        ),
        child: isCompleted
            ? const Center(
                child: Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 18,
                ),
              )
            : null,
      ),
    );
  }
}
