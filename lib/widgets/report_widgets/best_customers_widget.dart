


import 'package:flutter/material.dart';
import 'package:stylestore/model/common_functions.dart';

import '../../Utilities/constants/color_constants.dart';
import '../../Utilities/constants/font_constants.dart';

Widget bestCustomersWidget(List<MapEntry<String, double>> top5Customers, number) {
  // Build your list of customers here - consider using a ListView or Column
  return ListView.builder(
    shrinkWrap: true, // Makes list scrollable within a Column
    itemCount: top5Customers.length, // Assuming top 5
    itemBuilder: (context, index) {
      return ListTile(
        title: Text(top5Customers[index].key, style: kNormalTextStyle.copyWith(color: kPureWhiteColor),), // Customer Name
        trailing: Text(CommonFunctions().formatter.format(top5Customers[index].value), style: kNormalTextStyle.copyWith(color: kPureWhiteColor),), // Amount Spent
      );
    },
  );
}
