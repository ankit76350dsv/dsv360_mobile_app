import 'dart:async';
import 'package:dsv360/core/constants/auth_manager.dart';
import 'package:dsv360/core/constants/active_user_repository.dart';
import 'package:dsv360/core/constants/theme.dart';
import 'package:dsv360/core/constants/user_manager.dart';
import 'package:dsv360/core/widgets/global_error.dart';
import 'package:dsv360/core/widgets/global_loader.dart';
import 'package:dsv360/core/widgets/single_button.dart';
import 'package:dsv360/core/widgets/warning_dialogue_box.dart';
import 'package:dsv360/features/dashboard/viewmodel/dashboard_viewmodel.dart';
import 'package:dsv360/features/people/repositories/check_in_repository.dart';
import 'package:dsv360/features/people/repositories/people_summary_repository.dart';
import 'package:dsv360/features/people/repositories/user_check_in_status_repository.dart';
import 'package:dsv360/features/people/model/user_check_in_status.dart';
import 'package:dsv360/features/people/repositories/attendance_dashboard_repository.dart';
import 'package:dsv360/features/people/view/widgets/check_in_elapsed_card.dart';
import 'package:dsv360/features/people/view/widgets/reporting_manager_card.dart';
import 'package:dsv360/features/people/view/widgets/summary_stat_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

class CheckInTab extends ConsumerStatefulWidget {
  const CheckInTab({super.key});

  @override
  ConsumerState<CheckInTab> createState() => _CheckInTabState();
}

