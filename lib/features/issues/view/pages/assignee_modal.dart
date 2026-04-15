import 'package:dsv360/core/constants/theme.dart';
import 'package:flutter/material.dart';
// import '../../core/constants/app_colors.dart';

class AssigneeModal extends StatelessWidget {
  final String assignedTo;
  final String owner;

  const AssigneeModal({
    super.key,
    required this.assignedTo,
    required this.owner,
  });

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).custom;

    final count = assignedTo
    .split(',')
    .map((e) => e.trim())
    .where((e) => e.isNotEmpty)
    .length;

    // simple linear scaling
    double initial = (0.25 + count * 0.05).clamp(0.3, 0.5);
    double min = 0.2;
    double max = (0.3 + count * 0.05).clamp(0.3, 0.5);

    return DraggableScrollableSheet(
      initialChildSize: initial,
      minChildSize: min,
      maxChildSize: max,
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
            mainAxisSize: MainAxisSize.min,
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

              // Heading
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Assignee Details',
                    style: TextStyle(
                      color: customColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Assignee List
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    // Assigned To
                    _buildAssigneeCard(
                      icon: Icons.person_outline,
                      label: 'Assigned To',
                      name: assignedTo,
                      color: customColors.primary!,
                      context: context
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAssigneeCard({
    required IconData icon,
    required String label,
    required String name,
    required Color color,
    required BuildContext context
  }) {
    final customColors = Theme.of(context).custom;
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: customColors.inputFill,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: customColors.inputBorder!, width: 1),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: customColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    name.split(',').map((e) => e.trim()).join('\n'),
                    style: TextStyle(
                      color: customColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
