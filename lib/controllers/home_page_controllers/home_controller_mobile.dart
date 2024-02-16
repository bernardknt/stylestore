
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stylestore/Utilities/constants/user_constants.dart';
import 'package:stylestore/screens/home_pages/home_page.dart';
import 'package:stylestore/utilities/constants/color_constants.dart';
import '../../screens/analytics/analysis_page.dart';
import '../../screens/products_pages/store_page.dart';



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
    MerchantStorePage(),
    // AnalysisPage()
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
              icon: Icon(Icons.home_max),label:'Dashboard',
              backgroundColor: Colors.green),

          BottomNavigationBarItem(
              icon: Icon(Icons.storefront),label:'$storeName Store',
              // icon: Icon(LineIcons.warehouse),label:'Store',
              backgroundColor: Colors.black),
          // BottomNavigationBarItem(
          //     icon: Icon(Icons.trending_up_outlined),label:'Analytics',
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
