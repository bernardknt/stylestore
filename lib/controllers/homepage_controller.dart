


import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter_zoom_drawer/config.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:stylestore/screens/home_page.dart';

import '../screens/menu_page.dart';

class HomePageController extends StatefulWidget {
  static String id = 'MenuPageController';

  @override
  State<HomePageController> createState() => _HomePageControllerState();
}

class _HomePageControllerState extends State<HomePageController> {
  @override
  Widget build(BuildContext context) =>  !Platform.isIOS && !Platform.isAndroid ? ZoomDrawer(
      style: DrawerStyle
          .defaultStyle
      //.defaultStyle
      ,
      menuScreen: MenuPage(),
      mainScreen: HomePage()): ZoomDrawer(
    style: DrawerStyle
      .style4
        //.defaultStyle
      ,
      menuScreen: MenuPage(),
      mainScreen: HomePage());
}
