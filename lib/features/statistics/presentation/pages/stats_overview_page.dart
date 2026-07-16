import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/stats_bloc.dart';
import '../widgets/skill_progress_bar.dart';
import '../widgets/gantt_chart_widget.dart';
import '../widgets/radar_chart_widget.dart';
import '../widgets/stats_summary_card.dart';
import 'gantt_chart_page.dart';
import 'radar_chart_page.dart';

class StatsOverviewPage extends StatelessWidget {
  const StatsOverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📊 Статистика'),
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

          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, StatsLoaded state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StatsSummaryCard(stats: state.stats),
          const SizedBox(height: 16),
          Text(
            '📈 Прогресс навыков',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 12),
          SkillProgressCard(stats: state.stats),
          const SizedBox(height: 16),
          Text(
            '🗓️ Недельный прогресс',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 12),
          GanttChartWidget(weeklyData: state.weeklyProgress),
          const SizedBox(height: 16),
          Text(
            '🎯 Радар навыков',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 12),
          RadarChartWidget(skillProgress: state.stats.skillProgress),
          const SizedBox(height: 16),
          _buildNavigationRow(context),
        ],
      ),
    );
  }

  Widget _buildNavigationRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildNavigationCard(
            context,
            icon: Icons.bar_chart,
            title: 'Диаграмма Ганта',
            subtitle: 'Недельный прогресс',
            color: Colors.blue,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const GanttChartPage()),
              );
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildNavigationCard(
            context,
            icon: Icons.radar,
            title: 'Радар навыков',
            subtitle: 'Все навыки',
            color: Colors.purple,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RadarChartPage()),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
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
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            const Icon(Icons.arrow_forward, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}