import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Utilities/constants/color_constants.dart';
import '../../Utilities/constants/font_constants.dart';
import '../../Utilities/constants/user_constants.dart';
import '../../model/common_functions.dart';
import '../../utilities/constants/word_constants.dart';
import '../../widgets/text_form.dart';
import '../MobileMoneyPages/mobile_money_page.dart';

class SupplierForm extends StatefulWidget {
  static String id = "supplier_form";
  final bool doesNotNeedReloading;

  const SupplierForm({Key? key, this.doesNotNeedReloading = true}) : super(key: key);

  // const SupplierForm({super.key});
  @override
  _SupplierFormState createState() => _SupplierFormState();
}

class _SupplierFormState extends State<SupplierForm> {
  // Controller for text input fields
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController serviceSuppliedController = TextEditingController();
  final TextEditingController nationalityController = TextEditingController();
  final TextEditingController nationalIdNumberController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

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

  final RoundedLoadingButtonController _btnController =
  RoundedLoadingButtonController();
  File? image;
  var imageUploaded = false;
  var code = "";
  final storage = FirebaseStorage.instance;
  String serviceId = 'emp${uuid.v1().split("-")[0]}';
  UploadTask? uploadTask;
  String supplierId = "";
  String phoneNumber = "";
  String password = '';

  Map<String, String> optionsToUpload = {};
  String errorMessage = 'Error Signing Up';
  double errorMessageOpacity = 0.0;
  String countryCode = ' ';
  double opacityOfTextFields = 1.0;

  CollectionReference customerProvided =
  FirebaseFirestore.instance.collection('suppliers');


  Future<void> addNewSupplier() async {
    final prefs = await SharedPreferences.getInstance();
    return customerProvided
        .doc(supplierId)
        .set({
      'id': supplierId,
      'active': true,
      'supplies': serviceSuppliedController.text,
      'phoneNumber': phoneNumber,
      'name': fullNameController.text,
      'email': emailController.text,
      'nationality': selectedNationality,
      'address': addressController.text,
      'storeId': prefs.getString(kStoreIdConstant),

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
    supplierId = 'supplier${initials}${uuid.v1().split("-")[0]}';
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
        title: const Text('New Supplier Form'),
        automaticallyImplyLeading: true,
      ),
      body:
      Padding(
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
                      "Supplier Information",
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
                    TextForm(label:'Supplier Name *', controller:fullNameController),
                    TextForm(label:'Product / Service Supplied',controller: serviceSuppliedController),

                    kLargeHeightSpacing,
                    Text("Phone Number",
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

                    TextForm(label: 'Email',controller: emailController),
                    TextForm(label:'Physical Address', controller:addressController),
                    Text('Country',
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

                    ElevatedButton(
                      onPressed: () {
                        // Add your form submission logic here
                        if (fullNameController.text == "" ) {
                          CommonFunctions().alertDialogueError(context);

                        } else
                        {
                          addNewSupplier();
                          Navigator.pop(context);
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
