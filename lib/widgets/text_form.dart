

import 'package:flutter/material.dart';

class TextForm extends StatelessWidget {
  final String label;
  final TextEditingController controller;

  const TextForm(this.label, this.controller);

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
          decoration: InputDecoration(
            hintText: 'Enter $label',
          ),
        ),
        SizedBox(height: 16),
      ],
    );
  }
}