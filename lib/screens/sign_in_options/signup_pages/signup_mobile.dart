import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stylestore/Utilities/constants/color_constants.dart';
import 'package:stylestore/model/common_functions.dart';
import '../../../Utilities/constants/font_constants.dart';
import '../../../Utilities/constants/user_constants.dart';
import '../../../controllers/responsive/responsive_page.dart';
import '../../../widgets/text_form.dart';


class SignupMobile extends StatefulWidget {
  static String id = 'signup_page_web';
  @override
  _SignupMobileState createState() => _SignupMobileState();
}

class _SignupMobileState extends State<SignupMobile> {
  final auth = FirebaseAuth.instance;
  String email = ' ';
  String password = ' ';
  String supplierId = "";
  String phoneNumber = "";
  String gender = '';
  String? selectedDepartment;
  String selectedNationality = "Ugandan";


  Map<String, String> optionsToUpload = {};
  String errorMessage = 'Error Signing Up';
  double errorMessageOpacity = 0.0;
  String countryCode = ' ';
  double opacityOfTextFields = 1.0;
  final RoundedLoadingButtonController _btnController =
  RoundedLoadingButtonController();
  bool showSpinner = false;
  bool ownerLogin = false;
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController serviceSuppliedController = TextEditingController();
  final TextEditingController nationalityController = TextEditingController();
  final TextEditingController nationalIdNumberController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController emailController = TextEditingController();


  void defaultsInitiation() async {
    final prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool(kIsLoggedInConstant) ?? false;
    setState(() {
      userLoggedIn = isLoggedIn;
      if (userLoggedIn == true) {
        Navigator.pushNamed(context, SuperResponsiveLayout.id);
      } else {
        print('NOT LOGGED IN');
      }
    });
  }

  bool userLoggedIn = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: kPureWhiteColor,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

            Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Center(
                    child: Container(
                      // color: kAppPinkColor.withOpacity(0.1),
                      width: 650,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Departments dropdown
                            Text(
                              "CREATE YOUR ACCOUNT",
                              style: kNormalTextStyle.copyWith(
                                  color: kAppPinkColor,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold),
                            ),
                            kLargeHeightSpacing,
                            TextForm(label:'Business Name', controller:fullNameController),
                            // TextForm(label:'What you deal in',controller: serviceSuppliedController),

                            kLargeHeightSpacing,
                            Row(
                              children: [
                                Text("Phone Number",
                                    style: kNormalTextStyle.copyWith(
                                        color: kBlack,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14
                                    )),
                              ],
                            ),

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
                            // TextForm(label:'Physical Address', controller:addressController),
                            TextForm(label: 'Email',controller: emailController),
                            TextForm(label: 'Password',controller: emailController),



                            ElevatedButton(

                              onPressed: () {
                                // Add your form submission logic here
                                if (fullNameController.text == "" ) {
                                  CommonFunctions().alertDialogueError(context);

                                } else
                                {
                                  // addNewSupplier();
                                  Navigator.pop(context);
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: Text('Create Account',
                                    style: kNormalTextStyle.copyWith(
                                        color: kPureWhiteColor,
                                        fontWeight: FontWeight.bold)),
                              ),
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
            ),


          ],
        ),
      ),
    );
  }
}
