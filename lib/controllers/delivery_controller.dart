
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';

import '../screens/completed_page.dart';
import '../screens/delivery_page.dart';
import '../utilities/constants/color_constants.dart';
import '../utilities/constants/user_constants.dart';





class DeliveryController extends StatefulWidget {
  static String id = 'delivery_controller';
  @override
  _DeliveryControllerState createState() => _DeliveryControllerState();
}

class _DeliveryControllerState extends State<DeliveryController> {

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child:
      Scaffold(

          appBar: AppBar(
            automaticallyImplyLeading: false,
            toolbarHeight: 80,
            backgroundColor: kBlueDarkColor,
            title: Center(child: Text("Production & Delivery Process", style: TextStyle(color: kBiegeThemeColor, fontSize: 13, fontWeight: FontWeight.bold),),),
            bottom: TabBar(
              indicator: BoxDecoration(
                  gradient: LinearGradient(
                      colors: [Colors.orange, Colors.green]),
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.redAccent),

              //indicatorColor: kPinkDarkThemeColor,
              labelColor: Colors.white,
              unselectedLabelColor: kBiegeThemeColor,
              tabs: [
                Tab(child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children:[
                      Icon(LineIcons.cut, size: 20,),
                      SizedBox(width: 4,),
                      Text('Progress')]
                ),),
                // ),),
                Tab(child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children:[
                      Icon(LineIcons.motorcycle, size: 16,),
                      SizedBox(width: 4,),
                      Text('Delivery')]
                ),),
                Tab(child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children:[
                      Icon(LineIcons.checkCircle, size: 16,),
                      SizedBox(width: 4,),
                      Text('Completed')]
                ),),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              Container(),
              Container(),
              Container(color: Colors.amber,)
              // VisaPage(),
            ],
          )
      ),
    );
  }
}
