import 'package:dsv360/core/network/dio_client.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'check_in_repository.g.dart';

@riverpod
class CheckInRepository extends _$CheckInRepository {
  @override
  void build() {
    return;
  }

  Future<Map<String, dynamic>> checkIn({
    required String userId,
    required String username,
    required String device,
    required double lat,
    required double long,
    required String dayDate,
  }) async {
    try {
      final response = await DioClient.instance.post(
        'time_entry_management_application_function/checkIn',
        data: {
          "CIN_Device": device,
          "CIN_Location_Lat": lat,
          "CIN_Location_Long": long,
          "Day_Date": dayDate,
          "User_ID": userId,
          "Username": username,
        },
      );
      debugPrint("CheckIn Response: ${response.data}");
      return response.data;
    } catch (e) {
      debugPrint("Error in checkIn: $e");
      rethrow;
    }
  }

  Future<Map<String, dynamic>> checkOut({
    required String device,
    required double lat,
    required double long,
    required int checkInTimestamp,
    required String rowId,
  }) async {
    try {
      final response = await DioClient.instance.put(
        'time_entry_management_application_function/checkOut',
        data: {
          "COUT_Device": device,
          "COUT_Location_Lat": lat,
          "COUT_Location_Long": long,
          "Check_In": checkInTimestamp,
          "ROWID": rowId,
        },
      );
      debugPrint("CheckOut Response: ${response.data}");
      return response.data;
    } catch (e) {
      debugPrint("Error in checkOut: $e");
      rethrow;
    }
  }
}
