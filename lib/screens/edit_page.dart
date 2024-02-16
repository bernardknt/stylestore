
import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:iconsax/iconsax.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';

import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stylestore/screens/change_store_photo.dart';
import 'package:stylestore/screens/sign_in_options/login_page.dart';
import 'package:stylestore/screens/store_setup.dart';
import 'package:stylestore/utilities/constants/icon_constants.dart';
import 'package:stylestore/utilities/constants/user_constants.dart';

import '../Utilities/constants/color_constants.dart';
import '../Utilities/constants/font_constants.dart';
import '../model/common_functions.dart';
import '../model/styleapp_data.dart';
import '../widgets/carousel_photo_widget.dart';
import '../widgets/dividing_line_widget.dart';
import '../widgets/locked_widget.dart';
import '../widgets/rounded_buttons.dart';
import '../widgets/rounded_icon_widget.dart';

class EditShopPage extends StatefulWidget {
  static String id = 'beautician_page';


  @override
  State<EditShopPage> createState() => _EditShopPageState();
}


class _EditShopPageState extends State<EditShopPage> {
  var urlImages = [];
  var location = 'Kyambogo';
  var treatmentTime = 30;
  var beauticianName = 'Nazz beauty';
  var beauticianSells = true;
  var trueImage = '';

  // THIS IS SERVICES VARIABLES
  var closingTime = [];
  var otherServices = [];
  var openTime = [];
  var beauticianNames = [];
  var beauticianImages = [];
  var doesMobile = [];
  var phoneNumber = '';
  var businessName = '';
  var businessLocation = '';

  var phone = [];
  var deliveryFee = "0";
  var blackout = [];
  var storeId = '';
  DateTime opening = DateTime.now();
  DateTime closing = DateTime.now();

  var onlineSwitchValue = true;
  var mobileSwitchValue = true;
  var activeStatus = 'Open';
  var userName = '';
  Map<String, dynamic> permissionsMap = {};


  void defaultInitialisation()async {
    final prefs = await SharedPreferences.getInstance();
    permissionsMap = await CommonFunctions().convertPermissionsJson();
    storeId = prefs.getString(kStoreIdConstant) ?? 'Hi';
    trueImage = prefs.getString(kImageConstant)!;
    userName = prefs.getString(kLoginPersonName)!;
    onlineSwitchValue = Provider.of<StyleProvider>(context, listen: false).isActive;

    // onlineSwitchValue = Provider.of<StyleProvider>(context, listen: false).does;

    setState((){
      if(onlineSwitchValue == false){
        activeStatus = 'Business Closed';
      }else {
        activeStatus = 'Business Open';
      }
    });
  }


  @override
  void initState() {
    // TODO: implement initState

    super.initState();
    defaultInitialisation();
  }


  @override

