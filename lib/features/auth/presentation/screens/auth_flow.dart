import 'package:flutter/material.dart';
import 'auth_welcome_screen.dart';
import 'account_info_screen.dart';
import 'medication_selection_screen.dart';
import 'dose_selection_screen.dart';
import 'frequency_selection_screen.dart';
import 'birthday_input_screen.dart';
import 'height_weight_screen.dart';
import 'motivation_selection_screen.dart';
import 'concerns_selection_screen.dart';
import 'auth_loading_screen.dart';
import 'auth_complete_screen.dart';
import '../../../navigation/presentation/screens/main_navigation_screen.dart';

class AuthFlow extends StatelessWidget {
  const AuthFlow({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SemaSync Auth',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        scaffoldBackgroundColor: Colors.white,
      ),
      initialRoute: '/auth/welcome',
      routes: {
        '/auth/welcome': (context) => const AuthWelcomeScreen(),
        '/auth/account': (context) => const AccountInfoScreen(),
        '/auth/medication': (context) => const MedicationSelectionScreen(),
        '/auth/dose': (context) => const DoseSelectionScreen(),
        '/auth/frequency': (context) => const FrequencySelectionScreen(),
        '/auth/birthday': (context) => const BirthdayInputScreen(),
        '/auth/height-weight': (context) => const HeightWeightScreen(),
        '/auth/motivation': (context) => const MotivationSelectionScreen(),
        '/auth/concerns': (context) => const ConcernsSelectionScreen(),
        '/auth/loading': (context) => const AuthLoadingScreen(),
        '/auth/complete': (context) => const AuthCompleteScreen(),
        '/main': (context) => const MainNavigationScreen(),
      },
    );
  }
}
