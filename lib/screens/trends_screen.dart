import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../providers/medical_data_provider.dart';
import '../providers/reminder_provider.dart';
import '../models/models.dart';

class TrendsScreen extends StatelessWidget {
  const TrendsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Trends'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
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
            _buildLabResultsChart(context),
            const SizedBox(height: 32),
            _buildInsightCard(context),
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
    return Consumer<ReminderProvider>(
      builder: (context, provider, _) {
        // Mocking adherence data for the last 7 days
        return Container(
          height: 250,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
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
                _buildBarGroup(5, 60, 'Sat'),
                _buildBarGroup(6, 80, 'Sun'),
              ],
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                      return Text(days[value.toInt()], style: const TextStyle(fontSize: 10));
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: true, reservedSize: 30),
                ),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
            ),
          ),
        );
      },
    );
  }

  BarChartGroupData _buildBarGroup(int x, double y, String label) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: y > 80 ? Colors.green : (y > 60 ? Colors.orange : Colors.red),
          width: 16,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  Widget _buildLabResultsChart(BuildContext context) {
    return Consumer<MedicalDataProvider>(
      builder: (context, provider, _) {
        // Extracting glucose values from history
        final glucoseHistory = provider.history
            .where((item) => item.type == 'document')
            .map((item) {
              final doc = item.data as MedicalDocument;
              final glucoseFinding = doc.keyFindings.firstWhere(
                (f) => f.label.toLowerCase() == 'glucose',
                orElse: () => KeyFinding(label: '', value: '0', normalRange: '', isAbnormal: false),
              );
              return double.tryParse(glucoseFinding.value) ?? 0.0;
            })
            .where((val) => val > 0)
            .toList();

        // If not enough data, show mock trend
        final plotData = glucoseHistory.length >= 2 
            ? glucoseHistory 
            : [95.0, 110.0, 105.0, 98.0, 120.0, 102.0];

        return Container(
          height: 250,
          padding: const EdgeInsets.only(top: 24, bottom: 12, right: 24, left: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
          ),
          child: LineChart(
            LineChartData(
              lineBarsData: [
                LineChartBarData(
                  spots: List.generate(plotData.length, (i) => FlSpot(i.toDouble(), plotData[i])),
                  isCurved: true,
                  color: Colors.blue,
                  barWidth: 4,
                  belowBarData: BarAreaData(
                    show: true,
                    color: Colors.blue.withOpacity(0.1),
                  ),
                ),
              ],
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  axisNameWidget: const Text('Recent Tests', style: TextStyle(fontSize: 12)),
                  sideTitles: SideTitles(showTitles: true, reservedSize: 22),
                ),
                leftTitles: AxisTitles(
                  axisNameWidget: const Text('Value (mg/dL)', style: TextStyle(fontSize: 12)),
                  sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                ),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              gridData: const FlGridData(show: true, drawVerticalLine: false),
              borderData: FlBorderData(show: false),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInsightCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.blue.shade700, Colors.blue.shade900]),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, color: Colors.amber, size: 24),
              SizedBox(width: 12),
              Text(
                'AI Smart Insights',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            'Your medication adherence has improved by 15% this week! This correlates with your stabilizing glucose levels. Keep it up.',
            style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
          ),
        ],
      ),
    );
  }
}
