
import 'package:flutter/material.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:provider/provider.dart';

import '../../Utilities/constants/color_constants.dart';
import '../../Utilities/constants/font_constants.dart';
import '../../model/styleapp_data.dart';



class PaymentProcessing extends StatefulWidget {

  @override
  _PaymentProcessingState createState() => _PaymentProcessingState();
}

class _PaymentProcessingState extends State<PaymentProcessing> {
  @override
  // CountDownController _controller = CountDownController();


  String countdownText = 'Awaiting Payment Confirmation.\nA USSD prompt will be sent to your phone to complete the transaction';

  Widget build(BuildContext context) {
    var styleDataDisplay = Provider.of<StyleProvider>(context);
    return Container(
      color: Color(0xFF757575),

      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
            color: Colors.white ,
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(25), topLeft: Radius.circular(25))),
        child: Column(children: [
          const Text('Payment in Progress', style: kHeading2TextStyleBold,),
          const SizedBox(height: 15,),
          CircularCountDownTimer(isReverse: true, width: 100, height: 100, duration: 30,
            fillColor: kAppPinkColor, ringColor: kBlueDarkColorOld,onStart:(){
              // Navigator.pushNamed(context, ControlPage.id);


            },onComplete: (){
            styleDataDisplay.clearLists();
             Navigator.pop(context);
            },
          ),
          const SizedBox(height: 20,),
          Text(countdownText, maxLines: 5,textAlign: TextAlign.center,style: kHeading2TextStyle,),

        ],),
      ),


    );
  }
}
