import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/standard_widgets.dart';
import '../../../../core/providers/treatment_provider.dart';
import '../providers/medication_level_provider.dart';

enum DoseType { last, next }

class DoseCard extends StatelessWidget {
  final DoseType type;

  const DoseCard({
    super.key,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    final isLast = type == DoseType.last;
    final title = isLast ? 'Last Dose' : 'Next Dose';
    
    return Consumer2<TreatmentProvider, MedicationLevelProvider>(
      builder: (context, treatmentProvider, medicationProvider, child) {
        final time = isLast 
            ? _getLastDoseTime(treatmentProvider) 
            : _getNextDoseTime(treatmentProvider);
        final doseInfo = isLast
            ? _getLastDoseInfo(treatmentProvider)
            : _getNextDoseInfo(treatmentProvider);
        final status = isLast ? 'administered' : 'scheduled';
        final statusColor = isLast ? AppColors.success : AppColors.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.spacing4),
      padding: const EdgeInsets.all(AppConstants.spacing6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
        // border: Border.all(color: AppColors.warning.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                // Container(
                //   padding: const EdgeInsets.symmetric(
                //     horizontal: AppConstants.spacing8,
                //     vertical: AppConstants.spacing4,
                //   ),
                //   decoration: BoxDecoration(
                //     color: statusColor.withOpacity(0.1),
                //     borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                //   ),
                //   child: Text(
                //     status,
                //     style: TextStyle(
                //       color: statusColor,
                //       fontSize: 12,
                //       fontWeight: FontWeight.w500,
                //     ),
                //   ),
                // ),
              ],
            ),
            const SizedBox(height: AppConstants.spacing16),
            Row(
              children: [
                // Container(
                //   padding: const EdgeInsets.all(AppConstants.spacing12),
                //   decoration: BoxDecoration(
                //     color: statusColor.withOpacity(0.1),
                //     borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                //   ),
                //   child: Icon(
                //     icon,
                //     color: statusColor,
                //     size: 24,
                //   ),
                // ),
                // const SizedBox(width: AppConstants.spacing12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        time,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppConstants.spacing4),
                      Text(
                        doseInfo,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                      // if (!isLast) ...[
                      //   const SizedBox(height: AppConstants.spacing4),
                      //   Text(
                      //     'Left thigh injection site',
                      //     style: TextStyle(
                      //       color: AppColors.textSecondary,
                      //       fontSize: 12,
                      //     ),
                      //   ),
                      // ],
                    ],
                  ),
                ),
              ],
            ),
            // if (!isLast) ...[
            //   const SizedBox(height: AppConstants.spacing16),
            //   SizedBox(
            //     width: double.infinity,
            //     child: ElevatedButton.icon(
            //       onPressed: () {
            //         // TODO: Implement dose logging
            //       },
            //       icon: const Icon(Icons.add),
            //       label: const Text('Log Dose'),
            //       style: ElevatedButton.styleFrom(
            //         backgroundColor: AppColors.primary,
            //         foregroundColor: Colors.white,
            //       ),
            //     ),
            //   ),
            // ],
          ],
        ),
      ),
    );
      },
    );
  }

  String _getLastDoseTime(TreatmentProvider provider) {
    final latestShot = provider.latestShot;
    
    if (latestShot != null) {
      try {
        final formatter = DateFormat('MMM d, h:mm a');
        final dateTime = latestShot.date.toLocal();
        return formatter.format(dateTime);
      } catch (e) {
        debugPrint('❌ Error formatting last shot date: $e');
        return 'No data';
      }
    }
    
    return 'No data';
  }

  String _getLastDoseInfo(TreatmentProvider provider) {
    final latestShot = provider.latestShot;
    
    if (latestShot != null) {
      return '${latestShot.dosage} ${latestShot.medication}';
    }
    
    return 'No data';
  }

  String _getNextDoseTime(TreatmentProvider provider) {
    final nextShot = provider.nextShotInfo;
    
    if (nextShot != null && nextShot.hasShots) {
      // Use countdown from nextShotInfo
      return nextShot.countdown ?? _calculateNextDoseFromSchedule();
    }
    
    // No shots logged yet, calculate from schedule
    return _calculateNextDoseFromSchedule();
  }

  String _getNextDoseInfo(TreatmentProvider provider) {
    final latestShot = provider.latestShot;
    
    if (latestShot != null) {
      // Show the same dosage as last shot (assuming dosage doesn't change)
      return '${latestShot.dosage} scheduled';
    }
    
    // No shots yet, show default starting dosage
    return '0.25mg scheduled';
  }

  String _calculateNextDoseFromSchedule() {
    // TODO: Get injection day from user's treatment schedule
    // For now, assume Wednesday as injection day based on user's schedule
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // Get next injection day (Wednesday = 3)
    final nextInjectionDay = _getNextInjectionDay(today, DateTime.wednesday);
    final daysUntilNext = nextInjectionDay.difference(today).inDays;
    
    if (daysUntilNext == 0) {
      // Today is injection day
      final hoursUntilEndOfDay = 24 - now.hour;
      if (hoursUntilEndOfDay <= 12) {
        return 'Today';
      } else {
        return '${hoursUntilEndOfDay}h';
      }
    } else if (daysUntilNext == 1) {
      return 'Tomorrow';
    } else {
      return '${daysUntilNext}d';
    }
  }

  DateTime _getNextInjectionDay(DateTime from, int targetWeekday) {
    final daysUntilTarget = (targetWeekday - from.weekday) % 7;
    
    if (daysUntilTarget == 0) {
      // Today is the injection day - check if it's past a certain time
      // If it's still early in the day, return today
      // Otherwise, return next week's injection day
      final now = DateTime.now();
      if (now.hour < 20) { // Before 8 PM, show today
        return from;
      } else {
        return from.add(const Duration(days: 7));
      }
    } else {
      return from.add(Duration(days: daysUntilTarget));
    }
  }
}
