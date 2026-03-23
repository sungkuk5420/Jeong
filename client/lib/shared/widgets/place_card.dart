import 'package:flutter/material.dart';

import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_text_styles.dart';
import 'source_badge.dart';
import 'star_rating.dart';

class PlaceCard extends StatelessWidget {
  const PlaceCard({
    super.key,
    required this.name,
    required this.category,
    required this.district,
    required this.rating,
    required this.reviewCount,
    required this.sourceType,
    this.imageUrl,
    this.distance,
    this.description,
    this.registeredBy,
    this.onTap,
  });

  final String name;
  final String category;
  final String district;
  final double rating;
  final int reviewCount;
  final SourceType sourceType;
  final String? imageUrl;
  final String? distance;
  final String? description;
  final String? registeredBy;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppSizes.md,
          vertical: AppSizes.xs,
        ),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppSizes.radiusMd),
                bottomLeft: Radius.circular(AppSizes.radiusMd),
              ),
              child: Container(
                width: AppSizes.cardImageWidth,
                height: AppSizes.cardHeight,
                color: colorScheme.surfaceContainerHighest,
                child: Icon(
                  Icons.restaurant_rounded,
                  color: colorScheme.onSurfaceVariant,
                  size: 32,
                ),
              ),
            ),
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.sm + 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Name + Badge
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: AppTextStyles.subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: AppSizes.xs),
                        SourceBadge(type: sourceType),
                      ],
                    ),
                    const SizedBox(height: AppSizes.xs),
                    // Rating
                    Row(
                      children: [
                        StarRating(rating: rating, size: 14),
                        const SizedBox(width: AppSizes.xs),
                        Text(
                          '$rating ($reviewCount)',
                          style: AppTextStyles.caption.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSizes.xs),
                    // Category · District · Distance
                    Text(
                      [category, district, if (distance != null) distance]
                          .join(' · '),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (description != null) ...[
                      const SizedBox(height: AppSizes.xs),
                      Text(
                        '"$description"',
                        style: AppTextStyles.caption.copyWith(
                          fontStyle: FontStyle.italic,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
