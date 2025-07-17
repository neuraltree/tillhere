import 'package:flutter/material.dart';
import '../routing/app_routes.dart';

/// Service for handling deep linking within the app
/// Manages navigation from notifications and other external triggers
class DeepLinkingService {
  static final DeepLinkingService _instance = DeepLinkingService._internal();
  factory DeepLinkingService() => _instance;
  DeepLinkingService._internal();

  GlobalKey<NavigatorState>? _navigatorKey;

  /// Initialize the deep linking service with the navigator key
  void initialize(GlobalKey<NavigatorState> navigatorKey) {
    _navigatorKey = navigatorKey;
  }

  /// Handle deep link navigation based on payload
  Future<void> handleDeepLink(String? payload) async {
    if (_navigatorKey?.currentContext == null) {
      print('⚠️ DeepLinkingService: Navigator context not available');
      return;
    }

    print('🔗 DeepLinkingService: Handling deep link with payload: $payload');

    switch (payload) {
      case 'mood_input':
        await _navigateToMoodInput();
        break;
      case 'home':
        await _navigateToHome();
        break;
      case 'settings':
        await _navigateToSettings();
        break;
      default:
        print('⚠️ DeepLinkingService: Unknown payload: $payload');
        await _navigateToHome();
    }
  }

  /// Navigate to home page and focus mood input
  Future<void> _navigateToMoodInput() async {
    final context = _navigatorKey!.currentContext!;
    
    // Navigate to home if not already there
    if (ModalRoute.of(context)?.settings.name != AppRoutes.home) {
      await Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.home,
        (route) => false,
      );
    }

    // Post a callback to focus the mood input after navigation completes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusMoodInput();
    });
  }

  /// Navigate to home page
  Future<void> _navigateToHome() async {
    final context = _navigatorKey!.currentContext!;
    
    if (ModalRoute.of(context)?.settings.name != AppRoutes.home) {
      await Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.home,
        (route) => false,
      );
    }
  }

  /// Navigate to settings page
  Future<void> _navigateToSettings() async {
    final context = _navigatorKey!.currentContext!;
    
    if (ModalRoute.of(context)?.settings.name != AppRoutes.settings) {
      await Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.settings,
        (route) => false,
      );
    }
  }

  /// Focus the mood input widget
  void _focusMoodInput() {
    final context = _navigatorKey!.currentContext!;
    
    // Try to find and focus the mood input
    // This will be handled by the FixedTextInput widget through a global key or callback
    print('🎯 DeepLinkingService: Attempting to focus mood input');
    
    // We can use a notification to trigger focus in the FixedTextInput widget
    MoodInputFocusNotification().dispatch(context);
  }
}

/// Custom notification to trigger mood input focus
class MoodInputFocusNotification extends Notification {
  const MoodInputFocusNotification();
}
