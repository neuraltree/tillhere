import 'package:flutter/material.dart';

/// Represents a single step in the mood scale with canonical label, synonyms, color, and emoji
class MoodStep {
  final String canonicalLabel;
  final List<String> synonyms;
  final Color color;
  final String emoji;

  const MoodStep({required this.canonicalLabel, required this.synonyms, required this.color, required this.emoji});

  /// Get all words (canonical + synonyms) for this mood step
  List<String> get allWords => [canonicalLabel, ...synonyms];

  /// Check if a word matches this mood step (case-insensitive)
  bool containsWord(String word) {
    final normalizedWord = _normalizeWord(word);
    return allWords.any((w) => _normalizeWord(w) == normalizedWord);
  }

  /// Normalize word for comparison (lowercase, strip punctuation)
  String _normalizeWord(String word) {
    return word.toLowerCase().replaceAll(RegExp(r'[^\w\s]'), '').trim();
  }

  @override
  String toString() => 'MoodStep($canonicalLabel: ${synonyms.join(", ")})';
}

/// Complete mood scale vocabulary mapping
class MoodVocabulary {
  static const Map<int, MoodStep> scale = {
    1: MoodStep(
      canonicalLabel: 'Ruined',
      synonyms: ['devastated', 'shattered', 'lifeless'],
      color: Color(0xFFCC0000), // Dark Red
      emoji: '😭',
    ),
    2: MoodStep(
      canonicalLabel: 'Miserable',
      synonyms: ['desolate', 'crushed', 'hopeless'],
      color: Color(0xFFFF0000), // Red
      emoji: '😢',
    ),
    3: MoodStep(
      canonicalLabel: 'Sad',
      synonyms: ['down', 'blue', 'gloomy'],
      color: Color(0xFFFF4500), // Red Orange
      emoji: '😞',
    ),
    4: MoodStep(
      canonicalLabel: 'Meh',
      synonyms: ['flat', 'jaded', 'listless'],
      color: Color(0xFFFF8C00), // Dark Orange
      emoji: '😕',
    ),
    5: MoodStep(
      canonicalLabel: 'OK',
      synonyms: ['neutral', 'fine', 'steady'],
      color: Color(0xFFFFD700), // Gold/Yellow
      emoji: '😐',
    ),
    6: MoodStep(
      canonicalLabel: 'Content',
      synonyms: ['calm', 'relaxed', 'easy-going'],
      color: Color(0xFFADFF2F), // Green Yellow
      emoji: '🙂',
    ),
    7: MoodStep(
      canonicalLabel: 'Happy',
      synonyms: ['pleased', 'upbeat', 'cheerful'],
      color: Color(0xFF7FFF00), // Chartreuse
      emoji: '😊',
    ),
    8: MoodStep(
      canonicalLabel: 'Thrilled',
      synonyms: ['excited', 'energised', 'buzzing'],
      color: Color(0xFF32CD32), // Lime Green
      emoji: '😄',
    ),
    9: MoodStep(
      canonicalLabel: 'Ecstatic',
      synonyms: ['elated', 'euphoric', 'overjoyed'],
      color: Color(0xFF228B22), // Forest Green
      emoji: '😁',
    ),
    10: MoodStep(
      canonicalLabel: 'Bliss',
      synonyms: ['rapturous', 'transcendent', 'exalted'],
      color: Color(0xFF006400), // Dark Green
      emoji: '🤩',
    ),
  };

  /// Get mood step for a given score
  static MoodStep? getStep(int score) {
    return scale[score];
  }

  /// Get mood step for a given score (double)
  static MoodStep? getStepForDouble(double score) {
    return getStep(score.round());
  }

  /// Find mood score for a given word (case-insensitive)
  static int? findScoreForWord(String word) {
    for (final entry in scale.entries) {
      if (entry.value.containsWord(word)) {
        return entry.key;
      }
    }
    return null;
  }

  /// Get all possible mood words (for autocomplete)
  static List<String> getAllWords() {
    final words = <String>[];
    for (final step in scale.values) {
      words.addAll(step.allWords);
    }
    return words;
  }

  /// Extract mood words from text and return the highest scoring match
  static int? extractMoodFromText(String text) {
    final words = _extractWords(text);
    int? highestScore;

    for (final word in words) {
      final score = findScoreForWord(word);
      if (score != null) {
        if (highestScore == null || score > highestScore) {
          highestScore = score;
        }
      }
    }

    return highestScore;
  }

