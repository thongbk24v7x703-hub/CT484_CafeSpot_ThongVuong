import 'package:flutter/material.dart';

bool get supportsLocalFiles => false;

String normalizeFilePath(String value) => value.trim();

Widget buildLocalFileImage({
  required String path,
  BoxFit fit = BoxFit.cover,
  double? width,
  double? height,
  required Widget Function() fallback,
}) {
  return fallback();
}

ImageProvider? localFileProvider(String path) => null;

Future<String> persistPickedImage(String sourcePath) async {
  throw UnsupportedError('Chọn ảnh từ file chưa hỗ trợ trên web. Hãy dùng link https://...');
}
