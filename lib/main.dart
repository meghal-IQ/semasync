import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/api/api_client.dart';
import 'core/api/api_config.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/dashboard_provider.dart';
import 'core/providers/treatment_provider.dart';
import 'core/providers/health_provider.dart';
import 'core/providers/activity_provider.dart';
import 'core/providers/nutrition_provider.dart';
import 'core/providers/weekly_checkup_provider.dart';
import 'core/providers/historical_data_provider.dart';
import 'core/providers/shot_day_tasks_provider.dart';
import 'features/treatment/presentation/providers/side_effect_provider.dart';
import 'features/treatment/presentation/providers/medication_level_provider.dart';
import 'features/treatment/presentation/providers/treatment_schedule_provider.dart';
import 'core/api/side_effect_api.dart';
import 'core/api/medication_level_api.dart';
import 'core/api/treatment_schedule_api.dart';
import 'core/api/services/weekly_checkup_service.dart';
import 'features/auth/presentation/screens/holographic_login_screen.dart';
import 'features/navigation/presentation/screens/main_navigation_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Print API configuration for debugging
  ApiConfig.printConfig();
  
  // Initialize API client and wait for token to load
  await ApiClient().initialize();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => TreatmentProvider()),
        ChangeNotifierProvider(create: (_) => HealthProvider()),
        ChangeNotifierProvider(create: (_) => ActivityProvider()),
        ChangeNotifierProvider(create: (_) => NutritionProvider()),
        ChangeNotifierProvider(create: (_) => HistoricalDataProvider()),
        ChangeNotifierProvider(create: (_) => ShotDayTasksProvider()),
        ChangeNotifierProvider(create: (_) => WeeklyCheckupProvider(WeeklyCheckupService(ApiClient().dio))),
        ChangeNotifierProvider(create: (_) => SideEffectProvider(SideEffectApi(ApiClient().dio))),
        ChangeNotifierProvider(create: (_) => MedicationLevelProvider(MedicationLevelApi(ApiClient().dio))),
        ChangeNotifierProvider(create: (_) => TreatmentScheduleProvider(TreatmentScheduleApi(ApiClient().dio))),
      ],
      child: MaterialApp(
        title: 'SemaSync',
        theme: AppTheme.lightTheme,
        home: const AppInitializer(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      await Future.delayed(Duration.zero);
      if (!mounted) return;
      
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.initialize();
    } catch (e) {
      print('Initialization error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Show loading while initializing
        if (authProvider.status == AuthStatus.initial || 
            authProvider.status == AuthStatus.loading) {
          return const Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        
        // Show main app if authenticated
        if (authProvider.status == AuthStatus.authenticated) {
          return const MainNavigationScreen();
        }
        
        // Show login screen if not authenticated
        return const HolographicLoginScreen();
      },
    );
  }
}