import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stylestore/Utilities/constants/color_constants.dart';
import 'package:stylestore/model/common_functions.dart';
import 'package:stylestore/screens/onboarding_businesses/onboarding_business.dart';
import 'package:stylestore/screens/sign_in_options/signup_page.dart';

import '../../../Utilities/constants/font_constants.dart';
import '../../../Utilities/constants/user_constants.dart';
import '../../../controllers/responsive/responsive_page.dart';
import '../../../model/styleapp_data.dart';
import '../../../widgets/text_form.dart';
import '../../store_setup.dart';
import '../employee_sign_in.dart';

class SignupWeb extends StatefulWidget {
  static String id = 'signup_page_web';
  @override
  _SignupWebState createState() => _SignupWebState();
}

class _SignupWebState extends State<SignupWeb> {
  final auth = FirebaseAuth.instance;
  String email = ' ';
  String password = ' ';
  String supplierId = "";
  String phoneNumber = "";
  String gender = '';
  String? selectedDepartment;
  String selectedNationality = "Ugandan";
  final _auth = FirebaseAuth.instance;

  Map<String, String> optionsToUpload = {};
  String errorMessage = 'Error Signing Up';
  double errorMessageOpacity = 0.0;
  String countryCode = ' ';
  String country = ' ';
  double opacityOfTextFields = 1.0;
  final RoundedLoadingButtonController _btnController =
  RoundedLoadingButtonController();
  bool showSpinner = false;
  bool ownerLogin = false;
  final TextEditingController businessNameController = TextEditingController();
  final TextEditingController serviceSuppliedController = TextEditingController();
  final TextEditingController nationalityController = TextEditingController();
  final TextEditingController nationalIdNumberController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();


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
      body: Row(
        children: [
          Expanded(
            flex: 1,
            child: Container(
              height: double.infinity,
              color: kAppPinkColor,
              child: Image.asset("images/businesspilot_store.png", fit: BoxFit.fitHeight,),
            ),
          ),
          Expanded(
            flex: 1,
            child: SingleChildScrollView(
              child: Container(
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
                                    TextForm(label:'Business Name', controller:businessNameController),
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
                                                country = value.name!;
                                              },
                                              onChanged: (value) {
                                                countryCode = value.dialCode!;
                                                country = value.name!;
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
                                    TextForm(label: 'Email',controller: emailController),
                                    TextForm(label: 'Password',controller: passwordController, password: true,),
              
              
              
                                    ElevatedButton(
              
                                      onPressed: ()async {

                                        if (businessNameController.text == "" || phoneNumber == "" || emailController.text =="" || passwordController.text == "" ) {
                                          CommonFunctions().alertDialogueError(context);
              
                                        } else
                                        {
                                          try{
                                            final newUser = await _auth.createUserWithEmailAndPassword(email: emailController.text,
                                                password: passwordController.text);
                                            if (newUser != null){
                                              CommonFunctions().setupStoreInFirestore(newUser.user?.uid, emailController.text, businessNameController.text, country, phoneNumber, "businessType", businessNameController.text, countryCode, country,  CommonFunctions().getCurrencyCode(countryCode, context), context);

                                              final prefs = await SharedPreferences.getInstance();
                                              prefs.setString(kLoginPersonName, businessNameController.text );
                                              prefs.setString(kStoreIdConstant, newUser.user!.uid);
                                              prefs.setString(kCountryCode, countryCode);
                                              prefs.setString(kCurrency, CommonFunctions().getCurrencyCode(countryCode, context));
                                              prefs.setString(kEmailConstant, email);
                                              prefs.setString(kPhoneNumberConstant, phoneNumber);
                                              prefs.setBool(kIsLoggedInConstant, true);
                                              prefs.setBool(kIsFirstTimeUser, true);
                                              prefs.setInt(kStoreOpeningTime, 7);
                                              prefs.setInt(kStoreClosingTime, 20);
                                              prefs.setStringList(kStoreImages, []);
                                              prefs.setBool(kDoesMobileConstant, true);



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

                                    TextButton(onPressed: (){
                                      Navigator.pushNamed(context, OnboardingStepper.id);
                                    }, child: Text("Onboarding Screens"))
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
            ),
          )
        ],
      ),
    );
  }
}
