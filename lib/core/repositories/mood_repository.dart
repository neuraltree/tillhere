import '../entities/mood_entry.dart';
import '../entities/date_range.dart';
import '../errors/failures.dart';

/// Result type for operations that can fail
/// Using a simple approach instead of dartz for this implementation
class Result<T> {
  final T? data;
  final Failure? failure;
  
  const Result.success(this.data) : failure = null;
  const Result.failure(this.failure) : data = null;
  
  bool get isSuccess => failure == null;
  bool get isFailure => failure != null;
}

/// Abstract repository interface for mood-related operations
/// This interface defines the contract for mood data operations
/// and follows Clean Architecture principles by being in the domain layer
abstract class MoodRepository {
  /// Inserts a new mood entry into the repository
  /// Returns the inserted mood entry on success, or a failure
  Future<Result<MoodEntry>> insertMood(MoodEntry moodEntry);
  
  /// Updates an existing mood entry
  /// Returns the updated mood entry on success, or a failure
  Future<Result<MoodEntry>> updateMood(MoodEntry moodEntry);
  
  /// Deletes a mood entry by its ID
  /// Returns true on successful deletion, or a failure
  Future<Result<bool>> deleteMood(String moodId);
  
  /// Retrieves a mood entry by its ID
  /// Returns the mood entry if found, or a failure
  Future<Result<MoodEntry?>> getMoodById(String moodId);
  
  /// Queries mood entries within a specified date range
  /// Returns a list of mood entries, or a failure
  Future<Result<List<MoodEntry>>> queryRange(DateRange dateRange);
  
  /// Retrieves all mood entries
  /// Returns a list of all mood entries, or a failure
  Future<Result<List<MoodEntry>>> getAllMoods();
  
  /// Exports mood data as encrypted JSON
  /// Takes a passcode for encryption and returns encrypted JSON string
  Future<Result<String>> exportJson(String passcode);
  
  /// Imports mood data from encrypted JSON
  /// Takes encrypted JSON string and passcode for decryption
  /// Returns the number of imported entries, or a failure
  Future<Result<int>> importJson(String encryptedJson, String passcode);
  
  /// Clears all mood data from the repository
  /// Returns true on success, or a failure
  Future<Result<bool>> clearAllData();
}

/// Abstract repository interface for tag-related operations
abstract class TagRepository {
  /// Inserts a new tag into the repository
  /// Returns the inserted tag on success, or a failure
  Future<Result<Tag>> insertTag(Tag tag);
  
  /// Updates an existing tag
  /// Returns the updated tag on success, or a failure
  Future<Result<Tag>> updateTag(Tag tag);
  
  /// Deletes a tag by its ID
  /// Returns true on successful deletion, or a failure
  Future<Result<bool>> deleteTag(String tagId);
  
  /// Retrieves a tag by its ID
  /// Returns the tag if found, or a failure
  Future<Result<Tag?>> getTagById(String tagId);
  
  /// Retrieves a tag by its name
  /// Returns the tag if found, or a failure
  Future<Result<Tag?>> getTagByName(String name);
  
  /// Retrieves all tags
  /// Returns a list of all tags, or a failure
  Future<Result<List<Tag>>> getAllTags();
  
  /// Retrieves tags associated with a specific mood entry
  /// Returns a list of tags, or a failure
  Future<Result<List<Tag>>> getTagsForMood(String moodId);
  
  /// Associates a tag with a mood entry
  /// Returns true on success, or a failure
  Future<Result<bool>> addTagToMood(String moodId, String tagId);
  
  /// Removes a tag association from a mood entry
  /// Returns true on success, or a failure
  Future<Result<bool>> removeTagFromMood(String moodId, String tagId);
  
  /// Clears all tag data from the repository
  /// Returns true on success, or a failure
  Future<Result<bool>> clearAllTags();
}
