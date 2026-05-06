import 'dart:developer' as developer;

import 'package:dsv360/core/network/dio_client.dart';
import 'package:dsv360/features/teams/model/batch_profile_model.dart';
import 'package:flutter/material.dart';

class BatchProfileRepository {
  final _client = ApiClient.instance;

  /// Fetch batch profile data by posting the raw users array.
  Future<List<BatchProfile>> fetchBatchProfiles() async {
    try {
      debugPrint('👥 Fetching users list for batch profile payload');

      const usersPath = 'time_entry_management_application_function/employee';
      final usersResponse = await _client.get(usersPath);

      if (usersResponse.statusCode != 200 && usersResponse.statusCode != 201) {
        throw Exception('Failed to fetch users: ${usersResponse.statusCode}');
      }

      final dynamic usersData = usersResponse.data;
      List<dynamic> usersList = [];

      if (usersData is Map<String, dynamic>) {
        usersList = (usersData['users'] as List<dynamic>?) ?? [];
      } else if (usersData is List) {
        usersList = usersData;
      }

      if (usersList.isEmpty) {
        debugPrint('No users found for batch profile payload');
        return [];
      }

      // Create a map of user_id -> employee data for easy lookup
      final employeeMap = <String, dynamic>{};
      for (final user in usersList) {
        final userId = user['user_id']?.toString() ?? '';
        if (userId.isNotEmpty) {
          employeeMap[userId] = user;
        }
      }

      // Transform to send only user_id in the required format
      final payload = usersList
          .map((user) => {'user_id': user['user_id']?.toString() ?? ''})
          .toList();

      const path = 'time_entry_management_application_function/batchProfile';
      debugPrint('🌐 path: $path');

      final response = await _client.post(path, data: payload);
      debugPrint('📊 Response Status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = response.data as Map<String, dynamic>;

        if (jsonResponse['success'] == true) {
          final List<dynamic> profileList =
              (jsonResponse['data'] as List<dynamic>?) ?? [];
          debugPrint('✅ Batch profiles fetched: ${profileList.length}');

          return profileList
              .map((item) {
                final profile = item as Map<String, dynamic>;
                final userId = profile['user_id']?.toString() ?? '';
                // Merge with employee data to get name if not in profile
                if (employeeMap.containsKey(userId)) {
                  final employeeData = employeeMap[userId] as Map<String, dynamic>;
                  profile['first_name'] = profile['first_name'] ?? employeeData['first_name'];
                  profile['last_name'] = profile['last_name'] ?? employeeData['last_name'];
                }
                return BatchProfile.fromJson(profile);
              })
              .toList();
        } else {
          final msg = jsonResponse['message']?.toString() ?? 'Unknown server error';
          debugPrint('❌ API returned success: false — $msg');
          throw Exception(msg);
        }
      }

      throw Exception('Failed to fetch batch profiles: ${response.statusCode}');
    } catch (e, st) {
      debugPrint('❌ Error fetching batch profiles: $e');
      developer.log(
        'Error fetching batch profiles: $e\n$st',
        name: 'BatchProfileRepository',
      );
      rethrow;
    }
  }
}