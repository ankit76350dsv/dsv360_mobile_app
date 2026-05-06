import 'dart:async';
import 'dart:developer' as developer;
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:dsv360/core/constants/token_manager.dart';
import 'package:dsv360/core/network/dio_client.dart';
import 'package:dsv360/features/users/model/users.dart';
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

/// Plain (non-notifier) repository for create / update / delete operations.
/// View pages that need to call these without a Riverpod notifier use this.
class UserCrudRepository {
  final _client = ApiClient.instance;

  Future<void> createUser({
    required String firstName,
    required String lastName,
    required String emailId,
    required String roleId,
  }) async {
    const path = 'time_entry_management_application_function/AddEmployees';
    final formData = FormData.fromMap({
      'first_name': firstName.trim(),
      'last_name': lastName.trim(),
      'email_id': emailId.trim(),
      'role_id': roleId.trim(),
    });
    debugPrint('POST $path with body fields: ${formData.fields}');
    try {
      final response = await _client.post(path, data: formData);
      debugPrint('Create user response status: ${response.statusCode}');
      debugPrint('Create user response data: ${response.data}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data is Map<String, dynamic> &&
            data.containsKey('success') &&
            data['success'] != true) {
          throw Exception(data['message'] ?? 'Failed to create user');
        }
        return;
      }
      throw Exception('Failed to create user: ${response.statusCode}');
    } catch (e) {
      debugPrint('Error creating user: $e');
      throw Exception('Error creating user: $e');
    }
  }

  Future<void> updateUser({
    required String userId,
    required String firstName,
    required String lastName,
    required String emailId,
    required String roleId,
  }) async {
    final path = 'time_entry_management_application_function/UpdateEmployee/$userId';
    final body = {
      'first_name': firstName.trim(),
      'last_name': lastName.trim(),
      'email_id': emailId.trim(),
      'role_id': roleId.trim(),
    };
    debugPrint('POST $path with body: $body');
    try {
      final response = await _client.post(path, data: body);
      debugPrint('Update user response status: ${response.statusCode}');
      debugPrint('Update user response data: ${response.data}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data is Map<String, dynamic> &&
            data.containsKey('success') &&
            data['success'] != true) {
          throw Exception(data['message'] ?? 'Failed to update user');
        }
        return;
      }
      throw Exception('Failed to update user: ${response.statusCode}');
    } catch (e) {
      debugPrint('Error updating user: $e');
      throw Exception('Error updating user: $e');
    }
  }

  Future<void> deleteUser({
    required String userId,
    List<Map<String, dynamic>> reassignmentPayload = const [],
  }) async {
    final path = 'time_entry_management_application_function/employee/$userId';
    debugPrint('POST $path with reassignment payload: $reassignmentPayload');
    try {
      final response = await _client.post(path, data: reassignmentPayload);
      debugPrint('Delete user response status: ${response.statusCode}');
      debugPrint('Delete user response data: ${response.data}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data is Map<String, dynamic> &&
            data.containsKey('success') &&
            data['success'] != true) {
          throw Exception(data['message'] ?? 'Failed to delete user');
        }
        return;
      }
      throw Exception('Failed to delete user: ${response.statusCode}');
    } catch (e) {
      debugPrint('Error deleting user: $e');
      throw Exception('Error deleting user: $e');
    }
  }
}

// Keep legacy aliases so existing instantiation code compiles unchanged.
class CreateUserRepository extends UserCrudRepository {}
class UpdateUserRepository extends UserCrudRepository {}
class DeleteUserRepository extends UserCrudRepository {}

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
