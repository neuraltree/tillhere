import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/entities/mood_vocabulary.dart';
import '../../core/services/deep_linking_service.dart';
import '../../data/datasources/local/database_helper.dart';
import '../../data/repositories/mood_repository_impl.dart';
import '../providers/mood_capture_provider.dart';

/// Clean, unified text input component similar to Telegram/WhatsApp
/// Can be used as fixed bottom input or standalone input field
class FixedTextInput extends StatefulWidget {
  final String placeholder;
  final VoidCallback? onSubmit;
  final EdgeInsets? padding;

  const FixedTextInput({super.key, this.placeholder = 'How are you feeling?', this.onSubmit, this.padding});

  @override
  State<FixedTextInput> createState() => _FixedTextInputState();
}

class _FixedTextInputState extends State<FixedTextInput> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  int? _selectedMoodScore = 7; // Default to happy
  bool _isSliderActive = false; // Track if slider is being touched/moved

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();

    // Initialize with provider's current text if available and set smart default mood
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        try {
          final provider = context.read<MoodCaptureProvider>();
          _controller.text = provider.noteText;
          _controller.addListener(_onTextChanged);

          // Set smart default mood score
          _setSmartDefaultMoodScore();
        } catch (e) {
          // Provider might not be available in all contexts
          debugPrint('MoodCaptureProvider not available: $e');
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    try {
      final provider = context.read<MoodCaptureProvider>();
      provider.updateNoteText(_controller.text);
      setState(() {}); // Update button state
    } catch (e) {
      // Provider might not be available
    }
  }

  void _handleSubmit() async {
    if (_controller.text.trim().isNotEmpty || _selectedMoodScore != null) {
      try {
        final provider = context.read<MoodCaptureProvider>();

        // Update provider with current values
        if (_selectedMoodScore != null) {
          provider.updateMoodScore(_selectedMoodScore!.toDouble());
        }
        provider.updateNoteText(_controller.text);

        // Save to database
        final success = await provider.saveMoodEntry();

        if (success) {
          // Clear the input after successful save
          _controller.clear();
          // Reset to smart default (will be 1 point higher than the entry we just saved)
          _setSmartDefaultMoodScore();

          // Show success feedback
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Mood saved successfully!'),
                backgroundColor: AppColors.neonGreen,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        } else {
          // Show error feedback
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(provider.errorMessage ?? 'Failed to save mood'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        }

        // Call the original onSubmit callback if provided
        widget.onSubmit?.call();
      } catch (e) {
        // Handle any errors
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red, duration: const Duration(seconds: 3)),
          );
        }
      }
    }
  }

  void _showAdvancedSettings() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildAdvancedSettingsModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return NotificationListener<MoodInputFocusNotification>(
      onNotification: (notification) {
        // Focus the text input when notification is received
        _focusNode.requestFocus();
        return true;
      },
      child: _buildInputWidget(context, isDark),
    );
  }

  Widget _buildInputWidget(BuildContext context, bool isDark) {
    final mediaQuery = MediaQuery.of(context);
    final bottomPadding = mediaQuery.padding.bottom;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.backgroundSecondaryDark : AppColors.backgroundSecondaryLight,
        border: Border(top: BorderSide(color: isDark ? AppColors.dividerDark : AppColors.dividerLight, width: 0.5)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding:
              widget.padding ??
              EdgeInsets.fromLTRB(
                16,
                8,
                16,
                8 + (bottomPadding > 0 ? 4 : 0), // Proper padding for chat-like interface
              ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Mood range slider
              _buildMoodSlider(),
              const SizedBox(height: 8),
              // Text input row
              Row(
                children: [
                  // Settings button
                  GestureDetector(
                    onTap: _showAdvancedSettings,
                    child: Container(
                      width: 40.0,
                      height: 40.0,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.backgroundTertiaryDark : AppColors.backgroundTertiaryLight,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: (isDark ? AppColors.borderDark : AppColors.borderLight).withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        Icons.settings,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Text input field
                  Expanded(
                    child: Container(
                      constraints: const BoxConstraints(
                        maxHeight: 100.0, // Max height for about 4 lines
                      ),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.backgroundTertiaryDark : AppColors.backgroundTertiaryLight,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _focusNode.hasFocus
                              ? AppColors.neonGreen.withValues(alpha: 0.5)
                              : (isDark ? AppColors.borderDark : AppColors.borderLight).withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        maxLines: null,
                        minLines: 1,
                        textInputAction: TextInputAction.newline,
                        decoration: InputDecoration(
                          hintText: widget.placeholder,
                          hintStyle: TextStyle(
                            color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                        style: TextStyle(
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                        onSubmitted: (_) => _handleSubmit(),
                        onTapOutside: (_) => _focusNode.unfocus(),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12), // Proper spacing between input and button
                  // Submit button
                  GestureDetector(
                    onTap: _handleSubmit,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 40.0,
                      height: 40.0,
                      decoration: BoxDecoration(
                        color: (_controller.text.trim().isNotEmpty || _selectedMoodScore != null)
                            ? AppColors.neonGreen
                            : (isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.send_rounded,
                        color: (_controller.text.trim().isNotEmpty || _selectedMoodScore != null)
                            ? AppColors.backgroundPrimaryDark
                            : (isDark ? AppColors.backgroundSecondaryDark : AppColors.backgroundSecondaryLight),
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMoodSlider() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Slider with bubble
          Stack(
            clipBehavior: Clip.none,
            children: [
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: _getMoodColor(_selectedMoodScore ?? 5),
                  inactiveTrackColor: (isDark ? AppColors.borderDark : AppColors.borderLight).withValues(alpha: 0.3),
                  thumbColor: _getMoodColor(_selectedMoodScore ?? 5),
                  overlayColor: _getMoodColor(_selectedMoodScore ?? 5).withValues(alpha: 0.2),
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                  trackHeight: 6,
                ),
                child: Slider(
                  value: (_selectedMoodScore ?? 5).toDouble(),
                  min: 1,
                  max: 10,
                  divisions: 9,
                  onChangeStart: (value) {
                    setState(() {
                      _isSliderActive = true;
                    });
                  },
                  onChanged: (value) {
                    setState(() {
                      _selectedMoodScore = value.round();
                    });

                    // Update provider with new mood score
                    try {
                      final provider = context.read<MoodCaptureProvider>();
                      provider.updateMoodScore(value);
                    } catch (e) {
                      // Provider might not be available in all contexts
                      debugPrint('MoodCaptureProvider not available: $e');
                    }
                  },
                  onChangeEnd: (value) {
                    setState(() {
                      _isSliderActive = false;
                    });
                  },
                ),
              ),

              // Bubble tooltip - only show when slider is being touched/moved
              if (_selectedMoodScore != null && _isSliderActive)
                Positioned(
                  left: _getBubblePosition(),
                  top: -40,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getMoodColor(_selectedMoodScore!),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      _getMoodLabel(_selectedMoodScore!),
                      style: TextStyle(
                        color: _getBubbleTextColor(_selectedMoodScore!),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _getMoodLabel(int score) {
    return '${score.moodEmoji} ${score.moodLabel}';
  }

  Color _getMoodColor(int score) {
    // Use the same color system as the heatmap for consistency
    return MoodVocabulary.getColorForScore(score.toDouble());
  }

  double _getBubblePosition() {
    if (_selectedMoodScore == null) return 0;

    // Get the actual slider widget width
    final screenWidth = MediaQuery.of(context).size.width;
    final containerPadding = 32.0; // 16 left + 16 right from container padding
    final sliderPadding = 32.0; // Internal slider padding
    final availableWidth = screenWidth - containerPadding - sliderPadding;

    // Calculate thumb position (0-1 normalized)
    final normalizedPosition = (_selectedMoodScore! - 1) / 9;
    final thumbPosition = normalizedPosition * availableWidth;

    // Calculate bubble width (estimate based on content)
    final bubbleWidth = _getMoodLabel(_selectedMoodScore!).length * 8.0 + 20; // Rough estimate

    // Center bubble over thumb, but clamp to screen bounds
    double bubbleLeft = thumbPosition + (containerPadding / 2) + (sliderPadding / 2) - (bubbleWidth / 2);

    // Clamp to prevent going off screen
    final minLeft = 8.0; // Minimum margin from screen edge
    final maxLeft = screenWidth - bubbleWidth - 8.0; // Maximum position

    return bubbleLeft.clamp(minLeft, maxLeft);
  }

  Color _getBubbleTextColor(int score) {
    // Use black text for light/bright colors, white for dark colors
    if (score >= 5 && score <= 7) {
      return Colors.black; // Yellow and light green backgrounds need black text
    } else {
      return Colors.white; // Dark red and dark green use white text
    }
  }

  /// Set smart default mood score based on recent entries
  Future<void> _setSmartDefaultMoodScore() async {
    try {
      // Import necessary classes
      final databaseHelper = DatabaseHelper();
      final moodRepository = MoodRepositoryImpl(databaseHelper);

      // Get recent mood entries
      final result = await moodRepository.getAllMoods();
      if (result.isSuccess) {
        final allMoods = result.data ?? [];
        if (allMoods.isNotEmpty) {
          // Sort by timestamp descending (most recent first)
          allMoods.sort((a, b) => b.timestampUtc.compareTo(a.timestampUtc));
          final mostRecentMood = allMoods.first;

          // Set to 1 point higher than most recent, capped at 10 (bliss)
          final newDefault = (mostRecentMood.moodScore + 1).clamp(1, 10);

          if (mounted) {
            setState(() {
              _selectedMoodScore = newDefault;
            });
          }
        }
        // If no moods exist, keep the default of 7 (happy)
      }
    } catch (e) {
      // If there's an error, keep the default of 7 (happy)
      debugPrint('Error setting smart default mood score: $e');
    }
  }

  Widget _buildAdvancedSettingsModal() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.backgroundSecondaryDark : AppColors.backgroundSecondaryLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Advanced Settings',
              style: TextStyle(
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),

            // Date/Time setting
            ListTile(
              leading: Icon(Icons.schedule, color: AppColors.neonGreen),
              title: Text(
                'Set Date & Time',
                style: TextStyle(color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
              ),
              subtitle: Text(
                'Change when this mood entry occurred',
                style: TextStyle(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
              ),
              onTap: () {
                Navigator.pop(context);
                _showDateTimePicker(context);
              },
            ),

            // Tags setting
            ListTile(
              leading: Icon(Icons.tag, color: AppColors.solarOrange),
              title: Text(
                'Add Tags',
                style: TextStyle(color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
              ),
              subtitle: Text(
                'Categorize this mood entry',
                style: TextStyle(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
              ),
              onTap: () {
                Navigator.pop(context);
                _showTagsSelector(context);
              },
            ),

            const SizedBox(height: 20),

            // Close button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.neonGreen,
                  foregroundColor: AppColors.backgroundPrimaryDark,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Done'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Show date/time picker for setting custom entry time
  void _showDateTimePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildDateTimePickerModal(context),
    );
  }

  /// Show tags selector for adding tags to mood entry
  void _showTagsSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildTagsSelectorModal(context),
    );
  }

  /// Build date/time picker modal
  Widget _buildDateTimePickerModal(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.backgroundSecondaryDark : AppColors.backgroundSecondaryLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Set Date & Time',
              style: TextStyle(
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),

            Text(
              'This feature will be available soon to set custom dates for past mood entries.',
              style: TextStyle(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.neonGreen,
                  foregroundColor: AppColors.backgroundPrimaryDark,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Got it'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build tags selector modal
  Widget _buildTagsSelectorModal(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.backgroundSecondaryDark : AppColors.backgroundSecondaryLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add Tags',
              style: TextStyle(
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),

            Text(
              'This feature will be available soon to add custom tags to categorize your mood entries.',
              style: TextStyle(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.neonGreen,
                  foregroundColor: AppColors.backgroundPrimaryDark,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Got it'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
