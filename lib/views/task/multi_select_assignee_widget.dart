import 'package:dsv360/core/constants/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/teams/model/employee_model.dart';
import '../../providers/employee_provider.dart';

class MultiSelectAssigneeWidget extends ConsumerStatefulWidget {
  final List<Employee> selectedEmployees;
  final ValueChanged<List<Employee>> onSelectionChanged;

  const MultiSelectAssigneeWidget({
    super.key,
    required this.selectedEmployees,
    required this.onSelectionChanged,
  });

  @override
  ConsumerState<MultiSelectAssigneeWidget> createState() =>
      _MultiSelectAssigneeWidgetState();
}

class _MultiSelectAssigneeWidgetState
    extends ConsumerState<MultiSelectAssigneeWidget> {
  late List<Employee> _selectedEmployees;

  @override
  void initState() {
    super.initState();
    _selectedEmployees = List.from(widget.selectedEmployees);
  }

  @override
  Widget build(BuildContext context) {
    final employeesAsync = ref.watch(employeeListProvider);
    final customColors = Theme.of(context).custom;

    return employeesAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(16),
        child: CircularProgressIndicator(),
      ),
      error: (error, st) => Padding(
        padding: const EdgeInsets.all(16),
        child: Text('Error loading employees: $error'),
      ),
      data: (employees) {
        // Filter out inactive employees
        final activeEmployees =
            employees.where((e) => e.status == 'ACTIVE').toList();

        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.85,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: customColors.cardBackground,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  // Drag handle
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: customColors.textSecondary!.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Select Assignees',
                          style: TextStyle(
                            color: customColors.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${_selectedEmployees.length} selected',
                          style: TextStyle(
                            color: customColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Employee List
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: activeEmployees.length,
                      itemBuilder: (context, index) {
                        final employee = activeEmployees[index];
                        final isSelected = _selectedEmployees
                            .any((e) => e.userId == employee.userId);

                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? customColors.primary!.withOpacity(0.1)
                                : customColors.inputFill,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? customColors.primary!
                                  : customColors.inputBorder!,
                              width: 1.5,
                            ),
                          ),
                          child: CheckboxListTile(
                            value: isSelected,
                            onChanged: (value) {
                              setState(() {
                                if (value == true) {
                                  _selectedEmployees.add(employee);
                                } else {
                                  _selectedEmployees.removeWhere(
                                      (e) => e.userId == employee.userId);
                                }
                              });
                            },
                            activeColor: customColors.primary,
                            checkColor: Colors.white,
                            title: Text(
                              employee.fullName,
                              style: TextStyle(
                                color: customColors.textPrimary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            subtitle: Text(
                              employee.emailId,
                              style: TextStyle(
                                color: customColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Action Buttons
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: customColors.textPrimary,
                              side: BorderSide(
                                color: customColors.inputBorder!,
                              ),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Text('Cancel'),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              widget.onSelectionChanged(_selectedEmployees);
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: customColors.primary,
                            ),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Text(
                                'Done',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ],
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
