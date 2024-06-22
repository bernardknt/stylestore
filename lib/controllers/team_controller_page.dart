
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stylestore/Utilities/constants/font_constants.dart';
import 'package:stylestore/Utilities/constants/user_constants.dart';
import 'package:stylestore/screens/subscription_pages/annual_subscription_pages.dart';



import '../screens/MobileMoneyPages/subscription_monthly_payment.dart';
import '../screens/employee_pages/edit_employee_profile_page.dart';
import '../screens/employee_pages/employees_page.dart';
import '../screens/tasks_pages/tasks_widget.dart';
import '../screens/HomePageWidgets/stock_summary_page.dart';
import '../screens/HomePageWidgets/summary_widget.dart';
import '../screens/team_pages/employee_permissions_page.dart';
import '../utilities/constants/color_constants.dart';






class TeamControllerPage extends StatefulWidget {
  static String id = 'team_controller';
  @override
  _TeamControllerPageState createState() => _TeamControllerPageState();
}

class _TeamControllerPageState extends State<TeamControllerPage> {

  @override
  Widget build(BuildContext context) {
    return
      DefaultTabController(
        length: 3,
        child:
        Scaffold(
            backgroundColor: kPureWhiteColor,

            appBar: AppBar(
              // automaticallyImplyLeading: true,
              toolbarHeight: 30,
              backgroundColor: kCustomColorPurple.withOpacity(1),
              foregroundColor: kBlack,
              elevation: 0,
              //title: Center(child: Text("Stock Page", style: TextStyle(color: kBiegeThemeColor, fontSize: 13, fontWeight: FontWeight.bold),),),
              bottom: TabBar(
                indicatorPadding: EdgeInsets.all(7),
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [kPureWhiteColor, kPureWhiteColor]),
                  borderRadius: BorderRadius.circular(10),
                  // color: Colors.redAccent
                ),

                labelColor: kBlueDarkColorOld,
                unselectedLabelColor: kBlueDarkColorOld,
                tabs: [
                  Tab(child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children:[

                        Text('Profile', style: kNormalTextStyle.copyWith(color: kBlack))]
                  ),),

                  Tab(child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Permissions', style: kNormalTextStyle.copyWith(color: kBlack)),
                  ),),
                  Tab(child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Checklist', style: kNormalTextStyle.copyWith(color: kBlack),),
                  ),),



                ],
              ),
            ),
            body: TabBarView(
              children: [
                EditProfilePage(),
                EmployeePermissionsPage(),
                Container(color: kPlainBackground,child: Center(child: Text("Checklist"),),),
              ],
            )
        ),
      );
  }
}
