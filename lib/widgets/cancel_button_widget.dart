import 'package:flutter/material.dart';

class CancelButtonWidget extends StatelessWidget {
  const CancelButtonWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(onPressed: (){Navigator.pop(context);}, child: Text("Cancel"));
  }
}