import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:stylestore/Utilities/constants/color_constants.dart';
import 'package:stylestore/model/beautician_data.dart';
import 'package:stylestore/model/common_functions.dart';
import 'package:stylestore/model/styleapp_data.dart';
import 'package:stylestore/utilities/constants/font_constants.dart';
import 'package:stylestore/widgets/TicketDots.dart';
import 'package:url_launcher/url_launcher.dart';

import '../controllers/home_controller.dart';
import '../utilities/paymentButtons.dart';
import '../widgets/orderedContentsWidget.dart';
import 'new_printer.dart';

class AppointmentSummary extends StatefulWidget {
  static String id = 'appointment_summary_details';

  AppointmentSummary({Key? key}) : super(key: key);

  @override
  _AppointmentSummaryState createState() => _AppointmentSummaryState();
}




class _AppointmentSummaryState extends State<AppointmentSummary> {
  var colorOfButton = kAppPinkColor;
  defaultsInitiation(){
    if (Provider.of<BeauticianData>(context, listen: false).appointmentDate.day == DateTime.now().day){
      colorOfButton = kAppPinkColor;
    }else {
      colorOfButton = kFontGreyColor;
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    defaultsInitiation();
  }
  @override
  Widget build(BuildContext context) {
    var beauticianData = Provider.of<BeauticianData>(context);
    CollectionReference customerOrderStatus =
        FirebaseFirestore.instance.collection('orders');
    Future<void> changeOrderStatus() {
      // Call the user's CollectionReference to add a new user
      return customerOrderStatus
          .doc(beauticianData.orderNumber)
          .update({
            "status": "Ready for Delivery",
            "prepareEndTime": DateTime.now()
          })
          .then((value) => print("Status Changed"))
          .catchError((error) => print("Failed to change status: $error"));
    }

    return Scaffold(
        floatingActionButton: FloatingActionButton.extended(
          splashColor: kBlueDarkColorOld,
          // foregroundColor: Colors.black,
          backgroundColor: colorOfButton,
          //blendedData.saladButtonColour,
          onPressed: () {
            // if(Provider.of<BlenditData>(context, listen: false).saladIngredientsNumber == 0){
            //   AlertPopUpDialogueMain(context, imagePath: 'images/addItems.json', title: 'No ingredients Added', text: 'Add some ingredients into your Salad Bowl', fruitProvider: fruitProvider, extraProvider: extraProvider, blendedData: blendedData, vegProvider: vegProvider);
            //
            // }
            // else {
            //   showModalBottomSheet(
            //       context: context,
            //       builder: (context) {
            //         return SelectedSaladIngredientsListView();
            //       });
            // }
            if (colorOfButton == kAppPinkColor){

            }else{
              CoolAlert.show(
                  lottieAsset: 'images/booking.json',
                  context: context,
                  type: CoolAlertType.success,
                  text: "This Booking is not yet due",
                  title: "Appointment not Today",
                  confirmBtnText: 'Yes',
                  confirmBtnColor: kFaintGrey,
                  cancelBtnText: 'Cancel',
                  showCancelBtn: true,
                  backgroundColor: kPureWhiteColor,

                  onConfirmBtnTap: (){
                    // Provider.of<StyleProvider>(context, listen: false).deleteItemFromBasket(styleData.basketItems[index]);
                    //  removePostFavourites(docIdList[index],postId[index], userEmail);
                    Navigator.pop(context);
                  }
              );
            }

          },
          icon: const Icon(
            Iconsax.calendar,
            color: kPureWhiteColor,
          ),
          label: Text(
            'Start Appointment',
            style: kNormalTextStyle.copyWith(color: kPureWhiteColor),
          ),
        ),
        floatingActionButtonLocation:
            FloatingActionButtonLocation.miniCenterFloat,
        appBar: AppBar(
          backgroundColor: kPureWhiteColor,
          centerTitle: true,
          title: Text(
            'Appointment Summary',
            style: kNormalTextStyle,
          ),
        ),
        backgroundColor: kContainerGrey,
        body: Column(
          children: [
            Stack(children: [
              Container(
                //color: Colors.blue,
                margin: EdgeInsets.all(10),
                padding: EdgeInsets.all(10),
                // height: 100,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    color: kBlueDarkColorOld),
                child: Column(
                  children: [
                    Container(
                      child: RichText(
                        text: TextSpan(
                          text: 'Customer: ${beauticianData.clientName}',
                          style: kHeading2TextStyleBold.copyWith(
                              color: kPureWhiteColor, fontSize: 14),
                          children: <TextSpan>[
                            TextSpan(
                                text: "\nPhone No: ${beauticianData.phoneNumber}",
                                style: kHeading2TextStyleBold.copyWith(
                                    color: kPureWhiteColor, fontSize: 14)),
                            // TextSpan(
                            //     text:
                            //         "\nItems Ordered: ${beauticianData.itemDetails.length}",
                            //     style: kHeading2TextStyleBold.copyWith(
                            //         color: kPureWhiteColor, fontSize: 14)),
                            TextSpan(
                                text: '\nLocation: ${beauticianData.location}',
                                style: kHeading2TextStyleBold.copyWith(
                                    color: kPureWhiteColor, fontSize: 14)),
                            TextSpan(
                                text:
                                    "\nTime: ${DateFormat('EEE-kk-MMM').format(beauticianData.appointmentDate)} ${DateFormat('h:mm a').format(beauticianData.appointmentTime)}",
                                style: kHeading2TextStyleBold.copyWith(
                                    color: kPureWhiteColor, fontSize: 14)),
                            TextSpan(
                                text: "\nBill Total: ${CommonFunctions().formatter.format(beauticianData.bill)} Ugx",
                                style: kHeading2TextStyleBold.copyWith(
                                    color: kPureWhiteColor, fontSize: 14)),
                            TextSpan(
                                text: "\nBooked: - ${CommonFunctions().formatter.format(beauticianData.bookingFee)} Ugx",
                                style: kHeading2TextStyleBold.copyWith(
                                    color: kAppPinkColor, fontSize: 14)),
                            TextSpan(
                                text:
                                    "\nReceivable: ${CommonFunctions().formatter.format(beauticianData.bill - beauticianData.bookingFee)} Ugx",
                                style: kHeading2TextStyleBold.copyWith(
                                    color: kGreenThemeColor, fontSize: 14)),
                            // TextSpan(text: '\nStatus: ${beauticianData.note}'),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    paymentButtons(
                      continueFunction: () {
                        CoolAlert.show(
                            lottieAsset: 'images/print.json',
                            context: context,
                            type: CoolAlertType.success,
                            widget: Text("Please contact Support for a thermal printer to be able to print these receipts",textAlign: TextAlign.center, style: kNormalTextStyle,),
                            title: "Contact Support",
                            confirmBtnText: 'Ok',
                            confirmBtnColor: kAppPinkColor,
                            // cancelBtnText: 'Cancel',
                            showCancelBtn: false,
                            backgroundColor: kBlueDarkColorOld,

                            onConfirmBtnTap: (){
                              // Provider.of<StyleProvider>(context, listen: false).deleteItemFromBasket(styleData.basketItems[index]);
                              //  removePostFavourites(docIdList[index],postId[index], userEmail);
                              Navigator.pop(context);
                            }
                        );
                        // Navigator.pushNamed(context, NewPrinter.id);
                      },
                      continueBuyingText: 'Print Receipt',
                      lineIconFirstButton: Icons.print,
                      checkOutText: 'Edit Order',
                      buyFunction: () {
                        changeOrderStatus();
                        Navigator.pushNamed(context, ControlPage.id);
                      },
                    )
                  ],
                ),
              ),
              Positioned(
                  top: 20,
                  right: 20,
                  child: GestureDetector(
                    onTap: () {
                      // CommonFunctions()
                      //     .callPhoneNumber(beauticianData.phoneNumber);
                      CoolAlert.show(
                          lottieAsset: 'images/message.json',
                          context: context,
                          type: CoolAlertType.success,
                          // text: "Would you like to send an appointment reminder message to customer? ",
                          title: "Reminder Message",
                          widget: Column(
                            children: [
                              Text("Would you like to send an appointment SMS message to customer?",textAlign:TextAlign.center, style: kNormalTextStyleDark.copyWith(fontSize: 15),),
                              kSmallHeightSpacing,
                              TicketDots(mainColor: kFontGreyColor, circleColor: kPureWhiteColor,),
                              Text("Message:",style: kNormalTextStyle.copyWith(fontSize: 15)),
                              Text('"Dear ${beauticianData.clientName},Your appointment with ${Provider.of<StyleProvider>(context, listen: false).beauticianName} is due on ${DateFormat('EEE-kk-MMM').format(beauticianData.appointmentDate)} ${DateFormat('h:mm a').format(beauticianData.appointmentTime)}"',textAlign:TextAlign.center, style: kNormalTextStyle.copyWith(fontSize: 14, )),
                            ],
                          ),
                          confirmBtnText: 'Send',
                          cancelBtnText: 'Cancel',
                          showCancelBtn: true,
                          backgroundColor: kPureWhiteColor,

                          onConfirmBtnTap: (){
                            // Provider.of<StyleProvider>(context, listen: false).deleteItemFromBasket(styleData.basketItems[index]);
                            //  removePostFavourites(docIdList[index],postId[index], userEmail);
                            Navigator.pop(context);
                          }
                      );

                    },
                    child: CircleAvatar(
                      radius: 16,
                      child: Icon(Iconsax.sms),
                    ),
                  ))
            ]),
            Stack(children: [
              ListView.builder(
                  shrinkWrap: true,
                  itemCount: beauticianData.itemDetails.length,
                  itemBuilder: (context, index) {
                    return OrderedContentsWidget(
                      productDescription: beauticianData.itemDetails[index]
                          ['description'],
                      productName: beauticianData.itemDetails[index]['product'],
                      quantity: beauticianData.itemDetails[index]['quantity'],
                      orderIndex: index + 1,
                      note: beauticianData.note,
                    );
                  }),
            ]),
          ],
        ));
  }
}
