import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/models/place.dart';
import '../../../../core/models/review.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/providers/place_provider.dart';
import '../../../../core/providers/review_provider.dart';
import '../../../../shared/widgets/review_source_badge.dart';
import '../../../../shared/widgets/source_badge.dart';
import '../../../../shared/widgets/star_rating.dart';
import '../widgets/review_card.dart';

class PlaceDetailPage extends ConsumerWidget {
  const PlaceDetailPage({super.key, required this.placeId});

  final String placeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final placeAsync = ref.watch(placeByIdProvider(placeId));
    final user = ref.watch(authProvider);

    return placeAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('Error: $e')),
      ),
      data: (place) {
        if (place == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Place not found')),
          );
    }

    final isBookmarked = user.bookmarkedPlaceIds.contains(placeId);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Hero Image + AppBar
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: colorScheme.surfaceContainerHighest,
                child: Icon(
                  Icons.restaurant_rounded,
                  size: 64,
                  color:
                      colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  isBookmarked
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
                  color: isBookmarked ? colorScheme.primary : null,
                ),
                onPressed: () {
                  if (user.isGuest) {
                    _showLoginPrompt(context, ref);
                  } else {
                    ref.read(authProvider.notifier).toggleBookmark(placeId);
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.share_rounded),
                onPressed: () {},
              ),
            ],
          ),

          // Place Info
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name + Badge
                  Row(
                    children: [
                      Expanded(
                        child: Text(place.name,
                            style: AppTextStyles.heading2),
                      ),
                      SourceBadge(type: place.sourceType),
                    ],
                  ),
                  const SizedBox(height: AppSizes.sm),

                  // Tags
                  if (place.tags.isNotEmpty) ...[
                    Wrap(
                      spacing: AppSizes.xs,
                      children: place.tags
                          .map((tag) => Chip(
                                label: Text(tag,
                                    style: AppTextStyles.caption),
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                visualDensity: VisualDensity.compact,
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: AppSizes.sm),
                  ],

                  // Dual Rating
                  _DualRating(place: place),

                  const SizedBox(height: AppSizes.md),

                  // Quick Info
                  if (place.address != null)
                    _InfoRow(
                      icon: Icons.location_on_rounded,
                      text: place.address!,
                    ),
                  if (place.openingHours != null) ...[
                    const SizedBox(height: AppSizes.sm),
                    _InfoRow(
                      icon: Icons.access_time_rounded,
                      text: place.openingHours!,
                      textColor: const Color(0xFF4CAF50),
                    ),
                  ],
                  if (place.phone != null) ...[
                    const SizedBox(height: AppSizes.sm),
                    _InfoRow(
                      icon: Icons.phone_rounded,
                      text: place.phone!,
                    ),
                  ],
                  const SizedBox(height: AppSizes.md),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.navigation_rounded,
                              size: 18),
                          label: const Text('Directions'),
                        ),
                      ),
                      if (place.phone != null) ...[
                        const SizedBox(width: AppSizes.sm),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {},
                            icon:
                                const Icon(Icons.phone_rounded, size: 18),
                            label: const Text('Call'),
                          ),
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: AppSizes.md),

                  // Foreigner Tips
                  if (place.tips.isNotEmpty)
                    _ForeignerTips(tips: place.tips),

                  const SizedBox(height: AppSizes.lg),
                  Divider(color: colorScheme.outlineVariant),
                ],
              ),
            ),
          ),

          // Reviews Section
          SliverToBoxAdapter(
            child: _ReviewSection(placeId: placeId),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: AppSizes.xxl)),
        ],
      ),

      // Write Review FAB
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (user.isGuest) {
            _showLoginPrompt(context, ref);
          } else {
            _showWriteReviewSheet(context);
          }
        },
        icon: const Icon(Icons.rate_review_rounded),
        label: const Text('Write Review'),
      ),
    );
      },
    );
  }

  void _showWriteReviewSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.radiusLg),
        ),
      ),
      builder: (_) => _WriteReviewSheet(placeId: placeId),
    );
  }

  void _showLoginPrompt(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.radiusLg),
        ),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppSizes.lg),
            Icon(
              Icons.rate_review_rounded,
              size: 48,
              color: colorScheme.primary,
            ),
            const SizedBox(height: AppSizes.md),
            Text(
              'Sign in to continue',
              style: AppTextStyles.heading3,
            ),
            const SizedBox(height: AppSizes.xs),
            Text(
              'Share your experience with other travelers',
              style: AppTextStyles.body.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSizes.lg),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton.icon(
                onPressed: () {
                  ref.read(authProvider.notifier).signInWithGoogle();
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.g_mobiledata_rounded),
                label: const Text('Continue with Google'),
              ),
            ),
            const SizedBox(height: AppSizes.sm),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton.icon(
                onPressed: () {
                  ref.read(authProvider.notifier).signInWithApple();
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.apple_rounded),
                label: const Text('Continue with Apple'),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: AppSizes.md),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Maybe later'),
            ),
            const SizedBox(height: AppSizes.sm),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────
