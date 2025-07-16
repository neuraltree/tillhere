import '../../core/entities/life_expectancy.dart';
import '../../core/entities/country.dart';
import '../../core/repositories/life_expectancy_repository.dart';
import '../../core/utils/result.dart';
import '../../core/errors/failures.dart';
import '../datasources/local/life_expectancy_local_datasource.dart';

/// Concrete implementation of LifeExpectancyRepository using local JSON data
/// Handles all life expectancy data operations using the bundled asset file
class LifeExpectancyRepositoryImpl implements LifeExpectancyRepository {
  final LifeExpectancyLocalDataSource _localDataSource;

  LifeExpectancyRepositoryImpl(this._localDataSource);

  @override
  Future<Result<LifeExpectancy>> getLifeExpectancy(String countryCode) async {
    try {
      // Validate country code
      if (countryCode.isEmpty || countryCode.length != 2) {
        return Result.failure(
          ValidationFailure('Invalid country code: $countryCode')
        );
      }

      return await _localDataSource.getLifeExpectancy(countryCode);
    } catch (e) {
      return Result.failure(
        CacheFailure('Failed to get life expectancy for $countryCode: $e')
      );
    }
  }

  @override
  Future<Result<Map<String, LifeExpectancy>>> getMultipleLifeExpectancies(
    List<String> countryCodes,
  ) async {
    try {
      // Validate input
      if (countryCodes.isEmpty) {
        return Result.success(<String, LifeExpectancy>{});
      }

      // Validate all country codes
      for (final code in countryCodes) {
        if (code.isEmpty || code.length != 2) {
          return Result.failure(
            ValidationFailure('Invalid country code: $code')
          );
        }
      }

      return await _localDataSource.getMultipleLifeExpectancies(countryCodes);
    } catch (e) {
      return Result.failure(
        CacheFailure('Failed to get multiple life expectancies: $e')
      );
    }
  }

  @override
  Future<Result<List<Country>>> getAllCountries() async {
    try {
      return await _localDataSource.getAllCountries();
    } catch (e) {
      return Result.failure(
        CacheFailure('Failed to get all countries: $e')
      );
    }
  }

