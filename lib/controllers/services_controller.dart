
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:stylestore/screens/store_pages/store_page.dart';
import '../screens/services_page.dart';
import '../utilities/constants/color_constants.dart';
import '../utilities/constants/user_constants.dart';





class ServicesController extends StatefulWidget {
  static String id = 'stock_controller';
  @override
  _ServicesControllerState createState() => _ServicesControllerState();
}

class _ServicesControllerState extends State<ServicesController> {

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child:
      Scaffold(

          appBar: AppBar(
            automaticallyImplyLeading: false,
            toolbarHeight: 30,
            backgroundColor: kBackgroundGreyColor,
            //title: Center(child: Text("Stock Page", style: TextStyle(color: kBiegeThemeColor, fontSize: 13, fontWeight: FontWeight.bold),),),
            bottom: TabBar(
              indicator: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [kAppPinkColor, kBackgroundGreyColor]),
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.redAccent),

              //indicatorColor: kPinkDarkThemeColor,
              labelColor: kBlueDarkColorOld,
              unselectedLabelColor: kBlueDarkColorOld,
              tabs: [
                Tab(child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children:[
                      Icon(LineIcons.gifts, size: 16,),
                      SizedBox(width: 4,),
                      Text('Products')]
                ),),
                Tab(child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children:[
                      Icon(LineIcons.scissorsHandAlt, size: 20,),
                      SizedBox(width: 4,),
                      Text('Services')]
                ),),
                // ),),

              ],
            ),
          ),
          body: TabBarView(
            children: [
              StorePageMobile(),
              ServicesPage(),


              // VisaPage(),
            ],
          )
      ),
    );
  }
}
