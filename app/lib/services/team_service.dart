import 'package:cricstatz/models/profile.dart';
import 'package:cricstatz/models/team.dart';
import 'package:cricstatz/models/team_member.dart';
import 'package:cricstatz/services/supabase_service.dart';

class TeamService {
  static Future<Team> createTeam({
    required String name,
    required String shortCode,
  }) async {
    final userId = SupabaseService.currentUser!.id;
    final data = await SupabaseService.client.from('teams').insert({
      'name': name,
      'short_code': shortCode,
      'created_by': userId,
    }).select().single();

    return Team.fromJson(data);
  }

  static Future<List<Team>> getMyTeams() async {
    final userId = SupabaseService.currentUser!.id;

    // Teams where user is creator
    final createdTeams = await SupabaseService.client
        .from('teams')
        .select()
        .eq('created_by', userId);

    // Teams where user is a member
    final memberTeamIds = await SupabaseService.client
        .from('team_members')
        .select('team_id')
        .eq('profile_id', userId);

    final memberIds =
        (memberTeamIds as List).map((e) => e['team_id'] as String).toList();

    List<Team> teams =
        (createdTeams as List).map((e) => Team.fromJson(e)).toList();

    if (memberIds.isNotEmpty) {
      final memberTeams = await SupabaseService.client
          .from('teams')
          .select()
          .inFilter('id', memberIds);

      final memberTeamList =
          (memberTeams as List).map((e) => Team.fromJson(e)).toList();

      // Avoid duplicates (user could be creator AND member)
      final existingIds = teams.map((t) => t.id).toSet();
      for (final team in memberTeamList) {
        if (!existingIds.contains(team.id)) {
          teams.add(team);
        }
      }
    }

    return teams;
  }

  static Future<void> addMember({
    required String teamId,
    required String profileId,
  }) async {
    await SupabaseService.client.from('team_members').insert({
      'team_id': teamId,
      'profile_id': profileId,
    });
  }

  static Future<void> removeMember({
    required String teamId,
    required String profileId,
  }) async {
    await SupabaseService.client
        .from('team_members')
        .delete()
        .eq('team_id', teamId)
        .eq('profile_id', profileId);
  }

  static Future<List<Profile>> getTeamMembers(String teamId) async {
    final data = await SupabaseService.client
        .from('team_members')
        .select('profile_id, profiles(*)')
        .eq('team_id', teamId);

    return (data as List)
        .map((e) => Profile.fromJson(e['profiles'] as Map<String, dynamic>))
        .toList();
  }

  static Future<List<TeamMember>> getTeamMemberRecords(String teamId) async {
    final data = await SupabaseService.client
        .from('team_members')
        .select()
        .eq('team_id', teamId);

    return (data as List).map((e) => TeamMember.fromJson(e)).toList();
  }

  static Future<void> deleteTeam(String teamId) async {
    await SupabaseService.client.from('teams').delete().eq('id', teamId);
  }

  static Future<Team> updateTeam({
    required String teamId,
    String? name,
    String? shortCode,
  }) async {
    final updates = <String, dynamic>{};
    if (name != null) updates['name'] = name;
    if (shortCode != null) updates['short_code'] = shortCode;

    final data = await SupabaseService.client
        .from('teams')
        .update(updates)
        .eq('id', teamId)
        .select()
        .single();

    return Team.fromJson(data);
  }
}
