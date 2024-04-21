
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stylestore/model/common_functions.dart';
import 'package:stylestore/model/styleapp_data.dart';
import 'package:stylestore/utilities/basket_items.dart';
import 'package:stylestore/utilities/constants/color_constants.dart';
import 'package:stylestore/utilities/constants/icon_constants.dart';
import 'package:stylestore/utilities/constants/user_constants.dart';
import 'package:stylestore/utilities/customer_items.dart';
import 'package:stylestore/widgets/customer_content.dart';
import 'package:stylestore/widgets/order_contents.dart';
import 'package:stylestore/widgets/rounded_buttons.dart';
import 'package:uuid/uuid.dart';
import 'dart:math';

import '../../Utilities/constants/font_constants.dart';
import '../../utilities/InputFieldWidget.dart';
var uuid = Uuid();


class AddCustomersPage extends StatefulWidget {
  static String id = 'add_customers_page';
  @override
  _AddCustomersPageState createState() => _AddCustomersPageState();
}

class _AddCustomersPageState extends State<AddCustomersPage> {
  final _auth = FirebaseAuth.instance;
  final RoundedLoadingButtonController _btnController = RoundedLoadingButtonController();
  File? image;
  var imageUploaded = false;
  final storage = FirebaseStorage.instance;
  String serviceId = 'sp${uuid.v1().split("-")[0]}';
  UploadTask? uploadTask;

  CollectionReference customerProvided = FirebaseFirestore.instance.collection('customers');


