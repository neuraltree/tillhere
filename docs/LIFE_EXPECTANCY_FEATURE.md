# Life Expectancy Feature Documentation

## Overview

The Life Expectancy feature provides functionality to:
- Fetch life expectancy data for device locale via World Bank API data (cached locally)
- Compute estimated death date based on date of birth + life expectancy
- Store user settings including date of birth and computed death date in the settings table
- Generate list of future weeks from today to estimated death date (past weeks are ignored)

## Architecture

The feature follows Clean Architecture principles with clear separation of concerns:

```
├── Core Layer
│   ├── Entities (Domain Models)
│   ├── Repositories (Interfaces)
│   └── Services (Business Logic)
├── Data Layer
│   ├── Models (Data Transfer Objects)
│   ├── DataSources (Local/Remote)
│   └── Repositories (Implementations)
└── Presentation Layer
    └── UI Components
```

## Key Components

### 1. Domain Entities

#### LifeExpectancy
Represents life expectancy data for a country.

```dart
final lifeExpectancy = LifeExpectancy(
  countryCode: 'US',
  yearsAtBirth: 78.5,
  year: 2023,
  fetchedAt: DateTime.now(),
  source: 'World Bank API',
);
```

**Properties:**
- `countryCode`: ISO 3166-1 alpha-2 country code
- `yearsAtBirth`: Life expectancy at birth in years
- `year`: Year for which this data is valid
- `fetchedAt`: When the data was cached
- `source`: Data source identifier

**Methods:**
- `isValid`: Validates data integrity
- `isFresh`: Checks if cached data is still fresh (< 30 days)
- `totalDaysAtBirth`: Converts years to approximate days
- `totalWeeksAtBirth`: Converts years to approximate weeks

#### UserSettings
Represents user configuration and life expectancy calculations.

```dart
final settings = UserSettings(
  dateOfBirth: DateTime(1990, 5, 15),
  deathDate: DateTime(2070, 5, 15),
  countryCode: 'US',
  lifeExpectancyYears: 80.0,
  lastCalculatedAt: DateTime.now(),
);
```

**Properties:**
- `dateOfBirth`: User's date of birth
- `deathDate`: Computed estimated death date
- `countryCode`: Country for life expectancy calculation
- `lifeExpectancyYears`: Life expectancy used for calculation
- `lastCalculatedAt`: When death date was last calculated
- `showLifeExpectancy`: UI preference flag
- `showWeeksRemaining`: UI preference flag

**Methods:**
- `isValid`: Validates settings consistency
- `hasBasicSetup`: Checks if minimum required data is present
- `isCalculationFresh`: Checks if calculation is up to date
- `currentAgeInYears`: Calculates current age
- `weeksLived`: Calculates weeks lived so far
- `weeksRemaining`: Calculates weeks until estimated death

#### WeekRange
Represents a week range for life expectancy calculations.

```dart
final week = WeekRange.fromWeekNumber(0, birthDate);
final weeks = WeekRange.generateFutureWeeks(birthDate, deathDate);
```

**Properties:**
- `startDate`: Start of week (Monday)
- `endDate`: End of week (Sunday)
- `weekNumber`: Week number since birth (0-based)
- `isPast`: Whether this week has passed
- `isCurrent`: Whether this is the current week

**Methods:**
- `fromWeekNumber`: Creates week from week number since birth
- `generateFutureWeeks`: Generates list of future weeks
- `contains`: Checks if date falls within week
- `formattedRange`: Returns formatted date range string

### 2. Data Sources

#### LifeExpectancyLocalDataSource
Reads life expectancy data from bundled JSON asset file.

```dart
final dataSource = LifeExpectancyLocalDataSource();
final result = await dataSource.getLifeExpectancy('US');
```

**Methods:**
- `getLifeExpectancy(countryCode)`: Gets data for specific country
- `getMultipleLifeExpectancies(countryCodes)`: Gets data for multiple countries
- `getAllCountries()`: Gets all available countries
- `hasDataForCountry(countryCode)`: Checks data availability
- `getMetadata()`: Gets dataset metadata

#### LocaleDetectionService
Detects device locale and maps to country codes.

```dart
final service = LocaleDetectionService();
final result = await service.detectCountryCode();
```

**Methods:**
- `detectCountryCode()`: Detects device country code
- `detectCountry()`: Detects device country entity
- `isCountrySupported(countryCode)`: Checks if country is supported
- `getSupportedCountryCodes()`: Gets all supported countries

### 3. Services

#### LifeExpectancyService
Core business logic for life expectancy calculations.

```dart
final service = LifeExpectancyService(dataSource, localeService);
final result = await service.computeDeathDate(dateOfBirth);
```

**Methods:**
- `computeDeathDate(dateOfBirth, countryCode?)`: Computes death date
- `updateLifeExpectancy(settings, forceRefresh?)`: Updates life expectancy data
- `generateFutureWeeks(settings, startFrom?, maxWeeks?)`: Generates future weeks
- `getLifeExpectancyStats(settings)`: Gets detailed statistics
- `hasRequiredData(settings)`: Validates required data
- `needsRefresh(settings)`: Checks if refresh is needed

### 4. Repositories

#### SettingsRepository
Interface for user settings management.

```dart
final repository = SettingsRepositoryImpl(databaseHelper);
final result = await repository.getUserSettings();
```

**Methods:**
- `getUserSettings()`: Gets current user settings
- `updateUserSettings(settings)`: Updates user settings
- `getSetting(key)`: Gets specific setting value
- `setSetting(key, value)`: Sets specific setting value
- Type-specific getters/setters for bool, int, double, DateTime

