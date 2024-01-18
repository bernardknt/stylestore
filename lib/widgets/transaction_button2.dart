



import 'package:flutter/material.dart';

import '../screens/payment_pages/pos2.dart';
import '../utilities/constants/color_constants.dart';
import '../utilities/constants/font_constants.dart';


class TransactionButtons2 extends StatelessWidget {
  TransactionButtons2({ required this.labelText, required this.displayWidget, required this.icon, this.width = 130,  this.height = 130, this.colour = kPureWhiteColor, });


  final String labelText;
  final double width;
  final double height;
  final Widget displayWidget;
  final Icon icon;
  final Color colour;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (){
        Navigator.pop(context);
        Navigator.pushNamed(context, POS.id);
      },
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: colour,
        ),
        child: Center(child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            Text(labelText,textAlign: TextAlign.center, style: kNormalTextStyle,),
          ],
        )),

        // width: double.maxFinite,
      ),
    );
  }
}


