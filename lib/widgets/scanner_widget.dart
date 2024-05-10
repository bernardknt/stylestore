import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../Utilities/constants/color_constants.dart';

class ScannerWidget extends StatelessWidget {
  final Color scannerColor;
  final Color backgroundColor;


  const ScannerWidget({
    super.key, this.scannerColor = kPureWhiteColor, this.backgroundColor = kBlueDarkColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      width: 60,
      decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.all(Radius.circular(10)),
        // boxShadow: [BoxShadow(color: kFaintGrey.withOpacity(0.5), spreadRadius: 2,blurRadius: 2 )]

      ),
      child:  Icon(Icons.barcode_reader, size: 35,color: scannerColor,),
    );
  }
}