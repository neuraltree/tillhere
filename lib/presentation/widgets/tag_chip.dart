import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/entities/mood_entry.dart';
import '../../core/theme/app_colors.dart';
import '../providers/mood_capture_provider.dart';

/// Reusable tag chip widget for displaying and selecting mood categories
/// Follows Apple design standards with proper styling and animations
class TagChip extends StatelessWidget {
  final Tag tag;
  final bool isSelected;
  final VoidCallback? onTap;
  final bool showRemoveButton;

  const TagChip({
    super.key,
    required this.tag,
    this.isSelected = false,
    this.onTap,
    this.showRemoveButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.neonGreen.withOpacity(0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppColors.neonGreen
                : AppColors.borderDark.withOpacity(0.5),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              tag.name,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isSelected
                    ? AppColors.neonGreen
                    : (Theme.of(context).brightness == Brightness.dark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight),
              ),
            ),
            if (showRemoveButton) ...[
              const SizedBox(width: 4),
              Icon(
                Icons.close,
                size: 16,
                color: isSelected
                    ? AppColors.neonGreen
                    : AppColors.textSecondaryDark,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Tag chip that integrates with MoodCaptureProvider
class MoodTagChip extends StatelessWidget {
  final Tag tag;
  final bool showRemoveButton;

  const MoodTagChip({
    super.key,
    required this.tag,
    this.showRemoveButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<MoodCaptureProvider>(
      builder: (context, provider, child) {
        final isSelected = provider.isTagSelected(tag);
        
        return TagChip(
          tag: tag,
          isSelected: isSelected,
          showRemoveButton: showRemoveButton && isSelected,
          onTap: () => provider.toggleTag(tag),
        );
      },
    );
  }
}

/// Add new tag chip button
class AddTagChip extends StatefulWidget {
  final VoidCallback? onPressed;

  const AddTagChip({
    super.key,
    this.onPressed,
  });

  @override
  State<AddTagChip> createState() => _AddTagChipState();
}

class _AddTagChipState extends State<AddTagChip> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: _isPressed
              ? AppColors.neonGreen.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.neonGreen.withOpacity(0.7),
            width: 1,
            style: BorderStyle.solid,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.add,
              size: 16,
              color: AppColors.neonGreen,
            ),
            const SizedBox(width: 4),
            Text(
              'Add Tag',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.neonGreen,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tag input widget for creating new tags
class TagInputWidget extends StatefulWidget {
  final Function(String) onTagCreated;
  final VoidCallback? onCancel;

  const TagInputWidget({
    super.key,
    required this.onTagCreated,
    this.onCancel,
  });

  @override
  State<TagInputWidget> createState() => _TagInputWidgetState();
}

class _TagInputWidgetState extends State<TagInputWidget> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();
    
    // Auto-focus when widget is created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submitTag() {
    final tagName = _controller.text.trim();
    if (tagName.isNotEmpty) {
      widget.onTagCreated(tagName);
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.backgroundSecondaryDark
            : AppColors.backgroundSecondaryLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.neonGreen.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 80,
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submitTag(),
              decoration: InputDecoration(
                hintText: 'Tag name',
                hintStyle: TextStyle(
                  fontSize: 14,
                  color: AppColors.textTertiaryDark,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: _submitTag,
            child: Icon(
              Icons.check,
              size: 16,
              color: AppColors.neonGreen,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: widget.onCancel,
            child: Icon(
              Icons.close,
              size: 16,
              color: AppColors.textSecondaryDark,
            ),
          ),
        ],
      ),
    );
  }
}

/// Tag selection row with common tags and add button
class TagSelectionRow extends StatefulWidget {
  final List<Tag> commonTags;

  const TagSelectionRow({
    super.key,
    this.commonTags = const [],
  });

  @override
  State<TagSelectionRow> createState() => _TagSelectionRowState();
}

class _TagSelectionRowState extends State<TagSelectionRow> {
  bool _showingInput = false;

  // Default common tags
  static const List<Tag> _defaultCommonTags = [
    Tag(id: 'happy', name: 'Happy'),
    Tag(id: 'sad', name: 'Sad'),
    Tag(id: 'anxious', name: 'Anxious'),
    Tag(id: 'excited', name: 'Excited'),
    Tag(id: 'tired', name: 'Tired'),
    Tag(id: 'work', name: 'Work'),
    Tag(id: 'family', name: 'Family'),
    Tag(id: 'health', name: 'Health'),
  ];

  List<Tag> get _tagsToShow => widget.commonTags.isNotEmpty 
      ? widget.commonTags 
      : _defaultCommonTags;

  void _createNewTag(String tagName) {
    final provider = context.read<MoodCaptureProvider>();
    final newTag = Tag(
      id: 'tag_${DateTime.now().millisecondsSinceEpoch}',
      name: tagName,
    );
    provider.addTag(newTag);
    setState(() {
      _showingInput = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '🏷️ Tags',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimaryLight,
          ),
        ),
        
        const SizedBox(height: 8),
        
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            // Common tags
            ..._tagsToShow.map((tag) => MoodTagChip(
              tag: tag,
              showRemoveButton: true,
            )),
            
            // Add tag button or input
            if (_showingInput)
              TagInputWidget(
                onTagCreated: _createNewTag,
                onCancel: () => setState(() => _showingInput = false),
              )
            else
              AddTagChip(
                onPressed: () => setState(() => _showingInput = true),
              ),
          ],
        ),
      ],
    );
  }
}

/// Selected tags display (read-only)
class SelectedTagsDisplay extends StatelessWidget {
  final List<Tag> tags;
  final Function(Tag)? onTagRemoved;

  const SelectedTagsDisplay({
    super.key,
    required this.tags,
    this.onTagRemoved,
  });

  @override
  Widget build(BuildContext context) {
    if (tags.isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: tags.map((tag) => TagChip(
        tag: tag,
        isSelected: true,
        showRemoveButton: onTagRemoved != null,
        onTap: onTagRemoved != null ? () => onTagRemoved!(tag) : null,
      )).toList(),
    );
  }
}
