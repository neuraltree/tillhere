import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import '../errors/failures.dart';

/// Base API client for making HTTP requests
/// Provides common functionality for all API services
class ApiClient {
  final http.Client _httpClient;
  final Duration _timeout;

  ApiClient({
    http.Client? httpClient,
    Duration timeout = const Duration(seconds: 30),
  }) : _httpClient = httpClient ?? http.Client(),
       _timeout = timeout;

  /// Makes a GET request to the specified URL
  /// Returns the response body as a Map or throws an ApiException
  Future<Map<String, dynamic>> get(
    String url, {
    Map<String, String>? headers,
    Map<String, String>? queryParameters,
  }) async {
    try {
      // Build URL with query parameters
      final uri = Uri.parse(url);
      final finalUri = queryParameters != null
          ? uri.replace(queryParameters: {...uri.queryParameters, ...queryParameters})
          : uri;

      // Make the request
      final response = await _httpClient
          .get(
            finalUri,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              ...?headers,
            },
          )
          .timeout(_timeout);

      return _handleResponse(response);
    } on SocketException {
      throw const NetworkFailure('No internet connection');
    } on HttpException {
      throw const NetworkFailure('HTTP error occurred');
    } on FormatException {
      throw const NetworkFailure('Invalid response format');
    } catch (e) {
      throw NetworkFailure('Network request failed: $e');
    }
  }

  /// Makes a POST request to the specified URL
  Future<Map<String, dynamic>> post(
    String url, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
  }) async {
    try {
      final response = await _httpClient
          .post(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              ...?headers,
            },
            body: body != null ? json.encode(body) : null,
          )
          .timeout(_timeout);

      return _handleResponse(response);
    } on SocketException {
      throw const NetworkFailure('No internet connection');
    } on HttpException {
      throw const NetworkFailure('HTTP error occurred');
    } on FormatException {
      throw const NetworkFailure('Invalid response format');
    } catch (e) {
      throw NetworkFailure('Network request failed: $e');
    }
  }

  /// Handles HTTP response and converts to Map or throws appropriate exception
  Map<String, dynamic> _handleResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
      case 201:
        try {
          final decoded = json.decode(response.body);
          if (decoded is Map<String, dynamic>) {
            return decoded;
          } else if (decoded is List) {
            // Handle array responses by wrapping in a map
            return {'data': decoded};
          } else {
            throw const NetworkFailure('Invalid response format');
          }
        } catch (e) {
          throw NetworkFailure('Failed to parse response: $e');
        }
      case 400:
        throw const NetworkFailure('Bad request');
      case 401:
        throw const NetworkFailure('Unauthorized');
      case 403:
        throw const NetworkFailure('Forbidden');
      case 404:
        throw const NetworkFailure('Resource not found');
      case 429:
        throw const NetworkFailure('Too many requests');
      case 500:
        throw const NetworkFailure('Internal server error');
      case 502:
        throw const NetworkFailure('Bad gateway');
      case 503:
        throw const NetworkFailure('Service unavailable');
      default:
        throw NetworkFailure('HTTP ${response.statusCode}: ${response.reasonPhrase}');
    }
  }

  /// Disposes the HTTP client
  void dispose() {
    _httpClient.close();
  }
}
