import 'package:flutter/material.dart';

import '../../core/constants/app_sizes.dart';

enum ReviewSourceType { jeong, naver, google }

class ReviewSourceBadge extends StatelessWidget {
  const ReviewSourceBadge({super.key, required this.type});

  final ReviewSourceType type;

  Color _backgroundColor(ColorScheme colorScheme) {
    return switch (type) {
      ReviewSourceType.jeong => colorScheme.primaryContainer,
      ReviewSourceType.naver => const Color(0xFFE8F5E9),
      ReviewSourceType.google => const Color(0xFFFFF3E0),
    };
  }

  Color _foregroundColor(ColorScheme colorScheme) {
    return switch (type) {
      ReviewSourceType.jeong => colorScheme.onPrimaryContainer,
      ReviewSourceType.naver => const Color(0xFF2E7D32),
      ReviewSourceType.google => const Color(0xFFE65100),
    };
  }

  IconData get _icon {
    return switch (type) {
      ReviewSourceType.jeong => Icons.chat_bubble_rounded,
      ReviewSourceType.naver => Icons.link_rounded,
      ReviewSourceType.google => Icons.link_rounded,
    };
  }

  String get _label {
    return switch (type) {
      ReviewSourceType.jeong => 'Jeong',
      ReviewSourceType.naver => 'Naver',
      ReviewSourceType.google => 'Google',
    };
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bg = _backgroundColor(colorScheme);
    final fg = _foregroundColor(colorScheme);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, size: 11, color: fg),
          const SizedBox(width: 3),
          Text(
            _label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}
