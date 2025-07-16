import 'package:flutter/material.dart';

import '../../presentation/pages/export_page.dart';
import '../../presentation/pages/home_page.dart';
import '../../presentation/pages/settings_page.dart';
import '../../presentation/pages/stats_page.dart';
import 'app_routes.dart';

/// Route generator for the app
/// Following Clean Architecture principles - core routing logic
class RouteGenerator {
  /// Generate routes based on route settings
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.home:
        return _createRoute(const HomePage(), settings);
      
      case AppRoutes.stats:
        return _createRoute(const StatsPage(), settings);
      
      case AppRoutes.export:
        return _createRoute(const ExportPage(), settings);
      
      case AppRoutes.settings:
        return _createRoute(const SettingsPage(), settings);
      
      default:
        return _createRoute(const HomePage(), settings);
    }
  }

  /// Create a route with custom page transition
  static Route<dynamic> _createRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder<dynamic>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Apple-style slide transition
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
      reverseTransitionDuration: const Duration(milliseconds: 300),
    );
  }

  /// Create a route with fade transition (for drawer navigation)
  static Route<dynamic> createFadeRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder<dynamic>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 200),
      reverseTransitionDuration: const Duration(milliseconds: 200),
    );
  }
}
