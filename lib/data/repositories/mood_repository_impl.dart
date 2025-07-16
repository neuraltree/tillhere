import 'dart:convert';
import 'package:sqflite/sqflite.dart';

import '../../core/entities/mood_entry.dart';
import '../../core/entities/date_range.dart';
import '../../core/errors/failures.dart';
import '../../core/repositories/mood_repository.dart';
import '../datasources/local/database_helper.dart';
import '../datasources/local/encryption_service.dart';
import '../models/mood_entry_model.dart';
import '../models/tag_model.dart';
import '../models/export_data_model.dart';

/// Concrete implementation of TagRepository using SQLite
/// Handles all tag-related database operations
class TagRepositoryImpl implements TagRepository {
  final DatabaseHelper _databaseHelper;

  TagRepositoryImpl(this._databaseHelper);

  @override
  Future<Result<Tag>> insertTag(Tag tag) async {
    try {
      final db = await _databaseHelper.database;
      final tagModel = TagModel.fromEntity(tag);

      await db.insert(DatabaseHelper.tableTag, tagModel.toMap(), conflictAlgorithm: ConflictAlgorithm.fail);

      return Result.success(tag);
    } catch (e) {
      if (e.toString().contains('UNIQUE constraint failed')) {
        return Result.failure(ValidationFailure('Tag with name "${tag.name}" already exists'));
      }
      return Result.failure(DatabaseFailure('Failed to insert tag: $e'));
    }
  }

  @override
  Future<Result<Tag>> updateTag(Tag tag) async {
    try {
      final db = await _databaseHelper.database;
      final tagModel = TagModel.fromEntity(tag);

      final updatedRows = await db.update(
        DatabaseHelper.tableTag,
        tagModel.toMap(),
        where: '${DatabaseHelper.columnTagId} = ?',
        whereArgs: [tag.id],
      );

      if (updatedRows == 0) {
        return Result.failure(DatabaseFailure('Tag not found'));
      }

      return Result.success(tag);
    } catch (e) {
      if (e.toString().contains('UNIQUE constraint failed')) {
        return Result.failure(ValidationFailure('Tag with name "${tag.name}" already exists'));
      }
      return Result.failure(DatabaseFailure('Failed to update tag: $e'));
    }
  }

  @override
  Future<Result<bool>> deleteTag(String tagId) async {
    try {
      final db = await _databaseHelper.database;

      final deletedRows = await db.delete(
        DatabaseHelper.tableTag,
        where: '${DatabaseHelper.columnTagId} = ?',
        whereArgs: [tagId],
      );

      return Result.success(deletedRows > 0);
    } catch (e) {
      return Result.failure(DatabaseFailure('Failed to delete tag: $e'));
    }
  }

  @override
  Future<Result<Tag?>> getTagById(String tagId) async {
    try {
      final db = await _databaseHelper.database;

      final tagMaps = await db.query(
        DatabaseHelper.tableTag,
        where: '${DatabaseHelper.columnTagId} = ?',
        whereArgs: [tagId],
      );

      if (tagMaps.isEmpty) {
        return Result.success(null);
      }

      final tagModel = TagModel.fromMap(tagMaps.first);
      return Result.success(tagModel.toEntity());
    } catch (e) {
      return Result.failure(DatabaseFailure('Failed to get tag: $e'));
    }
  }

  @override
  Future<Result<Tag?>> getTagByName(String name) async {
    try {
      final db = await _databaseHelper.database;

      final tagMaps = await db.query(
        DatabaseHelper.tableTag,
        where: '${DatabaseHelper.columnTagName} = ?',
        whereArgs: [name],
      );

      if (tagMaps.isEmpty) {
        return Result.success(null);
      }

      final tagModel = TagModel.fromMap(tagMaps.first);
      return Result.success(tagModel.toEntity());
    } catch (e) {
      return Result.failure(DatabaseFailure('Failed to get tag by name: $e'));
    }
  }

  @override
  Future<Result<List<Tag>>> getAllTags() async {
    try {
      final db = await _databaseHelper.database;

      final tagMaps = await db.query(DatabaseHelper.tableTag, orderBy: '${DatabaseHelper.columnTagName} ASC');

      final tags = tagMaps.map((map) => TagModel.fromMap(map).toEntity()).toList();
      return Result.success(tags);
    } catch (e) {
      return Result.failure(DatabaseFailure('Failed to get all tags: $e'));
    }
  }

