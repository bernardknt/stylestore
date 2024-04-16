
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stylestore/model/common_functions.dart';
import 'package:stylestore/model/styleapp_data.dart';
import 'package:stylestore/screens/store_setup.dart';
import 'package:stylestore/utilities/constants/user_constants.dart';
import '../../../../Utilities/InputFieldWidget.dart';
import '../../Utilities/constants/color_constants.dart';
import '../../Utilities/constants/font_constants.dart';








class RegisterPageDuplicate extends StatefulWidget {
  static String id = 'register_page_duplicate';
  @override
  _RegisterPageDuplicateState createState() => _RegisterPageDuplicateState();
}

class _RegisterPageDuplicateState extends State<RegisterPageDuplicate> {
  final _auth = FirebaseAuth.instance;
  // final HttpsCallable callableSMS = FirebaseFunctions.instance.httpsCallable('sendWelcomeSMS');
  // final HttpsCallable callableEmail = FirebaseFunctions.instance.httpsCallable('sendEmail');
  final RoundedLoadingButtonController _btnController = RoundedLoadingButtonController();



  String email= '';
  String businessName= '';
  String location= '';
  String businessType= '';


  double changeInvalidMessageOpacity = 0.0;
  String invalidMessageDisplay = 'Invalid Number';
  String password = '';
  String repeatPassword = '';
  String fullName = '';
  String firstName = '';
  String phoneNumber = '';
  String country = '';

  //bool showSpinner = false;
  String errorMessage = 'Error Signing Up';
  double errorMessageOpacity = 0.0;
  String countryCode = "";

  defaultInitialization(){

  }