class _CheckInTabState extends ConsumerState<CheckInTab> {
  Timer? _timer;
  Duration _elapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    _startTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshPageData();
    });
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  Future<void> _refreshPageData() async {
    try {
      final _ = await ref.refresh(userStatusRepositoryProvider.future);
      final _ = await ref.refresh(peopleSummaryProvider.future);
    } catch (e) {
      debugPrint('Error refreshing data: $e');
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('SERVICES_DISABLED');
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('PERMISSION_DENIED');
      }
      if (permission == LocationPermission.deniedForever) {
        throw Exception('PERMISSION_DENIED_FOREVER');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('PERMISSION_DENIED_FOREVER');
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        timeLimit: const Duration(seconds: 10),
      );
      return position;
    } catch (e) {
      throw Exception('LOCATION_FETCH_FAILED');
    }
  }

  Future<void> _showLocationWarning(String errorCode) async {
    String title = 'Location Error';
    String subtitle = 'Unable to get location. Please try again.';

    if (errorCode == 'SERVICES_DISABLED') {
      title = 'Location Services Disabled';
      subtitle =
          'Please enable location services on your device settings to check in/out.';
    } else if (errorCode == 'PERMISSION_DENIED') {
      title = 'Location Permission Required';
      subtitle =
          'Location permission is required for check in/out. Please allow when prompted.';
    } else if (errorCode == 'PERMISSION_DENIED_FOREVER') {
      title = 'Location Permission Denied';
      subtitle =
          'Enable location permission in app settings to use check in/out feature.';
    } else if (errorCode == 'LOCATION_FETCH_FAILED') {
      title = 'Unable to Get Location';
      subtitle = 'Could not retrieve your location. Please try again.';
    }

    if (!mounted) return;

    await showWarningDialogueBox(
      context: context,
      title: title,
      subtitle: subtitle,
      primaryText: errorCode == 'PERMISSION_DENIED_FOREVER' ||
              errorCode == 'SERVICES_DISABLED'
          ? 'Open Settings'
          : 'Try Again',
      onPrimaryPressed: (dialogContext) {
        Navigator.of(dialogContext).pop();
        if (errorCode == 'PERMISSION_DENIED_FOREVER' ||
            errorCode == 'SERVICES_DISABLED') {
          Geolocator.openLocationSettings();
        }
      },
    );
  }

  String _extractErrorCode(String errorMessage) {
    if (errorMessage.contains('SERVICES_DISABLED')) return 'SERVICES_DISABLED';
    if (errorMessage.contains('PERMISSION_DENIED_FOREVER'))
      return 'PERMISSION_DENIED_FOREVER';
    if (errorMessage.contains('PERMISSION_DENIED')) return 'PERMISSION_DENIED';
    if (errorMessage.contains('LOCATION_FETCH_FAILED'))
      return 'LOCATION_FETCH_FAILED';
    return 'UNKNOWN_ERROR';
  }

  Future<void> _handleAction({
    required String userId,
    required String username,
    UserCheckInStatus? activeStatus,
  }) async {
    final loadingNotifier = ref.read(
      singleButtonLoadingProvider('checkInCheckOutButton').notifier,
    );
    loadingNotifier.state = true;

    try {
      final now = DateTime.now();
      final dayDate = DateFormat('yyyy-MM-dd').format(now);

      Position position;
      try {
        position = await _determinePosition();
      } catch (e) {
        if (mounted) {
          _showLocationWarning(_extractErrorCode(e.toString()));
        }
        return;
      }

      final lat = position.latitude;
      final long = position.longitude;
      final checkInRepo = ref.read(checkInRepositoryProvider.notifier);

      if (activeStatus == null || !activeStatus.isCheckIn) {
        await checkInRepo.checkIn(
          userId: userId,
          username: username,
          device: 'test-phone',
          lat: lat,
          long: long,
          dayDate: dayDate,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Successfully checked in!'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        await checkInRepo.checkOut(
          device: 'test-phone',
          lat: lat,
          long: long,
          checkInTimestamp:
              activeStatus.checkInTime?.millisecondsSinceEpoch ?? 0,
          rowId: activeStatus.rowId ?? '',
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Successfully checked out!'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }

      ref.invalidate(userStatusRepositoryProvider);
      ref.invalidate(attendanceDashboardRepositoryProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
      debugPrint('Check-in/out error: $e');
    } finally {
      loadingNotifier.state = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final summaryAsync = ref.watch(peopleSummaryProvider);
    final activeUser = ref.watch(activeUserRepositoryProvider);
    final userId = activeUser?.userId ?? '';

    final userProfile = UserManager.instance.userProfile;
    final empId = userProfile?.empId ?? '';
    final reporterName = userProfile?.reporterName ?? '';
    final reporterImage = userProfile?.reporterImage ?? '';

    final user = AuthManager.instance.currentUser;
    final role = user?.role?.name;

    debugPrint(role);

    final dashboardAsync = ref.watch(dashboardDataProvider);
    var totalEmployees = 0;
    dashboardAsync.whenData((dashboard) {
      totalEmployees = dashboard.userCnt;
    });

    if (userId.isEmpty) {
      return const GlobalLoader(message: 'Loading user info...');
    }

    final userStatusAsync = ref.watch(userStatusRepositoryProvider);
    debugPrint("userStatusAsync: $userStatusAsync");
    final isApplePlatform =
        Theme.of(context).platform == TargetPlatform.iOS ||
        Theme.of(context).platform == TargetPlatform.macOS;

    return RefreshIndicator(
      onRefresh: () async {
        final _ = await ref.refresh(userStatusRepositoryProvider.future);
        final _ = await ref.refresh(peopleSummaryProvider.future);
      },
      child: ColoredBox(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: userStatusAsync.when(
          loading: () =>
              const GlobalLoader(message: 'Loading Check In/Out status...'),
          error: (error, stack) => GlobalError(
            message: 'Failed to load Check In/Out status: Try Again',
            onRetry: () => ref.invalidate(userStatusRepositoryProvider),
          ),
          data: (status) {
            final isCheckedIn = status.isCheckIn;
            _elapsed = (isCheckedIn && status.checkInTime != null)
                ? DateTime.now().difference(status.checkInTime!)
                : Duration.zero;

            return LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: isApplePlatform
                      ? const ClampingScrollPhysics(
                          parent: AlwaysScrollableScrollPhysics(),
                        )
                      : const AlwaysScrollableScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        "${activeUser?.firstName ?? ''} ${activeUser?.lastName ?? ''}"
                                            .trim(),
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context).custom.primary,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      empId.isNotEmpty
                                          ? "EMP-ID: $empId"
                                          : "EMP-ID: --",
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Theme.of(context)
                                            .custom
                                            .textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                                if (!isCheckedIn)
                                  Container(
                                    margin: const EdgeInsets.only(top: 12),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color.fromARGB(
                                        57,
                                        255,
                                        105,
                                        59,
                                      ).withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(40),
                                      border: Border.all(
                                        color: Colors.red.shade700,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.access_time,
                                          color: Colors.red.shade800,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          "Yet to check-in",
                                          style: TextStyle(
                                            color: Colors.red.shade900,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),

                          CheckInElapsedCard(
                            elapsed: _elapsed,
                            isCheckedIn: isCheckedIn,
                          ),

                          const SizedBox(height: 16.0),
                          SingleButton(
                            loadingKey: 'checkInCheckOutButton',
                            text: isCheckedIn ? 'CHECK OUT' : 'CHECK IN NOW',
                            onPressed: () => _handleAction(
                              userId: userId,
                              username:
                                  "${activeUser?.firstName ?? ''} ${activeUser?.lastName ?? ''}"
                                      .trim(),
                              activeStatus: status,
                            ),
                            icon: isCheckedIn ? Icons.logout : Icons.login,
                          ),

                          if (role != 'Admin')
                            ReportingManagerCard(
                              reporterName: reporterName,
                              reporterImage: reporterImage,
                            ),

                          const SizedBox(height: 20),

                          if (role == 'Admin')
                            summaryAsync.when(
                              loading: () => const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                child: CircularProgressIndicator(),
                              ),
                              error: (_, __) => Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: GlobalError(
                                  message: 'Failed to load summary: Try Again',
                                  onRetry: () =>
                                      ref.invalidate(peopleSummaryProvider),
                                ),
                              ),
                              data: (summary) {
                                final totalLeave =
                                    (summary['total_leave'] as num?)?.toInt() ??
                                    0;
                                final totalPresent =
                                    (summary['total_present'] as num?)
                                        ?.toInt() ??
                                    0;
                                final unpaid =
                                    (summary['unpaid'] as num?)?.toInt() ?? 0;
                                final employees = totalEmployees;
                                final progress = unpaid == 0
                                    ? 0.0
                                    : (unpaid / totalLeave);

                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 12),
                                      Column(
                                        children: [
                                          Text(
                                            "Summary",
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: Theme.of(context)
                                                  .custom
                                                  .textPrimary,
                                              fontSize: 17,
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                        ],
                                      ),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: SummaryStatItem(
                                              title: "Total Leaves",
                                              value: "$totalLeave",
                                              employees:
                                                  "$employees Employees",
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Container(
                                            height: 90,
                                            width: 90,
                                            decoration: BoxDecoration(
                                              color: Theme.of(context)
                                                  .custom
                                                  .surfaceBackground,
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              border: Border.all(
                                                color: Theme.of(context)
                                                    .custom
                                                    .greyBorder!,
                                              ),
                                            ),
                                            child: Stack(
                                              alignment: Alignment.center,
                                              children: [
                                                SizedBox(
                                                  height: 60,
                                                  width: 60,
                                                  child:
                                                      CircularProgressIndicator(
                                                        value: progress,
                                                        strokeWidth: 6,
                                                        backgroundColor:
                                                            Theme.of(context)
                                                                .custom
                                                                .greyBorder,
                                                        valueColor:
                                                            AlwaysStoppedAnimation(
                                                              Theme.of(context)
                                                                  .custom
                                                                  .primary,
                                                            ),
                                                      ),
                                                ),
                                                Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      "$totalLeave",
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 14,
                                                        color: Theme.of(context)
                                                            .custom
                                                            .textPrimary,
                                                      ),
                                                    ),
                                                    Text(
                                                      "Total",
                                                      style: TextStyle(
                                                        fontSize: 10,
                                                        color: Theme.of(context)
                                                            .custom
                                                            .textSecondary,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: SummaryStatItem(
                                              title: "Total CheckIn",
                                              value: "$totalPresent",
                                              employees:
                                                  "$employees Employees",
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: SummaryStatItem(
                                              title: "Leave Without Pay",
                                              value: "$unpaid",
                                              employees:
                                                  "$employees Employees",
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 40),
                                    ],
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
