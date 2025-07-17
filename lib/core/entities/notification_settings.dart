/// Domain entity representing notification settings for mood tracking reminders
/// Contains notification schedule, timing, and customization options
class NotificationSettings {
  /// Unique identifier for the notification setting
  final String id;
  
  /// Whether this notification is enabled
  final bool enabled;
  
  /// Title of the notification
  final String title;
  
  /// Body text of the notification
  final String body;
  
  /// Type of schedule: 'daily', 'weekly', 'custom'
  final NotificationScheduleType scheduleType;
  
  /// Time of day for the notification in HH:mm format (24-hour)
  final String time;
  
  /// Days of the week for weekly schedules (1=Monday, 7=Sunday)
  /// Null for daily schedules
  final List<int>? daysOfWeek;
  
  /// When this notification setting was created
  final DateTime createdAt;
  
  /// When this notification setting was last updated
  final DateTime updatedAt;
  
  const NotificationSettings({
    required this.id,
    required this.enabled,
    required this.title,
    required this.body,
    required this.scheduleType,
    required this.time,
    this.daysOfWeek,
    required this.createdAt,
    required this.updatedAt,
  });
  
  /// Validates that the notification settings are consistent
  bool get isValid {
    // Time should be in HH:mm format
    if (!_isValidTimeFormat(time)) {
      return false;
    }
    
    // Days of week should be valid if provided
    if (daysOfWeek != null) {
      for (final day in daysOfWeek!) {
        if (day < 1 || day > 7) {
          return false;
        }
      }
    }
    
    // Weekly schedules should have days of week
    if (scheduleType == NotificationScheduleType.weekly && 
        (daysOfWeek == null || daysOfWeek!.isEmpty)) {
      return false;
    }
    
    // Daily schedules should not have days of week
    if (scheduleType == NotificationScheduleType.daily && 
        daysOfWeek != null && daysOfWeek!.isNotEmpty) {
      return false;
    }
    
    return true;
  }
  
  /// Checks if the time format is valid (HH:mm)
  bool _isValidTimeFormat(String timeStr) {
    final regex = RegExp(r'^([01]?[0-9]|2[0-3]):[0-5][0-9]$');
    return regex.hasMatch(timeStr);
  }
  
  /// Gets the hour from the time string
  int get hour {
    final parts = time.split(':');
    return int.parse(parts[0]);
  }
  
  /// Gets the minute from the time string
  int get minute {
    final parts = time.split(':');
    return int.parse(parts[1]);
  }
  
  /// Gets a formatted display time (e.g., "8:00 PM")
  String get displayTime {
    final hour24 = this.hour;
    final minute = this.minute;
    
    if (hour24 == 0) {
      return '12:${minute.toString().padLeft(2, '0')} AM';
    } else if (hour24 < 12) {
      return '$hour24:${minute.toString().padLeft(2, '0')} AM';
    } else if (hour24 == 12) {
      return '12:${minute.toString().padLeft(2, '0')} PM';
    } else {
      return '${hour24 - 12}:${minute.toString().padLeft(2, '0')} PM';
    }
  }
  
  /// Gets display text for days of week
  String get daysOfWeekDisplay {
    if (daysOfWeek == null || daysOfWeek!.isEmpty) {
      return 'Daily';
    }
    
    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final sortedDays = List<int>.from(daysOfWeek!)..sort();
    
    if (sortedDays.length == 7) {
      return 'Daily';
    } else if (sortedDays.length == 5 && 
               sortedDays.every((day) => day >= 1 && day <= 5)) {
      return 'Weekdays';
    } else if (sortedDays.length == 2 && 
               sortedDays.contains(6) && sortedDays.contains(7)) {
      return 'Weekends';
    } else {
      return sortedDays.map((day) => dayNames[day - 1]).join(', ');
    }
  }
  
  /// Creates a copy of the notification settings with updated values
  NotificationSettings copyWith({
    String? id,
    bool? enabled,
    String? title,
    String? body,
    NotificationScheduleType? scheduleType,
    String? time,
    List<int>? daysOfWeek,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NotificationSettings(
      id: id ?? this.id,
      enabled: enabled ?? this.enabled,
      title: title ?? this.title,
      body: body ?? this.body,
      scheduleType: scheduleType ?? this.scheduleType,
      time: time ?? this.time,
      daysOfWeek: daysOfWeek ?? this.daysOfWeek,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is NotificationSettings &&
        other.id == id &&
        other.enabled == enabled &&
        other.title == title &&
        other.body == body &&
        other.scheduleType == scheduleType &&
        other.time == time &&
        _listEquals(other.daysOfWeek, daysOfWeek) &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }
  
  /// Helper method to compare lists
  bool _listEquals<T>(List<T>? a, List<T>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (int index = 0; index < a.length; index += 1) {
      if (a[index] != b[index]) return false;
    }
    return true;
  }
  
  @override
  int get hashCode => 
      id.hashCode ^
      enabled.hashCode ^
      title.hashCode ^
      body.hashCode ^
      scheduleType.hashCode ^
      time.hashCode ^
      daysOfWeek.hashCode ^
      createdAt.hashCode ^
      updatedAt.hashCode;
  
  @override
  String toString() => 
      'NotificationSettings(id: $id, enabled: $enabled, title: $title, '
      'body: $body, scheduleType: $scheduleType, time: $time, '
      'daysOfWeek: $daysOfWeek, createdAt: $createdAt, updatedAt: $updatedAt)';
}

/// Enum for notification schedule types
enum NotificationScheduleType {
  daily,
  weekly,
  custom;
  
  /// Convert from string representation
  static NotificationScheduleType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'daily':
        return NotificationScheduleType.daily;
      case 'weekly':
        return NotificationScheduleType.weekly;
      case 'custom':
        return NotificationScheduleType.custom;
      default:
        throw ArgumentError('Invalid notification schedule type: $value');
    }
  }
  
  /// Convert to string representation
  String toString() {
    switch (this) {
      case NotificationScheduleType.daily:
        return 'daily';
      case NotificationScheduleType.weekly:
        return 'weekly';
      case NotificationScheduleType.custom:
        return 'custom';
    }
  }
}
