
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:stylestore/model/styleapp_data.dart';
import 'package:stylestore/screens/upload_trend.dart';
import 'package:stylestore/utilities/basket_items.dart';
import 'package:stylestore/utilities/constants/color_constants.dart';
import 'package:stylestore/utilities/constants/icon_constants.dart';
import 'package:stylestore/widgets/order_contents.dart';
import 'package:uuid/uuid.dart';
import 'dart:math';

import '../Utilities/constants/font_constants.dart';
import '../utilities/InputFieldWidget.dart';
var uuid = Uuid();


class AddTrendPage extends StatefulWidget {
  static String id = 'add_trend_input_page';
  @override
  _AddTrendPageState createState() => _AddTrendPageState();
}

class _AddTrendPageState extends State<AddTrendPage> {
  final _auth = FirebaseAuth.instance;
  final RoundedLoadingButtonController _btnController = RoundedLoadingButtonController();
  final _random = new Random();
  CollectionReference items = FirebaseFirestore.instance.collection('items');
  CollectionReference ingredients = FirebaseFirestore.instance.collection('ingredients');
  CollectionReference serviceProvided = FirebaseFirestore.instance.collection('services');


  void defaultInitialization(){
    containerToShow =
        Container(
      height: 180,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        // crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Opacity(
              opacity: changeInvalidMessageOpacity,
              child: Text(invalidMessageDisplay, style: TextStyle(color:Colors.red , fontSize: 12),)),
          InputFieldWidget(labelText:' Trend Name' ,hintText: 'Hair cut', keyboardType: TextInputType.text, onTypingFunction: (value){
            serviceName = value;

          },),

          // InputFieldWidget(labelText: ' Description', hintText: 'Cool and amazing haircut', keyboardType: TextInputType.text, onTypingFunction: (value){
          //   description = value;
          // }),
          // SizedBox(height: 8.0,),
          InputFieldWidget(labelText: ' Amount', hintText: '10000', keyboardType: TextInputType.number, onTypingFunction: (value){
            basePrice = int.parse(value);
          }),
        ],
      ),
    );
  }
  Future<void> addServices() {
    // Call the user's CollectionReference to add a new user
    return serviceProvided.doc(serviceId)
        .set({
      'id':serviceId,
      'active': true,
      'basePrice': basePrice,
      'category': 'main',
      'hasOptions': true,
      'info': description,
      'name': serviceName,
      'category':'haircut',
      'updateBy': "Bernard Kangave",
      'options':  optionsToUpload,
      'storeId': 'cat7b7171f0',
    })
        .then((value) => print("Service Added"))
        .catchError((error) => print("Failed to add service: $error"));
  }


  @override

  String serviceId = 'testServ${uuid.v1().split("-")[0]}';
  String description= '';
  int basePrice= 0;
  double changeInvalidMessageOpacity = 0.0;
  String invalidMessageDisplay = 'Invalid Number';
  String password = '';
  String serviceName = '';
  String optionName = '';
  int optionValue = 0;
  int price = 0;
  Container containerToShow = Container();
  Map<String, int> optionsToUpload = {};
  late List<BasketItem> options;


  //bool showSpinner = false;
  String errorMessage = 'Error Signing Up';
  double errorMessageOpacity = 0.0;
  String countryCode = ' ';
  double opacityOfTextFields = 1.0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    defaultInitialization();
  }


  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Post a Trend', style: kNormalTextStyle.copyWith(color: kPureWhiteColor)),
        backgroundColor: kBlack,
        leading: GestureDetector(
            onTap: (){Navigator.pop(context);},
            child: Icon(Icons.arrow_back, color: kPureWhiteColor,)),
      ),

      backgroundColor: kBlack,


      // appBar: AppBar(title: Text('Create Ingredient'),
      //   automaticallyImplyLeading: false,
      //   centerTitle: true,
      //   backgroundColor: Colors.black,),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 15.0, bottom: 15.0),
              child: Text("Enter Service Info",textAlign: TextAlign.start, style: kHeading3TextStyleBold.copyWith(fontSize: 16, ),),
            ),
            containerToShow,

            InkWell(
              onTap: (){
                Navigator.pushNamed(context, UploadTrendPage.id);

              },

              child: CircleAvatar(
                backgroundColor: kAppPinkColor,
                radius: 25,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add, color: kPureWhiteColor,size: 15,),
                    Text("Options", textAlign: TextAlign.center,style: kNormalTextStyleExtraSmall.copyWith(color: kPureWhiteColor),)
                  ],
                ),
              ),
            ),


            kLargeHeightSpacing,
            RoundedLoadingButton(
              color: kBabyPinkThemeColor,
              child: Text('Add Service', style: TextStyle(color: kAppPinkColor)),
              controller: _btnController,
              onPressed: () async {
                if ( serviceName == '' || Provider.of<StyleProvider>(context, listen: false).basketServiceOptionsToUpload.length == 0 || basePrice == 0){
                  _btnController.error();
                  showDialog(context: context, builder: (BuildContext context){
                    return
                      CupertinoAlertDialog(
                        title: Text('Oops Something is Missing'),
                        content: Text('Make sure you have filled in all the fields'),
                        actions: [CupertinoDialogAction(isDestructiveAction: true,
                            onPressed: (){
                              _btnController.reset();
                              Navigator.pop(context);
                            },
                            child: Text('Cancel'))],
                      );
                  });
                }else {
                  print(serviceName);
                  print(basePrice);

                  addServices();
                  // addItem();
                  // addItem();
                  Navigator.pop(context);
                  //Implement registration functionality.
                }
              },
            ),
            Opacity(
                opacity: errorMessageOpacity,
                child: Text(errorMessage, style: TextStyle(color: Colors.red),)),
          ],
        ),
      ),
    );
  }
}
