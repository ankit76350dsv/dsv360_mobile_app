import 'package:dsv360/core/constants/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../model/time_entry_model.dart';
import '../../repositories/time_entry_repository.dart';
import '../../providers/time_entry_provider.dart';
import '../widgets/time_entry_card.dart';
import '../../../../core/widgets/TopBar.dart';
import 'add_time_entry_dialog.dart';

class TimeEntriesScreen extends ConsumerStatefulWidget {
  final String taskId;
  final String projectId;
  final String taskName;
  final String projectName;
  final List<TimeEntry> timeEntries;

  const TimeEntriesScreen({
    super.key,
    required this.taskId,
    required this.projectId,
    required this.taskName,
    required this.projectName,
    this.timeEntries = const [],
  });

  @override
  ConsumerState<TimeEntriesScreen> createState() => _TimeEntriesScreenState();
}

class _TimeEntriesScreenState extends ConsumerState<TimeEntriesScreen> {
  late TimeEntryRepository _repository;

  DateTime? _fromDate;
  DateTime? _toDate;
  String? _billableFilter;

  @override
  void initState() {
    super.initState();
    _repository = TimeEntryRepository();
    _billableFilter = 'All';
  }

  void _refreshEntries() {
    if (widget.taskId.isNotEmpty) {
      if (_fromDate != null || _toDate != null) {
        ref.invalidate(timeEntriesByTaskWithDateFilterProvider);
      } else {
        ref.invalidate(timeEntriesByTaskProvider);
      }
    } else {
      if (_fromDate != null || _toDate != null) {
        ref.invalidate(timeEntriesByProjectWithDateFilterProvider);
      } else {
        ref.invalidate(timeEntriesByProjectProvider);
      }
    }
  }

  void _clearFilters() {
    setState(() {
      _fromDate = null;
      _toDate = null;
      _billableFilter = 'All';
    });
  }

  void _showFilterDialog(BuildContext context) {
    final customColors = Theme.of(context).custom;

    showModalBottomSheet(
      context: context,
      backgroundColor: customColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _FilterBottomSheet(
        fromDate: _fromDate,
        toDate: _toDate,
        billableFilter: _billableFilter ?? 'All',
        onApply: (fromDate, toDate, billableFilter) {
          setState(() {
            _fromDate = fromDate;
            _toDate = toDate;
            _billableFilter = billableFilter;
          });
          Navigator.pop(context);
        },
        onClear: () {
          _clearFilters();
          Navigator.pop(context);
        },
      ),
    );
  }

  String _getActiveFilterCount() {
    int count = 0;
    if (_fromDate != null) count++;
    if (_toDate != null) count++;
    if (_billableFilter != 'All') count++;
    return '$count filter${count != 1 ? 's' : ''}';
  }

  void _editTimeEntry(TimeEntry entry) {
    final customColors = Theme.of(context).custom;
    final messenger = ScaffoldMessenger.of(context);
    showDialog(
      context: context,
      builder: (context) => AddTimeEntryDialog(
        taskId: widget.taskId,
        projectId: widget.projectId,
        taskName: widget.taskName,
        projectName: widget.projectName,
        currentUser: entry.user,
        editingEntry: entry,
      ),
    ).then((updatedEntry) {
      if (updatedEntry != null && updatedEntry is TimeEntry) {
        _refreshEntries();
        messenger.showSnackBar(
          SnackBar(
            content: const Text('Time entry updated'),
            backgroundColor: customColors.primary,
          ),
        );
      }
    });
  }

