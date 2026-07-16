import 'package:flutter/material.dart';

import '../../../../core/domain/entities/stats_entity.dart';

class StatsSummaryCard extends StatelessWidget {
  final StatsEntity stats;

  const StatsSummaryCard({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple.shade400, Colors.blue.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            icon: Icons.check_circle,
            label: 'Выполнено',
            value: '${stats.totalTasksCompleted}',
          ),
          _buildStatItem(
            icon: Icons.local_fire_department,
            label: 'Серия',
            value: '${stats.currentStreak} дн.',
          ),
          _buildStatItem(
            icon: Icons.stars,
            label: 'Очки',
            value: '${stats.totalPoints}',
          ),
          _buildStatItem(
            icon: Icons.trending_up,
            label: 'Точность',
            value: '${(stats.overallAccuracy * 100).toInt()}%',
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 28),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}