enum SkillType {
  creativity('🎨', 'Креативность', 'Способность генерировать новые идеи и находить нестандартные решения'),
  logic('🧠', 'Логика', 'Способность мыслить последовательно и находить закономерности'),
  socialIntelligence('🤝', 'Социальный интеллект', 'Способность понимать других и эффективно взаимодействовать'),
  speed('⚡', 'Скорость', 'Способность быстро обрабатывать информацию и принимать решения');

  const SkillType(this.icon, this.label, this.description);

  final String icon;
  final String label;
  final String description;

  static SkillType fromName(String name) {
    return values.firstWhere(
      (e) => e.name == name,
      orElse: () => creativity,
    );
  }
}