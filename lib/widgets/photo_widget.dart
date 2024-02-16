import 'package:flutter/material.dart';
import 'package:stylestore/Utilities/constants/font_constants.dart';

import '../Utilities/constants/color_constants.dart';

class PhotoWidget extends StatelessWidget {

  final IconData iconToUse;
  final Color iconColor;
  final Color widgetColor;
  final String footer;
  final Function onTapFunction;
  final double height;
  final double width;
  final double fontSize;

  const PhotoWidget({Key? key, this.iconToUse = Icons.photo_camera,
    this.iconColor = kBlack,
    this.footer = "",
    required this.onTapFunction,
    this.widgetColor = Colors.transparent,
    this.height = 100,this.width = 150, required this.fontSize}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Handle icon click here
        onTapFunction();

        print('Icon clicked!');
      },
      child: Column(
        children: [
          Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: kPureWhiteColor,
              borderRadius: BorderRadius.circular(10),

            ),

            child: Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                color: widgetColor,
                borderRadius: BorderRadius.circular(10),

              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                 height<=80? Container(): Icon(
                    iconToUse,
                    size: 24,
                    color: iconColor,
                  ),
                  kSmallHeightSpacing,
                  Text(footer, style: kNormalTextStyle.copyWith(color: iconColor, fontWeight: FontWeight.bold, fontSize: fontSize),)
                ],
              ),
            ),
          ),
          // kSmallHeightSpacing,

        ],
      ),
    );
  }
}