
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
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


class AddEmployeePage extends StatefulWidget {
  static String id = 'add_employee_page';
  @override
  _AddEmployeePageState createState() => _AddEmployeePageState();
}

class _AddEmployeePageState extends State<AddEmployeePage> {

  final RoundedLoadingButtonController _btnController = RoundedLoadingButtonController();
  File? image;
  var imageUploaded = false;
  var code = "";
  final storage = FirebaseStorage.instance;
  String serviceId = 'emp${uuid.v1().split("-")[0]}';
  UploadTask? uploadTask;


  CollectionReference customerProvided = FirebaseFirestore.instance.collection('employees');


  void defaultInitialization() async{
    final prefs = await SharedPreferences.getInstance();
    final initials = prefs.getString(kBusinessNameConstant)?.split(' ')
        .map((word) => word.isNotEmpty ? word[0].toUpperCase() : '')
        .join('');
    customerId = 'employee${initials}${uuid.v1().split("-")[0]}';
    containerToShow =
        Container(height: 180, child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          // crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Opacity(
                opacity: changeInvalidMessageOpacity,
                child: Text(invalidMessageDisplay, style: const TextStyle(color:Colors.red , fontSize: 12),)),
            InputFieldWidget(labelText:' Employee Full Name' ,hintText: '', keyboardType: TextInputType.text, onTypingFunction: (value){
              customerName = value;

            },),
            Padding(
              padding: const EdgeInsets.only(left:20.0, right: 20, top: 10, bottom: 8),
              child: Container(
                height: 53,
                decoration: BoxDecoration(
                    border: Border.all(width: 1, color: kAppPinkColor),
                    borderRadius: BorderRadius.circular(10)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 10,
                    ),
                    CountryCodePicker(
                      textStyle: kNormalTextStyle,

                      onInit: (value){
                        countryCode = value!.dialCode!;
                      },
                      onChanged: (value){
                        countryCode = value.dialCode!;

                      },
                      // Initial selection and favorite can be one of code ('IT') OR dial_code('+39')
                      initialSelection: 'UG',
                      favorite: const ['+254','+255',"US"],
                      // optional. Shows only country name and flag
                      showCountryOnly: false,
                      // optional. Shows only country name and flag when popup is closed.
                      showOnlyCountryWhenClosed: false,
                      // optional. aligns the flag and the Text left
                      alignLeft: false,
                    ),
                    Text(
                      "|",
                      style: TextStyle(fontSize: 25, color: kAppPinkColor),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Expanded(
                        child:

                        TextFormField(
                          style: kNormalTextStyle.copyWith(color: kPureWhiteColor),
                          validator: (value){
                            List letters = List<String>.generate(
                                value!.length,
                                    (index) => value[index]);
                            print(letters);


                            if (value!=null && value.length > 10){
                              return 'Number is too long';
                            }else if (value == "") {
                              return 'Enter phone number';
                            } else if (letters[0] == '0'){
                              return 'Number cannot start with a 0';
                            } else if (value!= null && value.length < 9){
                              return 'Number short';

                            }
                            else {
                              return null;
                            }
                          },

                          onChanged: (value){
                            phoneNumber = countryCode + value;
                          },
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(

                              border: InputBorder.none,
                              hintText: "77000000",
                              hintStyle: kNormalTextStyle.copyWith(color: Colors.grey[500])

                          ),
                        ))
                  ],
                ),
              ),
            ),

            InputFieldWidget(fontColor: kPureWhiteColor, labelText: ' Position', hintText: '', keyboardType: TextInputType.text, onTypingFunction: (value){
              role = value;
            }),
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

    // Call the user's CollectionReference to add a new user
    return customerProvided.doc(customerId)
        .set({
      'id':customerId,
      'active': true,
      'phoneNumber': phoneNumber,
      'role': role,
      'name': customerName,
      'code': code,
      'signedIn': {"${DateFormat('hh:mm a EE, dd, MMM').format(DateTime.now())}":false},
      'storeId': prefs.getString(kStoreIdConstant),
      'token': "$customerName token goes here",
      'permissions': '{ "transactions": false,   "expenses": true,   "customers": false,   "sales": true,   "store": true,   "analytics": false,   "messages": false, "tasks": false, "admin": false, "summary": true, "employees": false, "notifications": false, "signIn": true, "takeStock": true, "qrCode": false }'
    })
        .then((value) => print("Service Added"))
        .catchError((error) => print("Failed to add service: $error"));
  }



  String customerId = "";
  String description= '';
  String phoneNumber= "";
  String role= "";

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
      appBar: AppBar(
        centerTitle: true,
        title: Text('Add Employee', style: kNormalTextStyle.copyWith(color: kPureWhiteColor)),
        backgroundColor: kBlack,
        foregroundColor: kPureWhiteColor,

      ),

      backgroundColor: kBlack,

      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 15.0, bottom: 15.0),
              child: Text("Enter Employee Information",textAlign: TextAlign.start, style: kHeading3TextStyleBold.copyWith(fontSize: 16,color: kPureWhiteColor ),),
            ),

            containerToShow,



            kLargeHeightSpacing,
            Text("Enter Pass Pin", style: kNormalTextStyle.copyWith(color: kPureWhiteColor),),
            kLargeHeightSpacing,
            Pinput(
              length: 4,
              onChanged: (value){
                code = value;
              },
              showCursor: true,
              onCompleted: (pin) => print(pin),
            ),
            kLargeHeightSpacing,

            RoundedLoadingButton(
              color: kAppPinkColor,
              child: Text('Add new Employee', style: TextStyle(color: Colors.white)),
              controller: _btnController,
              onPressed: () async {
                if ( customerName == ''||phoneNumber == ""||code ==""){
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

                  addCustomer("");

                  Navigator.pop(context);
                  //Implement registration functionality.
                }
              },
            ),

          ],
        ),

      ),

    );

  }

}
