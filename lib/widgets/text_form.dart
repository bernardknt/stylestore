

import 'package:flutter/material.dart';

class TextForm extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType keyBoardType;

 TextForm({required this.label, required this.controller,this.keyBoardType = TextInputType.text, });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        TextFormField(
          controller: controller,
          keyboardType: keyBoardType,
          decoration: InputDecoration(
            hintText: 'Enter $label',
          ),
        ),
        SizedBox(height: 16),
      ],
    );
  }
}