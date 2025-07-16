import '../entities/navigation_state.dart';
import '../entities/time_filter.dart';

/// Abstract repository interface for navigation operations
/// Following Clean Architecture principles - domain layer interface
abstract class NavigationRepository {
  /// Get the current navigation state
  NavigationState getCurrentState();

  /// Update the current route
  void updateCurrentRoute(String route);

  /// Toggle drawer open/closed state
  void toggleDrawer();

  /// Set drawer state explicitly
  void setDrawerState(bool isOpen);

  /// Update selected time filter
  void updateTimeFilter(TimeFilter filter);

  /// Get stream of navigation state changes
  Stream<NavigationState> get navigationStateStream;

  /// Dispose resources
  void dispose();
}
