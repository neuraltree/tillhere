import 'package:tillhere/core/entities/mood_entry.dart';
import 'package:tillhere/core/entities/date_range.dart';
import 'package:tillhere/data/datasources/local/database_helper.dart';
import 'package:tillhere/data/repositories/mood_repository_impl.dart';

/// Example usage of the mood tracking system
/// This demonstrates how to use the implemented SQLite schema and DAO methods
class MoodTrackingExample {
  late final MoodRepositoryImpl _moodRepository;
  late final TagRepositoryImpl _tagRepository;
  
  MoodTrackingExample() {
    final databaseHelper = DatabaseHelper();
    _moodRepository = MoodRepositoryImpl(databaseHelper);
    _tagRepository = TagRepositoryImpl(databaseHelper);
  }
  
  /// Example of inserting a mood entry with tags
  Future<void> insertMoodExample() async {
    // Create some tags
    const happyTag = Tag(id: 'tag-happy', name: 'happy');
    const productiveTag = Tag(id: 'tag-productive', name: 'productive');
    
    // Insert tags (will be ignored if they already exist)
    await _tagRepository.insertTag(happyTag);
    await _tagRepository.insertTag(productiveTag);
    
    // Create a mood entry
    final moodEntry = MoodEntry(
      id: 'mood-${DateTime.now().millisecondsSinceEpoch}',
      timestampUtc: DateTime.now(),
      moodScore: 8,
      note: 'Had a great day at work! Completed all my tasks.',
      tags: [happyTag, productiveTag],
    );
    
    // Insert the mood entry
    final result = await _moodRepository.insertMood(moodEntry);
    
    if (result.isSuccess) {
      print('✅ Mood entry inserted successfully: ${result.data?.id}');
    } else {
      print('❌ Failed to insert mood entry: ${result.failure?.message}');
    }
  }
  
  /// Example of querying mood entries within a date range
  Future<void> queryRangeExample() async {
    // Query moods from the last 7 days
    final dateRange = DateRange.lastDays(7);
    final result = await _moodRepository.queryRange(dateRange);
    
    if (result.isSuccess) {
      final moods = result.data!;
      print('📊 Found ${moods.length} mood entries in the last 7 days:');
      
      for (final mood in moods) {
        print('  • ${mood.timestampUtc.toLocal()}: Score ${mood.moodScore}/10');
        if (mood.note?.isNotEmpty == true) {
          print('    Note: ${mood.note}');
        }
        if (mood.tags.isNotEmpty) {
          print('    Tags: ${mood.tags.map((t) => t.name).join(', ')}');
        }
      }
    } else {
      print('❌ Failed to query mood entries: ${result.failure?.message}');
    }
  }
  
  /// Example of exporting data as encrypted JSON
  Future<void> exportJsonExample() async {
    const passcode = 'my_secure_passcode_123';
    
    final result = await _moodRepository.exportJson(passcode);
    
    if (result.isSuccess) {
      final encryptedJson = result.data!;
      print('🔐 Data exported successfully!');
      print('Encrypted JSON length: ${encryptedJson.length} characters');
      print('First 100 characters: ${encryptedJson.substring(0, 100)}...');
      
      // You could save this to a file or share it
      // File('mood_backup.json').writeAsString(encryptedJson);
    } else {
      print('❌ Failed to export data: ${result.failure?.message}');
    }
  }
  
  /// Example of importing data from encrypted JSON
  Future<void> importJsonExample(String encryptedJson) async {
    const passcode = 'my_secure_passcode_123';
    
    final result = await _moodRepository.importJson(encryptedJson, passcode);
    
    if (result.isSuccess) {
      final importedCount = result.data!;
      print('📥 Successfully imported $importedCount mood entries');
    } else {
      print('❌ Failed to import data: ${result.failure?.message}');
    }
  }
  
  /// Example of getting mood statistics
  Future<void> getMoodStatisticsExample() async {
    final allMoodsResult = await _moodRepository.getAllMoods();
    
    if (allMoodsResult.isSuccess) {
      final moods = allMoodsResult.data!;
      
      if (moods.isEmpty) {
        print('📈 No mood data available');
        return;
      }
      
      // Calculate statistics
      final totalMoods = moods.length;
      final averageScore = moods.map((m) => m.moodScore).reduce((a, b) => a + b) / totalMoods;
      final highestScore = moods.map((m) => m.moodScore).reduce((a, b) => a > b ? a : b);
      final lowestScore = moods.map((m) => m.moodScore).reduce((a, b) => a < b ? a : b);
      
      // Get most common tags
      final tagCounts = <String, int>{};
      for (final mood in moods) {
        for (final tag in mood.tags) {
          tagCounts[tag.name] = (tagCounts[tag.name] ?? 0) + 1;
        }
      }
      
      final sortedTags = tagCounts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      
      print('📈 Mood Statistics:');
      print('  Total entries: $totalMoods');
      print('  Average score: ${averageScore.toStringAsFixed(1)}/10');
      print('  Highest score: $highestScore/10');
      print('  Lowest score: $lowestScore/10');
      
      if (sortedTags.isNotEmpty) {
        print('  Most common tags:');
        for (int i = 0; i < 3 && i < sortedTags.length; i++) {
          final tag = sortedTags[i];
          print('    ${i + 1}. ${tag.key} (${tag.value} times)');
        }
      }
    } else {
      print('❌ Failed to get mood statistics: ${allMoodsResult.failure?.message}');
    }
  }
  
  /// Run all examples
  Future<void> runAllExamples() async {
    print('🚀 Running Mood Tracking System Examples\n');
    
    print('1. Inserting mood entries...');
    await insertMoodExample();
    
    // Insert a few more examples
    await _insertSampleData();
    
    print('\n2. Querying mood entries...');
    await queryRangeExample();
    
    print('\n3. Getting mood statistics...');
    await getMoodStatisticsExample();
    
    print('\n4. Exporting data...');
    await exportJsonExample();
    
    print('\n✅ All examples completed successfully!');
  }
  
  /// Helper method to insert sample data
  Future<void> _insertSampleData() async {
    final sampleMoods = [
      MoodEntry(
        id: 'mood-sample-1',
        timestampUtc: DateTime.now().subtract(const Duration(days: 1)),
        moodScore: 6,
        note: 'Average day, nothing special',
        tags: [const Tag(id: 'tag-neutral', name: 'neutral')],
      ),
      MoodEntry(
        id: 'mood-sample-2',
        timestampUtc: DateTime.now().subtract(const Duration(days: 2)),
        moodScore: 9,
        note: 'Amazing day! Got promoted at work!',
        tags: [
          const Tag(id: 'tag-excited', name: 'excited'),
          const Tag(id: 'tag-achievement', name: 'achievement'),
        ],
      ),
      MoodEntry(
        id: 'mood-sample-3',
        timestampUtc: DateTime.now().subtract(const Duration(days: 3)),
        moodScore: 4,
        note: 'Feeling a bit down today',
        tags: [const Tag(id: 'tag-sad', name: 'sad')],
      ),
    ];
    
    for (final mood in sampleMoods) {
      // Insert tags first
      for (final tag in mood.tags) {
        await _tagRepository.insertTag(tag);
      }
      // Insert mood
      await _moodRepository.insertMood(mood);
    }
  }
}

/// Main function to run the examples
Future<void> main() async {
  final example = MoodTrackingExample();
  await example.runAllExamples();
}
