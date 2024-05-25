import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stylestore/controllers/home_page_controllers/home_controller_mobile.dart';
import 'package:stylestore/model/beautician_data.dart';
import 'package:stylestore/model/common_functions.dart';
import 'package:stylestore/model/styleapp_data.dart';
import 'package:stylestore/utilities/basket_items.dart';

import '../utilities/constants/user_constants.dart';


class SuccessPageHiFive extends StatefulWidget {
  static String id = 'success_page_hi_five';

  @override
  _SuccessPageHiFiveState createState() => _SuccessPageHiFiveState();
}

class _SuccessPageHiFiveState extends State<SuccessPageHiFive> {


  @override
  late Timer _timer;
  var basketProducts = [];
  var totalPrice = 0;
  var basketToPost = [];

  @override

  void initState() {
    // TODO: implement initState
    super.initState();
    animationTimer();
  }
  final _random = new Random();
  CollectionReference appointments = FirebaseFirestore.instance.collection('appointments');
  animationTimer() {
    _timer = Timer(const Duration(milliseconds: 3000), () {
      CommonFunctions().showNotification(Provider.of<BeauticianData>(context, listen: false).bannerMessage, "${Provider.of<BeauticianData>(context, listen: false).bannerMessage} for ${Provider.of<StyleProvider>(context, listen:false).invoicedCustomer}");
      Navigator.pop(context);

    });
  }



  Widget build(BuildContext context) {


    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            kIsWeb?Image.asset("images/success.png", height: 100,):Lottie.asset(Provider.of<BeauticianData>(context, listen: false).lottieImage, height: 300, width: 300, fit: BoxFit.cover ),
            SizedBox(height: 10,),
            Center(child: Text('SUCCESS',textAlign: TextAlign.center, style: GoogleFonts.lato(fontWeight: FontWeight.bold, fontSize: 20),)),
            SizedBox(height: 10,),
            Center(child: Text(Provider.of<BeauticianData>(context, listen: false).bannerMessage,textAlign: TextAlign.center, style: GoogleFonts.lato( fontSize: 30),)),

          ],
        ),
      ),
    );
  }
}
