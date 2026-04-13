import 'package:dsv360/core/constants/theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../model/time_entry_model.dart';
import '../../repositories/time_entry_repository.dart';
import '../widgets/time_entry_card.dart';
import '../../../../views/widgets/TopBar.dart';
import 'add_time_entry_dialog.dart';

class TimeEntriesScreen extends StatefulWidget {
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
  State<TimeEntriesScreen> createState() => _TimeEntriesScreenState();
}

class _TimeEntriesScreenState extends State<TimeEntriesScreen> {
  late List<TimeEntry> _allEntries;
  late List<TimeEntry> displayedEntries;
  late TimeEntryRepository _repository;
  bool _isLoading = true;
  String? _error;
  
  // Filter variables
  DateTime? _fromDate;
  DateTime? _toDate;
  String? _billableFilter; // 'All', 'Billable', 'Non-Billable'

  @override
  void initState() {
    super.initState();
    _repository = TimeEntryRepository();
    _allEntries = List.from(widget.timeEntries);
    displayedEntries = List.from(_allEntries);
    _billableFilter = 'All';
    _fetchTimeEntries();
  }

  Future<void> _fetchTimeEntries() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      
      debugPrint('🔍 Fetching time entries for projectId: ${widget.projectId}');
      final entries = await _repository.getTimeEntriesByProject(widget.projectId);
      
      setState(() {
        _allEntries = entries;
        displayedEntries = List.from(_allEntries);
        _isLoading = false;
      });
      
      debugPrint('✅ Fetched ${entries.length} time entries');
    } catch (e) {
      debugPrint('❌ Error fetching time entries: $e');
      setState(() {
        _error = 'Failed to load time entries: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _applyFilters() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // If date filters are applied, fetch from API with date parameters
      if (_fromDate != null || _toDate != null) {
        debugPrint('🔍 Fetching time entries with date filter - from: $_fromDate to: $_toDate');
        final entries = await _repository.getTimeEntriesByProjectWithDateFilter(
          projectId: widget.projectId,
          startDate: _fromDate,
          endDate: _toDate,
        );
        
        debugPrint('✅ Fetched ${entries.length} time entries with date filter');
        _allEntries = entries;
      }
      
      // Apply billable filter client-side
      setState(() {
        displayedEntries = _allEntries.where((entry) {
          // Billable filter
          if (_billableFilter != 'All') {
            if (_billableFilter == 'Billable' && entry.type != 'Billable') {
              return false;
            }
            if (_billableFilter == 'Non-Billable' && entry.type != 'Non-Billable') {
              return false;
            }
          }
          return true;
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('❌ Error applying filters: $e');
      setState(() {
        _error = 'Failed to apply filters: $e';
        _isLoading = false;
      });
    }
  }

  

  

  void _clearFilters() {
    setState(() {
      _fromDate = null;
      _toDate = null;
      _billableFilter = 'All';
    });
    // Fetch all entries (without date filter)
    _fetchTimeEntries();
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
        onApply: (fromDate, toDate, billableFilter) async {
          setState(() {
            _fromDate = fromDate;
            _toDate = toDate;
            _billableFilter = billableFilter;
          });
          await _applyFilters();
          if (mounted) {
            Navigator.pop(context);
          }
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
        setState(() {
          final index = _allEntries.indexWhere((e) => e.id == entry.id);
          if (index != -1) {
            _allEntries[index] = updatedEntry;
          }
          _applyFilters();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Time entry updated'),
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
              // Capture the scaffold messenger before popping dialog
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              Navigator.pop(context);
              try {
                final success = await _repository.deleteTimeEntry(entry.id);
                if (success) {
                  setState(() {
                    _allEntries.removeWhere((e) => e.id == entry.id);
                    _applyFilters();
                  });
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.white),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Time entry deleted successfully',
                              style: const TextStyle(color: Colors.white),
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
                        Icon(Icons.error_outline, color: Colors.white),
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
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).custom;
    return Scaffold(
      backgroundColor: customColors.background,
      body: Column(
        children: [
          // Header with TopBar
          Container(
            padding: const EdgeInsets.only(top: 48, bottom: 12),
            child: TopBar(
              title: '${widget.taskName} - Time Entries',
              onBack: () {
                Navigator.pop(context);
              },
              onInfoTap: () {
                // Info tap action
              },
            ),
          ),
          // Body Content
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : _error != null
                    ? Center(
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
                              _error!,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: customColors.error,
                                fontSize: 18, // bodyLarge equivalent
                              ),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: _fetchTimeEntries,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : Column(
                        children: [
                    // Filter Button Section
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

                    // Time Entries List
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
                                      fontSize: 18, // bodyLarge equivalent
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
              // Drag handle
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

              // Header
              Text(
                'Filter by:',
                style: TextStyle(
                  color: customColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),

              // From and To Date in Row
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

              // Entry Type Dropdown
              DropdownButtonFormField<String>(
                value: _tempBillableFilter,
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

              // Buttons
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