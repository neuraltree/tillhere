import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../core/entities/mood_entry.dart';
import '../../core/entities/mood_vocabulary.dart';
import '../../core/repositories/mood_repository.dart';

/// Provider for managing mood capture state
/// Following Clean Architecture principles - presentation layer
class MoodCaptureProvider extends ChangeNotifier {
  final MoodRepository _moodRepository;

  // Form state
  double _moodScore = 5.0;
  String _noteText = '';
  DateTime _selectedDateTime = DateTime.now();
  final List<Tag> _selectedTags = [];

  // UI state
  bool _isLoading = false;
  String? _errorMessage;
  MoodEntry? _editingMoodEntry;

  // Form validation
  bool _hasSliderMoved = false;
  bool _hasTextEntered = false;

  MoodCaptureProvider({required MoodRepository moodRepository}) : _moodRepository = moodRepository;

  // Getters
  double get moodScore => _moodScore;
  String get noteText => _noteText;
  DateTime get selectedDateTime => _selectedDateTime;
  List<Tag> get selectedTags => List.unmodifiable(_selectedTags);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  MoodEntry? get editingMoodEntry => _editingMoodEntry;
  bool get hasSliderMoved => _hasSliderMoved;
  bool get hasTextEntered => _hasTextEntered;

  /// Check if the send/save button should be enabled
  bool get canSubmit => _hasSliderMoved || _hasTextEntered;

  /// Check if we're in editing mode
  bool get isEditing => _editingMoodEntry != null;

  /// Update mood score from slider
  void updateMoodScore(double value) {
    _moodScore = value;
    _hasSliderMoved = true;
    _clearError();

    // Provide haptic feedback
    HapticFeedback.selectionClick();

    notifyListeners();
  }

  /// Update note text
  void updateNoteText(String text) {
    _noteText = text;
    _hasTextEntered = text.trim().isNotEmpty;
    _clearError();
    notifyListeners();
  }

  /// Update selected date and time
  void updateDateTime(DateTime dateTime) {
    _selectedDateTime = dateTime;
    notifyListeners();
  }

  /// Add a tag to selection
  void addTag(Tag tag) {
    if (!_selectedTags.any((t) => t.id == tag.id)) {
      _selectedTags.add(tag);
      notifyListeners();
    }
  }

  /// Remove a tag from selection
  void removeTag(Tag tag) {
    _selectedTags.removeWhere((t) => t.id == tag.id);
    notifyListeners();
  }

  /// Toggle tag selection
  void toggleTag(Tag tag) {
    if (_selectedTags.any((t) => t.id == tag.id)) {
      removeTag(tag);
    } else {
      addTag(tag);
    }
  }

  /// Check if a tag is selected
  bool isTagSelected(Tag tag) {
    return _selectedTags.any((t) => t.id == tag.id);
  }

  /// Clear error message
  void _clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  /// Set error message
  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  /// Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Reset form to initial state
  void resetForm() {
    _moodScore = 5.0;
    _noteText = '';
    _selectedDateTime = DateTime.now();
    _selectedTags.clear();
    _hasSliderMoved = false;
    _hasTextEntered = false;
    _editingMoodEntry = null;
    _clearError();
    notifyListeners();
  }

  /// Load mood entry for editing
  void loadMoodForEditing(MoodEntry moodEntry) {
    _editingMoodEntry = moodEntry;
    _moodScore = moodEntry.moodScore.toDouble();
    _noteText = moodEntry.note ?? '';
    _selectedDateTime = moodEntry.timestampUtc.toLocal(); // Convert to local time
    _selectedTags.clear();
    _selectedTags.addAll(moodEntry.tags);
    _hasSliderMoved = true;
    _hasTextEntered = _noteText.isNotEmpty;
    _clearError();
    notifyListeners();
  }

  /// Save mood entry (create or update)
  Future<bool> saveMoodEntry() async {
    if (!canSubmit) {
      _setError('Please move the slider or enter a note');
      return false;
    }

    _setLoading(true);

    try {
      final moodEntry = MoodEntry(
        id: _editingMoodEntry?.id ?? _generateMoodId(),
        timestampUtc: _selectedDateTime.toUtc(), // Store as UTC
        moodScore: _moodScore.round(),
        note: _noteText.trim().isEmpty ? null : _noteText.trim(),
        tags: List.from(_selectedTags),
      );

      final result = await _moodRepository.insertMood(moodEntry);

      if (result.isSuccess) {
        resetForm();
        _setLoading(false);
        return true;
      } else {
        _setError(result.failure?.message ?? 'Failed to save mood entry');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('An unexpected error occurred: $e');
      _setLoading(false);
      return false;
    }
  }

  /// Delete current mood entry (only available in edit mode)
  Future<bool> deleteMoodEntry() async {
    if (_editingMoodEntry == null) {
      _setError('No mood entry to delete');
      return false;
    }

    _setLoading(true);

    try {
      final result = await _moodRepository.deleteMood(_editingMoodEntry!.id);

      if (result.isSuccess) {
        resetForm();
        _setLoading(false);
        return true;
      } else {
        _setError(result.failure?.message ?? 'Failed to delete mood entry');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('An unexpected error occurred: $e');
      _setLoading(false);
      return false;
    }
  }

  /// Generate a unique mood ID
  String _generateMoodId() {
    return 'mood_${DateTime.now().millisecondsSinceEpoch}';
  }

  /// Get mood color based on score using vocabulary system
  /// Returns a color that matches the mood vocabulary
  static int getMoodColor(double moodScore) {
    return MoodVocabulary.getColorForScore(moodScore).toARGB32();
  }

  /// Get mood label based on score using vocabulary system
  static String getMoodLabel(double moodScore) {
    return MoodVocabulary.getLabelForScore(moodScore);
  }

  /// Get mood step for current score
  MoodStep? get currentMoodStep => MoodVocabulary.getStepForDouble(_moodScore);

  /// Update mood score from text analysis
  void updateMoodFromText(String text) {
    final suggestedScore = MoodVocabulary.getSmartMoodSuggestion(text);

    // Only update if we found a meaningful suggestion different from current
    if (suggestedScore != 5 && // Not just the default "OK"
        (moodScore.round() - suggestedScore).abs() > 1) {
      // Significant difference
      updateMoodScore(suggestedScore.toDouble());
    }
  }
}
