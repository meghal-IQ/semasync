import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/providers/treatment_provider.dart';
import '../../../../core/api/models/shot_log_model.dart';
import '../../../../core/theme/app_text_styles.dart';

class LastDoseCard extends StatelessWidget {
  const LastDoseCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TreatmentProvider>(
      builder: (context, treatmentProvider, child) {
        final lastShot = treatmentProvider.latestShot;
        
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
                      Icons.add_box_outlined,
                      size: 20,
                      color: AppColors.textPrimary,
                    ),
                    const SizedBox(width: AppConstants.spacing8),
                    Text(
                      'Last Dose',
                      style: AppTextStyles.title(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.spacing6),
                if (lastShot != null) ...[
                  Text(
                    lastShot.dosage,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacing6),
                  Text(
                    lastShot.medication,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacing12),
                  Text(
                    DateFormat('MMM d, h:mm a').format(lastShot.date),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ] else ...[
                  Text(
                    'No data',
                    style: AppTextStyles.title(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacing12),
                  Text(
                    'Log your first shot',
                    style: AppTextStyles.title(
                      fontSize: 12,
                      color: AppColors.textSecondary,
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
}

class NextDoseCard extends StatelessWidget {
  const NextDoseCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TreatmentProvider>(
      builder: (context, treatmentProvider, child) {
        final nextShot = treatmentProvider.nextShotInfo;
        
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
                      Icons.add_box_outlined,
                      size: 20,
                      color: AppColors.textPrimary,
                    ),
                    const SizedBox(width: AppConstants.spacing8),
                    Text(
                      'Next Dose',
                      style: AppTextStyles.title(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.spacing12),
                if (nextShot != null && nextShot.hasShots) ...[
                  CountdownProgressIndicator(nextShot: nextShot),
                  const SizedBox(height: AppConstants.spacing12),
                  Text(
                    DateFormat('MMM d, h:mm a').format(nextShot.nextDueDate!),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ] else ...[
                  Text(
                    'No data',
                    style: AppTextStyles.title(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacing12),
                  Text(
                    'Log your first shot',
                    style: AppTextStyles.title(
                      fontSize: 12,
                      color: AppColors.textSecondary,
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

  Widget _buildCountdownProgress(NextShotInfo nextShot) {
    // --- Progress Calculation (as fixed previously) ---
    const double totalCycleHours = 7.0 * 24.0; // 168.0 hours
    final double remainingHours = nextShot.daysUntilNext * 24.0;

    double targetProgress = 0.0;
    if (!nextShot.isOverdue && remainingHours > 0) {
      final clampedRemainingHours = remainingHours.clamp(0.0, totalCycleHours);
      targetProgress = 1.0 - (clampedRemainingHours / totalCycleHours);
      targetProgress = targetProgress.clamp(0.0, 1.0);
    } else if (nextShot.isOverdue) {
      targetProgress = 1.0;
    }
    // --------------------------------------------------

    final daysRemaining = nextShot.daysUntilNext.toInt();
    final hoursRemaining = (nextShot.hoursUntilNext % 24).toInt();
    String displayText = nextShot.isOverdue
        ? 'Overdue'
        : (nextShot.countdown?.isNotEmpty == true ? nextShot.countdown! : '${daysRemaining}d ${hoursRemaining}h');

    return Stack(
      alignment: Alignment.center,
      children: [
        // Background Track (Light Grey) - Remains static
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(24.0),
          ),
        ),

        // Progress Bar: Animated using TweenAnimationBuilder
        LayoutBuilder(
          builder: (context, constraints) {
            // Use TweenAnimationBuilder to animate the progress value change
            return TweenAnimationBuilder<double>(
              // Animate from the previous value to the new 'targetProgress'
              tween: Tween<double>(begin: targetProgress, end: targetProgress),
              duration: const Duration(milliseconds: 700), // Smooth 0.7 second transition
              curve: Curves.easeInOut, // Nice easing effect
              builder: (context, animatedProgressValue, child) {

                // AnimatedContainer automatically smooths the width change
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 50), // Minimal duration for layout changes
                  curve: Curves.linear,
                  // The width is calculated using the animated value
                  width: constraints.maxWidth * animatedProgressValue,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    // Use a CustomClipper or similar if you need to perfectly match the rounded end
                    // for the *partial* progress, but this borderRadius is usually sufficient.
                    borderRadius: BorderRadius.circular(24.0),
                  ),
                );
              },
            );
          },
        ),

        // Timer Text - Always on top
        Text(
          displayText,
          style: AppTextStyles.title(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ],
    );
  }
}

class CountdownProgressIndicator extends StatefulWidget {
  final NextShotInfo nextShot; // Your data model
  final double totalCycleHours; // e.g., 168.0 for 7 days

  const CountdownProgressIndicator({
    required this.nextShot,
    this.totalCycleHours = 168.0,
    super.key,
  });

  @override
  State<CountdownProgressIndicator> createState() => _CountdownProgressIndicatorState();
}

class _CountdownProgressIndicatorState extends State<CountdownProgressIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;
  double _currentProgress = 0.0; // Stores the previous target progress

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700), // Duration for the smooth transition
    );
    // Initialize the current progress on load
    _currentProgress = _calculateTargetProgress(widget.nextShot);
    _setAnimation();
  }

  // Helper to calculate the progress value (0.0 to 1.0)
  double _calculateTargetProgress(NextShotInfo nextShot) {
    if (nextShot.isOverdue) return 1.0;

    final double remainingHours = nextShot.daysUntilNext * 24.0;
    if (remainingHours <= 0) return 1.0;

    final clampedRemainingHours = remainingHours.clamp(0.0, widget.totalCycleHours);
    double targetProgress = 1.0 - (clampedRemainingHours / widget.totalCycleHours);
    return targetProgress.clamp(0.0, 1.0);
  }

  // Sets up the animation to go from the old progress to the new one
  void _setAnimation() {
    final newTargetProgress = _calculateTargetProgress(widget.nextShot);

    // Create an animation that tweens from the last state to the new state
    _progressAnimation = Tween<double>(
      begin: _currentProgress,
      end: newTargetProgress,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    // Reset and start the animation
    _controller.reset();
    _controller.forward();

    // Update the stored progress value for the next update
    _currentProgress = newTargetProgress;
  }

  @override
  void didUpdateWidget(covariant CountdownProgressIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Check if the underlying data has changed significantly enough to trigger a new animation
    // We check the target date or the progress value itself.
    if (widget.nextShot.nextDueDate != oldWidget.nextShot.nextDueDate) {
      _setAnimation();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final daysRemaining = widget.nextShot.daysUntilNext.toInt();
    final hoursRemaining = (widget.nextShot.hoursUntilNext % 24).toInt();
    final displayText = widget.nextShot.isOverdue
        ? 'Overdue'
        : (widget.nextShot.countdown?.isNotEmpty == true ? widget.nextShot.countdown! : '${daysRemaining}d ${hoursRemaining}h');

    // Use AnimatedBuilder to listen to the controller and rebuild ONLY the progress bar
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Background Track (Light Grey)
            Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(24.0),
              ),
            ),

            // Foreground Progress (Purple) - Driven by the animation
            LayoutBuilder(
              builder: (context, constraints) {
                // Get the current animated value
                final animatedProgress = _progressAnimation.value;
                return Container(
                  // width: constraints.maxWidth * animatedProgress,
                  // height: 48,
                  // decoration: BoxDecoration(
                  //   color: AppColors.primary,
                  //   borderRadius: BorderRadius.circular(24.0),
                  // ),
                );
              },
            ),

            // Timer Text (Child is null, so we include Text outside of AnimatedBuilder)
            Text(
              displayText,
              style: AppTextStyles.title(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        );
      },
    );
  }
}



class NextDoseProgress extends StatelessWidget {
  final double progress; // 0.0 - 1.0
  final String label; // "1d 1h"

  const NextDoseProgress({
    super.key,
    required this.progress,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: SizedBox(
              height: 34,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Background track
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5E5E5),
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),

                  // Filled Purple Progress
                  Align(
                    alignment: Alignment.centerLeft,
                    child: FractionallySizedBox(
                      widthFactor: 0, // 0.0 to 1.0
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF6B32CF),
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                    ),
                  ),

                  // ✅ Text ABOVE everything
                  Text(
                    label, // e.g. "1d 1h"
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          )

        ],
      ),
    );
  }
}


