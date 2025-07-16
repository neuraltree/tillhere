import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../entities/mood_vocabulary.dart';

/// Service for managing custom mood words and accessibility preferences
/// Allows users to personalize their mood vocabulary while maintaining the core system
class MoodCustomizationService {
  static const String _customWordsKey = 'custom_mood_words';
  static const String _accessibilityKey = 'mood_accessibility_settings';
  static const String _colorBlindModeKey = 'color_blind_mode';

  static MoodCustomizationService? _instance;
  static MoodCustomizationService get instance {
    _instance ??= MoodCustomizationService._();
    return _instance!;
  }

  MoodCustomizationService._();

  /// Custom word mappings (score -> custom canonical label)
  Map<int, String> _customWords = {};
  
  /// Accessibility settings
  bool _showNumericValues = false;
  bool _enableHapticFeedback = true;
  bool _colorBlindMode = false;
  
  /// Color-blind friendly palette
  static const Map<int, Color> _colorBlindPalette = {
    1: Color(0xFF000080), // Dark blue
    2: Color(0xFF0000CC), // Blue
    3: Color(0xFF0066FF), // Light blue
    4: Color(0xFF00CCFF), // Cyan
    5: Color(0xFF66FF66), // Light green
    6: Color(0xFF00FF00), // Green
    7: Color(0xFFFFFF00), // Yellow
    8: Color(0xFFFFCC00), // Orange-yellow
    9: Color(0xFFFF6600), // Orange
    10: Color(0xFFFF0000), // Red
  };

  // Getters
  Map<int, String> get customWords => Map.unmodifiable(_customWords);
  bool get showNumericValues => _showNumericValues;
  bool get enableHapticFeedback => _enableHapticFeedback;
  bool get colorBlindMode => _colorBlindMode;

  /// Initialize the service by loading saved preferences
  Future<void> initialize() async {
    await _loadCustomWords();
    await _loadAccessibilitySettings();
  }

  /// Get the display label for a mood score (custom or default)
  String getDisplayLabel(int score) {
    if (_customWords.containsKey(score)) {
      return _customWords[score]!;
    }
    return MoodVocabulary.getStep(score)?.canonicalLabel ?? 'Unknown';
  }

  /// Get the color for a mood score (color-blind friendly if enabled)
  Color getDisplayColor(int score) {
    if (_colorBlindMode && _colorBlindPalette.containsKey(score)) {
      return _colorBlindPalette[score]!;
    }
    return MoodVocabulary.getStep(score)?.color ?? Colors.grey;
  }

  /// Set a custom word for a specific mood score
  Future<void> setCustomWord(int score, String customWord) async {
    if (score < 1 || score > 10) return;
    
    _customWords[score] = customWord.trim();
    await _saveCustomWords();
  }

  /// Remove custom word for a specific mood score (revert to default)
  Future<void> removeCustomWord(int score) async {
    _customWords.remove(score);
    await _saveCustomWords();
  }

  /// Clear all custom words
  Future<void> clearAllCustomWords() async {
    _customWords.clear();
    await _saveCustomWords();
  }

  /// Update accessibility settings
  Future<void> updateAccessibilitySettings({
    bool? showNumericValues,
    bool? enableHapticFeedback,
    bool? colorBlindMode,
  }) async {
    if (showNumericValues != null) {
      _showNumericValues = showNumericValues;
    }
    if (enableHapticFeedback != null) {
      _enableHapticFeedback = enableHapticFeedback;
    }
    if (colorBlindMode != null) {
      _colorBlindMode = colorBlindMode;
    }
    
    await _saveAccessibilitySettings();
  }

  /// Load custom words from storage
  Future<void> _loadCustomWords() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final customWordsJson = prefs.getString(_customWordsKey);
      
