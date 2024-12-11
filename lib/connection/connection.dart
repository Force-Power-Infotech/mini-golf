import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' as loader;

import 'package:minigolf/widgets/app_widgets.dart';

class ApiService {
  static final BaseOptions options = BaseOptions(
    receiveTimeout: const Duration(seconds: 90),
    connectTimeout: const Duration(seconds: 90),
    validateStatus: (status) {
      // Allow redirection codes to pass
      return status != null && status < 500;
    },
  );

  final Dio _dio = Dio();

  ApiService() {
    // Configure Dio with interceptors
    _dio.interceptors.add(InterceptorsWrapper(
      // Log Request Details
      onRequest: (RequestOptions options, RequestInterceptorHandler handler) {
        debugPrint('*** Request ***');
        debugPrint('URI: ${options.uri}');
        debugPrint('Method: ${options.method}');
        debugPrint('Headers: ${options.headers}');
        debugPrint('Query Parameters: ${options.queryParameters}');
        debugPrint('Data: ${options.data}');
        debugPrint('*** End Request ***');
        return handler.next(options);
      },
      // Log Response Details
      onResponse: (Response response, ResponseInterceptorHandler handler) {
        debugPrint('*** Response ***');
        debugPrint('Status Code: ${response.statusCode}');
        debugPrint('Data: ${response.data}');
        debugPrint('*** End Response ***');
        return handler.next(response);
      },
      // Log Error Details
      onError: (DioException error, ErrorInterceptorHandler handler) {
        debugPrint('*** Error ***');
        debugPrint('URI: ${error.requestOptions.uri}');
        debugPrint('Message: ${error.message}');
        debugPrint('StackTrace: ${error.error}');
        debugPrint('*** End Error ***');
        return handler.next(error);
      },
    ));
  }

  /// GET Request
  Future<Response?> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
  }) async {
    AppWidgets.showLoader();
    try {
      final response = await _dio.request(endpoint,
          queryParameters: queryParameters, options: Options(method: 'GET'));
      loader.Get.back(closeOverlays: true, canPop: false);
      return response;
    } catch (e) {
      loader.Get.back(closeOverlays: true, canPop: false);
      log('GET Exception: $e');
      rethrow;
    }
  }

  /// POST Request
  Future<Response?> post(
    String endpoint, {
    Map<String, dynamic>? data,
  }) async {
    AppWidgets.showLoader();
    try {
      // Convert data to FormData
      final formData = FormData.fromMap(data ?? {});
      Response response = await _dio.request(endpoint,
          data: formData, options: Options(method: 'POST'));
      if (response.statusCode == 302) {
        String? redirectUrl = response.headers['location']?.first;

        if (redirectUrl != null) {
          response = await _dio.get(redirectUrl);
        }
      }
      loader.Get.back(closeOverlays: true, canPop: false);
      return response;
    } catch (e) {
      loader.Get.back(closeOverlays: true, canPop: false);
      log('POST Exception: $e');
      rethrow;
    }
  }
}
