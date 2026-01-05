import 'package:dsv360/models/leave_details.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LeaveDetailsListRepository extends AsyncNotifier<List<LeaveDetails>> {
  @override
  Future<List<LeaveDetails>> build() async {
    return fetchLeaveDetails(isInitial: true) ?? [];
  }

  Future<List<LeaveDetails>> fetchLeaveDetails({bool isInitial = false}) async {
    return [];
  }
}

final leaveDetailsListRepositoryProvider =
    Provider<AsyncValue<List<LeaveDetails>>>((ref) {
      // Simulate API data
      final leaveDetailsList = <LeaveDetails>[
        LeaveDetails.fromJson({
          "CREATORID": "1",
          "Status": "Pending",
          "ActionByID": null,
          "Cancellation_Reason": null,
          "End_Date": "2026-01-07",
          "Reason": "Family vacation",
          "ActionBy": null,
          "LeaveCnt": "7",
          "MODIFIEDTIME": "",
          "Username": "Aman Jain",
          "UserID": "101",
          "Leave_Type": "Unpaid_Leave",
          "CREATEDTIME": "2025-12-20",
          "Start_Date": "2026-01-01",
          "ROWID": "1",
        }),
        LeaveDetails.fromJson({
          "CREATORID": "1",
          "Status": "Approved",
          "ActionByID": "200",
          "Cancellation_Reason": null,
          "End_Date": "2025-12-26",
          "Reason": "Travel to hometown",
          "ActionBy": "Manager",
          "LeaveCnt": "5",
          "MODIFIEDTIME": "",
          "Username": "Aman Jain",
          "UserID": "101",
          "Leave_Type": "Unpaid_Leave",
          "CREATEDTIME": "2025-12-15",
          "Start_Date": "2025-12-22",
          "ROWID": "2",
        }),
        LeaveDetails.fromJson({
          "CREATORID": "1",
          "Status": "Rejected",
          "ActionByID": "200",
          "Cancellation_Reason": "Project delivery",
          "End_Date": "2025-12-19",
          "Reason": "Personal work",
          "ActionBy": "Manager",
          "LeaveCnt": "3",
          "MODIFIEDTIME": "",
          "Username": "Aman Jain",
          "UserID": "101",
          "Leave_Type": "Unpaid_Leave",
          "CREATEDTIME": "2025-12-10",
          "Start_Date": "2025-12-17",
          "ROWID": "3",
        }),
        LeaveDetails.fromJson({
          "CREATORID": "1",
          "Status": "Pending",
          "ActionByID": null,
          "Cancellation_Reason": null,
          "End_Date": "2025-12-16",
          "Reason": "Medical checkup",
          "ActionBy": null,
          "LeaveCnt": "5",
          "MODIFIEDTIME": "",
          "Username": "Aman Jain",
          "UserID": "101",
          "Leave_Type": "Paid_Leave",
          "CREATEDTIME": "2025-12-08",
          "Start_Date": "2025-12-12",
          "ROWID": "4",
        }),
      ];

      return AsyncValue.data(leaveDetailsList);
    });


// final leaveDetailsListRepositoryProvider = AsyncNotifierProvider<LeaveDetailsListRepository, List<LeaveDetails>>(
//   LeaveDetailsListRepository.new,
// );