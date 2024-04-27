import 'package:cool_alert/cool_alert.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sidebarx/sidebarx.dart';
import 'package:stylestore/Utilities/constants/font_constants.dart';
import 'package:stylestore/controllers/responsive/responsive_page.dart';
import 'package:stylestore/controllers/transactions_controller.dart';
import 'package:stylestore/screens/Messages/message_history.dart';
import 'package:stylestore/screens/edit_page.dart';
import 'package:stylestore/screens/home_pages/home_page_web.dart';
import 'package:stylestore/screens/payment_pages/pos_mobile.dart';
import 'package:stylestore/screens/payment_pages/pos_web.dart';
import 'package:stylestore/screens/store_pages/store_page_web.dart';
import 'package:stylestore/screens/suppliers/supplier_page.dart';
import 'package:stylestore/utilities/constants/icon_constants.dart';

import 'package:stylestore/utilities/constants/word_constants.dart';

import '../../model/common_functions.dart';
import '../../model/styleapp_data.dart';
import '../../screens/analytics/deeper_analytics/analytics_new_web.dart';
import '../../screens/employee_pages/employees_page.dart';
import '../../screens/store_pages/store_page.dart';
import '../../screens/sign_in_options/login_new_layout_web.dart';
import '../../screens/sign_in_options/login_page.dart';
import '../../utilities/constants/color_constants.dart';
import '../../utilities/constants/user_constants.dart';


class ControlPageWeb extends StatefulWidget {
  static String id = "control_page_web_new";
  const ControlPageWeb({super.key});

  @override
  State<ControlPageWeb> createState() => _ControlPageWebState();
}

class _ControlPageWebState extends State<ControlPageWeb> {
  Widget _selectedWidget = HomePageWeb();
  final _controller = SidebarXController(selectedIndex: 0, extended: true);// Initialize controller
  int subscriptionDate = DateTime.now().millisecondsSinceEpoch;

  Color selectedColor = kGreenThemeColor.withOpacity(0.5); // Default selected widget
  final auth = FirebaseAuth.instance;
  final divider = Divider(color: kBlack.withOpacity(0.3), height: 1);

  defaultInitialization()async{
    final prefs = await SharedPreferences.getInstance();
    subscriptionDate = prefs.getInt(kSubscriptionEndDate)??subscriptionDate;

    setState(() {
      print("End Date: $subscriptionDate |Today:${DateTime.now().millisecondsSinceEpoch}");
    });

  }
  @override
  initState() {

    super.initState();
    defaultInitialization();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPlainBackground,
      body: Row(
        children: [
          SidebarX(
            controller: _controller,
            theme: SidebarXTheme(
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: kPureWhiteColor,
                borderRadius: BorderRadius.circular(20),
              ),
              hoverColor: kAppPinkColor.withOpacity(0.5),
              textStyle: TextStyle(color: kBlack.withOpacity(0.7)),
              selectedTextStyle: const TextStyle(color: kPureWhiteColor),
              itemTextPadding: const EdgeInsets.only(left: 30),
              selectedItemTextPadding: const EdgeInsets.only(left: 30),
              itemDecoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: kPureWhiteColor.withOpacity(0.37))),
              selectedItemDecoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: kBlueDarkColor.withOpacity(0.1),
                ),
                gradient: const LinearGradient(
                  colors: [kBlueDarkColor, kAppPinkColor],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.28),
                    blurRadius: 30,
                  )
                ],
              ),
              iconTheme: IconThemeData(
                color: kBlack.withOpacity(0.7),
                size: 20,
              ),
              selectedIconTheme: const IconThemeData(
                color: Colors.white,
                size: 20,
              ),
            ),
            extendedTheme: const SidebarXTheme(
              width: 200,
              decoration: BoxDecoration(
                color: kPureWhiteColor,
              ),
            ),
            footerDivider: divider,
            // Create a footer builder with sign out button
            footerBuilder: (context, extended) {
              return

                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                        onTap:(){
                          Navigator.pushNamed(context, EditShopPage.id);

                        },
                          child: const Icon(Icons.settings)),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                          onTap: () async {

                            CoolAlert.show(
                                width: MediaQuery.of(context).size.width > 600 ? 400 : MediaQuery.of(context).size.width * 0.8,

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
                                  )
                                  );
                                }


                            );
                          },
                          child: const Text('Log out', style: kNormalTextStyle,))
                    ),
                  ],
                );
            },

            headerBuilder: (context, extended) {
              return SizedBox(
                height: 50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Image.asset('images/new_logo.png'),
                      kSmallWidthSpacing,
                     subscriptionDate>= DateTime.now().millisecondsSinceEpoch ?
                     Text("PREMIUM",overflow: TextOverflow.ellipsis, style: kNormalTextStyle.copyWith(color: kAppPinkColor, fontWeight: FontWeight.bold, fontSize: 12),)
                     :Text("Basic",overflow: TextOverflow.ellipsis, style: kNormalTextStyle.copyWith(color: kAppPinkColor, fontWeight: FontWeight.bold, fontSize: 12),)
                    ],
                  ),
                ),
              );
            },
            items: [
              SidebarXItem(
                label: cHome,
                onTap: () {
                  setState(() {
                    _selectedWidget = HomePageWeb();
                  });
                },
                icon: kIconHome,
              ),
              SidebarXItem(
                label: cPOS,
                onTap: () {
                  setState(() {
                    _selectedWidget = SuperResponsiveLayout(mobileBody: POS(), desktopBody: PosWeb(showBackButton: false,));
                  });
                },
                // page: EmployeesPage(),
                icon:kIconPos
                //Icons.storefront,
              ),
              SidebarXItem(
                  label: '${CommonFunctions().getFirstWord(Provider.of<StyleProvider>(context, listen: false).beauticianName)} Store',
                  onTap: () {
                    setState(() {
                      _selectedWidget = SuperResponsiveLayout(mobileBody: StorePageMobile(), desktopBody: StorePageWeb(),);
                    });
                  },
                  // page: EmployeesPage(),
                  icon: kIconStore,
              ),
              SidebarXItem(
                label: cTeam,
                onTap: () {
                  setState(() {
                    _selectedWidget = EmployeesPage();
                  });
                },
                // page: EmployeesPage(),
                icon: kIconTeam,
              ),
              SidebarXItem(
                label: cSuppliers,
                onTap: () {
                  setState(() {
                    _selectedWidget = SuppliersPage();
                  });
                },
                // page: EmployeesPage(),
                icon: kIconSuppliers,
              ),
              SidebarXItem(
                label: cMessagingTab,
                onTap: () {
                  setState(() {
                    _selectedWidget = MessageHistoryPage(showBackButton: false,);
                  });
                },
                // page: AttendancePage(),
                icon: kIconMessage,
              ),
              SidebarXItem(
                label: cTransactions,
                onTap: () {
                  setState(() {
                    _selectedWidget = TransactionsController(showBackButton: false,);
                  });
                },
                // page: AttendancePage(),
                icon: kIconTransaction,
              ),
              SidebarXItem(
                label: cAnalytics,
                // page: ReportsPage(),
                icon: kIconAnalytics,
                onTap: () {
                  setState(() {
                    _selectedWidget = AnalyticsNewWeb() ;
                  });
                },
              ),

            ],
          ),
          Expanded(
            child: _selectedWidget, // Display the selected widget
          ),
        ],
      ),
    );
  }
}
