class Team {
  final String id;
  final String name;
  final String shortCode;
  final String? createdBy;

  const Team({
    required this.id,
    required this.name,
    required this.shortCode,
    this.createdBy,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'short_code': shortCode,
        'created_by': createdBy,
      };

  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      id: json['id'] as String,
      name: json['name'] as String,
      shortCode: json['short_code'] as String,
      createdBy: json['created_by'] as String?,
    );
  }
}
