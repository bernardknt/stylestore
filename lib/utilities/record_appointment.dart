import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:stylestore/utilities/constants/user_constants.dart';
import 'package:stylestore/widgets/select_services.dart';
import 'package:stylestore/widgets/transaction_button2.dart';
import '../model/styleapp_data.dart';
import '../screens/payment_pages/pos_mobile.dart';
import '../screens/store_pages/store_page_mobile.dart';
import '../widgets/transaction_buttons.dart';
import 'constants/color_constants.dart';
import 'constants/font_constants.dart';
import 'constants/icon_constants.dart';

class RecordAppointment extends StatefulWidget {
  const RecordAppointment({
    Key? key,
  }) : super(key: key);

  @override
  State<RecordAppointment> createState() => _RecordAppointmentState();
}


class _RecordAppointmentState extends State<RecordAppointment> {

  // THIS IS SERVICES VARIABLES
  var mainServices = [];
  var otherServices = [];
  var options = [];
  var basePrice = [];
  var optionsState = [];
  var fruitInfo = [];
  var extraInfo = [];

  @override
  Future<dynamic> getIngredients() async {
    final prefs = await SharedPreferences.getInstance(); 
    mainServices = [];
    options = [];
    basePrice = [];
    optionsState = [];
    fruitInfo = [];
    extraInfo = [];

    final availableIngredients = await FirebaseFirestore.instance
        .collection('services').where('storeId', isEqualTo: prefs.getString(kStoreIdConstant))
    //.orderBy('name',descending: false)
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        if(doc['active']== true) {
          if (doc['category'] == 'main') {
            mainServices.add(doc['name']);
            options.add(doc['options']);
            basePrice.add(doc['basePrice']);
            optionsState.add(doc['hasOptions']);
          } else {
            // if (doc['quantity'] >= 1){
            //
            //   extraInfo.add(doc['info']);
            // }
          }
        }
      });




    });
    Provider.of<StyleProvider>(context, listen: false).setServicesOptions(mainServices, options, optionsState, basePrice);
    return availableIngredients ;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getIngredients();


  }


  Widget build(BuildContext context) {
    return Container(color: kBackgroundGreyColor,
      child: Container(color: kBlueDarkColorOld,
        child: Column(
          // crossAxisAlignment: CrossAxisAlignment.center,
          // mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text('New Offline Transaction', style: kHeading2TextStyleBold.copyWith(color: kPureWhiteColor),),),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TransactionButtons(displayWidget: SelectServicePage(bookingButtonName: 'Book',), labelText: 'Make Appointment', icon: kIconCalendar,),
                    SizedBox(width: 10),
                    TransactionButtons(displayWidget: Container(
                        color: kBlueDarkColorOld,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,


                          children: [
                            Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children:[

                                  TransactionButtons(labelText: 'Service', displayWidget:SelectServicePage(bookingButtonName: 'Record',), icon: kIconScissor, height: 50,),
                                  kSmallWidthSpacing,
                                  TransactionButtons2(labelText: 'Products', displayWidget: POS(), icon: kIconProducts, height: 50,)

                                ] ),
                          ],
                        )), labelText: 'Record Sale', icon: kIconCustomer,),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
      // InputPage()
    );
  }
}

