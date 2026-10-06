import 'package:flutter/material.dart';

/// Bố cục responsive cơ bản theo chiều rộng màn hình.
class ResponsiveCenter extends StatelessWidget {
  const ResponsiveCenter({
    super.key,
    required this.child,
    this.maxWidth = 900,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final double maxWidth;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final horizontal = width > maxWidth ? (width - maxWidth) / 2 : padding.left;
        return Padding(
          padding: EdgeInsets.fromLTRB(
            horizontal,
            padding.top,
            horizontal,
            padding.bottom,
          ),
          child: child,
        );
      },
    );
  }
}

int gridCountForWidth(double width) {
  if (width >= 1100) return 4;
  if (width >= 750) return 3;
  if (width >= 520) return 2;
  return 1;
}
