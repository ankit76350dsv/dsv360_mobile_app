import 'package:dio/dio.dart';
import 'package:dsv360/core/constants/server_constant.dart';
import 'package:dsv360/core/constants/token_manager.dart';
// import 'package:esd_mobile_app/core/constants/token_manager.dart';
import 'package:flutter/material.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  static ApiClient get instance => _instance;

  late final Dio _dio = Dio();

  ApiClient._internal() {
    _dio.options.baseUrl = ServerConstant.serverURL;
    // Maximum time Dio will wait to establish a connection.
    _dio.options.connectTimeout = const Duration(seconds: 10);
    // Disables automatic HTTP redirects
    _dio.options.followRedirects = false;

    // Inject token once
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await TokenManager.instance.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Zoho-oauthtoken $token';
          }
          return handler.next(options);
        },
      ),
    );

    // FIX (401 intermittent error): if the server rejects the token with 401,
    // clear the cached token, fetch a fresh one, and retry the original request
    // once. This handles the case where the in-memory token has expired but the
    // proactive 50-min refresh in TokenManager did not fire (e.g. app was
    // backgrounded for a long time).
    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (DioException error, ErrorInterceptorHandler handler) async {
          if (error.response?.statusCode == 401) {
            debugPrint('🔄 401 received — clearing stale token and retrying...');
            TokenManager.instance.clearToken();
            final newToken = await TokenManager.instance.getToken();
            if (newToken != null) {
              // Retry the original request with the refreshed token.
              final opts = error.requestOptions;
              opts.headers['Authorization'] = 'Zoho-oauthtoken $newToken';
              try {
                final retryResponse = await _dio.fetch(opts);
                return handler.resolve(retryResponse);
              } catch (e) {
                // Retry also failed — let the error propagate normally.
                return handler.next(error);
              }
            }
          }
          return handler.next(error);
        },
      ),
    );

    // Automatically logs: Request URL, Headers, Body, Response body
    _dio.interceptors.add(
      LogInterceptor(requestBody: true, responseBody: true),
    );
  }

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response;
      } else {
        throw Exception('Unexpected status code: ${response.statusCode}');
      }
    } on DioException catch (e, trace) {
      throw Exception('Dio GET request failed: ${e.message} $trace');
    } catch (e, trace) {
      throw Exception('Unexpected error in GET request: $e $trace');
    }
  }

  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );

      debugPrint("ApiClientresponse: ${response.data}");
      debugPrint("ApiClientresponse: ${response.statusCode}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response;
      } else {
        throw Exception('Unexpected status code: ${response.statusCode}');
      }
    } on DioException catch (e, trace) {
      throw Exception('Dio PUT request failed: ${e.message} $trace');
    } catch (e, trace) {
      throw Exception('Unexpected error in PUT request: $e $trace');
    }
  }

  // / Public method to make a POST request
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    List<MultipartFile>? attachments,
  }) async {
    try {
      

      final response = await _dio.post(
        path,
        data: data,
        options: options,
        queryParameters: queryParameters,
      );

      // debugPrint("response:  $response");

      // Check for HTTP 200
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response;
      } else {
        throw Exception('Unexpected status code: ${response.statusCode}');
      }
    } on DioException catch (e, trace) {
      throw Exception('Dio POST request failed: ${e.message} $trace');
    } catch (e) {
      throw Exception('Unexpected error in POST request: $e');
    }
  }

  /// Public method to make a GET request
  Future<Response> getWithoutSuccess(String path, {Options? options}) async {
    try {
      //no need to add the token, parameters and options or cookie here
      final response = await _dio.get(path, options: options);

      // Check for HTTP 200
      if (response.statusCode == 200) {
        return response;
      } else {
        throw Exception('Unexpected status code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Dio GET request failed: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error in GET request: $e');
    }
  }

  Future<Response<dynamic>> downloadFile(
    String path,
    String savePath, {
    required Function(int, int)? onReceiveProgress,
    required CancelToken? cancelToken,
  }) async {
    try {
      // debugPrint("entered downloadFile");

      //no need to add the token, parameters and options or cookie here
      final response = await _dio.download(
        path,
        savePath,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
      // debugPrint("response $response");
      // debugPrint("response.data: ${response.data}");
      // debugPrint("response.data: ${response.data}");

      // Check for HTTP 200
      if (response.statusCode == 200) {
        return response;
      } else {
        throw Exception('Unexpected status code: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Unexpected error in GET request: $e');
      throw Exception('Unexpected error in GET request: $e');
    }
  }

  /// Public method to make a DELETE request
  Future<Response> delete(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    dynamic data,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        queryParameters: queryParameters,
        options: options,
        data: data, // optional body (some APIs need this)
      );

      // debugPrint("ApiClient response: ${response.data}");
      // debugPrint("ApiClient response code: ${response.statusCode}");

      if (response.statusCode == 200 || response.statusCode == 204) {
        return response;
      } else {
        throw Exception('Unexpected status code: ${response.statusCode}');
      }
    } on DioException catch (e, trace) {
      throw Exception('Dio DELETE request failed: ${e.message} $trace');
    } catch (e, trace) {
      throw Exception('Unexpected error in DELETE request: $e $trace');
    }
  }
}
