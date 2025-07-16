/// Base interface for all API services
/// Provides common patterns for API service implementations
abstract class ApiService {
  /// Base URL for the API service
  String get baseUrl;

  /// Default headers to be included in all requests
  Map<String, String> get defaultHeaders => {'Content-Type': 'application/json', 'Accept': 'application/json'};

  /// Timeout duration for API requests
  Duration get timeout => const Duration(seconds: 30);
}

/// Configuration for API services
class ApiConfig {
  final String baseUrl;
  final Duration timeout;
  final Map<String, String> defaultHeaders;

  const ApiConfig({
    required this.baseUrl,
    this.timeout = const Duration(seconds: 30),
    this.defaultHeaders = const {'Content-Type': 'application/json', 'Accept': 'application/json'},
  });
}
