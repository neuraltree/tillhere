import '../entities/life_expectancy.dart';
import '../entities/country.dart';
import '../utils/result.dart';

/// Repository interface for life expectancy data operations
/// Defines the contract for life expectancy data access
abstract class LifeExpectancyRepository {
  /// Gets life expectancy data for a specific country
  /// 
  /// [countryCode] - ISO 3166-1 alpha-2 country code (e.g., "US", "GB")
  /// 
  /// Returns a Result containing LifeExpectancy data or a Failure
  Future<Result<LifeExpectancy>> getLifeExpectancy(String countryCode);

  /// Gets life expectancy data for multiple countries
  /// 
  /// [countryCodes] - List of ISO 3166-1 alpha-2 country codes
  /// 
  /// Returns a Result containing a Map of country code to LifeExpectancy data
  Future<Result<Map<String, LifeExpectancy>>> getMultipleLifeExpectancies(
    List<String> countryCodes,
  );

  /// Gets all available countries with life expectancy data
  /// 
  /// Returns a Result containing a list of all available countries
  Future<Result<List<Country>>> getAllCountries();

  /// Checks if life expectancy data is available for a specific country
  /// 
  /// [countryCode] - ISO 3166-1 alpha-2 country code
  /// 
  /// Returns true if data is available, false otherwise
  Future<bool> hasDataForCountry(String countryCode);

  /// Gets metadata about the life expectancy dataset
  /// 
  /// Returns a Result containing metadata information
  Future<Result<Map<String, dynamic>>> getMetadata();

  /// Searches for countries by name or code
  /// 
  /// [query] - Search query (country name or code)
  /// 
  /// Returns a Result containing a list of matching countries
  Future<Result<List<Country>>> searchCountries(String query);

  /// Gets life expectancy data for countries in a specific region
  /// 
  /// [region] - Region name or code
  /// 
  /// Returns a Result containing a list of countries in the region
  Future<Result<List<Country>>> getCountriesByRegion(String region);

  /// Clears any cached data (useful for testing or forcing reload)
  void clearCache();
}
