import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:stylestore/Utilities/constants/font_constants.dart';
import 'package:stylestore/widgets/dividing_line_widget.dart';
import 'package:stylestore/widgets/photo_widget.dart';

import '../Utilities/constants/color_constants.dart';
import '../screens/videos/videos_page.dart';

class ReportPopupWidget extends StatelessWidget {
  const ReportPopupWidget({super.key, required this.actionButton, required this.title, required this.subTitle,
   // required this.image,
    required this.function,
    this.backgroundColour = kAppPinkColor, required this.report,
   // required this.youtubeLink
  });
  final String actionButton;
  final String title;
  final String subTitle;
  final String report;
 // final String image;
 // final String youtubeLink;
  final Function function;
  final Color backgroundColour;


  @override
  Widget build(BuildContext context) {
    final HttpsCallable callableCreateStoreAnalysis = FirebaseFunctions.instance.httpsCallable('createStoreAnalysis');

    return Center(
      child: Material(
        borderRadius: BorderRadius.circular(10.0),
        color: kPureWhiteColor,
        child: Container(
          padding: EdgeInsets.all(20.0),
          width: 300.0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: TextStyle(
                  color:backgroundColour,
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10.0),
              Text(
                subTitle,
                style: TextStyle(
                  color:backgroundColour,
                  fontSize: 16.0,
                ),
              ),
              SizedBox(height: 20.0),
              // Container(
              //   decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(10))),
              //   child: Image.asset(
              //     'images/'+image, // Replace with your image path
              //     width: 200.0,
              //     height: 200.0,fit: BoxFit.cover,
              //   ),
              // ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  PhotoWidget(
                      onTapFunction: (){
                       },
                      height: 90,
                      width: 100,
                      footer: "850,000",iconToUse: Iconsax.card_pos,
                      widgetColor: kPureWhiteColor,
                      iconColor: kCustomColorPink,
                      fontSize: 12
                    // 16,

                  ),
                  kMediumWidthSpacing,
                  PhotoWidget(
                      onTapFunction: (){
                       },
                      height: 90,
                      width: 100,
                      footer: "2 Signed In",iconToUse: Iconsax.people,
                      widgetColor: kPureWhiteColor,
                      iconColor: kCustomColorPink,
                      fontSize: 12
                    // 16,

                  ),
                ],
              ),
              kLargeHeightSpacing,
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  PhotoWidget(
                      onTapFunction: (){
                       },
                      height: 90,
                      width: 100,
                      footer: "3 Day Detox",iconToUse: Iconsax.box,
                      widgetColor: kPureWhiteColor,
                      iconColor: kCustomColorPink,
                      fontSize: 12
                    // 16,

                  ),
                  kMediumWidthSpacing,
                  PhotoWidget(
                      onTapFunction: (){
                       },
                      height: 90,
                      width: 100,
                      footer: "12 Restocked",iconToUse: Iconsax.money4,
                      widgetColor: kPureWhiteColor,
                      iconColor: kCustomColorPink,
                      fontSize: 12
                    // 16,

                  ),
                ],
              ),
              kSmallHeightSpacing,
              DividingLine(),
              kSmallHeightSpacing,
              Text(report, style: TextStyle(color: kBlack, fontWeight: FontWeight.bold),),
              kSmallHeightSpacing,
              DividingLine(),
              SizedBox(height: 20.0),
              Row(mainAxisAlignment: MainAxisAlignment.center,

                children: [

                  ElevatedButton(
                    onPressed: () async {
     Navigator.pop(context);
    // try {
    //   dynamic serverCallableVariable = await callableCreateStoreAnalysis.call(<String, dynamic>{
    //     'business': "Fruts Express",
    //     'storeId': "storeId",
    //     'info': "createMonthReportJson()",
    //   }).whenComplete(() =>
    //       // Navigator.push(context,
    //       print("Done")
    //   );
    // }catch(e) {
    //   print(e);
    // }
                      // showModalBottomSheet(isScrollControlled: true, context: context, builder: (context) {
                      //   return
                      //     Scaffold(
                      //         backgroundColor: kBlack,
                      //         appBar: AppBar(
                      //           automaticallyImplyLeading: false,
                      //           backgroundColor: kBlack,
                      //           foregroundColor: kPureWhiteColor,
                      //         ),
                      //
                      //         body: Column(
                      //           children: [
                      //             ExpandableVideoPlayer(videoUrl: youtubeLink),
                      //             kLargeHeightSpacing,
                      //             TextButton(onPressed: (){Navigator.pop(context);}, child: Text("Go Back", style: kNormalTextStyle.copyWith(color: kPureWhiteColor),))
                      //           ],
                      //         ));
                      // });


                      // Add your continue button functionality here
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kCustomColor,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    child: Text('Looks Good!'),
                  ),
                  // kMediumWidthSpacing,
                  // ElevatedButton(
                  //   onPressed: () {
                  //     Navigator.pop(context);
                  //     // function();
                  //
                  //     // Add your continue button functionality here
                  //   },
                  //   style: ElevatedButton.styleFrom(
                  //     primary: Colors.white,
                  //     onPrimary:kBlack,
                  //     shape: RoundedRectangleBorder(
                  //       borderRadius: BorderRadius.circular(10.0),
                  //     ),
                  //   ),
                  //   child: Text("Cancel"),
                  // ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}