import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

class AppWidgets {
  // Button
  static Widget button(
      {required String text,
      void Function()? onPressed,
      Color? color,
      double? width}) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        width: width ?? 100.w,
        margin: EdgeInsets.symmetric(vertical: 1.h, horizontal: 4.w),
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        decoration: BoxDecoration(
          color: color ?? Colors.green,
          borderRadius: BorderRadius.circular(5),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // Mobile Number Formatter
  static TextInputFormatter mobileNumberFormatter() {
    // Format Phone Number XXX-XXX-XXXX
    return TextInputFormatter.withFunction(
      (oldValue, newValue) {
        final text = newValue.text.replaceAll('-', '');
        if (text.length > 10) {
          return oldValue;
        }
        final buffer = StringBuffer();
        for (int i = 0; i < text.length; i++) {
          if (i == 3 || i == 6) {
            buffer.write('-');
          }
          buffer.write(text[i]);
        }
        return TextEditingValue(
          text: buffer.toString(),
          selection: TextSelection.collapsed(offset: buffer.length),
        );
      },
    );
  }

  static successSnackBar({
    required String content,
    Color textColor = Colors.black,
    Duration duration = const Duration(seconds: 3),
  }) {
    if (Get.isSnackbarOpen) {
      Get.closeAllSnackbars();
    }
    return Get.snackbar(
      'Success',
      content,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green.withOpacity(0.9),
      borderRadius: 20,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      colorText: textColor,
      duration: duration,
      icon: const Icon(
        CupertinoIcons.check_mark_circled_solid,
        color: Colors.white,
        size: 26,
      ),
      padding: const EdgeInsets.all(16),
      titleText: const Text(
        'Success',
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      messageText: Text(
        content,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
      ),
      boxShadows: [
        BoxShadow(
          color: Colors.greenAccent.withOpacity(0.3),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  static errorSnackBar({
    required String content,
    Color textColor = Colors.white,
    Duration duration = const Duration(seconds: 3),
  }) {
    if (Get.isSnackbarOpen) {
      Get.closeAllSnackbars();
    }
    return Get.snackbar(
      'Error',
      content,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red.withOpacity(0.9),
      borderRadius: 20,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      colorText: textColor,
      duration: duration,
      icon: const Icon(
        CupertinoIcons.exclamationmark_triangle_fill,
        color: Colors.white,
        size: 26,
      ),
      padding: const EdgeInsets.all(16),
      titleText: const Text(
        'Error',
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      messageText: Text(
        content,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
      ),
      boxShadows: [
        BoxShadow(
          color: Colors.redAccent.withOpacity(0.3),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  static showLoader() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      // Show loader with a centered image
      showDialog(
        context: Get.context ?? Get.overlayContext!,
        barrierDismissible: false, // Prevent dismiss
        builder: (_) => Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Image.asset(
                'assets/images/golfballfire.gif', // Replace with your loader image path
                width: 100, // Adjust the size as needed
                height: 100,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      );
    });
  }
}
