enum DifficultyLevel {
  easy('🟢', 'Лёгкий', 10),
  medium('🟡', 'Средний', 20),
  hard('🔴', 'Сложный', 35);

  const DifficultyLevel(this.icon, this.label, this.points);

  final String icon;
  final String label;
  final int points;

  static DifficultyLevel fromName(String name) {
    return values.firstWhere(
      (e) => e.name == name,
      orElse: () => medium,
    );
  }
}