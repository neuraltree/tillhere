import '../../../core/network/api_client.dart';
import '../../../core/network/api_service.dart';
import '../../../core/utils/result.dart';
import '../../../core/errors/failures.dart';
import '../../../core/entities/life_expectancy.dart';
import '../../models/world_bank_response_model.dart';

/// Remote data source for fetching life expectancy data from World Bank API
/// Implements the World Bank Data API for life expectancy indicator SP.DYN.LE00.IN
class WorldBankApiDataSource extends ApiService {
  final ApiClient _apiClient;

  static const String _baseUrl = 'https://api.worldbank.org/v2';
  static const String _lifeExpectancyIndicator = 'SP.DYN.LE00.IN';

  WorldBankApiDataSource({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  @override
  String get baseUrl => _baseUrl;

  /// Fetches life expectancy data for a specific country
  ///
  /// [countryCode] - ISO 3166-1 alpha-2 country code (e.g., "US", "GB")
  /// [startYear] - Optional start year for data range (defaults to last 5 years)
  /// [endYear] - Optional end year for data range (defaults to current year)
  ///
  /// Returns a Result containing LifeExpectancy data or a Failure
  Future<Result<LifeExpectancy>> getLifeExpectancy(String countryCode, {int? startYear, int? endYear}) async {
    try {
      // Validate country code
      if (countryCode.length != 2) {
        return Result.failure(ValidationFailure('Country code must be 2 characters long'));
      }

      // Set default year range (last 5 years to current year)
      final currentYear = DateTime.now().year;
      final defaultStartYear = currentYear - 5;
      final yearRange = '${startYear ?? defaultStartYear}:${endYear ?? currentYear}';

      // Build API URL
      final url = '$baseUrl/country/${countryCode.toUpperCase()}/indicator/$_lifeExpectancyIndicator';

      // Make API request
      final response = await _apiClient.get(
        url,
        queryParameters: {
          'format': 'json',
          'date': yearRange,
          'per_page': '100', // Get more data points if available
        },
      );

      // Parse response - World Bank API returns an array where second element contains data
      final apiResponse = response['data'] as List<dynamic>;
      final responseModel = WorldBankResponseModel.fromJson(apiResponse);

      // Convert to domain entity
      final lifeExpectancy = responseModel.toEntity(countryCode.toUpperCase());

      if (lifeExpectancy == null) {
        return Result.failure(NetworkFailure('No life expectancy data available for country $countryCode'));
      }

      // Validate the data
      if (!lifeExpectancy.isValid) {
        return Result.failure(ValidationFailure('Invalid life expectancy data received from API'));
      }

      return Result.success(lifeExpectancy);
    } on NetworkFailure catch (e) {
      return Result.failure(e);
    } catch (e) {
      return Result.failure(NetworkFailure('Failed to fetch life expectancy data: $e'));
    }
  }

  /// Fetches life expectancy data for multiple countries
  ///
  /// [countryCodes] - List of ISO 3166-1 alpha-2 country codes
  /// [startYear] - Optional start year for data range
  /// [endYear] - Optional end year for data range
  ///
  /// Returns a Result containing a Map of country code to LifeExpectancy data
  Future<Result<Map<String, LifeExpectancy>>> getMultipleLifeExpectancies(
    List<String> countryCodes, {
    int? startYear,
    int? endYear,
  }) async {
    try {
      final results = <String, LifeExpectancy>{};
      final failures = <String, Failure>{};

      // Fetch data for each country
      for (final countryCode in countryCodes) {
        final result = await getLifeExpectancy(countryCode, startYear: startYear, endYear: endYear);

        if (result.isSuccess) {
          results[countryCode.toUpperCase()] = result.data!;
        } else {
          failures[countryCode.toUpperCase()] = result.failure!;
        }
      }

      // Return success if we got at least some data
      if (results.isNotEmpty) {
        return Result.success(results);
      } else {
        // All requests failed
        final firstFailure = failures.values.first;
        return Result.failure(firstFailure);
      }
    } catch (e) {
      return Result.failure(NetworkFailure('Failed to fetch multiple life expectancy data: $e'));
    }
  }

  /// Checks if the World Bank API is available
  ///
  /// Returns a Result indicating whether the API is accessible
  Future<Result<bool>> checkApiAvailability() async {
    try {
      // Try to fetch a simple endpoint to check API availability
      final url = '$baseUrl/country/US/indicator/$_lifeExpectancyIndicator';

      await _apiClient.get(url, queryParameters: {'format': 'json', 'per_page': '1'});

      return Result.success(true);
    } on NetworkFailure catch (e) {
      return Result.failure(e);
    } catch (e) {
      return Result.failure(NetworkFailure('World Bank API is not available: $e'));
    }
  }

  /// Disposes the data source and cleans up resources
  void dispose() {
    _apiClient.dispose();
  }
}
