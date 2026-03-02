class TeamMember {
  final String id;
  final String teamId;
  final String profileId;
  final DateTime? joinedAt;

  const TeamMember({
    required this.id,
    required this.teamId,
    required this.profileId,
    this.joinedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'team_id': teamId,
        'profile_id': profileId,
      };

  factory TeamMember.fromJson(Map<String, dynamic> json) {
    return TeamMember(
      id: json['id'] as String,
      teamId: json['team_id'] as String,
      profileId: json['profile_id'] as String,
      joinedAt: json['joined_at'] != null
          ? DateTime.parse(json['joined_at'] as String)
          : null,
    );
  }
}
