/// Domain entity representing a mood entry in the system.
/// This is a pure Dart class with no external dependencies,
/// following Clean Architecture principles.
class MoodEntry {
  /// Unique identifier for the mood entry
  final String id;
  
  /// UTC timestamp when the mood was recorded
  final DateTime timestampUtc;
  
  /// Mood score on a scale of 1-10
  final int moodScore;
  
  /// Optional note associated with the mood entry
  final String? note;
  
  /// List of tags associated with this mood entry
  final List<Tag> tags;

  const MoodEntry({
    required this.id,
    required this.timestampUtc,
    required this.moodScore,
    this.note,
    this.tags = const [],
  });

  /// Validates that the mood score is within the valid range (1-10)
  bool get isValidMoodScore => moodScore >= 1 && moodScore <= 10;

  /// Returns a copy of this mood entry with updated values
  MoodEntry copyWith({
    String? id,
    DateTime? timestampUtc,
    int? moodScore,
    String? note,
    List<Tag>? tags,
  }) {
    return MoodEntry(
      id: id ?? this.id,
      timestampUtc: timestampUtc ?? this.timestampUtc,
      moodScore: moodScore ?? this.moodScore,
      note: note ?? this.note,
      tags: tags ?? this.tags,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is MoodEntry &&
        other.id == id &&
        other.timestampUtc == timestampUtc &&
        other.moodScore == moodScore &&
        other.note == note &&
        _listEquals(other.tags, tags);
  }

  @override
  int get hashCode {
    return id.hashCode ^
        timestampUtc.hashCode ^
        moodScore.hashCode ^
        note.hashCode ^
        tags.hashCode;
  }

  @override
  String toString() {
    return 'MoodEntry(id: $id, timestampUtc: $timestampUtc, moodScore: $moodScore, note: $note, tags: $tags)';
  }

  /// Helper method to compare lists
  bool _listEquals<T>(List<T>? a, List<T>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    if (identical(a, b)) return true;
    for (int index = 0; index < a.length; index += 1) {
      if (a[index] != b[index]) return false;
    }
    return true;
  }
}

/// Domain entity representing a tag that can be associated with mood entries
class Tag {
  /// Unique identifier for the tag
  final String id;
  
  /// Display name of the tag
  final String name;

  const Tag({
    required this.id,
    required this.name,
  });

  /// Returns a copy of this tag with updated values
  Tag copyWith({
    String? id,
    String? name,
  }) {
    return Tag(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is Tag &&
        other.id == id &&
        other.name == name;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode;

  @override
  String toString() => 'Tag(id: $id, name: $name)';
}
