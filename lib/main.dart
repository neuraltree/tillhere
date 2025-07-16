import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/injection/dependency_injection.dart';
import 'core/routing/app_routes.dart';
import 'core/routing/route_generator.dart';
import 'core/theme/app_theme.dart';
import 'presentation/providers/navigation_provider.dart';
import 'presentation/providers/mood_capture_provider.dart';
import 'presentation/providers/settings_provider.dart';

void main() {
  // Ensure Flutter bindings are initialized before accessing services
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize dependency injection
  DependencyInjection.initialize();

  runApp(const TillHereApp());
}

class TillHereApp extends StatelessWidget {
  const TillHereApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<NavigationProvider>.value(value: DependencyInjection.navigationProvider),
        ChangeNotifierProvider<MoodCaptureProvider>.value(value: DependencyInjection.moodCaptureProvider),
        ChangeNotifierProvider<SettingsProvider>.value(value: DependencyInjection.settingsProvider),
      ],
      child: MaterialApp(
        title: 'tilhere... - Your Personal Journey',
        debugShowCheckedModeBanner: false,

        // Theme configuration
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system, // Follow system theme
        // Routing configuration
        initialRoute: AppRoutes.initial,
        onGenerateRoute: RouteGenerator.generateRoute,

        // Navigation configuration
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(1.0), // Prevent text scaling issues
            ),
            child: child!,
          );
        },
      ),
    );
  }
}
