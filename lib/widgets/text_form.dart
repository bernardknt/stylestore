

import 'package:flutter/material.dart';

class TextForm extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType keyBoardType;
  final bool password;

 TextForm({required this.label, required this.controller,this.keyBoardType = TextInputType.text, this.password = false});

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
          obscureText: password,
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