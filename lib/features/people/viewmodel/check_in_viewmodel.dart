import 'package:flutter_riverpod/flutter_riverpod.dart';

// Tracks elapsed duration since check-in
final checkInElapsedProvider = StateProvider.autoDispose<Duration>((ref) {
  return Duration.zero;
});
