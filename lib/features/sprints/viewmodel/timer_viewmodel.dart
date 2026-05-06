import 'package:dsv360/features/sprints/repositories/timer_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final timerRepositoryProvider = Provider<TimerRepository>((ref) {
  return TimerRepository();
});

// Legacy provider aliases.
final startTimerRepositoryProvider = Provider<TimerRepository>((ref) => ref.read(timerRepositoryProvider));
final stopTimerRepositoryProvider = Provider<TimerRepository>((ref) => ref.read(timerRepositoryProvider));
final timerInfoRepositoryProvider = Provider<TimerRepository>((ref) => ref.read(timerRepositoryProvider));
final sprintTimeEntryRepositoryProvider = Provider<TimerRepository>((ref) => ref.read(timerRepositoryProvider));
final createTimeEntryRepositoryProvider = Provider<TimerRepository>((ref) => ref.read(timerRepositoryProvider));
