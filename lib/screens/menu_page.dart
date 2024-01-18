


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:iconsax/iconsax.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stylestore/controllers/transactions_controller.dart';
import 'package:stylestore/model/styleapp_data.dart';
import 'package:stylestore/screens/calendar_pages/calendar_page.dart';
import 'package:stylestore/screens/customer_care_page.dart';
import 'package:stylestore/screens/edit_page.dart';
import 'package:stylestore/screens/reviews_page.dart';
import 'package:stylestore/screens/services_page.dart';
import 'package:stylestore/screens/team_pages/team_page.dart';
import 'package:stylestore/screens/tutorials_page.dart';
import 'package:stylestore/utilities/constants/color_constants.dart';
import 'package:flutter/material.dart';
import 'package:stylestore/utilities/constants/font_constants.dart';
import 'package:stylestore/screens/videos/tutorials_page_new.dart';

import '../Utilities/constants/user_constants.dart';
import '../model/common_functions.dart';
import '../model/menu_items.dart';
import '../widgets/rounded_icon_widget.dart';
import 'Messages/message_history.dart';
import 'sign_in_options/login_page.dart';


class MenuPage extends StatefulWidget {

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  //MenuItem('Payment', Icons.payment);
  List <SideMenuItem> all = [
    SideMenuItem(title: 'Edit Store', icon: Iconsax.building),
    SideMenuItem(title: 'Transactions', icon: Iconsax.money_recive),
    SideMenuItem(title: 'Messages', icon: Iconsax.message),
    SideMenuItem(title: 'Team', icon: Iconsax.people),
    SideMenuItem(title: 'Tutorials', icon: LineIcons.youtube),
    // SideMenuItem(title: 'Reviews', icon: LineIcons.star),
    // SideMenuItem(title: 'Tutorials', icon: LineIcons.youtube),
    // SideMenuItem(title: 'Customer Support', icon: Icons.support_agent)
  ];

  List pages = [
    EditShopPage.id,
    TransactionsController.id,
    MessageHistoryPage.id,
    TeamPage.id,
    NewTutorialPage.id,

  ];
  var liveStatus = '';
  var liveColor = Colors.green;

  final auth = FirebaseAuth.instance;
  Map<String, dynamic> permissionsMap = {};

