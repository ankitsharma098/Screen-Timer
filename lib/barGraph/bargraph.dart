import 'package:device_apps/device_apps.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../CustomTheme/CustomTheme.dart';

class DailyUsageChart extends StatelessWidget {
  final List<Map<String, dynamic>> data;

  DailyUsageChart({required this.data});
  CustomTheme themeObj=CustomTheme();

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double maxUsage = data.map((app) => (app['usage'] as num).toDouble()).reduce((a, b) => a > b ? a : b);
    double chartHeight = maxUsage.ceil() + (maxUsage * 0.1); // Add 10% padding

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: size.height * 0.03),
          AspectRatio(
            aspectRatio: 1,
            child: BarChart(
              BarChartData(
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    tooltipBgColor: themeObj.primaryColor,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      String appName = data[group.x.toInt()]['name'];
                      appName = appName.split('.').last;
                      return BarTooltipItem(
                        '${appName}\n',
                        TextStyle(
                          color: themeObj.textBlack,
                          fontWeight: FontWeight.w400,
                          fontSize: size.width * 0.035,
                        ),
                        children: <TextSpan>[
                          TextSpan(
                            text: "${rod.toY.toStringAsFixed(1)} min",
                            style: TextStyle(
                              color: themeObj.textBlack,
                              fontSize: size.width * 0.04,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles:AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border(
                    left: BorderSide(color: Colors.grey),
                    bottom: BorderSide(color: Colors.grey),
                  ),
                ),
                gridData: FlGridData(drawVerticalLine: false),

                barGroups: List.generate(
                  data.length,
                      (index) => BarChartGroupData(
                    x: index,
                    barsSpace: 10,

                    barRods: [
                      BarChartRodData(
                        toY: (data[index]['usage'] as num).toDouble(),
                        color: Colors.blue,
                        width: 12, // Reduce this value to make bars narrower
                        borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
                      ),
                    ],
                  ),
                ),
                maxY: chartHeight,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget getBottomTitles(double value, TitleMeta meta, Size size) {
    if (value.toInt() >= 0 && value.toInt() < data.length) {
      return SideTitleWidget(
        axisSide: meta.axisSide,
        space: 4,
        child: Icon(data[value.toInt()]['icon'] as IconData, size: size.width * 0.05),
      );
    }
    return SizedBox.shrink();
  }

  Widget getLeftTitles(double value, TitleMeta meta, Size size) {
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 4,
      child: Text(
        '${value.toInt()} min',
        style: GoogleFonts.openSans(
          color: Colors.grey,
          fontWeight: FontWeight.w500,
          fontSize: size.width * 0.03,
        ),
      ),
    );
  }
}


