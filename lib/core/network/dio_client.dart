import 'package:dio/dio.dart';
import 'package:dsv360/core/constants/app_navigator_key.dart';
import 'package:dsv360/core/constants/auth_manager.dart';
import 'package:dsv360/core/constants/init_zcatalyst_app.dart';
import 'package:dsv360/core/constants/server_constant.dart';
import 'package:dsv360/core/constants/token_manager.dart';
import 'package:dsv360/core/constants/user_manager.dart';
import 'package:dsv360/core/welcome/welcome_page.dart';
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
    // once. If the retry also fails, the Catalyst SDK session has fully expired
    // — force a logout so the user can re-authenticate cleanly.
    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (DioException error, ErrorInterceptorHandler handler) async {
          // FIX (Solution F): only retry once — skip if this IS the retry
          // request (header '_isRetry' was set below before calling _dio.fetch).
          // Without this guard, a second 401 on the retry fires this interceptor
          // recursively, causing an infinite loop.
          final isRetry = error.requestOptions.headers['_isRetry'] == true;

          if (error.response?.statusCode == 401 && !isRetry) {
            debugPrint('🔄 401 received — clearing stale token and retrying...');
            TokenManager.instance.clearToken();
            final newToken = await TokenManager.instance.getToken();

            if (newToken != null) {
              final opts = error.requestOptions;
              opts.headers['Authorization'] = 'Zoho-oauthtoken $newToken';
              // Mark as retry so the interceptor does not fire a second time.
              opts.headers['_isRetry'] = true;
              try {
                final retryResponse = await _dio.fetch(opts);
                return handler.resolve(retryResponse);
              } catch (e) {
                // FIX (Solution E): retry ALSO got 401 — the Catalyst OAuth
                // session has fully expired (SDK returned a stale token).
                // Force a full logout so the user lands back on the login screen.
                debugPrint(
                  '❌ Retry also failed with 401 — forcing session logout...',
                );
                _forceLogout();
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
        debugPrint('❌ GET $path — unexpected status ${response.statusCode}');
        throw Exception(_statusMessage(response.statusCode));
      }
    } on DioException catch (e) {
      debugPrint('❌ GET $path — ${e.message}');
      throw Exception(_dioMessage(e));
    } catch (e) {
      debugPrint('❌ GET $path — $e');
      throw Exception('Something went wrong. Please try again.');
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
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response;
      } else {
        debugPrint('❌ PUT $path — unexpected status ${response.statusCode}');
        throw Exception(_statusMessage(response.statusCode));
      }
    } on DioException catch (e) {
      debugPrint('❌ PUT $path — ${e.message}');
      throw Exception(_dioMessage(e));
    } catch (e) {
      debugPrint('❌ PUT $path — $e');
      throw Exception('Something went wrong. Please try again.');
    }
  }

  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response;
      } else {
        debugPrint('❌ PATCH $path — unexpected status ${response.statusCode}');
        throw Exception(_statusMessage(response.statusCode));
      }
    } on DioException catch (e) {
      debugPrint('❌ PATCH $path — ${e.message}');
      throw Exception(_dioMessage(e));
    } catch (e) {
      debugPrint('❌ PATCH $path — $e');
      throw Exception('Something went wrong. Please try again.');
    }
  }

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
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response;
      } else {
        debugPrint('❌ POST $path — unexpected status ${response.statusCode}');
        throw Exception(_statusMessage(response.statusCode));
      }
    } on DioException catch (e) {
      debugPrint('❌ POST $path — ${e.message}');
      throw Exception(_dioMessage(e));
    } catch (e) {
      debugPrint('❌ POST $path — $e');
      throw Exception('Something went wrong. Please try again.');
    }
  }

  Future<Response> getWithoutSuccess(String path, {Options? options}) async {
    try {
      final response = await _dio.get(path, options: options);
      if (response.statusCode == 200) {
        return response;
      } else {
        debugPrint('❌ GET $path — unexpected status ${response.statusCode}');
        throw Exception(_statusMessage(response.statusCode));
      }
    } on DioException catch (e) {
      debugPrint('❌ GET $path — ${e.message}');
      throw Exception(_dioMessage(e));
    } catch (e) {
      debugPrint('❌ GET $path — $e');
      throw Exception('Something went wrong. Please try again.');
    }
  }

  Future<Response<dynamic>> downloadFile(
    String path,
    String savePath, {
    required Function(int, int)? onReceiveProgress,
    required CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.download(
        path,
        savePath,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
      if (response.statusCode == 200) {
        return response;
      } else {
        debugPrint('❌ DOWNLOAD $path — unexpected status ${response.statusCode}');
        throw Exception(_statusMessage(response.statusCode));
      }
    } on DioException catch (e) {
      debugPrint('❌ DOWNLOAD $path — ${e.message}');
      throw Exception(_dioMessage(e));
    } catch (e) {
      debugPrint('❌ DOWNLOAD $path — $e');
      throw Exception('Something went wrong. Please try again.');
    }
  }

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
        data: data,
      );
      if (response.statusCode == 200 || response.statusCode == 204) {
        return response;
      } else {
        debugPrint('❌ DELETE $path — unexpected status ${response.statusCode}');
        throw Exception(_statusMessage(response.statusCode));
      }
    } on DioException catch (e) {
      debugPrint('❌ DELETE $path — ${e.message}');
      throw Exception(_dioMessage(e));
    } catch (e) {
      debugPrint('❌ DELETE $path — $e');
      throw Exception('Something went wrong. Please try again.');
    }
  }

  String _dioMessage(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Request timed out. Please check your connection and try again.';
      case DioExceptionType.connectionError:
        return 'No internet connection. Please check your network.';
      case DioExceptionType.badResponse:
        return _statusMessage(e.response?.statusCode);
      default:
        return 'Something went wrong. Please try again.';
    }
  }

  String _statusMessage(int? statusCode) {
    if (statusCode == null) return 'Something went wrong. Please try again.';
    if (statusCode >= 500) return 'Server error. Please try again later.';
    if (statusCode == 404) return 'The requested resource was not found.';
    if (statusCode == 403) return 'You do not have permission to do this.';
    if (statusCode == 400) return 'Invalid request. Please try again.';
    return 'Something went wrong. Please try again.';
  }

  /// FIX (Solution E): called when a retried request also returns 401.
  /// Clears all local session state and sends the user back to the login screen.
  void _forceLogout() {
    TokenManager.instance.clearToken();
    UserManager.instance.clear();
    AuthManager.instance.currentUser = null;
    PaintingBinding.instance.imageCache.clear();

    // Fire-and-forget the Catalyst SDK logout (no BuildContext needed).
    AppInitManager.instance.catalystApp.logout().catchError((_) {});

    // Navigate to login. Provider invalidation is handled by LoadingPage on
    // the next login — safe moment after user is valid and before Dashboard mounts.
    appNavigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const WelcomePage()),
      (route) => false,
    );
  }
}
