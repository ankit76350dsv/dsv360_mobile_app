import 'dart:async';

import 'package:dsv360/core/constants/theme.dart';
import 'package:dsv360/features/sprints/repositories/stop_timer_repository.dart';
import 'package:dsv360/views/widgets/TopBar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StopTimerPage extends ConsumerStatefulWidget {
  final String rowId;
  final DateTime serverStartTime;
  final String taskName;

  const StopTimerPage({
    super.key,
    required this.rowId,
    required this.serverStartTime,
    required this.taskName,
  });

  @override
  ConsumerState<StopTimerPage> createState() => _StopTimerPageState();
}

class _StopTimerPageState extends ConsumerState<StopTimerPage> {
  final _noteController = TextEditingController();
  String _selectedType = 'Non-Billable';
  bool _isLoading = false;

  late Timer _ticker;
  late Duration _elapsed;

  static const List<String> _typeOptions = ['Billable', 'Non-Billable'];

  @override
  void initState() {
    super.initState();
    _elapsed = DateTime.now().difference(widget.serverStartTime);
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _elapsed = DateTime.now().difference(widget.serverStartTime);
      });
    });
  }

  @override
  void dispose() {
    _ticker.cancel();
    _noteController.dispose();
    super.dispose();
  }

  String _formatElapsed(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $period';
  }

  Future<void> _stopTimer() async {
    if (_noteController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add a note before stopping')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ref.read(stopTimerRepositoryProvider).stopTimer(
            rowId: widget.rowId,
            note: _noteController.text.trim(),
            type: _selectedType,
          );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Timer stopped successfully'),
          backgroundColor: Color(0xFF4CAF50),
        ),
      );

      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to stop timer: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).custom;
    final textPrimary = customColors.textPrimary ?? Colors.black;
    final textSecondary = customColors.textSecondary ?? Colors.grey;
    final cardBg = customColors.cardBackground ?? Colors.white;
    final primary = customColors.primary ?? const Color(0xFF1A56DB);
    final inputBorder = customColors.inputBorder ?? Colors.grey.shade300;

    return Scaffold(
      backgroundColor: customColors.background,
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(top: 48, bottom: 8),
            child: TopBar(
              title: 'Stop Timer',
              onBack: () => Navigator.of(context).pop(false),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Elapsed card ──────────────────────────────────────────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        vertical: 28, horizontal: 20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD32F2F).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFD32F2F).withValues(alpha: 0.25),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(
                                color: Color(0xFFD32F2F),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'TIMER RUNNING',
                              style: TextStyle(
                                color: const Color(0xFFD32F2F),
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _formatElapsed(_elapsed),
                          style: TextStyle(
                            color: const Color(0xFFD32F2F),
                            fontSize: 42,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 2,
                            fontFeatures: const [
                              FontFeature.tabularFigures(),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Started at ${_formatTime(widget.serverStartTime)}',
                          style: TextStyle(
                            color: textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Task name ─────────────────────────────────────────────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: inputBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Task',
                          style: TextStyle(
                            color: textSecondary,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.taskName,
                          style: TextStyle(
                            color: textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Type selector ─────────────────────────────────────────
                  Text(
                    'Type',
                    style: TextStyle(
                      color: textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: _typeOptions.map((type) {
                      final isSelected = _selectedType == type;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedType = type),
                          child: Container(
                            margin: EdgeInsets.only(
                              right: type == _typeOptions.first ? 8 : 0,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? primary.withValues(alpha: 0.12)
                                  : cardBg,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSelected ? primary : inputBorder,
                                width: isSelected ? 1.5 : 1,
                              ),
                            ),
                            child: Text(
                              type,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: isSelected ? primary : textSecondary,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // ── Note field ────────────────────────────────────────────
                  Text(
                    'Note *',
                    style: TextStyle(
                      color: textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: inputBorder, width: 1.5),
                    ),
                    child: TextField(
                      controller: _noteController,
                      maxLines: 5,
                      minLines: 4,
                      maxLength: 700,
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        hintText: 'What did you work on?',
                        hintStyle: TextStyle(
                          color: textSecondary.withValues(alpha: 0.6),
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(14),
                        counterStyle: TextStyle(
                          color: textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // ── Stop button ───────────────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _stopTimer,
                      icon: _isLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white),
                              ),
                            )
                          : const Icon(Icons.stop_circle_outlined,
                              color: Colors.white, size: 20),
                      label: Text(
                        _isLoading ? 'Stopping...' : 'STOP TIMER',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD32F2F),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ── Cancel button ─────────────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed:
                          _isLoading ? null : () => Navigator.of(context).pop(false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: textSecondary,
                        side: BorderSide(color: inputBorder),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'KEEP RUNNING',
                        style: TextStyle(
                          color: textSecondary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