  @override
  Future<Result<List<Tag>>> getTagsForMood(String moodId) async {
    try {
      final db = await _databaseHelper.database;

      final tagMaps = await db.rawQuery(
        '''
        SELECT t.${DatabaseHelper.columnTagId}, t.${DatabaseHelper.columnTagName}
        FROM ${DatabaseHelper.tableTag} t
        INNER JOIN ${DatabaseHelper.tableMoodTag} mt ON t.${DatabaseHelper.columnTagId} = mt.${DatabaseHelper.columnMoodTagTagId}
        WHERE mt.${DatabaseHelper.columnMoodTagMoodId} = ?
        ORDER BY t.${DatabaseHelper.columnTagName} ASC
      ''',
        [moodId],
      );

      final tags = tagMaps.map((map) => TagModel.fromMap(map).toEntity()).toList();
      return Result.success(tags);
    } catch (e) {
      return Result.failure(DatabaseFailure('Failed to get tags for mood: $e'));
    }
  }

  @override
  Future<Result<bool>> addTagToMood(String moodId, String tagId) async {
    try {
      final db = await _databaseHelper.database;
      final moodTagModel = MoodTagModel(moodId: moodId, tagId: tagId);

      await db.insert(DatabaseHelper.tableMoodTag, moodTagModel.toMap(), conflictAlgorithm: ConflictAlgorithm.ignore);

      return Result.success(true);
    } catch (e) {
      return Result.failure(DatabaseFailure('Failed to add tag to mood: $e'));
    }
  }

  @override
  Future<Result<bool>> removeTagFromMood(String moodId, String tagId) async {
    try {
      final db = await _databaseHelper.database;

      final deletedRows = await db.delete(
        DatabaseHelper.tableMoodTag,
        where: '${DatabaseHelper.columnMoodTagMoodId} = ? AND ${DatabaseHelper.columnMoodTagTagId} = ?',
        whereArgs: [moodId, tagId],
      );

      return Result.success(deletedRows > 0);
    } catch (e) {
      return Result.failure(DatabaseFailure('Failed to remove tag from mood: $e'));
    }
  }

  @override
  Future<Result<bool>> clearAllTags() async {
    try {
      final db = await _databaseHelper.database;

      await db.transaction((txn) async {
        await txn.delete(DatabaseHelper.tableMoodTag);
        await txn.delete(DatabaseHelper.tableTag);
      });

      return Result.success(true);
    } catch (e) {
      return Result.failure(DatabaseFailure('Failed to clear all tags: $e'));
    }
  }
}

/// Concrete implementation of MoodRepository using SQLite
/// Handles all mood-related database operations
class MoodRepositoryImpl implements MoodRepository {
  final DatabaseHelper _databaseHelper;

  MoodRepositoryImpl(this._databaseHelper);

  @override
  Future<Result<MoodEntry>> insertMood(MoodEntry moodEntry) async {
    try {
      final db = await _databaseHelper.database;

      // Validate mood entry
      if (!moodEntry.isValidMoodScore) {
        return Result.failure(ValidationFailure('Mood score must be between 1 and 10'));
      }

      await db.transaction((txn) async {
        // Insert mood entry
        final moodModel = MoodEntryModel.fromEntity(moodEntry);
        await txn.insert(
          DatabaseHelper.tableMoodEntry,
          moodModel.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );

        // Insert tags and relationships
        for (final tag in moodEntry.tags) {
          // Insert tag if it doesn't exist
          final tagModel = TagModel.fromEntity(tag);
          await txn.insert(DatabaseHelper.tableTag, tagModel.toMap(), conflictAlgorithm: ConflictAlgorithm.ignore);

          // Insert mood-tag relationship
          final moodTagModel = MoodTagModel(moodId: moodEntry.id, tagId: tag.id);
          await txn.insert(
            DatabaseHelper.tableMoodTag,
            moodTagModel.toMap(),
            conflictAlgorithm: ConflictAlgorithm.ignore,
          );
        }
      });

      return Result.success(moodEntry);
    } catch (e) {
      return Result.failure(DatabaseFailure('Failed to insert mood entry: $e'));
    }
  }

