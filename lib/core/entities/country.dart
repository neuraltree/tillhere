/// Domain entity representing a country
/// Contains country information needed for life expectancy calculations
class Country {
  /// ISO 3166-1 alpha-2 country code (e.g., "US", "GB", "DE")
  final String code;
  
  /// Full country name (e.g., "United States", "United Kingdom", "Germany")
  final String name;
  
  /// ISO 3166-1 alpha-3 country code (e.g., "USA", "GBR", "DEU")
  final String? alpha3Code;
  
  /// Region or continent the country belongs to
  final String? region;
  
  const Country({
    required this.code,
    required this.name,
    this.alpha3Code,
    this.region,
  });
  
  /// Validates that the country code is a valid ISO 3166-1 alpha-2 code
  bool get isValidCode => code.length == 2 && code == code.toUpperCase();
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is Country &&
        other.code == code &&
        other.name == name &&
        other.alpha3Code == alpha3Code &&
        other.region == region;
  }
  
  @override
  int get hashCode => code.hashCode ^ name.hashCode ^ alpha3Code.hashCode ^ region.hashCode;
  
  @override
  String toString() => 'Country(code: $code, name: $name, alpha3Code: $alpha3Code, region: $region)';
}
