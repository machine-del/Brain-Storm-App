import '../enums/achievement_type.dart';

class AchievementEntity {
  final String id;
  final String title;
  final String description;
  final String icon;
  final AchievementType type;
  final int requiredValue;
  final int currentProgress;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  const AchievementEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.type,
    required this.requiredValue,
    required this.currentProgress,
    required this.isUnlocked,
    this.unlockedAt,
  });

  double get progressPercentage {
    if (requiredValue <= 0) return 0;
    return (currentProgress / requiredValue).clamp(0.0, 1.0);
  }

  AchievementEntity copyWith({
    String? id,
    String? title,
    String? description,
    String? icon,
    AchievementType? type,
    int? requiredValue,
    int? currentProgress,
    bool? isUnlocked,
    DateTime? unlockedAt,
  }) {
    return AchievementEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      type: type ?? this.type,
      requiredValue: requiredValue ?? this.requiredValue,
      currentProgress: currentProgress ?? this.currentProgress,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }
}