  @override
  Future<Result<MoodEntry>> updateMood(MoodEntry moodEntry) async {
    try {
      final db = await _databaseHelper.database;

      // Validate mood entry
      if (!moodEntry.isValidMoodScore) {
        return Result.failure(ValidationFailure('Mood score must be between 1 and 10'));
      }

      await db.transaction((txn) async {
        // Update mood entry
        final moodModel = MoodEntryModel.fromEntity(moodEntry);
        final updatedRows = await txn.update(
          DatabaseHelper.tableMoodEntry,
          moodModel.toMap(),
          where: '${DatabaseHelper.columnMoodId} = ?',
          whereArgs: [moodEntry.id],
        );

        if (updatedRows == 0) {
          throw Exception('Mood entry not found');
        }

        // Delete existing tag relationships
        await txn.delete(
          DatabaseHelper.tableMoodTag,
          where: '${DatabaseHelper.columnMoodTagMoodId} = ?',
          whereArgs: [moodEntry.id],
        );

        // Insert new tags and relationships
        for (final tag in moodEntry.tags) {
          // Insert tag if it doesn't exist
          final tagModel = TagModel.fromEntity(tag);
          await txn.insert(DatabaseHelper.tableTag, tagModel.toMap(), conflictAlgorithm: ConflictAlgorithm.ignore);

          // Insert mood-tag relationship
          final moodTagModel = MoodTagModel(moodId: moodEntry.id, tagId: tag.id);
          await txn.insert(DatabaseHelper.tableMoodTag, moodTagModel.toMap());
        }
      });

      return Result.success(moodEntry);
    } catch (e) {
      return Result.failure(DatabaseFailure('Failed to update mood entry: $e'));
    }
  }

  @override
  Future<Result<bool>> deleteMood(String moodId) async {
    try {
      final db = await _databaseHelper.database;

      final deletedRows = await db.delete(
        DatabaseHelper.tableMoodEntry,
        where: '${DatabaseHelper.columnMoodId} = ?',
        whereArgs: [moodId],
      );

      return Result.success(deletedRows > 0);
    } catch (e) {
      return Result.failure(DatabaseFailure('Failed to delete mood entry: $e'));
    }
  }

  @override
  Future<Result<MoodEntry?>> getMoodById(String moodId) async {
    try {
      final db = await _databaseHelper.database;

      // Get mood entry
      final moodMaps = await db.query(
        DatabaseHelper.tableMoodEntry,
        where: '${DatabaseHelper.columnMoodId} = ?',
        whereArgs: [moodId],
      );

      if (moodMaps.isEmpty) {
        return Result.success(null);
      }

      final moodModel = MoodEntryModel.fromMap(moodMaps.first);

      // Get associated tags
      final tags = await _getTagsForMood(db, moodId);

      return Result.success(moodModel.toEntity(tags: tags));
    } catch (e) {
      return Result.failure(DatabaseFailure('Failed to get mood entry: $e'));
    }
  }

  @override
  Future<Result<List<MoodEntry>>> queryRange(DateRange dateRange) async {
    try {
      if (!dateRange.isValid) {
        return Result.failure(ValidationFailure('Invalid date range'));
      }

      final db = await _databaseHelper.database;

      final startTimestamp = dateRange.startDate.millisecondsSinceEpoch;
      final endTimestamp = dateRange.endDate.millisecondsSinceEpoch;

      // Query mood entries in date range
      final moodMaps = await db.query(
        DatabaseHelper.tableMoodEntry,
        where: '${DatabaseHelper.columnTimestampUtc} >= ? AND ${DatabaseHelper.columnTimestampUtc} <= ?',
        whereArgs: [startTimestamp, endTimestamp],
        orderBy: '${DatabaseHelper.columnTimestampUtc} ASC',
      );

      final moodEntries = <MoodEntry>[];

      for (final moodMap in moodMaps) {
        final moodModel = MoodEntryModel.fromMap(moodMap);
        final tags = await _getTagsForMood(db, moodModel.id);
        moodEntries.add(moodModel.toEntity(tags: tags));
      }

      return Result.success(moodEntries);
    } catch (e) {
      return Result.failure(DatabaseFailure('Failed to query mood entries: $e'));
    }
  }

