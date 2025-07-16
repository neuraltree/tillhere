/// App route constants
/// Following Clean Architecture principles - core constants
class AppRoutes {
  static const String home = '/home';
  static const String settings = '/settings';

  /// All available routes
  static const List<String> all = [home, settings];

  /// Default route
  static const String initial = home;

  /// Check if route is valid
  static bool isValidRoute(String route) {
    return all.contains(route);
  }

  /// Get route title
  static String getRouteTitle(String route) {
    switch (route) {
      case home:
        return 'Home';
      case settings:
        return 'Settings';
      default:
        return 'tilhere...';
    }
  }
}
