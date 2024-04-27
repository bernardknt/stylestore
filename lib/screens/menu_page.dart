
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stylestore/controllers/transactions_controller.dart';
import 'package:stylestore/model/styleapp_data.dart';
import 'package:stylestore/screens/edit_page.dart';
import 'package:stylestore/screens/employee_pages/employees_page.dart';
import 'package:stylestore/screens/sign_in_options/login_new_layout_web.dart';
import 'package:stylestore/screens/suppliers/supplier_page.dart';
import 'package:stylestore/utilities/constants/color_constants.dart';
import 'package:flutter/material.dart';
import 'package:stylestore/utilities/constants/font_constants.dart';
import 'package:stylestore/utilities/constants/icon_constants.dart';
import 'package:stylestore/utilities/constants/word_constants.dart';
import '../Utilities/constants/user_constants.dart';
import '../controllers/responsive/responsive_page.dart';
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
  List <SideMenuItem> all = [
    SideMenuItem(title: 'Edit Store', icon: kIconStore),
    // SideMenuItem(title: cStore, icon: Icons.chat_outlined),
    SideMenuItem(title: cTeam, icon: kIconTeam),
    SideMenuItem(title: cSuppliers, icon: kIconSuppliers),
    SideMenuItem(title: cMessagingTab, icon: kIconMessage),
    SideMenuItem(title: cTransactions, icon: kIconTransaction),


    // SideMenuItem(title: 'Business Wallet', icon: Icons.monetization_on_outlined),

  ];

  List pages = [
    EditShopPage.id,
    EmployeesPage.id,
    SuppliersPage.id,
    MessageHistoryPage.id,
  TransactionsController.id,
    // WalletsPage.id
    // NewTutorialPage.id,

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
                          await auth.signOut().then((value) => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SuperResponsiveLayout(
                                mobileBody: LoginPage(),
                                desktopBody: LoginPageNewWeb(),
                              ),
                            ),
                          ));
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


