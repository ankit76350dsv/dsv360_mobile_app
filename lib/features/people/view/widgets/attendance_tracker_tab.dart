import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dsv360/core/constants/theme.dart';
import 'package:dsv360/core/network/connectivity_provider.dart';
import 'package:dsv360/core/utils/snackbar_utils.dart';
import 'package:dsv360/core/widgets/custom_date_field.dart';
import 'package:dsv360/core/widgets/custom_dropdown_field.dart';
import 'package:dsv360/core/widgets/global_error.dart';
import 'package:dsv360/core/widgets/global_loader.dart';
import 'package:dsv360/core/widgets/single_button.dart';
import 'package:dsv360/features/people/model/attendance_dashboard.dart';
import 'package:dsv360/features/people/repositories/attendance_dashboard_repository.dart';
import 'package:dsv360/features/people/view/widgets/attendance_tile.dart';
import 'package:dsv360/features/people/viewmodel/attendance_tracker_viewmodel.dart';
import 'package:dsv360/features/users/repositories/users_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class AttendanceTrackerTab extends ConsumerStatefulWidget {
  const AttendanceTrackerTab({super.key});

  @override
  ConsumerState<AttendanceTrackerTab> createState() =>
      _AttendanceTrackerTabState();
}

class _AttendanceTrackerTabState
    extends ConsumerState<AttendanceTrackerTab> {
  Future<void> _pickDate({required bool isStart}) async {
    final tracker = ref.read(attendanceTrackerProvider);
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? tracker.startDate : tracker.endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      if (isStart) {
        ref.read(attendanceTrackerProvider.notifier).pickStartDate(picked);
      } else {
        ref.read(attendanceTrackerProvider.notifier).pickEndDate(picked);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).custom;
    final usersAsync = ref.watch(usersRepositoryProvider);
    final connectivityStatus = ref.watch(checkConnectivityProvider);
    final tracker = ref.watch(attendanceTrackerProvider);

    return connectivityStatus.when(
      loading: () => const GlobalLoader(message: 'Checking connection...'),
      error: (err, stack) => Center(
        child: GlobalError(
          message: 'Failed to check connectivity: Try Again',
          onRetry: () => ref.invalidate(checkConnectivityProvider),
        ),
      ),
      data: (results) {
        if (results.contains(ConnectivityResult.none)) {
          return GlobalError(
            message: 'Please check your internet connection.',
            isNetworkError: true,
            onRetry: () {
              ref.invalidate(checkConnectivityProvider);
            },
          );
        }

        return usersAsync.when(
          loading: () => const GlobalLoader(message: 'Loading users info...'),
          error: (error, stack) => GlobalError(
            message: 'Failed to load users data: Try Again',
            onRetry: () => ref.refresh(usersRepositoryProvider),
          ),
          data: (users) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Attendance Tracker',
                    style: TextStyle(
                      color: customColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),

                  CustomDropDownField(
                    options: users.map((u) {
                      return DropdownMenuItem<String>(
                        value: u.userId,
                        child: Text('${u.firstName} ${u.lastName}'.trim()),
                      );
                    }).toList(),
                    onChanged: users.isEmpty
                        ? (value) {}
                        : (value) => ref
                            .read(attendanceTrackerProvider.notifier)
                            .selectEmployee(value),
                    hintText: 'Select Employee',
                    labelText: 'Select Employee',
                    prefixIcon: Icons.person_outline,
                    searchable: true,
                    searchHintText: 'Search employee',
                  ),
                  const SizedBox(height: 8.0),

                  CustomPickerField(
                    label: 'Start Date',
                    valueText: tracker.startDate == null
                        ? null
                        : DateFormat('dd/MM/yyyy').format(tracker.startDate!),
                    placeholder: 'dd/mm/yyyy',
                    onTap: () => _pickDate(isStart: true),
                  ),
                  const SizedBox(height: 8.0),

                  CustomPickerField(
                    label: 'End Date',
                    valueText: tracker.endDate == null
                        ? null
                        : DateFormat('dd/MM/yyyy').format(tracker.endDate!),
                    placeholder: 'dd/mm/yyyy',
                    onTap: () => _pickDate(isStart: false),
                  ),

                  const SizedBox(height: 10.0),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 0.0),
                    child: SingleButton(
                      loadingKey: 'attendance_tracker',
                      text: 'submit',
                      icon: Icons.assignment_turned_in_sharp,
                      onPressed: () {
                        if (tracker.selectedEmployeeId == null ||
                            tracker.startDate == null ||
                            tracker.endDate == null) {
                          showErrorSnackBar(
                              context, 'Please select employee and dates');
                          return;
                        }

                        if (tracker.startDate!.isAfter(tracker.endDate!)) {
                          showErrorSnackBar(context,
                              'Start date cannot be after end date');
                          return;
                        }

                        ref
                            .read(attendanceTrackerProvider.notifier)
                            .submitQuery(
                              DateFormat('yyyy-MM-dd')
                                  .format(tracker.startDate!),
                              DateFormat('yyyy-MM-dd').format(tracker.endDate!),
                            );
                      },
                    ),
                  ),

                  const SizedBox(height: 16),

                  Expanded(
                    child: (tracker.queryUserId == null ||
                            tracker.queryStartDate == null ||
                            tracker.queryEndDate == null)
                        ? const Center(
                            child: Text(
                              "Select employee and dates to view attendance",
                            ),
                          )
                        : FutureBuilder<AttendanceDashboardResponse>(
                            future: ref
                                .read(attendanceDashboardRepositoryProvider)
                                .fetchAttendanceDashboard(
                                  userId: tracker.queryUserId!,
                                  startDate: tracker.queryStartDate!,
                                  endDate: tracker.queryEndDate!,
                                ),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }

                              if (snapshot.hasError) {
                                return GlobalError(
                                  message:
                                      'Failed to load attendance data: Try Again',
                                  onRetry: () => setState(() {}),
                                );
                              }

                              final response = snapshot.data;
                              if (response == null || response.data.isEmpty) {
                                return const Center(
                                  child: Text("No attendance records found"),
                                );
                              }

                              return RefreshIndicator(
                                onRefresh: () async {
                                  setState(() {});
                                },
                                child: ListView.builder(
                                  itemCount: response.data.length,
                                  itemBuilder: (context, index) {
                                    final detail = response.data[index];
                                    final date =
                                        DateTime.tryParse(detail.dayDate) ??
                                        DateTime.now();
                                    final hasCheckOut =
                                        detail.checkOut.isNotEmpty;

                                    return AttendanceTile(
                                      day: DateFormat('EEE').format(date),
                                      date: DateFormat('d MMM').format(date),
                                      status: hasCheckOut ? "Present" : "P (In)",
                                      statusColor: hasCheckOut
                                          ? Colors.green
                                          : Colors.orange,
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
