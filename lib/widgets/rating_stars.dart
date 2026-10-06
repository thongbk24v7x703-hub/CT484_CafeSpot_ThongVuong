import 'package:flutter/material.dart';

class RatingStars extends StatelessWidget {
  const RatingStars({
    super.key,
    required this.rating,
    this.size = 18,
    this.onChanged,
  });

  final double rating;
  final double size;
  final ValueChanged<double>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final starIndex = index + 1;
        final icon = rating >= starIndex
            ? Icons.star_rounded
            : rating >= starIndex - 0.5
                ? Icons.star_half_rounded
                : Icons.star_outline_rounded;
        return InkWell(
          onTap: onChanged == null ? null : () => onChanged!(starIndex.toDouble()),
          child: Icon(icon, color: Colors.amber.shade700, size: size),
        );
      }),
    );
  }
}
