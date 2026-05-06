import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dsv360/features/teams/viewmodel/teams_provider.dart';
import 'package:dsv360/features/teams/viewmodel/batch_profile_provider.dart';

// ╔══════════════════════════════════════════════════════════════╗
// ║              DATA MODELS                                    ║
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
// ║              TEAMS VIEWMODEL                                ║
// ╚══════════════════════════════════════════════════════════════╝

class TeamsViewModel {
  final Ref _ref;

  TeamsViewModel(this._ref);

  /// Load teams from API and convert to local Team models
  Future<List<Team>> loadTeams() async {
    try {
      final teamModels = await _ref.read(teamsProvider.future);
      return teamModels
          .map((t) => Team(
                id: t.rowId,
                name: t.teamName,
                reportingManagerId: t.teamReportingManagerId,
                reportingManager: t.teamReportingManager,
              ))
          .toList();
    } catch (e) {
      debugPrint('Error loading teams: $e');
      rethrow;
    }
  }

  /// Load employees from API and convert to local Employee models
  Future<List<Employee>> loadEmployees() async {
    try {
      final batchProfiles = await _ref.read(batchProfilesProvider.future);
      return batchProfiles
          .map((profile) => Employee(
                id: profile.userId,
                name: profile.fullName,
                phone: profile.phone ?? '',
                profileImageUrl:
                    profile.profilePic.isNotEmpty ? profile.profilePic : null,
                teamId: profile.teamId,
              ))
          .toList();
    } catch (e) {
      debugPrint('Error loading batch profiles: $e');
      rethrow;
    }
  }

  /// Get employees assigned to a specific team
  List<Employee> getEmployeesInTeam(String teamId, List<Employee> employees) {
    return employees.where((e) => e.teamId == teamId).toList();
  }

  /// Filter unassigned employees by search query
  List<Employee> filterUnassignedEmployees(
    List<Employee> employees,
    String searchQuery,
  ) {
    final unassigned = employees.where((e) => e.teamId == null).toList();
    if (searchQuery.trim().isEmpty) return unassigned;
    final q = searchQuery.toLowerCase();
    return unassigned
        .where((e) =>
            e.name.toLowerCase().contains(q) || e.phone.contains(q))
        .toList();
  }

  /// Get total count of unassigned employees
  int getTotalUnassigned(List<Employee> employees) {
    return employees.where((e) => e.teamId == null).length;
  }

  /// Move employee to a team
  Future<void> moveEmployee(
    Employee employee,
    String? targetTeamId,
    String? targetTeamName,
  ) async {
    if (employee.teamId == targetTeamId) return;

    try {
      final teamNotifier = _ref.read(teamNotifierProvider.notifier);
      await teamNotifier.assignUserToTeam(
        userId: employee.id,
        teamId: targetTeamId,
        teamName: targetTeamName,
      );
    } catch (e) {
      debugPrint('Error moving employee to team: $e');
      rethrow;
    }
  }

  /// Delete a team
  Future<void> deleteTeam(String teamId) async {
    try {
      final teamNotifier = _ref.read(teamNotifierProvider.notifier);
      await teamNotifier.deleteTeam(teamId);
    } catch (e) {
      debugPrint('Error deleting team: $e');
      rethrow;
    }
  }
}
