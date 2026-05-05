import 'package:dsv360/core/network/dio_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final peopleSummaryProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final response = await ApiClient.instance.get(
    'time_entry_management_application_function/dashboard',
  );

  final body = response.data as Map<String, dynamic>? ?? {};
  final data = body['data'] as Map<String, dynamic>? ?? {};

  return {
    'date': (data['date'] ?? '').toString(),
    'total_present': data['total_present'] ?? 0,
    'total_leave': data['total_leave'] ?? 0,
    'sick': data['Sick'] ?? 0,
    'paid': data['Paid'] ?? 0,
    'unpaid': data['Unpaid'] ?? 0,
  };
});