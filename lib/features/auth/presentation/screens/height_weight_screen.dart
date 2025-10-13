import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../data/auth_data.dart';
import 'motivation_selection_screen.dart';

class HeightWeightScreen extends StatefulWidget {
  const HeightWeightScreen({super.key});

  @override
  State<HeightWeightScreen> createState() => _HeightWeightScreenState();
}

class _HeightWeightScreenState extends State<HeightWeightScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isImperial = true;
  
  // Store actual values in cm and kg
  double _heightCm = 180.0; // 5'11"
  double _startWeightKg = 80.0;    // Start/Current weight (same on first registration)
  double _goalWeightKg = 70.0;     // Default goal

  final _startWeightController = TextEditingController();
  final _goalWeightController = TextEditingController();

  // Imperial lists
  final List<String> _heightsImperial = [
    "5'0\"", "5'1\"", "5'2\"", "5'3\"", "5'4\"", "5'5\"", "5'6\"",
    "5'7\"", "5'8\"", "5'9\"", "5'10\"", "5'11\"", "6'0\"", "6'1\"",
    "6'2\"", "6'3\"", "6'4\"", "6'5\"", "6'6\""
  ];

  // Metric lists
  final List<String> _heightsMetric = List.generate(
    101,
    (index) => "${150 + index}cm",
  );

  @override
  void initState() {
    super.initState();
    // Initialize with default values
    _heightCm = 180.0;
    _startWeightKg = 80.0;
    _goalWeightKg = 70.0;
    _updateWeightControllers();
  }

  @override
  void dispose() {
    _startWeightController.dispose();
    _goalWeightController.dispose();
    super.dispose();
  }

  void _updateWeightControllers() {
    if (_isImperial) {
      _startWeightController.text = (_startWeightKg * 2.20462).toStringAsFixed(1);
      _goalWeightController.text = (_goalWeightKg * 2.20462).toStringAsFixed(1);
    } else {
      _startWeightController.text = _startWeightKg.toStringAsFixed(1);
      _goalWeightController.text = _goalWeightKg.toStringAsFixed(1);
    }
  }

  String get _selectedHeight {
    if (_isImperial) {
      return _convertCmToFeetInches(_heightCm);
    } else {
      return "${_heightCm.round()}cm";
    }
  }

  List<String> get _currentHeights => _isImperial ? _heightsImperial : _heightsMetric;

  @override
  Widget build(BuildContext context) {
    final weightUnit = _isImperial ? 'lbs' : 'kg';
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Progress Bar
              _buildProgressBar(),
              
              // Main Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppConstants.spacing24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      const Text(
                        'Your Height & Weight',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      
                      const SizedBox(height: AppConstants.spacing12),
                      
                      // Subtitle
                      const Text(
                        'Your current height and weight help us calculate your BMI and personalize your daily nutrition and activity goals.',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      
                      const SizedBox(height: AppConstants.spacing32),
                      
                      // Unit Toggle
                      _buildUnitToggle(),
                      
                      const SizedBox(height: AppConstants.spacing24),
                      
                      // Height Picker
                      _buildHeightPicker(),
                      
                      const SizedBox(height: AppConstants.spacing24),
                      
                      // Start Weight Field (Current weight on first registration)
                      _buildWeightField(
                        controller: _startWeightController,
                        label: 'Current Weight *',
                        unit: weightUnit,
                        hint: 'Your current weight',
                        onChanged: (value) {
                          final weight = double.tryParse(value);
                          if (weight != null) {
                            _startWeightKg = _isImperial ? weight * 0.453592 : weight;
                          }
                        },
                      ),
                      
                      const SizedBox(height: AppConstants.spacing16),
                      
                      // Goal Weight Field
                      _buildWeightField(
                        controller: _goalWeightController,
                        label: 'Goal Weight *',
                        unit: weightUnit,
                        hint: 'Your target weight',
                        onChanged: (value) {
                          final weight = double.tryParse(value);
                          if (weight != null) {
                            _goalWeightKg = _isImperial ? weight * 0.453592 : weight;
                          }
                        },
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

  Widget _buildHeightPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Height *',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppConstants.spacing12),
        Container(
          height: 200,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
            border: Border.all(color: AppColors.divider),
          ),
          child: _buildPickerColumn(
            items: _currentHeights,
            selectedItem: _selectedHeight,
            onSelected: (item) {
              setState(() {
                if (_isImperial) {
                  _heightCm = _convertFeetInchesToCm(item);
                } else {
                  _heightCm = double.parse(item.replaceAll('cm', ''));
                }
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildWeightField({
    required TextEditingController controller,
    required String label,
    required String unit,
    String? hint,
    required Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppConstants.spacing8),
        TextFormField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            hintText: hint,
            suffixText: unit,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
            ),
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spacing16,
              vertical: AppConstants.spacing16,
            ),
          ),
          onChanged: onChanged,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'This field is required';
            }
            final weight = double.tryParse(value);
            if (weight == null || weight <= 0) {
              return 'Please enter a valid weight';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPickerColumn({
    required List<String> items,
    required String selectedItem,
    required Function(String) onSelected,
  }) {
    final selectedIndex = items.indexOf(selectedItem);
    
    return ListView.builder(
      controller: ScrollController(
        initialScrollOffset: selectedIndex > 2 ? (selectedIndex - 2) * 50.0 : 0,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final isSelected = index == selectedIndex;
        final distance = (index - selectedIndex).abs();
        final opacity = distance == 0 ? 1.0 : distance == 1 ? 0.5 : 0.3;
        
        return GestureDetector(
          onTap: () => onSelected(items[index]),
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
    );
  }

  Widget _buildUnitToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'imperial',
          style: TextStyle(
            fontSize: 14,
            color: _isImperial ? AppColors.textPrimary : AppColors.textSecondary,
            fontWeight: _isImperial ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        const SizedBox(width: AppConstants.spacing12),
        GestureDetector(
          onTap: () {
            setState(() {
              _isImperial = !_isImperial;
              _updateWeightControllers();
            });
          },
          child: Container(
            width: 50,
            height: 30,
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(15),
            ),
            child: AnimatedAlign(
              duration: const Duration(milliseconds: 200),
              alignment: _isImperial ? Alignment.centerLeft : Alignment.centerRight,
              child: Container(
                width: 26,
                height: 26,
                margin: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: _isImperial ? Colors.black : Colors.white,
                  borderRadius: BorderRadius.circular(13),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppConstants.spacing12),
        Text(
          'metric',
          style: TextStyle(
            fontSize: 14,
            color: !_isImperial ? AppColors.textPrimary : AppColors.textSecondary,
            fontWeight: !_isImperial ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  // Convert feet/inches string to cm
  double _convertFeetInchesToCm(String feetInches) {
    final parts = feetInches.split("'");
    final feet = int.parse(parts[0]);
    final inches = int.parse(parts[1].replaceAll('"', ''));
    final totalInches = feet * 12 + inches;
    return totalInches * 2.54;
  }

  // Convert cm to feet/inches string
  String _convertCmToFeetInches(double cm) {
    final totalInches = cm / 2.54;
    final feet = totalInches ~/ 12;
    final inches = (totalInches % 12).round();
    return "$feet'$inches\"";
  }

  void _onContinue() {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Save to authData (always in cm and kg for backend)
    authData.height = _heightCm;
    authData.weight = _startWeightKg; // Use start weight as the profile weight
    authData.heightUnit = _isImperial ? 'ft' : 'cm';
    authData.weightUnit = _isImperial ? 'lbs' : 'kg';
    
    // Save goal weight
    authData.targetWeight = _goalWeightKg;
    
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MotivationSelectionScreen()),
    );
  }
}
