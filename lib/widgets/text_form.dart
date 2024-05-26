

import 'package:flutter/material.dart';
import 'package:stylestore/Utilities/constants/color_constants.dart';
import 'package:stylestore/Utilities/constants/font_constants.dart';

class TextForm extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType keyBoardType;
  final bool password;
  final Color labelColor;

 TextForm({required this.label, required this.controller,this.keyBoardType = TextInputType.text, this.password = false,
  this.labelColor = kBlack});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: labelColor),
        ),
        TextFormField(
          obscureText: password,
          controller: controller,
          keyboardType: keyBoardType,
          style: kNormalTextStyle.copyWith(color: labelColor),

          decoration: InputDecoration(
            hintText: 'Enter $label',
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: labelColor.withOpacity(0.5)),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: labelColor.withOpacity(0.5)),
            ),

            hintStyle: TextStyle(color: labelColor.withOpacity(0.5), fontSize: 12),


          ),
        ),
        SizedBox(height: 16),
      ],
    );
  }
}