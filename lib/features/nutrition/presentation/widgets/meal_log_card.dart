import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';

class MealLogCard extends StatelessWidget {
  const MealLogCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Meals Today',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '4 meals',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacing16),
            _buildMealItem(
              mealType: 'Breakfast',
              time: '8:30 AM',
              items: ['Oatmeal with berries', 'Greek yogurt'],
              calories: '320 cal',
              color: AppColors.proteinOrange,
            ),
            const SizedBox(height: AppConstants.spacing12),
            _buildMealItem(
              mealType: 'Lunch',
              time: '12:45 PM',
              items: ['Grilled chicken salad', 'Quinoa'],
              calories: '450 cal',
              color: AppColors.fiberGreen,
            ),
            const SizedBox(height: AppConstants.spacing12),
            _buildMealItem(
              mealType: 'Snack',
              time: '3:15 PM',
              items: ['Apple slices', 'Almonds'],
              calories: '180 cal',
              color: AppColors.waterBlue,
            ),
            const SizedBox(height: AppConstants.spacing12),
            _buildMealItem(
              mealType: 'Dinner',
              time: '7:00 PM',
              items: ['Salmon fillet', 'Steamed vegetables'],
              calories: '420 cal',
              color: AppColors.primary,
            ),
            const SizedBox(height: AppConstants.spacing20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // TODO: Add meal
                    },
                    icon: const Icon(Icons.add, size: 20),
                    label: const Text('Add Meal'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(
                        vertical: AppConstants.spacing12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppConstants.spacing12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Scan barcode
                    },
                    icon: const Icon(Icons.qr_code_scanner, size: 20),
                    label: const Text('Scan Food'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(
                        vertical: AppConstants.spacing12,
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

  Widget _buildMealItem({
    required String mealType,
    required String time,
    required List<String> items,
    required String calories,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacing12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppConstants.spacing8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
            ),
            child: Icon(
              _getMealIcon(mealType),
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: AppConstants.spacing12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      mealType,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      time,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.spacing4),
                ...items.map((item) => Text(
                  '• $item',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                )),
                const SizedBox(height: AppConstants.spacing4),
                Text(
                  calories,
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.check_circle,
            color: AppColors.success,
            size: 20,
          ),
        ],
      ),
    );
  }

  IconData _getMealIcon(String mealType) {
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        return Icons.free_breakfast;
      case 'lunch':
        return Icons.lunch_dining;
      case 'dinner':
        return Icons.dinner_dining;
      case 'snack':
        return Icons.cookie;
      default:
        return Icons.restaurant;
    }
  }
}




