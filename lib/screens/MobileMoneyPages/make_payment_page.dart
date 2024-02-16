import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../../Utilities/constants/color_constants.dart';
import '../../Utilities/constants/font_constants.dart';
import '../../controllers/home_page_controllers/home_controller_mobile.dart';
import '../../controllers/responsive/responsive_page.dart';
import '../../model/styleapp_data.dart';
import 'mm_payment_button_widget.dart';



class MakePaymentPage extends StatefulWidget {
  static String id = 'make_payment_page';

  @override
  _MakePaymentPageState createState() => _MakePaymentPageState();
}

class _MakePaymentPageState extends State<MakePaymentPage> {




  @override

  void initState() {
    // TODO: implement initState

    super.initState();

  }


  Widget build(BuildContext context) {
    // var points = Provider.of<BlenditData>(context, listen: false).rewardPoints ;

    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(20),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Lottie.asset('images/mailtime.json', height: 150, width: 150, fit: BoxFit.cover ),
              kSmallHeightSpacing,
              Center(child: Text(Provider.of<StyleProvider>(context).pendingPaymentStatement,textAlign: TextAlign.center, style: kNormalTextStyle)),
              kSmallHeightSpacing,
              Lottie.asset('images/loading.json', height: 50, width: 150,),
              kLargeHeightSpacing,
              kLargeHeightSpacing,
              kLargeHeightSpacing,
              MobileMoneyPaymentButton(firstButtonFunction: (){Navigator.pushNamed(context, SuperResponsiveLayout.id); }, firstButtonText: 'Go Home',buttonTextColor: kPureWhiteColor, lineIconFirstButton: Icons.check_circle_outline,)

              // SizedBox(height: 10,),
              // Center(child: Text('You have Earned',textAlign: TextAlign.center, style: GoogleFonts.lato( fontSize: 30),)),
              //SizedBox(height: 10,),
              // Center(child: Text('${points.toString()} points',textAlign: TextAlign.center, style: GoogleFonts.lato(fontWeight: FontWeight.bold, fontSize: 30, color: Colors.green),)),
            ],
          ),
        ),
      ),
    );
  }
}
