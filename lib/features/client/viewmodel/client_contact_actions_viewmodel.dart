import 'package:dsv360/core/network/dio_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final clientContactActionsViewModelProvider =
    Provider<ClientContactActionsViewModel>((ref) {
  return ClientContactActionsViewModel();
});

class ClientContactActionsViewModel {
  bool _is404(Object e) {
    final s = e.toString();
    return s.contains('404') || s.contains('Not Found');
  }

  Future<void> updateClientStatusWithFallback({
    required bool newStatus,
    required String rowId,
    required String userId,
  }) async {
    final Map<String, dynamic> body = {
      'status': newStatus,
      'ROWID': rowId,
      'USERID': userId,
    };

    try {
      await ApiClient.instance.post(
        'time_entry_management_application_function/updateClientContactStatus',
        data: body,
      );
      return;
    } catch (e) {
      if (!_is404(e)) rethrow;
    }

    try {
      await ApiClient.instance.put(
        'time_entry_management_application_function/updateClientContactStatus/$rowId',
        data: body,
      );
      return;
    } catch (e) {
      if (!_is404(e)) rethrow;
    }

    await ApiClient.instance.put(
      'time_entry_management_application_function/contact/$rowId',
      data: body,
    );
  }

  Future<void> deleteClientContact({
    required String rowId,
    required String userId,
  }) async {
    final Map<String, dynamic> body = {
      'ROWID': rowId,
      'USERID': userId,
    };

    await ApiClient.instance.delete(
      'time_entry_management_application_function/contact',
      data: body,
    );
  }
}
