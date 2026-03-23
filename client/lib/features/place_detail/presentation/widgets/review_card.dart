import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/providers/translation_provider.dart';
import '../../../../shared/widgets/review_source_badge.dart';
import '../../../../shared/widgets/star_rating.dart';

class ReviewCard extends ConsumerStatefulWidget {
  const ReviewCard({
    super.key,
    required this.reviewId,
    required this.source,
    required this.authorName,
    required this.rating,
    required this.date,
    required this.content,
    this.nationality,
    this.likes = 0,
    this.comments = 0,
    this.hasPhotos = false,
    this.translatedContent,
    this.targetLanguage = 'en',
  });

  final String reviewId;
  final ReviewSourceType source;
  final String authorName;
  final double rating;
  final String date;
  final String content;
  final String? nationality;
  final int likes;
  final int comments;
  final bool hasPhotos;
  final String? translatedContent;
  final String targetLanguage;

  @override
  ConsumerState<ReviewCard> createState() => _ReviewCardState();
}

class _ReviewCardState extends ConsumerState<ReviewCard> {
  bool _showingTranslation = false;
  bool _isTranslating = false;
  String? _translatedText;

  @override
  void initState() {
    super.initState();
    _translatedText = widget.translatedContent;
  }

  Future<void> _onTranslateTap() async {
    // Already have translation → just toggle
    if (_translatedText != null) {
      setState(() => _showingTranslation = !_showingTranslation);
      return;
    }

    // Fetch translation via service (DB cache → Azure API → DB save)
    setState(() {
      _isTranslating = true;
      _showingTranslation = true;
    });

    try {
      final service = ref.read(translationServiceProvider);
      final translated = await service.translateReview(
        reviewId: widget.reviewId,
        content: widget.content,
        targetLanguage: widget.targetLanguage,
      );

      if (mounted) {
        setState(() {
          _translatedText = translated;
          _isTranslating = false;
          if (translated == null) _showingTranslation = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isTranslating = false;
          _showingTranslation = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.md),
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Badge + Author + Date
          Row(
            children: [
              ReviewSourceBadge(type: widget.source),
              const SizedBox(width: AppSizes.sm),
              Expanded(
                child: Row(
                  children: [
                    Text(widget.authorName, style: AppTextStyles.label),
                    if (widget.nationality != null) ...[
                      const SizedBox(width: AppSizes.xs),
                      Text(widget.nationality!,
                          style: const TextStyle(fontSize: 14)),
                    ],
                  ],
                ),
              ),
              Text(
                widget.date,
                style: AppTextStyles.caption.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.sm),

          // Star Rating
          StarRating(rating: widget.rating, size: 14),
          const SizedBox(height: AppSizes.sm),

          // Content
          Text(
            _showingTranslation && _translatedText != null
                ? _translatedText!
                : widget.content,
            style: AppTextStyles.body,
          ),

          // Loading indicator
          if (_isTranslating) ...[
            const SizedBox(height: AppSizes.sm),
            Row(
              children: [
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(width: AppSizes.xs),
                Text(
                  'Translating...',
                  style: AppTextStyles.caption.copyWith(
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
          ],

          // Photo placeholder
          if (widget.hasPhotos) ...[
            const SizedBox(height: AppSizes.sm),
            SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 2,
                itemBuilder: (_, i) => Container(
                  width: 80,
                  height: 80,
                  margin: const EdgeInsets.only(right: AppSizes.sm),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                  ),
                  child: Icon(
                    Icons.photo_rounded,
                    color:
                        colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                  ),
                ),
              ),
            ),
          ],

          const SizedBox(height: AppSizes.sm),

          // Bottom: Likes + Comments + Translate
          Row(
            children: [
              Icon(Icons.thumb_up_outlined,
                  size: 16, color: colorScheme.onSurfaceVariant),
              const SizedBox(width: AppSizes.xs),
              Text(
                '${widget.likes}',
                style: AppTextStyles.caption.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: AppSizes.md),
              Icon(Icons.chat_bubble_outline_rounded,
                  size: 16, color: colorScheme.onSurfaceVariant),
              const SizedBox(width: AppSizes.xs),
              Text(
                '${widget.comments}',
                style: AppTextStyles.caption.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: _isTranslating ? null : _onTranslateTap,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.translate_rounded,
                      size: 16,
                      color: _showingTranslation
                          ? colorScheme.primary
                          : colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: AppSizes.xs),
                    Text(
                      _showingTranslation && _translatedText != null
                          ? 'Original'
                          : 'Translate',
                      style: AppTextStyles.caption.copyWith(
                        color: _showingTranslation
                            ? colorScheme.primary
                            : colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