#### LifeExpectancyRepository
Interface for life expectancy data operations.

```dart
final repository = LifeExpectancyRepositoryImpl(dataSource);
final result = await repository.getLifeExpectancy('US');
```

**Methods:**
- `getLifeExpectancy(countryCode)`: Gets life expectancy for country
- `getMultipleLifeExpectancies(countryCodes)`: Gets data for multiple countries
- `getAllCountries()`: Gets all available countries
- `searchCountries(query)`: Searches countries by name/code
- `getCountriesByRegion(region)`: Gets countries by region

## Database Schema

### Settings Table
```sql
CREATE TABLE settings (
  key TEXT PRIMARY KEY,
  value TEXT,
  type TEXT NOT NULL DEFAULT 'string',
  updated_at INTEGER NOT NULL
);
```

**Key Settings:**
- `date_of_birth`: User's date of birth (datetime)
- `death_date`: Computed death date (datetime)
- `country_code`: Country code for life expectancy (string)
- `life_expectancy_years`: Life expectancy in years (double)
- `last_calculated_at`: Last calculation timestamp (datetime)
- `locale`: User's locale (string)
- `show_life_expectancy`: Show life expectancy features (boolean)
- `show_weeks_remaining`: Show weeks remaining (boolean)

## Data Source

Life expectancy data is sourced from the World Bank API and cached locally as a JSON asset file:

- **Source**: World Bank Data API
- **Indicator**: SP.DYN.LE00.IN (Life expectancy at birth, total years)
- **URL**: `https://api.worldbank.org/v2/country/{code}/indicator/SP.DYN.LE00.IN?format=json`
- **Cache Location**: `assets/life_expectancy.json`
- **Update Frequency**: Data is fetched once and bundled with the app

### Data Structure
```json
{
  "metadata": {
    "source": "World Bank API",
    "indicator": "SP.DYN.LE00.IN",
    "description": "Life expectancy at birth, total (years)",
    "generatedAt": "2024-01-15T10:30:00Z",
    "totalCountries": 195
  },
  "countries": {
    "US": {
      "name": "United States",
      "iso3": "USA",
      "lifeExpectancy": 78.9,
      "year": 2023,
      "lastUpdated": "2024-01-15T10:30:00Z"
    }
  }
}
```

## Usage Examples

### Basic Setup
```dart
// Initialize services
final lifeExpectancyService = LifeExpectancyService(
  LifeExpectancyLocalDataSource(),
  LocaleDetectionService(),
);

// Compute death date
final result = await lifeExpectancyService.computeDeathDate(
  DateTime(1990, 5, 15), // Date of birth
);

if (result.isSuccess) {
  final settings = result.data!;
  print('Death date: ${settings.deathDate}');
  print('Life expectancy: ${settings.lifeExpectancyYears} years');
}
```

### Generate Future Weeks
```dart
// Generate next 52 weeks
final weeksResult = await lifeExpectancyService.generateFutureWeeks(
  settings,
  maxWeeks: 52,
);

if (weeksResult.isSuccess) {
  final weeks = weeksResult.data!;
  for (final week in weeks) {
    print('Week ${week.weekNumber}: ${week.formattedRange}');
  }
}
```

### Get Statistics
```dart
final statsResult = await lifeExpectancyService.getLifeExpectancyStats(settings);

if (statsResult.isSuccess) {
  final stats = statsResult.data!;
  print('Weeks lived: ${stats.weeksLived}');
  print('Weeks remaining: ${stats.weeksRemaining}');
  print('Percentage lived: ${stats.percentageLived.toStringAsFixed(1)}%');
}
```

## Error Handling

The feature uses a `Result<T>` type for consistent error handling:

```dart
final result = await service.computeDeathDate(dateOfBirth);

if (result.isSuccess) {
  final data = result.data!;
  // Handle success
} else {
  final error = result.failure!;
  // Handle error
}
```

**Common Error Types:**
- `ValidationFailure`: Invalid input data
- `NetworkFailure`: Data source issues
- `CacheFailure`: Local data access issues
- `DatabaseFailure`: Database operation issues

## Testing

Comprehensive unit tests are provided for all components:

- `test/core/entities/` - Entity tests
- `test/core/services/` - Service tests
- `test/data/datasources/` - Data source tests
- `test/data/repositories/` - Repository tests

Run tests with:
```bash
flutter test
```

## Performance Considerations

- Life expectancy data is cached locally to avoid network requests
- Database operations use transactions for consistency
- Week generation is optimized to exclude past weeks
- Settings are cached in memory after first load

## Future Enhancements

- Support for gender-specific life expectancy
- Regional life expectancy variations
- Health factor adjustments
- Historical life expectancy trends
- Comparative analysis with other countries

## Dependencies

- `sqflite`: Local database storage
- `flutter/services`: Asset loading
- `dart:ui`: Locale detection
- `dart:convert`: JSON parsing
- `dart:io`: Platform detection

## Quick Start

1. **Add the life expectancy asset to pubspec.yaml:**
```yaml
flutter:
  assets:
    - assets/life_expectancy.json
```

2. **Initialize the services:**
```dart
final lifeExpectancyService = LifeExpectancyService(
  LifeExpectancyLocalDataSource(),
  LocaleDetectionService(),
);
```

3. **Set up user's life expectancy:**
```dart
final result = await lifeExpectancyService.computeDeathDate(
  DateTime(1990, 5, 15), // User's date of birth
);
```

4. **Generate future weeks:**
```dart
final weeks = await lifeExpectancyService.generateFutureWeeks(settings);
```

See `example/life_expectancy_example.dart` for complete usage examples.
