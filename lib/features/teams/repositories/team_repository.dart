import 'package:dsv360/core/network/dio_client.dart';
import 'package:dsv360/features/teams/model/team.dart';

class TeamRepository {
  final _client = ApiClient.instance;

  /// Fetch all teams from API
  /// Throws exception if fetch fails
  Future<List<Team>> getTeams() async {
    const path = 'time_entry_management_application_function/team';
    
    final response = await _client.get(path);

    final Map<String, dynamic> jsonResponse = response.data as Map<String, dynamic>;
    final List<dynamic> teamList = jsonResponse['data'] as List<dynamic>;
    
    return teamList
        .map((teamJson) => Team.fromJson(teamJson as Map<String, dynamic>))
        .toList();
  }

  /// Create a new team via API
  /// Throws exception if creation fails
  Future<Team> createTeam({
    required String teamName,
    required String teamReportingManagerId,
    required String teamReportingManager,
    required String teamReportingManagerProfile,
    required String orgId,
  }) async {
    const path = 'time_entry_management_application_function/team';

    final payload = Team.createPayload(
      teamName: teamName,
      teamReportingManagerId: teamReportingManagerId,
      teamReportingManager: teamReportingManager,
      teamReportingManagerProfile: teamReportingManagerProfile,
      orgId: orgId,
    );

    final response = await _client.post(path, data: payload);

    final Map<String, dynamic> jsonResponse = response.data as Map<String, dynamic>;
    final teamData = jsonResponse['data'] as Map<String, dynamic>;
    return Team.fromJson(teamData);
  }

  /// Update an existing team via API
  /// Throws exception if update fails
  Future<Team> updateTeam({
    required String teamId,
    required String teamName,
    required String teamReportingManagerId,
    required String teamReportingManager,
    required String teamReportingManagerProfile,
    required String orgId,
  }) async {
    const path = 'time_entry_management_application_function/team';

    final payload = Team.createPayload(
      teamName: teamName,
      teamReportingManagerId: teamReportingManagerId,
      teamReportingManager: teamReportingManager,
      teamReportingManagerProfile: teamReportingManagerProfile,
      orgId: orgId,
    );

    final response = await _client.put(
      path,
      data: payload,
      queryParameters: {'ROWID': teamId},
    );

    final Map<String, dynamic> jsonResponse = response.data as Map<String, dynamic>;
    final teamData = jsonResponse['data'] as Map<String, dynamic>;
    return Team.fromJson(teamData);
  }
}
