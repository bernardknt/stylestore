
import 'package:csv/csv.dart';
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
  Map permissionsMap = {};
  List tabs = [];
  List<BottomNavigationBarItem> navigationItems =  [];


  var storeName = "";

  void defaultInitialization()async {
    final prefs = await SharedPreferences.getInstance();
    permissionsMap = await CommonFunctions().convertPermissionsJson();
    storeName = CommonFunctions().getFirstWord(prefs.getString(kBusinessNameConstant)??"");
    if (permissionsMap['takeStock']==true){
      tabs = [
        HomePage(),
        StorePageMobile(),
        TakeStockWidget(mainPage: true,)
        // AnalysisPage()
      ];
      navigationItems =  [
        BottomNavigationBarItem(
            icon: Icon(kIconHome),label: cHome,
            backgroundColor: Colors.green),

        BottomNavigationBarItem(
            icon: Icon(kIconStore),label:'$storeName $cStore',

            backgroundColor: Colors.black),
        BottomNavigationBarItem(
            icon: Icon(kIconStock),label:'Take Stock',

            backgroundColor: Colors.black),
      ];
    } else {
      tabs = [
        HomePage(),
        StorePageMobile(),

        // AnalysisPage()
      ];
      navigationItems =  [
        BottomNavigationBarItem(
            icon: Icon(kIconHome),label: cHome,
            backgroundColor: Colors.green),

        BottomNavigationBarItem(
            icon: Icon(kIconStore),label:'$storeName $cStore',

            backgroundColor: Colors.black),

      ];
    }

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
        items: navigationItems
        // Item 1
       ,
        onTap: (index){
          setState(() {
            _currentIndex = index;
          });

        },

      ),
    );
  }

}
