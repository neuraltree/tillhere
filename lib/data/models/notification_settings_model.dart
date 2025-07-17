import 'dart:convert';
import '../../core/entities/notification_settings.dart';
import '../datasources/local/database_helper.dart';

/// Data model for notification settings that handles database serialization/deserialization
/// This model is responsible for converting between database maps and domain entities
class NotificationSettingsModel {
  final String id;
  final bool enabled;
  final String title;
  final String body;
  final String scheduleType;
  final String time;
  final String? daysOfWeek; // JSON string for list of integers
  final DateTime createdAt;
  final DateTime updatedAt;

  const NotificationSettingsModel({
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

  /// Create NotificationSettingsModel from database map
  factory NotificationSettingsModel.fromMap(Map<String, dynamic> map) {
    return NotificationSettingsModel(
      id: map[DatabaseHelper.columnNotificationId] as String,
      enabled: (map[DatabaseHelper.columnNotificationEnabled] as int) == 1,
      title: map[DatabaseHelper.columnNotificationTitle] as String,
      body: map[DatabaseHelper.columnNotificationBody] as String,
      scheduleType: map[DatabaseHelper.columnNotificationScheduleType] as String,
      time: map[DatabaseHelper.columnNotificationTime] as String,
      daysOfWeek: map[DatabaseHelper.columnNotificationDaysOfWeek] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        map[DatabaseHelper.columnNotificationCreatedAt] as int,
      ),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(
        map[DatabaseHelper.columnNotificationUpdatedAt] as int,
      ),
    );
  }

  /// Convert NotificationSettingsModel to database map
  Map<String, dynamic> toMap() {
    return {
      DatabaseHelper.columnNotificationId: id,
      DatabaseHelper.columnNotificationEnabled: enabled ? 1 : 0,
      DatabaseHelper.columnNotificationTitle: title,
      DatabaseHelper.columnNotificationBody: body,
      DatabaseHelper.columnNotificationScheduleType: scheduleType,
      DatabaseHelper.columnNotificationTime: time,
      DatabaseHelper.columnNotificationDaysOfWeek: daysOfWeek,
      DatabaseHelper.columnNotificationCreatedAt: createdAt.millisecondsSinceEpoch,
      DatabaseHelper.columnNotificationUpdatedAt: updatedAt.millisecondsSinceEpoch,
    };
  }

  /// Create NotificationSettingsModel from domain entity
  factory NotificationSettingsModel.fromEntity(NotificationSettings entity) {
    String? daysOfWeekJson;
    if (entity.daysOfWeek != null && entity.daysOfWeek!.isNotEmpty) {
      daysOfWeekJson = jsonEncode(entity.daysOfWeek);
    }

    return NotificationSettingsModel(
      id: entity.id,
      enabled: entity.enabled,
      title: entity.title,
      body: entity.body,
      scheduleType: entity.scheduleType.toString(),
      time: entity.time,
      daysOfWeek: daysOfWeekJson,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Convert NotificationSettingsModel to domain entity
  NotificationSettings toEntity() {
    List<int>? parsedDaysOfWeek;
    if (daysOfWeek != null && daysOfWeek!.isNotEmpty) {
      try {
        final decoded = jsonDecode(daysOfWeek!) as List<dynamic>;
        parsedDaysOfWeek = decoded.cast<int>();
      } catch (e) {
        // If JSON parsing fails, treat as null
        parsedDaysOfWeek = null;
      }
    }

    return NotificationSettings(
      id: id,
      enabled: enabled,
      title: title,
      body: body,
      scheduleType: NotificationScheduleType.fromString(scheduleType),
      time: time,
      daysOfWeek: parsedDaysOfWeek,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Create a copy with updated values
  NotificationSettingsModel copyWith({
    String? id,
    bool? enabled,
    String? title,
    String? body,
    String? scheduleType,
    String? time,
    String? daysOfWeek,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NotificationSettingsModel(
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

    return other is NotificationSettingsModel &&
        other.id == id &&
        other.enabled == enabled &&
        other.title == title &&
        other.body == body &&
        other.scheduleType == scheduleType &&
        other.time == time &&
        other.daysOfWeek == daysOfWeek &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
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
      'NotificationSettingsModel(id: $id, enabled: $enabled, title: $title, '
      'body: $body, scheduleType: $scheduleType, time: $time, '
      'daysOfWeek: $daysOfWeek, createdAt: $createdAt, updatedAt: $updatedAt)';
}