  void defaultsInitiation()async{
    permissionsMap = await CommonFunctions().convertPermissionsJson();
    print(Provider.of<StyleProvider>(context, listen: false).isActive);
    if (Provider.of<StyleProvider>(context, listen: false).isActive == false){
      liveStatus = 'Offline';
      liveColor = Colors.red;
      setState((){
      });
    } else {
      liveStatus = 'Online';
      liveColor = Colors.green;
      setState((){
      });
    }
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    defaultsInitiation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBlueDarkColorOld,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Spacer(),
              kLargeHeightSpacing,
              Row(
                children: [
                  RoundImageRing(radius: 80, outsideRingColor: kPureWhiteColor, networkImageToUse: Provider.of<StyleProvider>(context).beauticianImageUrl,),
                  Spacer(),
                  // Container(
                  //   decoration: BoxDecoration(
                  //     borderRadius: BorderRadius.circular(10),
                  //     color: kBlueDarkColorOld,
                  //   ),
                  //   child:
                  //   Row(
                  //     children: [
                  //       Padding(
                  //         padding: const EdgeInsets.all(2.0),
                  //         child: Container(
                  //           decoration: BoxDecoration(
                  //             shape: BoxShape.circle,
                  //             // borderRadius: BorderRadius.circular(10),
                  //             color: kBackgroundGreyColor,
                  //           ),
                  //           child: Icon(Icons.circle, color: Provider.of<StyleProvider>(context).liveIndicatorColor,size: 15,),
                  //         ),
                  //       ),
                  //       kSmallWidthSpacing,
                  //       Text(Provider.of<StyleProvider>(context).liveIndicatorString, style: kNormalTextStyleWhiteLabel.copyWith( fontSize: 15, color: kPureWhiteColor),),
                  //       // kSmallWidthSpacing
                  //     ],
                  //   ),
                  // ),
                ],
              ),
              kLargeHeightSpacing,

              ListView.builder(
                  itemCount: all.length,
                  shrinkWrap: true ,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: (){
                        Navigator.pushNamed(context, pages[index]);
                      },
                      child: ListTile(
                        selectedTileColor: kAppPinkColor,
                        minLeadingWidth: 20,
                        leading: Text(all[index].title, style: kNormalTextStyleBoldPink.copyWith(color: kPureWhiteColor),),
                        trailing: Icon(all[index].icon, color: kPureWhiteColor,),
                      ),
                    );
                  }
              ),
              Spacer(),
              GestureDetector(
                onTap: (){
                  CommonFunctions().callPhoneNumber('0782081219');
                //   Navigator.pushNamed(context, CustomerCarePage.id);
                },
                child: ListTile(
                  selectedTileColor: kAppPinkColor,
                  minLeadingWidth: 20,
                  leading: Text('Customer Care', style: kNormalTextStyleBoldPink.copyWith(color: kPureWhiteColor),),
                  trailing: Icon(Icons.support_agent, color: kPureWhiteColor,),
                ),
              ),

              GestureDetector(
                  onTap: (){
                    CoolAlert.show(
                        context: context,
                        type: CoolAlertType.success,
                        widget: Column(
                          children: [
                            Text('Are you sure you want to Log Out?', textAlign: TextAlign.center, style: kNormalTextStyle,),

                          ],
                        ),
                        title: 'Log Out?',

                        confirmBtnColor: kFontGreyColor,
                        confirmBtnText: 'Yes',
                        confirmBtnTextStyle: kNormalTextStyleWhiteButtons,
                        lottieAsset: 'images/leave.json', showCancelBtn: true, backgroundColor: kBlack,


                        onConfirmBtnTap: () async{
                          final prefs = await SharedPreferences.getInstance();
                          prefs.setBool(kIsLoggedInConstant, false);
                          prefs.setBool(kIsFirstTimeUser, true);
                          await auth.signOut().then((value) => Navigator.pushNamed(context, LoginPage.id));



                        }


                    );
                  },
                  child: Text("Log Out", style:kNormalTextStyleBoldPink.copyWith(color: Colors.blue) ,)),
              kLargeHeightSpacing,
              permissionsMap['admin'] == true ?
              TextButton(onPressed: (){

                CoolAlert.show(
                    context: context,
                    type: CoolAlertType.success,
                    widget: Column(
                      children: const [
                        Text('Are you sure you want Delete this Account? All your data will be lost and this action cannot be undone', textAlign: TextAlign.center, style: kNormalTextStyle,),
                      ],
                    ),
                    title: 'Delete Account!',

                    confirmBtnColor: kFontGreyColor,
                    confirmBtnText: 'Yes',
                    confirmBtnTextStyle: kNormalTextStyleWhiteButtons,
                    lottieAsset: 'images/delete.json', showCancelBtn: true, backgroundColor: kBlack,


                    onConfirmBtnTap: () async{
                      // FirebaseUser user = await FirebaseAuth.instance.currentUser!();
                      // user.delete();
                      // CommonFunctions().signOut();
                      // // Navigator.pop(context);
                      // // Navigator.pop(context);
                      // // Navigator.pop(context);
                      // Navigator.pushNamed(context, WelcomePage.id)


                      final prefs = await SharedPreferences.getInstance();
                      prefs.setBool(kIsLoggedInConstant, false);
                      prefs.setBool(kIsFirstTimeUser, true);

                      await FirebaseFirestore.instance.collection('users').doc(auth.currentUser!.uid).delete().then((value) async =>
                      await auth.signOut().then((value) => Navigator.pushNamed(context, LoginPage.id)));

                      // await auth.signOut().then((value) => Navigator.pushNamed(context, WelcomePage.id));


                    }
                );



              }, child:  Text("Delete Account", style: kNormalTextStyle.copyWith(fontSize: 12),)):SizedBox(),


    ],
          ),
        ),
      ),
    );
  }
}


