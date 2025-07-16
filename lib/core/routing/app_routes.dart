/// App route constants
/// Following Clean Architecture principles - core constants
class AppRoutes {
  static const String home = '/home';
  static const String stats = '/stats';
  static const String export = '/export';
  static const String settings = '/settings';

  /// All available routes
  static const List<String> all = [home, stats, export, settings];

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
      case stats:
        return 'Stats';
      case export:
        return 'Export / Import';
      case settings:
        return 'Settings';
      default:
        return 'tilhere...';
    }
  }
}
