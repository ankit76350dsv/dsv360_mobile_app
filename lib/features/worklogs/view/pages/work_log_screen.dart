import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dsv360/core/constants/app_colors.dart';
import 'package:dsv360/core/constants/theme.dart';
import 'package:dsv360/core/network/connectivity_provider.dart';
import 'package:dsv360/core/widgets/dsv_loader.dart';
import 'package:dsv360/core/widgets/global_error.dart';
import 'package:dsv360/core/widgets/global_loader.dart';
import 'package:dsv360/features/dashboard/view/pages/AppDrawer.dart';
import 'package:dsv360/features/worklogs/model/worklog_model.dart';
import 'package:dsv360/features/worklogs/viewmodel/worklogs_viewmodel.dart';
import 'package:dsv360/repositories/active_user_repository.dart';
import 'package:dsv360/views/widgets/TopBar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';


class WorkLogScreen extends ConsumerStatefulWidget {
  const WorkLogScreen({super.key});

  @override
  ConsumerState<WorkLogScreen> createState() => _WorkLogScreenState();
}

class _WorkLogScreenState extends ConsumerState<WorkLogScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  DateTime _fromDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _toDate = DateTime.now();

  List<WorklogDaySummary>? _data;
  bool _loading = true;
 
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _formatDateParam(DateTime date) => DateFormat('yyyy-MM-dd').format(date);

  String _formatDateLabel(DateTime date) => DateFormat('MM/dd/yyyy').format(date);

  String _formatDayHeader(String dateStr) {
    try {
      final dt = DateFormat('yyyy-MM-dd').parse(dateStr);
      final dayName = DateFormat('EEEE').format(dt);
      final datePart = DateFormat('MMM d, yyyy').format(dt);
      return '$dayName, $datePart';
    } catch (_) {
      return dateStr;
    }
  }

  Future<void> _loadData({bool isRefresh = false}) async {
  final activeUser = ref.read(activeUserRepositoryProvider);
  final userId = activeUser?.userId ?? '';

  if (userId.isEmpty) {
    setState(() {
      _error = 'User not found';
    });
    return;
  }

  setState(() {
    if (isRefresh) {
   
    } else {
      _loading = true;
    }
    _error = null;
  });

  try {
    final vm = ref.read(worklogsViewModelProvider);
    final result = await vm.fetchTimeline(
      userId: userId,
      startDate: _formatDateParam(_fromDate),
      endDate: _formatDateParam(_toDate),
    );

    if (mounted) {
      setState(() {
        _data = result;
        _loading = false;
   
      });
    }
  } catch (e) {
    if (mounted) {
      setState(() {
        _error = e.toString();
        _loading = false;
      
      });
    }
  }
}

  Future<void> _pickFromDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fromDate,
      firstDate: DateTime(2020),
      lastDate: _toDate,
    );
    if (picked != null && picked != _fromDate) {
      setState(() => _fromDate = picked);
      await _loadData();
    }
  }

  Future<void> _pickToDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _toDate,
      firstDate: _fromDate,
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _toDate) {
      setState(() => _toDate = picked);
      await _loadData();
    }
  }

  List<WorklogDaySummary> get _filtered {
    final data = _data ?? [];
    if (_searchQuery.isEmpty) return data;
    final q = _searchQuery.toLowerCase();
    return data
        .map((day) {
          final matched = day.entries.where((e) {
            return e.task.toLowerCase().contains(q) ||
                e.project.toLowerCase().contains(q) ||
                e.description.toLowerCase().contains(q);
          }).toList();
          if (matched.isEmpty) return null;
          return WorklogDaySummary(
            date: day.date,
            totalHours: day.totalHours,
            entries: matched,
          );
        })
        .whereType<WorklogDaySummary>()
        .toList();
  }

  int get _activeSessions {
    return (_data ?? []).length;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeController.themeMode,
      builder: (context, mode, _) {
        final customColors = Theme.of(context).custom;
        final isDark = mode == ThemeMode.dark;

        final background = customColors.background ??
            (isDark ? AppColorsDark.background : AppColorsLight.background);
        final cardBg = customColors.cardBackground ??
            (isDark ? AppColorsDark.cardBackground : AppColorsLight.cardBackground);
        final textPrimary = customColors.textPrimary ??
            (isDark ? AppColorsDark.textPrimary : AppColorsLight.textPrimary);
        final textSecondary = customColors.textSecondary ??
            (isDark ? AppColorsDark.textSecondary : AppColorsLight.textSecondary);
        final greyBorder = customColors.greyBorder ??
            (isDark ? AppColorsDark.greyBorder : AppColorsLight.greyBorder);
        final primary = customColors.primary ?? const Color(0xFF004da7);
        final surfaceBg = customColors.surfaceBackground ??
            (isDark ? AppColorsDark.surfaceBackground : AppColorsLight.surfaceBackground);

        final connectivityStatus = ref.watch(connectivityStatusProvider);

        return Scaffold(
          drawer: const AppDrawer(),
          backgroundColor: background,
          body: SafeArea(
            child: connectivityStatus.when(
              data: (results) {
                if (results.contains(ConnectivityResult.none)) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TopBar(
                        title: 'Work Logs',
                        onBack: () {
                          if (Navigator.canPop(context)) Navigator.pop(context);
                        },
                      ),
                      Expanded(
                        child: GlobalError(
                          message: 'Please check your internet connection.',
                          isNetworkError: true,
                          onRetry: () => ref.invalidate(connectivityStatusProvider),
                        ),
                      ),
                    ],
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TopBar(
                      title: 'Work Logs',
                      onBack: () {
                        if (Navigator.canPop(context)) Navigator.pop(context);
                      },
                      onInfoTap: _loadData,
                      actionIcon: Icons.refresh_rounded,
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                      child: _buildSearchBar(surfaceBg, textSecondary),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                      child: _buildTimelineAndAddRow(primary, textSecondary),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                      child: _buildDateRangeRow(
                        context, cardBg, greyBorder, textPrimary, textSecondary,
                      ),
                    ),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () => _loadData(isRefresh: true),
                        child: _buildScrollContent(
                          cardBg, textPrimary, textSecondary, greyBorder, primary, isDark,
                        ),
                      ),
                    ),
                  ],
                );
              },
              error: (error, stack) => GlobalError(
                message: 'Failed to check connectivity: $error',
                onRetry: () => ref.invalidate(connectivityStatusProvider),
              ),
              loading: () => const GlobalLoader(message: 'Checking connection...'),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchBar(Color surfaceBg, Color textSecondary) {
    return TextField(
      controller: _searchController,
      onChanged: (value) => setState(() => _searchQuery = value.trim()),
      decoration: InputDecoration(
        hintText: 'Search logs',
        hintStyle: const TextStyle(
          color: Colors.grey,
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
        filled: true,
        fillColor: surfaceBg,
        prefixIcon: const Icon(Icons.search, color: Colors.grey),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(200),
          borderSide: BorderSide(
            color: Colors.grey.withValues(alpha: 0.2),
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(200),
          borderSide: BorderSide(
            color: Colors.grey.withValues(alpha: 0.2),
            width: 1.5,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 2),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: Colors.grey.withValues(alpha: 0.2),
            width: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildDateRangeRow(
    BuildContext context, Color cardBg, Color greyBorder,
    Color textPrimary, Color textSecondary,
  ) {
    return Row(
      children: [
        _buildDateChip(
          context,
          label: 'from',
          date: _formatDateLabel(_fromDate),
          cardBg: cardBg,
          greyBorder: greyBorder,
          textPrimary: textPrimary,
          textSecondary: textSecondary,
          onTap: () => _pickFromDate(context),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Icon(Icons.arrow_forward, size: 16, color: textSecondary),
        ),
        _buildDateChip(
          context,
          label: 'to',
          date: _formatDateLabel(_toDate),
          cardBg: cardBg,
          greyBorder: greyBorder,
          textPrimary: textPrimary,
          textSecondary: textSecondary,
          onTap: () => _pickToDate(context),
        ),
      ],
    );
  }

  Widget _buildTimelineAndAddRow(Color primary, Color textSecondary) {
    return Row(
      children: [
        Icon(Icons.calendar_month_outlined, size: 15, color: textSecondary),
        const SizedBox(width: 6),
        Text(
          'Timeline',
          style: TextStyle(fontSize: 12, color: textSecondary),
        ),
        const SizedBox(width: 4),
        Text('— ', style: TextStyle(fontSize: 12, color: textSecondary)),
        Text(
          '$_activeSessions active sessions',
          style: TextStyle(
            fontSize: 12,
            color: primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: _loadData,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              '+ Add Log',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScrollContent(
    Color cardBg, Color textPrimary, Color textSecondary,
    Color greyBorder, Color primary, bool isDark,
  ) {
    if (_loading && _data == null) {
      return const Center(child: DsvLoader());
    }
    if (_error != null) {
      return Center(
        child: Text('Error: $_error', style: TextStyle(color: textSecondary)),
      );
    }
    if (!_loading && (_data == null || _filtered.isEmpty)) {
  return Center(
    child: Text('No work logs found', style: TextStyle(color: textSecondary)),
  );
}
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      itemCount: _filtered.length,
      itemBuilder: (context, index) {
        final day = _filtered[index];
        return Padding(
          padding: const EdgeInsets.only(top: 2),
          child: _buildDayGroup(
            day, cardBg, textPrimary, textSecondary, greyBorder, primary, isDark,
          ),
        );
      },
    );
  }

  Widget _buildDateChip(
    BuildContext context, {
    required String label,
    required String date,
    required Color cardBg,
    required Color greyBorder,
    required Color textPrimary,
    required Color textSecondary,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: greyBorder, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: TextStyle(fontSize: 9, color: textSecondary)),
            SizedBox(width: 8,),
            
            Text(
              date,
              style: TextStyle(
                fontSize: 11,
                color: textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayGroup(
    WorklogDaySummary day, Color cardBg, Color textPrimary,
    Color textSecondary, Color greyBorder, Color primary, bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDayHeader(day, textSecondary, isDark),
        const SizedBox(height: 8),
        ...day.entries.map((entry) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _buildEntryCard(
            entry, cardBg, textPrimary, textSecondary, greyBorder, primary,
          ),
        )),
      ],
    );
  }

  Widget _buildDayHeader(
    WorklogDaySummary day, Color textSecondary, bool isDark,
  ) {
    return Column(
      children: [
        SizedBox(height: 6,),
        Row(
          children: [
            Icon(Icons.calendar_view_day_outlined, size: 20, color: textSecondary),
            const SizedBox(width: 6),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatDayHeader(day.date),
                  style: TextStyle(
                    fontSize: 12,
                    color: textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Daily Activity Summary',
                  style: TextStyle(fontSize: 10, color: textSecondary),
                ),
              ],
            ),
            const Spacer(),
            Text('Total Effort', style: TextStyle(fontSize: 11, color: textSecondary)),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.black,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '${day.totalHours}:00',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEntryCard(
    WorklogEntry entry, Color cardBg, Color textPrimary,
    Color textSecondary, Color greyBorder, Color primary,
  ) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black.withValues(alpha: 0.4),
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      color: cardBg,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Task label + name
            Text(
              'Task Name',
              style: TextStyle(fontSize: 10, color: textSecondary),
            ),
            const SizedBox(height: 2),
            Text(
              entry.task,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            // Project label + name + badge
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Project',
                        style: TextStyle(fontSize: 10, color: textSecondary),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        entry.project,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildSourceBadge(entry.sourceType, primary),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _buildTimeBox('Start Time', entry.start, textPrimary, textSecondary, greyBorder),
                const SizedBox(width: 8),
                _buildTimeBox('End Time', entry.end, textPrimary, textSecondary, greyBorder),
                const SizedBox(width: 8),
                _buildTotalTimeBox(entry.hours, textPrimary, textSecondary, greyBorder),
              ],
            ),
            if (entry.description.isNotEmpty) ...[
              const SizedBox(height: 10),
              _buildNoteBox(entry.description, textPrimary, textSecondary, greyBorder),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSourceBadge(String sourceType, Color primary) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: primary,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        _sourceTypeLabel(sourceType),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _sourceTypeLabel(String sourceType) {
    switch (sourceType.toUpperCase()) {
      case 'SPRINT_TASK':
        return 'Sprint Task';
      case 'SPRINT_SUBTASK':
        return 'Sprint Subtask';
      case 'DIRECT':
        return 'Direct';
      default:
        return sourceType;
    }
  }

  Widget _buildTimeBox(
    String label, String value, Color textPrimary,
    Color textSecondary, Color greyBorder,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: greyBorder.withValues(alpha: 0.4), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: textPrimary,
              ),
            ),
            Text(label, style: TextStyle(fontSize: 10, color: textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalTimeBox(
    String hours, Color textPrimary, Color textSecondary, Color greyBorder,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: greyBorder.withValues(alpha: 0.4), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _parseHours(hours),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: textPrimary,
              ),
            ),
            Text('Total Time', style: TextStyle(fontSize: 10, color: textSecondary)),
          ],
        ),
      ),
    );
  }

  String _parseHours(String time) {
  try {
    final parts = time.split(':');

    int h = 0, m = 0, s = 0;

    if (parts.length >= 1) h = int.parse(parts[0]);
    if (parts.length >= 2) m = int.parse(parts[1]);
    if (parts.length >= 3) s = int.parse(parts[2]);

    final hh = h.toString().padLeft(2, '0');
    final mm = m.toString().padLeft(2, '0');
    final ss = s.toString().padLeft(2, '0');

    return '$hh:$mm:$ss';
  } catch (_) {
    return '00:00:00';
  }
}

  Widget _buildNoteBox(
    String note, Color textPrimary, Color textSecondary, Color greyBorder,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: greyBorder.withValues(alpha: 0.4), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
              'Note',
              style: TextStyle(fontSize: 10, color: textSecondary),
            ),
          const SizedBox(height: 4),
          Text(note, style: TextStyle(fontSize: 13, color: textPrimary)),
        ],
      ),
    );
  }
}
