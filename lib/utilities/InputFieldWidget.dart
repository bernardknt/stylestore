

import 'package:flutter/material.dart';
import 'package:stylestore/utilities/constants/color_constants.dart';
import 'package:stylestore/utilities/constants/font_constants.dart';


class InputFieldWidget extends StatelessWidget {
  InputFieldWidget({required this.hintText, required this.onTypingFunction, required this.keyboardType, required this.labelText , this.passwordType = false, this.controller= '', this.leftPadding = 20,  this.rightPadding = 20, this.ringColor = kAppPinkColor, this.hintTextColor = Colors.grey, this.labelTextColor = Colors.grey,  this.readOnly = false, this.maxLines,  this.fontColor = kFontGreyColor, });
  final String hintText;
  final Color hintTextColor;
  final Color labelTextColor;
  final void Function(String) onTypingFunction;
  final TextInputType keyboardType;
  final String labelText;
  final bool passwordType;
  final String controller;
  final double leftPadding;
  final double rightPadding;
  final Color ringColor;
  final Color fontColor;
  final bool readOnly;
  final int? maxLines;



  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        // width: 20,
        // height: 300,
        padding: EdgeInsets.only(left: leftPadding, right: rightPadding),

        child: TextField(
          readOnly: readOnly ,
          onEditingComplete: (){print("Done"); },
          obscureText: passwordType,
          keyboardType: keyboardType,
          maxLines: maxLines,
          onChanged: onTypingFunction,
          textAlign: TextAlign.center,
          style: kNormalTextStyle.copyWith(color: fontColor) ,
          //keyboardType: TextInputType.number,
          controller: TextEditingController()..text = controller,
          decoration: InputDecoration(

            hintText: hintText,
            hintStyle: TextStyle(fontSize: 14, color: hintTextColor),
            labelText: labelText,
            labelStyle: TextStyle(fontSize: 14, color: Colors.grey[500]),
            contentPadding:
            const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(15.0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: ringColor, width: 1.0),
              borderRadius: BorderRadius.all(Radius.circular(15.0)),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color:  Colors.pink),
            ),
            // focusedBorder: OutlineInputBorder(
            //   borderSide: BorderSide(color: Colors.green, width: 0),
            //   borderRadius: BorderRadius.all(Radius.circular(32.0)),
            // ),
          ),
        ),
      ),
    );
  }
}

