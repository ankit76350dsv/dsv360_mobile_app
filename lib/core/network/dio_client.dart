import 'package:dio/dio.dart';
import 'package:dsv360/core/constants/server_constant.dart';
import 'package:dsv360/core/constants/token_manager.dart';
// import 'package:esd_mobile_app/core/constants/token_manager.dart';
import 'package:flutter/material.dart';

class DioClient {
  static final DioClient _instance = DioClient._internal();
  static DioClient get instance => _instance;

  late final Dio _dio = Dio();

  DioClient._internal() {
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

      debugPrint("DioClient response: " + response.data.toString());
      debugPrint("DioClient response: " + response.statusCode.toString());

      if (response.statusCode == 200) {
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
    String path) async {
    try {
      final response = await _dio.put(
        path
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map &&
            (data['success'] == true || data['status'] == 'success')) {
          return response;
        } else {
          throw Exception(
            'API returned success = false: ${data['message'] ?? 'No message'}',
          );
        }
      } else {
        throw Exception('Unexpected status code: ${response.statusCode}');
      }
    } on DioException catch (e, trace) {
      throw Exception('Dio GET request failed: ${e.message} $trace');
    } catch (e, trace) {
      throw Exception('Unexpected error in GET request: $e $trace');
    }
  }

  // / Public method to make a POST request
  Future<Response?> post(
    String path,
    {
      dynamic data,
      Map<String, dynamic>? queryParameters,
      Options? options,
      List<MultipartFile>? attachments}) async {
    try {
      // Token interceptor added ONCE here
      // _dio.interceptors.add(InterceptorsWrapper(
      //   onRequest: (options, handler) {
      //     // final token = TokenManager.instance.token;
      //     // if (token != null) {
      //     //   options.headers['Authorization'] = 'Zoho-oauthtoken $token';
      //     // }
      //     return handler.next(options);
      //   },
      // ));

      final response = await _dio.post(
        path,
        data: data,
        options: options,
        queryParameters: queryParameters
      );

      debugPrint("response:  $response");

      // Check for HTTP 200
      if (response.statusCode == 200) {
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
      debugPrint("entered downloadFile");

      //no need to add the token, parameters and options or cookie here
      final response = await _dio.download(
        path,
        savePath,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
      debugPrint("response $response");
      debugPrint("response.data: ${response.data}");
      debugPrint("response.data: ${response.data}");

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
}
