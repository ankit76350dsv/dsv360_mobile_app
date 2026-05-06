import 'dart:convert';

import 'package:dsv360/core/constants/auth_manager.dart';
import 'package:dsv360/core/constants/theme.dart';
import 'package:dsv360/features/time_entry/repositories/time_entry_history_repository.dart';
import 'package:dsv360/core/widgets/TopBar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


// ─── Model ────────────────────────────────────────────────────────────────────
class _RequestEntry {
  final String rowId;
  final String status;
  final String username;
  final String projectName;
  final String taskName;
  final List<Map<String, dynamic>> reasons;
  final DateTime createdTime;
  final List<Map<String, dynamic>> entries;

  _RequestEntry({
    required this.rowId,
    required this.status,
    required this.username,
    required this.projectName,
    required this.taskName,
    required this.reasons,
    required this.createdTime,
    required this.entries,
  });

  String get shortId => 'REQ-${rowId.length >= 4 ? rowId.substring(rowId.length - 4) : rowId}';

  factory _RequestEntry.fromMap(Map<String, dynamic> map) {
    DateTime parseCreated(String s) {
      try {
        final normalized = s
            .replaceAll(' ', 'T')
            .replaceRange(s.lastIndexOf(':'), s.lastIndexOf(':') + 1, '.');
        return DateTime.parse(normalized);
      } catch (_) {
        return DateTime.now();
      }
    }

    List<Map<String, dynamic>> parseReasons(dynamic raw) {
  if (raw == null) return [];

  final str = raw.toString().trim();
  if (str.isEmpty) return [];

  try {
    if (str.startsWith('[') || str.startsWith('{')) {
      final decoded = jsonDecode(str);

      if (decoded is List) {
        return decoded
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }

      if (decoded is Map) {
        return [Map<String, dynamic>.from(decoded)];
      }
    }

    // fallback → plain string (no structured data)
    return [
      {'reason': str}
    ];
  } catch (e) {
    return [
      {'reason': str}
    ];
  }
}

    List<Map<String, dynamic>> parseEntries(String raw) {
      try {
        final decoded = jsonDecode(raw) as List;
        return decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      } catch (_) {
        return [];
      }
    }

    return _RequestEntry(
      rowId: map['ROWID']?.toString() ?? '',
      status: map['Status']?.toString() ?? 'Pending',
      username: map['Username']?.toString() ?? '',
      projectName: map['Project_Name']?.toString() ?? '',
      taskName: map['Task_Name']?.toString() ?? '',
      reasons: parseReasons(map['Reason']),
      createdTime: parseCreated(map['CREATEDTIME']?.toString() ?? ''),
      entries: parseEntries(map['Timeentry_Data']?.toString() ?? '[]'),
    );
  }
}

// ─── Page ─────────────────────────────────────────────────────────────────────
class TimeEntryHistory extends StatefulWidget {
  const TimeEntryHistory({super.key});

  @override
  State<TimeEntryHistory> createState() => _TimeEntryHistoryState();
}

class _TimeEntryHistoryState extends State<TimeEntryHistory> {
  final TimeEntryHistoryRepository _repository = TimeEntryHistoryRepository();

List<_RequestEntry> _requests = [];
bool isLoading = true;
  final Set<int> _expanded = {};

  @override
void initState() {
  super.initState();
  fetchHistory();
}
final userId = AuthManager.instance.currentUser?.id ?? '';

Future<void> fetchHistory() async {
  try {
    final response = await _repository.timeEntryHistory(userId); // your userId

    // 🔴 IMPORTANT: print once to check structure
    debugPrint("API RESPONSE: $response",wrapWidth: 2000);

    final List list = response['data'] is List ? response['data'] : [];// adjust if key is different

    setState(() {
      final parsed = list.map((e) => _RequestEntry.fromMap(e)).toList();

// 🔥 Sort by newest first
parsed.sort((a, b) => b.createdTime.compareTo(a.createdTime));

setState(() {
  _requests = parsed;
  isLoading = false;
});
      isLoading = false;
    });

  } catch (e) {
    debugPrint("Error: $e");
    setState(() {
      isLoading = false;
    });
  }
}

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).custom;

    return Scaffold(
      backgroundColor: c.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(120),
        child: Padding(
          padding: const EdgeInsets.only(top: 48),
          child: TopBar(
            title: "History",
            onBack: () => Navigator.of(context).pop(),
            

            
          ),
        ),
      ),
      body: isLoading
    ? const Center(child: CircularProgressIndicator())
    : _requests.isEmpty
        ? RefreshIndicator(
            onRefresh: fetchHistory,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.7,
                  child: _EmptyState(c: c),
                ),
              ],
            ),
          )
        : RefreshIndicator(
            onRefresh: fetchHistory,
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: _requests.length,
              itemBuilder: (ctx, i) => _RequestCard(
                request: _requests[i],
                isExpanded: _expanded.contains(i),
                onToggle: () => setState(() {
                  if (_expanded.contains(i)) {
                    _expanded.remove(i);
                  } else {
                    _expanded.add(i);
                  }
                }),
                c: c,
              ),
            ),
          ),
    );
  }
}

