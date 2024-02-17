import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
// import 'package:new_version/new_version.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stylestore/controllers/home_page_controllers/home_control_page_web.dart';
import 'package:stylestore/model/beautician_data.dart';
import 'package:stylestore/model/common_functions.dart';
import 'package:stylestore/screens/sign_in_options/logi_new_layout_web.dart';
import 'package:stylestore/utilities/constants/color_constants.dart';

import '../Utilities/constants/font_constants.dart';
import '../controllers/home_page_controllers/home_controller_mobile.dart';
import '../controllers/responsive/responsive_page.dart';
import '../model/styleapp_data.dart';
import '../utilities/constants/user_constants.dart';
import 'sign_in_options/login_page.dart';

class SplashPage extends StatefulWidget {
  static String id = 'splash_page';

  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  late Timer _timer;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  void defaultsInitiation() async {
    final prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool(kIsLoggedInConstant) ?? false;
    String oldPermissions = prefs.getString(kPermissions) ?? "";
    bool ownerStatus = prefs.getBool(kIsOwner) ?? false;
    _firebaseMessaging
        .getToken()
        .then((value) => prefs.setString(kToken, value!));
    var start = FirebaseFirestore.instance
        .collection('variables')
        .snapshots()
        .listen((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((users) async {
        setState(() {
          Provider.of<StyleProvider>(context, listen: false)
              .setSubscriptionVariables(
            users['videos'],
          );
          prefs.setString(kWalkthroughVideos, users["walkthroughs"]);

          Provider.of<BeauticianData>(context, listen: false)
              .setAllEmployeePermission(CommonFunctions()
                  .convertPermissionsStringToJson(users["walkthroughs"]));
        });
      });
    });


    if (ownerStatus == false) {
      var employ = FirebaseFirestore.instance
          .collection('employees')
          .where("id", isEqualTo: prefs.getString(kEmployeeId) ?? "")
          .snapshots()
          .listen((QuerySnapshot querySnapshot) {
        querySnapshot.docs.forEach((users) async {
          prefs.setString(kPermissions, users["permissions"]);
          print("permissions:${users["permissions"]}");
          Provider.of<BeauticianData>(context, listen: false)
              .setAllEmployeePermission(CommonFunctions()
                  .convertPermissionsStringToJson(users["permissions"]));

          setState(() {
            if (users["permissions"] != oldPermissions) {
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Permissions were Updated')));
              Navigator.pushNamed(context, SplashPage.id);
            }

            // setSubscriptionVariables( users['videos'],);
          });
        });
      });
    }

    setState(() {
      userLoggedIn = isLoggedIn;
      print('The login status is $isLoggedIn');
      if (userLoggedIn == true) {
        _timer = new Timer(const Duration(milliseconds: 1500), () {
          // _checkAppVersion();
          Navigator.pushNamed(context, SuperResponsiveLayout.id);
          print("Yeeeeep This run");
          // _checkAppVersion();
        });
      } else {
        _timer = new Timer(const Duration(milliseconds: 1000), () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SuperResponsiveLayout(
                mobileBody: LoginPage(),
                desktopBody: LoginPageNewWeb(),
              ),
            ),
          );
        });
      }
    });
  }

  // _checkAppVersion() async {
  //   final newVersion = NewVersion(
  //     iOSId: "com.kingdomfinanciers.stylestore.stylestore",
  //     androidId: "com.kingdomfinanciers.stylestore.stylestore",
  //   );
  //   final status = await newVersion.getVersionStatus();
  //   var latest = status!.localVersion;
  //   if (status.canUpdate!) {
  //
  //     // Show bottom sheet for update
  //     showModalBottomSheet(
  //       context: context,
  //       builder: (context) => BottomSheet(
  //         onClosing: () {},
  //         builder: (context) => Container(
  //           padding: const EdgeInsets.all(20),
  //           child: Column(
  //             mainAxisAlignment: MainAxisAlignment.center,
  //             crossAxisAlignment: CrossAxisAlignment.stretch,
  //             mainAxisSize: MainAxisSize.min,
  //             children: [
  //               Text(
  //                 "New Version Available",
  //                 style: TextStyle(
  //                   fontSize: 18,
  //                   fontWeight: FontWeight.bold,
  //                 ),
  //                 textAlign: TextAlign.center,
  //               ),
  //               SizedBox(height: 20),
  //               Text(
  //                 "We have been hard at work to bring you an amazing new version of our app!\nGet version: ${status.storeVersion} From ${status.localVersion}",
  //                 textAlign: TextAlign.center,
  //               ),
  //               SizedBox(height: 20),
  //               ElevatedButton(
  //                 style: ButtonStyle(backgroundColor: MaterialStateProperty.all(kGreenThemeColor)),
  //                 onPressed: () {
  //                   if (Platform.isAndroid) {
  //                     newVersion.launchAppStore("https://apps.apple.com/us/app/open-e/id6443682456");
  //                   } else if (Platform.isIOS) {
  //                     newVersion.launchAppStore("https://play.google.com/store/apps/details?id=com.kingdomfinanciers.stylestore.stylestore");
  //                   } else {
  //                     print("Unknown OS");
  //                   }
  //                   newVersion.launchAppStore("https://apps.apple.com/us/app/open-e/id6443682456");
  //                   Navigator.pop(context); // Close the bottom sheet
  //                 },
  //                 child: Text("Update", style: kNormalTextStyle.copyWith(color: kPureWhiteColor),),
  //               ),
  //               SizedBox(height: 10),
  //               TextButton(
  //                 onPressed: () {
  //                   Navigator.pop(context); // Close the bottom sheet
  //                   // defaultsInitiation();
  //                 },
  //                 child: Text("Cancel"),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ),
  //     );
  //   } else {
  //     // defaultsInitiation(); // Continue with the normal flow if no update is needed
  //   }
  // }

  Future deliveryStream() async {
    var prefs = await SharedPreferences.getInstance();
    var id = prefs.getString(kStoreIdConstant)!;

    var start = FirebaseFirestore.instance
        .collection('medics')
        .where('id', isEqualTo: id)
        .snapshots()
        .listen((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) async {
        prefs.setString(kPhoneNumberConstant, doc['phone']);
        prefs.setString(kImageConstant, doc['image']);
        prefs.setDouble(kSmsAmount, doc['sms']);
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

      setState(() {});
    });

    return start;
  }

  bool userLoggedIn = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    defaultsInitiation();
    deliveryStream();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: kBlueDarkColorOld,
      body: Container(
        padding: EdgeInsets.all(40),
        decoration: BoxDecoration(
          image: DecorationImage(
            colorFilter: ColorFilter.mode(Colors.black26, BlendMode.darken),
            image: AssetImage('images/welcome.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            // Image.asset('images/logo_white2.png',),
            Text(
              'Manage and Grow your Business',
              style: kHeadingTextStyleWhite.copyWith(color: kPureWhiteColor),
            )
          ]),
        ),
      ),
    );
  }
}
