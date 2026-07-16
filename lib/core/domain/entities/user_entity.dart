class UserEntity {
  final String id;
  final String name;
  final int level;
  final int experience;
  final int nextLevelExperience;
  final int totalPoints;
  final int streak;
  final int completedTasks;
  final DateTime? lastActivityDate;
  final String? avatarUrl;

  const UserEntity({
    required this.id,
    required this.name,
    required this.level,
    required this.experience,
    required this.nextLevelExperience,
    required this.totalPoints,
    required this.streak,
    required this.completedTasks,
    this.lastActivityDate,
    this.avatarUrl,
  });

  double get progressToNextLevel => nextLevelExperience > 0 
      ? experience / nextLevelExperience 
      : 0.0;

  UserEntity copyWith({
    String? id,
    String? name,
    int? level,
    int? experience,
    int? nextLevelExperience,
    int? totalPoints,
    int? streak,
    int? completedTasks,
    DateTime? lastActivityDate,
    String? avatarUrl,
  }) {
    return UserEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      level: level ?? this.level,
      experience: experience ?? this.experience,
      nextLevelExperience: nextLevelExperience ?? this.nextLevelExperience,
      totalPoints: totalPoints ?? this.totalPoints,
      streak: streak ?? this.streak,
      completedTasks: completedTasks ?? this.completedTasks,
      lastActivityDate: lastActivityDate ?? this.lastActivityDate,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}