import '../../core/entities/life_expectancy.dart';

/// Data model for World Bank API response
/// Represents the structure of the life expectancy API response
class WorldBankResponseModel {
  final List<WorldBankIndicatorModel> indicators;
  
  const WorldBankResponseModel({
    required this.indicators,
  });
  
  /// Creates a WorldBankResponseModel from JSON response
  factory WorldBankResponseModel.fromJson(List<dynamic> json) {
    // World Bank API returns an array where the second element contains the data
    if (json.length < 2 || json[1] == null) {
      return const WorldBankResponseModel(indicators: []);
    }
    
    final dataList = json[1] as List<dynamic>;
    final indicators = dataList
        .map((item) => WorldBankIndicatorModel.fromJson(item as Map<String, dynamic>))
        .where((indicator) => indicator.value != null) // Filter out null values
        .toList();
    
    return WorldBankResponseModel(indicators: indicators);
  }
  
  /// Converts to domain entity
  LifeExpectancy? toEntity(String countryCode) {
    if (indicators.isEmpty) return null;
    
    // Get the most recent data point
    final sortedIndicators = List<WorldBankIndicatorModel>.from(indicators)
      ..sort((a, b) => b.date.compareTo(a.date));
    
    final mostRecent = sortedIndicators.first;
    
    return LifeExpectancy(
      countryCode: countryCode,
      yearsAtBirth: mostRecent.value!,
      year: mostRecent.date,
      fetchedAt: DateTime.now(),
      source: 'World Bank API',
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'indicators': indicators.map((indicator) => indicator.toJson()).toList(),
    };
  }
}

/// Data model for individual World Bank indicator data point
class WorldBankIndicatorModel {
  final String indicatorId;
  final String indicatorValue;
  final String countryId;
  final String countryValue;
  final int date;
  final double? value;
  final String? unit;
  final String? obsStatus;
  final int? decimal;
  
  const WorldBankIndicatorModel({
    required this.indicatorId,
    required this.indicatorValue,
    required this.countryId,
    required this.countryValue,
    required this.date,
    this.value,
    this.unit,
    this.obsStatus,
    this.decimal,
  });
  
  /// Creates a WorldBankIndicatorModel from JSON
  factory WorldBankIndicatorModel.fromJson(Map<String, dynamic> json) {
    return WorldBankIndicatorModel(
      indicatorId: json['indicator']?['id'] ?? '',
      indicatorValue: json['indicator']?['value'] ?? '',
      countryId: json['country']?['id'] ?? '',
      countryValue: json['country']?['value'] ?? '',
      date: json['date'] ?? 0,
      value: json['value']?.toDouble(),
      unit: json['unit'],
      obsStatus: json['obs_status'],
      decimal: json['decimal'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'indicator': {
        'id': indicatorId,
        'value': indicatorValue,
      },
      'country': {
        'id': countryId,
        'value': countryValue,
      },
      'date': date,
      'value': value,
      'unit': unit,
      'obs_status': obsStatus,
      'decimal': decimal,
    };
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is WorldBankIndicatorModel &&
        other.indicatorId == indicatorId &&
        other.countryId == countryId &&
        other.date == date &&
        other.value == value;
  }
  
  @override
  int get hashCode => 
      indicatorId.hashCode ^ 
      countryId.hashCode ^ 
      date.hashCode ^ 
      value.hashCode;
  
  @override
  String toString() => 
      'WorldBankIndicatorModel(countryId: $countryId, date: $date, value: $value)';
}
