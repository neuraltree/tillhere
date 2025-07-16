import 'dart:convert';
import 'package:flutter/services.dart';

import '../../../core/utils/result.dart';
import '../../../core/errors/failures.dart';
import '../../../core/entities/life_expectancy.dart';
import '../../../core/entities/country.dart';

/// Local data source for life expectancy data
/// Reads from bundled JSON asset file instead of making HTTP requests
class LifeExpectancyLocalDataSource {
  static const String _assetPath = 'assets/life_expectancy.json';

  Map<String, dynamic>? _cachedData;

  /// Loads life expectancy data from local JSON asset
  Future<Result<Map<String, dynamic>>> _loadData() async {
    if (_cachedData != null) {
      return Result.success(_cachedData!);
    }

    try {
      final jsonString = await rootBundle.loadString(_assetPath);
      _cachedData = json.decode(jsonString) as Map<String, dynamic>;
      return Result.success(_cachedData!);
    } catch (e) {
      return Result.failure(CacheFailure('Failed to load life expectancy data: $e'));
    }
  }

  /// Gets life expectancy data for a specific country
  ///
  /// [countryCode] - ISO 3166-1 alpha-2 country code (e.g., "US", "GB")
  ///
  /// Returns a Result containing LifeExpectancy data or a Failure
  Future<Result<LifeExpectancy>> getLifeExpectancy(String countryCode) async {
    try {
      // Validate country code
      if (countryCode.length != 2) {
        return Result.failure(ValidationFailure('Country code must be 2 characters long'));
      }

      final dataResult = await _loadData();
      if (dataResult.isFailure) {
        return Result.failure(dataResult.failure!);
      }

      final data = dataResult.data!;
      final countries = data['countries'] as Map<String, dynamic>;
      final upperCountryCode = countryCode.toUpperCase();

      if (!countries.containsKey(upperCountryCode)) {
        return Result.failure(NetworkFailure('No life expectancy data available for country $countryCode'));
      }

      final countryData = countries[upperCountryCode] as Map<String, dynamic>;

      // Convert to domain entity
      final lifeExpectancy = LifeExpectancy(
        countryCode: upperCountryCode,
        yearsAtBirth: (countryData['lifeExpectancy'] as num).toDouble(),
        year: countryData['year'] as int,
        fetchedAt: DateTime.parse(countryData['lastUpdated'] as String),
        source: data['metadata']['source'] as String,
      );

      // Validate the data
      if (!lifeExpectancy.isValid) {
        return Result.failure(ValidationFailure('Invalid life expectancy data for country $countryCode'));
      }

      return Result.success(lifeExpectancy);
    } catch (e) {
      return Result.failure(CacheFailure('Failed to get life expectancy data: $e'));
    }
  }

  /// Gets life expectancy data for multiple countries
  ///
  /// [countryCodes] - List of ISO 3166-1 alpha-2 country codes
  ///
  /// Returns a Result containing a Map of country code to LifeExpectancy data
  Future<Result<Map<String, LifeExpectancy>>> getMultipleLifeExpectancies(List<String> countryCodes) async {
    try {
      final results = <String, LifeExpectancy>{};
      final failures = <String, Failure>{};

      // Get data for each country
      for (final countryCode in countryCodes) {
        final result = await getLifeExpectancy(countryCode);

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
      return Result.failure(CacheFailure('Failed to get multiple life expectancy data: $e'));
    }
  }

  /// Gets all available countries with their life expectancy data
  ///
  /// Returns a Result containing a list of all available countries
  Future<Result<List<Country>>> getAllCountries() async {
    try {
      final dataResult = await _loadData();
      if (dataResult.isFailure) {
        return Result.failure(dataResult.failure!);
      }

      final data = dataResult.data!;
      final countries = data['countries'] as Map<String, dynamic>;

      final countryList = <Country>[];

      for (final entry in countries.entries) {
        final countryCode = entry.key;
        final countryData = entry.value as Map<String, dynamic>;

        countryList.add(
          Country(code: countryCode, name: countryData['name'] as String, alpha3Code: countryData['iso3'] as String),
        );
      }

      // Sort by country name
      countryList.sort((a, b) => a.name.compareTo(b.name));

      return Result.success(countryList);
    } catch (e) {
      return Result.failure(CacheFailure('Failed to get countries list: $e'));
    }
  }

  /// Gets metadata about the life expectancy dataset
  ///
  /// Returns a Result containing metadata information
  Future<Result<Map<String, dynamic>>> getMetadata() async {
    try {
      final dataResult = await _loadData();
      if (dataResult.isFailure) {
        return Result.failure(dataResult.failure!);
      }

      final data = dataResult.data!;
      final metadata = data['metadata'] as Map<String, dynamic>;

      return Result.success(metadata);
    } catch (e) {
      return Result.failure(CacheFailure('Failed to get metadata: $e'));
    }
  }

  /// Checks if data is available for a specific country
  ///
  /// [countryCode] - ISO 3166-1 alpha-2 country code
  ///
  /// Returns true if data is available, false otherwise
  Future<bool> hasDataForCountry(String countryCode) async {
    final result = await getLifeExpectancy(countryCode);
    return result.isSuccess;
  }

  /// Clears the cached data (useful for testing or forcing reload)
  void clearCache() {
    _cachedData = null;
  }
}
