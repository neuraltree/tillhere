import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'core/injection/dependency_injection.dart';
import 'core/routing/app_routes.dart';
import 'core/routing/route_generator.dart';
import 'core/theme/app_theme.dart';
import 'core/services/deep_linking_service.dart';
import 'presentation/providers/navigation_provider.dart';
import 'presentation/providers/mood_capture_provider.dart';
import 'presentation/providers/settings_provider.dart';
import 'presentation/providers/notification_provider.dart';

/// Global navigation key for deep linking
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  // Ensure Flutter bindings are initialized before accessing services
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize timezone data
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('America/New_York')); // Default timezone

  // Initialize dependency injection
  DependencyInjection.initialize();

  // Initialize deep linking service
  DeepLinkingService().initialize(navigatorKey);

  runApp(const TillHereApp());
}

class TillHereApp extends StatefulWidget {
  const TillHereApp({super.key});

  @override
  State<TillHereApp> createState() => _TillHereAppState();
}

class _TillHereAppState extends State<TillHereApp> {
  @override
  void initState() {
    super.initState();
    // Initialize notification provider after the widget tree is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeNotifications();
    });
  }

  Future<void> _initializeNotifications() async {
    try {
      final notificationProvider = DependencyInjection.notificationProvider;
      await notificationProvider.initialize();
    } catch (e) {
      print('Failed to initialize notifications: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<NavigationProvider>.value(value: DependencyInjection.navigationProvider),
        ChangeNotifierProvider<MoodCaptureProvider>.value(value: DependencyInjection.moodCaptureProvider),
        ChangeNotifierProvider<SettingsProvider>.value(value: DependencyInjection.settingsProvider),
        ChangeNotifierProvider<NotificationProvider>.value(value: DependencyInjection.notificationProvider),
      ],
      child: MaterialApp(
        title: 'tilhere... - Your Personal Journey',
        debugShowCheckedModeBanner: false,
        navigatorKey: navigatorKey,

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
