import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';

import 'constants/color_constants.dart';




class paymentButtons extends StatelessWidget {
  paymentButtons({ required this.continueFunction, required this.continueBuyingText, required this.checkOutText, required this.buyFunction, this.lineIconFirstButton = LineIcons.removeUser, this.lineIconSecondButton = Icons.check});

  final VoidCallback continueFunction;
  final VoidCallback buyFunction;
  final String continueBuyingText;
  final String checkOutText;
  final IconData lineIconFirstButton;
  final IconData lineIconSecondButton;

  @override
  Widget build(BuildContext context) {
    return
      Container(
        child: Row(
            children: [
              Expanded(
                flex: 4,
                child: TextButton.icon(onPressed: continueFunction,
                  style: TextButton.styleFrom(
                    //elevation: ,
                      shadowColor:  kBlueDarkColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18)
                      ),
                      backgroundColor: kBiegeThemeColor),icon: Icon(lineIconFirstButton, color: kBlueDarkColor,),
                  label: Text(continueBuyingText, style: TextStyle(fontWeight: FontWeight.bold,
                      color: kBlueDarkColor), ), ),
              ),
              SizedBox(width: 5,),
              Expanded(
                flex: 3,
                child: TextButton.icon(onPressed: buyFunction,
                  style: TextButton.styleFrom(
                    //elevation: ,
                      shadowColor: kBlueDarkColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18)
                      ),
                      backgroundColor: kBlueDarkColorOld
                  ),icon: Icon(lineIconSecondButton, color: Color(0xFFF2efe4),),
                  label: Text(checkOutText, style: TextStyle(fontWeight: FontWeight.bold,
                      color: kBiegeThemeColor), ), ),
              ),
            ]),

      );
  }
}