import 'dart:async';
import 'package:flutter/foundation.dart';

import '../../core/entities/navigation_item.dart';
import '../../core/entities/navigation_state.dart';
import '../../core/entities/time_filter.dart';
import '../../core/usecases/navigation_usecases.dart';

/// Provider for navigation state management
/// Following Clean Architecture principles - presentation layer
class NavigationProvider extends ChangeNotifier {
  final NavigateToRouteUseCase _navigateToRouteUseCase;
  final ToggleDrawerUseCase _toggleDrawerUseCase;
  final SetDrawerStateUseCase _setDrawerStateUseCase;
  final UpdateTimeFilterUseCase _updateTimeFilterUseCase;
  final GetNavigationStateUseCase _getNavigationStateUseCase;
  final ObserveNavigationStateUseCase _observeNavigationStateUseCase;

  late StreamSubscription<NavigationState> _stateSubscription;
  NavigationState _currentState = NavigationState.initial();

  NavigationProvider({
    required NavigateToRouteUseCase navigateToRouteUseCase,
    required ToggleDrawerUseCase toggleDrawerUseCase,
    required SetDrawerStateUseCase setDrawerStateUseCase,
    required UpdateTimeFilterUseCase updateTimeFilterUseCase,
    required GetNavigationStateUseCase getNavigationStateUseCase,
    required ObserveNavigationStateUseCase observeNavigationStateUseCase,
  }) : _navigateToRouteUseCase = navigateToRouteUseCase,
       _toggleDrawerUseCase = toggleDrawerUseCase,
       _setDrawerStateUseCase = setDrawerStateUseCase,
       _updateTimeFilterUseCase = updateTimeFilterUseCase,
       _getNavigationStateUseCase = getNavigationStateUseCase,
       _observeNavigationStateUseCase = observeNavigationStateUseCase {
    _initializeState();
  }

  /// Initialize state and listen to changes
  void _initializeState() {
    _currentState = _getNavigationStateUseCase();
    _stateSubscription = _observeNavigationStateUseCase().listen((state) {
      _currentState = state;
      notifyListeners();
    });
  }

  /// Current navigation state
  NavigationState get state => _currentState;

  /// Current route
  String get currentRoute => _currentState.currentRoute;

  /// Navigation items
  List<NavigationItem> get navigationItems => _currentState.navigationItems;

  /// Is drawer open
  bool get isDrawerOpen => _currentState.isDrawerOpen;

  /// Selected time filter
  TimeFilter get selectedTimeFilter => _currentState.selectedTimeFilter;

  /// Current page title
  String get currentPageTitle => _currentState.currentPageTitle;

  /// Active navigation item
  NavigationItem? get activeNavigationItem => _currentState.activeNavigationItem;

  /// Navigate to a specific route
  void navigateToRoute(String route) {
    _navigateToRouteUseCase(route);
  }

  /// Toggle drawer state
  void toggleDrawer() {
    _toggleDrawerUseCase();
  }

  /// Set drawer state explicitly
  void setDrawerState(bool isOpen) {
    _setDrawerStateUseCase(isOpen);
  }

  /// Update time filter
  void updateTimeFilter(TimeFilter filter) {
    _updateTimeFilterUseCase(filter);
  }

  /// Close drawer
  void closeDrawer() {
    setDrawerState(false);
  }

  /// Open drawer
  void openDrawer() {
    setDrawerState(true);
  }

  @override
  void dispose() {
    _stateSubscription.cancel();
    super.dispose();
  }
}
