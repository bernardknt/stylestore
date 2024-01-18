import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:iconsax/iconsax.dart';
import 'package:line_icons/line_icons.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';


import 'package:intl/intl.dart';
import 'package:slider_button/slider_button.dart';


import '../screens/order_details_page.dart';
import '../widgets/orderedContentsWidget.dart';
import 'constants/color_constants.dart';
import 'constants/font_constants.dart';
import 'constants/user_constants.dart';

showDialogFunc(context, orderStatus, location, clientName, orderNumber, orderSelected, note, time){
  String formattedDate = DateFormat('EEE, dd, MMMM').format(time);


  CollectionReference customerOrderStatus = FirebaseFirestore.instance.collection('orders');
  Future<void> changeOrderStatus()async {
    final prefs = await SharedPreferences.getInstance();
    // Call the user's CollectionReference to add a new user
    return customerOrderStatus.doc(orderNumber).update({
      "status": "preparing",
      "prepareStartTime": DateTime.now(),
      "chef": prefs.getString(kBusinessNameConstant)

    })
        .then((value) => print("Status Changed"))
        .catchError((error) => print("Failed to change status: $error"));
  }

  Timer _timer;
  return showDialog(context: context,barrierLabel: 'Items', builder: (context){
    return
      Stack(
      children: [
        ListView.builder(
          shrinkWrap: true,
          itemCount: orderSelected.length,
          itemBuilder: (context, index){
              return OrderedContentsWidget(productDescription: orderSelected[index]['description'], productName: orderSelected[index]['product'],quantity: orderSelected[index]['quantity'], orderIndex: index + 1, note: note,);
          }),
        Positioned(
          left: 30,
            right: 20,
            bottom: 20,
            child:
            SliderButton(

              action: () {
                changeOrderStatus();
                Navigator.pop(context);
                print(time);
                Navigator.pushNamed(context, AppointmentSummary.id);
              },
              ///Put label over here
              label: Text(
                "Slide to Mark Task as Done",
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                    fontSize: 17),
              ),
              icon: Icon(Iconsax.tick_circle,color: kPureWhiteColor,size: 30,),

              //Put BoxShadow here
              boxShadow: BoxShadow(
                color: Colors.black,
                blurRadius: 4,
              ),


              width: 250,
              radius: 100,
              buttonColor: kAppPinkColor,
              backgroundColor: kBiegeThemeColor,
              highlightedColor: Colors.black,
              baseColor: kAppPinkColor,
            ),
        ),
        Positioned(
          top: 10,
          right: 10,
          child: Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(10), ),color: Colors.orange ),
            //color: Colors.red,
            child: Column(
              children: [
                Text(formattedDate, style: GoogleFonts.lato(fontWeight: FontWeight.bold, color: Colors.white),),
              ],
            ),
          ),
        ),
      ]
    );
  }
      );
}
