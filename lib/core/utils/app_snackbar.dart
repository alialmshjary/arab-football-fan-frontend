import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppSnackbar {
  AppSnackbar._();

  static DateTime? _lastNetworkErrorAt;
  static const Duration _networkErrorGap = Duration(seconds: 5);

  static bool get _canShowNetworkError {
    final now = DateTime.now();
    final last = _lastNetworkErrorAt;

    if (last != null && now.difference(last) < _networkErrorGap) {
      return false;
    }

    _lastNetworkErrorAt = now;
    return true;
  }

  static bool isNetworkMessage(String message) {
    final text = message.toLowerCase();
    return text.contains('internet') ||
        text.contains('network') ||
        text.contains('socket') ||
        text.contains('connection') ||
        text.contains('timed out') ||
        text.contains('timeout') ||
        text.contains('الاتصال') ||
        text.contains('الإنترنت') ||
        text.contains('انترنت') ||
        text.contains('مهلة') ||
        text.contains('الخادم');
  }

  static String cleanError(Object error) {
    var message = error.toString();
    message = message
        .replaceFirst('Exception: ', '')
        .replaceFirst('ApiException: ', '')
        .replaceAll('SocketException:', '')
        .replaceAll('ClientException:', '')
        .trim();

    if (isNetworkMessage(message)) {
      return 'تعذر الاتصال بالإنترنت. تحقق من الشبكة وحاول مرة أخرى.';
    }

    if (message.isEmpty) {
      return 'حدث خطأ غير متوقع. حاول مرة أخرى.';
    }

    return message;
  }

  static void show(String title, String message) {
    final cleanMessage = cleanError(message);

    if (isNetworkMessage(cleanMessage) && !_canShowNetworkError) {
      return;
    }

    Get.snackbar(
      title,
      cleanMessage,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 14,
      backgroundColor: Colors.black87,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }
}
