import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/tasks_bloc.dart';
import '../../../../core/domain/enums/skill_type.dart';

class SkillSelector extends StatefulWidget {
  const SkillSelector({super.key});

  @override
  State<SkillSelector> createState() => _SkillSelectorState();
}

class _SkillSelectorState extends State<SkillSelector> {
  SkillType _selectedSkill = SkillType.creativity;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Выбери навык для тренировки:',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 48,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: SkillType.values.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final skill = SkillType.values[index];
              final isSelected = _selectedSkill == skill;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedSkill = skill;
                  });
                  context
                      .read<TasksBloc>()
                      .add(LoadTasksBySkillEvent(skillType: skill));
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: isSelected ? skill.color : skill.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isSelected ? skill.color : skill.color.withOpacity(0.2),
                    ),
                  ),
                  child: Center(
                    child: Row(
                      children: [
                        Text(skill.icon, style: const TextStyle(fontSize: 16)),
                        const SizedBox(width: 6),
                        Text(
                          skill.label,
                          style: TextStyle(
                            color: isSelected ? Colors.white : skill.color,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

extension SkillTypeExtension on SkillType {
  Color get color {
    switch (this) {
      case SkillType.creativity:
        return Colors.purple;
      case SkillType.logic:
        return Colors.blue;
      case SkillType.socialIntelligence:
        return Colors.green;
      case SkillType.speed:
        return Colors.orange;
    }
  }
}