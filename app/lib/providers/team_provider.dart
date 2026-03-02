import 'package:cricstatz/models/profile.dart';
import 'package:cricstatz/models/team.dart';
import 'package:cricstatz/services/team_service.dart';
import 'package:flutter/foundation.dart';

class TeamProvider extends ChangeNotifier {
  List<Team> _teams = [];
  bool _isLoading = false;
  String? _error;

  List<Team> get teams => List.unmodifiable(_teams);
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadTeams() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _teams = await TeamService.getMyTeams();
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<Team> createTeam({
    required String name,
    required String shortCode,
  }) async {
    final team = await TeamService.createTeam(
      name: name,
      shortCode: shortCode,
    );
    _teams.add(team);
    notifyListeners();
    return team;
  }

  Future<void> deleteTeam(String teamId) async {
    await TeamService.deleteTeam(teamId);
    _teams.removeWhere((t) => t.id == teamId);
    notifyListeners();
  }

  Future<void> addMember({
    required String teamId,
    required String profileId,
  }) async {
    await TeamService.addMember(teamId: teamId, profileId: profileId);
  }

  Future<void> removeMember({
    required String teamId,
    required String profileId,
  }) async {
    await TeamService.removeMember(teamId: teamId, profileId: profileId);
  }

  Future<List<Profile>> getTeamMembers(String teamId) async {
    return TeamService.getTeamMembers(teamId);
  }
}
