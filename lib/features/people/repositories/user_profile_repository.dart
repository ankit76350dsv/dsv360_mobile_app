import 'package:dsv360/core/network/dio_client.dart';
import 'package:flutter/material.dart';

class UserProfileRepository {
  final _client = ApiClient.instance;

  Future<Map<String, dynamic>> userProfile(String userId) async{
    try{
      const path = 'time_entry_management_application_function/profile/data';
      final response = await _client.get(path, queryParameters: {'User_ID':userId});

      debugPrint("User Profile Data here from People Module ${response.data}");

      if(response.statusCode == 200){
        return response.data as Map<String, dynamic>;
      }else{
        throw Exception('Failed to check timer status : ${response.statusCode}');
      }
    }catch(e){
      rethrow;
    }
  }
}
