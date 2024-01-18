
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:stylestore/Utilities/constants/font_constants.dart';



import '../screens/tasks_pages/tasks_widget.dart';
import '../screens/HomePageWidgets/stock_summary_page.dart';
import '../screens/HomePageWidgets/summary_widget.dart';
import '../utilities/constants/color_constants.dart';






class TasksController extends StatefulWidget {
  static String id = 'tasks_controller';
  @override
  _TasksControllerState createState() => _TasksControllerState();
}

class _TasksControllerState extends State<TasksController> {

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
            // shape: ShapeBorder.lerp(, b, t),
            elevation: 0,
            //title: Center(child: Text("Stock Page", style: TextStyle(color: kBiegeThemeColor, fontSize: 13, fontWeight: FontWeight.bold),),),
            bottom: TabBar(
              indicatorPadding: EdgeInsets.all(7),
              indicator: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [kPureWhiteColor, kPureWhiteColor]),
                  borderRadius: BorderRadius.circular(10),
                  // color: Colors.redAccent
              ),

              //indicatorColor: kPinkDarkThemeColor,
              labelColor: kBlueDarkColorOld,
              unselectedLabelColor: kBlueDarkColorOld,
              tabs: [

                Tab(child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children:[

                      Text('Business Summary')]
                ),),
                Tab(child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('My Tasks'),
                ),),


              ],
            ),
          ),
          body: TabBarView(
            children: [
              // TransactionsOnlinePage(),
              // SummaryWidget(),
              SummaryPage(),
             // Container(
             //   child: Center(child: Column(
             //     mainAxisAlignment: MainAxisAlignment.center,
             //     children: [
             //       Icon(Iconsax.designtools5, color: kAppPinkColor,),
             //       Text("Different Tasks will appear here", style: kNormalTextStyle,),
             //     ],
             //   )),
             // )
             //  StockSummaryPage(),
              TasksWidget(),



              // VisaPage(),
            ],
          )
      ),
    );
  }
}
