import 'package:flutter/material.dart';

import '../utils/local_file.dart';

/// Ảnh quán: hỗ trợ asset nội bộ, URL mạng, hoặc file trên máy.
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

  static bool isNetwork(String value) {
    final v = value.trim().toLowerCase();
    return v.startsWith('http://') || v.startsWith('https://');
  }

  static bool isFile(String value) {
    final v = value.trim();
    if (v.isEmpty || isAsset(v) || isNetwork(v)) return false;
    if (v.startsWith('file:')) return true;
    if (v.startsWith('/')) return true;
    return RegExp(r'^[a-zA-Z]:[\\/]').hasMatch(v);
  }

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
        errorBuilder: (_, _, _) => fallback(),
      );
    }

    if (isFile(source)) {
      return buildLocalFileImage(
        path: source,
        fit: fit,
        width: width,
        height: height,
        fallback: fallback,
      );
    }

    return Image.network(
      source,
      fit: fit,
      width: width,
      height: height,
      errorBuilder: (_, _, _) => fallback(),
    );
  }

  static ImageProvider? providerOf(String source) {
    if (source.trim().isEmpty) return null;
    if (isAsset(source)) return AssetImage(normalizeAsset(source));
    if (isFile(source)) return localFileProvider(source);
    return NetworkImage(source);
  }
}
