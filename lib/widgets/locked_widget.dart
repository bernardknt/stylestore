import 'package:flutter/material.dart';
import 'package:stylestore/Utilities/constants/font_constants.dart';

import '../Utilities/constants/color_constants.dart';

class LockedWidget extends StatelessWidget {
  
  
  const LockedWidget({ required this.page});
  final page; 
  

  @override
  Widget build(BuildContext context) {
    return Center(child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [

        Icon(Icons.lock, color: kAppPinkColor,),
        Text(page, style: kNormalTextStyle.copyWith(color: kAppPinkColor),)
      ],
    ),);
  }
}