import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../../core/domain/enums/skill_type.dart';

class RadarChartWidget extends StatelessWidget {
  final Map<SkillType, double> skillProgress;

  const RadarChartWidget({super.key, required this.skillProgress});

  @override
  Widget build(BuildContext context) {
    final skills = SkillType.values;
    final values = skills.map((s) => skillProgress[s] ?? 0).toList();

    return Container(
      height: 250,
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
      child: RadarChart(
        RadarChartData(
          radarShape: RadarShape.polygon,
          radarBorderData: const BorderSide(color: Colors.transparent),
          titlePositionPercentageOffset: 0.2,
          titleTextStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          getTitle: (index, angle) {
            return RadarChartTitle(
              text: skills[index].label,
              angle: angle,
              positionPercentageOffset: 0.2,
            );
          },
          tickBorderData: BorderSide(color: Colors.grey.withOpacity(0.3)),
          tickCount: 5,
          radarBackgroundColor: Colors.grey.withOpacity(0.05),
          dataSets: [
            RadarDataSet(
              fillColor: Colors.purple.withOpacity(0.2),
              borderColor: Colors.purple,
              entryRadius: 4,
              dataEntries: values.asMap().entries.map((entry) {
                return RadarEntry(value: entry.value / 100);
              }).toList(),
            ),
          ],
          radarTouchData: RadarTouchData(
            touchCallback: (FlTouchEvent event, RadarTouchResponse? response) {},
          ),
        ),
      ),
    );
  }
}