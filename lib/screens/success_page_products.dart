import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stylestore/controllers/home_page_controllers/home_controller_mobile.dart';
import 'package:stylestore/model/styleapp_data.dart';
import 'package:stylestore/utilities/basket_items.dart';

import '../utilities/constants/user_constants.dart';


class SuccessPageProducts extends StatefulWidget {
  static String id = 'success_page_products';

  @override
  _SuccessPageProductsState createState() => _SuccessPageProductsState();
}

class _SuccessPageProductsState extends State<SuccessPageProducts> {


  @override
  late Timer _timer;
  var basketProducts = [];
  double totalPrice = 0;
  var basketToPost = [];

  @override

  void initState() {
    // TODO: implement initState
    super.initState();
    basketProducts = Provider.of<StyleProvider>(context, listen: false).basketItems;
    totalPrice = Provider.of<StyleProvider>(context, listen: false).totalPrice;
    for(var i = 0; i < Provider.of<StyleProvider>(context, listen: false).basketItems.length; i ++){
      basketToPost.add( {
        'product' : (Provider.of<StyleProvider>(context, listen: false).basketItems[i].name),
        'description':(Provider.of<StyleProvider>(context, listen: false).basketItems[i].details),
        'quantity': (Provider.of<StyleProvider>(context, listen: false).basketItems[i].quantity),
        'totalPrice':(Provider.of<StyleProvider>(context, listen: false).basketItems[i].amount)
      }
      );
    }






    print(Provider.of<StyleProvider>(context, listen: false).totalPrice);


    animationTimer();
  }
  final _random = new Random();
  CollectionReference appointments = FirebaseFirestore.instance.collection('appointments');
  animationTimer() {
    _timer = Timer(const Duration(milliseconds: 2000), () {
      Provider.of<StyleProvider>(context, listen: false).clearLists();
      upLoadOrder();


    });
  }

  Future<void> upLoadOrder ( )async {



    final prefs =  await SharedPreferences.getInstance();
    List<BasketItem> products = Provider.of<StyleProvider>(context, listen: false).basketItems;

    return appointments.doc(prefs.getString(kOrderId))
        .set({
      'active': true,
      'client': Provider.of<StyleProvider>(context, listen: false).customerName,
      'clientPhone': Provider.of<StyleProvider>(context, listen: false).customerNumber, // John Doe
      'clientLocation': Provider.of<StyleProvider>(context, listen: false).customerLocation,
      'instructions': '',
      'sender_id': prefs.getString(kStoreIdConstant),
      'location':  Provider.of<StyleProvider>(context, listen: false).beauticianLocation,
      'beauticianName':  Provider.of<StyleProvider>(context, listen: false).beauticianName,
      'beauticianNumber': Provider.of<StyleProvider>(context, listen: false).beauticianPhoneNumber,
      'beauticianEmail': prefs.getString(kEmailConstant),
      'beautician_id':  prefs.getString(kStoreIdConstant),
      'appointmentDate':  Provider.of<StyleProvider>(context, listen: false).appointmentDate,
      'appointmentTime':  Provider.of<StyleProvider>(context, listen: false).appointmentTime,
      'appointmentId': prefs.getString(kOrderId),
      'paymentMethod': 'cash',
      'paymentStatus': 'offline',
      'bookingFee' :  0,
      'image' :Provider.of<StyleProvider>(context, listen: false).beauticianImageUrl,
      'rating':0,
      'rating_comment': '',
      'hasRated': false,
      'status': Provider.of<StyleProvider>(context, listen: false).paymentStatus,
      'totalFee': totalPrice,
      'order_time': DateTime.now(),
      'payment_date': DateTime.now(),
      'token': 'AcertaintokenNumberwascreated',
      'phoneNumber': Provider.of<StyleProvider>(context, listen: false).customerNumber,
      'items':basketToPost
    }).then((value) {
      Navigator.pop(context);
      // Navigator.pushNamed(context, ControlPageMobile.id);

    } ).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Check your Internet Connection')));

      Navigator.pop(context);

    } );
  }

  Widget build(BuildContext context) {


    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Lottie.asset('images/success.json', height: 300, width: 300, fit: BoxFit.cover ),
            SizedBox(height: 10,),
            Center(child: Text('SUCCESS',textAlign: TextAlign.center, style: GoogleFonts.lato(fontWeight: FontWeight.bold, fontSize: 20),)),
            SizedBox(height: 10,),
            Center(child: Text('Transaction Created',textAlign: TextAlign.center, style: GoogleFonts.lato( fontSize: 30),)),

          ],
        ),
      ),
    );
  }
}