  @override
  Future<Result<List<MoodEntry>>> getAllMoods() async {
    try {
      final db = await _databaseHelper.database;

      // Query all mood entries
      final moodMaps = await db.query(
        DatabaseHelper.tableMoodEntry,
        orderBy: '${DatabaseHelper.columnTimestampUtc} ASC',
      );

      final moodEntries = <MoodEntry>[];

      for (final moodMap in moodMaps) {
        final moodModel = MoodEntryModel.fromMap(moodMap);
        final tags = await _getTagsForMood(db, moodModel.id);
        moodEntries.add(moodModel.toEntity(tags: tags));
      }

      return Result.success(moodEntries);
    } catch (e) {
      return Result.failure(DatabaseFailure('Failed to get all mood entries: $e'));
    }
  }

  /// Helper method to get tags for a specific mood entry
  Future<List<Tag>> _getTagsForMood(Database db, String moodId) async {
    final tagMaps = await db.rawQuery(
      '''
      SELECT t.${DatabaseHelper.columnTagId}, t.${DatabaseHelper.columnTagName}
      FROM ${DatabaseHelper.tableTag} t
      INNER JOIN ${DatabaseHelper.tableMoodTag} mt ON t.${DatabaseHelper.columnTagId} = mt.${DatabaseHelper.columnMoodTagTagId}
      WHERE mt.${DatabaseHelper.columnMoodTagMoodId} = ?
    ''',
      [moodId],
    );

    return tagMaps.map((tagMap) => TagModel.fromMap(tagMap).toEntity()).toList();
  }

  @override
  Future<Result<String>> exportJson(String passcode) async {
    try {
      final db = await _databaseHelper.database;

      // Get all mood entries
      final moodMaps = await db.query(DatabaseHelper.tableMoodEntry);
      final moodEntries = moodMaps.map((map) => MoodEntryModel.fromMap(map)).toList();

      // Get all tags
      final tagMaps = await db.query(DatabaseHelper.tableTag);
      final tags = tagMaps.map((map) => TagModel.fromMap(map)).toList();

      // Get all mood-tag relationships
      final moodTagMaps = await db.query(DatabaseHelper.tableMoodTag);
      final moodTags = moodTagMaps.map((map) => MoodTagModel.fromMap(map)).toList();

      // Create export data model
      final exportData = ExportDataModel(
        moodEntries: moodEntries,
        tags: tags,
        moodTags: moodTags,
        exportTimestamp: DateTime.now(),
      );

      // Convert to JSON
      final jsonString = jsonEncode(exportData.toJson());

      // Encrypt JSON
      final encryptedJson = EncryptionService.encryptJson(jsonString, passcode);

      return Result.success(encryptedJson);
    } catch (e) {
      if (e is EncryptionException) {
        return Result.failure(CryptographyFailure(e.message));
      }
      return Result.failure(DatabaseFailure('Failed to export data: $e'));
    }
  }

  @override
  Future<Result<int>> importJson(String encryptedJson, String passcode) async {
    try {
      // Decrypt JSON
      final jsonString = EncryptionService.decryptJson(encryptedJson, passcode);

      // Parse JSON
      final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;
      final exportData = ExportDataModel.fromJson(jsonData);

      final db = await _databaseHelper.database;
      int importedCount = 0;

      await db.transaction((txn) async {
        // Import tags first
        for (final tagModel in exportData.tags) {
          await txn.insert(DatabaseHelper.tableTag, tagModel.toMap(), conflictAlgorithm: ConflictAlgorithm.ignore);
        }

        // Import mood entries
        for (final moodModel in exportData.moodEntries) {
          await txn.insert(
            DatabaseHelper.tableMoodEntry,
            moodModel.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
          importedCount++;
        }

        // Import mood-tag relationships
        for (final moodTagModel in exportData.moodTags) {
          await txn.insert(
            DatabaseHelper.tableMoodTag,
            moodTagModel.toMap(),
            conflictAlgorithm: ConflictAlgorithm.ignore,
          );
        }
      });

      return Result.success(importedCount);
    } catch (e) {
      if (e is EncryptionException) {
        return Result.failure(CryptographyFailure(e.message));
      }
      return Result.failure(SerializationFailure('Failed to import data: $e'));
    }
  }

  @override
  Future<Result<bool>> clearAllData() async {
    try {
      final db = await _databaseHelper.database;

      await db.transaction((txn) async {
        await txn.delete(DatabaseHelper.tableMoodTag);
        await txn.delete(DatabaseHelper.tableTag);
        await txn.delete(DatabaseHelper.tableMoodEntry);
      });

      return Result.success(true);
    } catch (e) {
      return Result.failure(DatabaseFailure('Failed to clear all data: $e'));
    }
  }
}
