import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:stylestore/Utilities/constants/color_constants.dart';
import 'package:stylestore/screens/customer_pages/customer_data.dart';
import '../../Utilities/constants/font_constants.dart';
import '../../model/beautician_data.dart';
import '../../model/common_functions.dart';
import '../../model/styleapp_data.dart';
import '../../widgets/rounded_icon_widget.dart';
import '../MobileMoneyPages/make_custom_mobile_money_payment.dart';


class BulkSmsPage extends StatefulWidget {
  static String id = "bulkSms_page";
  const BulkSmsPage({super.key});

  @override
  State<BulkSmsPage> createState() => _BulkSmsPageState();
}

class _BulkSmsPageState extends State<BulkSmsPage> {
  List<AllCustomerData> newCustomers = [];
  String businessId = '';
  Map<String, dynamic> permissionsMap = {};
  Map<String, dynamic> videoMap = {};
  TextEditingController controller  = TextEditingController()..text = '';
  TextEditingController controllerBulkNumbers  = TextEditingController()..text = '';

  var message  = "";
  var options =[];
  bool showManually = false;



  TextEditingController searchController = TextEditingController();
  List<AllCustomerData> filteredCustomers = [];


  @override
  void initState() {
    defaultInitialization();

    super.initState();
  }

  void filterEmployees(String query) {
    setState(() {
      filteredCustomers = newCustomers
          .where((employee) =>
      employee.fullNames.toLowerCase().contains(query.toLowerCase()) ||
          employee.fullNames.toLowerCase().contains(query.toLowerCase()) ||
          employee.phone.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }


  void defaultInitialization() async {

    controller.text = Provider.of<BeauticianData>(context, listen: false).textMessage;
    controllerBulkNumbers.text = Provider.of<BeauticianData>(context, listen: false).bulkNumbersForMessaging;

    permissionsMap = await CommonFunctions().convertPermissionsJson();
    videoMap = await CommonFunctions().convertWalkthroughVideoJson();
    newCustomers = await CommonFunctions().retrieveCustomerData(context);
    filteredCustomers.addAll(newCustomers);
    // options = jsonMap['options'];
    setState(() {});
  }

// Helper method to build information card
  Widget buildInfoCard(
      {required String title,
        required String value,
        Color cardColor = kBackgroundGreyColor,
        IconData cardIcon = Icons.accessibility}) {
    return Tooltip(
      message: title,
      child: Card(
        color: cardColor.withOpacity(0.2),
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              kSmallHeightSpacing,
              Icon(
                cardIcon,
                color: cardColor.withOpacity(0.6),
              ),
              kSmallHeightSpacing,
              Text(
                value,
                style: TextStyle(fontSize: 18.0),
              ),
            ],
          ),
        ),
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    var beauticianDataListen = Provider.of<BeauticianData>(context);
    var styleData = Provider.of<StyleProvider>(context, listen: false);
    var styleDataListen = Provider.of<StyleProvider>(context, listen: true);
    return Scaffold(
      // floatingActionButtonLocation: FloatingActionButtonLocation.,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: kAppPinkColor,
        onPressed: () {
          print(Provider.of<StyleProvider>(context, listen: false).bulkNumbers);
          print(CommonFunctions().processPhoneNumbers(Provider.of<StyleProvider>(context, listen: false).bulkNumbers));

          // If the store balance is less than the cost of the sms going out then
          if(styleDataListen.storeSmsBalance< 40 * CommonFunctions().processPhoneNumbers(styleData.bulkNumbers).length)
            {
              showDialog(context: context, builder: (BuildContext context) {
                return
                  Material(
                    color: Colors.transparent,

                    child: Stack(
                      children: [

                        CupertinoAlertDialog(
                          title: const Text('LOW SMS BALANCE'),
                          content: Column(
                            children: [
                              Text("Oops looks like your SMS Balance is not enough\n${40 *
                                  CommonFunctions()
                                      .processPhoneNumbers(styleData.bulkNumbers)
                                      .length} Ugx is the cost for sending this message to ${CommonFunctions()
                                  .processPhoneNumbers(styleData.bulkNumbers)
                                  .length} Numbers\n_________________________\nYour account balance is ${styleData.storeSmsBalance} Ugx ",
                                style: kNormalTextStyle.copyWith(color: kBlack),),

                            ],
                          ),
                          actions: [
                            CupertinoDialogAction(isDestructiveAction: true,
                                onPressed: () {
                                  // _btnController.reset();
                                  Navigator.pop(context);
                                },
                                child: const Text('Cancel')),
                            CupertinoDialogAction(isDefaultAction: true,
                                onPressed: () {
                                  Navigator.pop(context);
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
                                child: const Text('Load Bundles')),

                          ],
                        ),
                      ],
                    ),
                  );
              });

            }else {
            showDialog(context: context, builder: (BuildContext context) {
              return
                Material(
                  color: Colors.transparent,

                  child: Stack(
                    children: [

                      CupertinoAlertDialog(
                        title: const Text('SENDING MESSAGE'),
                        content: Column(
                          children: [
                            Text("${beauticianDataListen
                                .textMessage}\n_________________________\nTo: ${CommonFunctions()
                                .processPhoneNumbers(styleData.bulkNumbers)
                                .length} Numbers\n_________________________\n@ ${40 *
                                CommonFunctions()
                                    .processPhoneNumbers(styleData.bulkNumbers)
                                    .length} Ugx",
                              style: kNormalTextStyle.copyWith(color: kBlack),),

                          ],
                        ),
                        actions: [
                          CupertinoDialogAction(isDestructiveAction: true,
                              onPressed: () {
                                // _btnController.reset();
                                Navigator.pop(context);
                              },
                              child: const Text('Cancel')),
                          CupertinoDialogAction(isDefaultAction: true,
                              onPressed: () {
                                Provider.of<BeauticianData>(
                                    context, listen: false).setLottieImage(
                                    'images/sending.json', "Message Sent");
                                CommonFunctions().sendBulkSms(
                                    CommonFunctions().processPhoneNumbers(
                                        styleData.bulkNumbers),
                                    beauticianDataListen.textMessage,
                                    "Frutsexpress", "0");

                                // This function sends the message to the server and records the list of those numbers sent.
                                final double costOfMessages = 40.0 * CommonFunctions().processPhoneNumbers(styleData.bulkNumbers).length;
                                CommonFunctions().uploadMessageToServer(context, "Bulk Numbers", true,CommonFunctions().processPhoneNumbers(styleData.bulkNumbers), costOfMessages);
                                Navigator.pop(context);
                              },
                              child: const Text('Send')),

                        ],
                      ),
                    ],
                  ),
                );
            });
          }
        },
        label: Text("Send", style: kNormalTextStyle.copyWith(color: kPureWhiteColor),),


      ),


      body:  SingleChildScrollView(
        child: Column(
          children: [
            Center(
              child: SizedBox(
                height: 900,
                width: MediaQuery.of(context).size.width > 600 ? 400 : MediaQuery.of(context).size.width * 1.5,

                child: Column(

                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [


                    // Row of four cards
                    Text("Type your message here",style: kNormalTextStyle.copyWith(color: kBlack, fontWeight: FontWeight.bold),),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child:
                      TextField(
                        controller:controller,
                        maxLength: 160,
                        onChanged: (enteredQuestion){
                          print(enteredQuestion);
                          message = enteredQuestion;
                          beauticianDataListen.setTextMessage(enteredQuestion);
                        },
                        maxLines: null,
                        decoration: InputDecoration(
                          border:
                          //InputBorder.none,
                          OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.green, width: 2),
                          ),
                          labelText: 'Message',
                          labelStyle: kNormalTextStyleExtraSmall,
                          hintText: '',
                          hintStyle: kNormalTextStyle,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text("Send the message to:",style: kNormalTextStyle.copyWith(color: kBlack, fontWeight: FontWeight.bold),),
                              kSmallWidthSpacing,
                              Container(
                                decoration: BoxDecoration(
                                  color: kPlainBackground,
                                  borderRadius: BorderRadius.all(Radius.circular(5))
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(5),
                                  child: Row(
                                    children: [
                                      Icon(Icons.people_alt_outlined),
                                      kSmallWidthSpacing,
                                      Text("${Provider.of<StyleProvider>(context).bulkNumbers.length}")
                                    ]

                                  ),
                                ),
                              )
                            ],
                          ),

                          GestureDetector(
                            onTap: (){
                              showManually =!showManually;
                              setState(() {

                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: showManually != true?kGreenThemeColor:kFontGreyColor,
                                borderRadius: BorderRadius.all(Radius.circular(5))
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(8),
                                child:

                                Text("Add Manually", style: kNormalTextStyle.copyWith(color: kPureWhiteColor),),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),

                    kSmallHeightSpacing,
                    showManually==true?

                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(

                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          Row(
                            children: [
                              Icon(Icons.info, color: kGreenThemeColor,),
                              kSmallWidthSpacing,
                              Text("Input phone numbers, one on each line", style: kNormalTextStyle,),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: kBackgroundGreyColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                children: [

                                  kSmallHeightSpacing,
                                  TextField(
                                    controller: controllerBulkNumbers,
                                    maxLines: 5,
                                    decoration: InputDecoration(
                                      hintText: '0770000111\n0777111222\n0776889996',
                                      hintStyle:
                                      kNormalTextStyle.copyWith(color: kFontGreyColor),
                                      border: InputBorder.none,
                                    ),
                                    style: kNormalTextStyle.copyWith(color: kBlack),
                                    onChanged: (value) {

                                      // Provider.of<StyleProvider>(context, listen: false).setTransactionNote(value);
                                      // taskToDo = value;
                                      Provider.of<BeauticianData>(context, listen: false).setBulkMessagingNumbers(value);
                                    },
                                  ),
                                  kSmallHeightSpacing,
                                  Provider.of<BeauticianData>(context, listen: true).bulkNumbersForMessaging!=""?
                                  GestureDetector(
                                    onTap: (){
                                      var numbers = Provider.of<BeauticianData>(context, listen:false).bulkNumbersForMessaging;
                                      // print(  Provider.of<BeauticianData>(context, listen:false).bulkNumbersForMessaging);
                                      print(CommonFunctions().convertTextToPhoneNumbers(numbers, context));
                                      // showManually =!showManually;
                                      // setState(() {
                                      //
                                      // });
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                          color: kGreenThemeColor,
                                          borderRadius: BorderRadius.all(Radius.circular(5))
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.all(8),
                                        child:

                                        Text("Upload Numbers", style: kNormalTextStyle.copyWith(color: kPureWhiteColor),),
                                      ),
                                    ),
                                  ):SizedBox()
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ):SizedBox(),
                    kSmallHeightSpacing,
                    SizedBox(
                      height: 50,
                      child:
                      ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: Provider.of<StyleProvider>(context).bulkNumbers.length,
                        itemBuilder: (context, i) {
                          return GestureDetector(
                            onTap: (){
                              Provider.of<StyleProvider>(context, listen: false).addBulkSmsList(Provider.of<StyleProvider>(context, listen: false).bulkNumbers[i],Provider.of<StyleProvider>(context, listen: false).bulkNames[i] );
                            },
                            child: Padding(
                              padding:
                              const EdgeInsets.only(
                                  right: 3.0),
                              child: Column(
                                children: [
                                  Text(Provider.of<StyleProvider>(context, listen: false).bulkNames[i],style: kNormalTextStyle.copyWith(fontSize: 9),),

                                  Container(
                                    decoration: BoxDecoration(
                                      color: kSalesButtonColor,
                                      borderRadius:
                                      BorderRadius.circular(
                                          10),
                                    ),
                                    child: Padding(
                                      padding:
                                      const EdgeInsets.all(
                                          8.0),
                                      child: Text(
                                        Provider.of<StyleProvider>(context, listen: false).bulkNumbers[i],
                                        style:
                                        kNormalTextStyleDark
                                            .copyWith(
                                          color:
                                          kBlack,
                                          fontWeight:
                                          FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Stack(
                        children: [
                          TextField(
                            controller: searchController,
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.search),
                              hintText: 'Search Customer',
                              hintFadeDuration: Duration(milliseconds: 100),
                            ),
                            onChanged: filterEmployees,
                          ),
                          Positioned(
                            right: 0,
                            child: GestureDetector(
                              onTap: (){

                                styleDataListen.addEntireContactToSmsList(filteredCustomers);
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                    color: kCustomersButtonColor,
                                    borderRadius: BorderRadius.all(Radius.circular(5))
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Text("Select All", style: kNormalTextStyle.copyWith(color: kBlack, fontSize: 12),),
                                ),
                              ),
                            )
                          ),
                        ],
                      ),
                    ),

                    Expanded(
                      child: ListView.builder(
                        itemCount: filteredCustomers.length,
                        itemBuilder: (context, index) {
                          return Card(
                            margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                            child: ListTile(
                              leading: RoundImageRing(
                                networkImageToUse: filteredCustomers[index].photo,
                                outsideRingColor: kBackgroundGreyColor,
                                radius: 48,
                              ),
                              title: Text(
                                "${filteredCustomers[index].fullNames}",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              trailing:styleData.bulkNumbers.contains(filteredCustomers[index].phone)?Icon(Icons.check_circle_outline, color: kGreenThemeColor,size: 14,):Icon(Icons.add, size: 14,),
                              subtitle: Text('Phone: ${filteredCustomers[index].phone}'),
                              onTap: () {
                                // Handle employee item tap
                                styleDataListen.addBulkSmsList(filteredCustomers[index].phone, filteredCustomers[index].fullNames);
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
