import 'package:dio/dio.dart';

class ApiClient {
  final Dio _dio;
  ApiClient._internal(this._dio);

  static final ApiClient _instance =
      ApiClient._internal(Dio(BaseOptions(baseUrl: 'https://api.dsv360.ai')));

  factory ApiClient() => _instance;

  Future<Response> get(String path, {Map<String, dynamic>? query}) async {
    return _dio.get(path, queryParameters: query);
  }

  Future<Response> post(String path, {dynamic data}) async {
    return _dio.post(path, data: data);
  }
}