  void defaultInitialization() async{
    final prefs = await SharedPreferences.getInstance();
    final initials = prefs.getString(kBusinessNameConstant)?.split(' ')
        .map((word) => word.isNotEmpty ? word[0].toUpperCase() : '')
        .join('');
    customerId = 'customer${initials}${uuid.v1().split("-")[0]}';
    containerToShow =
        Container(
      height: 270,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        // crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Opacity(
              opacity: changeInvalidMessageOpacity,
              child: Text(invalidMessageDisplay, style: const TextStyle(color:Colors.red , fontSize: 12),)),
          InputFieldWidget(labelText:' Customer Name' ,hintText: '', keyboardType: TextInputType.text, onTypingFunction: (value){
            customerName = value;

          },),
          InputFieldWidget(labelText: ' Phone Number', hintText: '', keyboardType: TextInputType.number, onTypingFunction: (value){
            phoneNumber = value;
          }),
          InputFieldWidget(labelText: ' Location', hintText: '', keyboardType: TextInputType.text, onTypingFunction: (value){
            location = value;
          }),

          InputFieldWidget(labelText: ' Note', hintText: 'Likes fitting shirts', keyboardType: TextInputType.text, onTypingFunction: (value){
            description = value;
          }),
          // SizedBox(height: 8.0,),

        ],
      ),
    );

    setState(() {

    });

  }
  Future pickImage(ImageSource source)async{
    try {
      final image = await ImagePicker().pickImage(source: source);
      // await ImagePicker().pickImage(source: ImageSource.gallery);

      if (image == null){
        return ;
      }else {
        var file = File(image.path);

        final compressedImage = await CommonFunctions().compressImage(File(image.path));

        setState(() {
          imageUploaded = true;
          this.image = compressedImage;
        });
      }
    } on PlatformException catch (e) {
      print('Failed to pick image $e');

    }
  }

  Future<void> addCustomer(urlToPhoto) async{
    final prefs = await SharedPreferences.getInstance();
    String account = prefs.getString(kLoginPersonName) ?? "";
    // Call the user's CollectionReference to add a new user
    return customerProvided.doc(customerId)
        .set({
      'id':customerId,
      'image': image != null ? urlToPhoto : "https://mcusercontent.com/f78a91485e657cda2c219f659/images/db929836-bf22-1b6d-9c82-e63932ac1fd2.png",
      'active': true,
      'phoneNumber': phoneNumber,
      'location': location,
      'category': 'main',
      'hasOptions': true,
      'info': description,
      'name': CommonFunctions().removeLeadingTrailingSpaces(customerName),
      'updateBy': account,
      'options':  optionsToUpload,
      'storeId': prefs.getString(kStoreIdConstant),
    })
        .then((value) => print("Service Added"))
        .catchError((error) => print("Failed to add service: $error"));
  }
  Future<void> uploadPhoto(String filePath, String fileName)async {
    File file = File(filePath);
    try {
      uploadTask  = storage.ref('customer/$fileName').putFile(file);
      final snapshot = await uploadTask!.whenComplete((){

      });
      final urlDownload = await snapshot.ref.getDownloadURL();
      print("KIWEEEEEEDDDEEEEEEEEEEEEEE: $urlDownload");
      addCustomer(urlDownload);
      // Navigator.pushNamed(context, ControlPage.id);
    }  catch(e){
      print(e);
    }
  }


  String customerId = "";
  String description= '';
  String phoneNumber= "";
  String location= "";

  double changeInvalidMessageOpacity = 0.0;
  String invalidMessageDisplay = 'Invalid Number';
  String password = '';
  String customerName = '';
  String optionName = '';
  String optionValue = "";
  Container containerToShow = Container();
  Map<String, String> optionsToUpload = {};
  late List<CustomerItem> options;


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
      appBar: AppBar(title: Text('Create Customer', style: kNormalTextStyle.copyWith(color: kBlueDarkColorOld)),
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
              child: Text("Add Customer Information",textAlign: TextAlign.start, style: kHeading3TextStyleBold.copyWith(fontSize: 16, ),),
            ),

            containerToShow,
            Padding(
              padding: const EdgeInsets.only(left: 20.0, right: 20, bottom: 10),

              child:

              image != null ?
              Image.file(image!, height: 150,) :
              GestureDetector(
                onTap: (){
                  pickImage(ImageSource.gallery);
                },
                child: Container(
                  width: 150,
                  height: 150,
                  // Lottie.asset('images/scan.json'),
                  decoration: BoxDecoration(

                      border: Border.all(color: kFontGreyColor),

                      borderRadius: const BorderRadius.all(Radius.circular(0)),
                      color: kBlack),
                  child:
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Icon(Icons.photo_camera_front_outlined, color: kBlack,size: 30,),
                      Text("Add Customer Photo", style: kNormalTextStyle.copyWith(color: kPureWhiteColor, fontWeight: FontWeight.w500, fontSize: 14,),),
                    ],
                  ),


                ),
              ),
            ),


            Padding(
              padding: const EdgeInsets.only(left: 50.0, right: 50),
              child: RoundedButtons(buttonHeight: 40, buttonColor: kAppPinkColor, title: 'Add Customer Options', onPressedFunction: (){

                if ( customerName == '' || phoneNumber == 0){


                }else{
                  showDialog(context: context, builder: (BuildContext context){
                    return
                      GestureDetector(
                        onTap: (){
                          Navigator.pop(context);
                        },
                        child: Material(
                          color: Colors.transparent,
                          child: Stack(
                            children: [

                              CupertinoAlertDialog(
                                title:  const Text('Enter Extra Customer Field options below', style: kNormalTextStyle,),
                                content:Column(
                              children: [
                              // const Text('Enter Customer Information option below', style: kNormalTextStyle,),
                              // kLargeHeightSpacing,
                              Row(
                                  children: [

                                    InputFieldWidget(labelText:' Option' ,hintText: 'Height', keyboardType: TextInputType.text, onTypingFunction: (value){
                                      optionName = value;
                                    },),
                                    InputFieldWidget(labelText:' Value' ,hintText: '170cm', keyboardType: TextInputType.text, onTypingFunction: (value){
                                      optionValue = value;
                                    },
                                    ),
                                  ]
                              )

                            ],
                          ),



                                actions: [
                                  CupertinoDialogAction(isDestructiveAction: true,
                                    onPressed: (){
                                      // _btnController.reset();
                                      Navigator.pop(context);
                                    },
                                    child: const Text('Cancel')
                                ),
                                  CupertinoDialogAction(isDefaultAction: true,
                                      onPressed: (){


                                              containerToShow = Container(
                                                child: Padding(
                                                  padding: const EdgeInsets.all(10.0),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      Text('$customerName Information Captured', style: kHeading2TextStyleBold.copyWith(color: kGreenThemeColor, fontSize: 14),),
                                                      Icon(Iconsax.tick_circle, color: kGreenThemeColor,),


                                                    ],
                                                  ),
                                                ),
                                              );

                                              Provider.of<StyleProvider>(context, listen: false).addToCustomerUploadItem(CustomerItem(optionValue: optionValue, name: optionName));
                                              options =  Provider.of<StyleProvider>(context, listen: false).basketCustomerOptionsToUpload;

                                              optionsToUpload.addAll({optionName: optionValue});

                                              Navigator.pop(context);


                                      },
                                      child: const Text('Add')
                                  )
                                ],
                              ),

                            ],
                          ),
                        ),
                      );
                  });
                  // CoolAlert.show(
                  //   // lottieAsset: 'images/booking.json',
                  //     context: context,
                  //     type: CoolAlertType.custom,
                  //     // title: "Enter option",
                  //     widget: Column(
                  //       children: [
                  //         const Text('Enter Customer Information option below', style: kNormalTextStyle,),
                  //         kLargeHeightSpacing,
                  //         Row(
                  //             children: [
                  //
                  //               InputFieldWidget(labelText:' Option Name' ,hintText: 'Height', keyboardType: TextInputType.text, onTypingFunction: (value){
                  //                 optionName = value;
                  //               },),
                  //               InputFieldWidget(labelText:' Option Value' ,hintText: '170cm', keyboardType: TextInputType.text, onTypingFunction: (value){
                  //                 optionValue = value;
                  //               },
                  //               ),
                  //             ]
                  //         )
                  //
                  //       ],
                  //     ),
                  //     confirmBtnText: 'Yes',
                  //     confirmBtnColor: kBlueDarkColorOld,
                  //     cancelBtnText: 'Cancel',
                  //     showCancelBtn: true,
                  //     backgroundColor: kPureWhiteColor,
                  //
                  //     onConfirmBtnTap: (){
                  //       containerToShow = Container(
                  //         child: Padding(
                  //           padding: const EdgeInsets.all(10.0),
                  //           child: Row(
                  //             mainAxisAlignment: MainAxisAlignment.center,
                  //             children: [
                  //               Text('$customerName Information Captured', style: kHeading2TextStyleBold.copyWith(color: kGreenThemeColor, fontSize: 14),),
                  //               Icon(Iconsax.tick_circle, color: kGreenThemeColor,),
                  //
                  //
                  //             ],
                  //           ),
                  //         ),
                  //       );
                  //
                  //       Provider.of<StyleProvider>(context, listen: false).addToCustomerUploadItem(CustomerItem(optionValue: optionValue, name: optionName));
                  //       options =  Provider.of<StyleProvider>(context, listen: false).basketCustomerOptionsToUpload;
                  //
                  //       optionsToUpload.addAll({optionName: optionValue});
                  //
                  //       Navigator.pop(context);
                  //
                  //     }
                  // );
                }
              }


              ),
            ),
            kSmallHeightSpacing,
            Opacity(
              opacity: 1,
              child:
              ListView.builder(


                  shrinkWrap: true,
                  itemCount: Provider.of<StyleProvider>(context).basketCustomerOptionsToUpload.length,
                  itemBuilder: (context, i) {
                    return CustomerContentsWidget(
                        orderIndex: i + 1,
                        optionName: options[i].name,
                        optionValue: options[i].optionValue);
                  })
            ),
            kLargeHeightSpacing,
            kLargeHeightSpacing,
            kLargeHeightSpacing,
            kLargeHeightSpacing,
            kLargeHeightSpacing,

            RoundedLoadingButton(
              color: kBlueDarkColorOld,
              child: Text('Add a new Customer', style: TextStyle(color: Colors.white)),
              controller: _btnController,
              onPressed: () async {
                if ( customerName == '' ){
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

                  image == null ? addCustomer("") : uploadPhoto(image!.path, serviceId);

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
