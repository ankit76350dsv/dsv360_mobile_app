import 'dart:async';

import 'package:dsv360/core/constants/theme.dart';
import 'package:dsv360/core/utils/snackbar_utils.dart';
import 'package:dsv360/features/sprints/viewmodel/timer_viewmodel.dart';
import 'package:dsv360/core/widgets/TopBar.dart';
import 'package:dsv360/core/widgets/custom_dropdown_field.dart';
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
      
      showErrorSnackBar(context, 'Please add a note before stopping');
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

      showSuccessSnackBar(context, 'Timer stopped successfully');

      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      showErrorSnackBar(context, 'Failed to stop timer. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).custom;
    final textPrimary = customColors.textPrimary ?? Colors.black;
    final textSecondary = customColors.textSecondary ?? Colors.grey;
    final cardBg = customColors.cardBackground ?? Colors.white;
    final inputBorder = customColors.inputBorder ?? Colors.grey.shade300;

    return Scaffold(
      backgroundColor: customColors.background,
      body: SafeArea(
        child: Column(
          children: [
            
             
              TopBar(
                title: 'Stop Timer',
                onBack: () => Navigator.of(context).pop(false),
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
        
                    // ── Type selector ───────────────────────────────
                    CustomDropDownField(
                      hintText: 'Type',
                      labelText: 'Type',
                      prefixIcon: Icons.category_outlined,
                      options: _typeOptions
                          .map(
                            (type) => DropdownMenuItem<String>(
                              value: type,
                              child: Text(type),
                            ),
                          )
                          .toList(),
                      selectedOption: _selectedType,
                      onChanged: (value) {
                        if (value != null) setState(() => _selectedType = value);
                      },
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
        
        
        
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      
                      children: [
                          // ── Stop button ───────────────────────────────────────────
                    Expanded(
                      
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
                            borderRadius: BorderRadius.circular(100),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
        
                    // ── Cancel button ─────────────────────────────────────────
                    Expanded(
                   
                      child: OutlinedButton(
                        onPressed:
                            _isLoading ? null : () => Navigator.of(context).pop(false),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: textSecondary,
                          side: BorderSide(color: inputBorder),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
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
                    ],),
        
                    
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
