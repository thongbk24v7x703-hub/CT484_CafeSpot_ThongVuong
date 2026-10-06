import 'package:flutter/material.dart';

import '../models/cafe.dart';
import 'rating_stars.dart';

class CafeCard extends StatelessWidget {
  const CafeCard({
    super.key,
    required this.cafe,
    required this.onTap,
    this.onFavorite,
    this.compact = false,
  });

  final Cafe cafe;
  final VoidCallback onTap;
  final VoidCallback? onFavorite;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 1,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: compact ? 3 : 4,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    cafe.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: theme.colorScheme.secondaryContainer,
                      child: const Icon(Icons.coffee, size: 48),
                    ),
                  ),
                  if (onFavorite != null)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Material(
                        color: Colors.black45,
                        shape: const CircleBorder(),
                        child: IconButton(
                          icon: Icon(
                            cafe.isFavorite
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: cafe.isFavorite ? Colors.redAccent : Colors.white,
                          ),
                          onPressed: onFavorite,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cafe.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      cafe.address,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall,
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        RatingStars(rating: cafe.rating, size: 16),
                        const SizedBox(width: 6),
                        Text(cafe.rating.toStringAsFixed(1)),
                        const Spacer(),
                        Chip(
                          label: Text(cafe.category),
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                        ),
                      ],
                    ),
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
