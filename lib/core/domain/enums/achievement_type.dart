enum AchievementType {
  tasksCompleted('Выполнение заданий'),
  streak('Серия дней'),
  skillMastery('Мастерство навыка'),
  totalPoints('Общие очки'),
  speedRun('Скоростной режим'),
  perfectScore('Идеальный результат');

  const AchievementType(this.label);

  final String label;

  static AchievementType fromName(String name) {
    return values.firstWhere(
      (e) => e.name == name,
      orElse: () => tasksCompleted,
    );
  }
}