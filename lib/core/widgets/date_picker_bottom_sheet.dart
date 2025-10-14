import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';

class DatePickerBottomSheet extends StatefulWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;

  const DatePickerBottomSheet({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  State<DatePickerBottomSheet> createState() => _DatePickerBottomSheetState();
}

class _DatePickerBottomSheetState extends State<DatePickerBottomSheet> {
  late DateTime _selectedDate;
  late DateTime _currentMonth;
  late PageController _pageController;
  late int _currentPage;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.selectedDate;
    _currentMonth = DateTime(_selectedDate.year, _selectedDate.month);
    _currentPage = _getPageForMonth(_currentMonth);
    _pageController = PageController(initialPage: _currentPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  int _getPageForMonth(DateTime month) {
    final now = DateTime.now();
    final monthsDifference = (now.year - month.year) * 12 + (now.month - month.month);
    return monthsDifference;
  }

  DateTime _getMonthForPage(int page) {
    final now = DateTime.now();
    final targetMonth = now.month - page;
    final targetYear = now.year + (targetMonth <= 0 ? -1 : 0);
    final adjustedMonth = targetMonth <= 0 ? targetMonth + 12 : targetMonth;
    return DateTime(targetYear, adjustedMonth);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const Text(
                  'Select Date',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    final today = DateTime.now();
                    setState(() {
                      _selectedDate = today;
                      _currentMonth = DateTime(today.year, today.month);
                      _currentPage = 0;
                    });
                    _pageController.animateToPage(
                      0,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: const Text(
                    'Today',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Calendar
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (page) {
                setState(() {
                  _currentPage = page;
                  _currentMonth = _getMonthForPage(page);
                });
              },
              itemBuilder: (context, page) {
                final month = _getMonthForPage(page);
                return _buildCalendarMonth(month);
              },
            ),
          ),
          
          // Month navigation
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                IconButton(
                  onPressed: () {
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  icon: const Icon(Icons.chevron_left),
                ),
                Expanded(
                  child: Text(
                    _formatMonth(_currentMonth),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
          ),
          
          // Action buttons
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: AppColors.divider),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onDateSelected(_selectedDate);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Select',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarMonth(DateTime month) {
    final firstDayOfMonth = DateTime(month.year, month.month, 1);
    final lastDayOfMonth = DateTime(month.year, month.month + 1, 0);
    final firstDayWeekday = firstDayOfMonth.weekday;
    final daysInMonth = lastDayOfMonth.day;
    
    // Calculate days from previous month to fill the first week
    final previousMonth = DateTime(month.year, month.month - 1);
    final daysInPreviousMonth = DateTime(previousMonth.year, previousMonth.month + 1, 0).day;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Day headers
          Row(
            children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                .map((day) => Expanded(
                      child: Center(
                        child: Text(
                          day,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
          
          const SizedBox(height: 8),
          
          // Calendar grid
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 1,
              ),
              itemCount: 42, // 6 weeks * 7 days
              itemBuilder: (context, index) {
                final dayOfWeek = index % 7;
                final week = index ~/ 7;
                final dayIndex = week * 7 + dayOfWeek - firstDayWeekday + 1;
                
                DateTime? dayDate;
                bool isCurrentMonth = false;
                bool isPreviousMonth = false;
                bool isNextMonth = false;
                
                if (dayIndex <= 0) {
                  // Previous month
                  dayDate = DateTime(previousMonth.year, previousMonth.month, daysInPreviousMonth + dayIndex);
                  isPreviousMonth = true;
                } else if (dayIndex > daysInMonth) {
                  // Next month
                  dayDate = DateTime(month.year, month.month + 1, dayIndex - daysInMonth);
                  isNextMonth = true;
                } else {
                  // Current month
                  dayDate = DateTime(month.year, month.month, dayIndex);
                  isCurrentMonth = true;
                }
                
                if (dayDate == null) return const SizedBox();
                
                final isSelected = _isSameDay(dayDate, _selectedDate);
                final isToday = _isSameDay(dayDate, DateTime.now());
                final isPast = dayDate.isBefore(DateTime.now().subtract(const Duration(days: 1)));
                
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedDate = dayDate!;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? AppColors.primary 
                          : isToday 
                              ? AppColors.primary.withOpacity(0.1)
                              : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: isToday && !isSelected
                          ? Border.all(color: AppColors.primary, width: 1)
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        '${dayDate.day}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.normal,
                          color: isSelected 
                              ? Colors.white
                              : isToday 
                                  ? AppColors.primary
                                  : isCurrentMonth 
                                      ? AppColors.textPrimary
                                      : AppColors.textSecondary.withOpacity(0.5),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _formatMonth(DateTime month) {
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[month.month - 1]} ${month.year}';
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && 
           date1.month == date2.month && 
           date1.day == date2.day;
  }
}