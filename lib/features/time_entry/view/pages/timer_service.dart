import 'dart:async';
import 'package:flutter/foundation.dart';

class TimerService extends ChangeNotifier {
  static final TimerService instance = TimerService._();
  TimerService._();

  Timer? _ticker;
  DateTime? _startTime;
  bool _isRunning = false;

  bool get isRunning => _isRunning;
  DateTime? get startTime => _startTime;

  Duration get elapsed {
    if (_startTime == null) return Duration.zero;
    return DateTime.now().difference(_startTime!);
  }

  String get elapsedFormatted {
    final d = elapsed;
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  String get startTimeFormatted {
    if (_startTime == null) return '--:-- --';
    final t = _startTime!;
    final hour = t.hour % 12 == 0 ? 12 : t.hour % 12;
    final minute = t.minute.toString().padLeft(2, '0');
    final period = t.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  String get currentClockTime {
    final now = DateTime.now();
    final hour = now.hour % 12 == 0 ? 12 : now.hour % 12;
    final minute = now.minute.toString().padLeft(2, '0');
    final second = now.second.toString().padLeft(2, '0');
    final period = now.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute:$second $period';
  }

  void startLocal() {
    if (_isRunning) return;
    _startTime = DateTime.now();
    _isRunning = true;
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      notifyListeners();
    });
    notifyListeners();
  }

  /// Restores timer state from server — used when app restarts while timer is running.
  /// [serverStartTime] is the DateTime the server recorded as the timer start.
  void restoreFromServer(DateTime serverStartTime) {
    _ticker?.cancel();
    _startTime = serverStartTime;
    _isRunning = true;
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      notifyListeners();
    });
    notifyListeners();
  }

  void stop() {
    _ticker?.cancel();
    _ticker = null;
    _isRunning = false;
    _startTime = null;
    notifyListeners();
  }
}
