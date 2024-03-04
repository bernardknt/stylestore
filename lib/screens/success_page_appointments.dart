import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stylestore/Utilities/constants/color_constants.dart';
import 'package:stylestore/Utilities/constants/font_constants.dart';
import 'package:stylestore/controllers/home_page_controllers/home_controller_mobile.dart';
import 'package:stylestore/controllers/responsive/responsive_page.dart';
import 'package:stylestore/model/common_functions.dart';
import 'package:stylestore/model/styleapp_data.dart';
import 'package:stylestore/screens/tasks_pages/add_tasks.dart';
import 'package:stylestore/screens/tasks_pages/tasks_widget.dart';
import 'package:stylestore/utilities/basket_items.dart';

import '../utilities/constants/user_constants.dart';
import 'Messages/message.dart';


class SuccessPage extends StatefulWidget {
  static String id = 'success_page';

  @override
  _SuccessPageState createState() => _SuccessPageState();
}

class _SuccessPageState extends State<SuccessPage> {


  @override
  late Timer _timer;
  var basketProducts = [];
  double totalPrice = 0;
  var token = "";
  var orderId = "";
  var basketToPost = [];
  var uploadStatus = 0;


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
    token = prefs.getString(kToken)??"";
    orderId = prefs.getString(kOrderId)!;

