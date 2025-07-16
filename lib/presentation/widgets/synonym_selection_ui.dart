import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import '../../core/entities/mood_vocabulary.dart';

/// Synonym selection overlay that appears on long-press of mood labels
/// Allows users to choose alternative words for their mood
class SynonymSelectionOverlay extends StatefulWidget {
  final MoodStep moodStep;
  final Offset position;
  final Function(String synonym) onSynonymSelected;
  final VoidCallback onDismiss;

  const SynonymSelectionOverlay({
    super.key,
    required this.moodStep,
    required this.position,
    required this.onSynonymSelected,
    required this.onDismiss,
  });

  @override
  State<SynonymSelectionOverlay> createState() => _SynonymSelectionOverlayState();
}

class _SynonymSelectionOverlayState extends State<SynonymSelectionOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.position.dx - 100, // Center the overlay
      top: widget.position.dy - 60, // Position above the label
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Opacity(
              opacity: _opacityAnimation.value,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: 200,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.backgroundSecondaryDark
                        : AppColors.backgroundSecondaryLight,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: widget.moodStep.color.withValues(alpha: 0.3),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadowDark.withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header
                      Text(
                        'Choose your word',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Current canonical label
                      _buildSynonymChip(
                        widget.moodStep.canonicalLabel,
                        isCanonical: true,
                      ),
                      
                      const SizedBox(height: 6),
                      
                      // Synonyms
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: widget.moodStep.synonyms
                            .map((synonym) => _buildSynonymChip(synonym))
                            .toList(),
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Dismiss button
                      GestureDetector(
                        onTap: widget.onDismiss,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.textTertiaryDark.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textTertiaryDark,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSynonymChip(String word, {bool isCanonical = false}) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        widget.onSynonymSelected(word);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isCanonical
              ? widget.moodStep.color.withValues(alpha: 0.2)
              : widget.moodStep.color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: widget.moodStep.color.withValues(alpha: isCanonical ? 0.6 : 0.4),
            width: isCanonical ? 2 : 1,
          ),
        ),
        child: Text(
          word,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isCanonical ? FontWeight.w600 : FontWeight.w500,
            color: widget.moodStep.color,
          ),
        ),
      ),
    );
  }
}

/// Enhanced mood label that supports synonym selection
class InteractiveMoodLabel extends StatefulWidget {
  final double moodScore;
  final Function(String selectedWord)? onWordSelected;

  const InteractiveMoodLabel({
    super.key,
    required this.moodScore,
    this.onWordSelected,
  });

  @override
  State<InteractiveMoodLabel> createState() => _InteractiveMoodLabelState();
}

class _InteractiveMoodLabelState extends State<InteractiveMoodLabel> {
  bool _showingOverlay = false;
  String? _selectedWord;

  @override
  Widget build(BuildContext context) {
    final moodStep = MoodVocabulary.getStepForDouble(widget.moodScore);
    if (moodStep == null) return const SizedBox.shrink();

    final displayWord = _selectedWord ?? moodStep.canonicalLabel;

    return GestureDetector(
      onLongPress: () => _showSynonymOverlay(context, moodStep),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: moodStep.color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: moodStep.color.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              displayWord,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: moodStep.color,
              ),
            ),
            
            const SizedBox(width: 6),
            
            // Indicator that long-press is available
            Icon(
              Icons.keyboard_arrow_down,
              size: 16,
              color: moodStep.color.withValues(alpha: 0.7),
            ),
          ],
        ),
      ),
    );
  }

  void _showSynonymOverlay(BuildContext context, MoodStep moodStep) {
    if (_showingOverlay) return;

    setState(() {
      _showingOverlay = true;
    });

    HapticFeedback.mediumImpact();

    // Get the position of the label
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);

    // Show overlay
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => GestureDetector(
        onTap: () => _dismissOverlay(overlayEntry),
        behavior: HitTestBehavior.translucent,
        child: Container(
          color: Colors.transparent,
          child: Stack(
            children: [
              SynonymSelectionOverlay(
                moodStep: moodStep,
                position: position,
                onSynonymSelected: (synonym) {
                  _selectSynonym(synonym);
                  _dismissOverlay(overlayEntry);
                },
                onDismiss: () => _dismissOverlay(overlayEntry),
              ),
            ],
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);
  }

  void _selectSynonym(String synonym) {
    setState(() {
      _selectedWord = synonym;
    });
    widget.onWordSelected?.call(synonym);
  }

  void _dismissOverlay(OverlayEntry overlayEntry) {
    overlayEntry.remove();
    setState(() {
      _showingOverlay = false;
    });
  }
}

/// Compact mood label for collapsed state
class CompactMoodLabel extends StatelessWidget {
  final double moodScore;
  final bool showNumeric;

  const CompactMoodLabel({
    super.key,
    required this.moodScore,
    this.showNumeric = false,
  });

  @override
  Widget build(BuildContext context) {
    final moodStep = MoodVocabulary.getStepForDouble(moodScore);
    if (moodStep == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: moodStep.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: moodStep.color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Text(
        showNumeric
            ? '${moodStep.canonicalLabel} (${moodScore.round()})'
            : moodStep.canonicalLabel,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: moodStep.color,
        ),
      ),
    );
  }
}
