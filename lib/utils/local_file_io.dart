import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

bool get supportsLocalFiles => true;

String normalizeFilePath(String value) {
  final v = value.trim();
  if (v.startsWith('file://')) {
    return Uri.parse(v).toFilePath();
  }
  return v;
}

Widget buildLocalFileImage({
  required String path,
  BoxFit fit = BoxFit.cover,
  double? width,
  double? height,
  required Widget Function() fallback,
}) {
  return Image.file(
    File(normalizeFilePath(path)),
    fit: fit,
    width: width,
    height: height,
    errorBuilder: (_, _, _) => fallback(),
  );
}

ImageProvider localFileProvider(String path) =>
    FileImage(File(normalizeFilePath(path)));

Future<String> persistPickedImage(String sourcePath) async {
  final docs = await getApplicationDocumentsDirectory();
  final cafeImages = Directory(p.join(docs.path, 'cafe_images'));
  if (!await cafeImages.exists()) {
    await cafeImages.create(recursive: true);
  }
  final ext = p.extension(sourcePath).isEmpty ? '.jpg' : p.extension(sourcePath);
  final destPath = p.join(cafeImages.path, '${const Uuid().v4()}$ext');
  await File(sourcePath).copy(destPath);
  return destPath;
}
