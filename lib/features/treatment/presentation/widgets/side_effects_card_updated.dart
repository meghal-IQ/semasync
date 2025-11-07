import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/side_effect_provider.dart';
import '../../domain/models/side_effect.dart';
import '../screens/side_effect_logging_screen.dart';

class SideEffectsCardUpdated extends StatelessWidget {
  const SideEffectsCardUpdated({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SideEffectProvider>(
      builder: (context, sideEffectProvider, child) {
        final currentSideEffects = sideEffectProvider.currentSideEffects;
        
        return Card(
          color: AppColors.lightGrey,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.spacing16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.auto_awesome, // Person with sparks icon
                      size: 20,
                      color: AppColors.textPrimary,
                    ),
                    const SizedBox(width: AppConstants.spacing8),
                    Text(
                      'Side Effects',
                      style: AppTextStyles.title(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    // Plus icon button in top right
                    IconButton(
                      icon: const Icon(Icons.add, size: 24),
                      color: AppColors.textPrimary,
                      onPressed: () async {
                        // Navigate to side effect logging screen
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SideEffectLoggingScreen(),
                          ),
                        );
                        
                        // Refresh side effects data when returning from the screen
                        // This ensures the treatment page shows the newly added side effects
                        sideEffectProvider.loadCurrentSideEffects(forceRefresh: true);
                        sideEffectProvider.loadSideEffects(forceRefresh: true);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.spacing16),
                if (currentSideEffects != null && currentSideEffects.isNotEmpty) ...[
                  // Flatten all effects from all side effect logs and take top 3 by severity
                  ..._getTopSideEffects(currentSideEffects).take(3).map((sideEffectDetail) => 
                    _buildSideEffectItem(sideEffectDetail)
                  ).toList(),
                  const SizedBox(height: AppConstants.spacing12),
                  // Timestamp at bottom
                  Text(
                    _getLatestTimestamp(currentSideEffects),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ] else ...[
                  _buildNoSideEffects(),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  // Get top side effects from all side effect logs, sorted by severity
  List<SideEffectDetail> _getTopSideEffects(List<SideEffect> sideEffects) {
    final allEffects = <SideEffectDetail>[];
    
    for (final sideEffectLog in sideEffects) {
      allEffects.addAll(sideEffectLog.effects);
    }
    
    // Sort by severity (highest first) and return
    allEffects.sort((a, b) => b.severity.compareTo(a.severity));
    return allEffects;
  }

  Widget _buildSideEffectItem(SideEffectDetail sideEffectDetail) {
    final name = sideEffectDetail.name;
    final severity = sideEffectDetail.severity;
    const maxSeverity = 10.0;
    
    // Calculate progress (0.0 to 1.0)
    final progress = (severity / maxSeverity).clamp(0.0, 1.0);
    final severityScore = severity.round();
    
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.spacing6),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppConstants.spacing8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: AppColors.darkGrey,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.error),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppConstants.spacing12),
          // Severity score on the right
          Text(
            '$severityScore/${maxSeverity.toInt()}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  String _getLatestTimestamp(List<SideEffect> sideEffects) {
    if (sideEffects.isEmpty) {
      final now = DateTime.now();
      final day = now.day;
      final ordinal = _getOrdinal(day);
      return DateFormat('MMMM d\'$ordinal\' yyyy, h:mm a').format(now);
    }
    
    // Get the most recent side effect date
    final latest = sideEffects.reduce((a, b) => a.date.isAfter(b.date) ? a : b);
    final day = latest.date.day;
    final ordinal = _getOrdinal(day);
    return DateFormat('MMMM d\'$ordinal\' yyyy, h:mm a').format(latest.date);
  }

  String _getOrdinal(int day) {
    if (day >= 11 && day <= 13) {
      return 'th';
    }
    switch (day % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }

  Widget _buildNoSideEffects() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacing16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          'No side effects reported',
          style: AppTextStyles.title(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

}

