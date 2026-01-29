import 'package:dsv360/core/network/dio_client.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AiRepository {
  final Ref ref;

  AiRepository(this.ref);

  Future<String> getLlmAnswer({
    required String prompt,
    required String modelType,
    required String model,
    List<String>? images,
  }) async {
    try {
      final response = await DioClient.instance.post(
        'ai_service/api/llm/answer',
        data: {
          "prompt": prompt,
          "model_type": modelType,
          "model": model,
          if (images != null) "images": images,
        },
      );

      debugPrint("Response From getLlmAnswer: ${response.data}");

      // Based on common patterns, extracting the answer
      // Adjusting this if the structure is different
      if (response.data != null) {
        if (response.data is Map) {
          return response.data['answer'] ??
              response.data['response'] ??
              response.data['data']?['answer'] ??
              "No response received";
        }
        return response.data.toString();
      }
      return "Empty response";
    } catch (e) {
      debugPrint("Error in getLlmAnswer: $e");
      rethrow;
    }
  }

  Future<String> getRagAnswer({
    required String query,
    required List<String> documents,
  }) async {
    try {
      final response = await DioClient.instance.post(
        'ai_service/api/rag/answer',
        data: {"query": query, "documents": documents},
      );

      debugPrint("Response From getRagAnswer: ${response.data}");

      if (response.data != null) {
        if (response.data is Map) {
          return response.data['answer'] ??
              response.data['response'] ??
              response.data['data']?['answer'] ??
              "No response received";
        }
        return response.data.toString();
      }
      return "Empty response";
    } catch (e) {
      debugPrint("Error in getRagAnswer: $e");
      rethrow;
    }
  }
}

final aiRepositoryProvider = Provider<AiRepository>((ref) {
  return AiRepository(ref);
});
