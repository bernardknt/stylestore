
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:stylestore/Utilities/constants/font_constants.dart';
import 'package:stylestore/controllers/messages_controller.dart';
import 'package:stylestore/model/common_functions.dart';
import 'package:stylestore/model/styleapp_data.dart';
import 'package:stylestore/screens/Messages/message.dart';
import 'package:stylestore/screens/Messages/sms_class.dart';
import 'package:stylestore/screens/Messages/sms_details_page.dart';
import 'package:stylestore/screens/MobileMoneyPages/mobile_money_page.dart';
import 'package:stylestore/utilities/constants/icon_constants.dart';
import 'package:stylestore/utilities/constants/user_constants.dart';
import 'package:stylestore/utilities/constants/word_constants.dart';
import 'package:stylestore/widgets/locked_widget.dart';

import '../../Utilities/constants/color_constants.dart';
import '../../model/beautician_data.dart';
import '../../widgets/customer_content.dart';
import '../MobileMoneyPages/make_custom_mobile_money_payment.dart';






class MessageHistoryPage extends StatefulWidget {
  static String id = 'message_history';
  final bool showBackButton;

  const MessageHistoryPage({Key? key, this.showBackButton = true}) : super(key: key);


  @override
  _MessageHistoryPageState createState() => _MessageHistoryPageState();
}

class _MessageHistoryPageState extends State<MessageHistoryPage> {
  // final dateNow = new DateTime.now();
  late int price = 0;
  late int quantity = 1;
  DateTime? _previousDate;
  double smsAmount = 0.0;
  String country = "";
  String currency = "";
  var formatter = NumberFormat('#,###,000');

