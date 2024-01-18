
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../Utilities/constants/color_constants.dart';
import '../../model/beautician_data.dart';
import 'line_titles.dart';


class LineChartWidget extends StatelessWidget {
  LineChartWidget({required this.graphValues, required this.targetValues, required this.targetDays, required this.scale});

    final List<FlSpot> graphValues;
    final List<FlSpot> targetValues;
    final List<String> targetDays;
    final List<String> scale;

  final List<Color> gradientColors = [
    kCustomColor.withOpacity(0.3),
    kAppPinkColor.withOpacity(0.3),

  ];
  final List<Color> gradientColors2 = [

    kAppPinkColor.withOpacity(0.1),
    kAppPinkColor.withOpacity(0.1),

  ];
  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        minX:0,
        maxX: 6,
        minY: 0,
        maxY: 40,
        titlesData: LineTitles("Average Ordering Times", [100,100,100,100,100,100,100], targetDays, kPureWhiteColor, "Orders").getTitleData(),
        borderData:
        FlBorderData(
          show: false
        ),
        gridData: FlGridData(
          show: false,

        ),
        lineBarsData: [

          LineChartBarData(
            isCurved: true,
            barWidth: 2,
            belowBarData: BarAreaData(
              show: true,
              // color: kCustomColor
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: gradientColors,
              ),
            ),
            spots: graphValues
          ),

        ]
      )

    );
  }
}
