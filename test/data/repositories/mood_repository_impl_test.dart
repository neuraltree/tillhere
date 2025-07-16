import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:tillhere/core/entities/mood_entry.dart';
import 'package:tillhere/core/entities/date_range.dart';
import 'package:tillhere/data/datasources/local/database_helper.dart';
import 'package:tillhere/data/repositories/mood_repository_impl.dart';

void main() {
  late DatabaseHelper databaseHelper;
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
    moodRepository = MoodRepositoryImpl(databaseHelper);

    // Clean database before each test
    await databaseHelper.deleteDatabase();
  });

  tearDown(() async {
    await databaseHelper.close();
  });

  group('MoodRepositoryImpl', () {
    test('should insert mood entry successfully', () async {
      // Arrange
      final moodEntry = MoodEntry(
        id: 'test-mood-1',
        timestampUtc: DateTime.now(),
        moodScore: 7,
        note: 'Feeling good today',
        tags: [
          const Tag(id: 'tag-1', name: 'happy'),
          const Tag(id: 'tag-2', name: 'productive'),
        ],
      );

      // Act
      final result = await moodRepository.insertMood(moodEntry);

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.data, equals(moodEntry));
    });

    test('should fail to insert mood entry with invalid score', () async {
      // Arrange
      final moodEntry = MoodEntry(
        id: 'test-mood-1',
        timestampUtc: DateTime.now(),
        moodScore: 11, // Invalid score
        note: 'Invalid mood',
      );

      // Act
      final result = await moodRepository.insertMood(moodEntry);

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.failure?.message, contains('Mood score must be between 1 and 10'));
    });

    test('should retrieve mood entry by id', () async {
      // Arrange
      final moodEntry = MoodEntry(id: 'test-mood-1', timestampUtc: DateTime.now(), moodScore: 5, note: 'Average day');
      await moodRepository.insertMood(moodEntry);

      // Act
      final result = await moodRepository.getMoodById('test-mood-1');

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.data?.id, equals('test-mood-1'));
      expect(result.data?.moodScore, equals(5));
      expect(result.data?.note, equals('Average day'));
    });

    test('should return null for non-existent mood entry', () async {
      // Act
      final result = await moodRepository.getMoodById('non-existent');

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.data, isNull);
    });

    test('should query mood entries within date range', () async {
      // Arrange
      final now = DateTime.now();
      final yesterday = now.subtract(const Duration(days: 1));
      final tomorrow = now.add(const Duration(days: 1));

      final mood1 = MoodEntry(id: 'mood-1', timestampUtc: yesterday, moodScore: 6);
      final mood2 = MoodEntry(id: 'mood-2', timestampUtc: now, moodScore: 8);
      final mood3 = MoodEntry(id: 'mood-3', timestampUtc: tomorrow, moodScore: 4);

      await moodRepository.insertMood(mood1);
      await moodRepository.insertMood(mood2);
      await moodRepository.insertMood(mood3);

      final dateRange = DateRange(
        startDate: yesterday.subtract(const Duration(hours: 1)),
        endDate: now.add(const Duration(hours: 1)),
      );

      // Act
      final result = await moodRepository.queryRange(dateRange);

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.data?.length, equals(2));
      expect(result.data?.map((m) => m.id), containsAll(['mood-1', 'mood-2']));
    });

    test('should update mood entry successfully', () async {
      // Arrange
      final originalMood = MoodEntry(
        id: 'test-mood-1',
        timestampUtc: DateTime.now(),
        moodScore: 5,
        note: 'Original note',
      );
      await moodRepository.insertMood(originalMood);

      final updatedMood = originalMood.copyWith(
        moodScore: 8,
        note: 'Updated note',
        tags: [const Tag(id: 'tag-1', name: 'updated')],
      );

      // Act
      final result = await moodRepository.updateMood(updatedMood);

      // Assert
      expect(result.isSuccess, isTrue);

      final retrievedResult = await moodRepository.getMoodById('test-mood-1');
      expect(retrievedResult.data?.moodScore, equals(8));
      expect(retrievedResult.data?.note, equals('Updated note'));
      expect(retrievedResult.data?.tags.length, equals(1));
    });

    test('should delete mood entry successfully', () async {
      // Arrange
      final moodEntry = MoodEntry(id: 'test-mood-1', timestampUtc: DateTime.now(), moodScore: 7);
      await moodRepository.insertMood(moodEntry);

      // Act
      final deleteResult = await moodRepository.deleteMood('test-mood-1');
      final getResult = await moodRepository.getMoodById('test-mood-1');

      // Assert
      expect(deleteResult.isSuccess, isTrue);
      expect(deleteResult.data, isTrue);
      expect(getResult.data, isNull);
    });

    test('should export and import JSON data with encryption', () async {
      // Arrange
      const passcode = 'test_passcode_123';
      final moodEntries = [
        MoodEntry(
          id: 'mood-1',
          timestampUtc: DateTime.now(),
          moodScore: 7,
          note: 'Good day',
          tags: [const Tag(id: 'tag-1', name: 'happy')],
        ),
        MoodEntry(
          id: 'mood-2',
          timestampUtc: DateTime.now().add(const Duration(hours: 1)),
          moodScore: 5,
          note: 'Average day',
        ),
      ];

      for (final mood in moodEntries) {
        await moodRepository.insertMood(mood);
      }

      // Act - Export
      final exportResult = await moodRepository.exportJson(passcode);
      expect(exportResult.isSuccess, isTrue);

      // Clear database
      await moodRepository.clearAllData();
      final emptyResult = await moodRepository.getAllMoods();
      expect(emptyResult.data?.isEmpty, isTrue);

      // Act - Import
      final importResult = await moodRepository.importJson(exportResult.data!, passcode);
      expect(importResult.isSuccess, isTrue);
      expect(importResult.data, equals(2)); // 2 mood entries imported

      // Assert
      final allMoodsResult = await moodRepository.getAllMoods();
      expect(allMoodsResult.data?.length, equals(2));

      final importedMoods = allMoodsResult.data!;
      expect(importedMoods.map((m) => m.id), containsAll(['mood-1', 'mood-2']));
      expect(importedMoods.firstWhere((m) => m.id == 'mood-1').tags.length, equals(1));
    });

    test('should fail import with wrong passcode', () async {
      // Arrange
      const correctPasscode = 'correct_passcode';
      const wrongPasscode = 'wrong_passcode';

      final moodEntry = MoodEntry(id: 'mood-1', timestampUtc: DateTime.now(), moodScore: 7);
      await moodRepository.insertMood(moodEntry);

      final exportResult = await moodRepository.exportJson(correctPasscode);
      expect(exportResult.isSuccess, isTrue);

      // Act
      final importResult = await moodRepository.importJson(exportResult.data!, wrongPasscode);

      // Assert
      expect(importResult.isFailure, isTrue);
      expect(importResult.failure?.message, contains('Failed to decrypt'));
    });

    test('should clear all data successfully', () async {
      // Arrange
      final moodEntry = MoodEntry(
        id: 'mood-1',
        timestampUtc: DateTime.now(),
        moodScore: 7,
        tags: [const Tag(id: 'tag-1', name: 'test')],
      );
      await moodRepository.insertMood(moodEntry);

      // Act
      final clearResult = await moodRepository.clearAllData();
      final allMoodsResult = await moodRepository.getAllMoods();

      // Assert
      expect(clearResult.isSuccess, isTrue);
      expect(allMoodsResult.data?.isEmpty, isTrue);
    });
  });
}
