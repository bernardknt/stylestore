
import 'package:cloud_firestore/cloud_firestore.dart';
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
import '../widgets/text_form.dart';

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
  bool invoicePay = false;
  var businessName = '';
  var businessLocation = '';

  var phone = [];
  var deliveryFee = "0";
  var blackout = [];
  var storeId = '';
  DateTime opening = DateTime.now();
  DateTime closing = DateTime.now();

  var onlineSwitchValue = true;
  var invoiceSwitchValue = false;
  var mobileSwitchValue = true;
  var activeStatus = 'Open';
  var activeSwitchStatus = 'Open';
  var userName = '';
  Map<String, dynamic> permissionsMap = {};


  void defaultInitialisation()async {
    final prefs = await SharedPreferences.getInstance();
    permissionsMap = await CommonFunctions().convertPermissionsJson();
    storeId = prefs.getString(kStoreIdConstant) ?? 'Hi';
    trueImage = prefs.getString(kImageConstant)!;
    userName = prefs.getString(kLoginPersonName)!;
    invoicePay = prefs.getBool(kInvoicePay)?? false;

    onlineSwitchValue = Provider.of<StyleProvider>(context, listen: false).isActive;
    invoiceSwitchValue = invoicePay;

    // onlineSwitchValue = Provider.of<StyleProvider>(context, listen: false).does;
    if(invoiceSwitchValue == false){
      activeSwitchStatus = 'Invoice Pay';
    }else {
      activeSwitchStatus = 'Invoice Pay';
    }

    setState((){
      if(onlineSwitchValue == false){
        activeStatus = 'InvoicePay OFF';
      }else {
        activeStatus = 'InvoicePay ON';
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
        child: Center(
          child: Container(
            width: MediaQuery.of(context).size.width > 600 ? 400 : MediaQuery.of(context).size.width * 0.87,

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
                        child: Image.asset("images/store_design.png",
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
                      )
                    ]
                      ),
                    ListTile(
                      leading: kIconClockOpen,
                      title: Text(styleDataDisplay.beauticianName, style: kNormalTextStyle.copyWith(fontSize: 15),),
                      trailing: GestureDetector(
                          onTap: (){
                            buildShowEditDialog(context, styleDataDisplay.beauticianName, "Business Name", "business");
                          },
                          child: Icon(LineIcons.pen, color: kAppPinkColor,)),
                    ),

                    DividingLine(),


                    ListTile(
                      leading: kIconLocation,
                      title: Text(styleDataDisplay.beauticianLocation, style: kNormalTextStyle.copyWith(),),
                      trailing: GestureDetector(
                          onTap: (){
                            buildShowEditDialog(context, styleDataDisplay.beauticianLocation, "Location", "location");

                          },
                          child: Icon(LineIcons.pen, color: kAppPinkColor,)),
                    ),
                    ListTile(
                      leading: kIconClockOpen,
                      title: Text("${DateFormat('h aa').format(DateTime(2022,1,1,Provider.of<StyleProvider>(context, listen: false).openingTime,0))}", style: kNormalTextStyle.copyWith(),),
                      subtitle: Text('Opening Time', style: kNormalTextStyle.copyWith(fontSize: 12),),
                      trailing: GestureDetector(
                          onTap: (){

                          },
                          child: kIconPen),
                    ),
                    ListTile(
                      leading: kIconClockClose,
                      title: Text("${DateFormat('h aa').format(DateTime(2022,1,1,Provider.of<StyleProvider>(context, listen: false).closingTime,0))}", style: kNormalTextStyle.copyWith(),),
                      subtitle: Text('Closing Time', style: kNormalTextStyle.copyWith(fontSize: 12),),
                      trailing: GestureDetector(
                          onTap: (){
                          },
                          child: kIconPen),
                    ),ListTile(
                      leading: kIconPhone,
                      title: Text(styleDataDisplay.beauticianPhoneNumber, style: kNormalTextStyle.copyWith(),),
                      trailing: GestureDetector(
                          onTap: (){
                           buildShowEditDialog(context, styleDataDisplay.beauticianPhoneNumber, "Number", "number");

                          },
                          child: kIconPen),
                    ),
                    ListTile(
                      leading: kIconClockOpen,
                      title: Text(activeStatus, style: kNormalTextStyle.copyWith(),),
                      subtitle: Text(activeStatus, style: kNormalTextStyle.copyWith(fontSize: 12),),
                      trailing: buildSwitch(),
                    ),
                    // ListTile(
                    //   leading: kIconClockOpen,
                    //   title: Text(activeSwitchStatus, style: kNormalTextStyle.copyWith(),),
                    //   subtitle: Text(activeSwitchStatus, style: kNormalTextStyle.copyWith(fontSize: 12),),
                    //   trailing: buildInvoicePaySwitch(),
                    // ),
                    kLargeHeightSpacing,

                  ]

              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<dynamic> buildShowEditDialog(BuildContext context, String defaultValue, String reason, String field) {
    TextEditingController textController = TextEditingController()..text = defaultValue;

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return Material(
          color: Colors.transparent,
          child: CupertinoAlertDialog(
            title: Text('Edit $reason'),
            content: TextFormField(
              decoration: InputDecoration(labelText: reason),
              controller: textController,
            ),
            actions: [
              CupertinoDialogAction(
                isDestructiveAction: true,
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Cancel'),
              ),
              CupertinoDialogAction(
                isDefaultAction: true,
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  // Retrieve the value from the text controller
                  String newValue = textController.text;


                  await FirebaseFirestore.instance.collection('medics').doc(prefs.getString(kStoreIdConstant)).update({
                    field: newValue,
                  });

                  // Close the dialog
                  Navigator.pop(context);
                },
                child: Text('Update $reason'),
              ),
            ],
          ),
        );
      },
    );
  }


  Future<dynamic> buildShowDialog(BuildContext context) {
    return showDialog(context: context, builder: (BuildContext context){
    return
      CupertinoAlertDialog(
        title: Text('ACTIVATE ACCOUNT', style: kHeading2TextStyleBold.copyWith(color: kAppPinkColor),),
        content: Text('To be able to edit this account must first be activated. Contact us on +256782081219 for more details.', style: kNormalTextStyle.copyWith(color: kBlack),),
        actions: [
          CupertinoDialogAction(isDestructiveAction: true,
              onPressed: (){
                Navigator.pop(context);
              },

              child: Text('Cancel',)), ],
      );
  });
  }

  Widget buildInvoicePaySwitch() => Switch.adaptive(
      activeColor: kGreenThemeColor,
      inactiveThumbColor: kAppPinkColor,

      //inactiveTrackColor: kAirPink,

      value: invoiceSwitchValue,
      onChanged: (value){
        if (value == false){
          activeSwitchStatus = 'Pay with Invoice';
          setState(()async{
            final prefs = await SharedPreferences.getInstance();
            invoiceSwitchValue = value;
            //CommonFunctions().updateOnlineStoreInfo(storeId, "active", value);
            //Provider.of<StyleProvider>(context, listen: false).setLiveIndicatorValues(Colors.red, 'Closed');
           //prefs.setString(kLiveString, 'Open');
            // location = Provider.of<StyleProvider>(context, listen: false).beauticianLocation;
            // Provider.of<StyleProvider>(context, listen: false).setLocationOfAppointment(location, value);
            // print(value);
          });
        }else {
          activeSwitchStatus = 'No invoice Pay';
          setState(()async{
            final prefs = await SharedPreferences.getInstance();
          });

        }
      }


  );
  Widget buildSwitch() => Switch.adaptive(
      activeColor: kGreenThemeColor,
      inactiveThumbColor: kAppPinkColor,

      value: onlineSwitchValue,
      onChanged: (value){
          if (value == false){
            activeStatus = 'InvoicePay OFF';
            setState(()async{
              final prefs = await SharedPreferences.getInstance();
              onlineSwitchValue = value;
              prefs.setBool(kInvoicePay, false);
              // CommonFunctions().updateOnlineStoreInfo(storeId, "active", value);
              // Provider.of<StyleProvider>(context, listen: false).setLiveIndicatorValues(Colors.red, 'Closed');
              // prefs.setString(kLiveString, 'Open');

            });
          }else {
            activeStatus = 'InvoicePay ON';
            setState(()async{
              final prefs = await SharedPreferences.getInstance();


              onlineSwitchValue = value;
              prefs.setBool(kInvoicePay, true);
              // CommonFunctions().updateOnlineStoreInfo(storeId, "active", value);
              // Provider.of<StyleProvider>(context, listen: false).setLiveIndicatorValues(kGreenThemeColor, 'Open');
              // prefs.setString(kLiveString, 'Open');
            });

          }
      }


  );
}












