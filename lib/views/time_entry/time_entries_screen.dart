import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/time_entry_model.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../widgets/time_entry_card.dart';
import 'add_time_entry_dialog.dart';

class TimeEntriesScreen extends StatefulWidget {
  final String taskId;
  final String taskName;
  final List<TimeEntry> timeEntries;

  const TimeEntriesScreen({
    super.key,
    required this.taskId,
    required this.taskName,
    required this.timeEntries,
  });

  @override
  State<TimeEntriesScreen> createState() => _TimeEntriesScreenState();
}

class _TimeEntriesScreenState extends State<TimeEntriesScreen> {
  late List<TimeEntry> _allEntries;
  late List<TimeEntry> displayedEntries;
  
  // Filter variables
  DateTime? _fromDate;
  DateTime? _toDate;
  String? _billableFilter; // 'All', 'Billable', 'Non-Billable'

  @override
  void initState() {
    super.initState();
    _allEntries = List.from(widget.timeEntries);
    displayedEntries = List.from(_allEntries);
    _billableFilter = 'All';
  }

  void _applyFilters() {
    setState(() {
      displayedEntries = _allEntries.where((entry) {
        // Date range filter
        if (_fromDate != null) {
          if (entry.date.isBefore(_fromDate!)) return false;
        }
        if (_toDate != null) {
          if (entry.date.isAfter(_toDate!)) return false;
        }

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
    });
  }

  

  

  void _clearFilters() {
    setState(() {
      _fromDate = null;
      _toDate = null;
      _billableFilter = 'All';
      displayedEntries = List.from(_allEntries);
    });
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBackground,
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
            _applyFilters();
          });
          Navigator.pop(context);
        },
        onClear: () {
          setState(() {
            _fromDate = null;
            _toDate = null;
            _billableFilter = 'All';
            displayedEntries = List.from(_allEntries);
          });
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
    showDialog(
      context: context,
      builder: (context) => AddTimeEntryDialog(
        taskId: widget.taskId,
        taskName: widget.taskName,
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
          const SnackBar(
            content: Text('Time entry updated'),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    });
  }

  void _deleteTimeEntry(TimeEntry entry) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text(
          'Delete Time Entry',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          'Are you sure you want to delete this time entry?',
          style: const TextStyle(color: AppColors.textPrimary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.primary),
            ),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                displayedEntries.removeWhere((e) => e.id == entry.id);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Time entry deleted'),
                  backgroundColor: AppColors.error,
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('${widget.taskName} - Time Entries'),
        backgroundColor: AppColors.cardBackground,
      ),
      body: Column(
        children: [
          // Filter Button Section
          Padding(
            padding: const EdgeInsets.only(left: 18.0, top: 14.0, right: 18.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: _showFilterDialog,
                  icon: const Icon(Icons.filter_list),
                  label: const Text('Filters'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
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
                    backgroundColor: AppColors.primary,
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
                          color: AppColors.textSecondary.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No time entries found',
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: AppColors.textSecondary,
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
    final picked = await showDatePicker(
      context: context,
      initialDate: _tempFromDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: _tempToDate ?? DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.primary,
              surface: AppColors.cardBackground,
              onSurface: AppColors.textPrimary,
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
    final picked = await showDatePicker(
      context: context,
      initialDate: _tempToDate ?? DateTime.now(),
      firstDate: _tempFromDate ?? DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.primary,
              surface: AppColors.cardBackground,
              onSurface: AppColors.textPrimary,
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
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.only(
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
                    color: AppColors.textSecondary.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Header
              const Text(
                'Filter by:',
                style: TextStyle(
                  color: AppColors.textPrimary,
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
                        labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600),
                        floatingLabelBehavior: FloatingLabelBehavior.auto,
                        prefixIcon: const Icon(Icons.calendar_today_outlined, color: AppColors.textSecondary, size: 20),
                        filled: true,
                        fillColor: AppColors.inputFill,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: AppColors.inputBorder, width: 1.5),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: AppColors.inputBorder, width: 1.5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                      ),
                      controller: TextEditingController(
                        text: _tempFromDate != null ? DateFormat('dd-MM-yyyy').format(_tempFromDate!) : '',
                      ),
                      style: const TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      readOnly: true,
                      onTap: _selectToDate,
                      decoration: InputDecoration(
                        label: const Text('To'),
                        labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600),
                        floatingLabelBehavior: FloatingLabelBehavior.auto,
                        prefixIcon: const Icon(Icons.calendar_today_outlined, color: AppColors.textSecondary, size: 20),
                        filled: true,
                        fillColor: AppColors.inputFill,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: AppColors.inputBorder, width: 1.5),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: AppColors.inputBorder, width: 1.5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                      ),
                      controller: TextEditingController(
                        text: _tempToDate != null ? DateFormat('dd-MM-yyyy').format(_tempToDate!) : '',
                      ),
                      style: const TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Entry Type Dropdown
              DropdownButtonFormField<String>(
                value: _tempBillableFilter,
                hint: const Text(
                  'Entry Type',
                  style: TextStyle(color: AppColors.textHint),
                ),
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                dropdownColor: AppColors.inputFill,
                decoration: InputDecoration(
                  labelText: 'Entry Type',
                  labelStyle: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  filled: true,
                  fillColor: AppColors.inputFill,
                  prefixIcon: const Icon(Icons.category_outlined, color: AppColors.textSecondary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.inputBorder, width: 1.5),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.inputBorder, width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: Colors.grey[400]!, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'All',
                    child: Text(
                      'All Entries',
                      style: TextStyle(color: AppColors.textPrimary),
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'Billable',
                    child: Text(
                      'Billable Only',
                      style: TextStyle(color: AppColors.primary),
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'Non-Billable',
                    child: Text(
                      'Non-Billable Only',
                      style: TextStyle(color: AppColors.statusPending),
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
                    child: const Text(
                      'Reset All',
                      style: TextStyle(
                        color: AppColors.error,
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
                      backgroundColor: AppColors.primary,
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