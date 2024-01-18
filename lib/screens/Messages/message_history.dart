
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:stylestore/Utilities/constants/font_constants.dart';
import 'package:stylestore/model/common_functions.dart';
import 'package:stylestore/model/styleapp_data.dart';
import 'package:stylestore/widgets/locked_widget.dart';

import '../../Utilities/constants/color_constants.dart';
import '../../model/beautician_data.dart';
import '../../widgets/customer_content.dart';






class MessageHistoryPage extends StatefulWidget {
  static String id = 'message_history';

  @override
  _MessageHistoryPageState createState() => _MessageHistoryPageState();
}

class _MessageHistoryPageState extends State<MessageHistoryPage> {
  // final dateNow = new DateTime.now();
  late int price = 0;
  late int quantity = 1;
  DateTime? _previousDate;
  var formatter = NumberFormat('#,###,000');

  defaultInitialization()async{
    permissionsMap = await CommonFunctions().convertPermissionsJson();
    setState(() {

    });
  }



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    defaultInitialization();
    print(Provider.of<StyleProvider>(context, listen: false).beauticianId);


  }

  var productList = [];
  var orderStatusList = [];
  var clientList = [];
  var phoneList = [];
  var descList = [];
  var transIdList = [];
  var dateList = [];
  var paidStatusList = [];
  var paidStatusListColor = [];
  List<double> opacityList = [];
  Map<String, dynamic> permissionsMap = {};

  double textSize = 12.0;
  String fontFamilyMont = 'Montserrat-Medium';


  @override
  Widget build(BuildContext context) {double width = MediaQuery.of(context).size.width * 0.6;
  // var blendedData = Provider.of<BlenditData>(context);

  return Scaffold(
    backgroundColor: kBlack,
      appBar: AppBar(
        title: Text("SMS History", style: kNormalTextStyle.copyWith(color: kPureWhiteColor),),
        backgroundColor: kAppPinkColor,
        foregroundColor: kPureWhiteColor,
        elevation: 0,
        centerTitle: true,
      ),

      body:
      permissionsMap['messages'] == false ? LockedWidget(page: "Messages"):StreamBuilder<QuerySnapshot> (
          stream: FirebaseFirestore.instance
              .collection('sms')
              .where('sender_id', isEqualTo:
         Provider.of<StyleProvider>(context, listen: false).beauticianId
          )


              .orderBy('date',descending: true)
              .snapshots(),
          builder: (context, snapshot)
          {
            if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            if(!snapshot.hasData){
              return Container();
            }else{

              phoneList = [];
              descList = [];
              transIdList = [];
              dateList = [];
              paidStatusList = [];
              paidStatusListColor = [];
              opacityList = [];
              clientList = [];

              var dateSeparator = '';
              var orders = snapshot.data?.docs;
              for( var doc in orders!){



                  phoneList.add(doc['clientPhone']);
                  descList.add(doc['message']);
                  transIdList.add(doc['id']);
                  orderStatusList.add(doc['status']);
                  dateList.add(doc['date'].toDate());
                  clientList.add(doc['client']);




              }
              // return Text('Let us understand this ${deliveryTime[3]} ', style: TextStyle(color: Colors.white, fontSize: 25),);
              return
                phoneList.isEmpty? Center(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [Lottie.asset("images/mailtime.json",height: 100), Text("No Messages sent yet!", style: kNormalTextStyle.copyWith(color: kPureWhiteColor),) ]),
                ):ListView.builder(
                  shrinkWrap: true,
                  itemCount: descList.length,

                  itemBuilder: (context, index){
                    var transactionDate = DateTime(dateList[index].year, dateList[index].month, dateList[index].day);
                    var showDateSeparator = false;
                    if (transactionDate.difference(DateTime.now()).inDays == 0) {
                      dateSeparator = 'Today';
                    } else if (transactionDate.difference(DateTime.now()).inDays == -1) {
                      dateSeparator = 'Yesterday';
                    } else {
                      dateSeparator = '${transactionDate.day}/${transactionDate.month}/${transactionDate.year}';
                    }
                    if (_previousDate == null || transactionDate != _previousDate) {
                      showDateSeparator = true;
                      _previousDate = transactionDate;
                    }
                    return Column(

                      children: [
                        if (showDateSeparator) ...[
                          SizedBox(height: 10),
                          Text(
                            _getDateSeparator(transactionDate),
                            style: kNormalTextStyle.copyWith(color: kPureWhiteColor, fontSize: 13),
                          ),
                          SizedBox(height: 10),
                        ],
                        Card(

                          color: kPureWhiteColor.withOpacity(0.8),
                          margin: const EdgeInsets.fromLTRB(25.0, 8.0, 25.0, 8.0),
                          shape: RoundedRectangleBorder(borderRadius:BorderRadius.circular(10)),
                          shadowColor: kAppPinkColor,
                          elevation: 1.0,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Stack(
                              children: [
                                Container(
                                  width: 300,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('"${descList[index]}"', style: const TextStyle( fontSize: 14, fontStyle: FontStyle.italic, fontWeight: FontWeight.w500),),
                                      kSmallHeightSpacing,
                                      Text('To:  ${clientList[index]} .No.:  ${phoneList[index]}', style: TextStyle(fontSize: 12, color: kBlack)),
                                      // Text('No.:  ${phoneList[index]}', style: TextStyle(fontSize: 13, color: kBlack)),
                                      Text('Sent: ${DateFormat('EE, dd, MMM, hh:mm a').format(dateList[index])}', style: TextStyle(fontSize: 12, color: kBlack),),

                                    ],
                                  ),
                                ),
                                Positioned(
                                    bottom: 2,
                                    right: 5,

                                    child: Icon(Icons.check_circle, color: kGreenThemeColor,size: 15,))
                              ],
                            ),
                          ),
                        ),
                      ],
                    );

                  }
              );
            }

          }

      )
  );
  }
  String _getDateSeparator(DateTime date) {
    if (date.difference(DateTime.now()).inDays == 0) {
      return 'Today';
    } else if (date.difference(DateTime.now()).inDays == -1) {
      return 'Yesterday';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}



