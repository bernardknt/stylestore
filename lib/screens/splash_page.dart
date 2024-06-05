import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stylestore/model/beautician_data.dart';
import 'package:stylestore/model/common_functions.dart';
import 'package:stylestore/screens/sign_in_options/login_new_layout_web.dart';
import 'package:stylestore/utilities/constants/color_constants.dart';
import '../Utilities/constants/font_constants.dart';
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
    CommonFunctions().deliveryStream(context);

    CommonFunctions().userSubscription(context);
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
              .setVideoVariables(
            users['videos'],
          );
          CommonFunctions().openLink(Provider.of<StyleProvider>(context, listen: false).setVideoTutorials()) ;
          prefs.setString(kWalkthroughVideos, users["walkthroughs"]);

          Provider.of<BeauticianData>(context, listen: false).setAllEmployeePermission(CommonFunctions().convertPermissionsStringToJson(users["walkthroughs"]));
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



  bool userLoggedIn = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    defaultsInitiation();

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
              'Automate and Grow Yours Business',
              style: kHeadingTextStyleWhite.copyWith(color: kPureWhiteColor),
            )
          ]),
        ),
      ),
    );
  }
}
