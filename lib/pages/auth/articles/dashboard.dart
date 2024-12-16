import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_application_5/models/chart_data.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int touchedIndex = -1;

  final List<ChartData> donutData = [
    ChartData(name: "Reuters", value: 38.82, category: "Type 1"),
    ChartData(name: "Bloomberg", value: 37.18, category: "Type 2"),
    ChartData(name: "Associated Press", value: 24.00, category: "Type 3"),
  ];

  final Map<String, List<ChartData>> categoryBarData = {
    "Politics": [
      ChartData(name: "Subcategory 1", value: 45.0, category: "Politics"),
      ChartData(name: "Subcategory 2", value: 60.0, category: "Politics"),
      ChartData(name: "Subcategory 3", value: 55.0, category: "Politics"),
    ],
    "Sports": [
      ChartData(name: "Subcategory 1", value: 30.0, category: "Sports"),
      ChartData(name: "Subcategory 2", value: 40.0, category: "Sports"),
      ChartData(name: "Subcategory 3", value: 50.0, category: "Sports"),
    ],
    "Business": [
      ChartData(name: "Subcategory 1", value: 58.0, category: "Business"),
      ChartData(name: "Subcategory 2", value: 65.0, category: "Business"),
      ChartData(name: "Subcategory 3", value: 75.0, category: "Business"),
    ],
  };

  final List<Color> pieColors = [
    Colors.blue.shade900,
    Colors.blue.shade700,
    Colors.blue.shade500,
  ];

  Widget getPieChartWithLegend() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'News Sources Distribution',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        LayoutBuilder(
          builder: (context, constraints) {
            final isPortrait = constraints.maxWidth < 600;

            return isPortrait
                ? Column(
                    children: [
                      AspectRatio(
                        aspectRatio: 1.2, // Smaller aspect ratio for pie chart
                        child: PieChart(
                          PieChartData(
                            sections: donutData.asMap().entries.map((entry) {
                              final isTouched = entry.key == touchedIndex;
                              final value = entry.value;
                              final double fontSize = isTouched ? 16 : 14;
                              final double radius = isTouched ? 90 : 80;

                              return PieChartSectionData(
                                color: pieColors[entry.key % pieColors.length],
                                value: value.value,
                                title: '${value.value.toStringAsFixed(1)}%',
                                radius: radius,
                                titleStyle: TextStyle(
                                  fontSize: fontSize,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              );
                            }).toList(),
                            centerSpaceRadius: 30,
                            sectionsSpace: 2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildLegend(),
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2, // Larger portion for pie chart
                        child: AspectRatio(
                          aspectRatio: 1.2,
                          child: PieChart(
                            PieChartData(
                              sections: donutData.asMap().entries.map((entry) {
                                final isTouched = entry.key == touchedIndex;
                                final value = entry.value;
                                final double fontSize = isTouched ? 16 : 14;
                                final double radius = isTouched ? 90 : 80;

                                return PieChartSectionData(
                                  color:
                                      pieColors[entry.key % pieColors.length],
                                  value: value.value,
                                  title: '${value.value.toStringAsFixed(1)}%',
                                  radius: radius,
                                  titleStyle: TextStyle(
                                    fontSize: fontSize,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                );
                              }).toList(),
                              centerSpaceRadius: 30,
                              sectionsSpace: 2,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 1, // Smaller portion for legend
                        child: _buildLegend(),
                      ),
                    ],
                  );
          },
        ),
      ],
    );
  }

  Widget _buildLegend() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: donutData.map((data) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: pieColors[donutData.indexOf(data) % pieColors.length],
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  data.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget getBarChart(String category) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 100,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${categoryBarData[category]![group.x].name}\n${rod.toY.toStringAsFixed(1)}%',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 &&
                    value.toInt() < categoryBarData[category]!.length) {
                  return RotatedBox(
                    quarterTurns: 1,
                    child: Text(
                      categoryBarData[category]![value.toInt()].name,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }
                return const SizedBox();
              },
              reservedSize: 40,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) => Text(
                value.toInt().toString(),
                style: const TextStyle(fontSize: 12),
              ),
              reservedSize: 30,
            ),
          ),
        ),
        gridData: FlGridData(show: true, horizontalInterval: 20),
        borderData: FlBorderData(
          show: true,
          border: const Border(
            bottom: BorderSide(color: Colors.black),
            left: BorderSide(color: Colors.black),
          ),
        ),
        barGroups: categoryBarData[category]!
            .asMap()
            .entries
            .map(
              (entry) => BarChartGroupData(
                x: entry.key,
                barRods: [
                  BarChartRodData(
                    toY: entry.value.value,
                    color: Colors.blue.shade700,
                    width: 20,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
            )
            .toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Analytics Dashboard'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: getPieChartWithLegend(),
                ),
              ),
              const SizedBox(height: 20),
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text(
                        'Category-wise News Distribution',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 300,
                        child: PageView(
                          children: categoryBarData.keys
                              .map((category) => Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                    child: getBarChart(category),
                                  ))
                              .toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
