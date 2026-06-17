import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:video_compress/video_compress.dart';

class MediaCompressor {
  MediaCompressor._();

  static const _imageExtensions = ['.jpg', '.jpeg', '.png', '.webp'];
  static const _videoExtensions = ['.mp4', '.mov', '.m4v', '.avi', '.mkv'];

  static bool isImage(String path) {
    final lower = path.toLowerCase();
    return _imageExtensions.any(lower.endsWith);
  }

  static bool isVideo(String path) {
    final lower = path.toLowerCase();
    return _videoExtensions.any(lower.endsWith);
  }

  static Future<String> compressMedia(String path) async {
    if (isImage(path)) return compressImage(path);
    if (isVideo(path)) return compressVideo(path);
    return path;
  }

  static Future<String> compressImage(String path) async {
    try {
      final source = File(path);
      if (!await source.exists()) return path;

      final lower = path.toLowerCase();
      final format = lower.endsWith('.png')
          ? CompressFormat.png
          : lower.endsWith('.webp')
              ? CompressFormat.webp
              : CompressFormat.jpeg;
      final extension = format == CompressFormat.png
          ? 'png'
          : format == CompressFormat.webp
              ? 'webp'
              : 'jpg';

      final targetPath = '${Directory.systemTemp.path}/madraj_img_${DateTime.now().microsecondsSinceEpoch}.$extension';

      final result = await FlutterImageCompress.compressAndGetFile(
        source.absolute.path,
        targetPath,
        quality: 72,
        minWidth: 1600,
        minHeight: 1600,
        format: format,
        keepExif: false,
      );

      if (result == null) return path;

      final compressed = File(result.path);
      if (!await compressed.exists()) return path;

      final originalSize = await source.length();
      final compressedSize = await compressed.length();

      return compressedSize > 0 && compressedSize < originalSize ? compressed.path : path;
    } catch (e) {
      debugPrint('IMAGE COMPRESSION ERROR = $e');
      return path;
    }
  }

  static Future<String> compressVideo(String path) async {
    try {
      final source = File(path);
      if (!await source.exists()) return path;

      final info = await VideoCompress.compressVideo(
        path,
        quality: VideoQuality.MediumQuality,
        deleteOrigin: false,
        includeAudio: true,
      );

      final compressedPath = info?.path;
      if (compressedPath == null || compressedPath.isEmpty) return path;

      final compressed = File(compressedPath);
      if (!await compressed.exists()) return path;

      final originalSize = await source.length();
      final compressedSize = await compressed.length();

      return compressedSize > 0 && compressedSize < originalSize ? compressed.path : path;
    } catch (e) {
      debugPrint('VIDEO COMPRESSION ERROR = $e');
      return path;
    }
  }

  static Future<void> clearTempVideos() async {
    try {
      await VideoCompress.deleteAllCache();
    } catch (_) {}
  }
}
