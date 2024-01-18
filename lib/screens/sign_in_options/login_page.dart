
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stylestore/Utilities/constants/font_constants.dart';

import 'package:stylestore/screens/sign_in_options/employee_sign_in.dart';
import 'package:stylestore/screens/sign_in_options/signup_page.dart';
import 'package:stylestore/screens/tasks_pages/tasks_widget.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../controllers/home_controller.dart';
import '../../model/styleapp_data.dart';
import '../../utilities/constants/color_constants.dart';
import '../../utilities/constants/icon_constants.dart';
import '../../utilities/constants/user_constants.dart';
import'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';


class LoginPage extends StatefulWidget {
  static String id = 'login_page';
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // final RoundedLoadingButtonController _btnController = RoundedLoadingButtonController();
  final auth = FirebaseAuth.instance;
  String email = ' ';
  String password = ' ';

  final RoundedLoadingButtonController _btnController = RoundedLoadingButtonController();
  bool showSpinner = false;
  bool ownerLogin = false;



  // void subscribeToTopic()async{
  //   await FirebaseMessaging.instance.subscribeToTopic('beauticians').then((value) =>
  //   print('Succefully Subscribed')
  //   );
  // }
  Future deliveryStream() async {
    var prefs = await SharedPreferences.getInstance();
    var id = prefs.getString(kStoreIdConstant)!;
    // Provider.of<StyleProvider>(context, listen: false).clearSpecialityList();
    var start = FirebaseFirestore.instance.collection('medics').where('id', isEqualTo: id).
    snapshots().listen((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) async {
        Provider.of<StyleProvider>(context, listen: false).setAllStoreDefaults(doc['active'], doc['blackout'], doc['clients'], doc['close'], doc['open'], doc['doesMobile'], doc['location'],doc['modes'], doc['phone'], doc['name'], doc['image'], doc['transport']);
      });
      setState(() {

      });
    });

    return start;
  }

  void defaultsInitiation () async{
    final prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool(kIsLoggedInConstant) ?? false;
    setState(() {
      userLoggedIn = isLoggedIn ;
      if(userLoggedIn == true){
        Navigator.pushNamed(context, ControlPage.id);
      }else{
        print('NOT LOGGED IN');
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


      backgroundColor: kPureWhiteColor,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Stack(
                children: [
                  Lottie.asset("images/flying.json", fit: BoxFit.fitWidth),
                  Positioned(
                      bottom: 10,
                      top: 10,
                      right: 10,
                      child:
                      Container(
                          height: 50,
                          width: 50,
                          child: Image.asset("images/new_logo.png",))
                  ),
                  Positioned(
                      bottom: 10,
                      left: 10,
                      right: 10,
                      child: CircleAvatar(
                        backgroundColor: kAppPinkColor,
                          radius: 40,

                          child: Icon(Iconsax.shop, size: 40,))),
                  Positioned(
                      top: 10,
                      left: 10,
                      right: 10,
                      child: Text("YOUR BUSINESS ON AUTO PILOT",textAlign: TextAlign.center,style: kNormalTextStyle.copyWith(fontWeight: FontWeight.bold, color: kBlueDarkColor) ),

                  )
                ],
              ),
            //   SizedBox(
            //   height: 180,
            //   width: double.infinity,
            //
            //   //color: Colors.red,
            //   child: Stack(
            //     children: [
            //
            //       // Positioned(child: Container(
            //       //   decoration: const BoxDecoration(
            //       //     borderRadius: BorderRadius.only(bottomLeft: Radius.circular(90), bottomRight: Radius.circular(90)),
            //       //     image: DecorationImage
            //       //       (
            //       //         image:
            //       //         //Lottie.asset(name),
            //       //          AssetImage('images/welcome.jpg'),
            //       //         fit: BoxFit.fitWidth),
            //       //   ),
            //       // ))
            //     ],
            //   ),
            // ),
              //åSizedBox(height: 10,),
              //kLargeHeightSpacing,

              // kSmallHeightSpacing,
              // TextButton.icon(
              //     onPressed: (){
              //       // launchUrl(Uri.parse('https://skmjitdmvzo.typeform.com/to/WmADCAZW'));
              //       Navigator.pushNamed(context, RegisterPageDuplicate.id);
              //
              //     },
              //     label:Text("Create Business Account", style: kNormalTextStyle.copyWith(color: Colors.blueAccent),
              //     ), icon: kIconScissorWhite
              // ),
              // kLargeHeightSpacing,
              // kLargeHeightSpacing,
              // Container(
              //     height: 50,
              //     width: 50,
              //     child: Image.asset("images/new_logo.png",)),
              // kLargeHeightSpacing,
              Padding(padding: EdgeInsets.only(left: 50, right: 50,),
                  child:
                  Container(
                    height: 400,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Text("YOUR BUSINESS ON AUTO PILOT",textAlign: TextAlign.center,style: TextStyle(fontSize: 12, color: kBlack, fontFamily: "Helvitica", fontWeight: FontWeight.bold, ) ),
                        // kLargeHeightSpacing,

                        GestureDetector(
                          onTap: (){
                            Navigator.pushNamed(context, RegisterPageDuplicate.id);
                          },
                          child:
                          Container(
                            width: double.infinity,
                            height: 40,
                            decoration: BoxDecoration(
                              color: kPureWhiteColor,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: kPureWhiteColor,
                                width: 1,
                              ),
                            ),
                            child: Center(child: Text("Create a New Business Account", style: kNormalTextStyle.copyWith(color: kAppPinkColor),)),
                          ),
                        ),
                        kLargeHeightSpacing,
                        kLargeHeightSpacing,
                        ownerLogin == true? Container():GestureDetector(
                          onTap: (){
                          setState(() {
                            ownerLogin = true;
                          });
                          },
                          child:
                          Container(
                            width: double.infinity,
                            height: 40,
                            decoration: BoxDecoration(
                              color: kAppPinkColor,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: kPureWhiteColor,
                                width: 1,
                              ),
                            ),
                            child: Center(child: Text("Login as Business Owner", style: kNormalTextStyle.copyWith(color: kPureWhiteColor),)),
                          ),
                        ),
                        kSmallHeightSpacing,
                        ownerLogin== false?Container():Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: kBlueDarkColorOld,
                                      blurRadius: 3,
                                      offset: Offset(0,2),
                                    )
                                  ]
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                        border: Border(bottom: BorderSide(
                                            color: kBlueDarkColorOld
                                        ))
                                    ),
                                    child: TextField(

                                      onChanged: (value){
                                        email = value;
                                      },
                                      decoration: InputDecoration(
                                          border: InputBorder.none,
                                          hintText:  'Email Address',
                                          hintStyle: TextStyle(color: Colors.grey)
                                      ) ,
                                    )
                                    ,),
                                  // SizedBox(height: 10),
                                  Container(
                                    padding: EdgeInsets.all(10),

                                    child: TextField(
                                      obscureText: true,
                                      onChanged: (value){
                                        password = value;
                                      },
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText:  'Password',
                                        hintStyle: TextStyle(color: Colors.grey),
                                      ) ,
                                    )
                                    ,),
                                ],
                              ) ,
                            ),
                            TextButton(onPressed: (){
                              if(email != ''){
                                auth.sendPasswordResetEmail(email: email);
                                showDialog(context: context, builder: (BuildContext context){
                                  return CupertinoAlertDialog(
                                    title: Text('Reset Email Sent'),
                                    content: Text('Check email $email for the reset link'),
                                    actions: [CupertinoDialogAction(isDestructiveAction: true,
                                        onPressed: (){
                                          _btnController.reset();
                                          Navigator.pop(context);
                                        },
                                        child: Text('Cancel'))],
                                  );
                                });
                              }else{
                                showDialog(context: context, builder: (BuildContext context){
                                  return CupertinoAlertDialog(
                                    title: Text('Type Email'),
                                    content: Text('Please type your email Address and Click on the forgot password!'),
                                    actions: [CupertinoDialogAction(isDestructiveAction: true,
                                        onPressed: (){
                                          //_btnController.reset();
                                          Navigator.pop(context);
                                        },
                                        child: Text('Cancel'))],
                                  );
                                });
                              }

                            }, child: Text('Forgot Password')),
                            RoundedLoadingButton(
                              color: kAppPinkColor,
                              child: Text('Login', style: TextStyle(color: Colors.white)),
                              controller: _btnController,
                              onPressed: () async {
                                try{
                                  await auth.signInWithEmailAndPassword(email: email, password: password);
                                  final users = await FirebaseFirestore.instance.collection('users').doc(auth.currentUser!.uid).get();
                                  if(users['subscribed'] == false){
                                    print("WE ENTERED HERE");


                                    final store = await FirebaseFirestore.instance.collection('medics').doc(auth.currentUser!.uid).get();
                                    print("WE NEED THIS");
                                    final prefs = await SharedPreferences.getInstance();
                                    print('${store['open']}');
                                    prefs.setString(kBusinessNameConstant, store['name']);
                                    prefs.setString(kLocationConstant, store['location']);
                                    prefs.setString(kImageConstant, store['image']);
                                    prefs.setString(kStoreIdConstant, store['id']);
                                    prefs.setInt(kStoreOpeningTime, store['open']);
                                    prefs.setInt(kStoreClosingTime, store['close']);
                                    prefs.setString(kLoginPersonName, users['lastName']);
                                    prefs.setString(kPermissions, store['permissions']);
                                    prefs.setBool(kDoesMobileConstant, store['doesMobile']);
                                    prefs.setBool(kIsOwner,true);
                                    prefs.setString(kEmployeeId, users.id);
                                    //prefs.setStringList(kStoreIdConstant, store['blackout']);

                                    prefs.setString(kPhoneNumberConstant, users['phoneNumber']);
                                    prefs.setBool(kIsLoggedInConstant, true);
                                    // subscribeToTopic();
                                    deliveryStream();

                                    Navigator.pushNamed(context, ControlPage.id);
                                  } else {
                                    showDialog(context: context, builder: (BuildContext context){
                                      return CupertinoAlertDialog(
                                        title: Text('This account is not Registered for Beautician'),
                                        content: Text('The credentials you have entered are incorrect'),
                                        actions: [CupertinoDialogAction(isDestructiveAction: true,
                                            onPressed: (){
                                              _btnController.reset();
                                              Navigator.pop(context);
                                            },
                                            child: Text('Cancel'))],
                                      );
                                    });
                                  }

                                  //showSpinner = false;
                                }catch(e) {
                                  _btnController.error();
                                  showDialog(context: context, builder: (BuildContext context){
                                    return CupertinoAlertDialog(
                                      title: Text('Oops Login Failed'),
                                      content: Text("$e"),
                                      actions: [CupertinoDialogAction(isDestructiveAction: true,
                                          onPressed: (){
                                            _btnController.reset();
                                            Navigator.pop(context);
                                          },
                                          child: Text('Cancel'))],
                                    );
                                  });
                                }
                              },
                            ),
                          ],
                        ),


                        kLargeHeightSpacing,
                        GestureDetector(
                          onTap: (){
                           Navigator.pushNamed(context, EmployeeSignIn.id);
                          },
                          child:
                          Container(
                            width: double.infinity,
                            height: 40,
                            decoration: BoxDecoration(
                              color: kBlueDarkColor,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: kPureWhiteColor,
                                width: 1,
                              ),
                            ),
                            child: Center(child: Text("Login as Staff Member", style: kNormalTextStyle.copyWith(color: kPureWhiteColor),)),
                          ),
                        ),
                        kLargeHeightSpacing,

                      ],
                    ),
                  )
              ),
            ],
          ),
        ),
      ),
    );
  }
}
