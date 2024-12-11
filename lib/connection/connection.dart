import 'dart:convert';
import 'dart:developer';
import 'package:get/get.dart' as loader;

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'package:minigolf/widgets/app_widgets.dart';

class ApiService {
  static BaseOptions options = BaseOptions(
    receiveTimeout: const Duration(seconds: 90),
    connectTimeout: const Duration(seconds: 90),
    followRedirects: true,
  );
  final Dio _dio = Dio(options);

  ApiService() {
    // _dio.interceptors.add(LogInterceptor());
    debugPrint(
        'DioClient initialized with connectTimeout: ${options.connectTimeout} and receiveTimeout: ${options.receiveTimeout}');
    _dio.interceptors.add(InterceptorsWrapper(
      // Print Request
      onRequest: (RequestOptions options, RequestInterceptorHandler handler) {
        debugPrint('*** Request ***');
        debugPrint('uri: ${options.uri}');
        debugPrint('method: ${options.method}');
        debugPrint('responseType: ${options.responseType.toString()}');
        debugPrint('followRedirects: ${options.followRedirects}');
        debugPrint('persistentConnection: ${options.persistentConnection}');
        debugPrint('connectTimeout: ${options.connectTimeout}');
        debugPrint('sendTimeout: ${options.sendTimeout}');
        debugPrint('receiveTimeout: ${options.receiveTimeout}');
        debugPrint(
            'receiveDataWhenStatusError: ${options.receiveDataWhenStatusError}');
        debugPrint('headers: ${options.headers}');
        debugPrint('queryParameters: ${options.queryParameters}');
        debugPrint('data: ${options.data}');
        debugPrint('*** End Request ***');
        return handler.next(options);
      },
      // Print Response
      onResponse: (Response response, ResponseInterceptorHandler handler) {
        debugPrint('*** Response ***');
        debugPrint('statusCode: ${response.statusCode}');
        debugPrint('statusMessage: ${response.statusMessage}');
        debugPrint('headers: ${response.headers}');
        debugPrint('request: ${response.requestOptions}');
        debugPrint('data: ${response.data}');
        debugPrint('*** End Response ***');
        return handler.next(response);
      },
      // Print Error
      onError: (DioException error, ErrorInterceptorHandler handler) {
        debugPrint('*** Error ***');
        debugPrint('uri: ${error.requestOptions.uri}');
        debugPrint('$error');
        debugPrint('*** End Error ***');
        return handler.next(error);
      },
    ));
  }

  Future<Response?> get(String url,
      {Map<String, dynamic>? queryParameters}) async {
    AppWidgets.showLoader();
    try {
      final response = await _dio.get(url, queryParameters: queryParameters);
      loader.Get.back(closeOverlays: true, canPop: false);
      return response;
    } catch (e) {
      loader.Get.back(closeOverlays: true, canPop: false);
      log('Exception: $e');
      rethrow;
    }
  }

  Future<Response?> post(String url, {Map<String, dynamic>? data}) async {
    await AppWidgets.showLoader();

    try {
      data?.addAll({});
      Object formData = FormData.fromMap(data ?? {});

      final response = await _dio.post(url, data: formData);
      log('Response: ${response.data}');
      loader.Get.back(closeOverlays: true, canPop: false);
      return response;
    } catch (e) {
      loader.Get.back(closeOverlays: true, canPop: false);
      log('Exception: $e');
      rethrow;
    }
  }
}
