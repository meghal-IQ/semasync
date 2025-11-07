import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:semasync_new/core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../treatment/presentation/providers/medication_level_provider.dart';
import '../../../../core/providers/auth_provider.dart';

class MedicationLevelCard extends StatefulWidget {
  final DateTime? selectedDate;
  
  const MedicationLevelCard({super.key, this.selectedDate});

  @override
  State<MedicationLevelCard> createState() => _MedicationLevelCardState();
}

class _MedicationLevelCardState extends State<MedicationLevelCard> {
  DateTime? _lastLoadedDate;

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
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadMedicationLevel();
  }

  @override
  void didUpdateWidget(MedicationLevelCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedDate != widget.selectedDate) {
      _loadMedicationLevel();
    }
  }

  void _loadMedicationLevel() {
    final selectedDate = widget.selectedDate ?? DateTime.now();
    final now = DateTime.now();
    final isToday = selectedDate.year == now.year &&
                    selectedDate.month == now.month &&
                    selectedDate.day == now.day;
    
    // Only load if date changed or hasn't loaded yet
    if (_lastLoadedDate == null || 
        _lastLoadedDate!.year != selectedDate.year ||
        _lastLoadedDate!.month != selectedDate.month ||
        _lastLoadedDate!.day != selectedDate.day) {
      _lastLoadedDate = selectedDate;
      
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          final provider = Provider.of<MedicationLevelProvider>(context, listen: false);
          if (isToday) {
            provider.loadCurrentMedicationLevel();
          } else {
            provider.loadMedicationLevelForDate(selectedDate);
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<MedicationLevelProvider, AuthProvider>(
      builder: (context, provider, authProvider, _) {
        final percentage = provider.currentLevelPercentage; // 0-100
        final nextDose = provider.countdownString; // e.g., "6d 5h"
        final isLoading = provider.isLoading;
        // Get medication name from user's registration data, fallback to empty string if not available
        final medicationName = authProvider.user?.glp1Journey.medication ?? '';

        return Container(
      // padding: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        color: AppColors.lightGrey,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Section: Icon, Title, Badge
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Image.asset('assets/images/injection.png'),
                        const SizedBox(width: 12),
                        Text(
                          'Medication Level',
                          style: _montserrat(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    if (medicationName.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey[300]!,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          medicationName,
                          style: _montserrat(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSubTitle,
                          ),
                        ),
                      ),
                  ],
                ),

                // const SizedBox(height: 12),

                // Current Status Section
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Current Status',
                          style: _montserrat(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSubTitle,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              isLoading
                                  ? '...'
                                  : '${(percentage / 380).toStringAsFixed(3)}mg',
                              style: _montserrat(
                                fontSize: 27,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Text(
                                'Current estimate',
                                style: _montserrat(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textSubTitle,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Progress Bar Section
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF8B5CF6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isLoading ? '...' : '${percentage.toStringAsFixed(0)}%',
                        style: _montserrat(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: isLoading ? 0.0 : (percentage.clamp(0, 100) / 100),
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF8B5CF6),
                              borderRadius: BorderRadius.circular(4),
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


          // Next Dose Section
          if(nextDose.isNotEmpty)
            Column(
              children: [
                // const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: RichText(text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Next Dose',
                            style: AppTextStyles.title(fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,),
                          ),
                          TextSpan(
                            text: ' $nextDose',
                            style: AppTextStyles.title(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary),
                          ),
                        ]
                    )),
                  ),
                ),
              ],
            )



          // Center(
          //   child: Text(
          //     isLoading || nextDose.isEmpty ? 'Next Dose' : 'Next Dose $nextDose',
          //     style: _montserrat(
          //       fontSize: 16,
          //       fontWeight: FontWeight.w700,
          //       color: Colors.black,
          //     ),
          //   ),
          // ),
        ],
      ),
    );
      },
    );
  }
}