  void _deleteTimeEntry(TimeEntry entry) {
    final customColors = Theme.of(context).custom;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: customColors.cardBackground,
        title: Text(
          'Delete Time Entry',
          style: TextStyle(color: customColors.textPrimary),
        ),
        content: Text(
          'Are you sure you want to delete this time entry?',
          style: TextStyle(color: customColors.textPrimary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: customColors.primary),
            ),
          ),
          TextButton(
            onPressed: () async {
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              Navigator.pop(context);
              try {
                final success = await _repository.deleteTimeEntry(entry.id);
                if (success) {
                  _refreshEntries();
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.white),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Time entry deleted successfully',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                      backgroundColor: customColors.primary,
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 3),
                    ),
                  );
                } else {
                  throw Exception('Failed to delete');
                }
              } catch (e) {
                debugPrint('❌ Error deleting entry: $e');
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.white),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Failed to delete: $e',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    backgroundColor: customColors.error,
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 3),
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: customColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).custom;

    final AsyncValue<List<TimeEntry>> timeEntriesAsync;

    if (widget.taskId.isNotEmpty) {
      if (_fromDate != null || _toDate != null) {
        timeEntriesAsync = ref.watch(timeEntriesByTaskWithDateFilterProvider((
          taskId: widget.taskId,
          userId: null,
          startDate: _fromDate,
          endDate: _toDate,
        )));
      } else {
        timeEntriesAsync = ref.watch(timeEntriesByTaskProvider(widget.taskId));
      }
    } else {
      if (_fromDate != null || _toDate != null) {
        timeEntriesAsync = ref.watch(timeEntriesByProjectWithDateFilterProvider((
          projectId: widget.projectId,
          startDate: _fromDate,
          endDate: _toDate,
        )));
      } else {
        timeEntriesAsync = ref.watch(timeEntriesByProjectProvider(widget.projectId));
      }
    }

    return Scaffold(
      backgroundColor: customColors.background,
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(top: 48, bottom: 12),
            child: TopBar(
              title: '${widget.taskName} - Time Entries',
              onBack: () {
                Navigator.pop(context);
              },
              onInfoTap: () {},
            ),
          ),
          Expanded(
            child: timeEntriesAsync.when(
              data: (entries) {
                final displayedEntries = _billableFilter == 'All'
                    ? entries
                    : entries.where((entry) {
                        if (_billableFilter == 'Billable') return entry.type == 'Billable';
                        if (_billableFilter == 'Non-Billable') return entry.type == 'Non-Billable';
                        return true;
                      }).toList();

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 18.0, top: 14.0, right: 18.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () => _showFilterDialog(context),
                            icon: const Icon(Icons.filter_list),
                            label: const Text('Filters'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: customColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                          if (_fromDate != null || _toDate != null || _billableFilter != 'All')
                            Chip(
                              label: Text(
                                _getActiveFilterCount(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              backgroundColor: customColors.primary,
                              deleteIcon: const Icon(Icons.close, size: 16, color: Colors.white),
                              onDeleted: _clearFilters,
                            ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: displayedEntries.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.schedule_outlined,
                                    size: 64,
                                    color: customColors.textSecondary!.withValues(alpha: 0.5),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No time entries found',
                                    style: TextStyle(
                                      color: customColors.textSecondary,
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: displayedEntries.length,
                              itemBuilder: (context, index) {
                                final entry = displayedEntries[index];
                                return TimeEntryCard(
                                  entry: entry,
                                  onEdit: () => _editTimeEntry(entry),
                                  onDelete: () => _deleteTimeEntry(entry),
                                );
                              },
                            ),
                    ),
                  ],
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, stack) {
                debugPrint('❌ Error loading time entries: $error');
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: customColors.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Failed to load time entries: $error',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: customColors.error,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _refreshEntries,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterBottomSheet extends StatefulWidget {
  final DateTime? fromDate;
  final DateTime? toDate;
  final String billableFilter;
  final Function(DateTime?, DateTime?, String) onApply;
  final VoidCallback onClear;

  const _FilterBottomSheet({
    required this.fromDate,
    required this.toDate,
    required this.billableFilter,
    required this.onApply,
    required this.onClear,
  });

  @override
  State<_FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<_FilterBottomSheet> {
  late DateTime? _tempFromDate;
  late DateTime? _tempToDate;
  late String _tempBillableFilter;

  @override
  void initState() {
    super.initState();
    _tempFromDate = widget.fromDate;
    _tempToDate = widget.toDate;
    _tempBillableFilter = widget.billableFilter;
  }

  void _selectFromDate() async {
    final customColors = Theme.of(context).custom;
    final picked = await showDatePicker(
      context: context,
      initialDate: _tempFromDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: _tempToDate ?? DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: customColors.primary!,
              surface: customColors.cardBackground!,
              onSurface: customColors.textPrimary!,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _tempFromDate = picked;
      });
    }
  }

  void _selectToDate() async {
    final customColors = Theme.of(context).custom;
    final picked = await showDatePicker(
      context: context,
      initialDate: _tempToDate ?? DateTime.now(),
      firstDate: _tempFromDate ?? DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: customColors.primary!,
              surface: customColors.cardBackground!,
              onSurface: customColors.textPrimary!,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _tempToDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).custom;
    return Container(
      decoration: BoxDecoration(
        color: customColors.cardBackground,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: customColors.textSecondary!.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Filter by:',
                style: TextStyle(
                  color: customColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      readOnly: true,
                      onTap: _selectFromDate,
                      decoration: InputDecoration(
                        label: const Text('From'),
                        labelStyle: TextStyle(color: customColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600),
                        floatingLabelBehavior: FloatingLabelBehavior.auto,
                        prefixIcon: Icon(Icons.calendar_today_outlined, color: customColors.textSecondary, size: 20),
                        filled: true,
                        fillColor: customColors.inputFill,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: customColors.inputBorder!, width: 1.5),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: customColors.inputBorder!, width: 1.5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: customColors.primary!, width: 1.5),
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                      ),
                      controller: TextEditingController(
                        text: _tempFromDate != null ? DateFormat('dd-MM-yyyy').format(_tempFromDate!) : '',
                      ),
                      style: TextStyle(color: customColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      readOnly: true,
                      onTap: _selectToDate,
                      decoration: InputDecoration(
                        label: const Text('To'),
                        labelStyle: TextStyle(color: customColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600),
                        floatingLabelBehavior: FloatingLabelBehavior.auto,
                        prefixIcon: Icon(Icons.calendar_today_outlined, color: customColors.textSecondary, size: 20),
                        filled: true,
                        fillColor: customColors.inputFill,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: customColors.inputBorder!, width: 1.5),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: customColors.inputBorder!, width: 1.5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: customColors.primary!, width: 1.5),
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                      ),
                      controller: TextEditingController(
                        text: _tempToDate != null ? DateFormat('dd-MM-yyyy').format(_tempToDate!) : '',
                      ),
                      style: TextStyle(color: customColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              DropdownButtonFormField<String>(
                initialValue: _tempBillableFilter,
                hint: Text(
                  'Entry Type',
                  style: TextStyle(color: customColors.textHint),
                ),
                style: TextStyle(
                  color: customColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                dropdownColor: customColors.inputFill,
                decoration: InputDecoration(
                  labelText: 'Entry Type',
                  labelStyle: TextStyle(
                    color: customColors.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  filled: true,
                  fillColor: customColors.inputFill,
                  prefixIcon: Icon(Icons.category_outlined, color: customColors.textSecondary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: customColors.inputBorder!, width: 1.5),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: customColors.inputBorder!, width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: Colors.grey[400]!, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                ),
                items: [
                  DropdownMenuItem(
                    value: 'All',
                    child: Text(
                      'All Entries',
                      style: TextStyle(color: customColors.textPrimary),
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'Billable',
                    child: Text(
                      'Billable Only',
                      style: TextStyle(color: customColors.primary),
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'Non-Billable',
                    child: Text(
                      'Non-Billable Only',
                      style: TextStyle(color: customColors.statusPending),
                    ),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _tempBillableFilter = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      widget.onClear();
                    },
                    child: Text(
                      'Reset All',
                      style: TextStyle(
                        color: customColors.error,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      widget.onApply(_tempFromDate, _tempToDate, _tempBillableFilter);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: customColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Apply Filters'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
