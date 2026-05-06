import 'package:dsv360/features/ai/repositories/ai_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final aiRepositoryProvider = Provider<AiRepository>((ref) {
  return AiRepository(ref);
});
