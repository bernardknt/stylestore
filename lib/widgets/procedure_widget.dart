import 'package:flutter/material.dart';

import '../Utilities/constants/color_constants.dart';
import '../Utilities/constants/font_constants.dart';

class ProcedureStep extends StatelessWidget {
  final int stepNumber;
  final String description;

  const ProcedureStep({
    required this.stepNumber,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: kBlueDarkColor,
        child: Text(
          stepNumber.toString(),
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(
        description,
        style: kNormalTextStyle.copyWith(fontSize: 16.0, color: kBlack),
      ),
    );
  }
}