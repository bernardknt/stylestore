




import 'package:flutter/material.dart';
import 'package:stylestore/model/common_functions.dart';

import '../../Utilities/constants/color_constants.dart';
import '../../Utilities/constants/font_constants.dart';

Widget bestProductsWidget(List<MapEntry<String, double>> topProducts) {
  // Build your list of customers here - consider using a ListView or Column
  return ListView.builder(
    shrinkWrap: true, // Makes list scrollable within a Column
    itemCount: topProducts.length, // Assuming top 5
    itemBuilder: (context, index) {
      return ListTile(
        title: Text("${index+1}. ${topProducts[index].key}", style: kNormalTextStyle.copyWith(color: kBlack),), // Customer Name
        trailing: Text(
          "x ${topProducts[index].value.toString()}", style: kNormalTextStyle.copyWith(color: kBlack, fontWeight: FontWeight.w600),), // Amount Spent
      );
    },
  );
}