    var providerData = Provider.of<StyleProvider>(context, listen: false);
    try {
    await appointments.doc(prefs.getString(kOrderId))
        .set({
      'active': true,
      'client': providerData.customerName,
      'clientPhone': providerData.customerNumber,
      'clientLocation': providerData.customerLocation,// John Doe
      'instructions': providerData.instructionsInfo,
      'sender_id': prefs.getString(kStoreIdConstant),
      'location':  providerData.beauticianLocation,
      'beauticianName':  providerData.beauticianName,
      'beauticianNumber': providerData.beauticianPhoneNumber,
      'beauticianEmail': prefs.getString(kEmailConstant),
      'beautician_id':  prefs.getString(kStoreIdConstant),
      'appointmentDate':  providerData.invoicedDate,
      'appointmentTime':  providerData.appointmentTime,
      'appointmentId': prefs.getString(kOrderId),
      'customerId': providerData.customerId,
      'paymentMethod': providerData.paymentMethod,
      'paymentStatus': 'offline',
      'payment_date': providerData.paymentDate,
      'bookingFee' :  0,
      'image' :providerData.beauticianImageUrl,
      'rating':0,
      'rating_comment': '',
      'hasRated': false,
      'status': providerData.paymentStatus,
      'totalFee': totalPrice,
      'paidAmount': providerData.paidPrice,
      'order_time': DateTime.now(),
      'token': token,
      'phoneNumber': providerData.customerNumber,
      'items':basketToPost,
      'currency': "Ugx",
      'notes': providerData.transactionNote,
      'sms':CommonFunctions().smsValue(providerData.beauticianName, CommonFunctions().formatPhoneNumber(prefs.getString(kPhoneNumberConstant)!, prefs.getString(kCountryCode)?? "+256"), providerData.customerName,  prefs.getString(kCountryCode)?? "+256"),

    }).then((value) {
      if(providerData.selectedStockItems.length != 0) {
        var itemsWhoStockChanged = [];
        var selectedStocks = providerData.selectedStockItems;
        for(var i = 0; i < selectedStocks.length; i ++){
          print("${selectedStocks[i].name}: ${selectedStocks[i].restock}");
          itemsWhoStockChanged.add( {
            'product' : selectedStocks[i].name,
            'description':selectedStocks[i].description,
            'quantity': selectedStocks[i].restock,
            'totalPrice':selectedStocks[i].price
          }
          );
        }

        CommonFunctions().uploadReducedStockItems(selectedStocks, context, itemsWhoStockChanged, prefs.getString(kOrderId));
      } else {

      }

    } ).whenComplete(() =>
    setState((){
      uploadStatus = 1;
    })
    )
        .catchError((error) {
      print(error);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Check your Internet Connection')));

      Navigator.pop(context);

    } );
    } catch (error) {
      print(error);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('An error occurred. Please check your internet connection.')));
      setState(() {
        uploadStatus = 2; // Failed to upload
      });
      Navigator.pop(context);
    }
  }

  Widget build(BuildContext context) {



    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            uploadStatus == 0 ? Lottie.asset('images/sync.json', height: 100, width: 200, ):Lottie.asset('images/success.json', height: 200, width: 200, fit: BoxFit.cover ),
            SizedBox(height: 10,),
            Center(child: uploadStatus == 0 ?Text('Syncing everything',textAlign: TextAlign.center, style: GoogleFonts.lato(fontWeight: FontWeight.bold, fontSize: 20),):Text('SUCCESS',textAlign: TextAlign.center, style: GoogleFonts.lato(fontWeight: FontWeight.bold, fontSize: 20),)),
            SizedBox(height: 10,),
            uploadStatus == 0 ?Container(): Center(child: Text('Transaction Created',textAlign: TextAlign.center, style: GoogleFonts.lato( fontSize: 30),)),
            SizedBox(height: 20,),
            uploadStatus == 0 ?Column(
              mainAxisAlignment: MainAxisAlignment.center,


              children: [
                TextButton(onPressed: (){
                  // Navigator.pushNamed(context, ControlPageMobile.id);
                  }, child: Text("Go Back", style: kNormalTextStyle.copyWith(color: kAppPinkColor),)),
                kLargeHeightSpacing,
                kLargeHeightSpacing,
                kLargeHeightSpacing,
                kLargeHeightSpacing,
                kLargeHeightSpacing,
                kLargeHeightSpacing,
                Text("Incase this takes too long please check your internet connection",textAlign:TextAlign.center,style: kNormalTextStyle,)
              ],
            ):Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  style:ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(kAppPinkColor)),

                    onPressed:(){
                    // Navigator.pop(context);
                    // Navigator.pushNamed(context, ControlPageMobile.id);
                      Navigator.pushNamed(context, SuperResponsiveLayout.id);

                }, child: Text('Go Home',style: kNormalTextStyle.copyWith(color: kPureWhiteColor),)),
                kSmallWidthSpacing,
                kSmallWidthSpacing,
                ElevatedButton(
                    style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(kBlueDarkColor)),
                    onPressed:() async {
                      final prefs = await SharedPreferences.getInstance();
                      var countryCode = prefs.getString(kCountryCode)?? "+256";
                      var providerData = Provider.of<StyleProvider>(context, listen: false);

                      Provider.of<StyleProvider>(context, listen: false).setInvoicedPriceToPay(providerData.invoicedPriceToPay);

                      Provider.of<StyleProvider>(context, listen: false).setInvoicedValues(totalPrice, providerData.paidPrice, providerData.customerName, providerData.invoiceTransactionId, CommonFunctions().smsJustPaid(providerData.beauticianName, providerData.beauticianPhoneNumber, providerData.customerName, countryCode), providerData.customerNumber, DateTime.now(), providerData.invoicedTotalPrice - providerData.invoicedPaidPrice, "");

                      // Navigator.pop(context);
                      Navigator.pushNamed(context, SuperResponsiveLayout.id);
                      final orderText = StringBuffer();
                      basketToPost.length == 1 ? orderText.writeln('Order has ${basketToPost.length} item'):orderText.writeln('Order has ${basketToPost.length} items');
                      for (var i = 0; i < basketToPost.length; i++) {
                        final item = basketToPost[i];
                        orderText.writeln('${i + 1}. ${item['product']} (${item['description']}) x ${item['quantity'].toInt()}');
                      }
                      Provider.of<StyleProvider>(context, listen: false).setTaskToDo("No. $orderId\nOrder For ${providerData.customerName}: ${providerData.customerNumber}\n_____________________\nLocation: ${providerData.customerLocation} \n_____________________\n${orderText.toString()}\n_____________________\nNote: ${providerData.transactionNote}");
                      showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (context) {
                            return Scaffold(
                                appBar: AppBar(
                                  automaticallyImplyLeading: false,
                                  backgroundColor: kPureWhiteColor,
                                  elevation: 0,
                                ),
                                body: AddTasksWidget());
                          });
                }, child: Text('Create Task from Order', style: kNormalTextStyle.copyWith(color: kPureWhiteColor),)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
