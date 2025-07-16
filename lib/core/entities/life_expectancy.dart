/// Domain entity representing life expectancy data for a country
/// Contains life expectancy information from World Bank API
class LifeExpectancy {
  /// ISO 3166-1 alpha-2 country code
  final String countryCode;
  
  /// Life expectancy at birth in years
  final double yearsAtBirth;
  
  /// Year for which this life expectancy data is valid
  final int year;
  
  /// Timestamp when this data was fetched/cached
  final DateTime fetchedAt;
  
  /// Data source (e.g., "World Bank API")
  final String source;
  
  const LifeExpectancy({
    required this.countryCode,
    required this.yearsAtBirth,
    required this.year,
    required this.fetchedAt,
    this.source = 'World Bank API',
  });
  
  /// Validates that the life expectancy data is reasonable
  bool get isValid => 
      yearsAtBirth > 0 && 
      yearsAtBirth <= 150 && 
      year >= 1960 && 
      year <= DateTime.now().year &&
      countryCode.length == 2;
  
  /// Checks if the cached data is still fresh (less than 30 days old)
  bool get isFresh {
    final now = DateTime.now();
    final daysSinceFetch = now.difference(fetchedAt).inDays;
    return daysSinceFetch < 30;
  }
  
  /// Converts years to total days (approximate)
  int get totalDaysAtBirth => (yearsAtBirth * 365.25).round();
  
  /// Converts years to total weeks (approximate)
  int get totalWeeksAtBirth => (yearsAtBirth * 52.18).round();
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is LifeExpectancy &&
        other.countryCode == countryCode &&
        other.yearsAtBirth == yearsAtBirth &&
        other.year == year &&
        other.fetchedAt == fetchedAt &&
        other.source == source;
  }
  
  @override
  int get hashCode => 
      countryCode.hashCode ^ 
      yearsAtBirth.hashCode ^ 
      year.hashCode ^ 
      fetchedAt.hashCode ^ 
      source.hashCode;
  
  @override
  String toString() => 
      'LifeExpectancy(countryCode: $countryCode, yearsAtBirth: $yearsAtBirth, '
      'year: $year, fetchedAt: $fetchedAt, source: $source)';
}
