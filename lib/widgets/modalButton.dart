


import 'package:flutter/material.dart';

import '../Utilities/constants/color_constants.dart';
import '../Utilities/constants/font_constants.dart';


Widget buildButton(BuildContext context, String title, IconData icon, Function() execute) {
  return GestureDetector(
    onTap: execute,
    child: Card(
      shadowColor: kAppPinkColor,
      elevation: 1,

      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Row(
          children: [
            Icon(icon),
            kMediumWidthSpacing,
            Text(title, style: kNormalTextStyle.copyWith(color: kBlack, fontSize: 16),),
          ],
        ),
      ),
    ),
  );
}