// Dual Rating Widget
// ──────────────────────────────────────────
class _DualRating extends StatelessWidget {
  const _DualRating({required this.place});
  final Place place;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          // Combined
          Row(
            children: [
              Text(
                place.rating.toStringAsFixed(1),
                style: AppTextStyles.heading1.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(width: AppSizes.sm),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StarRating(rating: place.rating),
                  const SizedBox(height: 2),
                  Text(
                    '${place.reviewCount} reviews',
                    style: AppTextStyles.caption.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSizes.sm),
          Divider(
              color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
          const SizedBox(height: AppSizes.sm),
          // Split ratings
          Row(
            children: [
              Expanded(
                child: _RatingRow(
                  badge: const ReviewSourceBadge(
                      type: ReviewSourceType.jeong),
                  rating: place.jeongRating ?? place.rating,
                  count: place.jeongReviewCount,
                ),
              ),
              Container(
                width: 1,
                height: 30,
                color:
                    colorScheme.outlineVariant.withValues(alpha: 0.5),
              ),
              Expanded(
                child: _RatingRow(
                  badge: const ReviewSourceBadge(
                      type: ReviewSourceType.naver),
                  rating: place.externalRating ?? place.rating,
                  count: place.externalReviewCount,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RatingRow extends StatelessWidget {
  const _RatingRow({
    required this.badge,
    required this.rating,
    required this.count,
  });

  final Widget badge;
  final double rating;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        badge,
        const SizedBox(height: AppSizes.xs),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.star_rounded, size: 16, color: Colors.amber),
            const SizedBox(width: 2),
            Text(
              rating.toStringAsFixed(1),
              style: AppTextStyles.subtitle,
            ),
            Text(
              ' ($count)',
              style: AppTextStyles.caption.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ──────────────────────────────────────────
// Info Row
// ──────────────────────────────────────────
class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.text,
    this.textColor,
  });

  final IconData icon;
  final String text;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(icon, size: 18, color: colorScheme.onSurfaceVariant),
        const SizedBox(width: AppSizes.sm),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.body.copyWith(
              color: textColor ?? colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}

// ──────────────────────────────────────────
// Foreigner Tips
// ──────────────────────────────────────────
class _ForeignerTips extends StatelessWidget {
  const _ForeignerTips({required this.tips});
  final List<ForeignerTip> tips;

  IconData _getIcon(String iconName) {
    return switch (iconName) {
      'menu_book' => Icons.menu_book_rounded,
      'credit_card' => Icons.credit_card_rounded,
      'translate' => Icons.translate_rounded,
      'schedule' => Icons.schedule_rounded,
      'volume_off' => Icons.volume_off_rounded,
      'photo_camera' => Icons.photo_camera_rounded,
      'directions_walk' => Icons.directions_walk_rounded,
      'directions_bus' => Icons.directions_bus_rounded,
      'local_fire_department' => Icons.local_fire_department_rounded,
      _ => Icons.info_outline_rounded,
    };
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: colorScheme.tertiaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.tips_and_updates_rounded,
                size: 18,
                color: colorScheme.onTertiaryContainer,
              ),
              const SizedBox(width: AppSizes.sm),
              Text(
                'Tips for Visitors',
                style: AppTextStyles.label.copyWith(
                  color: colorScheme.onTertiaryContainer,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.sm),
          ...tips.map((tip) => Padding(
                padding: const EdgeInsets.only(bottom: AppSizes.xs),
                child: Row(
                  children: [
                    Icon(
                      _getIcon(tip.icon),
                      size: 14,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: AppSizes.sm),
                    Expanded(
                      child: Text(tip.text, style: AppTextStyles.bodySmall),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────
// Review Section with 3 Tabs
// ──────────────────────────────────────────
class _ReviewSection extends ConsumerStatefulWidget {
  const _ReviewSection({required this.placeId});
  final String placeId;

  @override
  ConsumerState<_ReviewSection> createState() => _ReviewSectionState();
}

class _ReviewSectionState extends ConsumerState<_ReviewSection>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final allReviewsAsync = ref.watch(reviewsForPlaceProvider(widget.placeId));
    final jeongReviewsAsync = ref.watch(jeongReviewsProvider(widget.placeId));
    final externalReviewsAsync =
        ref.watch(externalReviewsProvider(widget.placeId));

    final allReviews = allReviewsAsync.valueOrNull ?? [];
    final jeongReviews = jeongReviewsAsync.valueOrNull ?? [];
    final externalReviews = externalReviewsAsync.valueOrNull ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
          child: Text('Reviews', style: AppTextStyles.heading3),
        ),
        const SizedBox(height: AppSizes.sm),

        TabBar(
          controller: _tabController,
          labelColor: colorScheme.primary,
          unselectedLabelColor: colorScheme.onSurfaceVariant,
          indicatorColor: colorScheme.primary,
          tabs: [
            Tab(text: 'All (${allReviews.length})'),
            Tab(text: 'Jeong (${jeongReviews.length})'),
            Tab(text: 'External (${externalReviews.length})'),
          ],
        ),

        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSizes.md,
            AppSizes.sm,
            AppSizes.md,
            0,
          ),
          child: Row(
            children: [
              _FilterChip(label: 'Latest', isSelected: true),
              const SizedBox(width: AppSizes.sm),
              _FilterChip(label: 'Highest'),
              const SizedBox(width: AppSizes.sm),
              _FilterChip(label: 'Most Helpful'),
              const Spacer(),
              Icon(
                Icons.language_rounded,
                size: 20,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: AppSizes.xs),
              Text(
                'All',
                style: AppTextStyles.label.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSizes.sm),

        SizedBox(
          height: _calculateHeight(allReviews),
          child: TabBarView(
            controller: _tabController,
            children: [
              _ReviewList(reviews: allReviews),
              _ReviewList(reviews: jeongReviews),
              _ReviewList(reviews: externalReviews),
            ],
          ),
        ),
      ],
    );
  }

  double _calculateHeight(List<Review> reviews) {
    if (reviews.isEmpty) return 200;
    return (reviews.length * 200.0).clamp(200, 800);
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, this.isSelected = false});
  final String label;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected
            ? colorScheme.primaryContainer
            : Colors.transparent,
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
        border: isSelected
            ? null
            : Border.all(color: colorScheme.outlineVariant),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: isSelected
              ? colorScheme.onPrimaryContainer
              : colorScheme.onSurfaceVariant,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }
}

class _ReviewList extends StatelessWidget {
  const _ReviewList({required this.reviews});
  final List<Review> reviews;

  @override
  Widget build(BuildContext context) {
    if (reviews.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.rate_review_outlined,
              size: 48,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: AppSizes.md),
            Text(
              'No reviews yet',
              style: AppTextStyles.body.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
      itemCount: reviews.length,
      itemBuilder: (context, index) {
        final review = reviews[index];
        return ReviewCard(
          reviewId: review.id,
          source: review.source,
          authorName: review.authorName,
          nationality: review.nationality,
          rating: review.rating,
          date: review.date,
          content: review.content,
          likes: review.likes,
          comments: review.comments,
          hasPhotos: review.hasPhotos,
          translatedContent: review.translatedContent,
        );
      },
    );
  }
}

class _WriteReviewSheet extends StatefulWidget {
  const _WriteReviewSheet({required this.placeId});
  final String placeId;

  @override
  State<_WriteReviewSheet> createState() => _WriteReviewSheetState();
}

class _WriteReviewSheetState extends State<_WriteReviewSheet> {
  int _rating = 0;
  final _contentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  bool get _canSubmit => _rating > 0 && _contentController.text.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSizes.lg,
        AppSizes.lg,
        AppSizes.lg,
        MediaQuery.of(context).viewInsets.bottom + AppSizes.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppSizes.lg),
          Text('Write a Review', style: AppTextStyles.heading3),
          const SizedBox(height: AppSizes.md),
          Text('Rating', style: AppTextStyles.label),
          const SizedBox(height: AppSizes.sm),
          Row(
            children: List.generate(
              5,
              (i) => IconButton(
                icon: Icon(
                  i < _rating ? Icons.star_rounded : Icons.star_outline_rounded,
                  color: i < _rating ? Colors.amber : colorScheme.outlineVariant,
                  size: 32,
                ),
                onPressed: () => setState(() => _rating = i + 1),
              ),
            ),
          ),
          const SizedBox(height: AppSizes.md),
          TextField(
            controller: _contentController,
            maxLines: 4,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Share your experience with other travelers...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
            ),
          ),
          const SizedBox(height: AppSizes.md),
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.photo_camera_rounded, size: 18),
                label: const Text('Add Photos'),
              ),
              const Spacer(),
              FilledButton(
                onPressed: _canSubmit && !_isSubmitting
                    ? () async {
                        setState(() => _isSubmitting = true);
                        // TODO: call reviewRepo.createReview when Supabase connected
                        Navigator.pop(context);
                      }
                    : null,
                child: _isSubmitting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Submit'),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.sm),
        ],
      ),
    );
  }
}
