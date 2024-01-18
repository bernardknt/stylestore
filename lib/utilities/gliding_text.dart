
import 'package:flutter/material.dart';

import '../Utilities/constants/color_constants.dart';
import '../Utilities/constants/font_constants.dart';

class GlidingText extends StatefulWidget {
  final String text;
  final Duration delay;

  const GlidingText({Key? key, required this.text, required this.delay}) : super(key: key);

  @override
  _GlidingTextState createState() => _GlidingTextState();
}

class _GlidingTextState extends State<GlidingText> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
    Future.delayed(widget.delay, () {
      _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _animation.value,
      duration: const Duration(milliseconds: 500),
      child: Text(
        widget.text,
        style: kNormalTextStyle.copyWith(fontSize: 16, color: kBlack, fontWeight: FontWeight.w400),
      ),
    );
  }
}
