import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dsv360/core/constants/app_colors.dart';
import 'package:dsv360/core/constants/theme.dart';
import 'package:dsv360/features/teams/viewmodel/teams_viewmodel.dart';
import 'package:dsv360/features/teams/view/widgets/responsive_scale_helper.dart';
import 'package:dsv360/features/teams/view/widgets/empty_drop_zone.dart';
import 'package:dsv360/features/teams/view/widgets/employee_card.dart';
import 'package:dsv360/features/teams/view/widgets/icon_button.dart';
import 'package:dsv360/features/teams/view/widgets/search_field.dart';

// ╔══════════════════════════════════════════════════════════════╗
// ║               TEAM BOARD COMPONENT                           ║
// ╚══════════════════════════════════════════════════════════════╝

class TeamBoard extends StatefulWidget {
  final Team team;
  final List<Employee> employees;
  final void Function(
    Employee employee,
    String? targetTeamId,
    String? targetTeamName,
  ) onEmployeeDropped;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final ResponsiveScale rs;
  final bool isDeleting;

  const TeamBoard({
    super.key,
    required this.team,
    required this.employees,
    required this.onEmployeeDropped,
    required this.onEdit,
    required this.onDelete,
    required this.rs,
    this.isDeleting = false,
  });

  @override
  State<TeamBoard> createState() => _TeamBoardState();
}

class _TeamBoardState extends State<TeamBoard> {
  String _searchQuery = '';
  bool _isDragOver = false;

  List<Employee> get _filtered {
    if (_searchQuery.trim().isEmpty) return widget.employees;
    final q = _searchQuery.toLowerCase();
    return widget.employees
        .where((e) =>
            e.name.toLowerCase().contains(q) || e.phone.contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final rs = widget.rs;
    final customColors = Theme.of(context).custom;
    final isDark = themeController.themeMode.value == ThemeMode.dark;
    final boardBg = customColors.cardBackground ??
        (isDark ? AppColorsDark.cardBackground : AppColorsLight.cardBackground);
    final boardDropBg = isDark
        ? (customColors.primary ?? const Color(0xFF2563EB))
            .withValues(alpha: 0.16)
        : const Color(0xFFF0F6FF);
    final boardBorder = customColors.greyBorder ??
        (isDark ? AppColorsDark.greyBorder : AppColorsLight.greyBorder);

    return DragTarget<Employee>(
      onWillAccept: (data) {
        if (data == null || data.teamId == widget.team.id) return false;
        HapticFeedback.selectionClick();
        setState(() => _isDragOver = true);
        return true;
      },
      onLeave: (_) => setState(() => _isDragOver = false),
      onAccept: (employee) {
        HapticFeedback.mediumImpact();
        setState(() => _isDragOver = false);
        widget.onEmployeeDropped(employee, widget.team.id, widget.team.name);
      },
      builder: (context, candidateData, rejectedData) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          width: rs.s(265),
          margin: EdgeInsets.only(right: rs.s(12)),
          decoration: BoxDecoration(
            color: _isDragOver ? boardDropBg : boardBg,
            borderRadius: rs.radius(16),
            border: Border.all(
              color: _isDragOver ? const Color(0xFF2563EB) : boardBorder,
              width: _isDragOver ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.055),
                blurRadius: rs.s(10),
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header row ──
              Padding(
                padding:
                    rs.insets(const EdgeInsets.fromLTRB(14, 13, 10, 0)),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.team.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: rs.f(15),
                              color: customColors.textPrimary ??
                                  (isDark
                                      ? AppColorsDark.textPrimary
                                      : AppColorsLight.textPrimary),
                            ),
                          ),
                          SizedBox(height: rs.s(2)),
                          Text(
                            '${widget.employees.length} members',
                            style: TextStyle(
                              fontSize: rs.f(12.5),
                              color: customColors.textSecondary ??
                                  (isDark
                                      ? AppColorsDark.textSecondary
                                      : AppColorsLight.textSecondary),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: rs.s(6)),
                    IconBtn(
                      icon: Icons.edit,
                      iconColor: customColors.primary ??
                          const Color(0xFF2563EB),
                      bgColor: (customColors.primary ??
                              const Color(0xFF2563EB))
                          .withValues(alpha: 0.14),
                      onTap: widget.onEdit,
                      rs: rs,
                    ),
                    SizedBox(width: rs.s(6)),
                    IconBtn(
                      icon: Icons.delete,
                      iconColor: customColors.error ??
                          const Color(0xFFDC2626),
                      bgColor: (customColors.error ??
                              const Color(0xFFDC2626))
                          .withValues(alpha: 0.16),
                      onTap: widget.onDelete,
                      rs: rs,
                      isLoading: widget.isDeleting,
                    ),
                  ],
                ),
              ),
              SizedBox(height: rs.s(10)),

              // ── Search bar ──
              Padding(
                padding: rs.sym(h: 10),
                child: SearchField(
                  hintText: 'Search ${widget.team.name}',
                  onChanged: (v) => setState(() => _searchQuery = v),
                  rs: rs,
                ),
              ),
              SizedBox(height: rs.s(8)),

              // ── Employee list / Empty zone ──
              Expanded(
                child: Padding(
                  padding: rs.sym(h: 10),
                  child: _filtered.isEmpty
                      ? EmptyDropZone(rs: rs)
                      : ListView.builder(
                          itemCount: _filtered.length,
                          itemBuilder: (context, index) =>
                              EmployeeCard(
                                employee: _filtered[index],
                                rs: rs,
                              ),
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
