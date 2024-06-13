

// THIS IS THE SERVICES HOME PAGE
import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import 'package:intl/intl.dart';
import 'package:stylestore/screens/add_service.dart';
import 'package:stylestore/screens/calendar_pages/calendar_page.dart';
import 'package:stylestore/screens/success_page_appointments.dart';
import 'package:stylestore/widgets/rounded_buttons.dart';
import 'package:stylestore/screens/customer_pages/search_customer.dart';
import 'package:stylestore/widgets/services_provided.dart';

import '../Utilities/constants/color_constants.dart';
import '../model/styleapp_data.dart';
import '../screens/products_pages/products_upload.dart';
import '../utilities/basket_items.dart';
import '../utilities/constants/font_constants.dart';
import '../utilities/constants/icon_constants.dart';

class SelectServicePage extends StatelessWidget {

  SelectServicePage({ required this.bookingButtonName});
  final String bookingButtonName;

  var boxColours = [Colors.white, Colors.white, Colors.white, Colors.white, Colors.white, Colors.white, Colors.white, Colors.white, Colors.white, Colors.white, Colors.white, Colors.white, Colors.white, Colors.white, Colors.white, Colors.white];
  var formatter = NumberFormat('#,###,000');


  @override



  Widget build(BuildContext context) {
    var styleData = Provider.of<StyleProvider>(context, listen: false);
    var styleDataDisplay = Provider.of<StyleProvider>(context);
    List <BasketItem> itemsChosen = styleDataDisplay.basketItems ;

    // List randomFunction = (){
    //   List <BasketItem> itemsChosen = styleDataDisplay.basketItems ;
    //   var result = [];
    //   for (var i = 0; i < 10; i++){
    //     result.add(itemsChosen[i].details);
    //   }
    //   return [];
    // };

    return Container(
      color: kBackgroundCurveReveller,
      child: Container(

        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
            color: kBlueDarkColorOld,
            borderRadius: BorderRadius.only(topLeft: Radius.circular(20),topRight: Radius.circular(20))
        ),
        child:

        Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                kIconArrowLeft,
                SizedBox(width: 10,),
                Text('Choose The Service ', style:kNormalTextStyleSmall,),
                SizedBox(width: 10,),
                kIconArrowRight,
              ],
            ),
            kLargeHeightSpacing,
            Text("Main", style: kNormalTextStyleWhiteButtons,),
            kLargeHeightSpacing,
            ServicesProvidedList(services: styleData.servicesNames, boxColors: boxColours, type: 'main',),
            kLargeHeightSpacing,
            //Text("Other", style: kNormalTextStyleWhiteButtons,),
            kLargeHeightSpacing,
            // ServicesProvidedList(services: styleData.servicesNames, boxColors: boxColours, type: 'main',),
            kLargeHeightSpacing,
            RoundedButtons(buttonColor: styleDataDisplay.bookButtonColor, title: bookingButtonName,buttonWidth: 100 , onPressedFunction: (){
              if (styleDataDisplay.bookButtonColor == kAppPinkColor){
               var name = 'Customer';
               var phoneNumber = '';
               showModalBottomSheet(
                   isScrollControlled: true,
                   context: context,
                   builder: (context) {
                     return CustomerSearchPage();
                   });
                // CoolAlert.show(
                //
                //     lottieAsset: 'images/details.json',
                //     context: context,
                //     type: CoolAlertType.success,
                //     widget: SingleChildScrollView(
                //
                //       child:
                //       Container(
                //         child: Column(
                //           children: [
                //             TextField(
                //               onChanged: (customerName){
                //                 name = customerName;
                //                 // instructions = customerName;
                //                 // setState(() {
                //                 // });
                //               },
                //               decoration: InputDecoration(
                //                   // border: InputBorder.none,
                //                 labelText: 'Name',
                //                   labelStyle: kNormalTextStyleExtraSmall,
                //                   hintText:  'Charles Mukula',
                //                   hintStyle: kNormalTextStyle
                //               ) ,
                //             ),
                //             kSmallHeightSpacing,
                //             TextField(
                //               keyboardType: TextInputType.number,
                //
                //               onChanged: (customerNumber){
                //                phoneNumber = customerNumber;
                //
                //               },
                //               decoration: InputDecoration(
                //
                //                 // border: InputBorder.none,
                //                   labelText: 'Phone Number',
                //                   labelStyle: kNormalTextStyleExtraSmall,
                //
                //                   hintText:  '0771231233',
                //                   hintStyle: kNormalTextStyle
                //               ) ,
                //             ),
                //           ],
                //         ),
                //       )
                //     ),
                //     // text: 'Enter customers details',
                //     title: 'Customer Details',
                //     confirmBtnText: 'Ok',
                //     confirmBtnColor: Colors.green,
                //     backgroundColor: kBlueDarkColor,
                //     onConfirmBtnTap: (){
                //
                //       Provider.of<StyleProvider>(context, listen:false).setCustomerName(name, phoneNumber);
                //       if (bookingButtonName == 'Book'){
                //         Provider.of<StyleProvider>(context, listen:false).setPaymentStatus('Submitted');
                //         Navigator.pushNamed(context, CalendarPage.id);
                //       } else {
                //         Provider.of<StyleProvider>(context, listen:false).setPaymentStatus('Paid');
                //         Navigator.pushNamed(context, SuccessPage.id);
                //       }
                //
                //       // Navigator.pop(context);
                //     }
                // );
              }
              else {

              }

            }),

            kSmallHeightSpacing,
            Text("Total: ${formatter.format(styleDataDisplay.totalPrice)} Ugx", style: kNormalTextStyleExtraSmallGreen,),
            kSmallHeightSpacing,
            Text("Your Selection: ${styleDataDisplay.basketNameItems.join(', ')}",
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center, style: kNormalTextStyleExtraSmallGrey,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: (){
                    showModalBottomSheet(
                        isScrollControlled: true,
                        context: context,
                        builder: (context) {
                          return AddServicePage();
                        });

                  },
                  child: Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                        color: kAppPinkColor,
                        borderRadius: BorderRadius.circular(10)
                    ),
                    child: Center(child: Icon(Icons.add),),
                  )
                ),
                Text("Create Service",style: kNormalTextStyle.copyWith(color: kPureWhiteColor, fontSize: 12),)
              ],
            )


          ],
        ),

      ),
    );
  }
}
