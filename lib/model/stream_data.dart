



import 'dart:async';

import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../Utilities/constants/color_constants.dart';
import '../Utilities/constants/font_constants.dart';
import '../utilities/showDialogFunc.dart';
import 'beautician_data.dart';
import 'common_functions.dart';

StreamBuilder<QuerySnapshot<Object?>> buildStreamBuilder() {
  late Timer _timer;
  animationTimer() {

  }
  var orderStatus = [];

  var location = [];
  var customerName = [];
  var orderNumber = [];

  var orderContents = [];
  var instructions = [];
  var appointmentDate = [];
  var appointmentTime = [];
  var bookingFee = [];
  var note = [];
  var cardColor = [];
  var textColor = [];
  var phoneCircleColor = [];
  var names = [];
  var appointmentsToday = [];
  var customerPhone = [];
  var onlineStatus = [];
  var bellOpacity = [];
  List <Color> onlineStatusColour = [];
  var totalBill= [];

  return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('appointments')
          .orderBy('appointmentDate',descending: false)
          .snapshots(),
      builder: (context, snapshot)
      {
        if(!snapshot.hasData){
          return Container();
        }
        else
        {
        animationTimer(List appointments) {
          print('executed');
          _timer = Timer(const Duration(milliseconds: 500), () {
            Provider.of<BeauticianData>(context, listen: false).setAppointmentToday(appointments);
          });
        }
          customerName = [];
          customerPhone = [];
          location = [];
          orderNumber = [];
          orderStatus = [];
          orderContents = [];
          appointmentDate = [];
          appointmentTime = [];
          note = [];
          instructions = [];
          totalBill= [];
          onlineStatus= [];
          onlineStatusColour= [];
          bellOpacity = [];
          cardColor = [];
          textColor = [];
          phoneCircleColor = [];
          bookingFee = [];

          var orders = snapshot.data?.docs;
          for( var order in orders!){
            if(order.get('beautician_id')=='cat7b7171f0'){
              //order.get('client');

              DateTime appointmentDateTime = order.get('appointmentDate').toDate();

              if (appointmentDateTime.day >= DateTime.now().day){
                customerName.add(order.get('client'));
                location.add(order.get('location'));
                orderNumber.add(order.get('appointmentId'));
                orderStatus.add(order.get('status'));
                orderContents.add(order.get('items'));
                instructions.add(order.get('instructions'));
                appointmentDate.add(order.get('appointmentDate').toDate());
                appointmentTime.add(order.get('appointmentTime').toDate());
                note.add(order.get('paymentStatus'));
                customerPhone.add(order.get('clientPhone'));
                totalBill.add(order.get('totalFee'));
                bookingFee.add(order.get('bookingFee'));
                //bookingFee.add(order.get('bookingFee'));
                if (order.get("paymentStatus") == "offline"){
                  onlineStatus.add('Offline');
                  onlineStatusColour.add(kAppPinkColor);

                }else {
                  onlineStatus.add('Online');
                  onlineStatusColour.add(kGreenThemeColor);
                }

                if (appointmentDateTime.day == DateTime.now().day){
                  bellOpacity.add(1.0);

                  appointmentsToday.add(order.get('client'));
                  cardColor.add(kBlueDarkColorOld);
                  phoneCircleColor.add(kAppPinkColor);
                  textColor.add(kPureWhiteColor);

                } else {
                  bellOpacity.add(0.0);
                  cardColor.add(kBabyPinkThemeColor);
                  phoneCircleColor.add(kBlueDarkColorOld);
                  textColor.add(kBlack);
                }
              }

            }
            // animationTimer(appointmentsToday);
          }

          // Provider.of<BeauticianData>(context, listen: false).setAppointmentToday(2);
          // return Text('Let us understand this ${deliveryTime[3]} ', style: TextStyle(color: Colors.white, fontSize: 25),);
          return
            StaggeredGridView.countBuilder(
                crossAxisCount: 2,
                itemCount: location.length,
                crossAxisSpacing: 10,
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true ,
                itemBuilder: (context, index){
                  return Stack(
                      children: [
                        GestureDetector(
                          onTap: (){
                            Provider.of<BeauticianData>(context, listen: false).changeOrderDetails(customerName[index], location[index], orderNumber[index], appointmentDate[index], note[index], orderContents[index], orderStatus[index], customerPhone[index], totalBill[index].toDouble(), bookingFee[index].toDouble(), appointmentTime[index]);
                            showDialogFunc(context, orderStatus[index], location[index], customerName[index], orderNumber[index], orderContents[index], note[index], appointmentDate[index] );
                          },
                          child: Container(
                            margin: EdgeInsets.only(top: 10, right: 0, left: 0, bottom: 3),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: cardColor[index],
                            ),
                            child: Column(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(10),
                                  //height: 170,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('${customerName[index]}', style: kNormalTextStyleDark.copyWith(color: textColor[index]),),
                                      Text('Date: ${DateFormat('dd-MMM-yyyy ').format(appointmentDate[index])} ', style: kNormalTextStyleDark.copyWith(color: textColor[index]),),
                                      Text('Time: ${DateFormat('kk:mm ').format(appointmentTime[index])} ', style: kNormalTextStyleDark.copyWith(color: textColor[index]),),
                                      Text('Location: ${location[index]}', style: kNormalTextStyleDark.copyWith(color: textColor[index]),),
                                      Text('Bill : ${CommonFunctions().formatter.format(totalBill[index])} Ugx', style: kNormalTextStyleDark.copyWith(color: textColor[index]),),
                                      // Text('Bill : ${formatter.format(bookingFee[index])} Ugx', style: kNormalTextStyleDark.copyWith(color: textColor[index]),),
                                      kLargeHeightSpacing,
                                      kLargeHeightSpacing


                                    ],),
                                ),

                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child:GestureDetector(
                            onTap:(){
                              CommonFunctions().callPhoneNumber(customerPhone[index]);

                            },
                            child:CircleAvatar(
                              radius: 15,
                              child: Icon(CupertinoIcons.phone, color: kPureWhiteColor,),
                              backgroundColor: phoneCircleColor[index],
                            ),
                          ),

                        ),
                        Positioned(
                          left: 10,
                          bottom: 10,


                          child: Opacity(
                            opacity: 1,
                            child: Container(


                              decoration:  BoxDecoration(
                                  color: onlineStatusColour[index],
                                  borderRadius: BorderRadius.all(Radius.circular(6))
                              ),
                              child:  Padding(
                                padding: EdgeInsets.all(3.0),
                                child: Text(onlineStatus[index], style: kNormalTextStyleWhitePendingLabel,),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 12,
                          bottom: 5,


                          child: Opacity(
                            opacity: bellOpacity[index],
                            child: Lottie.asset('images/ring.json', height: 30),
                          ),
                        ),
                      ]
                  );
                }, staggeredTileBuilder: (index)=> StaggeredTile.fit(1));
        }
      }
  );
}