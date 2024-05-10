
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stylestore/Utilities/constants/user_constants.dart';
import 'package:stylestore/model/common_functions.dart';
import 'package:stylestore/screens/home_pages/home_page_mobile.dart';
import 'package:stylestore/utilities/constants/color_constants.dart';
import 'package:stylestore/utilities/constants/icon_constants.dart';
import 'package:stylestore/utilities/constants/word_constants.dart';
import '../../Utilities/constants/font_constants.dart';
import '../../screens/analytics/analysis_page.dart';
import '../../screens/products_pages/stock_history.dart';
import '../../screens/store_pages/store_page_mobile.dart';
import '../../screens/store_pages/take_stock_page.dart';



class ControlPageMobile extends StatefulWidget {
  ControlPageMobile();
  static String id = 'home_control_page_mobile';

  @override
  _ControlPageMobileState createState() => _ControlPageMobileState();

}

class _ControlPageMobileState extends State<ControlPageMobile> {


  int _currentIndex = 0;
  double buttonHeight = 40.0;
  int amount = 0;
  final tabs = [
    // SuperResponsiveLayout(mobileBody: HomePageController(), desktopBody: ControlPageWeb(),),
    HomePage(),
    StorePageMobile(),
   TakeStockWidget(mainPage: true,)
    // AnalysisPage()
  ];


  var storeName = "";

  void defaultInitialization()async {
    final prefs = await SharedPreferences.getInstance();
    storeName = CommonFunctions().getFirstWord(prefs.getString(kBusinessNameConstant)??"");
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
              icon: Icon(kIconHome),label: cHome,
              backgroundColor: Colors.green),

          BottomNavigationBarItem(
              icon: Icon(kIconStore),label:'$storeName $cStore',

              backgroundColor: Colors.black),
          BottomNavigationBarItem(
              icon: Icon(kIconStock),label:'Take Stock',

              backgroundColor: Colors.black),


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
