
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:slider_button/slider_button.dart';
import 'package:stylestore/controllers/home_controller.dart';
import 'package:stylestore/model/common_functions.dart';
import 'package:stylestore/model/styleapp_data.dart';
import 'package:stylestore/screens/sign_in_options/login_page.dart';
import 'package:stylestore/utilities/constants/font_constants.dart';
import 'package:uuid/uuid.dart';

import '../../Utilities/constants/color_constants.dart';
import '../../Utilities/constants/user_constants.dart';
import '../tasks_pages/tasks_widget.dart';



class SignInUserPage extends StatefulWidget {
  static String id = 'signInUser';


  @override
  _SignInUserPageState createState() => _SignInUserPageState();
}



class _SignInUserPageState extends State<SignInUserPage> {
  var uuid = Uuid();
  var name = '';
  var companyName = '';
  var qrcodeTruth = true;
  final auth = FirebaseAuth.instance;
  var token = '';
  var storeId = '';
  bool isShowingScanner = true;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  String qrCode = "";
  Map<String, dynamic> permissionsMap = {};

  void defaultInitialization()async{
    final prefs = await SharedPreferences.getInstance();
    permissionsMap = await CommonFunctions().convertPermissionsJson();
    setState((){
      name = prefs.getString(kLoginPersonName)!;
      companyName = prefs.getString(kBusinessNameConstant)!;
      storeId = prefs.getString(kStoreIdConstant)!;

    });
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((barcode) {
      print("${barcode.code}");

      // Navigator.pushNamed(context, ControlPage.id);
     // Navigator.pop(context);

      setState(() {
        qrCode = barcode.code?? "";
      });
      if (qrCode == storeId){
        controller.dispose();
        upLoadOrder();
      } else {
        controller.dispose();
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return CupertinoAlertDialog(
              title: Text("Wrong Code Scanned"),
              content: Text("Wrong code scanned for this store."),
              actions: [
                CupertinoDialogAction(
                  child: Text("OK"),
                  onPressed: () {
                    Navigator.of(context).pop();
                    setState(() {

                    });
                    // Close the dialog
                  // Navigate back to the home page
                  },
                ),
              ],
            );
          },
        );
      }

    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void initState() {
    // TODO: implement initState
    super.initState();
    defaultInitialization();
    _firebaseMessaging.getToken().then((value) async{
      final prefs = await SharedPreferences.getInstance();
      token = value!;
      prefs.setString(kToken, token);

    } );

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBlack,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          GestureDetector(
            onTap: (){
              showDialog(context: context, builder: (BuildContext context){
                return
                  Scaffold(
                      appBar: AppBar(
                        elevation: 0,
                        title: Text("Your Tasks",style: kNormalTextStyle.copyWith(color: kBlack),),
                        centerTitle: true,
                        backgroundColor: kPureWhiteColor,
                      ),
                      body: TasksWidget());
              });



            },
            child: Container(
              // height: 10,
              width: 100,
              decoration: BoxDecoration(
                color: kBlack,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(child: Text("Tasks", style: kNormalTextStyle.copyWith(color: kPureWhiteColor, fontSize: 13),)),
              // color: kAirPink,
            ),
          )
        ],
        leading: TextButton(onPressed: () {

            CoolAlert.show(
                context: context,
                type: CoolAlertType.success,
                widget: Column(
                  children: [
                    Text('Are you sure you want to Log Out of the Application?', textAlign: TextAlign.center, style: kNormalTextStyle,),

                  ],
                ),
                title: 'Log Out?',

                confirmBtnColor: kFontGreyColor,
                confirmBtnText: 'Yes',
                confirmBtnTextStyle: kNormalTextStyleWhiteButtons,
                lottieAsset: 'images/leave.json', showCancelBtn: true, backgroundColor: kAppPinkColor,


                onConfirmBtnTap: () async{
                  final prefs = await SharedPreferences.getInstance();
                  prefs.setBool(kIsLoggedInConstant, false);
                  prefs.setBool(kIsFirstTimeUser, true);
                  await auth.signOut().then((value) => Navigator.pushNamed(context, LoginPage.id));



                }


            );

        }, child: Icon(Icons.logout_sharp, color: kPureWhiteColor,)),

      ),
      body: WillPopScope(
        onWillPop: ()async{
          return false;
        },
        child: Stack(
          children: [Container(
            color: Colors.black,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                Text("Welcome to ${Provider.of<StyleProvider>(context, listen: false).beauticianName}\n $name",textAlign: TextAlign.center, style: kHeading2TextStyleBold.copyWith(color: kPureWhiteColor),),
                kLargeHeightSpacing,
                permissionsMap['qrCode'] ?? false == true  ?
                Column(

                  children: [
                    Text("Scan the QR Code to Sign in",style: kNormalTextStyle.copyWith(color: kPureWhiteColor), ),
                    kSmallHeightSpacing,
                    Container(
                      width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.only(left:70.0, right: 70.0 ),
                        child:
                        Container(
                          width: 250,
                          height: 250,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: kAppPinkColor,
                              width: 3.0,
                            ),),
                          child: _buildQRView()
                          // QRView(
                          //   key: qrKey,
                          //   onQRViewCreated: _onQRViewCreated,
                          // ),
                        ),
                      ),
                    ),
                  ],
                ):
                Center(
                  child:
                  SliderButton(
                    action: () async{
                      final prefs = await SharedPreferences.getInstance();
                      prefs.setBool(kIsCheckedIn, true);
                      upLoadOrder();

                    },
                    ///Put label over here
                    label:
                    Text(
                      "Slide to Sign Into Work",
                      style: kNormalTextStyle.copyWith(fontSize: 14),
                    ),
                    icon: const Center(
                      // child: Image.asset('images/logo.png',height: 40,)
                        child: Icon(
                          LineIcons.signature,
                          color: Colors.white,
                          size: 30.0,
                        )
                    ),

                    //Put BoxShadow here
                    boxShadow: BoxShadow(
                      color: Colors.black,
                      blurRadius: 4,
                    ),
                    width: 250,
                    radius: 100,
                    buttonColor: kAppPinkColor,
                    backgroundColor: kBiegeThemeColor,
                    highlightedColor: Colors.black,
                    baseColor: kAppPinkColor,
                  ),

                ),


              ],
            ),
          ),
            Positioned(
                bottom: 10,
                right: 100,
                left: 20,

                child: Row(
                  children: [

                    Icon(Icons.copyright, color: kPureWhiteColor,size: 14,),
                    Text('BusinessPilot 2023',style: kNormalTextStyle.copyWith(color: kPureWhiteColor, fontSize: 10),),
                  ],
                ))
        ]
        ),
      ),
    );

  }

  Widget _buildQRView() {
    final qrKey = GlobalKey(debugLabel: 'QR');
    return QRView(
      key: qrKey,
      onQRViewCreated: (controller) {
        this.controller = controller;
        controller.scannedDataStream.listen((barcode) {
          setState(() {
            if (qrCode != barcode.code) {
              qrCode = barcode.code!;

              // Check if the scanned QR code is correct
              if (qrCode == storeId) {
                // Navigate back to the home page
                upLoadOrder();
              } else {
                // Show a dialog for wrong QR code
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return CupertinoAlertDialog(
                      title: Text("Wrong Code Scanned"),
                      content: Text("Wrong code scanned for this store."),
                      actions: [
                        CupertinoDialogAction(
                          child: Text("OK"),
                          onPressed: () {
                            Navigator.of(context).pop(); // Close the dialog
                            setState(() {
                              isShowingScanner = true; // Reopen the QR scanner
                            });
                          },
                        ),
                      ],
                    );
                  },
                );
              }
            }
          });
        });
      },
    );
  }
  Future<void> upLoadOrder ()async {
    final dateNow = new DateTime.now();
    CollectionReference userOrder = FirebaseFirestore.instance.collection('attendance');
    final prefs =  await SharedPreferences.getInstance();
    ScaffoldMessenger.of(context).showSnackBar( SnackBar(content: Text('Welcome aboard $companyName, $name.')));

    String orderId = '${DateTime.now()}${uuid.v1().split("-")[0]}';

    try {
      userOrder.doc(orderId)
          .set({
        'name': prefs.getString(kLoginPersonName),
        'signOut': dateNow,
        'phoneNumber': prefs.getString(kPhoneNumberConstant),
        'signIn':dateNow,
        'id': orderId,
        'storeId': prefs.getString(kStoreIdConstant),
        'token': token,

      })
          .then((value) {
        prefs.setBool(kIsCheckedIn, true);
        prefs.setString(kSignInId, orderId);
        prefs.setString(kAttendanceCode, orderId);
        Navigator.pop(context);

        // Navigator.pushNamed(context, ControlPage.id);
        CommonFunctions().updateEmployeeSignInAndOutDoc(true);

        // updateNotifyArray(token);

      } )
          .catchError((error) => print("Failed to add user: $error"));
    }catch (e){
      print("UOLOLOLOLOLOLOLO: $e");
    }

  }
}