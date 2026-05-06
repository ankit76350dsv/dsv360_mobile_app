import 'package:dsv360/core/network/dio_client.dart';
import 'package:flutter/foundation.dart';

class TimeEntryHistoryRepository {
  final _client = ApiClient.instance;

  Future<Map<String, dynamic>> timeEntryHistory(String userId) async{

    try{

      const path = 'time_entry_management_application_function/timeentry/approval';

      final response = await _client.get(path, queryParameters: {'User_ID': userId});

      if(response.statusCode == 200){
        return response.data as Map<String, dynamic>;

      }else{
        throw Exception("failed : ${response.statusCode}");
      }

    }catch(e){
      debugPrint('Error $e');
      rethrow;
    }
  }

}