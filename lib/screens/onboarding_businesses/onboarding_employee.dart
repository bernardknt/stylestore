import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stylestore/model/styleapp_data.dart';
import '../../Utilities/constants/color_constants.dart';
import '../../Utilities/constants/font_constants.dart';
import '../../Utilities/constants/user_constants.dart';
import '../../model/common_functions.dart';
import '../../utilities/constants/word_constants.dart';
import '../../widgets/text_form.dart';
import '../MobileMoneyPages/mobile_money_page.dart';

class OnboardingEmployee extends StatefulWidget {
  static String id = "onboarding_employee";
  @override
  _OnboardingEmployeeState createState() => _OnboardingEmployeeState();
}

class _OnboardingEmployeeState extends State<OnboardingEmployee> {
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

  DateTime selectedBirthday = DateTime(1998, 1, 16); // Variable to store the selected birthday



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
  String country = '';
  String storeId = '';
  String initialCountryCode = '+256';
  Map<String, String> optionsToUpload = {};
  String errorMessage = 'Error Signing Up';
  double errorMessageOpacity = 0.0;
  String countryCode = ' ';
  String permissions = '{"transactions": true,"expenses": true,"customers": true,"sales": true,"store": true,"analytics": true,"messages": true,"tasks": true,"admin": true,"summary": true,"employees": true,"notifications": true,"signIn": true,"takeStock": true, "qrCode": false}';
  double opacityOfTextFields = 1.0;
  CollectionReference storesDb = FirebaseFirestore.instance.collection('medics');
  CollectionReference employeeDb = FirebaseFirestore.instance.collection('employees');
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  String token = "this_is_a_web_token_updated";

  Future<void> addNewEmployee() async {
    final prefs = await SharedPreferences.getInstance();
    showDialog(context: context, builder: ( context) {return const Center(child: CircularProgressIndicator(
      color: kAppPinkColor,));});
    return employeeDb
        .doc(customerId)
        .set({
      'id': customerId,
      'active': true,
      'phoneNumber': phoneNumber,
      'role': positionController.text,
      'name': fullNameController.text,
      'email': prefs.getString(kEmailConstant),
      'gender': gender,
      'nationality': '',
      'dateOfBirth': selectedBirthday,
      'address': '',
      'nextOfKin': '',
      'nextOfKinNumber': '',
      'nationalIdNumber': '',
      'tin': '',
      'department': selectedDepartment,
      'code': code,
      'maritalStatus': 'Single',
      'picture': 'https://mcusercontent.com/f78a91485e657cda2c219f659/images/5320d4cd-cde9-74be-c923-506a8da6ed8a.png',
      'signedIn': {
        "${DateFormat('hh:mm a EE, dd, MMM').format(DateTime.now())}": false
      },
      'storeId': prefs.getString(kStoreIdConstant),
      'token': "token goes here",
      'permissions': permissions,
      'checklist': []
    }).whenComplete((){




      prefs.setString(kPermissions, permissions);

      prefs.setString(kLoginPersonName, fullNameController.text);
      prefs.setBool(kDoesMobileConstant, true);
      prefs.setString(kEmployeeId,   customerId );
      prefs.setBool(kIsOwner,  true );
      prefs.setBool(kIsCheckedIn, false);
      prefs.setBool(kIsLoggedInConstant, true);
      CommonFunctions().deliveryStream(context);
      CommonFunctions().updateNotificationsIfAdmin(storeId, token);
      CommonFunctions().updateUserNotificationToken(prefs.getString(kStoreIdConstant));


      Provider.of<StyleProvider>(context, listen: false).setOnboardingIndex(3);
      CommonFunctions().showSuccessNotification("${fullNameController.text} Updated", context);
      Navigator.pop(context);
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
    _firebaseMessaging.getToken().then((value) async{
      final prefs = await SharedPreferences.getInstance();
      token = value!;
      print(value);
      prefs.setString(kToken, token);
    } );
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
                    "Your Details",
                    style: kNormalTextStyle.copyWith(
                        color: kBlack,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),

              kSmallHeightSpacing,
              TextForm(label:'Your Full Names', controller:fullNameController),
              kSmallHeightSpacing,
              GestureDetector(
                  onTap: () {
                    _selectBirthday(context);
                  },
                  child: Container(
                    color: Colors.grey[200],
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                          selectedBirthday != DateTime.now()
                              ? "Date of Birth: ${DateFormat('dd, MMMM, yyyy').format(selectedBirthday)}"
                              : 'Click to Set Date of Birth',
                          style: kNormalTextStyle.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue)),
                    ),
                  )),
              kSmallHeightSpacing,
              Text(
                'Gender *',
                style:
                TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  Radio(
                    value: 'Male',
                    groupValue: gender,
                    onChanged: (value) {
                      setState(() {
                        gender = value.toString();
                      });
                    },
                  ),
                  Text('Male',
                      style: kNormalTextStyle.copyWith(
                        color: kBlack,
                      )),
                  Radio(
                    value: 'Female',
                    groupValue: gender,
                    onChanged: (value) {
                      setState(() {
                        gender = value.toString();
                      });
                    },
                  ),
                  Text('Female',
                      style: kNormalTextStyle.copyWith(
                        color: kBlack,
                      )),
                ],
              ),
              kLargeHeightSpacing,
              Text("Phone Number*",
                  style: kNormalTextStyle.copyWith(
                      color: kBlack,
                      fontWeight: FontWeight.bold,
                    fontSize: 14
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
                          country = value.name!;
                        },
                        onChanged: (value) {
                          countryCode = value.dialCode!;
                          country = value.name!;
                        },
                        // Initial selection and favorite can be one of code ('IT') OR dial_code('+39')
                        initialSelection: initialCountryCode,
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
              TextForm(label:'Position (Eg Manager, Accountant)',controller: positionController),
              kLargeHeightSpacing,
              Text(
                'Department *',
                style: kNormalTextStyle.copyWith(
                    color: kBlack,
                    fontSize: 14,
                    fontWeight: FontWeight.bold),
              ),
              DropdownButton<String>(
                value:
                selectedDepartment, // The currently selected department
                items: departments
                    .map((department) => DropdownMenuItem(
                  value: department,
                  child: Text(department),
                ))
                    .toList(),
                onChanged: (newDepartment) => setState(() =>
                selectedDepartment =
                    newDepartment), // Update the selected department when a new one is chosen
                hint: Text(
                    'Select Department'), // Placeholder text before a department is selected
              ),
              // kLargeHeightSpacing,

              // TextForm(label: 'Email',controller: emailController),
              // TextForm(label:'Location', controller:addressController),
              // kLargeHeightSpacing,



              kLargeHeightSpacing,

              Center(
                child: ElevatedButton(
                  onPressed: () {
                    // Add your form submission logic here
                    if (selectedDepartment == "" || gender == "" || phoneNumber == ''|| positionController.text ==""|| fullNameController.text == ""|| selectedDepartment == null){
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
                                      "Create Your Pass Pin ${CommonFunctions().getFirstWord(fullNameController.text)}",
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
                                      child: Text('Create Administrator', style: TextStyle(color: Colors.white)),
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
                                          // Navigator.pop(context);
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
