import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ActivityCard extends StatelessWidget {
  final int steps;
  final int stepsGoal;
  final Function()? onIncrement;
  final Function()? onDecrement;

  const ActivityCard({
    super.key,
    this.steps = 0,
    this.stepsGoal = 10000,
    this.onIncrement,
    this.onDecrement,
  });

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
  Widget build(BuildContext context) {
    final progress = (steps / stepsGoal).clamp(0.0, 1.0);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title with running icon
          Row(
            children: [
              const Icon(
                Icons.directions_run,
                color: Colors.black,
                size: 20,
              ),
              const SizedBox(width: 6),
              Text(
                'Activity',
                style: _montserrat(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Steps',
                    style: _montserrat(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600]!,
                    ),
                  ),
                  Text(
                    '$steps / $stepsGoal',
                    style: _montserrat(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Footprint icons
          Row(
            children: List.generate(10, (index) {
              final isActive = index < (progress * 10);
              return Container(
                width: 20,
                height: 20,
                margin: EdgeInsets.only(right: index == 9 ? 0 : 6),
                decoration: BoxDecoration(
                  color: isActive ? Colors.red : Colors.grey[200],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.single_bed,
                  size: 12,
                  color: isActive ? Colors.white : Colors.grey[400],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

