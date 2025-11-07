import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_text_styles.dart';
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
                      Text(
                        'Your Height & Weight',
                        style: AppTextStyles.title(
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1F36),
                          letterSpacing: -0.5,
                          height: 1.2,
                        ),
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Subtitle
                      Text(
                        'Your current height and weight help us calculate your BMI and personalize your daily nutrition and activity goals.',
                        style: AppTextStyles.title(
                          fontSize: 15,
                          color: Color(0xFF6B7280),
                          fontWeight: FontWeight.w400,
                          height: 1.4,
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Unit Toggle
                      _buildUnitToggle(),
                      
                      const SizedBox(height: 32),
                      
                      // Height Picker
                      _buildHeightPicker(),
                      
                      const SizedBox(height: 24),
                      
                      // Start Weight Field (Current weight on first registration)
                      _buildWeightField(
                        controller: _startWeightController,
                        label: 'Current Weight',
                        unit: weightUnit,
                        hint: 'Enter weight',
                        onChanged: (value) {
                          final weight = double.tryParse(value);
                          if (weight != null) {
                            _startWeightKg = _isImperial ? weight * 0.453592 : weight;
                          }
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Goal Weight Field
                      _buildWeightField(
                        controller: _goalWeightController,
                        label: 'Goal Weight',
                        unit: weightUnit,
                        hint: 'Enter goal weight',
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
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _onContinue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.continueButton,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      'Continue',
                      style: AppTextStyles.title(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
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
        Text(
          'Height',
          style: AppTextStyles.title(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1F36),
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 180,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFE5E7EB),
              width: 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
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
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1F36),
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFF1A1F36),
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              color: Color(0xFF9CA3AF),
              fontWeight: FontWeight.w400,
            ),
            suffixText: unit,
            suffixStyle: const TextStyle(
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w500,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFE5E7EB),
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFE5E7EB),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF8B5CF6),
                width: 2,
              ),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 18,
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
    final scrollController = ScrollController(
      initialScrollOffset: selectedIndex > 2 ? (selectedIndex - 2) * 60.0 : 0,
    );
    
    return ListView.builder(
      controller: scrollController,
      itemCount: items.length,
      itemBuilder: (context, index) {
        final isSelected = index == selectedIndex;
        final distance = (index - selectedIndex).abs();
        final opacity = distance == 0 ? 1.0 : distance == 1 ? 0.4 : distance == 2 ? 0.2 : 0.1;
        
        return GestureDetector(
          onTap: () => onSelected(items[index]),
          child: Container(
            height: 60,
            child: Center(
              child: Text(
                items[index],
                style: AppTextStyles.title(
                  fontSize: isSelected ? 20 : 16,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? const Color(0xFF1A1F36)
                      : const Color(0xFF6B7280).withOpacity(opacity),
                  letterSpacing: -0.3,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildUnitToggle() {
    return Center(
      child: Container(
        width: 200,
        height: 36,
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              left: _isImperial ? 4 : 100,
              top: 4,
              child: Container(
                width: 96,
                height: 28,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if (!_isImperial) {
                        setState(() {
                          _isImperial = true;
                          _updateWeightControllers();
                        });
                      }
                    },
                    child: Center(
                      child: Text(
                        'Imperial',
                        style: AppTextStyles.title(
                          fontSize: 14,
                          fontWeight: _isImperial ? FontWeight.w600 : FontWeight.w400,
                          color: _isImperial ? const Color(0xFF1A1F36) : const Color(0xFF9CA3AF),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if (_isImperial) {
                        setState(() {
                          _isImperial = false;
                          _updateWeightControllers();
                        });
                      }
                    },
                    child: Center(
                      child: Text(
                        'Metric',
                        style: AppTextStyles.title(
                          fontSize: 14,
                          fontWeight: !_isImperial ? FontWeight.w600 : FontWeight.w400,
                          color: !_isImperial ? const Color(0xFF1A1F36) : const Color(0xFF9CA3AF),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
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
