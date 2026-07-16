import '../../../../core/domain/entities/achievement_entity.dart';
import '../../../../core/domain/enums/achievement_type.dart';

class AchievementModel {
  final String id;
  final String title;
  final String description;
  final String icon;
  final String type;
  final int requiredValue;
  final int currentProgress;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  AchievementModel({
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

  factory AchievementModel.fromJson(Map<String, dynamic> json) {
    return AchievementModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      icon: json['icon'] ?? '🏆',
      type: json['type'] ?? 'tasksCompleted',
      requiredValue: json['requiredValue'] ?? 0,
      currentProgress: json['currentProgress'] ?? 0,
      isUnlocked: json['isUnlocked'] ?? false,
      unlockedAt: json['unlockedAt'] != null
          ? DateTime.parse(json['unlockedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'icon': icon,
      'type': type,
      'requiredValue': requiredValue,
      'currentProgress': currentProgress,
      'isUnlocked': isUnlocked,
      'unlockedAt': unlockedAt?.toIso8601String(),
    };
  }

  AchievementEntity toEntity() {
    return AchievementEntity(
      id: id,
      title: title,
      description: description,
      icon: icon,
      type: AchievementType.fromName(type),
      requiredValue: requiredValue,
      currentProgress: currentProgress,
      isUnlocked: isUnlocked,
      unlockedAt: unlockedAt,
    );
  }

  static AchievementModel fromEntity(AchievementEntity entity) {
    return AchievementModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      icon: entity.icon,
      type: entity.type.name,
      requiredValue: entity.requiredValue,
      currentProgress: entity.currentProgress,
      isUnlocked: entity.isUnlocked,
      unlockedAt: entity.unlockedAt,
    );
  }
}