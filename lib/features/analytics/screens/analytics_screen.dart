import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:eaze_my_cargo/core/theme/app_theme.dart';
import 'package:eaze_my_cargo/core/widgets/brand_logo.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      appBar: const EazeAppBar(title: 'Analytics & Intelligence'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _buildKPIRow(),
          const SizedBox(height: 16),
          _sectionTitle('Fleet Utilization'),
          _buildBarChart(),
          const SizedBox(height: 16),
          _sectionTitle('ETA Performance (7 Days)'),
          _buildLineChart(),
          const SizedBox(height: 16),
          _sectionTitle('Shipment Status Distribution'),
          _buildPieChart(),
          const SizedBox(height: 16),
          _sectionTitle('Corridor Efficiency'),
          _buildCorridorCards(),
          const SizedBox(height: 80),
        ]),
      ),
    );
  }

  Widget _buildKPIRow() {
    final kpis = [
      ('Route Efficiency', '87%', AppColors.success, Icons.route_rounded),
      ('Fleet Utilization', '74%', AppColors.brandBlue, Icons.local_shipping_rounded),
      ('On-Time Rate', '92%', AppColors.warning, Icons.access_time_rounded),
      ('Delay Index', '12%', AppColors.brandRed, Icons.schedule_send_rounded),
    ];
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.8,
      children: kpis.map((k) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: AppColors.darkCard, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.darkBorder)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Row(children: [
            Icon(k.$4, color: k.$3, size: 16),
            const SizedBox(width: 6),
            Expanded(child: Text(k.$1, style: const TextStyle(fontFamily: 'Inter', fontSize: 11, color: AppColors.neutral400, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis)),
          ]),
          Text(k.$2, style: TextStyle(fontFamily: 'Inter', fontSize: 26, fontWeight: FontWeight.w800, color: k.$3, letterSpacing: -1.0, height: 1.0)),
        ]),
      )).toList(),
    );
  }

  Widget _buildBarChart() {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.darkCard, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.darkBorder)),
      child: BarChart(BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 100,
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, _) => Text(['Mon','Tue','Wed','Thu','Fri','Sat','Sun'][v.toInt()], style: const TextStyle(fontFamily: 'Inter', fontSize: 10, color: AppColors.neutral500)), reservedSize: 22)),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (_) => FlLine(color: AppColors.darkBorder, strokeWidth: 1)),
        borderData: FlBorderData(show: false),
        barGroups: [72, 85, 91, 68, 88, 76, 94].asMap().entries.map((e) => BarChartGroupData(
          x: e.key,
          barRods: [BarChartRodData(toY: e.value.toDouble(), color: AppColors.brandBlue, width: 18, borderRadius: BorderRadius.circular(4))],
        )).toList(),
      )),
    );
  }

  Widget _buildLineChart() {
    return Container(
      height: 180,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.darkCard, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.darkBorder)),
      child: LineChart(LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots: const [FlSpot(0,88), FlSpot(1,92), FlSpot(2,85), FlSpot(3,94), FlSpot(4,89), FlSpot(5,96), FlSpot(6,92)],
            isCurved: true, color: AppColors.brandBlue, barWidth: 3,
            belowBarData: BarAreaData(show: true, color: AppColors.brandBlue.withValues(alpha: 0.1)),
            dotData: FlDotData(show: false),
          ),
          LineChartBarData(
            spots: const [FlSpot(0,12), FlSpot(1,8), FlSpot(2,15), FlSpot(3,6), FlSpot(4,11), FlSpot(5,4), FlSpot(6,8)],
            isCurved: true, color: AppColors.brandRed, barWidth: 2,
            belowBarData: BarAreaData(show: true, color: AppColors.brandRed.withValues(alpha: 0.07)),
            dotData: FlDotData(show: false),
          ),
        ],
        titlesData: FlTitlesData(show: false),
        gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (_) => FlLine(color: AppColors.darkBorder, strokeWidth: 1)),
        borderData: FlBorderData(show: false),
      )),
    );
  }

  Widget _buildPieChart() {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.darkCard, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.darkBorder)),
      child: Row(children: [
        Expanded(child: PieChart(PieChartData(
          sections: [
            PieChartSectionData(value: 35, color: AppColors.success, title: '35%', titleStyle: const TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
            PieChartSectionData(value: 28, color: AppColors.brandBlue, title: '28%', titleStyle: const TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
            PieChartSectionData(value: 22, color: AppColors.warning, title: '22%', titleStyle: const TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
            PieChartSectionData(value: 15, color: AppColors.brandRed, title: '15%', titleStyle: const TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
          ],
          sectionsSpace: 3,
          centerSpaceRadius: 40,
        ))),
        const SizedBox(width: 16),
        Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
          _legend('Completed', AppColors.success),
          _legend('In Transit', AppColors.brandBlue),
          _legend('Pending', AppColors.warning),
          _legend('Delayed', AppColors.brandRed),
        ]),
      ]),
    );
  }

  Widget _legend(String label, Color color) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(children: [
      Container(width: 10, height: 10, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
      const SizedBox(width: 8),
      Text(label, style: const TextStyle(fontFamily: 'Inter', fontSize: 12, color: AppColors.neutral300)),
    ]),
  );

  Widget _buildCorridorCards() {
    final corridors = [
      ('Vizag — Kakinada', '83%', AppColors.success),
      ('Kakinada — Vijayawada', '71%', AppColors.warning),
      ('Guntur — Vizag', '56%', AppColors.brandRed),
      ('Hyderabad — Vizag', '88%', AppColors.success),
    ];
    return Column(children: corridors.map((c) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: AppColors.darkCard, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.darkBorder)),
        child: Row(children: [
          const Icon(Icons.route_rounded, color: AppColors.neutral400, size: 18),
          const SizedBox(width: 10),
          Expanded(child: Text(c.$1, style: const TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.white))),
          const SizedBox(width: 8),
          Text(c.$2, style: TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w800, color: c.$3)),
          const SizedBox(width: 10),
          SizedBox(
            width: 60, height: 6,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: double.parse(c.$2.replaceAll('%', '')) / 100,
                backgroundColor: AppColors.darkSurface,
                valueColor: AlwaysStoppedAnimation<Color>(c.$3),
              ),
            ),
          ),
        ]),
      ),
    )).toList());
  }

  Widget _sectionTitle(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(children: [
      Container(width: 3, height: 16, decoration: BoxDecoration(color: AppColors.brandBlue, borderRadius: BorderRadius.circular(2))),
      const SizedBox(width: 8),
      Text(title, style: const TextStyle(fontFamily: 'Inter', fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.white)),
    ]),
  );
}