  @override
  Future<bool> hasDataForCountry(String countryCode) async {
    try {
      return await _localDataSource.hasDataForCountry(countryCode);
    } catch (e) {
      return false;
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> getMetadata() async {
    try {
      return await _localDataSource.getMetadata();
    } catch (e) {
      return Result.failure(
        CacheFailure('Failed to get metadata: $e')
      );
    }
  }

  @override
  Future<Result<List<Country>>> searchCountries(String query) async {
    try {
      if (query.isEmpty) {
        return Result.success(<Country>[]);
      }

      // Get all countries first
      final countriesResult = await getAllCountries();
      if (countriesResult.isFailure) {
        return Result.failure(countriesResult.failure!);
      }

      final allCountries = countriesResult.data!;
      final queryLower = query.toLowerCase();

      // Filter countries by name or code
      final matchingCountries = allCountries.where((country) {
        return country.name.toLowerCase().contains(queryLower) ||
               country.code.toLowerCase().contains(queryLower) ||
               (country.alpha3Code?.toLowerCase().contains(queryLower) ?? false);
      }).toList();

      // Sort by relevance (exact matches first, then starts with, then contains)
      matchingCountries.sort((a, b) {
        // Exact code match gets highest priority
        if (a.code.toLowerCase() == queryLower) return -1;
        if (b.code.toLowerCase() == queryLower) return 1;

        // Exact name match gets second priority
        if (a.name.toLowerCase() == queryLower) return -1;
        if (b.name.toLowerCase() == queryLower) return 1;

        // Name starts with query gets third priority
        final aStartsWith = a.name.toLowerCase().startsWith(queryLower);
        final bStartsWith = b.name.toLowerCase().startsWith(queryLower);
        if (aStartsWith && !bStartsWith) return -1;
        if (bStartsWith && !aStartsWith) return 1;

        // Otherwise sort alphabetically
        return a.name.compareTo(b.name);
      });

      return Result.success(matchingCountries);
    } catch (e) {
      return Result.failure(
        CacheFailure('Failed to search countries: $e')
      );
    }
  }

  @override
  Future<Result<List<Country>>> getCountriesByRegion(String region) async {
    try {
      // Get all countries first
      final countriesResult = await getAllCountries();
      if (countriesResult.isFailure) {
        return Result.failure(countriesResult.failure!);
      }

      final allCountries = countriesResult.data!;
      final regionLower = region.toLowerCase();

      // Filter countries by region
      final regionCountries = allCountries.where((country) {
        return country.region?.toLowerCase() == regionLower;
      }).toList();

      // Sort alphabetically
      regionCountries.sort((a, b) => a.name.compareTo(b.name));

      return Result.success(regionCountries);
    } catch (e) {
      return Result.failure(
        CacheFailure('Failed to get countries by region: $e')
      );
    }
  }

  @override
  void clearCache() {
    _localDataSource.clearCache();
  }

  /// Gets life expectancy data for the most populous countries
  /// 
  /// [limit] - Maximum number of countries to return (default: 20)
  /// 
  /// Returns a Result containing a list of major countries
  Future<Result<List<Country>>> getMajorCountries({int limit = 20}) async {
    try {
      // Define major countries by population/importance
      const majorCountryCodes = [
        'CN', 'IN', 'US', 'ID', 'PK', 'BR', 'NG', 'BD', 'RU', 'MX',
        'JP', 'PH', 'ET', 'VN', 'EG', 'TR', 'IR', 'DE', 'TH', 'GB',
        'FR', 'IT', 'ZA', 'TZ', 'MM', 'KR', 'CO', 'KE', 'ES', 'UG',
        'AR', 'DZ', 'SD', 'UA', 'IQ', 'AF', 'PL', 'CA', 'MA', 'SA',
        'UZ', 'PE', 'MY', 'AO', 'MZ', 'GH', 'YE', 'NP', 'VE', 'MG',
      ];

      final limitedCodes = majorCountryCodes.take(limit).toList();
      
      // Get all countries
      final countriesResult = await getAllCountries();
      if (countriesResult.isFailure) {
        return Result.failure(countriesResult.failure!);
      }

      final allCountries = countriesResult.data!;
      
      // Filter to major countries and maintain order
      final majorCountries = <Country>[];
      for (final code in limitedCodes) {
        final country = allCountries.firstWhere(
          (c) => c.code == code,
          orElse: () => Country(code: code, name: code),
        );
        if (country.name != code) { // Only add if we found actual data
          majorCountries.add(country);
        }
      }

      return Result.success(majorCountries);
    } catch (e) {
      return Result.failure(
        CacheFailure('Failed to get major countries: $e')
      );
    }
  }

  /// Gets life expectancy statistics across all countries
  /// 
  /// Returns a Result containing global life expectancy statistics
  Future<Result<GlobalLifeExpectancyStats>> getGlobalStats() async {
    try {
      // Get all countries
      final countriesResult = await getAllCountries();
      if (countriesResult.isFailure) {
        return Result.failure(countriesResult.failure!);
      }

      final countries = countriesResult.data!;
      
      // Get life expectancy data for all countries
      final countryCodes = countries.map((c) => c.code).toList();
      final lifeExpectanciesResult = await getMultipleLifeExpectancies(countryCodes);
      if (lifeExpectanciesResult.isFailure) {
        return Result.failure(lifeExpectanciesResult.failure!);
      }

      final lifeExpectancies = lifeExpectanciesResult.data!.values.toList();
      
      if (lifeExpectancies.isEmpty) {
        return Result.failure(
          CacheFailure('No life expectancy data available')
        );
      }

      // Calculate statistics
      final values = lifeExpectancies.map((le) => le.yearsAtBirth).toList();
      values.sort();

      final average = values.reduce((a, b) => a + b) / values.length;
      final median = values.length % 2 == 0
          ? (values[values.length ~/ 2 - 1] + values[values.length ~/ 2]) / 2
          : values[values.length ~/ 2];
      final min = values.first;
      final max = values.last;

      final stats = GlobalLifeExpectancyStats(
        totalCountries: lifeExpectancies.length,
        averageLifeExpectancy: average,
        medianLifeExpectancy: median,
        minLifeExpectancy: min,
        maxLifeExpectancy: max,
        lastUpdated: DateTime.now(),
      );

      return Result.success(stats);
    } catch (e) {
      return Result.failure(
        CacheFailure('Failed to get global stats: $e')
      );
    }
  }
}

/// Global life expectancy statistics
class GlobalLifeExpectancyStats {
  final int totalCountries;
  final double averageLifeExpectancy;
  final double medianLifeExpectancy;
  final double minLifeExpectancy;
  final double maxLifeExpectancy;
  final DateTime lastUpdated;

  const GlobalLifeExpectancyStats({
    required this.totalCountries,
    required this.averageLifeExpectancy,
    required this.medianLifeExpectancy,
    required this.minLifeExpectancy,
    required this.maxLifeExpectancy,
    required this.lastUpdated,
  });

  @override
  String toString() => 
      'GlobalLifeExpectancyStats(countries: $totalCountries, '
      'average: ${averageLifeExpectancy.toStringAsFixed(1)}, '
      'range: ${minLifeExpectancy.toStringAsFixed(1)}-${maxLifeExpectancy.toStringAsFixed(1)})';
}
