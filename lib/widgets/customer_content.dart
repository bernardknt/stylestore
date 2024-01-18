
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


import '../utilities/constants/color_constants.dart';
import '../utilities/constants/font_constants.dart';



class CustomerContentsWidget extends StatelessWidget {

  CustomerContentsWidget({
    required this.orderIndex,
    this.productDescription = '', required this.optionName, required this.optionValue, this.fontSize = 12});

  final String optionName;
  final String productDescription;
  // final int quantity;
  final int orderIndex;
  final String optionValue;
  final double fontSize;

  var formatter = NumberFormat('#,###,000');

  @override
  Widget build(BuildContext context) {

    return Container(
      //width: double.infinity,


      // margin: EdgeInsets.only(top: 16, left:16, right: 16),
      decoration: BoxDecoration(
        color: Colors.transparent, borderRadius: BorderRadius.circular(18), //Color(0xFF212121)
      ),
      child: ListTile(
        // leading: Text('$orderIndex', style: kNormalTextStyle.copyWith(fontSize: 8),),
        title: Text('$optionName', style:kHeading2TextStyleBold.copyWith(color: kBlack,fontSize: fontSize) ,),
        // subtitle: Text('$productDescription', style:kHeading2TextStyleBold.copyWith(color: kFontGreyColor,fontSize: 15) ,),
        trailing: Text(optionValue, style: kHeading2TextStyleBold.copyWith(color: kBlack,fontSize: fontSize) ,),

      ),
    );
  }
}