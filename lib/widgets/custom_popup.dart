import 'package:flutter/material.dart';
import 'package:stylestore/Utilities/constants/font_constants.dart';

import '../Utilities/constants/color_constants.dart';
import '../screens/videos/videos_page.dart';

class CustomPopupWidget extends StatelessWidget {
  const CustomPopupWidget({super.key, required this.actionButton, required this.title, required this.subTitle, required this.image, required this.function,  this.backgroundColour = kAppPinkColor, required this.youtubeLink});
  final String actionButton;
  final String title;
  final String subTitle;
  final String image;
  final String youtubeLink;
  final Function function;
  final Color backgroundColour;


  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        borderRadius: BorderRadius.circular(10.0),
        color: backgroundColour,
        child: Container(
          padding: EdgeInsets.all(20.0),
          width: 300.0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10.0),
              Text(
                subTitle,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.0,
                ),
              ),
              SizedBox(height: 20.0),
              Container(
                decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(10))),
                child: Image.asset(
                  'images/'+image, // Replace with your image path
                  width: 200.0,
                  height: 200.0,fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: 20.0),
              Align(
                alignment: Alignment.bottomRight,
                child: Row(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        showModalBottomSheet(isScrollControlled: true, context: context, builder: (context) {
                          return
                            Scaffold(
                              backgroundColor: kBlack,
                              appBar: AppBar(
                                automaticallyImplyLeading: false,
                                backgroundColor: kBlack,
                                foregroundColor: kPureWhiteColor,
                              ),

                              body: Column(
                                children: [
                                  ExpandableVideoPlayer(videoUrl: youtubeLink),
                                  kLargeHeightSpacing,
                                  TextButton(onPressed: (){Navigator.pop(context);}, child: Text("Go Back", style: kNormalTextStyle.copyWith(color: kPureWhiteColor),))
                                ],
                              ));
                        });


                        // Add your continue button functionality here
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kCustomColor,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      child: Text('Watch Video'),
                    ),
                    kMediumWidthSpacing,
                    ElevatedButton(
                      onPressed: () {
                        // Navigator.pop(context);
                        function();

                        // Add your continue button functionality here
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: backgroundColour,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      child: Text(actionButton),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}