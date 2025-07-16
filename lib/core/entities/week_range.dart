/// Domain entity representing a week range for life expectancy calculations
/// Used to generate lists of future weeks from today to estimated death date
class WeekRange {
  /// Start date of the week (typically Monday)
  final DateTime startDate;
  
  /// End date of the week (typically Sunday)
  final DateTime endDate;
  
  /// Week number since birth (0-based)
  final int weekNumber;
  
  /// Whether this week has already passed
  final bool isPast;
  
  /// Whether this is the current week
  final bool isCurrent;
  
  const WeekRange({
    required this.startDate,
    required this.endDate,
    required this.weekNumber,
    required this.isPast,
    required this.isCurrent,
  });
  
  /// Creates a WeekRange for a specific week number since birth
  factory WeekRange.fromWeekNumber(
    int weekNumber,
    DateTime birthDate, {
    DateTime? referenceDate,
  }) {
    final reference = referenceDate ?? DateTime.now();
    
    // Calculate the start of the week (Monday)
    final weekStart = birthDate.add(Duration(days: weekNumber * 7));
    final mondayStart = weekStart.subtract(Duration(days: weekStart.weekday - 1));
    final startOfDay = DateTime(mondayStart.year, mondayStart.month, mondayStart.day);
    
    // Calculate the end of the week (Sunday)
    final endOfWeek = startOfDay.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59, milliseconds: 999));
    
    // Determine if this week is past, current, or future
    final now = DateTime.now();
    final currentWeekStart = now.subtract(Duration(days: now.weekday - 1));
    final currentWeekStartOfDay = DateTime(currentWeekStart.year, currentWeekStart.month, currentWeekStart.day);
    
    final isPast = endOfWeek.isBefore(currentWeekStartOfDay);
    final isCurrent = startOfDay.isAtSameMomentAs(currentWeekStartOfDay) || 
                     (startOfDay.isBefore(now) && endOfWeek.isAfter(now));
    
    return WeekRange(
      startDate: startOfDay,
      endDate: endOfWeek,
      weekNumber: weekNumber,
      isPast: isPast,
      isCurrent: isCurrent,
    );
  }
  
  /// Creates a list of WeekRange objects from today to death date
  static List<WeekRange> generateFutureWeeks(
    DateTime birthDate,
    DateTime deathDate, {
    DateTime? startFrom,
  }) {
    final start = startFrom ?? DateTime.now();
    final weeks = <WeekRange>[];
    
    // Calculate the current week number since birth
    final daysSinceBirth = start.difference(birthDate).inDays;
    final currentWeekNumber = (daysSinceBirth / 7).floor();
    
    // Calculate the total weeks until death
    final totalDaysToDeath = deathDate.difference(birthDate).inDays;
    final totalWeeksToDeath = (totalDaysToDeath / 7).floor();
    
    // Generate weeks from current week to death
    for (int weekNum = currentWeekNumber; weekNum <= totalWeeksToDeath; weekNum++) {
      final week = WeekRange.fromWeekNumber(weekNum, birthDate);
      
      // Only include weeks that haven't completely passed
      if (!week.isPast) {
        weeks.add(week);
      }
    }
    
    return weeks;
  }
  
  /// Duration of this week
  Duration get duration => endDate.difference(startDate);
  
  /// Checks if a given date falls within this week
  bool contains(DateTime date) {
    return (date.isAfter(startDate) || date.isAtSameMomentAs(startDate)) &&
           (date.isBefore(endDate) || date.isAtSameMomentAs(endDate));
  }
  
  /// Returns a formatted string representation of the week
  String get formattedRange {
    final startFormatted = '${startDate.day}/${startDate.month}/${startDate.year}';
    final endFormatted = '${endDate.day}/${endDate.month}/${endDate.year}';
    return '$startFormatted - $endFormatted';
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is WeekRange &&
        other.startDate == startDate &&
        other.endDate == endDate &&
        other.weekNumber == weekNumber &&
        other.isPast == isPast &&
        other.isCurrent == isCurrent;
  }
  
  @override
  int get hashCode => 
      startDate.hashCode ^
      endDate.hashCode ^
      weekNumber.hashCode ^
      isPast.hashCode ^
      isCurrent.hashCode;
  
  @override
  String toString() => 
      'WeekRange(weekNumber: $weekNumber, startDate: $startDate, endDate: $endDate, '
      'isPast: $isPast, isCurrent: $isCurrent)';
}
