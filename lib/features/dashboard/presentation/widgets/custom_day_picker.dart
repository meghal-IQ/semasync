import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:semasync_new/core/theme/app_colors.dart';

class CustomDayPicker extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onDaySelected;

  const CustomDayPicker({
    super.key,
    required this.selectedIndex,
    required this.onDaySelected,
  });

  @override
  State<CustomDayPicker> createState() => _CustomDayPickerState();
}

class _CustomDayPickerState extends State<CustomDayPicker> {
  late ScrollController _scrollController;
  bool _hasScrolledToInitial = false;
  
  // Calculate today's index: -60 to +60 means today (offset 0) is at index 60
  int get _todayIndex => 60;
  
  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }
  
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Scroll to selected index after first frame
    if (!_hasScrolledToInitial) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Wait for ScrollController to be attached
        if (_scrollController.hasClients) {
          _scrollToIndex(widget.selectedIndex);
          _hasScrolledToInitial = true;
        } else {
          // Retry after a short delay if controller isn't ready
          Future.delayed(const Duration(milliseconds: 100), () {
            if (mounted && _scrollController.hasClients && !_hasScrolledToInitial) {
              _scrollToIndex(widget.selectedIndex);
              _hasScrolledToInitial = true;
            }
          });
        }
      });
    }
  }
  
  @override
  void didUpdateWidget(CustomDayPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Scroll to new selected index if it changed
    if (oldWidget.selectedIndex != widget.selectedIndex && _scrollController.hasClients) {
      _scrollToIndex(widget.selectedIndex);
    }
  }
  
  void _scrollToIndex(int index) {
    if (!_scrollController.hasClients) return;
    
    // Calculate the position to scroll to
    // Each unselected item is 40px wide, separator is 10px
    // So position for index i = i * (40 + 10) = i * 50
    const unselectedItemWidth = 40.0;
    const separatorWidth = 10.0;
    const itemSpacing = unselectedItemWidth + separatorWidth;
    
    // For selected items, they have horizontal padding (8px each side) but we'll use 
    // the same spacing for calculation consistency
    final targetOffset = index * itemSpacing;
    
    // Center the selected item in the viewport
    final screenWidth = MediaQuery.of(context).size.width;
    final centeredOffset = targetOffset - (screenWidth / 2) + (itemSpacing / 2);
    
    // Wait a frame to ensure the ListView has laid out
    Future.microtask(() {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          centeredOffset.clamp(0.0, _scrollController.position.maxScrollExtent),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
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
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final List<DateTime> dates = [];
    final List<String> dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    
    // Generate dates: 2 months ago (~60 days) to 2 months ahead (~60 days)
    // Approximately 120 days total
    final daysBack = 60; // ~2 months
    final daysAhead = 60; // ~2 months
    for (int i = -daysBack; i <= daysAhead; i++) {
      dates.add(now.add(Duration(days: i)));
    }
    
    return SizedBox(
      height: 65,
      child: ListView.separated(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: dates.length,
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final date = dates[index];
          final dayOfWeek = dayLabels[date.weekday - 1];
          final dayNumber = date.day;
          final isSelected = index == widget.selectedIndex;
          
          final isToday = date.year == now.year &&
                          date.month == now.month &&
                          date.day == now.day;
          
          if (isSelected) {
            // Purple pill-shaped container with checkmark
            return GestureDetector(
              onTap: () => widget.onDaySelected(index),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 33,
                      height: 33,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xff8866e0),
                        border: Border.all(
                          color: Colors.white,
                          width: 2.5,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      dayOfWeek,
                      style: _montserrat(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else {
            // Unselected white circle with gray text
            return GestureDetector(
              onTap: () => widget.onDaySelected(index),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isToday 
                          ? const Color(0xFFF5F3FF) // Light purple for today
                          : Color(0xfff4f4f4), // Light purple
                    ),
                    child: DottedBorder(
                      options: CircularDottedBorderOptions(
                        dashPattern: [10, 4],
                        strokeWidth: 1,
                        color: AppColors.customGrey,
                        padding: EdgeInsets.all(4),
                      ),
                      child: Center(
                        child: Text(
                          '',
                          style: _montserrat(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isToday 
                                ? const Color(0xFF8B5CF6) // Purple for today
                                : const Color(0xFF6B7280), // Gray
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    dayOfWeek,
                    style: _montserrat(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isToday 
                          ? const Color(0xFF8B5CF6) // Purple for today
                          : const Color(0xFF6B7280), // Gray
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
}
