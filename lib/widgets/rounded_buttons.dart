import 'package:flutter/material.dart';
import 'package:stylestore/utilities/constants/color_constants.dart';
import 'package:stylestore/utilities/constants/font_constants.dart';



class RoundedButtons extends StatelessWidget {
  RoundedButtons({ required this.buttonColor,  required this.title,required this.onPressedFunction, this.buttonHeight = 30,
    this.buttonWidth = double.infinity});
  final String title;
  final Color buttonColor;
  final double buttonHeight;
  final VoidCallback onPressedFunction;
  final double buttonWidth;


  @override
  Widget build(BuildContext context) {
    return Container(


        child: GestureDetector(
          //onTap: onPressedFunction,
          child: MaterialButton(
            onPressed: onPressedFunction,
            clipBehavior: Clip.none,
            child: Text(title ,
              style:
              kNormalTextStyle.copyWith(color: kPureWhiteColor),

            ),




          ),
        ),
        height: buttonHeight,
        width: buttonWidth,
        margin: EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: buttonColor,
          borderRadius: BorderRadius.circular(8),
        )
    );
  }
}