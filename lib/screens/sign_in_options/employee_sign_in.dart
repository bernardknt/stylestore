
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Utilities/constants/color_constants.dart';
import '../../Utilities/constants/font_constants.dart';

import '../../controllers/home_controller.dart';
import '../../model/common_functions.dart';
import '../../model/styleapp_data.dart';
import '../../utilities/constants/user_constants.dart';



class EmployeeSignIn extends StatefulWidget {
  static String id = 'employee_sign_in';




  @override
  State<EmployeeSignIn> createState() => _EmployeeSignInState();
}

class _EmployeeSignInState extends State<EmployeeSignIn> {
  TextEditingController countryController = TextEditingController();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  String token = "";
  Map<String, dynamic> permissionsMap = {};


  void updateNotificationsIfAdmin(documentId)async{
    permissionsMap = await CommonFunctions().convertPermissionsJson();
    if (permissionsMap['admin'] == true) {
      FirebaseFirestore.instance.collection('medics').doc(documentId)
          .update({
        'adminTokens': FieldValue.arrayUnion([token]),
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    countryController.text = "+256";
    super.initState();
    _firebaseMessaging.getToken().then((value) async{
      final prefs = await SharedPreferences.getInstance();
      token = value!;
      prefs.setString(kToken, token);
    } );
  }
  var countryName = '';
  var countryFlag = '';
  var countryCode = "+256";
  var code = "";
  final RoundedLoadingButtonController _btnController = RoundedLoadingButtonController();

  var phoneNumber = '';
  final formKey = GlobalKey<FormState>();



  Future<void> checkPhoneNumberAndCode(String phoneNumber, String code) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    final prefs = await SharedPreferences.getInstance();

    try {
      QuerySnapshot querySnapshot = await firestore.collection('employees')
          .where('phoneNumber', isEqualTo: phoneNumber)
          .where('code', isEqualTo: code)
          .get();
      var users = querySnapshot.docs[0];

      if (querySnapshot.docs.isNotEmpty) {
        String storeId = querySnapshot.docs[0]['storeId'];

        DocumentSnapshot store = await firestore.collection('medics').doc(storeId).get();

        if (store.exists) {
          print("THIS RUN");


          prefs.setString(kBusinessNameConstant, store['name']);
          prefs.setString(kLocationConstant, store['location']);
          prefs.setString(kImageConstant, store['image']);
          prefs.setString(kStoreIdConstant, store['id']);
          prefs.setInt(kStoreOpeningTime, store['open']);
          prefs.setInt(kStoreClosingTime, store['close']);
          prefs.setString(kPermissions, users['permissions']);
          prefs.setString(kLoginPersonName, users['name']);
          prefs.setBool(kDoesMobileConstant, store['doesMobile']);
          prefs.setString(kEmployeeId,  users['id'] );
          prefs.setBool(kIsOwner,  false );
          prefs.setBool(kIsCheckedIn, false);
          // prefs.setString(kPhoneNumberConstant,users['phoneNumber']);
          prefs.setString(kPhoneNumberConstant,store['businessPhone']);
          prefs.setBool(kIsLoggedInConstant, true);

          deliveryStream();
          updateNotificationsIfAdmin(storeId);
          Navigator.pushNamed(context, ControlPage.id);

        } else {

          _showCupertinoDialog(context, 'Phone number and code not found');
        }
      } else {

        _showCupertinoDialog(context, 'Phone number and code not found');

      }
    } catch (error) {
      _showCupertinoDialog(context, "Negative, Captain. The PIN doesn't match our coordinates. Please re-enter your access code to stay on course.");
    }
  }

  void _showCupertinoDialog(BuildContext context, String message) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text('Status'),
          content: Text(message),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text('OK'),
              onPressed: () {
                _btnController.reset();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future deliveryStream() async {

    var prefs = await SharedPreferences.getInstance();
    var id = prefs.getString(kStoreIdConstant)!;
    // Provider.of<StyleProvider>(context, listen: false).clearSpecialityList();
    var start = FirebaseFirestore.instance.collection('medics').where(
        'id', isEqualTo: id).
    snapshots().listen((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) async {
        Provider.of<StyleProvider>(context, listen: false).setAllStoreDefaults(
            doc['active'],
            doc['blackout'],
            doc['clients'],
            doc['close'],
            doc['open'],
            doc['doesMobile'],
            doc['location'],
            doc['modes'],
            doc['phone'],
            doc['name'],
            doc['image'],
            doc['transport']);
      });
      setState(() {

      });
    });
  }






  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kAppPinkColor,
        foregroundColor: kPureWhiteColor,
        centerTitle: true,
        title: Text("Employee Sign In",style: kNormalTextStyle.copyWith(color: kPureWhiteColor),),
      ),
      body: Form(
        key: formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Container(
          margin: EdgeInsets.only(left: 25, right: 25),
          alignment: Alignment.center,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                Text(
                  "Enter Your Phone Number and\nEmployee Pin",textAlign: TextAlign.center,
                  style: kNormalTextStyle.copyWith(color: kBlack, fontSize: 18),
                ),

                kLargeHeightSpacing,

                Container(
                  height: 53,
                  decoration: BoxDecoration(
                      border: Border.all(width: 1, color: Colors.grey),
                      borderRadius: BorderRadius.circular(10)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 10,
                      ),
                      CountryCodePicker(
                        onInit: (value){
                          countryCode = value!.dialCode!;
                          countryName = value!.name!;
                          countryFlag = value!.flagUri!;

                        },
                        onChanged: (value){
                          countryCode = value.dialCode!;
                          countryName = value.name!;
                          countryFlag = value.flagUri!;

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
                        style: TextStyle(fontSize: 25, color: Colors.grey),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                          child:

                          TextFormField(
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
                                hintText: "771234567",
                                hintStyle: kNormalTextStyle.copyWith(color: Colors.grey[500])

                            ),
                          ))
                    ],
                  ),
                ),
                kLargeHeightSpacing,
                Pinput(
                  length: 4,
                  // defaultPinTheme: defaultPinTheme,
                  // focusedPinTheme: focusedPinTheme,
                  // submittedPinTheme: submittedPinTheme,
                  onChanged: (value){
                    code = value;
                    print(value);

                  },

                  showCursor: true,
                  onCompleted: (pin) => print(pin),
                ),
                kLargeHeightSpacing,

                kLargeHeightSpacing,
                RoundedLoadingButton(
                  color: kAppPinkColor,
                  child: Text('Login', style: TextStyle(color: Colors.white)),
                  controller: _btnController,
                  onPressed: () async {
                    print("$phoneNumber : $code");
                    if (phoneNumber == ""||code ==""){
                      _btnController.error();
                    } else {
                      checkPhoneNumberAndCode(phoneNumber, code);
                    }




                  },
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}
