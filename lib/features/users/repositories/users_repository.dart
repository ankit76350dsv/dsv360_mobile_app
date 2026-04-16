import 'dart:async';
import 'dart:developer' as developer;
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:dsv360/core/constants/token_manager.dart';
import 'package:dsv360/core/network/dio_client.dart';
import 'package:dsv360/models/users.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UsersRepository extends AsyncNotifier<List<UsersModel>> {
  @override
  FutureOr<List<UsersModel>> build() async {
    return fetchUsers();
  }

  Future<List<UsersModel>> fetchUsers() async {
    try {
      final response = await ApiClient.instance.get(
        'time_entry_management_application_function/employee',
      );
      debugPrint('Users response: ${response.data}');

      final data = response.data;
      List<dynamic> usersJsonList = const [];

      if (data is List) {
        usersJsonList = data;
      } else if (data is Map) {
        if (data['users'] is List) {
          usersJsonList = data['users'] as List<dynamic>;
        } else if (data['data'] is List) {
          usersJsonList = data['data'] as List<dynamic>;
        }
      }

      if (usersJsonList.isEmpty) {
        developer.log('Users payload is empty or not a list', name: 'UsersRepository');
        return [];
      }

      return usersJsonList
          .whereType<Map>()
          .map((e) => UsersModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (e) {
      developer.log(
        'Error fetching users: $e',
        name: 'UsersRepository',
      );
      throw Exception('Failed to fetch users: $e');
    }
  }
}

final usersRepositoryProvider =
    AsyncNotifierProvider<UsersRepository, List<UsersModel>>(
      UsersRepository.new,
    );

final usersSearchQueryProvider = StateProvider.autoDispose<String>((ref) => '');

bool _isZohoUrl(String url) {
  return url.contains('catalystserverless.in') || url.contains('dsv360.ai');
}

/// Fetches profile image bytes using an authenticated Dio instance only for
/// Zoho-hosted URLs. Non-Zoho URLs (e.g. placeholders) are fetched without auth.
final profileImageProvider =
    FutureProvider.family<Uint8List?, String>((ref, url) async {
  if (url.isEmpty) return null;
  try {
    final dio = Dio();
    final Map<String, dynamic>? headers = _isZohoUrl(url)
        ? {'Authorization': 'Zoho-oauthtoken ${await TokenManager.instance.getToken()}'}
        : null;
    final response = await dio.get<List<int>>(
      url,
      options: Options(
        responseType: ResponseType.bytes,
        headers: headers,
        followRedirects: true,
        validateStatus: (status) => status != null && status < 400,
      ),
    );
    final data = response.data;
    if (data == null) return null;
    return Uint8List.fromList(data);
  } catch (e) {
    debugPrint('profileImageProvider error for $url: $e');
    return null;
  }
});
