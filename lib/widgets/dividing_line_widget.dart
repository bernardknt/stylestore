



import 'package:flutter/cupertino.dart';

import '../Utilities/constants/color_constants.dart';



class DividingLine extends StatelessWidget {
  const DividingLine({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 2.0, left: 10, right: 10),
      child: Opacity(
          opacity: 0.2,
          child: Container(color: kFaintGrey,height: 1,width: double.infinity,)),
    );
  }
}