import '../../core/entities/user_settings.dart';

/// Data model for settings storage in SQLite
/// Handles serialization/deserialization of settings data
class SettingsModel {
  final String key;
  final String? value;
  final String type;
  final DateTime updatedAt;

  const SettingsModel({
    required this.key,
    this.value,
    required this.type,
    required this.updatedAt,
  });

  /// Creates a SettingsModel from a database map
  factory SettingsModel.fromMap(Map<String, dynamic> map) {
    return SettingsModel(
      key: map['key'] as String,
      value: map['value'] as String?,
      type: map['type'] as String,
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
    );
  }

  /// Converts the SettingsModel to a database map
  Map<String, dynamic> toMap() {
    return {
      'key': key,
      'value': value,
      'type': type,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  /// Creates a SettingsModel for a string value
  factory SettingsModel.string(String key, String? value) {
    return SettingsModel(
      key: key,
      value: value,
      type: 'string',
      updatedAt: DateTime.now(),
    );
  }

  /// Creates a SettingsModel for an integer value
  factory SettingsModel.integer(String key, int? value) {
    return SettingsModel(
      key: key,
      value: value?.toString(),
      type: 'integer',
      updatedAt: DateTime.now(),
    );
  }

  /// Creates a SettingsModel for a double value
  factory SettingsModel.double(String key, double? value) {
    return SettingsModel(
      key: key,
      value: value?.toString(),
      type: 'double',
      updatedAt: DateTime.now(),
    );
  }

  /// Creates a SettingsModel for a boolean value
  factory SettingsModel.boolean(String key, bool? value) {
    return SettingsModel(
      key: key,
      value: value?.toString(),
      type: 'boolean',
      updatedAt: DateTime.now(),
    );
  }

  /// Creates a SettingsModel for a DateTime value
  factory SettingsModel.dateTime(String key, DateTime? value) {
    return SettingsModel(
      key: key,
      value: value?.toIso8601String(),
      type: 'datetime',
      updatedAt: DateTime.now(),
    );
  }

  /// Gets the value as a string
  String? get stringValue => value;

  /// Gets the value as an integer
  int? get intValue => value != null ? int.tryParse(value!) : null;

  /// Gets the value as a double
  double? get doubleValue => value != null ? double.tryParse(value!) : null;

  /// Gets the value as a boolean
  bool? get boolValue => value != null ? value!.toLowerCase() == 'true' : null;

  /// Gets the value as a DateTime
  DateTime? get dateTimeValue => value != null ? DateTime.tryParse(value!) : null;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SettingsModel &&
        other.key == key &&
        other.value == value &&
        other.type == type &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode => key.hashCode ^ value.hashCode ^ type.hashCode ^ updatedAt.hashCode;

  @override
  String toString() => 'SettingsModel(key: $key, value: $value, type: $type, updatedAt: $updatedAt)';
}

/// Helper class for converting UserSettings to/from SettingsModel list
class UserSettingsMapper {
  // Settings keys
  static const String keyDateOfBirth = 'date_of_birth';
  static const String keyDeathDate = 'death_date';
  static const String keyCountryCode = 'country_code';
  static const String keyLifeExpectancyYears = 'life_expectancy_years';
  static const String keyLastCalculatedAt = 'last_calculated_at';
  static const String keyLocale = 'locale';
  static const String keyShowLifeExpectancy = 'show_life_expectancy';
  static const String keyShowWeeksRemaining = 'show_weeks_remaining';

  /// Converts UserSettings to a list of SettingsModel
  static List<SettingsModel> toModels(UserSettings settings) {
    final models = <SettingsModel>[];

    if (settings.dateOfBirth != null) {
      models.add(SettingsModel.dateTime(keyDateOfBirth, settings.dateOfBirth));
    }

    if (settings.deathDate != null) {
      models.add(SettingsModel.dateTime(keyDeathDate, settings.deathDate));
    }

    if (settings.countryCode != null) {
      models.add(SettingsModel.string(keyCountryCode, settings.countryCode));
    }

    if (settings.lifeExpectancyYears != null) {
      models.add(SettingsModel.double(keyLifeExpectancyYears, settings.lifeExpectancyYears));
    }

    if (settings.lastCalculatedAt != null) {
      models.add(SettingsModel.dateTime(keyLastCalculatedAt, settings.lastCalculatedAt));
    }

    if (settings.locale != null) {
      models.add(SettingsModel.string(keyLocale, settings.locale));
    }

    models.add(SettingsModel.boolean(keyShowLifeExpectancy, settings.showLifeExpectancy));
    models.add(SettingsModel.boolean(keyShowWeeksRemaining, settings.showWeeksRemaining));

    return models;
  }

  /// Converts a list of SettingsModel to UserSettings
  static UserSettings fromModels(List<SettingsModel> models) {
    final settingsMap = <String, SettingsModel>{};
    for (final model in models) {
      settingsMap[model.key] = model;
    }

    return UserSettings(
      dateOfBirth: settingsMap[keyDateOfBirth]?.dateTimeValue,
      deathDate: settingsMap[keyDeathDate]?.dateTimeValue,
      countryCode: settingsMap[keyCountryCode]?.stringValue,
      lifeExpectancyYears: settingsMap[keyLifeExpectancyYears]?.doubleValue,
      lastCalculatedAt: settingsMap[keyLastCalculatedAt]?.dateTimeValue,
      locale: settingsMap[keyLocale]?.stringValue,
      showLifeExpectancy: settingsMap[keyShowLifeExpectancy]?.boolValue ?? true,
      showWeeksRemaining: settingsMap[keyShowWeeksRemaining]?.boolValue ?? true,
    );
  }
}
