import '../entities/navigation_state.dart';
import '../entities/time_filter.dart';
import '../repositories/navigation_repository.dart';

/// Use case for navigating to a specific route
/// Following Clean Architecture principles - application business rules
class NavigateToRouteUseCase {
  final NavigationRepository _repository;

  NavigateToRouteUseCase(this._repository);

  void call(String route) {
    _repository.updateCurrentRoute(route);
  }
}

/// Use case for toggling the drawer state
class ToggleDrawerUseCase {
  final NavigationRepository _repository;

  ToggleDrawerUseCase(this._repository);

  void call() {
    _repository.toggleDrawer();
  }
}

/// Use case for setting drawer state explicitly
class SetDrawerStateUseCase {
  final NavigationRepository _repository;

  SetDrawerStateUseCase(this._repository);

  void call(bool isOpen) {
    _repository.setDrawerState(isOpen);
  }
}

/// Use case for updating the time filter
class UpdateTimeFilterUseCase {
  final NavigationRepository _repository;

  UpdateTimeFilterUseCase(this._repository);

  void call(TimeFilter filter) {
    _repository.updateTimeFilter(filter);
  }
}

/// Use case for getting the current navigation state
class GetNavigationStateUseCase {
  final NavigationRepository _repository;

  GetNavigationStateUseCase(this._repository);

  NavigationState call() {
    return _repository.getCurrentState();
  }
}

/// Use case for observing navigation state changes
class ObserveNavigationStateUseCase {
  final NavigationRepository _repository;

  ObserveNavigationStateUseCase(this._repository);

  Stream<NavigationState> call() {
    return _repository.navigationStateStream;
  }
}
