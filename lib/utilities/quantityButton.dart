
import 'package:flutter/material.dart';

class QuantityBtn extends StatelessWidget {
  QuantityBtn({required this.onTapFunction, required this.text, required this.size, this.color = Colors.grey});
  final VoidCallback onTapFunction;
  final String text;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTapFunction,
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: color
        ),
        child: Text(text, style: TextStyle(fontSize: 25, fontWeight: FontWeight.w400, color: Colors.white),),
      ),
    );
  }
}
