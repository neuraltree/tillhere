import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../core/entities/mood_entry.dart';
import '../../core/entities/mood_vocabulary.dart';
import '../../core/theme/app_colors.dart';
import '../../data/repositories/mood_repository_impl.dart';
import '../../data/datasources/local/database_helper.dart';

/// All Entries Page - displays all mood entries with pagination, search, and filtering
/// Follows Apple design standards and TillHere's cosmic theme
class AllEntriesPage extends StatefulWidget {
  const AllEntriesPage({super.key});

  @override
  State<AllEntriesPage> createState() => _AllEntriesPageState();
}

class _AllEntriesPageState extends State<AllEntriesPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  List<MoodEntry> _allEntries = [];
  List<MoodEntry> _filteredEntries = [];
  bool _isLoading = false;
  bool _hasMore = true;
  String? _error;

  // Pagination
  static const int _pageSize = 20;
  int _currentPage = 0;

  // Filters
  String _searchQuery = '';
  DateTimeRange? _dateRange;

  @override
  void initState() {
    super.initState();
    _loadEntries();
    _scrollController.addListener(_onScroll);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  /// Load mood entries from database
  Future<void> _loadEntries() async {
    if (_isLoading || !_hasMore) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final databaseHelper = DatabaseHelper();
      final moodRepository = MoodRepositoryImpl(databaseHelper);

      final result = await moodRepository.getAllMoods();
      if (result.isSuccess) {
        final allMoods = result.data ?? [];
        // Sort by timestamp descending (most recent first)
        allMoods.sort((a, b) => b.timestampUtc.compareTo(a.timestampUtc));

        setState(() {
          _allEntries = allMoods;
          _applyFilters();
        });
      } else {
        setState(() {
          _error = 'Failed to load entries: ${result.failure?.message}';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error loading entries: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Apply search and date range filters
  void _applyFilters() {
    var filtered = _allEntries.where((entry) {
      // Search filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final noteMatches = entry.note?.toLowerCase().contains(query) ?? false;
        final tagMatches = entry.tags.any((tag) => tag.name.toLowerCase().contains(query));
        if (!noteMatches && !tagMatches) return false;
      }

      // Date range filter
      if (_dateRange != null) {
        final entryDate = entry.timestampUtc.toLocal();
        final entryDateOnly = DateTime(entryDate.year, entryDate.month, entryDate.day);
        final startDate = DateTime(_dateRange!.start.year, _dateRange!.start.month, _dateRange!.start.day);
        final endDate = DateTime(_dateRange!.end.year, _dateRange!.end.month, _dateRange!.end.day);

        if (entryDateOnly.isBefore(startDate) || entryDateOnly.isAfter(endDate)) {
          return false;
        }
      }

      return true;
    }).toList();

    setState(() {
      _filteredEntries = filtered;
      _hasMore = false; // For now, load all at once
    });
  }

  /// Handle scroll for pagination
  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      // Load more when near bottom (for future pagination implementation)
    }
  }

  /// Handle search input changes
  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
    });
    _applyFilters();
  }

  /// Show date range picker
  Future<void> _showDateRangePicker() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _dateRange,
      builder: (context, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(
              context,
            ).colorScheme.copyWith(primary: isDark ? AppColors.neonGreen : AppColors.cosmicBlue),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _dateRange = picked;
      });
      _applyFilters();
    }
  }

  /// Clear all filters
  void _clearFilters() {
    setState(() {
      _searchQuery = '';
      _dateRange = null;
    });
    _searchController.clear();
    _applyFilters();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Entries'),
        backgroundColor: isDark ? AppColors.backgroundPrimaryDark : AppColors.backgroundPrimaryLight,
        foregroundColor: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
        elevation: 0,
        actions: [
          if (_searchQuery.isNotEmpty || _dateRange != null)
            IconButton(icon: const Icon(Icons.clear), onPressed: _clearFilters, tooltip: 'Clear filters'),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              isDark ? AppColors.backgroundPrimaryDark : AppColors.backgroundPrimaryLight,
              isDark ? AppColors.backgroundSecondaryDark : AppColors.backgroundSecondaryLight,
            ],
          ),
        ),
        child: Column(
          children: [
            // Search and filter bar
            _buildFilterBar(context),

            // Entries list
            Expanded(child: _buildEntriesList(context)),
          ],
        ),
      ),
    );
  }

  /// Build filter bar with search and date range
  Widget _buildFilterBar(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Search field
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search notes and tags...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: isDark ? AppColors.neonGreen : AppColors.cosmicBlue, width: 2),
              ),
              filled: true,
              fillColor: isDark ? AppColors.cardDark : AppColors.cardLight,
            ),
          ),

          const SizedBox(height: 12),

          // Date range and filter info
          Row(
            children: [
              // Date range button
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _showDateRangePicker,
                  icon: const Icon(Icons.date_range),
                  label: Text(
                    _dateRange == null
                        ? 'Select date range'
                        : '${DateFormat('MMM d').format(_dateRange!.start)} - ${DateFormat('MMM d').format(_dateRange!.end)}',
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: isDark ? AppColors.neonGreen : AppColors.cosmicBlue,
                    side: BorderSide(color: isDark ? AppColors.neonGreen : AppColors.cosmicBlue),
                  ),
                ),
              ),
            ],
          ),

          // Filter summary
          if (_searchQuery.isNotEmpty || _dateRange != null) ...[
            const SizedBox(height: 8),
            Text(
              'Showing ${_filteredEntries.length} of ${_allEntries.length} entries',
              style: TextStyle(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                fontSize: 14,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Build entries list with loading and error states
  Widget _buildEntriesList(BuildContext context) {
    if (_isLoading && _filteredEntries.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadEntries, child: const Text('Retry')),
          ],
        ),
      );
    }

    if (_filteredEntries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.sentiment_neutral,
              size: 64,
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isNotEmpty || _dateRange != null ? 'No entries match your filters' : 'No mood entries yet',
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _filteredEntries.length + (_hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= _filteredEntries.length) {
          return const Center(
            child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()),
          );
        }

        final entry = _filteredEntries[index];
        return _buildEntryCard(context, entry);
      },
    );
  }

  /// Build individual entry card optimized for list view
  Widget _buildEntryCard(BuildContext context, MoodEntry entry) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final timeFormat = DateFormat('MMM d, h:mm a');

    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 8),
      color: isDark ? AppColors.cardDark : AppColors.cardLight,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row with mood dot, timestamp, and mood emoji
            Row(
              children: [
                // Small mood dot
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: MoodVocabulary.getColorForScore(entry.moodScore.toDouble()),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),

                // Timestamp
                Text(
                  timeFormat.format(entry.timestampUtc.toLocal()),
                  style: TextStyle(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const Spacer(),

                // Mood emoji and score
                Row(
                  children: [
                    Text(
                      MoodVocabulary.getEmojiForScore(entry.moodScore.toDouble()),
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${entry.moodScore}',
                      style: TextStyle(
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // Note content (if available)
            if (entry.note != null && entry.note!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                entry.note!,
                style: TextStyle(
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  fontSize: 14,
                  height: 1.4,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],

            // Tags (if available)
            if (entry.tags.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: entry.tags
                    .map(
                      (tag) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.neonGreen.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.neonGreen.withValues(alpha: 0.3), width: 1),
                        ),
                        child: Text(
                          tag.name,
                          style: TextStyle(color: AppColors.neonGreen, fontSize: 10, fontWeight: FontWeight.w500),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
