import 'package:flutter/material.dart';
import 'package:stylestore/Utilities/constants/color_constants.dart';
import 'package:stylestore/utilities/constants/font_constants.dart';

class DirectoryNotFoundPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBlack,
      appBar: AppBar(

        backgroundColor: kBlack,
        elevation: 0,
        title: Text('Directory Not Found', style: kNormalTextStyle.copyWith(color: kPureWhiteColor),),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Oooopss\nThe directory you are looking for does not exist.',
                style: kNormalTextStyle.copyWith(fontSize: 20, color: kPureWhiteColor),
                textAlign: TextAlign.center,
              ),
            ),
            Icon(Icons.web_asset_off, size: 60,color: kPureWhiteColor,)
          ],
        ),
      ),
    );
  }
}