import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'core/theme/app_theme.dart';
import 'firebase_options.dart';
import 'providers/theme_provider.dart';
import 'providers/nav_provider.dart';
import 'providers/projects_provider.dart';
import 'providers/contact_provider.dart';
import 'providers/portfolio_provider.dart';
import 'screens/home/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase (gracefully handles missing config)
  await _initFirebase();

  // Lock to landscape on web (optional)
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ),
  );

  runApp(const PortfolioApp());
}

/// Initialize Firebase with error handling for unconfigured projects
Future<void> _initFirebase() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // TEMPORARY: Seed the static data to Firebase on startup
    // final service = FirebaseService();
    // await service.seedPortfolioData();
    // debugPrint('Successfully seeded portfolio data to Firebase!');
  } catch (e) {
    // Firebase not configured yet — app will use sample data
    debugPrint('Firebase initialization skipped: $e');
  }
}

/// Root application widget
class PortfolioApp extends StatelessWidget {
  const PortfolioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => NavProvider()),
        ChangeNotifierProvider(create: (_) => ProjectsProvider()),
        ChangeNotifierProvider(create: (_) => ContactProvider()),
        ChangeNotifierProvider(create: (_) => PortfolioProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'Akash Kumar — Flutter Developer',
            debugShowCheckedModeBanner: false,
            themeMode: themeProvider.themeMode,
            theme: AppTheme.lightTheme(),
            darkTheme: AppTheme.darkTheme(),
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}
