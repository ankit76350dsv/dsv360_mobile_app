import 'package:dsv360/features/feedback/model/feedback_model.dart';
import 'package:dsv360/features/feedback/repositories/feedback_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final feedbackRepositoryProvider =
    AsyncNotifierProvider<FeedbackRepository, List<FeedbackModel>>(
      FeedbackRepository.new,
    );

final feedbackSearchQueryProvider = StateProvider.autoDispose<String>((ref) => '');