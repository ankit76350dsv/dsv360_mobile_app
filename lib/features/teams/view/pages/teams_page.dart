import 'dart:math';
import 'package:dsv360/core/constants/app_colors.dart';
import 'package:dsv360/core/constants/theme.dart';
import 'package:dsv360/core/widgets/warning_dialogue_box.dart';
import 'package:dsv360/features/teams/view/pages/add_edit_team.dart';
import 'package:dsv360/features/teams/providers/teams_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dsv360/views/widgets/TopBar.dart';
import 'package:dsv360/views/dashboard/AppDrawer.dart';
import 'package:dsv360/features/teams/providers/batch_profile_provider.dart';

// ╔══════════════════════════════════════════════════════════════╗
// ║              RESPONSIVE SCALE HELPER                        ║
// ║  Base design width = 390 (iPhone 14/15 logical pixels).     ║
// ║  On narrower devices, everything scales proportionally      ║
// ║  but never below 0.72 to stay readable.                     ║
// ╚══════════════════════════════════════════════════════════════╝

class _RS {
  static const double _baseWidth = 390.0;
  static const double _minScale = 0.72;
  static const double _maxScale = 1.0;

  final double scale;

  _RS(double deviceWidth)
      : scale = (deviceWidth / _baseWidth).clamp(_minScale, _maxScale);

  /// Scale a layout dimension
  double s(double v) => v * scale;

  /// Scale a font size (same ratio, already clamped via constructor)
  double f(double v) => v * scale;

  /// Scale an EdgeInsets
  EdgeInsets insets(EdgeInsets e) => EdgeInsets.fromLTRB(
        e.left * scale,
        e.top * scale,
        e.right * scale,
        e.bottom * scale,
      );

  /// Symmetric EdgeInsets shorthand
  EdgeInsets sym({double h = 0, double v = 0}) =>
      EdgeInsets.symmetric(horizontal: h * scale, vertical: v * scale);

  /// Scaled BorderRadius
  BorderRadius radius(double r) => BorderRadius.circular(r * scale);
}

// ╔══════════════════════════════════════════════════════════════╗
// ║                      DATA MODELS                            ║
// ╚══════════════════════════════════════════════════════════════╝

class Employee {
  final String id;
  final String name;
  final String phone;
  final String? profileImageUrl;
  String? teamId; // null = unassigned

  Employee({
    required this.id,
    required this.name,
    required this.phone,
    this.profileImageUrl,
    this.teamId,
  });
}

class Team {
  final String id;
  String name;
  final String? reportingManagerId;
  final String? reportingManager;

  Team({
    required this.id,
    required this.name,
    this.reportingManagerId,
    this.reportingManager,
  });
}

// ╔══════════════════════════════════════════════════════════════╗
// ║               DASHED BORDER PAINTER                         ║
// ╚══════════════════════════════════════════════════════════════╝

class _DashedBorderPainter extends CustomPainter {
  final Color color;

  const _DashedBorderPainter({
    this.color = const Color(0xFFCCCCCC),
  });

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 1.5;
    const dashWidth = 7.0;
    const dashGap = 5.0;
    const radius = 12.0;

    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(strokeWidth / 2, strokeWidth / 2,
            size.width - strokeWidth, size.height - strokeWidth),
        Radius.circular(radius),
      ));

    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final start = metric.getTangentForOffset(distance)?.position;
        final end = metric
            .getTangentForOffset(min(distance + dashWidth, metric.length))
            ?.position;
        if (start != null && end != null) {
          canvas.drawLine(start, end, paint);
        }
        distance += dashWidth + dashGap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) =>
      oldDelegate.color != color;
}

// ╔══════════════════════════════════════════════════════════════╗
// ║               EMPTY DROP ZONE COMPONENT                     ║
// ╚══════════════════════════════════════════════════════════════╝

