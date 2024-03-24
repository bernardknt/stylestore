import 'dart:io';

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

class BioDataForm extends StatefulWidget {
  static String id = "biodata_form_1";
  @override
  _BioDataFormState createState() => _BioDataFormState();
}

class _BioDataFormState extends State<BioDataForm> {
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

  Future<void> updateAllEmployeeDocuments() async {
    final firestore = FirebaseFirestore.instance;
    final employeesRef = firestore.collection('employees');

    // Get a snapshot of all documents in the collection
    final snapshot = await employeesRef.get();

    // Iterate through each document and update the fields
    for (final doc in snapshot.docs) {
      final docId = doc.id;
      final updatedData = {
        'maritalStatus': 'Single',
        'picture': 'https://mcusercontent.com/f78a91485e657cda2c219f659/images/5320d4cd-cde9-74be-c923-506a8da6ed8a.png',

      };

      await employeesRef.doc(docId).update(updatedData);
    }
  }

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
      'email': emailController.text,
      'gender': gender,
      'nationality': selectedNationality,
      'dateOfBirth': selectedBirthday,
      'address': addressController.text,
      'nextOfKin': kinController.text,
      'nextOfKinNumber': kinNumberController.text,
      'nationalIdNumber': nationalIdNumberController.text,
      'tin': tinController.text,
      'department': selectedDepartment,
      'code': code,
      'maritalStatus': 'Single',
      'picture': 'https://mcusercontent.com/f78a91485e657cda2c219f659/images/5320d4cd-cde9-74be-c923-506a8da6ed8a.png',

      'signedIn': {
        "${DateFormat('hh:mm a EE, dd, MMM').format(DateTime.now())}": false
      },
      'storeId': prefs.getString(kStoreIdConstant),
      'token': "token goes here",
      'permissions':
      '{ "transactions": false,   "expenses": true,   "customers": false,   "sales": true,   "store": true,   "analytics": false,   "messages": false, "tasks": false, "admin": false, "summary": true, "employees": false, "notifications": false, "signIn": true, "takeStock": true, "qrCode": false }'
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
      appBar: AppBar(
        title: const Text('Employee Information Form'),
        automaticallyImplyLeading: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          updateAllEmployeeDocuments();
        },
        child: const Icon(Icons.money),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Center(
            child: Container(
              color: kBackgroundGreyColor,
              width: 650,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Departments dropdown
                    Text(
                      "Section 1: Personal Information",
                      style: kNormalTextStyle.copyWith(
                          color: kGreenThemeColor,
                          fontSize: 15,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "Compulsory fields are denoted with *",
                      style: kNormalTextStyle.copyWith(
                        color: kBlack,
                        fontSize: 12,
                      ),
                    ),

                    kLargeHeightSpacing,
                    TextForm(label:'Full Name *', controller:fullNameController),
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

                    Text("Phone Number *",
                        style: kNormalTextStyle.copyWith(
                          color: kBlack,
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
                    // TextForm('Other Names', otherNamesController),
                    TextForm(label:'Position',controller: positionController),
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
                    TextForm(label: 'Email',controller: emailController),
                    TextForm(label:'Physical Address', controller:addressController),
                    TextForm(label: 'Next of Kin', controller:kinController),
                    TextForm(label:'Next of Kin Number', controller:kinNumberController),
                    Text('Nationality',
                        style: kNormalTextStyle.copyWith(
                          color: kBlack,
                        )),
                    DropdownButton<String>(
                      value:
                      selectedNationality, // The currently selected department
                      items: nationalities
                          .map((department) => DropdownMenuItem(
                        value: department,
                        child: Text(department),
                      ))
                          .toList(),
                      onChanged: (newNationality) => setState(() =>
                      selectedNationality =
                      newNationality!), // Update the selected department when a new one is chosen
                      hint: Text(
                          'Select Nationality'), // Placeholder text before a department is selected
                    ),
                    TextForm(label:'National ID Number', controller:nationalIdNumberController),

                    // TextForm('Home District', districtController),

                    TextForm(label:'TIN',controller: tinController),
                    // TextForm('NSSF Number', nssfNumberController),

                    SizedBox(height: 16),

                    ElevatedButton(
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
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
