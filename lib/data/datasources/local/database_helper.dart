import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

/// SQLite database helper for mood tracking application
/// Manages database creation, migrations, and provides access to the database instance
class DatabaseHelper {
  static const String _databaseName = 'tillhere_mood.db';
  static const int _databaseVersion = 3;

  // Table names
  static const String tableMoodEntry = 'mood_entry';
  static const String tableTag = 'tag';
  static const String tableMoodTag = 'mood_tag';
  static const String tableSettings = 'settings';
  static const String tableNotificationSettings = 'notification_settings';

  // Mood entry table columns
  static const String columnMoodId = 'id';
  static const String columnTimestampUtc = 'timestamp_utc';
  static const String columnMoodScore = 'mood_score';
  static const String columnNote = 'note';

  // Tag table columns
  static const String columnTagId = 'id';
  static const String columnTagName = 'name';

  // Mood-tag junction table columns
  static const String columnMoodTagMoodId = 'mood_id';
  static const String columnMoodTagTagId = 'tag_id';

  // Settings table columns
  static const String columnSettingsKey = 'key';
  static const String columnSettingsValue = 'value';
  static const String columnSettingsType = 'type';
  static const String columnSettingsUpdatedAt = 'updated_at';

  // Notification settings table columns
  static const String columnNotificationId = 'id';
  static const String columnNotificationEnabled = 'enabled';
  static const String columnNotificationTitle = 'title';
  static const String columnNotificationBody = 'body';
  static const String columnNotificationScheduleType = 'schedule_type'; // 'daily', 'weekly', 'custom'
  static const String columnNotificationTime = 'time'; // Time in HH:mm format
  static const String columnNotificationDaysOfWeek = 'days_of_week'; // JSON array for weekly schedules
  static const String columnNotificationCreatedAt = 'created_at';
  static const String columnNotificationUpdatedAt = 'updated_at';

  static Database? _database;

