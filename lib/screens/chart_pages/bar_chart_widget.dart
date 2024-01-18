import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:stylestore/model/common_functions.dart';
import 'package:stylestore/screens/chart_pages/line_titles.dart';

import '../../Utilities/constants/color_constants.dart';

class BarChartWidget extends StatelessWidget {
  BarChartWidget({required this.graphValues, required this.targetValues, required this.targetDays, required this.scale, required this.title});

  final List graphValues;
  final List<FlSpot> targetValues;
  final List<String> targetDays;
  final List<String> scale;
  final String title;

  final List<Color> gradientColors = [
    kCustomColor.withOpacity(0.3),
    kCustomColor.withOpacity(0.3),

  ];
  final List<Color> gradientColors2 = [

    kAppPinkColor.withOpacity(0.1),
    kAppPinkColor.withOpacity(0.1),

  ];

  @override
  Widget build(BuildContext context) {
    List<BarChartGroupData> _generateRandomData() {
      Random random = Random();
      List<double> data = List.generate(7, (_) => random.nextDouble() * 10 + 1);

      List<BarChartGroupData> barChartGroups = [];
      // for (int i = 0; i < data.length; i++) {
      for (int i = 0; i < graphValues.length; i++) {
        barChartGroups.add(
          BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                fromY: graphValues[i]/100000,
                width: 15,
                color: graphValues[i]/100000 >5?kAppPinkColor: kCustomColor,
                toY: 0,
              ),
            ],
          ),
        );
      }

      return barChartGroups;
    }
    return BarChart(
      BarChartData(
        barTouchData: BarTouchData(
          // touchCallback: (barTouchResponse, event){
          //   if (barTouchResponse.spot != null && barTouchResponse.touchInput is! FlPanEnd) {
          //     barTouchResponse.touchTooltipData.tooltipBottomMargin = -24; // Move tooltip above the bar
          //   }
          // },
          touchTooltipData: BarTouchTooltipData(


            tooltipBgColor: Colors.blueGrey,
            // fitInsideHorizontally: true,
            // fitInsideVertically: true,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              String weekDay = rodIndex.toString();
              String yValue = "Ugx ${CommonFunctions().formatter.format(rod.fromY * 100000) }";
              return BarTooltipItem('${yValue}', TextStyle(color: Colors.white));
            },

          ),
          ),
        minY: 0,
        maxY: 10,
        titlesData:LineTitles(title, ["0", "100000", "200000", "600000", "800000", "1000000"], ["Mon","Tue","Wed","Thur","Fri","Sat","Sun" ], kPureWhiteColor, "Ugx").getTitleData(),
        borderData: FlBorderData(
          show: false,
        ),
        barGroups: _generateRandomData(),
        gridData: FlGridData(
                  show: false,

                ),
      ),
    );

  }
}