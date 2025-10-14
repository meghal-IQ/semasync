import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../data/auth_data.dart';
import 'height_weight_screen.dart';

class BirthdayInputScreen extends StatefulWidget {
  const BirthdayInputScreen({super.key});

  @override
  State<BirthdayInputScreen> createState() => _BirthdayInputScreenState();
}

class _BirthdayInputScreenState extends State<BirthdayInputScreen> {
  DateTime _selectedDate = DateTime(1990, 1, 1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Progress Bar
            _buildProgressBar(),
            
            // Main Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.spacing24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    const Text(
                      'When\'s your birthday?',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    
                    const SizedBox(height: AppConstants.spacing12),
                    
                    // Subtitle
                    const Text(
                      'Your age helps us fine-tune your nutrition goals to keep them accurate and realistic.',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    
                    const SizedBox(height: AppConstants.spacing48),
                    
                    // Date Picker
                    Expanded(
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Month
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildDatePickerColumn(
                                    items: _getMonths(),
                                    selectedIndex: _selectedDate.month - 1,
                                    onSelected: (index) {
                                      setState(() {
                                        _selectedDate = DateTime(
                                          _selectedDate.year,
                                          index + 1,
                                          _selectedDate.day,
                                        );
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                            
                            // Day
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildDatePickerColumn(
                                    items: _getDays(),
                                    selectedIndex: _getValidDayIndex(),
                                    onSelected: (index) {
                                      setState(() {
                                        final newDay = index + 1;
                                        final daysInMonth = DateTime(_selectedDate.year, _selectedDate.month + 1, 0).day;
                                        final validDay = newDay <= daysInMonth ? newDay : daysInMonth;
                                        _selectedDate = DateTime(
                                          _selectedDate.year,
                                          _selectedDate.month,
                                          validDay,
                                        );
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                            
                            // Year
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildDatePickerColumn(
                                    items: _getYears(),
                                    selectedIndex: _getYearIndex(_selectedDate.year),
                                    onSelected: (index) {
                                      setState(() {
                                        _selectedDate = DateTime(
                                          _getYearFromIndex(index),
                                          _selectedDate.month,
                                          _selectedDate.day,
                                        );
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Continue Button
            Padding(
              padding: const EdgeInsets.all(AppConstants.spacing24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _onContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: AppConstants.spacing16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                    ),
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.spacing16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          ),
          Expanded(
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: 0.5, // 50% progress
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePickerColumn({
    required List<String> items,
    required int selectedIndex,
    required Function(int) onSelected,
  }) {
    return Container(
      height: 200,
      child: ListView.builder(
        controller: ScrollController(
          initialScrollOffset: (selectedIndex - 2) * 50.0,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final isSelected = index == selectedIndex;
          final distance = (index - selectedIndex).abs();
          final opacity = distance == 0 ? 1.0 : distance == 1 ? 0.5 : 0.3;
          
          return GestureDetector(
            onTap: () => onSelected(index),
            child: Container(
              height: 50,
              child: Center(
                child: Text(
                  items[index],
                  style: TextStyle(
                    fontSize: isSelected ? 18 : 16,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: AppColors.textPrimary.withOpacity(opacity),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  List<String> _getMonths() {
    return [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
  }

  List<String> _getDays() {
    // Get the number of days in the selected month and year
    final daysInMonth = DateTime(_selectedDate.year, _selectedDate.month + 1, 0).day;
    return List.generate(daysInMonth, (index) => '${index + 1}');
  }

  List<String> _getYears() {
    final currentYear = DateTime.now().year;
    final startYear = currentYear - 100; // Allow up to 100 years old
    final endYear = currentYear - 13; // Minimum age of 13
    return List.generate(endYear - startYear + 1, (index) => '${startYear + index}');
  }

  int _getYearIndex(int year) {
    final currentYear = DateTime.now().year;
    final startYear = currentYear - 100;
    return year - startYear;
  }

  int _getYearFromIndex(int index) {
    final currentYear = DateTime.now().year;
    final startYear = currentYear - 100;
    return startYear + index;
  }

  int _getValidDayIndex() {
    final daysInMonth = DateTime(_selectedDate.year, _selectedDate.month + 1, 0).day;
    final validDay = _selectedDate.day <= daysInMonth ? _selectedDate.day : daysInMonth;
    return validDay - 1;
  }

  void _onContinue() {
    // Save date of birth to authData
    authData.dateOfBirth = _selectedDate;
    
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const HeightWeightScreen()),
    );
  }
}
