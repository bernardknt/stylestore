import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../screens/service_edit_page.dart';
import '../utilities/paymentButtons.dart';



showItemFunc(context, String itemName,int quantity, String description ){
  //, orderStatus, location, clientName, orderNumber, orderSelected, note, time
  //String formattedDate = DateFormat('EEE, dd, MMMM– kk:mm aaa').format(time);


  CollectionReference customerOrderStatus = FirebaseFirestore.instance.collection('orders');
  Future<void> changeOrderStatus() {
    // Call the user's CollectionReference to add a new user
    return customerOrderStatus.doc('123213').update({
      "status": "preparing",
      "prepareStartTime": DateTime.now(),
      "chef":"Salim"

    })
        .then((value) => print("Status Changed"))
        .catchError((error) => print("Failed to change status: $error"));
  }

  Timer _timer;
  return showDialog(context: context,barrierLabel: 'Items', builder: (context){
    return
      Center(
        child: Container(

          color: Colors.white,
          padding: EdgeInsets.all(10),
          child: Column(
            children: [
              Text(itemName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
              SizedBox(height: 10,),
              Text(description, style: TextStyle(fontWeight: FontWeight.normal, fontSize: 16),),
              SizedBox(height: 10,),
              paymentButtons(continueFunction: (){Navigator.pop(context);}, continueBuyingText: 'Cancel', checkOutText: 'Update', buyFunction: (){
                Navigator.pushNamed(context, ServicesEditPage.id);
              }),
            ],
          ),
        ),
      );
  }
  );
}