  /// Extract individual words from text
  static List<String> _extractWords(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), ' ')
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList();
  }

  /// Get color for a mood score
  static Color getColorForScore(double score) {
    final step = getStepForDouble(score);
    return step?.color ?? const Color(0xFF666666);
  }

  /// Get canonical label for a mood score
  static String getLabelForScore(double score) {
    final step = getStepForDouble(score);
    return step?.canonicalLabel ?? 'Unknown';
  }

  /// Get emoji for a mood score
  static String getEmojiForScore(double score) {
    final step = getStepForDouble(score);
    return step?.emoji ?? '😐';
  }

  /// Sentiment analysis fallback for unknown words
  /// Maps valence ∈ [-1, 1] to score = round((valence+1)*4.5)+1
  static int sentimentToScore(double valence) {
    // Clamp valence to [-1, 1] range
    final clampedValence = valence.clamp(-1.0, 1.0);

    // Convert to 1-10 scale
    final score = ((clampedValence + 1) * 4.5 + 1).round();

    // Ensure score is within valid range
    return score.clamp(1, 10);
  }

  /// Simple sentiment analysis for common words (fallback implementation)
  /// In a real app, you'd use a proper sentiment analysis library
  static double getSimpleSentiment(String word) {
    final normalizedWord = word.toLowerCase().trim();

    // Positive words
    const positiveWords = {
      'good': 0.6,
      'great': 0.8,
      'awesome': 0.9,
      'amazing': 0.9,
      'wonderful': 0.8,
      'fantastic': 0.9,
      'excellent': 0.8,
      'love': 0.7,
      'like': 0.5,
      'enjoy': 0.6,
      'fun': 0.6,
      'nice': 0.5,
      'beautiful': 0.7,
      'perfect': 0.9,
    };

    // Negative words
    const negativeWords = {
      'bad': -0.6,
      'terrible': -0.8,
      'awful': -0.9,
      'horrible': -0.9,
      'hate': -0.8,
      'dislike': -0.5,
      'annoying': -0.6,
      'frustrating': -0.7,
      'angry': -0.7,
      'upset': -0.6,
      'worried': -0.5,
      'stressed': -0.7,
      'tired': -0.4,
      'exhausted': -0.6,
      'sick': -0.6,
    };

    if (positiveWords.containsKey(normalizedWord)) {
      return positiveWords[normalizedWord]!;
    }

    if (negativeWords.containsKey(normalizedWord)) {
      return negativeWords[normalizedWord]!;
    }

    return 0.0; // Neutral
  }

  /// Analyze text and suggest mood score using sentiment analysis
  static int analyzeTextSentiment(String text) {
    final words = _extractWords(text);
    if (words.isEmpty) return 5; // Default to OK

    double totalSentiment = 0.0;
    int wordCount = 0;

    for (final word in words) {
      final sentiment = getSimpleSentiment(word);
      if (sentiment != 0.0) {
        totalSentiment += sentiment;
        wordCount++;
      }
    }

    if (wordCount == 0) return 5; // No sentiment words found, default to OK

    final averageSentiment = totalSentiment / wordCount;
    return sentimentToScore(averageSentiment);
  }

  /// Get smart mood suggestion from text (combines exact matching and sentiment)
  static int getSmartMoodSuggestion(String text) {
    // First try exact word matching
    final exactMatch = extractMoodFromText(text);
    if (exactMatch != null) {
      return exactMatch;
    }

    // Fall back to sentiment analysis
    return analyzeTextSentiment(text);
  }
}

/// Extension methods for easier access
extension MoodScoreExtensions on double {
  /// Get the mood step for this score
  MoodStep? get moodStep => MoodVocabulary.getStepForDouble(this);

  /// Get the color for this mood score
  Color get moodColor => MoodVocabulary.getColorForScore(this);

  /// Get the canonical label for this mood score
  String get moodLabel => MoodVocabulary.getLabelForScore(this);

  /// Get the emoji for this mood score
  String get moodEmoji => MoodVocabulary.getEmojiForScore(this);
}

extension MoodScoreIntExtensions on int {
  /// Get the mood step for this score
  MoodStep? get moodStep => MoodVocabulary.getStep(this);

  /// Get the color for this mood score
  Color get moodColor => MoodVocabulary.getColorForScore(toDouble());

  /// Get the canonical label for this mood score
  String get moodLabel => MoodVocabulary.getLabelForScore(toDouble());

  /// Get the emoji for this mood score
  String get moodEmoji => MoodVocabulary.getEmojiForScore(toDouble());
}