  Widget build(BuildContext context) {
    return Scaffold(

      backgroundColor: kBackgroundGreyColor,
      appBar: AppBar(
        iconTheme:const IconThemeData(
          color: kPureWhiteColor, //change your color here
        ),
        title: Text('Create an Account', style: kNormalTextStyleWhiteButtons,),
        centerTitle: true,
        backgroundColor: kAppPinkColor,
        automaticallyImplyLeading: true,
      ),

      body: Padding(
        padding: const EdgeInsets.only(left: 5, right: 5, top: 0),

        child: SingleChildScrollView(
          child:
          SizedBox(
            height: 350,

            child:
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,

                // crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Center(child: Image.asset('images/logo.png',height: 110,)),
                  Opacity(
                      opacity: changeInvalidMessageOpacity,
                      child: Text(invalidMessageDisplay, style: TextStyle(color:Colors.red , fontSize: 12),)),
                  InputFieldWidget(labelText:" Owner's Full Names" ,hintText: '', keyboardType: TextInputType.text, onTypingFunction: (value){
                    fullName = value;
                    firstName = fullName.split(" ")[0]; // Gets the first name in the 0 positiion from the full names
                  },
                  ),
                  Row(
                    children: [
                      CountryCodePicker(
                        onInit: (value){
                          countryCode = value!.dialCode!;
                          country = value!.name!;
                          // countryFlag = value!.flagUri!;

                        },
                        onChanged: (value){
                          countryCode = value.dialCode!;
                          country = value.name!;


                        },
                        // Initial selection and favorite can be one of code ('IT') OR dial_code('+39')
                        initialSelection: 'UG',
                        favorite: const ['UG', '+254', '+255'],
                        // optional. Shows only country name and flag
                        showCountryOnly: true,
                        // optional. Shows only country name and flag when popup is closed.
                        showOnlyCountryWhenClosed: false,
                        // optional. aligns the flag and the Text left
                        alignLeft: false,
                      ),
                      InputFieldWidget(labelText: ' Business Mobile Number', hintText: '77100100', keyboardType: TextInputType.number,  onTypingFunction: (value){
                        // setState(() {
                        if (value.split('')[0] == '7'){
                          invalidMessageDisplay = 'Incomplete Number';
                          if (value.length == 9 && value.split('')[0] == '7'){
                            phoneNumber = value;
                            phoneNumber.split('0');
                            // print(phoneNumber.split(''));
                            changeInvalidMessageOpacity = 0.0;
                          } else if(value.length !=9 || value.split('')[0] != '7'){
                            changeInvalidMessageOpacity = 1.0;
                          }
                        }else {
                          invalidMessageDisplay = 'Number should start with 7';
                          changeInvalidMessageOpacity = 1.0;
                        }
                        // });

                        phoneNumber = value;
                      },),
                    ],
                  ),
                  kSmallHeightSpacing,

                  InputFieldWidget(labelText: ' Email', hintText: "", keyboardType: TextInputType.emailAddress, onTypingFunction: (value){
                    email = value;
                  },),
                  InputFieldWidget(labelText: ' Password', hintText: '', keyboardType: TextInputType.text, onTypingFunction: (value){
                    password = value;
                  },passwordType: true, maxLines: 1,),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child:
                    RoundedLoadingButton(
                      color: kAppPinkColor,
                      child: Text('Register', style: kHeadingTextStyleWhite),
                      controller: _btnController,
                      onPressed: () async {
                        if (email ==''|| phoneNumber == '' || email =='' || password == '' || fullName == ''){
                          _btnController.error();
                          showDialog(context: context, builder: (BuildContext context){

                            return CupertinoAlertDialog(
                              title: const Text('Oops Something is Missing'),
                              content: const Text('Make sure you have filled in all the fields'),
                              actions: [CupertinoDialogAction(isDestructiveAction: true,
                                  onPressed: (){
                                    _btnController.reset();
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Cancel'))],
                            );
                          });
                        }else {
                          print('Else activated');
                          setState(() {
                            //showSpinner = true;
                          });
                          try{
                            final newUser = await _auth.createUserWithEmailAndPassword(email: email,
                                password: password);
                            if (newUser != null){
                              CommonFunctions().setupStoreInFirestore(newUser.user?.uid, email, fullName, location, phoneNumber, businessType, businessName, countryCode, country,  CommonFunctions().getCurrencyCode(countryCode, context),context);

                              final prefs = await SharedPreferences.getInstance();
                              // prefs.setString(kBusinessNameConstant, businessName );
                              prefs.setString(kLoginPersonName, fullName );
                              // prefs.setString(kLocationConstant, location );
                              prefs.setString(kStoreIdConstant, newUser.user!.uid);
                              prefs.setString(kCountryCode, countryCode); 
                              prefs.setString(kCurrencyCode, CommonFunctions().getCurrencyCode(countryCode, context));
                              prefs.setString(kEmailConstant, email);
                              prefs.setString(kPhoneNumberConstant, phoneNumber);
                              prefs.setBool(kIsLoggedInConstant, true);
                              prefs.setBool(kIsFirstTimeUser, true);
                              prefs.setInt(kStoreOpeningTime, 7);
                              prefs.setInt(kStoreClosingTime, 20);
                              prefs.setStringList(kStoreImages, []);
                              prefs.setBool(kDoesMobileConstant, true);







                              Navigator.pushNamed(context, StoreSetup.id);


                              // SAVE THE VALUES TO THE USER DEFAULTS AND DATABASE
                            }else{
                              setState(() {
                                errorMessageOpacity = 1.0;
                              });
                            }

                          }catch(e){
                            _btnController.error();
                            showDialog(context: context, builder: (BuildContext context){
                              return CupertinoAlertDialog(
                                title: Text('Oops Register Error'),
                                content: Text('${e}'),
                                actions: [CupertinoDialogAction(isDestructiveAction: true,
                                    onPressed: (){
                                      _btnController.reset();
                                      Navigator.pop(context);
                                    },
                                    child: Text('Cancel'))],
                              );
                            });
                            //print('error message is: $e');
                          }
                          //Implement registration functionality.
                        }

                      },
                    ),
                  ),
                  Opacity(
                      opacity: errorMessageOpacity,
                      child: Text(errorMessage, style: TextStyle(color: Colors.red),)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
