/// Domain entity representing a date range for querying mood entries
class DateRange {
  /// Start date of the range (inclusive)
  final DateTime startDate;
  
  /// End date of the range (inclusive)
  final DateTime endDate;

  const DateRange({
    required this.startDate,
    required this.endDate,
  });

  /// Validates that the date range is valid (start <= end)
  bool get isValid => startDate.isBefore(endDate) || startDate.isAtSameMomentAs(endDate);

  /// Returns the duration of this date range
  Duration get duration => endDate.difference(startDate);

  /// Checks if a given date falls within this range
  bool contains(DateTime date) {
    return (date.isAfter(startDate) || date.isAtSameMomentAs(startDate)) &&
           (date.isBefore(endDate) || date.isAtSameMomentAs(endDate));
  }

  /// Creates a date range for today
  factory DateRange.today() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);
    return DateRange(startDate: startOfDay, endDate: endOfDay);
  }

  /// Creates a date range for the current week
  factory DateRange.thisWeek() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startOfDay = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    final endOfWeek = startOfDay.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59, milliseconds: 999));
    return DateRange(startDate: startOfDay, endDate: endOfWeek);
  }

  /// Creates a date range for the current month
  factory DateRange.thisMonth() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59, 999);
    return DateRange(startDate: startOfMonth, endDate: endOfMonth);
  }

  /// Creates a date range for the last N days
  factory DateRange.lastDays(int days) {
    final now = DateTime.now();
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);
    final startDate = endOfDay.subtract(Duration(days: days - 1));
    final startOfDay = DateTime(startDate.year, startDate.month, startDate.day);
    return DateRange(startDate: startOfDay, endDate: endOfDay);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is DateRange &&
        other.startDate == startDate &&
        other.endDate == endDate;
  }

  @override
  int get hashCode => startDate.hashCode ^ endDate.hashCode;

  @override
  String toString() => 'DateRange(startDate: $startDate, endDate: $endDate)';
}
