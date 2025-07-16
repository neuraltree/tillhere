import '../entities/life_expectancy.dart';
import '../entities/user_settings.dart';
import '../entities/week_range.dart';
import '../utils/result.dart';
import '../errors/failures.dart';
import '../../data/datasources/local/life_expectancy_local_datasource.dart';
import '../../data/datasources/local/locale_detection_service.dart';

/// Service for life expectancy calculations and week generation
/// Handles computing death dates and generating future weeks lists
class LifeExpectancyService {
  final LifeExpectancyLocalDataSource _lifeExpectancyDataSource;
  final LocaleDetectionService _localeDetectionService;

  LifeExpectancyService(this._lifeExpectancyDataSource, this._localeDetectionService);

  /// Computes the estimated death date based on date of birth and life expectancy
  ///
  /// [dateOfBirth] - User's date of birth
  /// [countryCode] - Country code for life expectancy lookup (optional, will detect if not provided)
  ///
  /// Returns a Result containing the computed death date and updated UserSettings
  Future<Result<UserSettings>> computeDeathDate(DateTime dateOfBirth, {String? countryCode}) async {
    try {
      // Validate date of birth
      if (dateOfBirth.isAfter(DateTime.now())) {
        return Result.failure(ValidationFailure('Date of birth cannot be in the future'));
      }

      // Get country code if not provided
      String finalCountryCode = countryCode ?? '';
      if (finalCountryCode.isEmpty) {
        final countryResult = await _localeDetectionService.detectCountryCode();
        if (countryResult.isFailure) {
          return Result.failure(countryResult.failure!);
        }
        finalCountryCode = countryResult.data!;
      }

      // Get life expectancy data for the country
      final lifeExpectancyResult = await _lifeExpectancyDataSource.getLifeExpectancy(finalCountryCode);
      if (lifeExpectancyResult.isFailure) {
        return Result.failure(lifeExpectancyResult.failure!);
      }

      final lifeExpectancy = lifeExpectancyResult.data!;

      // Calculate death date
      final deathDate = _calculateDeathDate(dateOfBirth, lifeExpectancy.yearsAtBirth);

      // Create updated user settings
      final userSettings = UserSettings(
        dateOfBirth: dateOfBirth,
        deathDate: deathDate,
        countryCode: finalCountryCode,
        lifeExpectancyYears: lifeExpectancy.yearsAtBirth,
        lastCalculatedAt: DateTime.now(),
        locale: finalCountryCode.toLowerCase(),
        showLifeExpectancy: true,
        showWeeksRemaining: true,
      );

      return Result.success(userSettings);
    } catch (e) {
      return Result.failure(ValidationFailure('Failed to compute death date: $e'));
    }
  }

  /// Updates an existing UserSettings with fresh life expectancy data
  ///
  /// [currentSettings] - Current user settings
  /// [forceRefresh] - Whether to force refresh even if data is fresh
  ///
  /// Returns a Result containing updated UserSettings
  Future<Result<UserSettings>> updateLifeExpectancy(UserSettings currentSettings, {bool forceRefresh = false}) async {
    try {
      // Check if we have the required data
      if (currentSettings.dateOfBirth == null || currentSettings.countryCode == null) {
        return Result.failure(ValidationFailure('Date of birth and country code are required'));
      }

      // Check if refresh is needed
      if (!forceRefresh && currentSettings.isCalculationFresh) {
        return Result.success(currentSettings);
      }

      // Recompute with fresh data
      return await computeDeathDate(currentSettings.dateOfBirth!, countryCode: currentSettings.countryCode);
    } catch (e) {
      return Result.failure(ValidationFailure('Failed to update life expectancy: $e'));
    }
  }

  /// Generates a list of future weeks from today to the estimated death date
  ///
  /// [userSettings] - User settings containing date of birth and death date
  /// [startFrom] - Optional start date (defaults to today)
  /// [maxWeeks] - Maximum number of weeks to generate (optional limit)
  ///
  /// Returns a Result containing a list of WeekRange objects
  Future<Result<List<WeekRange>>> generateFutureWeeks(
    UserSettings userSettings, {
    DateTime? startFrom,
    int? maxWeeks,
  }) async {
    try {
      // Validate required data
      if (userSettings.dateOfBirth == null || userSettings.deathDate == null) {
        return Result.failure(ValidationFailure('Date of birth and death date are required'));
      }

      final birthDate = userSettings.dateOfBirth!;
      final deathDate = userSettings.deathDate!;
      final start = startFrom ?? DateTime.now();

      // Generate weeks
      final weeks = WeekRange.generateFutureWeeks(birthDate, deathDate, startFrom: start);

      // Apply max weeks limit if specified
      final limitedWeeks = maxWeeks != null && weeks.length > maxWeeks ? weeks.take(maxWeeks).toList() : weeks;

      return Result.success(limitedWeeks);
    } catch (e) {
      return Result.failure(ValidationFailure('Failed to generate future weeks: $e'));
    }
  }

