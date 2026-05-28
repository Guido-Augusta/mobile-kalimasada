// lib/app/utils/image_helper.dart
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../data/constants/app_constants.dart';

class ImageHelper {
  static String getImageUrl(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return AppConstants.defaultProfileImageUrl;
    }

    if (kDebugMode && !kIsWeb) {
      try {
        if (Platform.isAndroid && imageUrl.contains('localhost')) {
          return imageUrl.replaceFirst('localhost', '10.0.2.2');
        }
      } catch (e) {
        if (kDebugMode) {
          print('Gagal mendeteksi platform di ImageHelper: $e');
        }
      }
    }

    return imageUrl;
  }
}
