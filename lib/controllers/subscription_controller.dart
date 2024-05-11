
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:iconsax/iconsax.dart';
import 'package:stylestore/Utilities/constants/font_constants.dart';
import 'package:stylestore/screens/subscription_pages/annual_subscription_pages.dart';



import '../screens/MobileMoneyPages/subscription_monthly_payment.dart';
import '../screens/tasks_pages/tasks_widget.dart';
import '../screens/HomePageWidgets/stock_summary_page.dart';
import '../screens/HomePageWidgets/summary_widget.dart';
import '../utilities/constants/color_constants.dart';






class SubscriptionController extends StatefulWidget {
  static String id = 'subscription_controller';
  @override
  _SubscriptionControllerState createState() => _SubscriptionControllerState();
}

class _SubscriptionControllerState extends State<SubscriptionController> {

  @override
  Widget build(BuildContext context) {
    return
      DefaultTabController(
        length: 2,
        child:
        Scaffold(
            backgroundColor: kPureWhiteColor,

            appBar: AppBar(
              automaticallyImplyLeading: false,
              toolbarHeight: 5,
              backgroundColor: kCustomColorPurple.withOpacity(1),
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

                        Text('Monthly')]
                  ),),
                  Tab(child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Annual'),
                  ),),


                ],
              ),
            ),
            body: TabBarView(
              children: [
                PremiumMonthlySubscriptionsPage(),
                PremiumAnnualSubscriptionsPage(),



                // VisaPage(),
              ],
            )
        ),
      );
  }
}
