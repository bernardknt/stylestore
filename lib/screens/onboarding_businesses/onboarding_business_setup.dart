import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stylestore/model/styleapp_data.dart';
import 'package:stylestore/utilities/constants/user_constants.dart';
import '../../Utilities/constants/color_constants.dart';
import '../../Utilities/constants/font_constants.dart';
import '../../model/common_functions.dart';

import '../../utilities/constants/word_constants.dart';
import '../../widgets/text_form.dart';
import '../MobileMoneyPages/mobile_money_page.dart';

class OnboardingBusiness extends StatefulWidget {
  static String id = "onboarding_business";
  @override
  _OnboardingBusinessState createState() => _OnboardingBusinessState();
}

class _OnboardingBusinessState extends State<OnboardingBusiness> {
  // Controller for text input fields
  final TextEditingController businessNameController = TextEditingController();
  final TextEditingController otherNamesController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  String country = '';
  int selectedOpeningTime = 8;
  int selectedClosingTime = 18;
  DayPeriod openingPeriod = DayPeriod.am;
  DayPeriod closingPeriod = DayPeriod.pm;

  Future<void> _showTimePickerForOpeningTime(BuildContext context,) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(DateTime.now()),
    );

    if (pickedTime != null) {
      setState(() {
        selectedOpeningTime = pickedTime.hour;
        openingPeriod = pickedTime.period;

      });
    }
  }

  Future<void> _showTimePickerForClosingTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(DateTime.now()),
    );

    if (pickedTime != null) {
      setState(() {
        selectedClosingTime = pickedTime.hour;
        closingPeriod = pickedTime.period;
      });
    }
  }


  final RoundedLoadingButtonController _btnController = RoundedLoadingButtonController();
  File? image;
  var imageUploaded = false;
  String imageToUpload = 'https://mcusercontent.com/f78a91485e657cda2c219f659/images/7e5d9ad3-e663-11d4-bb3e-96678f9428ec.png';
  var code = "";
  final storage = FirebaseStorage.instance;
  String serviceId = 'emp${uuid.v1().split("-")[0]}';
  UploadTask? uploadTask;
  String customerId = "";
  String phoneNumber = "";
  String password = '';
  String storeId = '';
  String initialCountryCode = '+256';
  Map<String, String> optionsToUpload = {};
  String errorMessage = 'Error Signing Up';
  double errorMessageOpacity = 0.0;
  String countryCode = '';
  double opacityOfTextFields = 1.0;
  CollectionReference storesDb = FirebaseFirestore.instance.collection('medics');


  Future<void> updateBusiness() async {
    final prefs = await SharedPreferences.getInstance();
    showDialog(context: context, builder: ( context) {return const Center(child: CircularProgressIndicator(
      color: kAppPinkColor,));});

    return storesDb
        .doc(storeId)
        .update({
      'businessPhone': phoneNumber,
      'phone': phoneNumber,
      'name': businessNameController.text,
      'location': addressController.text,
      'close': selectedClosingTime,
      'open': selectedOpeningTime,
      'image': imageToUpload,
      'countryCode': countryCode,
      'country':country,
      'currency':CommonFunctions().getCurrencyCode(countryCode, context),
      'permissions': '{ "transactions": false,   "expenses": true,   "customers": false,   "sales": true,   "store": true,   "analytics": false,   "messages": false, "tasks": false, "admin": false, "summary": true, "employees": false, "notifications": false, "signIn": true, "takeStock": true, "qrCode": false, "suppliers":true,"checklist":true }',
      'checklist': []
    }).whenComplete((){

      prefs.setString(kCountryCode, countryCode);
      prefs.setString(kCountry, country);
      prefs.setString(kCurrency, CommonFunctions().getCurrencyCode(countryCode, context));
      prefs.setInt(kStoreOpeningTime, selectedOpeningTime);
      prefs.setInt(kStoreClosingTime, selectedClosingTime);
      prefs.setString(kPhoneNumberConstant, phoneNumber);
      prefs.setString(kBusinessNameConstant, businessNameController.text);
      prefs.setString(kLocationConstant, addressController.text);
      prefs.setString(kImageConstant, imageToUpload);
      prefs.setString(kPhoneNumberConstant,phoneNumber);
      Provider.of<StyleProvider>(context, listen: false).setStoreName(businessNameController.text);
      Provider.of<StyleProvider>(context, listen: false).setOnboardingIndex(2);
      CommonFunctions().showSuccessNotification("Business Details Updated", context);
      Navigator.pop(context);
    })
        .then((value) => print("Service Added"))
        .catchError((error) => print("Failed to add service: $error"));
  }



  void defaultInitialization() async {
    final prefs = await SharedPreferences.getInstance();
    initialCountryCode = prefs.getString(kCountryCode)??"+1";
    storeId = prefs.getString(kStoreIdConstant)??"";
    print("HERE IS THE STORE ID: $storeId");
    final initials = prefs
        .getString(kBusinessNameConstant)
        ?.split(' ')
        .map((word) => word.isNotEmpty ? word[0].toUpperCase() : '')
        .join('');
    customerId = 'employee${initials}${uuid.v1().split("-")[0]}';
    setState(() {

    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    defaultInitialization();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPureWhiteColor,
      // floatingActionButton: FloatingActionButton(onPressed: () {  },child: Text("Submit Details"),),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Departments dropdown

              Row(mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Business Information",
                    style: kNormalTextStyle.copyWith(
                        color: kBlack,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              kLargeHeightSpacing,
              Row(
                children: [
                  Container(
                    height: 70,
                    width: 70,

                    decoration: BoxDecoration(borderRadius: const BorderRadius.all(Radius.circular(10)), color: kPlainBackground,


                    ),
                    child: Opacity(
                        opacity: 0.2,
                        child: Image.asset("images/new_logo.png", height: 20,width: 20,)),

                  ),
                  kMediumWidthSpacing,
                  kMediumWidthSpacing,

                  Text("Add Business Logo",
                      style: kNormalTextStyle.copyWith(
                          color: kBlack,
                          fontWeight: FontWeight.bold
                      )),
                ],
              ),

              kLargeHeightSpacing,
              TextForm(label:'Business Name', controller:businessNameController),
              kLargeHeightSpacing,
              Text("Business Phone Number *",
                  style: kNormalTextStyle.copyWith(
                    color: kBlack,
                    fontWeight: FontWeight.bold
                  )),
              // Phone number goes here
              // Phone number goes here
              Padding(
                padding: const EdgeInsets.only(
                    left: 0, right: 0, top: 10, bottom: 8),
                child: Container(
                  height: 53,
                  decoration: BoxDecoration(
                      border: Border.all(width: 1, color: kBlack),
                      borderRadius: BorderRadius.circular(10)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 10,
                      ),
                      CountryCodePicker(
                        textStyle: kNormalTextStyle,

                        onInit: (value) {
                          countryCode = value!.dialCode!;
                          country = value.name!;
                        },
                        onChanged: (value) {
                          countryCode = value.dialCode!;
                          country = value.name!;
                        },
                        // Initial selection and favorite can be one of code ('IT') OR dial_code('+39')
                        initialSelection: initialCountryCode,
                        favorite: const ['+256','+254', '+255', "US"],
                        // optional. Shows only country name and flag
                        showCountryOnly: false,
                        // optional. Shows only country name and flag when popup is closed.
                        showOnlyCountryWhenClosed: false,
                        // optional. aligns the flag and the Text left
                        alignLeft: false,
                      ),
                      Text(
                        "|",
                        style:
                        TextStyle(fontSize: 25, color: kAppPinkColor),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                          child: TextFormField(
                            style: kNormalTextStyle.copyWith(color: kBlack),
                            validator: (value) {
                              List letters = List<String>.generate(
                                  value!.length, (index) => value[index]);
                              print(letters);

                              if (value != null && value.length > 10) {
                                return 'Number is too long';
                              } else if (value == "") {
                                return 'Enter phone number';
                              } else if (letters[0] == '0') {
                                return 'Number cannot start with a 0';
                              } else if (value != null && value.length < 9) {
                                return 'Number short';
                              } else {
                                return null;
                              }
                            },
                            onChanged: (value) {
                              phoneNumber = countryCode + value;
                            },
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: "77000000",
                                hintStyle: kNormalTextStyle.copyWith(
                                    color: Colors.grey[500])),
                          ))
                    ],
                  ),
                ),
              ),
              kLargeHeightSpacing,
              GestureDetector(
                onTap: (){
                  _showTimePickerForOpeningTime(context);

                },
                child: Container(
                  decoration: BoxDecoration(
                      color: kBackgroundGreyColor,
                      borderRadius: BorderRadius.circular(10),),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,

                      children: [
                        Text("Opening Time",
                            style: kNormalTextStyle.copyWith(
                                color: kBlack,
                                fontWeight: FontWeight.bold
                            )),
                        kMediumWidthSpacing,
                        Container(height: 30,
                          width: 100,
                          decoration: BoxDecoration(
                              color: kGreenThemeColor.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(10)
                          ),
                          child: Center(
                            child: Text("$selectedOpeningTime ${openingPeriod.name}", style: kNormalTextStyle.copyWith(
                                color: kPureWhiteColor,
                                fontWeight: FontWeight.bold
                            )),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              kLargeHeightSpacing,
              GestureDetector(
                onTap: (){
                  _showTimePickerForClosingTime(context);

                },
                child: Container(
                  decoration: BoxDecoration(
                    color: kBackgroundGreyColor,
                    borderRadius: BorderRadius.circular(10)
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Closing Time",
                            style: kNormalTextStyle.copyWith(
                                color: kBlack,
                                fontWeight: FontWeight.bold
                            )),
                        kMediumWidthSpacing,
                        Container(height: 30,
                          width: 100,
                          decoration: BoxDecoration(
                              color: kRedColor.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(10)
                          ),
                          child: Center(
                            child: Text("$selectedClosingTime ${closingPeriod.name}", style: kNormalTextStyle.copyWith(
                                color: kBlack,
                                fontWeight: FontWeight.bold
                            )),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              kLargeHeightSpacing,

              // TextForm(label: 'Email',controller: emailController),
              TextForm(label:'Location', controller:addressController),
              kLargeHeightSpacing,



              kLargeHeightSpacing,

              Center(
                child: ElevatedButton(
                  onPressed: () {
                    // Add your form submission logic here
                    if ( phoneNumber == ''|| addressController.text ==""|| businessNameController.text == "") {
                      CommonFunctions().alertDialogueError(context);

                    } else
                    {
                      updateBusiness();

                    }
                  },
                  child: Text('Submit',
                      style: kNormalTextStyle.copyWith(
                          color: kPureWhiteColor,
                          fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kAppPinkColor,
                  ),
                ),
              ),
              kLargeHeightSpacing,
            ],
          ),
        ),
      ),
    );
  }
}
