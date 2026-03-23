import 'package:flutter/material.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_text_styles.dart';

class SearchBarWidget extends StatelessWidget {
  const SearchBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      child: Row(
        children: [
          const SizedBox(width: AppSizes.md),
          Icon(
            Icons.search_rounded,
            color: colorScheme.onSurfaceVariant,
            size: 22,
          ),
          const SizedBox(width: AppSizes.sm),
          Expanded(
            child: Text(
              'Search restaurants, attractions...',
              style: AppTextStyles.body.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Icon(
            Icons.tune_rounded,
            color: colorScheme.onSurfaceVariant,
            size: 20,
          ),
          const SizedBox(width: AppSizes.md),
        ],
      ),
    );
  }
}