// ─── Card ─────────────────────────────────────────────────────────────────────
class _RequestCard extends StatelessWidget {
  final _RequestEntry request;
  final bool isExpanded;
  final VoidCallback onToggle;
  final dynamic c;

  const _RequestCard({
    required this.request,
    required this.isExpanded,
    required this.onToggle,
    required this.c,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: c.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.05),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      margin: const EdgeInsets.only(bottom: 26),
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          // ── Header ──────────────────────────────────────────────────────
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Row 1: ID + Status + chevron
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // ID
                      Text(
                        request.shortId,
                        style: TextStyle(
                          color: c.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Status tag
                      _StatusTag(status: request.status), //bookmark tag
                      const Spacer(),
                      // Entries count badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 9, vertical: 3),
                        decoration: BoxDecoration(
                          color: c.textPrimary!.withOpacity(0.08), 
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Entries: ${request.entries.length}',
                          style: TextStyle(
                            color: c.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Chevron
                      AnimatedRotation(
                        turns: isExpanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOut,
                        child: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: c.textSecondary,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Row 2: project / task + date/time
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Project & Task
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.folder_outlined,
                                    size: 16, color: c.textSecondary),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    "Project: ${request.projectName}",
                                    style: TextStyle(
                                      color: c.textSecondary,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(Icons.task_alt_outlined,
                                    size: 16, color: c.textSecondary),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    request.taskName,
                                    style: TextStyle(
                                      color: c.textSecondary,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Date & time
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            DateFormat('dd MMM yyyy')
                                .format(request.createdTime),
                            style: TextStyle(
                              color: c.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            DateFormat('hh:mm a').format(request.createdTime),
                            style: TextStyle(
                              color: c.textSecondary,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Reason (only if rejected and has reason)
                  if (request.status.toLowerCase() == "rejected" && request.reasons.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                      
                        const SizedBox(width: 6),
                        Expanded(
                          child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.07),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.withOpacity(0.25), width: 1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: request.reasons.map((r) {
                          final reasonText = r['reason']?.toString() ?? '';
                          final start = r['Start_time'] ?? '';
                          final end = r['End_time'] ?? '';
                          final date = r['Entry_Date'] ?? '';
                    
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Reason text
                                
                                Text(
                                  "Rejected Reason: $reasonText",
                                  style: const TextStyle(
                                                  color: Colors.red,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                  ),
                                ),
                    
                                // 👇 Overlap time info
                                if (start != '' && end != '') ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    "Overlap: $date | $start → $end",
                                    style: const TextStyle(
                                      color: Colors.redAccent,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    )
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),

          // ── Expanded entries ─────────────────────────────────────────────
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity),
            secondChild: request.entries.isEmpty
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                    child: Text(
                      'No entry data available.',
                      style: TextStyle(
                          color: c.textSecondary, fontSize: 14),
                    ),
                  )
                : Column(
                    children: [
                      Divider(
                        height: 1,
                        thickness: 1,
                        color: c.inputBorder,
                      ),
                      ...request.entries.asMap().entries.map((e) {
                        final idx = e.key;
                        final entry = e.value;
                        final isLast =
                            idx == request.entries.length - 1;
                        return _EntryRow(
                          index: idx + 1,
                          entry: entry,
                          isLast: isLast,
                          c: c,
                        );
                      }),
                    ],
                  ),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
            sizeCurve: Curves.easeInOut,
          ),
        ],
      ),
    );
  }
}

// ─── Individual entry row inside expanded card ────────────────────────────────
class _EntryRow extends StatelessWidget {
  final int index;
  final Map<String, dynamic> entry;
  final bool isLast;
  final dynamic c;

  const _EntryRow({
    required this.index,
    required this.entry,
    required this.isLast,
    required this.c,
  });

  @override
  Widget build(BuildContext context) {
    final isBillable = (entry['Type']?.toString() ?? '') == 'Billable';

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(color: c.inputBorder!, width: 1.2),
              ),
      ),
      child: Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date + Type tag row
            Row(
              children: [
                Icon(Icons.calendar_today_outlined,
                    size: 13, color: c.textSecondary),
                const SizedBox(width: 4),
                Text(
                  _formatEntryDate(entry['Entry_Date']?.toString() ?? ''),
                  style: TextStyle(
                    color: c.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: isBillable
                        ? Colors.green.withOpacity(0.1)
                        : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    entry['Type']?.toString() ?? '',
                    style: TextStyle(
                      color: c.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
      
            // Start → End time
            Row(
              children: [
                Icon(Icons.access_time_outlined,
                    size: 13, color: c.textSecondary),
                const SizedBox(width: 4),
                Text(
                  '${entry['Start_time'] ?? ''} → ${entry['End_time'] ?? ''}',
                  style: TextStyle(
                    color: c.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _formatDuration(entry['Total_time']),
                  style: TextStyle(
                    color: c.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
      
            // Task + Project
            Row(
              children: [
                Expanded(
                  child: _InfoChip(
                    icon: Icons.task_alt_outlined,
                    label: entry['Task_Name']?.toString() ?? '',
                    c: c,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _InfoChip(
                    icon: Icons.folder_outlined,
                    label: entry['Project_Name']?.toString() ?? '',
                    c: c,
                  ),
                ),
              ],
            ),
      
            // Note
            if ((entry['Note']?.toString() ?? '').isNotEmpty) ...[
              const SizedBox(height: 6),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.description_outlined,
                      size: 13, color: c.textSecondary),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                     entry['Note'] != null && entry['Note'].toString().isNotEmpty
            ? "Note: ${entry['Note']}"
            : '',
                      style: TextStyle(
                        color: c.textSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatEntryDate(String raw) {
    try {
      final dt = DateFormat('yyyy-MM-dd').parse(raw);
      return DateFormat('dd MMM yyyy').format(dt);
    } catch (_) {
      return raw;
    }
  }

  String _formatDuration(dynamic minutes) {
    final mins = int.tryParse(minutes?.toString() ?? '') ?? 0;
    final h = mins ~/ 60;
    final m = mins % 60;
    if (h == 0) return '${m}m';
    if (m == 0) return '${h}h';
    return '${h}h ${m}m';
  }
}

// ─── Small chip for task / project label ──────────────────────────────────────
class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final dynamic c;

  const _InfoChip(
      {required this.icon, required this.label, required this.c});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: c.inputBorder!.withOpacity(0.4),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: c.textSecondary),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                color: c.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Status tag ───────────────────────────────────────────────────────────────
class _StatusTag extends StatelessWidget {
  final String status;

  const _StatusTag({required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    IconData icon;

    switch (status.toLowerCase()) {
      case 'accepted':
        bg = Colors.green.withOpacity(0.12);
        fg = Colors.green[700]!;
        icon = Icons.check_circle_outline_rounded;
        break;
      case 'rejected':
        bg = Colors.red.withOpacity(0.12);
        fg = Colors.red[700]!;
        icon = Icons.cancel_outlined;
        break;
      default: // pending
        bg = Colors.orange.withOpacity(0.12);
        fg = Colors.orange[800]!;
        icon = Icons.schedule_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: fg),
          const SizedBox(width: 4),
          Text(
            status,
            style: TextStyle(
              color: fg,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Empty state ──────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final dynamic c;

  const _EmptyState({required this.c});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_rounded, size: 64, color: c.textHint),
          const SizedBox(height: 16),
          Text(
            'No time entry requests yet',
            style: TextStyle(
              color: c.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Your submitted requests will appear here.',
            style: TextStyle(color: c.textSecondary, fontSize: 14),
          ),
        ],
      ),
    );
  }
}