import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../screens/side_effect_logging_screen.dart';
import '../../domain/models/side_effect.dart';
import '../providers/side_effect_provider.dart';

class SideEffectsCard extends StatelessWidget {
  const SideEffectsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SideEffectProvider>(
      builder: (context, provider, child) {
        // Get all side effects and sort by createdAt (most recent first)
        final allEffects = List<SideEffect>.from(provider.sideEffects);
        allEffects.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        
        // Debug output
        debugPrint('🔍 Side Effects Card - Total effects: ${allEffects.length}');
        if (allEffects.isNotEmpty) {
          debugPrint('🔍 Side Effects Card - Most recent createdAt: ${allEffects.first.createdAt}');
          debugPrint('🔍 Side Effects Card - Most recent date: ${allEffects.first.date}');
          debugPrint('🔍 Side Effects Card - Effects count: ${allEffects.first.effects.length}');
          debugPrint('🔍 Side Effects Card - First effect: ${allEffects.first.effects.map((e) => '${e.name}: ${e.severity}').join(', ')}');
        }
        
        // Get the most recent side effect log
        final mostRecentLog = allEffects.isNotEmpty ? allEffects.first : null;

        return Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.spacing16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.sick_outlined,
                          color: AppColors.success,
                          size: 20,
                        ),
                        const SizedBox(width: AppConstants.spacing8),
                        const Text(
                          'Side Effects',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.add, size: 20),
                      color: AppColors.primary,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SideEffectLoggingScreen(),
                          ),
                        ).then((_) {
                          // Refresh data when returning from logging screen
                          provider.loadSideEffects(forceRefresh: true);
                        });
                      },
                    ),
                  ],
                ),
                
                const SizedBox(height: AppConstants.spacing16),
                
                // Side effects list or empty state
                if (mostRecentLog != null) ...[
                  // Build side effect items from the most recent log
                  ...mostRecentLog.effects.map((effect) => 
                    _buildSideEffectItem(
                      effect.name,
                      effect.severity,
                    ),
                  ),
                  
                  // Timestamp
                  const SizedBox(height: AppConstants.spacing8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      _formatDate(mostRecentLog.date),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.all(AppConstants.spacing24),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                    ),
                    child: const Center(
                      child: Text(
                        'No side effects logged recently.\nTap + to log your first side effect.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSideEffectItem(String name, double severity) {
    final severityInt = severity.toInt();
    final color = _getSeverityColor(severity);
    
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.spacing12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name and severity value
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '$severityInt/10',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppConstants.spacing4),
          
          // Progress bar
          ClipRRect(
            child: LinearProgressIndicator(
              value: severity / 10,
              minHeight: 8,
              backgroundColor: AppColors.border.withOpacity(0.3),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }

  Color _getSeverityColor(double severity) {
    if (severity == 0) return Colors.grey.shade300;
    if (severity <= 3) return Colors.green.shade400;
    if (severity <= 6) return Colors.orange.shade400;
    return Colors.red.shade400;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      final formatter = DateFormat('h:mm a');
      return 'Today, ${formatter.format(date)}';
    } else if (difference.inDays == 1) {
      final formatter = DateFormat('h:mm a');
      return 'Yesterday, ${formatter.format(date)}';
    } else {
      final formatter = DateFormat('MMMM d\'st\' yyyy, h:mm a');
      return formatter.format(date);
    }
  }
}
