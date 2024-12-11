import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';

class LoggingInterceptors extends Interceptor {
  String logObject(Object object) {
    // Encode your object and then decode your object to Map variable
    Map jsonMapped = json.decode(json.encode(object));

    // Using JsonEncoder for spacing
    JsonEncoder encoder = const JsonEncoder.withIndent('  ');

    // encode it to string
    String prettylog = encoder.convert(jsonMapped);
    return prettylog;
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    log("--> ${options.method.toUpperCase()} ${"${options.baseUrl}${options.path}"}");
    log("Headers:");
    options.headers.forEach((k, v) => log('$k: $v'));
    log("queryParameters:");
    options.queryParameters.forEach((k, v) => log('$k: $v'));
    if (options.data != null) {
      try {
        // log("Body: ${logObject(options.data)}");
        FormData formData = options.data as FormData;
        log("Body:");
        var buffer = [];
        for (MapEntry<String, String> pair in formData.fields) {
          buffer.add('${pair.key}:${pair.value}');
        }
        log("Body:{${buffer.join(', ')}}");
      } catch (e) {
        log("Body: ${logObject(options.data)}");
      }
    }
    log("--> END ${options.method.toUpperCase()}");
    return super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    log("<-- ${err.message} ${(err.response?.requestOptions != null ? (err.response!.requestOptions.baseUrl + err.response!.requestOptions.path) : 'URL')}");
    log("${err.response != null ? err.response!.data : 'Unknown Error'}");
    log("<-- End error");
    return super.onError(err, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    log("<-- ${response.statusCode} ${((response.requestOptions.baseUrl + response.requestOptions.path))}");
    log("Headers:");
    response.headers.forEach((k, v) => log('$k: $v'));
    log("Response: ${response.data}");
    log("<-- END HTTP");
    return super.onResponse(response, handler);
  }
}
