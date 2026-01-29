import 'package:dsv360/core/network/dio_client.dart';
import 'package:dsv360/models/leave_calendar_event.dart';
import 'package:dsv360/models/leave_details.dart';
import 'package:dsv360/repositories/active_user_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LeaveDetailsListRepository extends AsyncNotifier<List<LeaveDetails>> {
  @override
  Future<List<LeaveDetails>> build() async {
    return fetchLeaveDetails();
  }

  Future<List<LeaveDetails>> fetchLeaveDetails() async {
    final activeUser = ref.read(activeUserRepositoryProvider);
    if (activeUser == null) {
      throw AsyncError("No active user found", StackTrace.current);
    }

    try {
      final userId = activeUser.userId;
      final response = await DioClient.instance.get(
        'time_entry_management_application_function/leave/approval/$userId',
      );

      debugPrint("Response From fetchLeaveDetails: ${response.data}");

      final data = response.data;
      final List<dynamic> list = data["data"] ?? [];
      final leaveDetailsList = list
          .map((e) => LeaveDetails.fromJson(e))
          .toList();

      return leaveDetailsList;
    } catch (e) {
      debugPrint("Error fetching Leave Details: $e");
      throw AsyncError(e, StackTrace.current);
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => fetchLeaveDetails());
  }

  Future<void> rejectLeave({
    required String rowId,
    required String actionById,
    required String actionBy,
    required String cancellationReason,
  }) async {
    try {
      final response = await DioClient.instance.post(
        'time_entry_management_application_function/leave/approval/$rowId',
        data: {
          "Status": "Rejected",
          "ActionByID": actionById,
          "ActionBy": actionBy,
          "Cancellation_Reason": cancellationReason,
        },
      );

      debugPrint("Response From rejectLeave: ${response.data}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        await refresh();
      } else {
        throw Exception("Failed to reject leave: ${response.data}");
      }
    } catch (e) {
      debugPrint("Error rejecting Leave: $e");
      rethrow;
    }
  }

  Future<void> approveLeave({
    required String rowId,
    required String actionById,
    required String actionBy,
  }) async {
    try {
      final response = await DioClient.instance.post(
        'time_entry_management_application_function/leave/approval/$rowId',
        data: {
          "Status": "Approved",
          "ActionByID": actionById,
          "ActionBy": actionBy,
          "Cancellation_Reason": "",
        },
      );

      debugPrint("Response From approveLeave: ${response.data}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        await refresh();
      } else {
        throw Exception("Failed to approve leave: ${response.data}");
      }
    } catch (e) {
      debugPrint("Error approving Leave: $e");
      rethrow;
    }
  }

  Future<void> requestLeave({
    required String userId,
    required String username,
    required String leaveType,
    required String reason,
    required String startDate,
    required String endDate,
    required String leaveCnt,
  }) async {
    try {
      final response = await DioClient.instance.post(
        'time_entry_management_application_function/leave/request',
        data: {
          "UserID": userId,
          "Username": username,
          "Leave_Type": leaveType,
          "Reason": reason,
          "End_Date": endDate,
          "LeaveCnt": leaveCnt,
          "Start_Date": startDate,
          "Status": "Pending",
        },
      );

      debugPrint("Response From requestLeave: ${response.data}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        await refresh();
      } else {
        throw Exception("Failed to request leave: ${response.data}");
      }
    } catch (e) {
      debugPrint("Error requesting Leave: $e");
      rethrow;
    }
  }

  Future<void> updateLeave({
    required String rowId,
    required String userId,
    required String username,
    required String leaveType,
    required String reason,
    required String startDate,
    required String endDate,
    required String leaveCnt,
  }) async {
    try {
      final response = await DioClient.instance.put(
        'time_entry_management_application_function/leave/approval/$rowId',
        data: {
          "UserID": userId,
          "Username": username,
          "Leave_Type": leaveType,
          "Reason": reason,
          "End_Date": endDate,
          "LeaveCnt": leaveCnt,
          "Start_Date": startDate,
        },
      );

      debugPrint("Response From updateLeave: ${response.data}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        await refresh();
      } else {
        throw Exception("Failed to update leave: ${response.data}");
      }
    } catch (e) {
      debugPrint("Error updating Leave: $e");
      rethrow;
    }
  }
}

final leaveDetailsListRepositoryProvider =
    AsyncNotifierProvider<LeaveDetailsListRepository, List<LeaveDetails>>(
      LeaveDetailsListRepository.new,
    );

class LeaveCalendarRepository extends AsyncNotifier<List<LeaveCalendarEvent>> {
  @override
  Future<List<LeaveCalendarEvent>> build() async {
    return fetchCalendarData();
  }

  Future<List<LeaveCalendarEvent>> fetchCalendarData() async {
    try {
      final response = await DioClient.instance.get(
        'time_entry_management_application_function/calendar',
      );

      debugPrint("Response From fetchCalendarData: ${response.data}");

      final data = response.data;
      final List<dynamic> list = data["data"] ?? [];
      final calendarEvents = list
          .map((e) => LeaveCalendarEvent.fromJson(e))
          .toList();

      return calendarEvents;
    } catch (e) {
      debugPrint("Error fetching Calendar Data: $e");
      throw AsyncError(e, StackTrace.current);
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => fetchCalendarData());
  }
}

final leaveCalendarRepositoryProvider =
    AsyncNotifierProvider<LeaveCalendarRepository, List<LeaveCalendarEvent>>(
      LeaveCalendarRepository.new,
    );
