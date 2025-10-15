import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/providers/health_provider.dart';
import '../../../../core/api/models/weight_log_model.dart';

class WeightLoggingScreen extends StatefulWidget {
  const WeightLoggingScreen({super.key});

  @override
  State<WeightLoggingScreen> createState() => _WeightLoggingScreenState();
}

class _WeightLoggingScreenState extends State<WeightLoggingScreen> {
  double _currentWeight = 143.3;
  bool _isMetric = true;
  DateTime _selectedDate = DateTime.now();
  bool _isSaving = false;

  // Weight ranges
  static const double _minWeightKg = 40.0;
  static const double _maxWeightKg = 200.0;
  static const double _minWeightLbs = 88.0;
  static const double _maxWeightLbs = 440.0;

  double get _minWeight => _isMetric ? _minWeightKg : _minWeightLbs;
  double get _maxWeight => _isMetric ? _maxWeightKg : _maxWeightLbs;

  String get _weightUnit => _isMetric ? 'kg' : 'lbs';
  String get _formattedWeight => _currentWeight.toStringAsFixed(1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),
            
            // Date Selector
            _buildDateSelector(),
            
            // Main Content
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Current Weight Display
                  _buildCurrentWeightDisplay(),
                  
                  const SizedBox(height: AppConstants.spacing32),
                  
                  // Weight Ruler
                  _buildWeightRuler(),
                  
                  const SizedBox(height: AppConstants.spacing32),
                  
                  // Unit Toggle
                  _buildUnitToggle(),
                  
                  const SizedBox(height: AppConstants.spacing48),
                ],
              ),
            ),
            
            // Log Weight Button
            _buildLogButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.spacing16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(
              Icons.arrow_back,
              color: AppColors.textPrimary,
              size: 24,
            ),
          ),
          const SizedBox(width: AppConstants.spacing16),
          const Text(
            'Weight Log',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.spacing16),
      padding: const EdgeInsets.all(AppConstants.spacing16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.calendar_today,
            color: AppColors.primary,
            size: 20,
          ),
          const SizedBox(width: AppConstants.spacing12),
          const Text(
            'Date',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: _selectDate,
            child: Text(
              _formatDate(_selectedDate),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: AppConstants.spacing8),
          const Icon(
            Icons.chevron_right,
            color: AppColors.textSecondary,
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentWeightDisplay() {
    return Column(
      children: [
        const Text(
          'Current Weight',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppConstants.spacing8),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: _formattedWeight,
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              TextSpan(
                text: ' $_weightUnit',
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWeightRuler() {
    final double range = _maxWeight - _minWeight;
    final double normalizedWeight = (_currentWeight - _minWeight) / range;
    
    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        setState(() {
          // Calculate the available width for the slider
          final double availableWidth = MediaQuery.of(context).size.width - 48;
          
          // Get current position as normalized value (0-1)
          double currentPosition = normalizedWeight * availableWidth;
          
          // Add the drag delta
          currentPosition += details.delta.dx;
          
          // Convert back to normalized position (0-1)
          double newNormalized = (currentPosition / availableWidth).clamp(0.0, 1.0);
          
          // Convert to actual weight
          _currentWeight = _minWeight + (range * newNormalized);
          
          // Round to 1 decimal place for smoother updates
          _currentWeight = ((_currentWeight * 10).round() / 10).clamp(_minWeight, _maxWeight);
        });
      },
      onTapDown: (details) {
        setState(() {
          // Allow tapping anywhere on the ruler to set weight
          final double availableWidth = MediaQuery.of(context).size.width - 48;
          final double localX = details.localPosition.dx - 24; // Account for margin
          
          double newNormalized = (localX / availableWidth).clamp(0.0, 1.0);
          _currentWeight = _minWeight + (range * newNormalized);
          _currentWeight = ((_currentWeight * 10).round() / 10).clamp(_minWeight, _maxWeight);
        });
      },
      child: Container(
        height: 100,
        margin: const EdgeInsets.symmetric(horizontal: AppConstants.spacing24),
        color: Colors.transparent, // Makes entire area tappable
        child: Stack(
          children: [
            // Ruler Background
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            
            // Weight Indicator Line
            Positioned(
              left: normalizedWeight * (MediaQuery.of(context).size.width - 48),
              top: 0,
              child: Column(
                children: [
                  Container(
                    width: 2,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.spacing8,
                      vertical: AppConstants.spacing4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                    ),
                    child: Text(
                      '$_formattedWeight $_weightUnit',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Ruler Marks
            ...List.generate(5, (index) {
              final double position = index / 4;
              final double weight = _minWeight + (range * position);
              return Positioned(
                left: position * (MediaQuery.of(context).size.width - 48),
                bottom: 0,
                child: Column(
                  children: [
                    Container(
                      width: 2,
                      height: 20,
                      decoration: BoxDecoration(
                        color: AppColors.textSecondary,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacing4),
                    Text(
                      weight.toStringAsFixed(0),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildUnitToggle() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.spacing24),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => _toggleUnit(false),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: AppConstants.spacing12),
                decoration: BoxDecoration(
                  color: !_isMetric ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                ),
                child: Text(
                  'Imperial',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: !_isMetric ? Colors.white : AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => _toggleUnit(true),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: AppConstants.spacing12),
                decoration: BoxDecoration(
                  color: _isMetric ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                ),
                child: Text(
                  'Metric',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _isMetric ? Colors.white : AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogButton() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(AppConstants.spacing16),
      child: ElevatedButton(
        onPressed: _isSaving ? null : _logWeight,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(vertical: AppConstants.spacing16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          ),
        ),
        child: _isSaving
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                'Log Weight',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  void _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1970), // Allow historical data entry from 1970
      lastDate: DateTime.now(),
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _toggleUnit(bool isMetric) {
    if (_isMetric == isMetric) return;
    
    setState(() {
      _isMetric = isMetric;
      
      // Convert weight between units
      if (isMetric) {
        // Convert from lbs to kg
        _currentWeight = _currentWeight * 0.453592;
      } else {
        // Convert from kg to lbs
        _currentWeight = _currentWeight * 2.20462;
      }
      
      // Clamp to valid range
      _currentWeight = _currentWeight.clamp(_minWeight, _maxWeight);
    });
  }

  Future<void> _logWeight() async {
    if (_isSaving) return;

    setState(() {
      _isSaving = true;
    });

    final request = WeightLogRequest(
      date: _selectedDate,
      weight: _currentWeight,
      unit: _weightUnit,
    );

    final provider = context.read<HealthProvider>();
    final success = await provider.logWeight(request);

    setState(() {
      _isSaving = false;
    });

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Weight logged: $_formattedWeight $_weightUnit'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage ?? 'Failed to log weight'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  String _formatDate(DateTime date) {
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    
    final weekday = weekdays[date.weekday - 1];
    final month = months[date.month - 1];
    final day = date.day;
    final hour = date.hour;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    
    return '$weekday, $day $month, $displayHour:$minute $period';
  }
}