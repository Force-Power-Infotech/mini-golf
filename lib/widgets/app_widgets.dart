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

  static successSnackBar(
      {required String content, Color textColor = Colors.black}) {
    if (Get.isSnackbarOpen) {
      Get.closeAllSnackbars();
    }
    return Get.snackbar('Success', content,
        backgroundColor: Colors.green.withOpacity(0.8),
        borderRadius: 10,
        colorText: textColor);
  }

  static errorSnackBar({
    required String content,
    Color textColor = Colors.white,
    Duration duration = const Duration(seconds: 3),
  }) {
    if (Get.isSnackbarOpen) {
      Get.closeAllSnackbars();
    }
    return Get.snackbar('Error', content,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: textColor,
        borderRadius: 10,
        duration: duration);
  }

  static showLoader() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      // show loader
      showDialog(
        context: Get.context ?? Get.overlayContext!,
        barrierDismissible: false,
        builder: (_) => Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
              margin: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(10)),
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CupertinoActivityIndicator(
                        color: Colors.white,
                        radius: 15,
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Text(
                        "Please wait...",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  )),
            ),
          ),
        ),
      );
    });
  }
}
