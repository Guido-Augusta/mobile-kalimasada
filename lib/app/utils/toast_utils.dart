import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toastification/toastification.dart';

class ToastUtils {
  // Success toast
  static void showSuccessToast(
    String message, {
    Duration duration = const Duration(milliseconds: 2000),
    Alignment alignment = Alignment.bottomCenter,
  }) {
    toastification.show(
      context: Get.context!,
      title: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Icon(Icons.check_circle_outline_rounded, color: Colors.green),
          SizedBox(width: 10),
          Text(message, style: TextStyle(color: Colors.white)),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      icon: Icon(Icons.check_circle_outline_rounded, color: Colors.green),
      showIcon: true,
      backgroundColor: Color(0xFF6B6B6B),
      borderSide: BorderSide.none,
      alignment: alignment,
      autoCloseDuration: duration,
      closeButton: ToastCloseButton(showType: CloseButtonShowType.none),
      animationBuilder: (context, animation, alignment, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      type: ToastificationType.success,
      style: ToastificationStyle.simple,
    );
  }

  // Error Toast
  static void showErrorToast(
    String message, {
    Duration duration = const Duration(milliseconds: 2000),
    Alignment alignment = Alignment.bottomCenter,
  }) {
    toastification.show(
      context: Get.context!,
      title: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Icon(Icons.error, color: Colors.white),
          SizedBox(width: 10),
          Text(message, style: TextStyle(color: Colors.white)),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      icon: Icon(Icons.error, color: Colors.white),
      showIcon: true,
      backgroundColor: Color(0xFF6B6B6B),
      borderSide: BorderSide.none,
      alignment: alignment,
      autoCloseDuration: duration,
      closeButton: ToastCloseButton(showType: CloseButtonShowType.none),
      animationBuilder: (context, animation, alignment, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      type: ToastificationType.error,
      style: ToastificationStyle.simple,
    );
  }
}
