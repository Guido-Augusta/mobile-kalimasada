// lib/app/utils/image_helper.dart
import 'dart:io';
import 'package:flutter/foundation.dart';

class AudioHelper {
  static String getAudioUrl(String? audioUrl) {
    if (audioUrl == null || audioUrl.isEmpty) {
      return "";
    }

    if (kDebugMode && !kIsWeb) {
      try {
        if (Platform.isAndroid) {
          String url = audioUrl;
          if (url.contains('localhost')) {
            url = url.replaceAll('localhost', '10.0.2.2');
          }
          if (url.contains('127.0.0.1')) {
            url = url.replaceAll('127.0.0.1', '10.0.2.2');
          }
          return url;
        }
      } catch (e) {
        if (kDebugMode) {
          print('Gagal mendeteksi platform di AudioHelper: $e');
        }
      }
    }

    return audioUrl;
  }
}
