import 'package:dsv360/core/constants/theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../models/issue_model.dart';

class IssueDetailsModalSheet extends StatefulWidget {
  final IssueModel issue;

  const IssueDetailsModalSheet({super.key, required this.issue});

  @override
  State<IssueDetailsModalSheet> createState() => _IssueDetailsModalSheetState();
}

class _IssueDetailsModalSheetState extends State<IssueDetailsModalSheet> {
  Color _getStatusColor(String status, CustomColors custom) {
    switch (status) {
      case 'Open':
        return custom.statusPending!;
      case 'In Progress':
        return custom.statusInProgress!;
      case 'Resolved':
        return custom.statusCompleted!;
      case 'Closed':
        return custom.textSecondary!;
      case 'On Hold':
        return custom.error!;
      default:
        return custom.textSecondary!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final custom = Theme.of(context).custom;

    return Container(
      constraints: BoxConstraints(maxHeight: screenHeight * 0.75),
      child: Card(
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
                    color: custom.textSecondary!.withOpacity(0.3),
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
                  'Issue Details',
                  style: TextStyle(
                    color: custom.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    // Row 1: Issue ID and Issue Name
                    Row(
                      children: [
                        Expanded(
                          child: _buildDetailCard(
                            icon: Icons.info_outline,
                            label: 'Issue ID',
                            value:
                                "I${widget.issue.id.length <= 4 ? widget.issue.id : widget.issue.id.substring(widget.issue.id.length - 4, widget.issue.id.length)}",
                            context: context,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildDetailCard(
                            icon: Icons.bug_report_outlined,
                            label: 'Issue Name',
                            value: widget.issue.issueName,
                            context: context,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Row 2: Project Name and Assignee
                    Row(
                      children: [
                        Expanded(
                          child: _buildDetailCard(
                            icon: Icons.folder,
                            label: 'Project Name',
                            value: widget.issue.projectName ?? 'N/A',
                            context: context,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildDetailCard(
                            icon: Icons.person,
                            label: 'Assignee',
                            value: widget.issue.assignedTo ?? 'Not assigned',
                            context: context,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Row 3: Reporter and Severity
                    Row(
                      children: [
                        Expanded(
                          child: _buildDetailCard(
                            icon: Icons.info_rounded,
                            label: 'Reporter',
                            value: widget.issue.owner ?? 'N/A',
                            context: context,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildDetailCard(
                            icon: Icons.warning_outlined,
                            label: 'Severity',
                            value: widget.issue.priority,
                            context: context,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Row 4: Due Date and Status
                    Row(
                      children: [
                        Expanded(
                          child: _buildDetailCard(
                            icon: Icons.calendar_today,
                            label: 'Due Date',
                            value: widget.issue.dueDate != null
                                ? DateFormat(
                                    'yyyy-MM-dd',
                                  ).format(widget.issue.dueDate!)
                                : 'Not set',
                            context: context,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatusCard(
                            label: 'Status',
                            value: widget.issue.status,
                            color: _getStatusColor(widget.issue.status, custom),
                            context: context,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Description (Full width at last)
                    _buildDetailCard(
                      icon: Icons.description_outlined,
                      label: 'Description',
                      value: widget.issue.description ?? 'N/A',
                      context: context,
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard({
    required IconData icon,
    required String label,
    required String value,
    required BuildContext context,
  }) {
    final customColors = Theme.of(context).custom;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: customColors.cardBackground!,
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: customColors.primary, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: customColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            label == "Assignee"
                ? value.split(',').map((e) => e.trim()).join('\n')
                : value,
            style: TextStyle(
              color: customColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
            maxLines: label == "Assignee" ? null : 1,
            overflow: label == "Assignee"
                ? TextOverflow.visible
                : TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard({
    required String label,
    required String value,
    required Color color,
    required BuildContext context,
  }) {
    final customColors = Theme.of(context).custom;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: customColors.cardBackground!,
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Wrap(
        children: [
          Icon(Icons.check_circle, color: customColors.primary, size: 18),
          const SizedBox(width: 8),
          Column(
            children: [
              Text(
                label,
                maxLines: 1,
                style: TextStyle(
                  color: customColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 5),
            ],
          ),
          SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),

            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
