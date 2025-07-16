import 'dart:async';

import '../../core/entities/navigation_state.dart';
import '../../core/entities/time_filter.dart';
import '../../core/repositories/navigation_repository.dart';

/// Implementation of NavigationRepository
/// Following Clean Architecture principles - data layer implementation
class NavigationRepositoryImpl implements NavigationRepository {
  NavigationState _currentState = NavigationState.initial();
  final StreamController<NavigationState> _stateController = 
      StreamController<NavigationState>.broadcast();

  @override
  NavigationState getCurrentState() {
    return _currentState;
  }

  @override
  void updateCurrentRoute(String route) {
    _currentState = _currentState.updateActiveRoute(route);
    _stateController.add(_currentState);
  }

  @override
  void toggleDrawer() {
    _currentState = _currentState.copyWith(
      isDrawerOpen: !_currentState.isDrawerOpen,
    );
    _stateController.add(_currentState);
  }

  @override
  void setDrawerState(bool isOpen) {
    _currentState = _currentState.copyWith(isDrawerOpen: isOpen);
    _stateController.add(_currentState);
  }

  @override
  void updateTimeFilter(TimeFilter filter) {
    _currentState = _currentState.copyWith(selectedTimeFilter: filter);
    _stateController.add(_currentState);
  }

  @override
  Stream<NavigationState> get navigationStateStream => _stateController.stream;

  @override
  void dispose() {
    _stateController.close();
  }
}
