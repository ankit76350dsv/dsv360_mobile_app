import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dsv360/features/teams/model/employee_model.dart';
import 'package:dsv360/features/teams/model/team.dart';
import 'package:dsv360/features/teams/repositories/team_repository.dart';
import 'package:dsv360/providers/employee_provider.dart';

/// Team Repository Provider
final teamRepositoryProvider = Provider<TeamRepository>((ref) {
  return TeamRepository();
});

/// Provider that fetches all teams from API
final teamsProvider = FutureProvider.autoDispose<List<Team>>((ref) async {
  final repository = ref.watch(teamRepositoryProvider);
  return await repository.getTeams();
});

/// Provider that returns a list of reporting managers
/// Filters employees to only include those with role:
/// - "Manager/Team Lead"
/// - "Admin"
final reportingManagersProvider = FutureProvider.autoDispose<List<Employee>>((ref) async {
  final allEmployees = await ref.watch(employeeListProvider.future);
  
  // Filter employees by role
  final reportingManagers = allEmployees.where((employee) {
    final role = employee.roleName.toLowerCase();
    return role == 'manager/team lead' || role == 'admin';
  }).toList();
  
  return reportingManagers;
});

/// AsyncValue-based provider for team creation/update operations
class TeamNotifier extends StateNotifier<AsyncValue<Team?>> {
  TeamNotifier(this._ref) : super(const AsyncValue.data(null));

  final Ref _ref;

  /// Create a new team - throws exception on error
  Future<Team> createTeam({
    required String teamName,
    required String teamReportingManagerId,
    required String teamReportingManager,
    required String teamReportingManagerProfile,
    required String orgId,
  }) async {
    final repository = _ref.read(teamRepositoryProvider);
    
    return await repository.createTeam(
      teamName: teamName,
      teamReportingManagerId: teamReportingManagerId,
      teamReportingManager: teamReportingManager,
      teamReportingManagerProfile: teamReportingManagerProfile,
      orgId: orgId,
    );
  }

  /// Update an existing team - throws exception on error
  Future<Team> updateTeam({
    required String teamId,
    required String teamName,
    required String teamReportingManagerId,
    required String teamReportingManager,
    required String teamReportingManagerProfile,
    required String orgId,
  }) async {
    final repository = _ref.read(teamRepositoryProvider);
    
    return await repository.updateTeam(
      teamId: teamId,
      teamName: teamName,
      teamReportingManagerId: teamReportingManagerId,
      teamReportingManager: teamReportingManager,
      teamReportingManagerProfile: teamReportingManagerProfile,
      orgId: orgId,
    );
  }

  /// Delete a team - throws exception on error
  Future<void> deleteTeam(String teamId) async {
    final repository = _ref.read(teamRepositoryProvider);
    return await repository.deleteTeam(teamId: teamId);
  }

  /// Assign user to a team, or unassign when teamId/teamName are null
  Future<void> assignUserToTeam({
    required String userId,
    String? teamId,
    String? teamName,
  }) async {
    final repository = _ref.read(teamRepositoryProvider);
    return await repository.assignUserToTeam(
      userId: userId,
      teamId: teamId,
      teamName: teamName,
    );
  }
}

/// State notifier provider for team operations
final teamNotifierProvider = StateNotifierProvider.autoDispose<TeamNotifier, AsyncValue<Team?>>((ref) {
  return TeamNotifier(ref);
});
