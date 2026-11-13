import 'package:flutter/material.dart';

/// Ảnh quán: hỗ trợ asset nội bộ (`assets/...`) hoặc URL mạng.
class CafeImage extends StatelessWidget {
  const CafeImage({
    super.key,
    required this.source,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.errorIconSize = 48,
  });

  final String source;
  final BoxFit fit;
  final double? width;
  final double? height;
  final double errorIconSize;

  static bool isAsset(String value) =>
      value.startsWith('assets/') || value.startsWith('asset:');

  static String normalizeAsset(String value) =>
      value.startsWith('asset:') ? value.substring(6) : value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Widget fallback() => Container(
          width: width,
          height: height,
          color: theme.colorScheme.secondaryContainer,
          alignment: Alignment.center,
          child: Icon(Icons.coffee, size: errorIconSize),
        );

    if (source.trim().isEmpty) return fallback();

    if (isAsset(source)) {
      return Image.asset(
        normalizeAsset(source),
        fit: fit,
        width: width,
        height: height,
        errorBuilder: (_, __, ___) => fallback(),
      );
    }

    return Image.network(
      source,
      fit: fit,
      width: width,
      height: height,
      errorBuilder: (_, __, ___) => fallback(),
    );
  }

  static ImageProvider? providerOf(String source) {
    if (source.trim().isEmpty) return null;
    if (isAsset(source)) return AssetImage(normalizeAsset(source));
    return NetworkImage(source);
  }
}
