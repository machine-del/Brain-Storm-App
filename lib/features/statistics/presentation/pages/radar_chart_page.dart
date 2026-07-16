import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/stats_bloc.dart';
import '../widgets/radar_chart_widget.dart';
import '../../../../core/domain/enums/skill_type.dart';

class RadarChartPage extends StatelessWidget {
  const RadarChartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🎯 Радар навыков'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<StatsBloc>().add(RefreshStatsEvent());
            },
          ),
        ],
      ),
      body: BlocBuilder<StatsBloc, StatsState>(
        builder: (context, state) {
          if (state is StatsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is StatsLoaded) {
            return _buildContent(context, state);
          }

          if (state is StatsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<StatsBloc>().add(RefreshStatsEvent());
                    },
                    child: const Text('Попробовать снова'),
                  ),
                ],
              ),
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, StatsLoaded state) {
    final skills = SkillType.values;
    final maxSkill = state.stats.skillProgress.values.isEmpty
        ? 0.0
        : state.stats.skillProgress.values.reduce((a, b) => a > b ? a : b);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(state, maxSkill),
          const SizedBox(height: 16),
          RadarChartWidget(skillProgress: state.stats.skillProgress),
          const SizedBox(height: 24),
          _buildSkillDetails(skills, state),
        ],
      ),
    );
  }

  Widget _buildHeader(StatsLoaded state, double maxSkill) {
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
            label: 'Сильный навык',
            value: state.stats.skillProgress.entries.isEmpty
                ? '—'
                : state.stats.skillProgress.entries
                    .reduce((a, b) => a.value > b.value ? a : b)
                    .key
                    .label,
          ),
          _buildStatItem(
            label: 'Максимум',
            value: '${maxSkill.toInt()}%',
          ),
          _buildStatItem(
            label: 'Средний',
            value: state.stats.skillProgress.values.isEmpty
                ? '0%'
                : '${(state.stats.skillProgress.values.reduce((a, b) => a + b) / state.stats.skillProgress.length).toInt()}%',
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
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

  Widget _buildSkillDetails(List<SkillType> skills, StatsLoaded state) {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📊 Детали навыков',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...skills.map((skill) {
            final progress = state.stats.skillProgress[skill] ?? 0;
            final completed = state.stats.skillCompletedCount[skill] ?? 0;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Text(
                    '${skill.icon} ${skill.label}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${progress.toInt()}%',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: _getSkillColor(skill),
                        ),
                      ),
                      Text(
                        'Заданий: $completed',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
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