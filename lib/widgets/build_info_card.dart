import 'package:flutter/material.dart';
import '../Utilities/constants/color_constants.dart';
import '../Utilities/constants/font_constants.dart';

Widget buildInfoCard({required String title, required String value, Color cardColor = kBackgroundGreyColor, IconData cardIcon = Icons.accessibility,
  double fontSize = 18,void Function()? tapped,
}) {
  return Tooltip(
    message: title,
    child: GestureDetector(
      onTap: tapped,
      child: Card(
        // Add a tooltip that appears when the user holds the mouse button down over the card
        // This tooltip should show the title of the card
        color: cardColor.withOpacity(0.2),
        elevation:0,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: fontSize),
              ),
              kSmallHeightSpacing,
              cardIcon == Icons.accessibility?SizedBox():Icon(cardIcon, color: cardColor.withOpacity(0.6),),
              kSmallHeightSpacing,
              Text(
                  value,
                  style: TextStyle(fontSize: fontSize,)
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
