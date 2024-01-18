import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter/material.dart';


class PrintOrder extends StatelessWidget {

  PrintOrder({ required this.order});
  final String order;


  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}