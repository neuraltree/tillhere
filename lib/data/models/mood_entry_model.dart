import '../../core/entities/mood_entry.dart';
import '../datasources/local/database_helper.dart';

/// Data model for mood entry that handles database serialization/deserialization
/// This model is responsible for converting between database maps and domain entities
class MoodEntryModel {
  final String id;
  final int timestampUtc;
  final int moodScore;
  final String? note;

  const MoodEntryModel({
    required this.id,
    required this.timestampUtc,
    required this.moodScore,
    this.note,
  });

  /// Create MoodEntryModel from database map
  factory MoodEntryModel.fromMap(Map<String, dynamic> map) {
    return MoodEntryModel(
      id: map[DatabaseHelper.columnMoodId] as String,
      timestampUtc: map[DatabaseHelper.columnTimestampUtc] as int,
      moodScore: map[DatabaseHelper.columnMoodScore] as int,
      note: map[DatabaseHelper.columnNote] as String?,
    );
  }

  /// Convert MoodEntryModel to database map
  Map<String, dynamic> toMap() {
    return {
      DatabaseHelper.columnMoodId: id,
      DatabaseHelper.columnTimestampUtc: timestampUtc,
      DatabaseHelper.columnMoodScore: moodScore,
      DatabaseHelper.columnNote: note,
    };
  }

  /// Create MoodEntryModel from domain entity
  factory MoodEntryModel.fromEntity(MoodEntry entity) {
    return MoodEntryModel(
      id: entity.id,
      timestampUtc: entity.timestampUtc.millisecondsSinceEpoch,
      moodScore: entity.moodScore,
      note: entity.note,
    );
  }

  /// Convert MoodEntryModel to domain entity (without tags)
  /// Tags are handled separately due to the junction table relationship
  MoodEntry toEntity({List<Tag> tags = const []}) {
    return MoodEntry(
      id: id,
      timestampUtc: DateTime.fromMillisecondsSinceEpoch(timestampUtc),
      moodScore: moodScore,
      note: note,
      tags: tags,
    );
  }

  /// Create MoodEntryModel from JSON (for export/import)
  factory MoodEntryModel.fromJson(Map<String, dynamic> json) {
    return MoodEntryModel(
      id: json['id'] as String,
      timestampUtc: json['timestamp_utc'] as int,
      moodScore: json['mood_score'] as int,
      note: json['note'] as String?,
    );
  }

  /// Convert MoodEntryModel to JSON (for export/import)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp_utc': timestampUtc,
      'mood_score': moodScore,
      'note': note,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is MoodEntryModel &&
        other.id == id &&
        other.timestampUtc == timestampUtc &&
        other.moodScore == moodScore &&
        other.note == note;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        timestampUtc.hashCode ^
        moodScore.hashCode ^
        note.hashCode;
  }

  @override
  String toString() {
    return 'MoodEntryModel(id: $id, timestampUtc: $timestampUtc, moodScore: $moodScore, note: $note)';
  }
}
