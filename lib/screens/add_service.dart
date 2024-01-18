
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stylestore/model/styleapp_data.dart';
import 'package:stylestore/utilities/basket_items.dart';
import 'package:stylestore/utilities/constants/color_constants.dart';
import 'package:stylestore/utilities/constants/icon_constants.dart';
import 'package:stylestore/utilities/constants/user_constants.dart';
import 'package:stylestore/widgets/order_contents.dart';
import 'package:uuid/uuid.dart';
import 'dart:math';

import '../Utilities/constants/font_constants.dart';
import '../utilities/InputFieldWidget.dart';
var uuid = Uuid();


class AddServicePage extends StatefulWidget {
  static String id = 'input_page';
  @override
  _AddServicePageState createState() => _AddServicePageState();
}

class _AddServicePageState extends State<AddServicePage> {
  final _auth = FirebaseAuth.instance;
  final RoundedLoadingButtonController _btnController = RoundedLoadingButtonController();
  final _random = new Random();
  CollectionReference items = FirebaseFirestore.instance.collection('items');
  CollectionReference ingredients = FirebaseFirestore.instance.collection('ingredients');
  CollectionReference serviceProvided = FirebaseFirestore.instance.collection('services');


  void defaultInitialization(){
     containerToShow = Container(
      height: 220,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        // crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Opacity(
              opacity: changeInvalidMessageOpacity,
              child: Text(invalidMessageDisplay, style: const TextStyle(color:Colors.red , fontSize: 12),)),
          InputFieldWidget(labelText:' Service Name' ,hintText: 'Hair cut', keyboardType: TextInputType.text, onTypingFunction: (value){
            serviceName = value;

          },),

          InputFieldWidget(labelText: ' Description', hintText: 'Cool and amazing haircut', keyboardType: TextInputType.text, onTypingFunction: (value){
            description = value;
          }),
          // SizedBox(height: 8.0,),
          InputFieldWidget(labelText: ' Base Price', hintText: '10000', keyboardType: TextInputType.number, onTypingFunction: (value){
            basePrice = int.parse(value);
          }),
        ],
      ),
    );
  }
  Future<void> addServices() async{
    final prefs = await SharedPreferences.getInstance();

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
      'category':'main',
      'updateBy': "Bernard Kangave",
      'options':  optionsToUpload,
      'storeId': prefs.getString(kStoreIdConstant),
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
  double optionValue = 0;
  double price = 0;
  Container containerToShow = Container();
  Map<String, double> optionsToUpload = {};
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
      appBar: AppBar(title: Text('Add New Service', style: kNormalTextStyle.copyWith(color: kBlueDarkColorOld)),
        backgroundColor: kPureWhiteColor,
      ),

      backgroundColor: kBackgroundGreyColor,
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
                if ( serviceName == '' || basePrice == 0){


                }else{
                  CoolAlert.show(
                    // lottieAsset: 'images/booking.json',
                      context: context,
                      type: CoolAlertType.custom,
                      // title: "Enter option",
                      widget: Column(
                        children: [
                          Text('Enter Service option below', style: kNormalTextStyle,),
                          kLargeHeightSpacing,
                          Row(
                              children: [

                                InputFieldWidget(labelText:' Option Name' ,hintText: 'Hair cut', keyboardType: TextInputType.text, onTypingFunction: (value){
                                  optionName = value;
                                },),
                                InputFieldWidget(labelText:' Option Price' ,hintText: '10000', keyboardType: TextInputType.number, onTypingFunction: (value){
                                  optionValue = double.parse(value);
                                },
                                ),
                              ]
                          )

                        ],
                      ),
                      confirmBtnText: 'Yes',
                      confirmBtnColor: kBlueDarkColorOld,
                      cancelBtnText: 'Cancel',
                      showCancelBtn: true,
                      backgroundColor: kPureWhiteColor,

                      onConfirmBtnTap: (){
                        containerToShow = Container(
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Service Information Captured', style: kHeading2TextStyleBold.copyWith(color: kGreenThemeColor),),
                                Icon(Iconsax.tick_circle, color: kGreenThemeColor,),


                              ],
                            ),
                          ),
                        );

                        Provider.of<StyleProvider>(context, listen: false).addToServiceUploadItem(BasketItem(amount: optionValue, quantity: 1, name: optionName, details: 'details', tracking: false));
                        options =  Provider.of<StyleProvider>(context, listen: false).basketServiceOptionsToUpload;

                          optionsToUpload.addAll({optionName: optionValue});

                        Navigator.pop(context);

                      }
                  );
                }
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
            kSmallHeightSpacing,
            Opacity(
              opacity: 1,
              child:
              ListView.builder(


                  shrinkWrap: true,
                  itemCount: Provider.of<StyleProvider>(context).basketServiceOptionsToUpload.length,
                  itemBuilder: (context, i){
                    return OrderedContentsWidget(
                      fontSize: 15,

                        orderIndex: i + 1,
                        productDescription: '1',
                        productName: options[i].name,
                        price: options[i].amount);
                  }),
             // OrderedContentsWidget(orderIndex: 0, productName: "Provider.of<StyleProvider>(context).basketUploadOption[0]", price: 10000)
            ),
            kLargeHeightSpacing,
            RoundedLoadingButton(
              color: kBlueDarkColorOld,
              child: Text('Add Service', style: TextStyle(color: Colors.white)),
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
