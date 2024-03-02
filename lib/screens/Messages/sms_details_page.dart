import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stylestore/Utilities/constants/color_constants.dart';
import 'package:stylestore/Utilities/constants/font_constants.dart';
import 'package:stylestore/screens/Messages/sms_class.dart';

class SmsDetailsPage extends StatelessWidget {
  final SmsMessage smsMessage;

  const SmsDetailsPage({Key? key, required this.smsMessage}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBlack,
      appBar: AppBar(
        backgroundColor: kBlack,
        foregroundColor: kPureWhiteColor,
        title: Text('Message Details', style: kNormalTextStyle.copyWith(color: kPureWhiteColor),),
      ),
      body: SingleChildScrollView( // Use if content might overflow
        padding: const EdgeInsets.all(16.0),
        child: Container(
          decoration: BoxDecoration(
            color: kPureWhiteColor,
            borderRadius: BorderRadius.circular(20)
            
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Message:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(smsMessage.message,  style: kNormalTextStyle.copyWith(color: kBlack, fontSize: 15),),
                kLargeHeightSpacing,
                Text('Recipients:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(smsMessage.recipients.join(', '), style: kNormalTextStyle.copyWith(color: kBlack, fontSize: 15),), // Join numbers with commas
                kLargeHeightSpacing,
                Text('Sent At:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(DateFormat('EEE, dd, MMMM, yyyy kk:mm a').format(smsMessage.timestamp), style: kNormalTextStyle.copyWith(color: kBlack, fontSize: 15),),
                kLargeHeightSpacing,
                Text('Delivery Status:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(smsMessage.delivered ? 'Yes' : 'No'),
                kLargeHeightSpacing,
                Text('Cost:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('${smsMessage.cost.toStringAsFixed(0)} Ugx',  style: kNormalTextStyle.copyWith(color: kBlack, fontSize: 15),), // Format cost
              ],
            ),
          ),
        ),
      ),
    );
  }
}
