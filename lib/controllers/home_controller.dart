
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:line_icons/line_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stylestore/Utilities/constants/user_constants.dart';
import 'package:stylestore/controllers/homepage_controller.dart';
import 'package:stylestore/controllers/services_controller.dart';
import 'package:stylestore/controllers/transactions_controller.dart';
import 'package:stylestore/model/responsive/responsive_layout.dart';
import 'package:stylestore/screens/analytics/analysis_page.dart';
import 'package:stylestore/screens/products_pages/store_page.dart';
import 'package:stylestore/utilities/constants/color_constants.dart';

import '../screens/analytics/intro_to_analysis.dart';
import '../screens/transactions_online_page.dart';
import '../screens/home_page.dart';
import 'delivery_controller.dart';



class ControlPage extends StatefulWidget {
  ControlPage();
  static String id = 'home_control_page';

  @override
  _ControlPageState createState() => _ControlPageState();

}

class _ControlPageState extends State<ControlPage> {


  int _currentIndex = 0;
  double buttonHeight = 40.0;
  int amount = 0;
  final tabs = [
    ResponsiveLayout(mobileBody: HomePageController(), desktopBody: Container(color: Colors.teal,)),
    // HomePageController(),
    MerchantStorePage(),
    // AnalysisIntroPage(),
    AnalysisPage()
    // CompletedPage(),
    // ServicesController(),
    // TransactionsController(),
    // Container(color: Colors.tealAccent)

  ];
  String getFirstWord(String sentence) {
    if (sentence.isNotEmpty) {
      List<String> words = sentence.split(' ');
      return words[0];
    }
    return "";
  }

  var storeName = "";

  void defaultInitialization()async {
    final prefs = await SharedPreferences.getInstance();
    storeName = getFirstWord(prefs.getString(kBusinessNameConstant)??"");
    setState(() {

    });
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    defaultInitialization();

  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body: tabs[_currentIndex],
      bottomNavigationBar:
      BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: kAppPinkColor,
        iconSize: 18,
        items:
        // Item 1
        [
          BottomNavigationBarItem(
              icon: Icon(Iconsax.menu_board),label:'Dashboard',
              backgroundColor: Colors.green),
          // Item 2
          // BottomNavigationBarItem(
          //     icon: Icon(CupertinoIcons.heart_fill , size: 18,),label:'Preparing',
          //     backgroundColor: Colors.purple),
          // Item 3

          BottomNavigationBarItem(
              icon: Icon(Iconsax.brush_1),label:'$storeName Store',
              // icon: Icon(LineIcons.warehouse),label:'Store',
              backgroundColor: Colors.black),
          BottomNavigationBarItem(
              icon: Icon(Iconsax.trend_up),label:'Analytics',
              backgroundColor: Colors.black),
          // BottomNavigationBarItem(
          //     //icon: Icon(LineIcons.greaterThanEqualTo),label:'More',
          //     icon: Icon(Iconsax.more),label:'More',
          //     backgroundColor: Colors.black),
        ],
        onTap: (index){
          setState(() {
            _currentIndex = index;
          });

        },

      ),
    );
  }

}
