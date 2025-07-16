import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:tillhere/core/entities/mood_entry.dart';
import 'package:tillhere/data/datasources/local/database_helper.dart';
import 'package:tillhere/data/repositories/mood_repository_impl.dart';

void main() {
  late DatabaseHelper databaseHelper;
  late TagRepositoryImpl tagRepository;
  late MoodRepositoryImpl moodRepository;

  setUpAll(() {
    // Initialize Flutter binding for testing
    TestWidgetsFlutterBinding.ensureInitialized();

    // Initialize FFI for testing
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    databaseHelper = DatabaseHelper();
    tagRepository = TagRepositoryImpl(databaseHelper);
    moodRepository = MoodRepositoryImpl(databaseHelper);

    // Clean database before each test
    await databaseHelper.deleteDatabase();
  });

  tearDown(() async {
    await databaseHelper.close();
  });

  group('TagRepositoryImpl', () {
    test('should insert tag successfully', () async {
      // Arrange
      const tag = Tag(id: 'tag-1', name: 'happy');

      // Act
      final result = await tagRepository.insertTag(tag);

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.data, equals(tag));
    });

    test('should fail to insert duplicate tag name', () async {
      // Arrange
      const tag1 = Tag(id: 'tag-1', name: 'happy');
      const tag2 = Tag(id: 'tag-2', name: 'happy'); // Same name

      await tagRepository.insertTag(tag1);

      // Act
      final result = await tagRepository.insertTag(tag2);

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.failure?.message, contains('already exists'));
    });

    test('should retrieve tag by id', () async {
      // Arrange
      const tag = Tag(id: 'tag-1', name: 'productive');
      await tagRepository.insertTag(tag);

      // Act
      final result = await tagRepository.getTagById('tag-1');

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.data?.id, equals('tag-1'));
      expect(result.data?.name, equals('productive'));
    });

    test('should retrieve tag by name', () async {
      // Arrange
      const tag = Tag(id: 'tag-1', name: 'creative');
      await tagRepository.insertTag(tag);

      // Act
      final result = await tagRepository.getTagByName('creative');

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.data?.id, equals('tag-1'));
      expect(result.data?.name, equals('creative'));
    });

    test('should return null for non-existent tag', () async {
      // Act
      final result = await tagRepository.getTagById('non-existent');

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.data, isNull);
    });

    test('should get all tags', () async {
      // Arrange
      const tags = [Tag(id: 'tag-1', name: 'happy'), Tag(id: 'tag-2', name: 'sad'), Tag(id: 'tag-3', name: 'excited')];

      for (final tag in tags) {
        await tagRepository.insertTag(tag);
      }

      // Act
      final result = await tagRepository.getAllTags();

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.data?.length, equals(3));
      expect(result.data?.map((t) => t.name), containsAll(['happy', 'sad', 'excited']));
    });

    test('should update tag successfully', () async {
      // Arrange
      const originalTag = Tag(id: 'tag-1', name: 'original');
      await tagRepository.insertTag(originalTag);

      const updatedTag = Tag(id: 'tag-1', name: 'updated');

      // Act
      final result = await tagRepository.updateTag(updatedTag);

      // Assert
      expect(result.isSuccess, isTrue);

      final retrievedResult = await tagRepository.getTagById('tag-1');
      expect(retrievedResult.data?.name, equals('updated'));
    });

    test('should delete tag successfully', () async {
      // Arrange
      const tag = Tag(id: 'tag-1', name: 'to-delete');
      await tagRepository.insertTag(tag);

      // Act
      final deleteResult = await tagRepository.deleteTag('tag-1');
      final getResult = await tagRepository.getTagById('tag-1');

      // Assert
      expect(deleteResult.isSuccess, isTrue);
      expect(deleteResult.data, isTrue);
      expect(getResult.data, isNull);
    });

    test('should get tags for specific mood', () async {
      // Arrange
      const tags = [
        Tag(id: 'tag-1', name: 'happy'),
        Tag(id: 'tag-2', name: 'productive'),
        Tag(id: 'tag-3', name: 'creative'),
      ];

      final moodEntry = MoodEntry(
        id: 'mood-1',
        timestampUtc: DateTime.now(),
        moodScore: 8,
        note: 'Great day',
        tags: [tags[0], tags[1]], // Only first two tags
      );

      await moodRepository.insertMood(moodEntry);

      // Act
      final result = await tagRepository.getTagsForMood('mood-1');

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.data?.length, equals(2));
      expect(result.data?.map((t) => t.name), containsAll(['happy', 'productive']));
      expect(result.data?.map((t) => t.name), isNot(contains('creative')));
    });

    test('should add tag to mood', () async {
      // Arrange
      const tag = Tag(id: 'tag-1', name: 'relaxed');
      await tagRepository.insertTag(tag);

      final moodEntry = MoodEntry(id: 'mood-1', timestampUtc: DateTime.now(), moodScore: 7);
      await moodRepository.insertMood(moodEntry);

      // Act
      final result = await tagRepository.addTagToMood('mood-1', 'tag-1');

      // Assert
      expect(result.isSuccess, isTrue);

      final tagsResult = await tagRepository.getTagsForMood('mood-1');
      expect(tagsResult.data?.length, equals(1));
      expect(tagsResult.data?.first.name, equals('relaxed'));
    });

    test('should remove tag from mood', () async {
      // Arrange
      const tag = Tag(id: 'tag-1', name: 'stressed');
      final moodEntry = MoodEntry(id: 'mood-1', timestampUtc: DateTime.now(), moodScore: 3, tags: [tag]);
      await moodRepository.insertMood(moodEntry);

      // Act
      final result = await tagRepository.removeTagFromMood('mood-1', 'tag-1');

      // Assert
      expect(result.isSuccess, isTrue);

      final tagsResult = await tagRepository.getTagsForMood('mood-1');
      expect(tagsResult.data?.isEmpty, isTrue);
    });

    test('should clear all tags', () async {
      // Arrange
      const tags = [Tag(id: 'tag-1', name: 'happy'), Tag(id: 'tag-2', name: 'sad')];

      for (final tag in tags) {
        await tagRepository.insertTag(tag);
      }

      // Act
      final clearResult = await tagRepository.clearAllTags();
      final allTagsResult = await tagRepository.getAllTags();

      // Assert
      expect(clearResult.isSuccess, isTrue);
      expect(allTagsResult.data?.isEmpty, isTrue);
    });

    test('should handle tag deletion with cascade to mood relationships', () async {
      // Arrange
      const tag = Tag(id: 'tag-1', name: 'energetic');
      final moodEntry = MoodEntry(id: 'mood-1', timestampUtc: DateTime.now(), moodScore: 9, tags: [tag]);
      await moodRepository.insertMood(moodEntry);

      // Act
      final deleteResult = await tagRepository.deleteTag('tag-1');

      // Assert
      expect(deleteResult.isSuccess, isTrue);

      // Tag should be deleted
      final tagResult = await tagRepository.getTagById('tag-1');
      expect(tagResult.data, isNull);

      // Mood should still exist but without tags
      final moodResult = await moodRepository.getMoodById('mood-1');
      expect(moodResult.data, isNotNull);
      expect(moodResult.data?.tags.isEmpty, isTrue);
    });
  });
}
