
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stylestore/Utilities/constants/color_constants.dart';
import 'package:stylestore/model/common_functions.dart';
import 'package:stylestore/utilities/constants/user_constants.dart';

import '../../../Utilities/constants/font_constants.dart';
import '../../../controllers/responsive/responsive_page.dart';
import '../../../widgets/text_form.dart';


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
  String countryCode = '';
  String country = '';
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
        CommonFunctions().showCountryPreference(context);
      }
    });
  }

  bool userLoggedIn = false;

  @override
  void initState() {
    // TODO: implement initState
    defaultsInitiation();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text("Create Account", style: kNormalTextStyle.copyWith(fontWeight: FontWeight.bold, fontSize: 16),),
      ),
      backgroundColor: kPureWhiteColor,
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
            child:
            SingleChildScrollView(
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
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: kBlueDarkColor
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    // Departments dropdown
                                    Text(
                                      "CREATE YOUR ACCOUNT",
                                      style: kNormalTextStyle.copyWith(
                                          color: kPureWhiteColor,
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold),
                                    ),

                                    TextForm(label: 'Email',controller: emailController, labelColor: kPureWhiteColor,),
                                    TextForm(label: 'Password',controller: passwordController, password: true,labelColor: kPureWhiteColor,),
              
              
              
                                    ElevatedButton(
              
                                      onPressed: ()async {

                                        if (emailController.text =="" || passwordController.text == "") {
                                          CommonFunctions().alertDialogueError(context);
              
                                        } else
                                        {
                                          try{
                                            final newUser = await _auth.createUserWithEmailAndPassword(email: emailController.text,
                                                password: passwordController.text);
                                            if (newUser != null){

                                              final prefs = await SharedPreferences.getInstance();
                                              // prefs.setString(kLoginPersonName, businessNameController.text );
                                              prefs.setString(kStoreIdConstant, newUser.user!.uid);
                                              // prefs.setString(kCountryCode, countryCode);
                                              // prefs.setString(kCurrency, CommonFunctions().getCurrencyCode(countryCode, context));
                                              prefs.setString(kEmailConstant, email);
                                              // prefs.setString(kPhoneNumberConstant, phoneNumber);
                                              prefs.setBool(kIsLoggedInConstant, true);
                                              prefs.setBool(kIsFirstTimeUser, true);
                                              // prefs.setInt(kStoreOpeningTime, 7);
                                              // prefs.setInt(kStoreClosingTime, 20);
                                              prefs.setStringList(kStoreImages, []);
                                              prefs.setBool(kDoesMobileConstant, true);

                                              //Get Prefs
                                              countryCode = prefs.getString(kCountryCode)??"+256";
                                              country = prefs.getString(kCountry)??"Uganda";

                                              CommonFunctions().setupStoreInFirestore(newUser.user?.uid, emailController.text, "", country, "", "businessType","", countryCode, country,  CommonFunctions().getCurrencyCode(countryCode, context), context);




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
