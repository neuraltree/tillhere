import '../../core/entities/mood_entry.dart';
import '../datasources/local/database_helper.dart';

/// Data model for tag that handles database serialization/deserialization
/// This model is responsible for converting between database maps and domain entities
class TagModel {
  final String id;
  final String name;

  const TagModel({
    required this.id,
    required this.name,
  });

  /// Create TagModel from database map
  factory TagModel.fromMap(Map<String, dynamic> map) {
    return TagModel(
      id: map[DatabaseHelper.columnTagId] as String,
      name: map[DatabaseHelper.columnTagName] as String,
    );
  }

  /// Convert TagModel to database map
  Map<String, dynamic> toMap() {
    return {
      DatabaseHelper.columnTagId: id,
      DatabaseHelper.columnTagName: name,
    };
  }

  /// Create TagModel from domain entity
  factory TagModel.fromEntity(Tag entity) {
    return TagModel(
      id: entity.id,
      name: entity.name,
    );
  }

  /// Convert TagModel to domain entity
  Tag toEntity() {
    return Tag(
      id: id,
      name: name,
    );
  }

  /// Create TagModel from JSON (for export/import)
  factory TagModel.fromJson(Map<String, dynamic> json) {
    return TagModel(
      id: json['id'] as String,
      name: json['name'] as String,
    );
  }

  /// Convert TagModel to JSON (for export/import)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is TagModel &&
        other.id == id &&
        other.name == name;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode;

  @override
  String toString() => 'TagModel(id: $id, name: $name)';
}

/// Data model for mood-tag junction table
class MoodTagModel {
  final String moodId;
  final String tagId;

  const MoodTagModel({
    required this.moodId,
    required this.tagId,
  });

  /// Create MoodTagModel from database map
  factory MoodTagModel.fromMap(Map<String, dynamic> map) {
    return MoodTagModel(
      moodId: map[DatabaseHelper.columnMoodTagMoodId] as String,
      tagId: map[DatabaseHelper.columnMoodTagTagId] as String,
    );
  }

  /// Convert MoodTagModel to database map
  Map<String, dynamic> toMap() {
    return {
      DatabaseHelper.columnMoodTagMoodId: moodId,
      DatabaseHelper.columnMoodTagTagId: tagId,
    };
  }

  /// Create MoodTagModel from JSON (for export/import)
  factory MoodTagModel.fromJson(Map<String, dynamic> json) {
    return MoodTagModel(
      moodId: json['mood_id'] as String,
      tagId: json['tag_id'] as String,
    );
  }

  /// Convert MoodTagModel to JSON (for export/import)
  Map<String, dynamic> toJson() {
    return {
      'mood_id': moodId,
      'tag_id': tagId,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is MoodTagModel &&
        other.moodId == moodId &&
        other.tagId == tagId;
  }

  @override
  int get hashCode => moodId.hashCode ^ tagId.hashCode;

  @override
  String toString() => 'MoodTagModel(moodId: $moodId, tagId: $tagId)';
}
