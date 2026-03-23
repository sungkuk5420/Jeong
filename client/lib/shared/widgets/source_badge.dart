import 'package:flutter/material.dart';

import '../../core/constants/app_sizes.dart';

enum SourceType { official, community }

class SourceBadge extends StatelessWidget {
  const SourceBadge({super.key, required this.type});

  final SourceType type;

  @override
  Widget build(BuildContext context) {
    final isOfficial = type == SourceType.official;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: isOfficial
            ? colorScheme.primaryContainer
            : colorScheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isOfficial ? Icons.verified_rounded : Icons.people_rounded,
            size: 12,
            color: isOfficial
                ? colorScheme.onPrimaryContainer
                : colorScheme.onTertiaryContainer,
          ),
          const SizedBox(width: 3),
          Text(
            isOfficial ? 'Official' : 'Community',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isOfficial
                  ? colorScheme.onPrimaryContainer
                  : colorScheme.onTertiaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}