  /// Gets statistics about the user's life expectancy
  ///
  /// [userSettings] - User settings containing life expectancy data
  ///
  /// Returns a Result containing life expectancy statistics
  Future<Result<LifeExpectancyStats>> getLifeExpectancyStats(UserSettings userSettings) async {
    try {
      if (userSettings.dateOfBirth == null || userSettings.deathDate == null) {
        return Result.failure(ValidationFailure('Date of birth and death date are required'));
      }

      final now = DateTime.now();
      final birthDate = userSettings.dateOfBirth!;
      final deathDate = userSettings.deathDate!;

      // Calculate various statistics
      final totalLifeExpectancyDays = deathDate.difference(birthDate).inDays;
      final totalLifeExpectancyWeeks = (totalLifeExpectancyDays / 7).floor();

      final daysLived = now.difference(birthDate).inDays;
      final weeksLived = (daysLived / 7).floor();

      final daysRemaining = deathDate.difference(now).inDays.clamp(0, double.infinity).toInt();
      final weeksRemaining = (daysRemaining / 7).floor();

      final percentageLived = (daysLived / totalLifeExpectancyDays * 100).clamp(0, 100).toDouble();

      final stats = LifeExpectancyStats(
        totalLifeExpectancyYears: userSettings.lifeExpectancyYears ?? 0,
        totalLifeExpectancyWeeks: totalLifeExpectancyWeeks,
        totalLifeExpectancyDays: totalLifeExpectancyDays,
        weeksLived: weeksLived,
        daysLived: daysLived,
        weeksRemaining: weeksRemaining,
        daysRemaining: daysRemaining,
        percentageLived: percentageLived,
        currentAge: userSettings.currentAgeInYears ?? 0,
        countryCode: userSettings.countryCode ?? '',
        lastUpdated: userSettings.lastCalculatedAt ?? DateTime.now(),
      );

      return Result.success(stats);
    } catch (e) {
      return Result.failure(ValidationFailure('Failed to get life expectancy stats: $e'));
    }
  }

  /// Calculates the estimated death date from date of birth and life expectancy
  DateTime _calculateDeathDate(DateTime dateOfBirth, double lifeExpectancyYears) {
    // Convert years to days (accounting for leap years approximately)
    final totalDays = (lifeExpectancyYears * 365.25).round();

    // Add to date of birth
    return dateOfBirth.add(Duration(days: totalDays));
  }

  /// Validates that user settings have the minimum required data for calculations
  bool hasRequiredData(UserSettings settings) {
    return settings.dateOfBirth != null && settings.countryCode != null && settings.isValid;
  }

  /// Checks if the life expectancy data needs to be refreshed
  bool needsRefresh(UserSettings settings) {
    return !settings.isCalculationFresh || settings.deathDate == null || settings.lifeExpectancyYears == null;
  }
}

/// Statistics about user's life expectancy
class LifeExpectancyStats {
  final double totalLifeExpectancyYears;
  final int totalLifeExpectancyWeeks;
  final int totalLifeExpectancyDays;
  final int weeksLived;
  final int daysLived;
  final int weeksRemaining;
  final int daysRemaining;
  final double percentageLived;
  final int currentAge;
  final String countryCode;
  final DateTime lastUpdated;

  const LifeExpectancyStats({
    required this.totalLifeExpectancyYears,
    required this.totalLifeExpectancyWeeks,
    required this.totalLifeExpectancyDays,
    required this.weeksLived,
    required this.daysLived,
    required this.weeksRemaining,
    required this.daysRemaining,
    required this.percentageLived,
    required this.currentAge,
    required this.countryCode,
    required this.lastUpdated,
  });

  @override
  String toString() =>
      'LifeExpectancyStats(totalYears: $totalLifeExpectancyYears, '
      'weeksLived: $weeksLived, weeksRemaining: $weeksRemaining, '
      'percentageLived: ${percentageLived.toStringAsFixed(1)}%)';
}