  Widget build(BuildContext context) {

    var styleData = Provider.of<StyleProvider>(context, listen: false);
    var styleDataDisplay = Provider.of<StyleProvider>(context);




    return Scaffold(
      backgroundColor: kBackgroundGreyColor,
      appBar: AppBar(
        leading: GestureDetector(
            onTap: (){

              // Provider.of<StyleProvider>(context, listen: false).beauticianCarouselClear();
              Navigator.pop(context);},
            child: Icon(Icons.arrow_back, color: kBlueDarkColor,)),
        backgroundColor: Colors.white,
      ),

      body: permissionsMap['admin'] == false ? LockedWidget(page: "Admin"):SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
              children: [

                // CarouselWidget(urlImages: urlImages),
                Stack(
                    children: [
                  //BannerPictureRoundedEdges(image: styleData.beauticianImageUrl),
                  // CarouselPhotosWidget(urlImages: styleData.beauticianClients),
                  Center(
                    child: Image.asset("images/new_logo.png",
                      height: 200,
                    ),
                  ),
                  Positioned(
                      bottom: 10,
                      left: 10,

                      child:
                      GestureDetector(
                        onTap: (){
                          // buildShowDialog(context);
                          Navigator.pushNamed(context, ChangeStorePhoto.id);

                        },
                        child: Stack(children: [
                          RoundImageRing(radius: 120, outsideRingColor: kPureWhiteColor, networkImageToUse: Provider.of<StyleProvider>(context).beauticianImageUrl,),
                          Positioned(
                              top: 5,
                              right: 5,
                              child: CircleAvatar(
                                  backgroundColor: kBlueDarkColorOld,
                                  child: Icon(LineIcons.pen, color: kPureWhiteColor,)))

                        ]),
                      ),
                      //Text(styleData.beauticianName, style: kHeadingTextStyleGold,))

                  )
                ]
                  ),



                // ),
                // kLargeHeightSpacing,
                //
                // ListTile(
                //   leading: Icon(LineIcons.walking),
                //   title: Text("Mobile Services", style: kNormalTextStyle.copyWith(),),
                //   subtitle: Text(activeStatus, style: kNormalTextStyle.copyWith(fontSize: 12),),
                //   trailing: buildSwitch(),
                // ),
                // kLargeHeightSpacing,


                ListTile(
                  leading: kIconStore,
                  title: Text(styleDataDisplay.beauticianName, style: kNormalTextStyle.copyWith(fontSize: 15),),
                  trailing: GestureDetector(
                      onTap: (){
                        // buildShowDialog(context);
                        CoolAlert.show(

                            lottieAsset: 'images/details.json',
                            context: context,
                            type: CoolAlertType.success,
                            widget: SingleChildScrollView(

                                child:
                                Container(
                                  child: Column(
                                    children: [

                                      TextField(
                                        // controller: TextEditingController!..text = "",
                                        controller: TextEditingController()..text = styleDataDisplay.beauticianName,
                                        keyboardType: TextInputType.text,

                                        onChanged: (customerNumber){
                                          businessName = customerNumber;

                                        },
                                        decoration: InputDecoration(

                                          // border: InputBorder.none,
                                            labelText: 'Business Name',
                                            labelStyle: kNormalTextStyleExtraSmall,

                                            hintText:  '',
                                            hintStyle: kNormalTextStyle
                                        ) ,
                                      ),
                                    ],
                                  ),
                                )
                            ),
                            // text: 'Enter customers details',
                            title: 'Business Name',
                            confirmBtnText: 'Ok',
                            showCancelBtn: true,
                            confirmBtnColor: Colors.green,
                            backgroundColor: kBlueDarkColor,
                            onConfirmBtnTap: () async
                            {
                              final prefs = await SharedPreferences.getInstance();
                              prefs.setString(kBusinessNameConstant, businessName);
                              print("Value set to businessName");
                              CommonFunctions().updateOnlineStoreInfo(storeId, "name", businessName);
                              setState(() {

                              });
                              Navigator.pop(context);

                            }
                        );

                      },
                      child: Icon(LineIcons.pen, color: kAppPinkColor,)),
                ),

                DividingLine(),
                ListTile(
                  leading: kIconCustomer,
                  title: Text(userName, style: kNormalTextStyle.copyWith(),),
                  trailing: GestureDetector(
                      onTap: (){
                        // buildShowDialog(context);
                        CoolAlert.show(

                            lottieAsset: 'images/details.json',
                            context: context,
                            type: CoolAlertType.success,
                            widget: SingleChildScrollView(

                                child:
                                Container(
                                  child: Column(
                                    children: [

                                      TextField(
                                        // controller: TextEditingController!..text = "",
                                        controller: TextEditingController()..text = userName,
                                        keyboardType: TextInputType.text,

                                        onChanged: (customerNumber){
                                          userName = customerNumber;

                                        },
                                        decoration: InputDecoration(

                                          // border: InputBorder.none,
                                            labelText: 'Your Name',
                                            labelStyle: kNormalTextStyleExtraSmall,

                                            hintText:  '',
                                            hintStyle: kNormalTextStyle
                                        ) ,
                                      ),
                                    ],
                                  ),
                                )
                            ),
                            // text: 'Enter customers details',
                            title: 'Your Name',
                            confirmBtnText: 'Ok',
                            showCancelBtn: true,
                            confirmBtnColor: Colors.green,
                            backgroundColor: kBlueDarkColor,
                            onConfirmBtnTap: () async
                            {
                              final prefs = await SharedPreferences.getInstance();
                              prefs.setString(kLoginPersonName, userName);
                              print("Value set to businessName");
                              CommonFunctions().updateOnlineStoreInfo(storeId, "ownerName", userName);
                              Navigator.pop(context);
                              setState(() {

                              });
                            }
                        );

                      },
                      child: Icon(LineIcons.pen, color: kAppPinkColor,)),

                ),

                ListTile(
                  leading: kIconLocation,
                  title: Text(styleDataDisplay.beauticianLocation, style: kNormalTextStyle.copyWith(),),
                  trailing: GestureDetector(
                      onTap: (){
                        CoolAlert.show(

                            lottieAsset: 'images/details.json',
                            context: context,
                            type: CoolAlertType.success,
                            widget: SingleChildScrollView(

                                child:
                                Container(
                                  child: Column(
                                    children: [

                                      TextField(
                                        // controller: TextEditingController!..text = "",
                                        controller: TextEditingController()..text = styleDataDisplay.beauticianLocation,
                                        keyboardType: TextInputType.text,

                                        onChanged: (customerLocation){
                                          businessLocation = customerLocation;

                                        },
                                        decoration: InputDecoration(

                                          // border: InputBorder.none,
                                            labelText: 'Business Location',
                                            labelStyle: kNormalTextStyleExtraSmall,

                                            hintText:  '',
                                            hintStyle: kNormalTextStyle
                                        ) ,
                                      ),
                                    ],
                                  ),
                                )
                            ),
                            // text: 'Enter customers details',
                            title: 'Business Location',
                            confirmBtnText: 'Ok',
                            showCancelBtn: true,
                            confirmBtnColor: Colors.green,
                            backgroundColor: kBlueDarkColor,
                            onConfirmBtnTap: ()async{
                              final prefs = await SharedPreferences.getInstance();
                              prefs.setString(kLocationConstant, businessLocation);
                              CommonFunctions().updateOnlineStoreInfo(storeId, "location", businessLocation);

                              Navigator.pop(context);
                              setState(() {

                              });
                            }
                        );
                      },
                      child: Icon(LineIcons.pen, color: kAppPinkColor,)),
                ),
                ListTile(
                  leading: kIconClockOpen,
                  title: Text("${DateFormat('h aa').format(DateTime(2022,1,1,Provider.of<StyleProvider>(context, listen: false).openingTime,0))}", style: kNormalTextStyle.copyWith(),),
                  subtitle: Text('Opening Time', style: kNormalTextStyle.copyWith(fontSize: 12),),
                  trailing: GestureDetector(
                      onTap: (){
                        // buildShowDialog(context);
                        // DatePicker.showTimePicker(context,
                        //     currentTime: DateTime(2022,12,9,10,00),
                        //     showSecondsColumn: false,
                        //     // theme: const DatePickerTheme(itemHeight: 50, itemStyle: kHeadingTextStyle),
                        //
                        //     //showTitleActions: t,
                        //
                        //     onConfirm: (time){
                        //
                        //
                        //       CommonFunctions().updateOnlineStoreInfo(storeId, "open", time.hour);
                        //
                        //
                        //       // deliveryTime = date;
                        //
                        //
                        //
                        //
                        //     });

                      },
                      child: kIconPen),
                ),
                ListTile(
                  leading: kIconClockClose,
                  title: Text("${DateFormat('h aa').format(DateTime(2022,1,1,Provider.of<StyleProvider>(context, listen: false).closingTime,0))}", style: kNormalTextStyle.copyWith(),),
                  subtitle: Text('Closing Time', style: kNormalTextStyle.copyWith(fontSize: 12),),
                  trailing: GestureDetector(
                      onTap: (){
                        // DatePicker.showTimePicker(context,
                        //     currentTime: DateTime(2022,12,9,10,00),
                        //     showSecondsColumn: false,
                        //     // theme: const DatePickerTheme(itemHeight: 50, itemStyle: kHeadingTextStyle),
                        //
                        //     //showTitleActions: t,
                        //
                        //     onConfirm: (time){
                        //       // DateTime opening = DateTime(2022,1,1,Provider.of<StyleProvider>(context, listen: false).openingTime,0);
                        //       // DateTime closing = DateTime(2022,1,1,Provider.of<StyleProvider>(context, listen: false).closingTime,0);
                        //       // DateTime selectedDateTime = DateTime(value.date!.year,value.date!.month,value.date!.day,time.hour, time.minute);
                        //       // var referenceTime = DateTime(2022,1,1,0,0);
                        //
                        //       CommonFunctions().updateOnlineStoreInfo(storeId, "close", time.hour);
                        //
                        //
                        //       // deliveryTime = date;
                        //
                        //
                        //
                        //
                        //     });
                      },
                      child: kIconPen),
                ),ListTile(
                  leading: kIconPhone,
                  title: Text(styleDataDisplay.beauticianPhoneNumber, style: kNormalTextStyle.copyWith(),),
                  trailing: GestureDetector(
                      onTap: (){
                        CoolAlert.show(

                            lottieAsset: 'images/details.json',
                            context: context,
                            type: CoolAlertType.success,
                            widget: SingleChildScrollView(

                                child:
                                Container(
                                  child: Column(
                                    children: [

                                      TextField(
                                        // controller: TextEditingController!..text = "",
                                        keyboardType: TextInputType.number,

                                        onChanged: (customerNumber){
                                          phoneNumber = customerNumber;

                                        },
                                        decoration: InputDecoration(

                                          // border: InputBorder.none,
                                            labelText: 'Phone Number',
                                            labelStyle: kNormalTextStyleExtraSmall,

                                            hintText:  '0771231233',
                                            hintStyle: kNormalTextStyle
                                        ) ,
                                      ),
                                    ],
                                  ),
                                )
                            ),
                            // text: 'Enter customers details',
                            title: 'Business Phone Number',
                            confirmBtnText: 'Ok',
                            showCancelBtn: true,
                            confirmBtnColor: Colors.green,
                            backgroundColor: kBlueDarkColor,
                            onConfirmBtnTap: (){


                              CommonFunctions().updateOnlineStoreInfo(storeId, "phone", phoneNumber);

                              Navigator.pop(context);
                              setState(() {

                              });
                            }
                        );
                        
                      },
                      child: kIconPen),
                ),
                ListTile(
                  leading: kIconStore,
                  title: Text(activeStatus, style: kNormalTextStyle.copyWith(),),
                  subtitle: Text(activeStatus, style: kNormalTextStyle.copyWith(fontSize: 12),),
                  trailing: buildSwitch(),
                ),

                // ListTile(
                //   leading: kIconBlackout,
                //   title: Text("Blackout Dates", style: kNormalTextStyle.copyWith(),),
                //   subtitle: Text('${styleDataDisplay.calendarBlackouts.length}', style: kNormalTextStyle.copyWith(fontSize: 12),),
                //   trailing: GestureDetector(
                //       onTap: (){
                //         buildShowDialog(context);
                //       },
                //       child: kIconPen),
                // ),
                //
                // ListTile(
                //   leading: Icon(LineIcons.car, color: kAppPinkColor,),
                //   title: Text("Mobile Services Fee", style: kNormalTextStyle.copyWith(),),
                //   subtitle: Text('${CommonFunctions().formatter.format(styleDataDisplay.beauticianTransport)} Ugx', style: kNormalTextStyle.copyWith(fontSize: 12),),
                //   trailing: GestureDetector(
                //       onTap: (){
                //         CoolAlert.show(
                //
                //             lottieAsset: 'images/details.json',
                //             context: context,
                //             type: CoolAlertType.success,
                //             widget: SingleChildScrollView(
                //
                //                 child:
                //                 Container(
                //                   child: Column(
                //                     children: [
                //
                //                       TextField(
                //                         keyboardType: TextInputType.number,
                //
                //                         onChanged: (mobileServices){
                //                           deliveryFee = mobileServices;
                //
                //                         },
                //                         decoration: InputDecoration(
                //
                //                           // border: InputBorder.none,
                //                             labelText: 'Amount',
                //                             labelStyle: kNormalTextStyleExtraSmall,
                //
                //                             hintText:  '10000',
                //                             hintStyle: kNormalTextStyle
                //                         ) ,
                //                       ),
                //                     ],
                //                   ),
                //                 )
                //             ),
                //             // text: 'Enter customers details',
                //             title: 'Amount to Provide Mobile Services',
                //             confirmBtnText: 'Ok',
                //             confirmBtnColor: Colors.green,
                //             backgroundColor: kBlueDarkColor,
                //             onConfirmBtnTap: (){
                //
                //
                //               CommonFunctions().updateOnlineStoreInfo(storeId, "transport", int.parse(deliveryFee));
                //
                //               Navigator.pop(context);
                //             }
                //         );
                //       },
                //       child: kIconPen),
                // ),


                kLargeHeightSpacing,

              ]

          ),
        ),
      ),
    );
  }

  Future<dynamic> buildShowDialog(BuildContext context) {
    return showDialog(context: context, builder: (BuildContext context){
    return
      CupertinoAlertDialog(
        title: Text('ACTIVATE ACCOUNT', style: kHeading2TextStyleBold.copyWith(color: kAppPinkColor),),
        content: Text('To be able to edit this account must first be activated. Contact us on +256782081219 for more details.', style: kNormalTextStyle.copyWith(color: kBlack),),
        actions: [
          // CupertinoDialogAction(
          //     onPressed: (){
          //
          //     },
          //     child: Text('UnSubscribe',
          //       style: TextStyle(color: Colors.grey[800], fontWeight: FontWeight.bold),)),
          CupertinoDialogAction(isDestructiveAction: true,
              onPressed: (){
                Navigator.pop(context);
              },

              child: Text('Cancel',)), ],
      );
  });
  }

  Widget buildSwitch() => Switch.adaptive(
      activeColor: kGreenThemeColor,
      inactiveThumbColor: kAppPinkColor,

      //inactiveTrackColor: kAirPink,

      value: onlineSwitchValue,
      onChanged: (value){
          if (value == false){
            activeStatus = 'Business Closed';
            setState(()async{
              final prefs = await SharedPreferences.getInstance();
              onlineSwitchValue = value;
              CommonFunctions().updateOnlineStoreInfo(storeId, "active", value);
              Provider.of<StyleProvider>(context, listen: false).setLiveIndicatorValues(Colors.red, 'Closed');
              prefs.setString(kLiveString, 'Open');
              // location = Provider.of<StyleProvider>(context, listen: false).beauticianLocation;
              // Provider.of<StyleProvider>(context, listen: false).setLocationOfAppointment(location, value);
              // print(value);
            });
          }else {
            activeStatus = 'Business Open';
            setState(()async{
              final prefs = await SharedPreferences.getInstance();

              onlineSwitchValue = value;
              CommonFunctions().updateOnlineStoreInfo(storeId, "active", value);
              Provider.of<StyleProvider>(context, listen: false).setLiveIndicatorValues(kGreenThemeColor, 'Open');
              prefs.setString(kLiveString, 'Open');
              // location = Provider.of<StyleProvider>(context, listen: false).beauticianLocation;
              // Provider.of<StyleProvider>(context, listen: false).setLocationOfAppointment(location, value);
              // print(value);
            });

          }
      }


  );
}












