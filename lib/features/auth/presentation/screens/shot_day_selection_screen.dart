import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../data/auth_data.dart';
import 'birthday_input_screen.dart';

class ShotDaySelectionScreen extends StatefulWidget {
  final String frequency;
  
  const ShotDaySelectionScreen({
    super.key,
    required this.frequency,
  });

  @override
  State<ShotDaySelectionScreen> createState() => _ShotDaySelectionScreenState();
}

class _ShotDaySelectionScreenState extends State<ShotDaySelectionScreen> {
  List<int> _selectedDays = [];
  
  final List<String> _dayNames = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
  final List<String> _dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  void initState() {
    super.initState();
    _setDefaultDays();
  }

  void _setDefaultDays() {
    switch (widget.frequency) {
      case 'Every day':
        _selectedDays = [1, 2, 3, 4, 5, 6, 7]; // All days
        break;
      case 'Every 7 days (most common)':
        _selectedDays = [1]; // Monday by default
        break;
      case 'Every 14 days':
        _selectedDays = [1]; // Monday by default
        break;
      case 'Custom':
        _selectedDays = [1]; // Start with Monday
        break;
      default:
        _selectedDays = [1]; // Default to Monday
    }
  }

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
                    Text(
                      _getTitle(),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1A1F36),
                        letterSpacing: -0.5,
                        height: 1.2,
                      ),
                    ),
                    
                    const SizedBox(height: AppConstants.spacing12),
                    
                    // Subtitle
                    Text(
                      _getSubtitle(),
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF6B7280),
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                      ),
                    ),
                    
                    const SizedBox(height: AppConstants.spacing32),
                    
                    // Day Selector
                    _buildDaySelector(),
                    
                    if (widget.frequency == 'Custom') ...[
                      const SizedBox(height: AppConstants.spacing24),
                      _buildCustomInstructions(),
                    ],
                  ],
                ),
              ),
            ),
            
            // Continue Button
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppConstants.spacing24,
                AppConstants.spacing16,
                AppConstants.spacing24,
                AppConstants.spacing24,
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _canContinue() ? _onContinue : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _canContinue()
                        ? AppColors.continueButton
                        : const Color(0xFFE5E7EB),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: AppConstants.spacing12),
                    elevation: _canContinue() ? 8 : 0,
                    shadowColor: AppColors.continueButton.withOpacity(0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
                    ),
                  ),
                  child: Text(
                    'Continue',
                    style: AppTextStyles.title(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
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

  String _getTitle() {
    switch (widget.frequency) {
      case 'Every day':
        return 'All days selected!';
      case 'Every 7 days (most common)':
        return 'Which day of the week?';
      case 'Every 14 days':
        return 'Which day of the week?';
      case 'Custom':
        return 'Select your shot days';
      default:
        return 'Select shot days';
    }
  }

  String _getSubtitle() {
    switch (widget.frequency) {
      case 'Every day':
        return 'You\'ll take shots every day.';
      case 'Every 7 days (most common)':
        return 'Choose the day you\'ll take your weekly shot.';
      case 'Every 14 days':
        return 'Choose the day you\'ll take your bi-weekly shot.';
      case 'Custom':
        return 'Select which days of the week you\'ll take shots.';
      default:
        return 'Select your preferred shot days.';
    }
  }

  bool _canContinue() {
    if (widget.frequency == 'Every day') return true;
    return _selectedDays.isNotEmpty;
  }

  Widget _buildDaySelector() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.spacing24, horizontal: AppConstants.spacing16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          // Horizontal scrollable day picker
          SizedBox(
            height: 90,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 7,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final dayOfWeek = index + 1; // 1=Monday, 7=Sunday
                final isSelected = _selectedDays.contains(dayOfWeek);
                final isDisabled = widget.frequency == 'Every day';
                
                return GestureDetector(
                  onTap: isDisabled ? null : () {
                    setState(() {
                      if (isSelected) {
                        _selectedDays.remove(dayOfWeek);
                      } else {
                        if (widget.frequency == 'Every 7 days (most common)' || 
                            widget.frequency == 'Every 14 days') {
                          // Only allow one day for weekly/bi-weekly
                          _selectedDays.clear();
                        }
                        _selectedDays.add(dayOfWeek);
                      }
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    width: isSelected ? 70 : 60,
                    padding: EdgeInsets.symmetric(
                      horizontal: isSelected ? 12 : 8,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF8B5CF6) // Purple
                          : isDisabled
                              ? const Color(0xFFF5F3FF)
                              : const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(isSelected ? 20 : 16),
                      border: isSelected
                          ? null
                          : Border.all(
                              color: isDisabled
                                  ? const Color(0xFFE5E7EB)
                                  : const Color(0xFFE5E7EB),
                              width: 2,
                            ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: const Color(0xFF8B5CF6).withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Day letter
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.white
                                : isDisabled
                                    ? const Color(0xFF8B5CF6).withOpacity(0.2)
                                    : Colors.transparent,
                            shape: BoxShape.circle,
                            border: !isSelected && !isDisabled
                                ? Border.all(
                                    color: const Color(0xFFD1D5DB),
                                    width: 2,
                                  )
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              _dayLabels[index],
                              style: AppTextStyles.title(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: isSelected
                                    ? const Color(0xFF8B5CF6)
                                    : isDisabled
                                        ? const Color(0xFF8B5CF6).withOpacity(0.6)
                                        : const Color(0xFF6B7280),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        // Day name
                        Text(
                          _dayNames[index].substring(0, 3),
                          style: AppTextStyles.title(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? Colors.white
                                : isDisabled
                                    ? const Color(0xFF9CA3AF)
                                    : const Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          
          const SizedBox(height: AppConstants.spacing20),
          
          // Selected days summary
          if (_selectedDays.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F3FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: Color(0xFF8B5CF6),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Selected: ${_selectedDays.map((day) => _dayNames[day - 1]).join(', ')}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF8B5CF6),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCustomInstructions() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacing16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline,
            color: AppColors.primary,
            size: 20,
          ),
          const SizedBox(width: AppConstants.spacing12),
          Expanded(
            child: Text(
              'For custom schedules, select all the days you plan to take shots. You can always adjust this later.',
              style: AppTextStyles.title(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
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
                widthFactor: 0.6, // 60% progress
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

  void _onContinue() {
    // Save injection days to authData
    authData.injectionDays = _selectedDays.map((day) => _dayNames[day - 1]).toList();
    
    // Set default start date to today
    authData.startDate = DateTime.now();
    
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const BirthdayInputScreen()),
    );
  }
}

