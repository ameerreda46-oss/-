import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../db/database_helper.dart';
import '../models/expense.dart';

class StatsScreen extends StatelessWidget {
  final DateTime month;
  const StatsScreen({super.key, required this.month});

  Future<(Map<String, double>, List<MapEntry<DateTime, double>>)> _load() async {
    final db = DatabaseHelper.instance;
    return (await db.totalsByCategory(month), await db.lastMonthsTotals(6));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الإحصائيات')),
      body: FutureBuilder(
        future: _load(),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final (byCat, monthly) = snap.data!;
          final total = byCat.values.fold(0.0, (a, b) => a + b);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'توزيع مصروفات ${DateFormat('MMMM yyyy', 'ar').format(month)}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              if (byCat.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: Text('لا توجد بيانات لهذا الشهر')),
                )
              else ...[
                SizedBox(
                  height: 220,
                  child: PieChart(PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 40,
                    sections: [
                      for (final e in byCat.entries)
                        PieChartSectionData(
                          value: e.value,
                          color: categoryByName(e.key).color,
                          radius: 60,
                          title: '${(e.value / total * 100).toStringAsFixed(0)}%',
                          titleStyle: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13),
                        ),
                    ],
                  )),
                ),
                const SizedBox(height: 12),
                for (final e in byCat.entries)
                  ListTile(
                    dense: true,
                    leading: Icon(categoryByName(e.key).icon,
                        color: categoryByName(e.key).color),
                    title: Text(e.key),
                    trailing: Text('${e.value.toStringAsFixed(2)} $currency'),
                  ),
              ],
              const Divider(height: 40),
              Text('آخر 6 أشهر',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 24),
              SizedBox(
                height: 220,
                child: BarChart(BarChartData(
                  borderData: FlBorderData(show: false),
                  gridData: const FlGridData(drawVerticalLine: false),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    leftTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (v, meta) {
                          final i = v.toInt();
                          if (i < 0 || i >= monthly.length) {
                            return const SizedBox();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                                DateFormat('MMM', 'ar').format(monthly[i].key),
                                style: const TextStyle(fontSize: 11)),
                          );
                        },
                      ),
                    ),
                  ),
                  barGroups: [
                    for (var i = 0; i < monthly.length; i++)
                      BarChartGroupData(x: i, barRods: [
                        BarChartRodData(
                          toY: monthly[i].value,
                          width: 18,
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ]),
                  ],
                )),
              ),
            ],
          );
        },
      ),
    );
  }
}
