import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:stylestore/model/common_functions.dart';
import 'package:stylestore/widgets/TicketDots.dart';

import '../Utilities/constants/color_constants.dart';
import '../Utilities/constants/font_constants.dart';
import '../model/styleapp_data.dart';
import '../utilities/constants/icon_constants.dart';


class ReviewsPage extends StatelessWidget {
  // ReviewsPage({required this.storeId});
  // final double storeId;

  static String id = 'ReviewPage';


  var reviewComment = [];
  var reviewRating = [];
  var reviewSender = [];
  var reviewTime= [];
  var reviewerImage= [];
  var reviewerDate= [];
  var reviewerHasPic= [];
  var picOpacity = [];
  var reviewerPics = [];
  //  List <String> premisesUrlImages = ["https://mcusercontent.com/f78a91485e657cda2c219f659/images/0676bf80-7b87-d87e-5dc9-8aee87f24c65.jpeg", "https://mcusercontent.com/f78a91485e657cda2c219f659/images/ea86d963-d59c-ddd4-5f41-f7cd8b7c9d6f.jpeg"];


  @override
  Widget build(BuildContext context) {
    var styleData = Provider.of<StyleProvider>(context, listen: false);
    return Scaffold(
      backgroundColor: kBlack,
      appBar: AppBar(
        foregroundColor: kAppPinkColor,
        backgroundColor: kBlack,
        title: Text("Customer Reviews", style: kNormalTextStyle,),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Row(
                children: [
                  Icon(Icons.star, color: kPureWhiteColor,),
                  kSmallWidthSpacing,
                  Text('Rating', style: kHeadingExtraLargeTextStyle.copyWith(color: kPureWhiteColor, fontSize: 15),),
                  kSmallWidthSpacing,
                  Container(color: kFaintGrey, height: 20, width: 1,),
                  kSmallWidthSpacing,
                  Text("from ${Provider.of<StyleProvider>(context, listen: false).beauticianReviewNumber.toString()} reviews", style: kHeadingExtraLargeTextStyle.copyWith(color: kPureWhiteColor, fontSize: 15),),
                ],
              ),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('reviews')
                // .orderBy('time',descending: true)
                    .where('stylist', isEqualTo: styleData.beauticianId

                )
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {



                    return Center(child: const Text('No Reviews Yet', style: kHeading2TextStyleBold,),);
                  } else {
                    reviewComment = [];
                    reviewRating = [];
                    reviewSender = [];
                    reviewTime = [];
                    reviewerImage = [];
                    reviewerDate = [];
                    reviewerHasPic = [];
                    reviewerPics = [];

                    var reviews = snapshot.data!.docs;
                    for (var review in reviews) {
                      reviewComment.add(review.get('comment'));
                      reviewRating.add(review.get('rating'));
                      reviewSender.add(review.get('sender'));
                      reviewTime.add(review.get('time'));
                      reviewerImage.add(review.get('image'));
                      reviewerDate.add(review.get('time').toDate());
                      reviewerHasPic.add(review.get('hasPic'));
                      reviewerPics.add(review.get('photo'));
                      if(review.get('hasPic')==true){
                        picOpacity.add(1.0);
                      }else {
                        picOpacity.add(0.0);
                      }


                    }

                  }
                  return ListView.builder(
                      shrinkWrap: true,
                      primary: false,
                      itemCount: reviewSender.length,
                      itemBuilder: (context, index){
                        //Provider.of<StyleProvider>(context, listen: false).setRatingsNumber(reviewComment.length);
                        return Container(
                          //width: double.infinity,
                          margin: EdgeInsets.only(top: 8, left:10, right: 16),
                          // decoration: BoxDecoration(
                          //    borderRadius: BorderRadius.circular(18),
                          // ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,

                            children: [

                              // Row(
                              //   children: [
                              //     RoundedIconButtons(networkImageToUse: reviewerImage[index], labelText: reviewSender[index], date: DateFormat('EEE-kk:mm aaa').format(reviewerDate[index]),),
                              //     kSmallWidthSpacing,
                              //     Opacity(
                              //       opacity: picOpacity[index],
                              //       child: IconButton(onPressed: (){
                              //         if(picOpacity[index]==1.0){
                              //           ShowPicturesDialogue(context, reviewerPics[index], reviewComment[index]);
                              //         }else {
                              //
                              //         }
                              //
                              //
                              //
                              //       }, icon: Icon(CupertinoIcons.camera_circle_fill, color:kAppPinkColor,)),
                              //     )
                              //   ],
                              // ),
                              kSmallHeightSpacing,
                              ListTile(
                                title: Text('${DateFormat('EEE-kk:mm aaa').format(reviewerDate[index])}', style: kNormalTextStyle.copyWith(color: kAppPinkColor, fontSize: 12),),
                                subtitle: Text(reviewComment[index], style: kNormalTextStyle.copyWith(color: kPureWhiteColor),),
                              ),
                              TicketDots(mainColor: kAppPinkColor, backgroundColor: kBlack,circleColor: kBlack,)

                              // RichText(text: TextSpan(text: reviewComment[index],
                              //   //style: TextStyle(fontSize: 15, color: Colors.white, fontWeight: FontWeight.bold),
                              //   style: kNormalTextStyleSmallBlack,
                              // ),
                              // ),
                              //
                            ],
                          ),
                        );
                      });
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}

