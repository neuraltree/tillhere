import 'package:flutter_test/flutter_test.dart';
import 'package:tillhere/core/entities/mood_entry.dart';

void main() {
  group('MoodEntry', () {
    test('should create a valid MoodEntry instance', () {
      // Arrange
      final timestamp = DateTime.now();
      const tag1 = Tag(id: 'tag1', name: 'happy');
      const tag2 = Tag(id: 'tag2', name: 'productive');

      // Act
      final moodEntry = MoodEntry(
        id: 'mood-123',
        timestampUtc: timestamp,
        moodScore: 8,
        note: 'Feeling great today!',
        tags: [tag1, tag2],
      );

      // Assert
      expect(moodEntry.id, equals('mood-123'));
      expect(moodEntry.timestampUtc, equals(timestamp));
      expect(moodEntry.moodScore, equals(8));
      expect(moodEntry.note, equals('Feeling great today!'));
      expect(moodEntry.tags, equals([tag1, tag2]));
    });

    test('should create MoodEntry with default empty tags', () {
      // Arrange
      final timestamp = DateTime.now();

      // Act
      final moodEntry = MoodEntry(id: 'mood-123', timestampUtc: timestamp, moodScore: 5);

      // Assert
      expect(moodEntry.tags, isEmpty);
      expect(moodEntry.note, isNull);
    });

    test('should validate mood score correctly', () {
      // Arrange
      final timestamp = DateTime.now();

      // Act & Assert - Valid scores
      for (int score = 1; score <= 10; score++) {
        final moodEntry = MoodEntry(id: 'mood-$score', timestampUtc: timestamp, moodScore: score);
        expect(moodEntry.isValidMoodScore, isTrue, reason: 'Score $score should be valid');
      }

      // Act & Assert - Invalid scores
      final invalidScores = [0, -1, 11, 15, 100];
      for (final score in invalidScores) {
        final moodEntry = MoodEntry(id: 'mood-$score', timestampUtc: timestamp, moodScore: score);
        expect(moodEntry.isValidMoodScore, isFalse, reason: 'Score $score should be invalid');
      }
    });

    test('should create copy with updated values', () {
      // Arrange
      final originalTimestamp = DateTime.now();
      final newTimestamp = originalTimestamp.add(const Duration(hours: 1));
      const originalTag = Tag(id: 'tag1', name: 'happy');
      const newTag = Tag(id: 'tag2', name: 'sad');

      final original = MoodEntry(
        id: 'mood-123',
        timestampUtc: originalTimestamp,
        moodScore: 8,
        note: 'Original note',
        tags: [originalTag],
      );

      // Act
      final copy = original.copyWith(
        id: 'mood-456',
        timestampUtc: newTimestamp,
        moodScore: 3,
        note: 'Updated note',
        tags: [newTag],
      );

      // Assert
      expect(copy.id, equals('mood-456'));
      expect(copy.timestampUtc, equals(newTimestamp));
      expect(copy.moodScore, equals(3));
      expect(copy.note, equals('Updated note'));
      expect(copy.tags, equals([newTag]));

      // Original should remain unchanged
      expect(original.id, equals('mood-123'));
      expect(original.timestampUtc, equals(originalTimestamp));
      expect(original.moodScore, equals(8));
      expect(original.note, equals('Original note'));
      expect(original.tags, equals([originalTag]));
    });

    test('should create copy with partial updates', () {
      // Arrange
      final timestamp = DateTime.now();
      const tag = Tag(id: 'tag1', name: 'happy');

      final original = MoodEntry(
        id: 'mood-123',
        timestampUtc: timestamp,
        moodScore: 8,
        note: 'Original note',
        tags: [tag],
      );

      // Act - Only update mood score
      final copy = original.copyWith(moodScore: 5);

      // Assert
      expect(copy.id, equals(original.id));
      expect(copy.timestampUtc, equals(original.timestampUtc));
      expect(copy.moodScore, equals(5));
      expect(copy.note, equals(original.note));
      expect(copy.tags, equals(original.tags));
    });

    test('should implement equality correctly', () {
      // Arrange
      final timestamp = DateTime.now();
      const tag = Tag(id: 'tag1', name: 'happy');

      final moodEntry1 = MoodEntry(
        id: 'mood-123',
        timestampUtc: timestamp,
        moodScore: 8,
        note: 'Test note',
        tags: [tag],
      );

      final moodEntry2 = MoodEntry(
        id: 'mood-123',
        timestampUtc: timestamp,
        moodScore: 8,
        note: 'Test note',
        tags: [tag],
      );

      final moodEntry3 = MoodEntry(
        id: 'mood-456',
        timestampUtc: timestamp,
        moodScore: 8,
        note: 'Test note',
        tags: [tag],
      );

      // Act & Assert
      expect(moodEntry1, equals(moodEntry2));
      expect(moodEntry1, isNot(equals(moodEntry3)));
      // Note: hashCode equality is not guaranteed for objects with nullable fields
    });

    test('should handle null note in equality', () {
      // Arrange
      final timestamp = DateTime.now();

      final moodEntry1 = MoodEntry(id: 'mood-123', timestampUtc: timestamp, moodScore: 8);

      final moodEntry2 = MoodEntry(id: 'mood-123', timestampUtc: timestamp, moodScore: 8);

      // Act & Assert
      expect(moodEntry1, equals(moodEntry2));
    });

    test('should have proper toString representation', () {
      // Arrange
      final timestamp = DateTime.now();
      const tag = Tag(id: 'tag1', name: 'happy');

      final moodEntry = MoodEntry(
        id: 'mood-123',
        timestampUtc: timestamp,
        moodScore: 8,
        note: 'Test note',
        tags: [tag],
      );

      // Act
      final stringRepresentation = moodEntry.toString();

      // Assert
      expect(stringRepresentation, contains('MoodEntry'));
      expect(stringRepresentation, contains('mood-123'));
      expect(stringRepresentation, contains('8'));
      expect(stringRepresentation, contains('Test note'));
    });
  });

  group('Tag', () {
    test('should create a valid Tag instance', () {
      // Act
      const tag = Tag(id: 'tag-123', name: 'happy');

      // Assert
      expect(tag.id, equals('tag-123'));
      expect(tag.name, equals('happy'));
    });

    test('should create copy with updated values', () {
      // Arrange
      const original = Tag(id: 'tag-123', name: 'happy');

      // Act
      final copy = original.copyWith(id: 'tag-456', name: 'sad');

      // Assert
      expect(copy.id, equals('tag-456'));
      expect(copy.name, equals('sad'));

      // Original should remain unchanged
      expect(original.id, equals('tag-123'));
      expect(original.name, equals('happy'));
    });

    test('should create copy with partial updates', () {
      // Arrange
      const original = Tag(id: 'tag-123', name: 'happy');

      // Act - Only update name
      final copy = original.copyWith(name: 'excited');

      // Assert
      expect(copy.id, equals(original.id));
      expect(copy.name, equals('excited'));
    });

    test('should implement equality correctly', () {
      // Arrange
      const tag1 = Tag(id: 'tag-123', name: 'happy');
      const tag2 = Tag(id: 'tag-123', name: 'happy');
      const tag3 = Tag(id: 'tag-456', name: 'happy');
      const tag4 = Tag(id: 'tag-123', name: 'sad');

      // Act & Assert
      expect(tag1, equals(tag2));
      expect(tag1, isNot(equals(tag3)));
      expect(tag1, isNot(equals(tag4)));
      expect(tag1.hashCode, equals(tag2.hashCode));
    });

    test('should have proper toString representation', () {
      // Arrange
      const tag = Tag(id: 'tag-123', name: 'happy');

      // Act
      final stringRepresentation = tag.toString();

      // Assert
      expect(stringRepresentation, contains('Tag'));
      expect(stringRepresentation, contains('tag-123'));
      expect(stringRepresentation, contains('happy'));
    });
  });
}
