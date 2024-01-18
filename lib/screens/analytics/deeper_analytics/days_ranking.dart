




import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import 'package:stylestore/model/common_functions.dart';
import 'package:stylestore/utilities/constants/color_constants.dart';


import '../../../Utilities/constants/font_constants.dart';


class BestDaysPage extends StatelessWidget {
  final List<String> bestDays;
  final List<double> amounts;

  BestDaysPage({required this.bestDays, required this.amounts});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBlack,
      appBar: AppBar(
        foregroundColor: kPureWhiteColor,
        title: Text('Best Days Ranked', style: kNormalTextStyle.copyWith(color: kPureWhiteColor),),
        centerTitle: true,
        backgroundColor: kBlack,
        elevation: 0,
      ),
      body: ListView.builder(
        itemCount:  bestDays.length > 7 ? 7 : bestDays.length,
        itemBuilder: (context, index) {
          final day = bestDays[index];
          return ListTile(
            tileColor: index == 0? kAppPinkColor:kBlack,
            title: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("${index+1}. ${day}", style: kNormalTextStyle.copyWith(color: kPureWhiteColor),),
                index == 0?Icon(Iconsax.crown, color: kGoldColor,size: 18,):SizedBox()
              ],
            ),
            trailing: Text('${CommonFunctions().formatter.format(amounts[index])}', style: kNormalTextStyle.copyWith(color: kPureWhiteColor),),
          );
        },
      ),
    );
  }
}