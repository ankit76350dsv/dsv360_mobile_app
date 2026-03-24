import 'dart:async';
import 'dart:developer' as developer;

import 'package:dsv360/core/network/dio_client.dart';
import 'package:dsv360/models/feedback_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FeedbackRepository extends AsyncNotifier<List<FeedbackModel>> {
  @override
  FutureOr<List<FeedbackModel>> build() async {
    return await fetchFeedbacks(isInitial: true);
  }

  Future<List<FeedbackModel>> fetchFeedbacks({bool isInitial = false}) async {
    try {
      // todo: Confirm the endpoint URL
      final response = await ApiClient.instance.get(
        'time_entry_management_application_function/feedback',
      );
      debugPrint("Response From fetchFeedbacks: $response");

      final data = response.data;
      final List<dynamic> list = data["data"] ?? [];
      final feedbackList = list.map((e) => FeedbackModel.fromJson(e)).toList();

      return feedbackList;
    } catch (e, st) {
      developer.log("Error fetching feedbacks: $e", name: "FeedbackRepository");
      throw AsyncError(e, st);
    }
  }
}

final feedbackRepositoryProvider =
    AsyncNotifierProvider<FeedbackRepository, List<FeedbackModel>>(
      FeedbackRepository.new,
    );

final feedbackSearchQueryProvider = StateProvider<String>((ref) => '');