      if (customWordsJson != null) {
        final Map<String, dynamic> decoded = jsonDecode(customWordsJson);
        _customWords = decoded.map((key, value) => MapEntry(int.parse(key), value.toString()));
      }
    } catch (e) {
      // Handle error gracefully - use defaults
      _customWords = {};
    }
  }

  /// Save custom words to storage
  Future<void> _saveCustomWords() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final customWordsJson = jsonEncode(_customWords.map((key, value) => MapEntry(key.toString(), value)));
      await prefs.setString(_customWordsKey, customWordsJson);
    } catch (e) {
      // Handle error gracefully
    }
  }

  /// Load accessibility settings from storage
  Future<void> _loadAccessibilitySettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _showNumericValues = prefs.getBool('${_accessibilityKey}_numeric') ?? false;
      _enableHapticFeedback = prefs.getBool('${_accessibilityKey}_haptic') ?? true;
      _colorBlindMode = prefs.getBool(_colorBlindModeKey) ?? false;
    } catch (e) {
      // Handle error gracefully - use defaults
      _showNumericValues = false;
      _enableHapticFeedback = true;
      _colorBlindMode = false;
    }
  }

  /// Save accessibility settings to storage
  Future<void> _saveAccessibilitySettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('${_accessibilityKey}_numeric', _showNumericValues);
      await prefs.setBool('${_accessibilityKey}_haptic', _enableHapticFeedback);
      await prefs.setBool(_colorBlindModeKey, _colorBlindMode);
    } catch (e) {
      // Handle error gracefully
    }
  }

  /// Export custom settings as JSON (for backup/sharing)
  Map<String, dynamic> exportSettings() {
    return {
      'customWords': _customWords,
      'accessibility': {
        'showNumericValues': _showNumericValues,
        'enableHapticFeedback': _enableHapticFeedback,
        'colorBlindMode': _colorBlindMode,
      },
      'version': '1.0',
      'exportDate': DateTime.now().toIso8601String(),
    };
  }

  /// Import custom settings from JSON
  Future<bool> importSettings(Map<String, dynamic> settings) async {
    try {
      // Validate version compatibility
      final version = settings['version'] as String?;
      if (version != '1.0') {
        return false; // Unsupported version
      }

      // Import custom words
      if (settings.containsKey('customWords')) {
        final customWordsData = settings['customWords'] as Map<String, dynamic>;
        _customWords = customWordsData.map((key, value) => MapEntry(int.parse(key), value.toString()));
      }

      // Import accessibility settings
      if (settings.containsKey('accessibility')) {
        final accessibilityData = settings['accessibility'] as Map<String, dynamic>;
        _showNumericValues = accessibilityData['showNumericValues'] as bool? ?? false;
        _enableHapticFeedback = accessibilityData['enableHapticFeedback'] as bool? ?? true;
        _colorBlindMode = accessibilityData['colorBlindMode'] as bool? ?? false;
      }

      // Save imported settings
      await _saveCustomWords();
      await _saveAccessibilitySettings();

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Reset all settings to defaults
  Future<void> resetToDefaults() async {
    _customWords.clear();
    _showNumericValues = false;
    _enableHapticFeedback = true;
    _colorBlindMode = false;

    await _saveCustomWords();
    await _saveAccessibilitySettings();
  }

  /// Get mood statistics for analytics
  Map<String, dynamic> getMoodStatistics() {
    return {
      'customWordsCount': _customWords.length,
      'customizedScores': _customWords.keys.toList(),
      'accessibilityEnabled': _showNumericValues || !_enableHapticFeedback || _colorBlindMode,
      'colorBlindMode': _colorBlindMode,
    };
  }
}

/// Extension to integrate customization service with mood vocabulary
extension CustomizedMoodVocabulary on MoodVocabulary {
  /// Get customized label for a score
  static String getCustomizedLabel(int score) {
    return MoodCustomizationService.instance.getDisplayLabel(score);
  }

  /// Get customized color for a score
  static Color getCustomizedColor(int score) {
    return MoodCustomizationService.instance.getDisplayColor(score);
  }

  /// Check if accessibility features are enabled
  static bool get accessibilityEnabled {
    final service = MoodCustomizationService.instance;
    return service.showNumericValues || service.colorBlindMode;
  }
}