  /// Singleton instance
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  /// Get database instance, creating it if necessary
  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  /// Initialize the database
  Future<Database> _initDatabase() async {
    String path;

    // Use in-memory database for testing
    if (Platform.environment.containsKey('FLUTTER_TEST')) {
      path = inMemoryDatabasePath;
    } else {
      final documentsDirectory = await getApplicationDocumentsDirectory();
      path = join(documentsDirectory.path, _databaseName);
    }

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onConfigure: _onConfigure,
    );
  }

  /// Configure database settings
  Future<void> _onConfigure(Database db) async {
    // Enable foreign key constraints
    await db.execute('PRAGMA foreign_keys = ON');
  }

  /// Create database tables
  Future<void> _onCreate(Database db, int version) async {
    await _createTables(db);
    await _createIndexes(db);
  }

  /// Handle database upgrades
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database migrations
    if (oldVersion < 3 && newVersion >= 3) {
      // Add notification_settings table in version 3
      await db.execute('''
        CREATE TABLE $tableNotificationSettings (
          $columnNotificationId TEXT PRIMARY KEY,
          $columnNotificationEnabled INTEGER NOT NULL DEFAULT 1,
          $columnNotificationTitle TEXT NOT NULL,
          $columnNotificationBody TEXT NOT NULL,
          $columnNotificationScheduleType TEXT NOT NULL DEFAULT 'daily',
          $columnNotificationTime TEXT NOT NULL,
          $columnNotificationDaysOfWeek TEXT,
          $columnNotificationCreatedAt INTEGER NOT NULL,
          $columnNotificationUpdatedAt INTEGER NOT NULL
        )
      ''');

      // Add indexes for notification settings
      await db.execute('''
        CREATE INDEX idx_notification_enabled
        ON $tableNotificationSettings($columnNotificationEnabled)
      ''');

      await db.execute('''
        CREATE INDEX idx_notification_schedule_type
        ON $tableNotificationSettings($columnNotificationScheduleType)
      ''');
    }

    // For any other version changes, recreate tables (fallback)
    if (oldVersion < newVersion && oldVersion < 2) {
      await _dropTables(db);
      await _createTables(db);
      await _createIndexes(db);
    }
  }

  /// Create all database tables
  Future<void> _createTables(Database db) async {
    // Create mood_entry table
    await db.execute('''
      CREATE TABLE $tableMoodEntry (
        $columnMoodId TEXT PRIMARY KEY,
        $columnTimestampUtc INTEGER NOT NULL,
        $columnMoodScore INTEGER CHECK ($columnMoodScore BETWEEN 1 AND 10),
        $columnNote TEXT
      )
    ''');

    // Create tag table
    await db.execute('''
      CREATE TABLE $tableTag (
        $columnTagId TEXT PRIMARY KEY,
        $columnTagName TEXT UNIQUE NOT NULL
      )
    ''');

    // Create mood_tag junction table
    await db.execute('''
      CREATE TABLE $tableMoodTag (
        $columnMoodTagMoodId TEXT REFERENCES $tableMoodEntry($columnMoodId) ON DELETE CASCADE,
        $columnMoodTagTagId TEXT REFERENCES $tableTag($columnTagId) ON DELETE CASCADE,
        PRIMARY KEY ($columnMoodTagMoodId, $columnMoodTagTagId)
      )
    ''');

    // Create settings table
    await db.execute('''
      CREATE TABLE $tableSettings (
        $columnSettingsKey TEXT PRIMARY KEY,
        $columnSettingsValue TEXT,
        $columnSettingsType TEXT NOT NULL DEFAULT 'string',
        $columnSettingsUpdatedAt INTEGER NOT NULL
      )
    ''');

    // Create notification_settings table
    await db.execute('''
      CREATE TABLE $tableNotificationSettings (
        $columnNotificationId TEXT PRIMARY KEY,
        $columnNotificationEnabled INTEGER NOT NULL DEFAULT 1,
        $columnNotificationTitle TEXT NOT NULL,
        $columnNotificationBody TEXT NOT NULL,
        $columnNotificationScheduleType TEXT NOT NULL DEFAULT 'daily',
        $columnNotificationTime TEXT NOT NULL,
        $columnNotificationDaysOfWeek TEXT,
        $columnNotificationCreatedAt INTEGER NOT NULL,
        $columnNotificationUpdatedAt INTEGER NOT NULL
      )
    ''');
  }

  /// Create database indexes for better performance
  Future<void> _createIndexes(Database db) async {
    // Index on mood entry timestamp for efficient date range queries
    await db.execute('''
      CREATE INDEX idx_mood_entry_timestamp
      ON $tableMoodEntry($columnTimestampUtc)
    ''');

    // Index on mood entry score for analytics
    await db.execute('''
      CREATE INDEX idx_mood_entry_score
      ON $tableMoodEntry($columnMoodScore)
    ''');

    // Index on tag name for efficient lookups
    await db.execute('''
      CREATE INDEX idx_tag_name
      ON $tableTag($columnTagName)
    ''');

    // Indexes on junction table foreign keys
    await db.execute('''
      CREATE INDEX idx_mood_tag_mood_id
      ON $tableMoodTag($columnMoodTagMoodId)
    ''');

    await db.execute('''
      CREATE INDEX idx_mood_tag_tag_id
      ON $tableMoodTag($columnMoodTagTagId)
    ''');

    // Index on notification settings enabled status
    await db.execute('''
      CREATE INDEX idx_notification_enabled
      ON $tableNotificationSettings($columnNotificationEnabled)
    ''');

    // Index on notification settings schedule type
    await db.execute('''
      CREATE INDEX idx_notification_schedule_type
      ON $tableNotificationSettings($columnNotificationScheduleType)
    ''');
  }

  /// Drop all tables (used for migrations)
  Future<void> _dropTables(Database db) async {
    await db.execute('DROP TABLE IF EXISTS $tableMoodTag');
    await db.execute('DROP TABLE IF EXISTS $tableTag');
    await db.execute('DROP TABLE IF EXISTS $tableMoodEntry');
    await db.execute('DROP TABLE IF EXISTS $tableSettings');
    await db.execute('DROP TABLE IF EXISTS $tableNotificationSettings');
  }

  /// Close the database
  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }

  /// Delete the database file (for testing purposes)
  Future<void> deleteDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }

    // Only delete file if not in-memory database
    if (!Platform.environment.containsKey('FLUTTER_TEST')) {
      final documentsDirectory = await getApplicationDocumentsDirectory();
      final path = join(documentsDirectory.path, _databaseName);
      final file = File(path);

      if (await file.exists()) {
        await file.delete();
      }
    }
  }

  /// Get database path (for debugging)
  Future<String> getDatabasePath() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    return join(documentsDirectory.path, _databaseName);
  }
}
