import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';

class MotivationalCard extends StatelessWidget {
  const MotivationalCard({super.key});

  final List<String> _motivationalQuotes = const [
    "Every step forward is progress, no matter how small.",
    "Your health journey is unique to you - celebrate every victory!",
    "Consistency is the key to success. You've got this!",
    "Small changes lead to big results. Keep going!",
    "You're stronger than you think. Believe in yourself!",
  ];

  @override
  Widget build(BuildContext context) {
    final quote = _motivationalQuotes[DateTime.now().day % _motivationalQuotes.length];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.auto_awesome,
                  color: AppColors.primary,
                  size: 20,
                ),
                SizedBox(width: AppConstants.spacing8),
                Text(
                  'Daily Motivation',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacing16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppConstants.spacing16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.1),
                    AppColors.secondary.withOpacity(0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.format_quote,
                    color: AppColors.primary,
                    size: 32,
                  ),
                  const SizedBox(height: AppConstants.spacing12),
                  Text(
                    quote,
                    style: const TextStyle(
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppConstants.spacing12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.spacing12,
                      vertical: AppConstants.spacing8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                    ),
                    child: const Text(
                      'You\'re doing amazing!',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppConstants.spacing16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // TODO: Share progress
                    },
                    icon: const Icon(Icons.share, size: 16),
                    label: const Text('Share Progress'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                    ),
                  ),
                ),
                const SizedBox(width: AppConstants.spacing12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // TODO: View achievements
                    },
                    icon: const Icon(Icons.emoji_events, size: 16),
                    label: const Text('Achievements'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
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
}




