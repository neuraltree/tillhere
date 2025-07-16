import 'mood_entry_model.dart';
import 'tag_model.dart';

/// Data model for exporting/importing complete mood data
/// Contains all mood entries, tags, and their relationships
class ExportDataModel {
  final List<MoodEntryModel> moodEntries;
  final List<TagModel> tags;
  final List<MoodTagModel> moodTags;
  final DateTime exportTimestamp;
  final String version;

  const ExportDataModel({
    required this.moodEntries,
    required this.tags,
    required this.moodTags,
    required this.exportTimestamp,
    this.version = '1.0',
  });

  /// Create ExportDataModel from JSON
  factory ExportDataModel.fromJson(Map<String, dynamic> json) {
    return ExportDataModel(
      moodEntries: (json['mood_entries'] as List<dynamic>)
          .map((e) => MoodEntryModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      tags: (json['tags'] as List<dynamic>).map((e) => TagModel.fromJson(e as Map<String, dynamic>)).toList(),
      moodTags: (json['mood_tags'] as List<dynamic>)
          .map((e) => MoodTagModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      exportTimestamp: DateTime.fromMillisecondsSinceEpoch(json['export_timestamp'] as int),
      version: json['version'] as String? ?? '1.0',
    );
  }

  /// Convert ExportDataModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'mood_entries': moodEntries.map((e) => e.toJson()).toList(),
      'tags': tags.map((e) => e.toJson()).toList(),
      'mood_tags': moodTags.map((e) => e.toJson()).toList(),
      'export_timestamp': exportTimestamp.millisecondsSinceEpoch,
      'version': version,
    };
  }

  /// Get statistics about the export data
  ExportStatistics get statistics {
    return ExportStatistics(
      moodEntryCount: moodEntries.length,
      tagCount: tags.length,
      relationshipCount: moodTags.length,
      dateRange: _getDateRange(),
    );
  }

  /// Calculate the date range of mood entries
  ExportDateRange? _getDateRange() {
    if (moodEntries.isEmpty) return null;

    final timestamps = moodEntries.map((e) => e.timestampUtc).toList()..sort();
    return ExportDateRange(
      startDate: DateTime.fromMillisecondsSinceEpoch(timestamps.first),
      endDate: DateTime.fromMillisecondsSinceEpoch(timestamps.last),
    );
  }

  @override
  String toString() {
    return 'ExportDataModel(moodEntries: ${moodEntries.length}, tags: ${tags.length}, moodTags: ${moodTags.length}, exportTimestamp: $exportTimestamp, version: $version)';
  }
}

/// Statistics about exported data
class ExportStatistics {
  final int moodEntryCount;
  final int tagCount;
  final int relationshipCount;
  final ExportDateRange? dateRange;

  const ExportStatistics({
    required this.moodEntryCount,
    required this.tagCount,
    required this.relationshipCount,
    this.dateRange,
  });

  @override
  String toString() {
    return 'ExportStatistics(moodEntries: $moodEntryCount, tags: $tagCount, relationships: $relationshipCount, dateRange: $dateRange)';
  }
}

/// Simple date range class for export statistics
class ExportDateRange {
  final DateTime startDate;
  final DateTime endDate;

  const ExportDateRange({required this.startDate, required this.endDate});

  @override
  String toString() => 'ExportDateRange(start: $startDate, end: $endDate)';
}