class EmptyDropZone extends StatelessWidget {
  final _RS rs;
  const EmptyDropZone({super.key, required this.rs});

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).custom;
    final isDark = themeController.themeMode.value == ThemeMode.dark;
    final borderColor = customColors.inputBorder ??
      (isDark ? AppColorsDark.inputBorder : AppColorsLight.inputBorder);
    final textColor = customColors.textHint ??
      (isDark ? AppColorsDark.textHint : AppColorsLight.textHint);

    return Padding(
      padding: rs.sym(v: 8),
      child: CustomPaint(
        painter: _DashedBorderPainter(color: borderColor),
        child: SizedBox(
          height: rs.s(100),
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.open_with_rounded,
                  color: textColor, size: rs.s(22)),
              SizedBox(height: rs.s(6)),
              Text(
                'Drag and Drop here',
                style: TextStyle(
                  color: textColor,
                  fontSize: rs.f(12.5),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ╔══════════════════════════════════════════════════════════════╗
// ║               EMPLOYEE CARD COMPONENT                       ║
// ╚══════════════════════════════════════════════════════════════╝

class EmployeeCard extends StatelessWidget {
  final Employee employee;
  final bool isGrid;
  final _RS rs;

  const EmployeeCard({
    super.key,
    required this.employee,
    required this.rs,
    this.isGrid = false,
  });

  Widget _buildAvatarImage(double avatarRadius) {
    final imageUrl = employee.profileImageUrl?.trim();

    if (imageUrl != null && imageUrl.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          imageUrl,
          width: avatarRadius * 2,
          height: avatarRadius * 2,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Image.asset(
              'assets/images/profile.jpg',
              width: avatarRadius * 2,
              height: avatarRadius * 2,
              fit: BoxFit.cover,
            );
          },
        ),
      );
    }

    return ClipOval(
      child: Image.asset(
        'assets/images/profile.jpg',
        width: avatarRadius * 2,
        height: avatarRadius * 2,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _cardContent(BuildContext context, {double? width, bool elevated = false}) {
    final customColors = Theme.of(context).custom;
    final isDark = themeController.themeMode.value == ThemeMode.dark;
    final avatarRadius = rs.s(isGrid ? 15.0 : 19.0);
    final hPad = rs.s(isGrid ? 8.0 : 12.0);
    final vPad = rs.s(isGrid ? 3: 10.0);

    return Container(
      width: width,
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
      decoration: BoxDecoration(
        color: customColors.surfaceBackground ??
            customColors.cardBackground ??
            (isDark ? AppColorsDark.surfaceBackground : AppColorsLight.surfaceBackground),
        borderRadius: rs.radius(12),
        border: Border.all(
          color: customColors.greyBorder ??
              (isDark ? AppColorsDark.greyBorder : AppColorsLight.greyBorder),
          width: 1,
        ),
        boxShadow: elevated
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: rs.s(12),
                  offset: const Offset(0, 4),
                )
              ]
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: rs.s(4),
                  offset: const Offset(0, 1),
                )
              ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Profile avatar
          CircleAvatar(
            radius: avatarRadius,
            backgroundColor: customColors.avatarBackground ??
                (isDark ? const Color.fromARGB(255, 96, 96, 96) : const Color.fromARGB(255, 164, 164, 164)),
            child: _buildAvatarImage(avatarRadius),
          ),
          SizedBox(width: rs.s(isGrid ? 6.0 : 10.0)),
          // Name + phone
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  employee.name,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: rs.f(isGrid ? 11.5 : 13.5),
                    color: customColors.textPrimary ??
                        (isDark ? AppColorsDark.textPrimary : AppColorsLight.textPrimary),
                    letterSpacing: -0.1,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                SizedBox(height: rs.s(1)),
                Text(
                  employee.phone,
                  style: TextStyle(
                    fontSize: rs.f(isGrid ? 9.5 : 11.0),
                    color: customColors.textSecondary ??
                        (isDark ? AppColorsDark.textSecondary : AppColorsLight.textSecondary),
                    fontWeight: FontWeight.w400,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),
          // Drag handle — omitted in grid to save horizontal space
          if (!isGrid)
            Padding(
              padding: EdgeInsets.only(left: rs.s(6)),
              child: Icon(
                Icons.drag_indicator_rounded,
                color: customColors.textHint ??
                    (isDark ? AppColorsDark.textHint : AppColorsLight.textHint),
                size: rs.s(20),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool didPulseDuringDrag = false;

    return LongPressDraggable<Employee>(
      data: employee,
      delay: const Duration(milliseconds: 300),
      hapticFeedbackOnStart: true,
      onDragStarted: () {
        didPulseDuringDrag = false;
        HapticFeedback.heavyImpact();
        HapticFeedback.vibrate();
      },
      onDragUpdate: (_) {
        if (!didPulseDuringDrag) {
          didPulseDuringDrag = true;
          HapticFeedback.mediumImpact();
        }
      },
      onDragEnd: (_) {
        HapticFeedback.lightImpact();
      },
      onDraggableCanceled: (_, __) {
        HapticFeedback.mediumImpact();
      },
      feedback: Material(
        color: Colors.transparent,
        child: _cardContent(context, width: rs.s(250), elevated: true),
      ),
      childWhenDragging: Opacity(
        opacity: 0.25,
        child: _cardContent(context),
      ),
      child: Padding(
        // Grid spacing is handled by gridDelegate; list needs explicit gap
        padding: EdgeInsets.only(bottom: isGrid ? 0 : rs.s(8)),
        child: _cardContent(context),
      ),
    );
  }
}

// ╔══════════════════════════════════════════════════════════════╗
// ║               TEAM BOARD COMPONENT                           ║
// ╚══════════════════════════════════════════════════════════════╝

class TeamBoard extends StatefulWidget {
  final Team team;
  final List<Employee> employees;
  final void Function(Employee employee, String targetTeamId) onEmployeeDropped;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final _RS rs;
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
        ? (customColors.primary ?? const Color(0xFF2563EB)).withValues(alpha: 0.16)
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
        widget.onEmployeeDropped(employee, widget.team.id);
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
              color: _isDragOver
                  ? const Color(0xFF2563EB)
                  : boardBorder,
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
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: rs.f(14.5),
                              color: customColors.textPrimary ??
                                  (isDark ? AppColorsDark.textPrimary : AppColorsLight.textPrimary),
                              letterSpacing: -0.2,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: rs.s(2)),
                          Text(
                            '${widget.employees.length} Members',
                            style: TextStyle(
                              fontSize: rs.f(11),
                              color: customColors.textSecondary ??
                                  (isDark ? AppColorsDark.textSecondary : AppColorsLight.textSecondary),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: rs.s(6)),
                    _IconBtn(
                      icon: Icons.edit,
                      iconColor: customColors.primary ?? const Color(0xFF2563EB),
                      bgColor: (customColors.primary ?? const Color(0xFF2563EB)).withValues(alpha: 0.14),
                      onTap: widget.onEdit,
                      rs: rs,
                    ),
                    SizedBox(width: rs.s(6)),
                    _IconBtn(
                      icon: Icons.delete,
                      iconColor: customColors.error ?? const Color(0xFFDC2626),
                      bgColor: (customColors.error ?? const Color(0xFFDC2626)).withValues(alpha: 0.16),
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
                child: _SearchField(
                  hintText: 'Search ${widget.team.name}',
                  onChanged: (v) =>
                      setState(() => _searchQuery = v),
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
                          padding:
                              EdgeInsets.only(bottom: rs.s(8)),
                          itemCount: _filtered.length,
                          itemBuilder: (_, i) => EmployeeCard(
                            employee: _filtered[i],
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

// ╔══════════════════════════════════════════════════════════════╗
// ║               SMALL SHARED WIDGETS                          ║
// ╚══════════════════════════════════════════════════════════════╝

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final VoidCallback onTap;
  final _RS rs;
  final bool isLoading;

  const _IconBtn({
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.onTap,
    required this.rs,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        width: rs.s(32),
        height: rs.s(32),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: rs.radius(8),
        ),
        child: isLoading
            ? SizedBox(
                width: rs.s(12),
                height: rs.s(12),
                child: Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    valueColor: AlwaysStoppedAnimation(iconColor),
                    
                  ),
                ),
              )
            : Icon(icon, size: rs.s(16), color: iconColor),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final String hintText;
  final ValueChanged<String> onChanged;
  final _RS rs;

  const _SearchField({
    required this.hintText,
    required this.onChanged,
    required this.rs,
  });

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).custom;
    final isDark = themeController.themeMode.value == ThemeMode.dark;
    final br = rs.radius(11);
    final border = OutlineInputBorder(
      borderRadius: br,
      borderSide: BorderSide(
        color: customColors.inputBorder ??
            (isDark ? AppColorsDark.inputBorder : AppColorsLight.inputBorder),
        width: 1,
      ),
    );
    final focusedBorder = OutlineInputBorder(
      borderRadius: br,
      borderSide:
          const BorderSide(color: Color(0xFF2563EB), width: 1.2),
    );
    return TextField(
      onChanged: onChanged,
      style: TextStyle(
        fontSize: rs.f(13),
        color: customColors.textPrimary ??
          (isDark ? AppColorsDark.textPrimary : AppColorsLight.textPrimary)),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
        fontSize: rs.f(13),
        color: customColors.textHint ??
          (isDark ? AppColorsDark.textHint : AppColorsLight.textHint)),
        prefixIcon: Icon(Icons.search_rounded,
        size: rs.s(18),
        color: customColors.textHint ??
          (isDark ? AppColorsDark.textHint : AppColorsLight.textHint)),
        prefixIconConstraints: BoxConstraints(
          minWidth: rs.s(36),
          minHeight: rs.s(36),
        ),
        filled: true,
        fillColor: customColors.inputFill ??
          (isDark ? AppColorsDark.inputFill : AppColorsLight.inputFill),
        contentPadding: EdgeInsets.symmetric(vertical: rs.s(9)),
        border: border,
        enabledBorder: border,
        focusedBorder: focusedBorder,
        isDense: true,
      ),
    );
  }
}

// ╔══════════════════════════════════════════════════════════════╗
// ║                    TEAMS PAGE (MAIN)                        ║
// ╚══════════════════════════════════════════════════════════════╝

class TeamsPage extends ConsumerStatefulWidget {
  const TeamsPage({super.key});

  @override
  ConsumerState<TeamsPage> createState() => _TeamsPageState();
}

class _TeamsPageState extends ConsumerState<TeamsPage> {
  String _unassignedSearch = '';
  bool _isUnassignedDragOver = false;
  late List<Team> _teams;
  late List<Employee> _employees;
  bool _isLoadingTeams = true;
  bool _isLoadingEmployees = true;
  String? _deletingTeamId;

  @override
  void initState() {
    super.initState();
    _teams = [];
    _employees = [];
    _loadTeams();
    _loadEmployees();
  }

  Future<void> _loadTeams() async {
    try {
      final teamModels = await ref.read(teamsProvider.future);
      // Convert API Team models to local Team class with manager info
      setState(() {
        _teams = teamModels
            .map((t) => Team(
              id: t.rowId,
              name: t.teamName,
              reportingManagerId: t.teamReportingManagerId,
              reportingManager: t.teamReportingManager,
            ))
            .toList();
        _isLoadingTeams = false;
      });
    } catch (e) {
      debugPrint('Error loading teams: $e');
      setState(() {
        _isLoadingTeams = false;
      });
    }
  }

  Future<void> _loadEmployees() async {
    try {
      final batchProfiles = await ref.read(batchProfilesProvider.future);
      // Convert batch profile response to local Employee class used in teams page
      setState(() {
        _employees = batchProfiles
            .map((profile) => Employee(
              id: profile.userId,
              name: profile.fullName,
              phone: profile.phone ?? '',
              profileImageUrl:
                  profile.profilePic.isNotEmpty ? profile.profilePic : null,
              teamId: profile.teamId,
            ))
            .toList();
        _isLoadingEmployees = false;
      });
    } catch (e) {
      debugPrint('Error loading batch profiles: $e');
      setState(() {
        _isLoadingEmployees = false;
      });
      
      // Show error message in snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading employees: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  // ── Helpers ──
  List<Employee> _employeesInTeam(String teamId) =>
      _employees.where((e) => e.teamId == teamId).toList();

  List<Employee> get _unassigned {
    final all = _employees.where((e) => e.teamId == null).toList();
    if (_unassignedSearch.trim().isEmpty) return all;
    final q = _unassignedSearch.toLowerCase();
    return all
        .where((e) =>
            e.name.toLowerCase().contains(q) || e.phone.contains(q))
        .toList();
  }

  int get _totalUnassigned =>
      _employees.where((e) => e.teamId == null).length;

  void _moveEmployee(Employee employee, String? targetTeamId) {
    setState(() {
      final idx = _employees.indexWhere((e) => e.id == employee.id);
      if (idx != -1) _employees[idx].teamId = targetTeamId;
    });
  }

  // ── Dialogs ──
  Future<void> _showAddTeamDialog() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (_) => const AddEditTeamPage()),
    );

    if (!mounted || result == null) return;

    final teamName = (result['teamName'] ?? '').toString().trim();
    if (teamName.isEmpty) return;

    // Refresh teams list from API after successful creation
    _loadTeams();
  }

  Future<void> _showEditTeamDialog(Team team) async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => AddEditTeamPage(
          teamId: team.id,
          teamName: team.name,
          reportingManager: team.reportingManager,
          reportingManagerId: team.reportingManagerId,
        ),
      ),
    );

    if (!mounted || result == null) return;

    final updatedName = (result['teamName'] ?? '').toString().trim();
    if (updatedName.isEmpty) return;

    // Refresh teams list from API after successful update
    _loadTeams();
  }

  void _confirmDeleteTeam(Team team) {
    showWarningDialogueBox<bool>(
      context: context,
      title: 'Delete Team',
      subtitle: 'Are you sure you want to delete "${team.name}"?',
      primaryText: 'Delete',
      onPrimaryPressed: (dialogContext) async {
        Navigator.of(dialogContext).pop(true);
        
        // Set loading state for this team
        setState(() => _deletingTeamId = team.id);

        try {
          // Call delete API
          final teamNotifier = ref.read(teamNotifierProvider.notifier);
          await teamNotifier.deleteTeam(team.id);

          // Remove from local state
          setState(() {
            for (final e in _employees) {
              if (e.teamId == team.id) e.teamId = null;
            }
            _teams.removeWhere((t) => t.id == team.id);
            _deletingTeamId = null;
          });

          // Show success snackbar
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Team "${team.name}" deleted successfully'),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 2),
              ),
            );
          }

          // Refresh teams list from API
          _loadTeams();
        } catch (e) {
          setState(() => _deletingTeamId = null);

          // Show error snackbar
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error deleting team: $e'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 4),
              ),
            );
          }
        }
      },
    );
  }

  // ╔══════════════════════════════════════════════════════════╗
  // ║                        BUILD                            ║
  // ╚══════════════════════════════════════════════════════════╝
  @override
  Widget build(BuildContext context) {
    // One RS instance for the whole page — derived from screen width
    final rs = _RS(MediaQuery.of(context).size.width);
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeController.themeMode,
      builder: (context, mode, _) {
        final customColors = Theme.of(context).custom;
        final isDark = mode == ThemeMode.dark;
        final background = customColors.background ??
            (isDark ? AppColorsDark.background : AppColorsLight.background);
        final cardBackground = customColors.cardBackground ??
            (isDark ? AppColorsDark.cardBackground : AppColorsLight.cardBackground);
        final textHint = customColors.textHint ??
            (isDark ? AppColorsDark.textHint : AppColorsLight.textHint);
        final textSecondary = customColors.textSecondary ??
            (isDark ? AppColorsDark.textSecondary : AppColorsLight.textSecondary);
        final textPrimary = customColors.textPrimary ??
            (isDark ? AppColorsDark.textPrimary : AppColorsLight.textPrimary);

        return Scaffold(
          drawer: const AppDrawer(),
          backgroundColor: background,
          body: SafeArea(
        child: Column(
          children: [
            // ── Top bar ──
            TopBar(
              title: 'Teams',
              onBack: () => Navigator.pop(context),
            ),

            // ── Body (55 / 45 split) ──
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final totalH = constraints.maxHeight;
                  final upperH = totalH * 0.55;
                  final lowerH = totalH * 0.45;

                  // Grid cell aspect ratio: shrinks on small screens so
                  // avatar + name + phone all fit without overflow.
                  // 2.6 on 390 px; approaches 1.9 at the minimum scale.
                    final gridAspect =
                      (rs.scale * 3.0).clamp(2.2, 3.0);

                  return Column(
                    children: [
                      // ════════════════════════════════════════
                      //   UPPER 55% — horizontal board scroll
                      // ════════════════════════════════════════
                      SizedBox(
                        height: upperH,
                        child: _isLoadingTeams
                            ? Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation(
                                    Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              )
                            : _teams.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.group_outlined,
                                        size: rs.s(40),
                                        color: textHint),
                                    SizedBox(height: rs.s(8)),
                                    Text(
                                      'No teams yet. Add one below.',
                                      style: TextStyle(
                                        color: textSecondary,
                                        fontSize: rs.f(14),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                scrollDirection: Axis.horizontal,
                                padding: rs.insets(
                                    const EdgeInsets.fromLTRB(
                                        16, 14, 4, 10)),
                                itemCount: _teams.length,
                                itemBuilder: (_, i) {
                                  final team = _teams[i];
                                  return TeamBoard(
                                    team: team,
                                    employees:
                                        _employeesInTeam(team.id),
                                    onEmployeeDropped: (emp, tid) =>
                                        _moveEmployee(emp, tid),
                                    onEdit: () =>
                                        _showEditTeamDialog(team),
                                    onDelete: () =>
                                        _confirmDeleteTeam(team),
                                    rs: rs,
                                    isDeleting: _deletingTeamId == team.id,
                                  );
                                },
                              ),
                      ),

                      // ════════════════════════════════════════
                      //   LOWER 45% — unassigned 2-col grid
                      // ════════════════════════════════════════
                      Container(
                        height: lowerH,
                        
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(
                              width: 0.8,
                              color: customColors.greyBorder ??
                                  (isDark ? AppColorsDark.greyBorder : AppColorsLight.greyBorder),
                            ),
                          ),
                          color: cardBackground,
                          // borderRadius: BorderRadius.vertical(
                          //     top: Radius.circular(22)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.09),
                              blurRadius: 16,
                              offset: Offset(0, -4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ── Handle pill ──
                            
                            SizedBox(height: rs.s(16)),

                            // ── Header row ──
                            Padding(
                              padding: rs.insets(
                                  const EdgeInsets.fromLTRB(
                                      16, 0, 16, 0)),
                              child: Row(
                                crossAxisAlignment:
                                    CrossAxisAlignment.center,
                                children: [
                                  // Orange icon box
                                  Container(
                                    width: rs.s(38),
                                    height: rs.s(38),
                                    decoration: BoxDecoration(
                                      color: (customColors.statusInProgress ?? customColors.primary ?? const Color(0xFFE07820)).withValues(alpha: 0.16),
                                      borderRadius: rs.radius(11),
                                    ),
                                    child: Icon(
                                      Icons.person,
                                      color: customColors.statusInProgress ?? customColors.primary ?? const Color(0xFFE07820),
                                      size: rs.s(21),
                                    ),
                                  ),
                                  SizedBox(width: rs.s(10)),
                                  // Title + member count
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Unassigned',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: rs.f(15),
                                          color: textPrimary,
                                          letterSpacing: -0.2,
                                        ),
                                      ),
                                      Text(
                                        '$_totalUnassigned Members',
                                        style: TextStyle(
                                          fontSize: rs.f(11),
                                          color: textSecondary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Spacer(),
                                  // +Add Team button
                                  GestureDetector(
                                    onTap: _showAddTeamDialog,
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: rs.s(12),
                                        vertical: rs.s(8),
                                      ),
                                      decoration: BoxDecoration(
                                        color: customColors.primary,
                                        borderRadius: rs.radius(10),
                                        boxShadow: [
                                          BoxShadow(
                                            color: (customColors.primary ?? const Color(0xFF2563EB)).withValues(alpha: 0.3),
                                            blurRadius: rs.s(8),
                                            offset:
                                                const Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      child: Text(
                                        '+ Add Team',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: rs.f(12),
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.1,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: rs.s(8)),

                            // ── Search bar ──
                            Padding(
                              padding: rs.sym(h: 16),
                              child: _SearchField(
                                hintText: 'Search Unassigned...',
                                onChanged: (v) => setState(
                                    () => _unassignedSearch = v),
                                rs: rs,
                              ),
                            ),
                            SizedBox(height: rs.s(6)),

                            // ── Unassigned drag-target 2-col grid ──
                            Expanded(
                              child: _isLoadingEmployees
                                  ? Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        valueColor: AlwaysStoppedAnimation(
                                          Theme.of(context).colorScheme.primary,
                                        ),
                                      ),
                                    )
                                  : DragTarget<Employee>(
                                      onWillAccept: (data) {
                                        if (data == null ||
                                            data.teamId == null)
                                          return false;
                                        HapticFeedback.selectionClick();
                                        setState(() =>
                                            _isUnassignedDragOver = true);
                                        return true;
                                      },
                                      onLeave: (_) => setState(() =>
                                          _isUnassignedDragOver = false),
                                      onAccept: (emp) {
                                        HapticFeedback.mediumImpact();
                                        setState(() =>
                                            _isUnassignedDragOver = false);
                                        _moveEmployee(emp, null);
                                      },
                                      builder: (ctx, candidate, rejected) {
                                        return AnimatedContainer(
                                          duration: const Duration(
                                              milliseconds: 180),
                                          curve: Curves.easeOut,
                                          margin: rs.sym(h: 16),
                                          decoration: _isUnassignedDragOver
                                              ? BoxDecoration(
                                                  color: (customColors.statusInProgress ?? customColors.primary ?? const Color(0xFFE07820)).withValues(alpha: 0.12),
                                                  borderRadius:
                                                      rs.radius(14),
                                                  border: Border.all(
                                                      color: customColors.statusInProgress ?? customColors.primary ?? const Color(0xFFE07820),
                                                      width: 2),
                                                )
                                              : null,
                                          child: _unassigned.isEmpty
                                              ? EmptyDropZone(rs: rs)
                                              : GridView.builder(
                                                  padding: EdgeInsets.only(
                                                    top: rs.s(4),
                                                    bottom: rs.s(12),
                                                  ),
                                                  gridDelegate:
                                                      SliverGridDelegateWithFixedCrossAxisCount(
                                                    crossAxisCount: 2,
                                                    crossAxisSpacing:
                                                        rs.s(8),
                                                    mainAxisSpacing:
                                                        rs.s(3),
                                                    // aspect ratio shrinks on
                                                    // small screens to prevent
                                                    // vertical overflow
                                                    childAspectRatio:
                                                        gridAspect,
                                                  ),
                                                  itemCount:
                                                      _unassigned.length,
                                                  itemBuilder: (_, i) =>
                                                      EmployeeCard(
                                                    employee:
                                                        _unassigned[i],
                                                    rs: rs,
                                                    isGrid: true,
                                                  ),
                                                ),
                                        );
                                      },
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
      },
    );
  }
}