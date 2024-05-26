import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pinput/pinput.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Utilities/constants/color_constants.dart';
import '../../Utilities/constants/font_constants.dart';
import '../../Utilities/constants/user_constants.dart';
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
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController otherNamesController = TextEditingController();
  final TextEditingController positionController = TextEditingController();
  final TextEditingController nationalityController = TextEditingController();
  final TextEditingController idNumberController = TextEditingController();
  final TextEditingController nationalIdNumberController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController districtController = TextEditingController();
  final TextEditingController kinNumberController = TextEditingController();
  final TextEditingController kinController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController subCountyController = TextEditingController();
  final TextEditingController tinController = TextEditingController();

  // Gender selection
  String gender = '';
  String? selectedDepartment;
  String selectedNationality = "Ugandan";

  int selectedOpeningTime = 8;
  int selectedClosingTime = 18;
  DayPeriod openingPeriod = DayPeriod.am;
  DayPeriod closingPeriod = DayPeriod.pm;
  _selectBirthday(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != selectedBirthday) {
      setState(() {
        selectedBirthday = picked;
      });
    }
  }

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
  
  

  DateTime selectedBirthday =
  DateTime(1998, 1, 16); // Variable to store the selected birthday


  

  final RoundedLoadingButtonController _btnController = RoundedLoadingButtonController();
  File? image;
  var imageUploaded = false;
  var code = "";
  final storage = FirebaseStorage.instance;
  String serviceId = 'emp${uuid.v1().split("-")[0]}';
  UploadTask? uploadTask;
  String customerId = "";
  String phoneNumber = "";
  String password = '';
  Map<String, String> optionsToUpload = {};
  String errorMessage = 'Error Signing Up';
  double errorMessageOpacity = 0.0;
  String countryCode = ' ';
  double opacityOfTextFields = 1.0;
  CollectionReference customerProvided =
  FirebaseFirestore.instance.collection('employees');

  Future<void> addNewEmployee() async {
    final prefs = await SharedPreferences.getInstance();
    return customerProvided
        .doc(customerId)
        .set({
      'id': customerId,
      'active': true,
      'phoneNumber': phoneNumber,
      'role': positionController.text,
      'name': fullNameController.text,
      'location': addressController.text,
      'picture': 'https://mcusercontent.com/f78a91485e657cda2c219f659/images/5320d4cd-cde9-74be-c923-506a8da6ed8a.png',
      'storeId': prefs.getString(kStoreIdConstant),
      'permissions': '{ "transactions": false,   "expenses": true,   "customers": false,   "sales": true,   "store": true,   "analytics": false,   "messages": false, "tasks": false, "admin": false, "summary": true, "employees": false, "notifications": false, "signIn": true, "takeStock": true, "qrCode": false, "suppliers":true,"checklist":true }',
      'checklist': []
    })
        .then((value) => print("Service Added"))
        .catchError((error) => print("Failed to add service: $error"));
  }

  void defaultInitialization() async {
    final prefs = await SharedPreferences.getInstance();
    final initials = prefs
        .getString(kBusinessNameConstant)
        ?.split(' ')
        .map((word) => word.isNotEmpty ? word[0].toUpperCase() : '')
        .join('');
    customerId = 'employee${initials}${uuid.v1().split("-")[0]}';
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
              TextForm(label:'Business Name', controller:fullNameController),
              kLargeHeightSpacing,
              Text("Business Phone Number *",
                  style: kNormalTextStyle.copyWith(
                    color: kBlack,
                    fontWeight: FontWeight.bold
                  )),
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
                        },
                        onChanged: (value) {
                          countryCode = value.dialCode!;
                        },
                        // Initial selection and favorite can be one of code ('IT') OR dial_code('+39')
                        initialSelection: 'UG',
                        favorite: const ['+254', '+255', "US"],
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
                    if (selectedDepartment == "" || gender == "" || phoneNumber == ''|| positionController.text ==""|| fullNameController.text == ""|| selectedDepartment == null) {
                      CommonFunctions().alertDialogueError(context);

                    } else
                    {
                      showModalBottomSheet(
                          context: context,
                          builder: (BuildContext context) {
                            return Container(
                              // height: 200,
                              color: kBlueDarkColor,
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.center,
                                  children: [
                                    kLargeHeightSpacing,
                                    Text(
                                      "Create Pass Pin for ${fullNameController.text}",
                                      style: kNormalTextStyle.copyWith(
                                          color: kPureWhiteColor),
                                    ),
                                    kLargeHeightSpacing,
                                    Pinput(
                                      length: 4,
                                      onChanged: (value) {
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
                                        if (code.length < 4) {
                                          _btnController.error();
                                          showDialog(context: context, builder: (BuildContext context){
                                            return
                                              CupertinoAlertDialog(
                                                title: Text('Code is too short'),
                                                content: Text('Make sure you have entered a 4 digit code'),
                                                actions: [CupertinoDialogAction(isDestructiveAction: true,
                                                    onPressed: (){
                                                      _btnController.reset();
                                                      Navigator.pop(context);
                                                    },
                                                    child: Text('Cancel'))],
                                              );
                                          });
                                        }else {
                                          addNewEmployee();
                                          Navigator.pop(context);
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          });
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
