import 'navigation_item.dart';
import 'time_filter.dart';

/// Navigation state entity representing the current navigation state
/// Following Clean Architecture principles - pure domain entity
class NavigationState {
  final String currentRoute;
  final List<NavigationItem> navigationItems;
  final bool isDrawerOpen;
  final TimeFilter selectedTimeFilter;
  final String currentPageTitle;

  const NavigationState({
    required this.currentRoute,
    required this.navigationItems,
    required this.isDrawerOpen,
    required this.selectedTimeFilter,
    required this.currentPageTitle,
  });

  /// Default navigation state
  factory NavigationState.initial() {
    return NavigationState(
      currentRoute: '/home',
      navigationItems: _defaultNavigationItems,
      isDrawerOpen: false,
      selectedTimeFilter: TimeFilter.day,
      currentPageTitle: 'Home',
    );
  }

  /// Default navigation items as specified in requirements
  static const List<NavigationItem> _defaultNavigationItems = [
    NavigationItem(id: 'home', title: 'Home', icon: '🗓', route: '/home', isActive: true),
    NavigationItem(id: 'settings', title: 'Settings', icon: '⚙️', route: '/settings'),
  ];

  /// Creates a copy of this navigation state with updated properties
  NavigationState copyWith({
    String? currentRoute,
    List<NavigationItem>? navigationItems,
    bool? isDrawerOpen,
    TimeFilter? selectedTimeFilter,
    String? currentPageTitle,
  }) {
    return NavigationState(
      currentRoute: currentRoute ?? this.currentRoute,
      navigationItems: navigationItems ?? this.navigationItems,
      isDrawerOpen: isDrawerOpen ?? this.isDrawerOpen,
      selectedTimeFilter: selectedTimeFilter ?? this.selectedTimeFilter,
      currentPageTitle: currentPageTitle ?? this.currentPageTitle,
    );
  }

  /// Update navigation items to reflect current active route
  NavigationState updateActiveRoute(String route) {
    final updatedItems = navigationItems.map((item) {
      return item.copyWith(isActive: item.route == route);
    }).toList();

    final pageTitle = _getPageTitleFromRoute(route);

    return copyWith(currentRoute: route, navigationItems: updatedItems, currentPageTitle: pageTitle);
  }

  /// Get page title from route
  String _getPageTitleFromRoute(String route) {
    switch (route) {
      case '/home':
        return 'Home';
      case '/settings':
        return 'Settings';
      default:
        return 'tilhere...';
    }
  }

  /// Get currently active navigation item
  NavigationItem? get activeNavigationItem {
    try {
      return navigationItems.firstWhere((item) => item.isActive);
    } catch (e) {
      return null;
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NavigationState &&
        other.currentRoute == currentRoute &&
        other.navigationItems.length == navigationItems.length &&
        other.isDrawerOpen == isDrawerOpen &&
        other.selectedTimeFilter == selectedTimeFilter &&
        other.currentPageTitle == currentPageTitle;
  }

  @override
  int get hashCode {
    return currentRoute.hashCode ^
        navigationItems.hashCode ^
        isDrawerOpen.hashCode ^
        selectedTimeFilter.hashCode ^
        currentPageTitle.hashCode;
  }

  @override
  String toString() {
    return 'NavigationState(currentRoute: $currentRoute, isDrawerOpen: $isDrawerOpen, selectedTimeFilter: $selectedTimeFilter, currentPageTitle: $currentPageTitle)';
  }
}
