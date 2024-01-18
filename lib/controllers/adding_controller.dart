
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../screens/add_service.dart';
import '../screens/addProduct.dart';
import '../utilities/constants/color_constants.dart';
import '../utilities/constants/user_constants.dart';




class AddItemsController extends StatefulWidget {
  static String id = 'adding_controller';
  @override
  _AddItemsControllerState createState() => _AddItemsControllerState();
}

class _AddItemsControllerState extends State<AddItemsController> {

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child:
      Scaffold(

          appBar: AppBar(
            // automaticallyImplyLeading: false,
            toolbarHeight: 80,
            backgroundColor: kPureWhiteColor,
            title: Center(child: Text("Inputing Items", style: TextStyle(color: kBiegeThemeColor, fontSize: 13, fontWeight: FontWeight.bold),),),
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
                      Icon(LineIcons.carrot, size: 20,),
                      SizedBox(width: 4,),
                      Text('Add Ingredient')]
                ),),
                // ),),
                Tab(child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children:[
                      Icon(LineIcons.gifts, size: 16,),
                      SizedBox(width: 4,),
                      Text('Add Product')]
                ),),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              AddServicePage(),
              InputProductPage(),
              // VisaPage(),
            ],
          )
      ),
    );
  }
}
