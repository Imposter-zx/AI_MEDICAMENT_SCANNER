import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../providers/medical_data_provider.dart';
import '../providers/user_profile_provider.dart';
import '../models/models.dart';

class TrendsScreen extends StatelessWidget {
  const TrendsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profileProvider = context.watch<UserProfileProvider>();
    final activeProfile = profileProvider.activeProfile;
    final medicalProvider = context.watch<MedicalDataProvider>();
    
    // Filter history for the active profile
    final userHistory = medicalProvider.history.where((item) => 
      item.userId == (activeProfile?.id ?? 'default')).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('📊 Health Trends'),
        elevation: 0,
        actions: [
          if (activeProfile != null)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Text(
                  activeProfile.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ),
        ],
      ),
      body: activeProfile == null 
        ? const Center(child: Text('Please select a profile to view trends.'))
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader('Medication Adherence'),
                const SizedBox(height: 16),
                _buildAdherenceChart(context),
                const SizedBox(height: 32),
                _buildSectionHeader('Lab Results History'),
                const SizedBox(height: 16),
                _buildLabResultsChart(context, userHistory),
                const SizedBox(height: 32),
                _buildInsightCard(context, activeProfile),
              ],
            ),
          ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildAdherenceChart(BuildContext context) {
    // Mocking adherence data
    return Container(
      height: 250,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 100,
          barGroups: [
            _buildBarGroup(0, 85, 'Mon'),
            _buildBarGroup(1, 90, 'Tue'),
            _buildBarGroup(2, 70, 'Wed'),
            _buildBarGroup(3, 100, 'Thu'),
            _buildBarGroup(4, 95, 'Fri'),
          ],
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'];
                  if (value >= days.length) return const SizedBox.shrink();
                  return Text(days[value.toInt()], style: const TextStyle(fontSize: 10));
                },
              ),
            ),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }

  BarChartGroupData _buildBarGroup(int x, double y, String label) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: y > 80 ? Colors.blue : (y > 60 ? Colors.orange : Colors.red),
          width: 16,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  Widget _buildLabResultsChart(BuildContext context, List<HistoryItem> history) {
    // Extracting glucose values from history (mocking if empty)
    final glucoseHistory = history
        .where((item) => item.type == 'document')
        .map((item) {
          final doc = item.data as MedicalDocument;
          final glucoseFinding = doc.keyFindings.firstWhere(
            (f) => f.label.toLowerCase().contains('glucose'),
            orElse: () => KeyFinding(label: '', value: '0', normalRange: '', isAbnormal: false),
          );
          return double.tryParse(glucoseFinding.value.split(' ').first) ?? 0.0;
        })
        .where((val) => val > 0)
        .toList();

    final plotData = glucoseHistory.length >= 2 
        ? glucoseHistory 
        : [95.0, 110.0, 105.0, 120.0, 102.0];

    return Column(
      children: [
        _buildLineChartCard(
          context, 
          'Blood Glucose Trend', 
          Icons.water_drop, 
          Colors.red, 
          plotData,
        ),
        const SizedBox(height: 16),
        _buildBPChartCard(context),
      ],
    );
  }

  Widget _buildLineChartCard(BuildContext context, String title, IconData icon, Color color, List<double> plotData) {
    return Container(
      height: 250,
      padding: const EdgeInsets.only(top: 24, bottom: 12, right: 24, left: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 12.0),
            child: Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: LineChart(
              LineChartData(
                lineBarsData: [
                  LineChartBarData(
                    spots: List.generate(plotData.length, (i) => FlSpot(i.toDouble(), plotData[i])),
                    isCurved: true,
                    color: color,
                    barWidth: 4,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(show: true, color: color.withValues(alpha: 0.1)),
                  ),
                ],
                titlesData: const FlTitlesData(
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: const FlGridData(show: true, drawVerticalLine: false),
                borderData: FlBorderData(show: false),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBPChartCard(BuildContext context) {
    // Mock BP data
    final systolicData = [120.0, 125.0, 118.0, 130.0, 122.0];
    final diastolicData = [80.0, 82.0, 78.0, 85.0, 80.0];

    return Container(
      height: 250,
      padding: const EdgeInsets.only(top: 24, bottom: 12, right: 24, left: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 12.0),
            child: Row(
              children: [
                Icon(Icons.monitor_heart, color: Colors.purple, size: 20),
                SizedBox(width: 8),
                Text('Blood Pressure', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: LineChart(
              LineChartData(
                lineBarsData: [
                  LineChartBarData(
                    spots: List.generate(systolicData.length, (i) => FlSpot(i.toDouble(), systolicData[i])),
                    isCurved: true,
                    color: Colors.purple,
                    barWidth: 3,
                    dotData: const FlDotData(show: true),
                  ),
                  LineChartBarData(
                    spots: List.generate(diastolicData.length, (i) => FlSpot(i.toDouble(), diastolicData[i])),
                    isCurved: true,
                    color: Colors.blueAccent,
                    barWidth: 3,
                    dotData: const FlDotData(show: true),
                  ),
                ],
                titlesData: const FlTitlesData(
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: const FlGridData(show: true, drawVerticalLine: false),
                borderData: FlBorderData(show: false),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightCard(BuildContext context, UserProfile profile) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.blue.shade700, Colors.blue.shade900]),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.auto_awesome, color: Colors.amber, size: 24),
              SizedBox(width: 12),
              Text(
                'AI Smart Insights',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Hello ${profile.name}, your adherence is looking good! '
            'Recent lab tests show stable glucose levels. Keep following your regimen.',
            style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
          ),
        ],
      ),
    );
  }
}
