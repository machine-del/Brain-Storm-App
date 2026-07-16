import 'package:flutter/material.dart';

import '../../../../core/domain/entities/stats_entity.dart';
import '../../../../core/domain/enums/skill_type.dart';

class SkillProgressCard extends StatelessWidget {
  final StatsEntity stats;

  const SkillProgressCard({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: stats.skillProgress.entries.map((entry) {
          return _buildSkillBar(
            skill: entry.key,
            progress: entry.value,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSkillBar({
    required SkillType skill,
    required double progress,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '${skill.icon} ${skill.label}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Text(
                '${progress.toInt()}%',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: _getSkillColor(skill),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              widthFactor: progress / 100,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _getSkillColor(skill).withOpacity(0.7),
                      _getSkillColor(skill),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getSkillColor(SkillType skill) {
    switch (skill) {
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