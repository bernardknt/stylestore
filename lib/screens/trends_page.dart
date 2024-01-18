import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:stylestore/screens/upload_trend.dart';
import '../../../Utilities/constants/color_constants.dart';
import '../../../Utilities/constants/font_constants.dart';
import '../../../Utilities/constants/user_constants.dart';
import '../utilities/constants/icon_constants.dart';
import '../widgets/rounded_icon_widget.dart';

class TrendsPage extends StatefulWidget {
  static String id = 'favourite_trend_page';

  @override
  _TrendsPageState createState() => _TrendsPageState();
}

class _TrendsPageState extends State<TrendsPage> {

  // void defaultsInitiation()async{
  //   final prefs = await SharedPreferences.getInstance();
  //   userEmail = prefs.getString(kEmailConstant)!;
  //   print('This line run');
  //
  //
  // }
  // OVERRIDE INITIAL STATE
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // defaultsInitiation();

  }

  // Variables
  String title = 'Your';
  String userEmail = 'bernard';
  var date = [];
  var amountList = [];
  var descList = [];
  var imgList = [];
  var titleList = [];
  var postId = [];
  var docIdList = [];
  var opacityList = [];
  var tokenList = [];
  var storeList = [];
  var locationList = [];
  var categoriesList = [];
  var token;
  var formatter = NumberFormat('#,###,000');
  @override

  Widget build(BuildContext context) {


    return Scaffold(
        backgroundColor: kBlack,
        floatingActionButtonLocation: FloatingActionButtonLocation.miniCenterFloat,
        floatingActionButton: FloatingActionButton(
            backgroundColor: kAppPinkColor,
            onPressed: (){
              // add Ingredient Here

              //Navigator.pushNamed(context, AddServicePage.id);
              Navigator.pushNamed(context, UploadTrendPage.id);
            },
            child: Icon(LineIcons.fire, color: kBlack,)
        ),
        appBar: AppBar(
          leading: GestureDetector(
              onTap: (){Navigator.pop(context);},
              child: Icon(Icons.arrow_back, color: kPureWhiteColor,)),

          backgroundColor: kBlack,


          title: Text('Your Trends', style: kNormalTextStyle.copyWith(color: kPureWhiteColor),),
        ),

        body:
        StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('favourites')

                .where('active', isEqualTo: true)
            // .where('email', isEqualTo: userId)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
              } else {
                date = [];
                descList = [];
                imgList = [];
                titleList = [];
                postId = [];
                opacityList = [];
                tokenList = [];
                storeList = [];
                amountList = [];
                categoriesList = [];
                locationList = [];
                docIdList = [];

                var appointments = snapshot.data!.docs;
                for (var appointment in appointments) {
                  if(appointment.get('email')==  'cathy@styleapp.com' ){
                    descList.add(appointment.get('description'));
                    imgList.add(appointment.get('image'));
                    titleList.add(appointment.get('beautician'));
                    postId.add(appointment.get('postId'));
                    storeList.add(appointment.get('storeId'));
                    categoriesList.add(appointment.get('categories'));
                    locationList.add(appointment.get('location'));
                    docIdList.add(appointment.get('docId'));
                    amountList.add(appointment.get('amount'));
                    date.add(appointment.get('date').toDate());

                  }


                }

              }
              return Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: ListView.builder(

                    itemCount: imgList.length,
                    itemBuilder: (context, index) {
                      if (imgList.length !=0){
                        return GestureDetector(
                          onTap: (){
                           // showDialogFunc(context, imgList[index], titleList[index], descList[index], amountList[index], postId[index],categoriesList[index], locationList[index],10000,true, 18,9 ); // transport, doesMobile, close, open

                          },
                          child:
                          Stack(
                              children: [
                                Card(
                                  color: Colors.white24,
                                  child: Row(
                                    children: [

                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child:
                                        Column(
                                          children: [
                                            RoundImageRing(networkImageToUse: imgList[index], outsideRingColor: kBeigeThemeColor, radius: 120,),

                                          ],
                                        ),
                                      ),
                                      Flexible(
                                        child: Padding(padding: EdgeInsets.all(10.0),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [

                                              Text('"${descList[index]}"',
                                                  overflow: TextOverflow.ellipsis,
                                                  style: kNormalTextStyleWhiteFavouritesItalic),

                                              kSmallHeightSpacing,

                                              Text('By ${titleList[index]}, Kyebando Kampala, Uganda',
                                                overflow: TextOverflow.fade,
                                                style:  kNormalTextStyleWhiteFavourites
                                                ,),
                                              kSmallHeightSpacing,
                                              Text(
                                                '@ ${formatter.format(amountList[index])} Ugx',
                                                overflow: TextOverflow.ellipsis,
                                                style:  kNormalTextStyleWhiteFavourites,),


                                            ],
                                          ),),
                                      ),
                                    ],
                                  ),
                                ),
                                Positioned(
                                    right: 10,
                                    top: 5,
                                    child: GestureDetector(
                                        onTap: (){
                                          CoolAlert.show(
                                              lottieAsset: 'images/question.json',
                                              context: context,
                                              type: CoolAlertType.success,
                                              text: "Are you sure you want to Remove this from favourites",
                                              title: "Remove Favourite",
                                              confirmBtnText: 'Yes',
                                              confirmBtnColor: Colors.red,
                                              cancelBtnText: 'Cancel',
                                              showCancelBtn: true,
                                              backgroundColor: kAppPinkColor,
                                              onConfirmBtnTap: (){
                                                // Provider.of<BlenditData>(context, listen: false).deleteItemFromBasket(blendedData.basketItems[index]);
                                              //  FirebaseServerFunctions().removePostFavourites(docIdList[index],postId[index], userEmail);

                                                Navigator.pop(context);
                                              }
                                          );

                                        },

                                        child: kIconCancel)),
                                Positioned(
                                    right: 5,
                                    bottom: 10,
                                    child: Text('${DateFormat('dd /MM/ yy').format(date[index])}', style: kNormalTextStyleExtraSmall,))
                              ]),
                        );
                      } else {
                        return Container(
                            child: Center(child: Text('You have no favourites yet'),)
                        );
                      }

                    }),
              );
            }
        )
    );
  }
}



