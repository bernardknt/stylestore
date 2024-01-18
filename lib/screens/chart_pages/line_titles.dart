
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../Utilities/constants/color_constants.dart';
import '../../Utilities/constants/font_constants.dart';
class LineTitles {
  LineTitles(this.heading, this.scale, this.days, this.textColor, this.yAxisName,);
  final String heading;

  final List scale;
  final List days;
  final Color textColor;
  final String yAxisName;
   getTitleData () =>

       FlTitlesData(
    show: true,
    rightTitles: AxisTitles(
        axisNameWidget: Text("", style: kNormalTextStyle.copyWith(color: kPureWhiteColor, fontSize: 14),)

    ),
    topTitles: AxisTitles(
      axisNameWidget: Column(
        children: [
          Text(heading, style: kNormalTextStyle.copyWith(color: kPureWhiteColor, fontSize: 12),),
        ],
      )

    ),
    leftTitles: AxisTitles(
        axisNameWidget: Text(yAxisName, style: kNormalTextStyle.copyWith(color: textColor, fontSize: 12),),
      axisNameSize: 40,
      sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 22,
          interval: 1,
          getTitlesWidget: (value, titleMeta){
            switch (value.toInt()){
            // case 1: return Text("Tue", style: kNormalTextStyle.copyWith(color: kPureWhiteColor, fontSize: 10),);
              case 100000: return Text(scale[1], style: kNormalTextStyle.copyWith(color: textColor, fontSize: 10),);
            // case 3: return Text("Thu", style: kNormalTextStyle.copyWith(color: kPureWhiteColor, fontSize: 10),);
              case 200000: return Text(scale[2], style: kNormalTextStyle.copyWith(color:textColor, fontSize: 10),);
            // case 5: return Text("Sat", style: kNormalTextStyle.copyWith(color: kPureWhiteColor, fontSize: 10),);
              case 600000: return Text(scale[3], style: kNormalTextStyle.copyWith(color: textColor, fontSize: 10),);
              case 800000: return Text(scale[4], style: kNormalTextStyle.copyWith(color:textColor, fontSize: 10),);
              case 1000000: return Text(scale[5], style: kNormalTextStyle.copyWith(color:textColor, fontSize: 10),);

            }
            return Text("", style: kNormalTextStyle.copyWith(color:textColor, fontSize: 10),);
          }
      )

    ),
    bottomTitles: AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        reservedSize: 22,
        interval: 1,
        getTitlesWidget: (value, titleMeta){
          switch (value.toInt()){
            case 1: return Text(days[1], style: kNormalTextStyle.copyWith(color: textColor, fontSize: 10),);
            case 2: return Text(days[2], style: kNormalTextStyle.copyWith(color: textColor, fontSize: 10),);
            case 3: return Text(days[3], style: kNormalTextStyle.copyWith(color: textColor, fontSize: 10),);
            case 4: return Text(days[4], style: kNormalTextStyle.copyWith(color: textColor, fontSize: 10),);
            case 5: return Text(days[5], style: kNormalTextStyle.copyWith(color: textColor, fontSize: 10),);
            case 6: return Text(days[6], style: kNormalTextStyle.copyWith(color: textColor, fontSize: 10),);
          }
          return Text(days[0], style: kNormalTextStyle.copyWith(color: textColor, fontSize: 10),);
        }
      )
    )
  );
}