import 'package:tillhere/data/datasources/local/database_helper.dart';
import 'package:tillhere/data/repositories/mood_repository_impl.dart';
import 'package:tillhere/core/entities/mood_entry.dart';
import 'package:intl/intl.dart';

/// Debug script to inspect mood entries and understand heatmap display issues
class MoodDataDebug {
  static Future<void> debugMoodEntries() async {
    print('🔍 DEBUG: Starting mood data investigation...');
    
    try {
      // Initialize database and repository
      final databaseHelper = DatabaseHelper();
      final moodRepository = MoodRepositoryImpl(databaseHelper);
      
      // Test 1: Check if database is accessible
      print('📊 DEBUG: Testing database access...');
      final db = await databaseHelper.database;
      print('✅ DEBUG: Database initialized successfully');
      
      // Test 2: Check if mood_entry table exists
      print('📊 DEBUG: Checking mood_entry table...');
      final tables = await db.rawQuery("SELECT name FROM sqlite_master WHERE type='table' AND name='mood_entry'");
      if (tables.isNotEmpty) {
        print('✅ DEBUG: mood_entry table exists');
      } else {
        print('❌ DEBUG: mood_entry table does not exist!');
        return;
      }
      
      // Test 3: Get all mood entries from repository
      print('📊 DEBUG: Loading all mood entries from repository...');
      final result = await moodRepository.getAllMoods();
      if (result.isSuccess) {
        final moodEntries = result.data!;
        print('✅ DEBUG: Found ${moodEntries.length} mood entries');
        
        if (moodEntries.isNotEmpty) {
          print('📊 DEBUG: Mood entries details:');
          for (int i = 0; i < moodEntries.length; i++) {
            final mood = moodEntries[i];
            final localTime = mood.timestampUtc.toLocal();
            final formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
            
            print('   ${i + 1}. ID: ${mood.id}');
            print('      UTC Time: ${formatter.format(mood.timestampUtc)}');
            print('      Local Time: ${formatter.format(localTime)}');
            print('      Date: ${localTime.day}/${localTime.month}/${localTime.year}');
            print('      Mood Score: ${mood.moodScore}');
            print('      Note: ${mood.note ?? 'No note'}');
            print('      Tags: ${mood.tags.map((t) => t.name).join(', ')}');
            print('');
          }
        }
      } else {
        print('❌ DEBUG: Failed to load mood entries: ${result.failure}');
      }
      
      // Test 4: Check raw database content
      print('📊 DEBUG: Checking raw database content...');
      final rawMoods = await db.query(DatabaseHelper.tableMoodEntry, orderBy: 'timestamp_utc ASC');
      print('✅ DEBUG: Raw mood entries in database:');
      for (final mood in rawMoods) {
        final timestampUtc = mood['timestamp_utc'] as int;
        final utcDateTime = DateTime.fromMillisecondsSinceEpoch(timestampUtc);
        final localDateTime = utcDateTime.toLocal();
        final formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
        
        print('   - ID: ${mood['id']}');
        print('     Raw UTC timestamp: $timestampUtc');
        print('     UTC DateTime: ${formatter.format(utcDateTime)}');
        print('     Local DateTime: ${formatter.format(localDateTime)}');
        print('     Date: ${localDateTime.day}/${localDateTime.month}/${localDateTime.year}');
        print('     Mood Score: ${mood['mood_score']}');
        print('     Note: ${mood['note'] ?? 'No note'}');
        print('');
      }
      
      // Test 5: Analyze current week and date calculations
      print('📊 DEBUG: Analyzing current week calculations...');
      final now = DateTime.now();
      print('✅ DEBUG: Current time info:');
      print('   - Now (local): ${DateFormat('yyyy-MM-dd HH:mm:ss').format(now)}');
      print('   - Today normalized: ${DateTime(now.year, now.month, now.day)}');
      print('   - Day of week: ${now.weekday} (1=Monday, 7=Sunday)');
      
      // Calculate start of current week (Monday)
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      final startOfWeekNormalized = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
      print('   - Start of week (Monday): ${DateFormat('yyyy-MM-dd').format(startOfWeekNormalized)}');
      
      // Show each day of the current week
      print('📊 DEBUG: Current week days:');
      for (int i = 0; i < 7; i++) {
        final weekDay = startOfWeekNormalized.add(Duration(days: i));
        final dayName = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][i];
        print('   - $dayName ${weekDay.day}/${weekDay.month}: ${DateFormat('yyyy-MM-dd').format(weekDay)}');
      }
      
      // Test 6: Check mood grouping logic for current week
      print('📊 DEBUG: Analyzing mood grouping for current week...');
      if (result.isSuccess) {
        final moodEntries = result.data!;
        final moodsByDay = <int, List<MoodEntry>>{};
        
        for (final mood in moodEntries) {
          final moodDate = mood.timestampUtc.toLocal();
          final moodDateNormalized = DateTime(moodDate.year, moodDate.month, moodDate.day);
          
          // Check if mood date falls within this week (Monday to Sunday)
          final daysDifference = moodDateNormalized.difference(startOfWeekNormalized).inDays;
          print('   - Mood ${mood.id}: ${DateFormat('yyyy-MM-dd').format(moodDateNormalized)}, days diff: $daysDifference');
          
          if (daysDifference >= 0 && daysDifference < 7) {
            final dayIndex = daysDifference; // 0 = Monday, 6 = Sunday
            moodsByDay.putIfAbsent(dayIndex, () => []).add(mood);
            print('     ✅ Added to day index $dayIndex');
          } else {
            print('     ❌ Outside current week range');
          }
        }
        
        print('📊 DEBUG: Moods grouped by day:');
        for (int i = 0; i < 7; i++) {
          final dayName = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][i];
          final dayMoods = moodsByDay[i] ?? [];
          print('   - $dayName (index $i): ${dayMoods.length} moods');
          for (final mood in dayMoods) {
            print('     • Score: ${mood.moodScore}, Time: ${DateFormat('HH:mm').format(mood.timestampUtc.toLocal())}');
          }
        }
      }
      
    } catch (e) {
      print('❌ DEBUG: Unexpected error during mood data debug: $e');
      print('Stack trace: ${StackTrace.current}');
    }
  }
}

/// Main function to run the debug script
void main() async {
  await MoodDataDebug.debugMoodEntries();
}
