import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/theme.dart';
import '../../../../core/constants/auth_manager.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../repositories/check_timer_status_repository.dart';
import '../../repositories/end_timer_repository.dart';
import '../../../../core/widgets/custom_dropdown_field.dart';
import '../../../../core/widgets/custom_input_field.dart';
import '../../../../core/widgets/TopBar.dart';
import 'timer_service.dart';

class RunningTimerScreen extends StatefulWidget {
  final String taskId;
  final String projectId;
  final String taskName;
  final String projectName;

  const RunningTimerScreen({
    super.key,
    required this.taskId,
    required this.projectId,
    required this.taskName,
    required this.projectName,
  });

  @override
  State<RunningTimerScreen> createState() => _RunningTimerScreenState();
}

class _RunningTimerScreenState extends State<RunningTimerScreen> {
  late TextEditingController _userController;
  late TextEditingController _noteController;

  String _selectedType = 'Non-Billable';
  final List<String> _typeOptions = ['Billable', 'Non-Billable'];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    TimerService.instance.addListener(_onTick);

    final firstName = AuthManager.instance.currentUser?.firstName ?? '';
    final lastName = AuthManager.instance.currentUser?.lastName ?? '';
    _userController = TextEditingController(
      text: '$firstName $lastName'.trim(),
    );
    _noteController = TextEditingController();
  }

  @override
  void dispose() {
    TimerService.instance.removeListener(_onTick);
    _userController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _onTick() {
    if (mounted) setState(() {});
  }

  Future<void> _stopTimer() async {
    final timer = TimerService.instance;

    setState(() => _isLoading = true);
    try {
      final userId = AuthManager.instance.currentUser?.id ?? '';

      // Fetch the server-side timer row ID
      final statusResponse = await CheckTimerStatusRepository().checkTimerStatus(userId);
      debugPrint('⏱️ Full status response: $statusResponse');

      final timerId = (statusResponse['TimerId'] ?? '').toString();
      debugPrint('⏱️ Timer ID: $timerId');
      if (timerId.isEmpty) throw Exception('Timer ID not found');
      await EndTimerRepository().endTimer(
        rowId: timerId,
        note: _noteController.text,
        type: _selectedType,
      );

      timer.stop();

      if (mounted) {
        Navigator.pop(context, true);
        showSuccessSnackBar(context, 'Timer stopped successfully');
      }
    } catch (e) {
      debugPrint('❌ Error stopping timer: $e');
      if (mounted) {
        showErrorSnackBar(context, 'Note field cannot be empty!');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).custom;
    final timer = TimerService.instance;
    final today = DateTime.now();

    return Scaffold(
      backgroundColor: customColors.background,
     
      body: SingleChildScrollView(
        
        child: SafeArea(
          child: Column(
            children: [
              TopBar(
            title: '${widget.taskName} - Timer',
            onBack: () => Navigator.of(context).pop(),
            
          ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // User field (read-only)
                    CustomInputField(
                      controller: _userController,
                      labelText: 'User',
                      hintText: 'User name',
                      prefixIcon: Icons.person_outline,
                      enabled: false,
                    ),
                    const SizedBox(height: 20),
              
                    // Date field (read-only, not tappable)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                      decoration: BoxDecoration(
                        color: customColors.cardBackground,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: customColors.inputBorder!, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today_outlined, color: customColors.textSecondary, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Date',
                                  style: TextStyle(
                                    color: customColors.textSecondary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  DateFormat('dd-MM-yyyy').format(today),
                                  style: TextStyle(
                                    color: customColors.textPrimary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
              
                    // Start Time and End Time Row
                    Row(
                      children: [
                        // Start Time (fixed, not tappable)
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                            decoration: BoxDecoration(
                              color: customColors.cardBackground,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: customColors.inputBorder!, width: 1.5),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.access_time_outlined, color: customColors.textSecondary, size: 20),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Start Time',
                                        style: TextStyle(
                                          color: customColors.textSecondary,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      FittedBox(
                                        fit: BoxFit.scaleDown,
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          timer.startTimeFormatted,
                                          style: TextStyle(
                                            color: customColors.textPrimary,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // End Time (live elapsed, not tappable)
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                            decoration: BoxDecoration(
                              color: customColors.cardBackground,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: customColors.inputBorder!, width: 1.5),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.access_time_outlined, color: customColors.primary, size: 20),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'End Time',
                                        style: TextStyle(
                                          color: customColors.textSecondary,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      FittedBox(
                                        fit: BoxFit.scaleDown,
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          timer.currentClockTime,
                                          style: TextStyle(
                                            color: customColors.primary,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
              
                    // Type field
                    CustomDropDownField(
                      hintText: 'Type',
                      labelText: 'Type',
                      prefixIcon: Icons.category_outlined,
                      options: _typeOptions
                          .map((type) => DropdownMenuItem<String>(
                                value: type,
                                child: Text(type),
                              ))
                          .toList(),
                      selectedOption: _selectedType,
                      onChanged: (value) {
                        setState(() => _selectedType = value ?? 'Non-Billable');
                      },
                    ),
                    const SizedBox(height: 20),
              
                    // Note field
                    CustomInputField(
                      controller: _noteController,
                      labelText: 'Note',
                      hintText: 'Add notes...',
                      isMultiline: true,
                      maxLines: 4,
                      minLines: 4,
                      maxLength: 700,
                      prefixIcon: Icons.description_outlined,
                    ),
                    const SizedBox(height: 8),
              
                    // Character count
                    Align(
                      alignment: Alignment.centerRight,
                      child: ValueListenableBuilder<TextEditingValue>(
                        valueListenable: _noteController,
                        builder: (context, value, child) {
                          final remaining = 700 - value.text.length;
                          return Text(
                            '$remaining characters left',
                            style: TextStyle(
                              color: remaining < 100 ? Colors.red : customColors.textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
              
                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: customColors.primary!.withValues(alpha: 0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _stopTimer,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                elevation: 0,
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  : const Text(
                                      'STOP TIMER',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: customColors.error,
                              side: BorderSide(color: customColors.error!, width: 2),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                            child: const Text(
                              'CANCEL',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
