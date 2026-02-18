import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'providers/auth_provider.dart';
import 'providers/intervention_provider.dart';
import 'providers/batiment_provider.dart';
import 'providers/equipement_provider.dart';
import 'providers/user_provider.dart';
import 'providers/team_provider.dart';
import 'providers/absence_provider.dart';
import 'providers/demande_provider.dart';
import 'providers/notification_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/splash_screen.dart';
import 'utils/theme.dart'; // Import the new theme

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final bool onboardingSeen = prefs.getBool('onboarding_seen') ?? false;

  runApp(MyApp(onboardingSeen: onboardingSeen));
}

class MyApp extends StatelessWidget {
  final bool onboardingSeen;

  const MyApp({super.key, required this.onboardingSeen});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => InterventionProvider()),
        ChangeNotifierProvider(create: (_) => BatimentProvider()),
        ChangeNotifierProvider(create: (_) => EquipementProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => TeamProvider()),
        ChangeNotifierProvider(create: (_) => AbsenceProvider()),
        ChangeNotifierProvider(create: (_) => DemandeProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: MaterialApp(
        scaffoldMessengerKey: scaffoldMessengerKey,
        title: 'GMAO App',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme, // Apply the new theme
        home: SplashScreen(onboardingSeen: onboardingSeen),
      ),
    );
  }
}
