import 'package:dsv360/core/network/dio_client.dart';
import 'package:dsv360/core/models/organization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OrganizationRepository extends AsyncNotifier<List<Organization>> {
  @override
  Future<List<Organization>> build() async {
    return fetchOrganizations(isInitial: true);
  }

  /// Fetch all organizations/clients from the backend
  Future<List<Organization>> fetchOrganizations({
    bool isInitial = false,
  }) async {
    try {
      final response = await ApiClient.instance.get(
        'time_entry_management_application_function/clientOrg',
      );
      debugPrint("Response From fetchOrganizations: $response");

      final data = response.data;
      
      if (data['success'] == true && data['data'] != null) {
        final List<dynamic> list = data["data"];
        final organizationsList = list
            .map((e) => Organization.fromJson(e))
            .toList();

        debugPrint("✅ Fetched ${organizationsList.length} organizations");
        return organizationsList;
      } else {
        debugPrint("⚠️ API returned success=false or no data");
        return [];
      }
    } catch (e, st) {
      debugPrint("❌ Error fetching organizations: $e");
      debugPrint("Stack trace: $st");
      throw AsyncError(e, st);
    }
  }

  /// Get only active organizations
  Future<List<Organization>> fetchActiveOrganizations() async {
    final allOrgs = await fetchOrganizations();
    return allOrgs.where((org) => org.isActive).toList();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(fetchOrganizations);
  }
}

final organizationListRepositoryProvider =
    AsyncNotifierProvider<OrganizationRepository, List<Organization>>(
      OrganizationRepository.new,
    );

final organizationSearchQueryProvider = StateProvider.autoDispose<String>((ref) => '');
