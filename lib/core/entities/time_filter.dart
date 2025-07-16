/// Time filter entity for filtering mood data by time range
/// Following Clean Architecture principles - pure domain entity
enum TimeFilterType {
  day,
  week,
  month,
}

class TimeFilter {
  final TimeFilterType type;
  final String displayName;
  final Duration duration;

  const TimeFilter({
    required this.type,
    required this.displayName,
    required this.duration,
  });

  /// Predefined time filters
  static const TimeFilter day = TimeFilter(
    type: TimeFilterType.day,
    displayName: 'Day',
    duration: Duration(days: 1),
  );

  static const TimeFilter week = TimeFilter(
    type: TimeFilterType.week,
    displayName: 'Week',
    duration: Duration(days: 7),
  );

  static const TimeFilter month = TimeFilter(
    type: TimeFilterType.month,
    displayName: 'Month',
    duration: Duration(days: 30),
  );

  /// All available time filters
  static const List<TimeFilter> all = [day, week, month];

  /// Get time filter by type
  static TimeFilter fromType(TimeFilterType type) {
    switch (type) {
      case TimeFilterType.day:
        return day;
      case TimeFilterType.week:
        return week;
      case TimeFilterType.month:
        return month;
    }
  }

  /// Get the start date for this filter from a given reference date
  DateTime getStartDate(DateTime referenceDate) {
    switch (type) {
      case TimeFilterType.day:
        return DateTime(referenceDate.year, referenceDate.month, referenceDate.day);
      case TimeFilterType.week:
        final weekday = referenceDate.weekday;
        return referenceDate.subtract(Duration(days: weekday - 1));
      case TimeFilterType.month:
        return DateTime(referenceDate.year, referenceDate.month, 1);
    }
  }

  /// Get the end date for this filter from a given reference date
  DateTime getEndDate(DateTime referenceDate) {
    switch (type) {
      case TimeFilterType.day:
        return DateTime(referenceDate.year, referenceDate.month, referenceDate.day, 23, 59, 59);
      case TimeFilterType.week:
        final weekday = referenceDate.weekday;
        final startOfWeek = referenceDate.subtract(Duration(days: weekday - 1));
        return startOfWeek.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));
      case TimeFilterType.month:
        final nextMonth = referenceDate.month == 12 
            ? DateTime(referenceDate.year + 1, 1, 1)
            : DateTime(referenceDate.year, referenceDate.month + 1, 1);
        return nextMonth.subtract(const Duration(seconds: 1));
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TimeFilter &&
        other.type == type &&
        other.displayName == displayName &&
        other.duration == duration;
  }

  @override
  int get hashCode {
    return type.hashCode ^ displayName.hashCode ^ duration.hashCode;
  }

  @override
  String toString() {
    return 'TimeFilter(type: $type, displayName: $displayName, duration: $duration)';
  }
}