  defaultInitialization()async{
    final prefs = await SharedPreferences.getInstance();
    country = prefs.getString(kCountry)??"Kenya";
    currency = prefs.getString(kCurrency)??"USD";
    permissionsMap = await CommonFunctions().convertPermissionsJson();
    smsAmount = prefs.getDouble(kSmsAmount)??0.0;
    business = prefs.getString(kBusinessNameConstant)??"";
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
  var costList = [];
  var phoneList = [];
  var messageList = [];
  var transIdList = [];
  var dateList = [];
  var paidStatusList = [];
  var paidStatusListColor = [];
  List<double> opacityList = [];
  Map<String, dynamic> permissionsMap = {};
  String business = '';

  double textSize = 12.0;
  String fontFamilyMont = 'Montserrat-Medium';


  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width * 0.6;


  return country!="Uganda"?Scaffold(
    backgroundColor: kBlack,

    body: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Center(child:Text("This service is not yet available in\n$country. We are working on it",textAlign: TextAlign.center, style: kNormalTextStyle.copyWith(color: kPureWhiteColor),)),
      ],
    ),
  ):Scaffold(
    backgroundColor: kBlack,
      appBar: AppBar(
        automaticallyImplyLeading: widget.showBackButton,
        actions: [
          GestureDetector(
            onTap: (){
              showModalBottomSheet(
                  isScrollControlled: true,
                  context: context,
                  builder: (context) {
                    return Scaffold(
                        appBar: AppBar(
                          elevation: 0,
                          backgroundColor: kPureWhiteColor,
                          automaticallyImplyLeading: false,
                        ),
                        body: CustomMobileMoneyPage());
                  });
            },
            child: Tooltip(
              message: "${cSmsAccountBalance.tr} ${CommonFunctions().formatter.format(Provider.of<StyleProvider>(context, listen: true).storeSmsBalance)} $currency",
              child: Padding(
                padding: const EdgeInsets.only(right: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Icon(Icons.wallet),
                    kMediumWidthSpacing,
                    Text('${CommonFunctions().formatter.format(Provider.of<StyleProvider>(context, listen: true).storeSmsBalance)} $currency', style: kNormalTextStyle.copyWith(color: kPureWhiteColor),)
                  ],
                ),
              ),
            ),
          )
        ],
        title: Text(cSmsAppBar.tr, style: kNormalTextStyle.copyWith(color: kPureWhiteColor),),
        backgroundColor: kAppPinkColor,
        foregroundColor: kPureWhiteColor,
        elevation: 0,
        centerTitle: MediaQuery.of(context).size.width< 600 ?false:true,
      ),
      floatingActionButton: permissionsMap['messages'] == false ? SizedBox():FloatingActionButton(
        onPressed: () {
          // Navigate to the MessagesPage
          Provider.of<StyleProvider>(context, listen: false).clearBulkSmsList();
          var sms = '{"thankyou": "Dear Customer! We appreciate your business. For any assistance, please call $business.","reminder": "Dear Customer, kindly make payment for your outstanding purchase with $business. For any assistance.","options": ["We value your business! Thank you for choosing $business. For any assistance, please call.","Thank you for your support! $business is here to serve you. For any assistance, please call.","Your order is on its way! Thank you for choosing $business. For any assistance, please call.","We appreciate your trust in $business! For any assistance, please call."]}';
          Provider.of<StyleProvider>(context, listen: false).setSms(sms);
          Navigator.pushNamed(context, MessagesController.id);

        },
        child: const Icon(Icons.sms_outlined, color: kPureWhiteColor,),
        backgroundColor: kAppPinkColor,
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
              messageList = [];
              transIdList = [];
              dateList = [];
              paidStatusList = [];
              paidStatusListColor = [];
              opacityList = [];
              clientList = [];
              costList = [];

              var dateSeparator = '';
              var orders = snapshot.data?.docs;
              for( var doc in orders!){

                  phoneList.add(doc['clientPhone']);
                  messageList.add(doc['message']);
                  transIdList.add(doc['id']);
                  orderStatusList.add(doc['status']);
                  dateList.add(doc['date'].toDate());
                  clientList.add(doc['numbers']);
                  costList.add(doc['cost']);

              }
              // return Text('Let us understand this ${deliveryTime[3]} ', style: TextStyle(color: Colors.white, fontSize: 25),);
              return
                phoneList.isEmpty? Center(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        kIsWeb?Icon(Icons.mark_email_read, color: kPureWhiteColor,):Lottie.asset("images/mailtime.json",height: 100),

                        Text(cNoMessages.tr, style: kNormalTextStyle.copyWith(color: kPureWhiteColor),) ]),
                ):ListView.builder(
                  shrinkWrap: true,
                  itemCount: messageList.length,

                  itemBuilder: (context, index){
                    var transactionDate = DateTime(dateList[index].year, dateList[index].month, dateList[index].day);
                    var showDateSeparator = false;
                    if (transactionDate.difference(DateTime.now()).inDays == 0) {
                      dateSeparator = cToday.tr;
                    } else if (transactionDate.difference(DateTime.now()).inDays == -1) {
                      dateSeparator = cYesterday.tr;
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
                          kLargeHeightSpacing,
                          Text(
                            _getDateSeparator(transactionDate),
                            style: kNormalTextStyle.copyWith(color: kPureWhiteColor, fontSize: 13),
                          ),
                          kLargeHeightSpacing,
                        ],
                        GestureDetector(
                          onTap: (){
                            showModalBottomSheet(
                                isScrollControlled: true,
                                context: context,
                                builder: (context) {
                                  return Scaffold(
                                      appBar: AppBar(
                                        elevation: 0,
                                        backgroundColor: kAppPinkColor,
                                        automaticallyImplyLeading: false,
                                      ),
                                      body: SmsDetailsPage(smsMessage: SmsMessage(message:messageList[index], recipients: clientList[index], timestamp: dateList[index], delivered: true, cost: costList[index].toDouble())),);
                                });
                          },
                          child: Card(

                            color: kPureWhiteColor.withOpacity(0.8),
                            margin: const EdgeInsets.fromLTRB(25.0, 8.0, 25.0, 8.0),
                            shape: RoundedRectangleBorder(borderRadius:BorderRadius.circular(10)),
                            shadowColor: kAppPinkColor,
                            elevation: 1.0,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Stack(
                                children: [
                                  SizedBox(
                                    width: 300,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('"${messageList[index]}"', style: const TextStyle( fontSize: 14, fontStyle: FontStyle.italic, fontWeight: FontWeight.w500),),
                                        kSmallHeightSpacing,
                                        Text('To: ${phoneList[index]}', style: TextStyle(fontSize: 12, color: kBlack)),
                                        // Text('No.:  ${phoneList[index]}', style: TextStyle(fontSize: 13, color: kBlack)),
                                        Text('Sent: ${DateFormat('EE, dd, MMM, kk:mm a').format(dateList[index])}', style: TextStyle(fontSize: 12, color: kBlack),),

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
      return cToday.tr;
    } else if (date.difference(DateTime.now()).inDays == -1) {
      return cYesterday.tr;
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}



