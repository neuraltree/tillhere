/// Domain entity representing user settings and life expectancy calculations
/// Contains user's date of birth, computed death date, and related settings
class UserSettings {
  /// User's date of birth
  final DateTime? dateOfBirth;
  
  /// Computed estimated death date (dateOfBirth + life expectancy)
  final DateTime? deathDate;
  
  /// Country code for life expectancy calculation
  final String? countryCode;
  
  /// Life expectancy in years used for calculation
  final double? lifeExpectancyYears;
  
  /// Timestamp when death date was last calculated
  final DateTime? lastCalculatedAt;
  
  /// User's preferred locale/language
  final String? locale;
  
  /// Whether to show life expectancy features in the app
  final bool showLifeExpectancy;
  
  /// Whether to show weeks remaining in various UI elements
  final bool showWeeksRemaining;
  
  const UserSettings({
    this.dateOfBirth,
    this.deathDate,
    this.countryCode,
    this.lifeExpectancyYears,
    this.lastCalculatedAt,
    this.locale,
    this.showLifeExpectancy = true,
    this.showWeeksRemaining = true,
  });
  
  /// Validates that the user settings are consistent
  bool get isValid {
    // If date of birth is set, it should be in the past
    if (dateOfBirth != null && dateOfBirth!.isAfter(DateTime.now())) {
      return false;
    }
    
    // If death date is set, it should be after date of birth
    if (dateOfBirth != null && deathDate != null && deathDate!.isBefore(dateOfBirth!)) {
      return false;
    }
    
    // Life expectancy should be reasonable if set
    if (lifeExpectancyYears != null && (lifeExpectancyYears! <= 0 || lifeExpectancyYears! > 150)) {
      return false;
    }
    
    return true;
  }
  
  /// Checks if the user has completed the basic setup (date of birth and country)
  bool get hasBasicSetup => dateOfBirth != null && countryCode != null;
  
  /// Checks if the death date calculation is up to date (less than 30 days old)
  bool get isCalculationFresh {
    if (lastCalculatedAt == null) return false;
    final daysSinceCalculation = DateTime.now().difference(lastCalculatedAt!).inDays;
    return daysSinceCalculation < 30;
  }
  
  /// Calculates the user's current age in years
  int? get currentAgeInYears {
    if (dateOfBirth == null) return null;
    final now = DateTime.now();
    int age = now.year - dateOfBirth!.year;
    if (now.month < dateOfBirth!.month || 
        (now.month == dateOfBirth!.month && now.day < dateOfBirth!.day)) {
      age--;
    }
    return age;
  }
  
  /// Calculates weeks lived so far
  int? get weeksLived {
    if (dateOfBirth == null) return null;
    final now = DateTime.now();
    final daysSinceBirth = now.difference(dateOfBirth!).inDays;
    return (daysSinceBirth / 7).floor();
  }
  
  /// Calculates weeks remaining until estimated death date
  int? get weeksRemaining {
    if (deathDate == null) return null;
    final now = DateTime.now();
    if (now.isAfter(deathDate!)) return 0;
    final daysRemaining = deathDate!.difference(now).inDays;
    return (daysRemaining / 7).floor();
  }
  
  /// Creates a copy of the settings with updated values
  UserSettings copyWith({
    DateTime? dateOfBirth,
    DateTime? deathDate,
    String? countryCode,
    double? lifeExpectancyYears,
    DateTime? lastCalculatedAt,
    String? locale,
    bool? showLifeExpectancy,
    bool? showWeeksRemaining,
  }) {
    return UserSettings(
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      deathDate: deathDate ?? this.deathDate,
      countryCode: countryCode ?? this.countryCode,
      lifeExpectancyYears: lifeExpectancyYears ?? this.lifeExpectancyYears,
      lastCalculatedAt: lastCalculatedAt ?? this.lastCalculatedAt,
      locale: locale ?? this.locale,
      showLifeExpectancy: showLifeExpectancy ?? this.showLifeExpectancy,
      showWeeksRemaining: showWeeksRemaining ?? this.showWeeksRemaining,
    );
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is UserSettings &&
        other.dateOfBirth == dateOfBirth &&
        other.deathDate == deathDate &&
        other.countryCode == countryCode &&
        other.lifeExpectancyYears == lifeExpectancyYears &&
        other.lastCalculatedAt == lastCalculatedAt &&
        other.locale == locale &&
        other.showLifeExpectancy == showLifeExpectancy &&
        other.showWeeksRemaining == showWeeksRemaining;
  }
  
  @override
  int get hashCode => 
      dateOfBirth.hashCode ^
      deathDate.hashCode ^
      countryCode.hashCode ^
      lifeExpectancyYears.hashCode ^
      lastCalculatedAt.hashCode ^
      locale.hashCode ^
      showLifeExpectancy.hashCode ^
      showWeeksRemaining.hashCode;
  
  @override
  String toString() => 
      'UserSettings(dateOfBirth: $dateOfBirth, deathDate: $deathDate, '
      'countryCode: $countryCode, lifeExpectancyYears: $lifeExpectancyYears, '
      'lastCalculatedAt: $lastCalculatedAt, locale: $locale, '
      'showLifeExpectancy: $showLifeExpectancy, showWeeksRemaining: $showWeeksRemaining)';
}
