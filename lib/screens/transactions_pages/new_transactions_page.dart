


import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stylestore/Utilities/constants/font_constants.dart';
import 'package:stylestore/Utilities/constants/user_constants.dart';
import 'package:stylestore/model/common_functions.dart';
import 'package:stylestore/model/styleapp_data.dart';
import 'package:stylestore/screens/Messages/message.dart';

import 'package:stylestore/widgets/TicketDots.dart';
import 'package:stylestore/screens/payment_pages/record_payment_widget.dart';
import '../../Utilities/constants/color_constants.dart';
import '../../model/pdf_files/invoice.dart';
import '../../model/pdf_files/invoice_customer.dart';
import '../../model/pdf_files/invoice_supplier.dart';
import '../../model/pdf_files/pdf_api.dart';
import '../../model/pdf_files/pdf_invoice_api.dart';
import '../../widgets/transaction_widget.dart';
import '../edit_invoice_pages/edit_invoice.dart';


class NewTransactionsPage extends StatefulWidget {
  static String id = 'new_transactions_page';

  @override
  _NewTransactionsPageState createState() => _NewTransactionsPageState();
}

class _NewTransactionsPageState extends State<NewTransactionsPage> {

  DateTime? _previousDate;
  var storeName = "";
  var location = "";
  var phoneNumber = "";
  var formatter = NumberFormat('#,###,000');
  // Add a variable to track the selected date range.
  String _selectedDateRange = '1 month';
  String logo = '';

  void defaultInitialization()async{
    var prefs = await SharedPreferences.getInstance();
    storeName = prefs.getString(kBusinessNameConstant)!;
    location = prefs.getString(kLocationConstant)!;
    phoneNumber = prefs.getString(kPhoneNumberConstant)!;
    logo = prefs.getString(kImageConstant)!;
    setState(() {
    });
  }



  // Method to update the Firestore query based on the selected date range.
  Query _getFilteredFirestoreQuery() {
    Query query = FirebaseFirestore.instance
        .collection('appointments')
        .where('beautician_id', isEqualTo: Provider.of<StyleProvider>(context, listen: false).beauticianId);

    if (_selectedDateRange == '1 week') {
      var oneWeekAgo = DateTime.now().subtract(Duration(days: 7));
      query = query.where('appointmentDate', isGreaterThan: oneWeekAgo);
    } else if (_selectedDateRange == '1 month') {
      var oneMonthAgo = DateTime.now().subtract(Duration(days: 30));
      query = query.where('appointmentDate', isGreaterThan: oneMonthAgo);
    } else if (_selectedDateRange == 'Today') {
      var oneDayAgo = DateTime.now().subtract(Duration(days: 1));
      query = query.where('appointmentDate', isGreaterThan: oneDayAgo);
    }

    // Apply the orderBy('appointmentDate', descending: true) to the filtered query.
    query = query.orderBy('appointmentDate', descending: true);
    return query;
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
  var smsList = [];
  var clientLocationList = [];
  var clientPhoneList = [];
  var paymentDueDateList = [];
  var priceList = [];
  var paidAmountList = [];
  var paymentMethodList = [];
  var currencyList = [];
  var descList = [];
  var transIdList = [];
  var dateList = [];
  var customerIdList = [];
  var paidStatusList = [];
  var paymentHistoryList = [];
  var paidStatusListColor = [];
  List<double> opacityList = [];

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  double textSize = 12.0;
  String fontFamilyMont = 'Montserrat-Medium';
  @override
  Widget build(BuildContext context) {double width = MediaQuery.of(context).size.width * 0.6;
  var styleData = Provider.of<StyleProvider>(context, listen: false);

  return Scaffold(
      backgroundColor: kPureWhiteColor,

      body:
      Column(
        children: [

          Expanded(
            child: StreamBuilder<QuerySnapshot> (
                stream: _getFilteredFirestoreQuery().snapshots(),
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
                    productList = [];
                    orderStatusList = [];
                    priceList = [];
                    descList = [];
                    transIdList = [];
                    dateList = [];
                    paidStatusList = [];
                    paidStatusListColor = [];
                    opacityList = [];
                    clientList = [];
                    clientLocationList = [];
                    paymentDueDateList = [];
                    paidAmountList = [];
                    clientPhoneList = [];
                    smsList = [];
                    paymentMethodList = [];
                    currencyList = [];
                    paymentHistoryList = [];

                    var dateSeparator = '';
                    var orders = snapshot.data?.docs;
                    for( var doc in orders!){

                      // if( isSameDay(doc['appointmentDate'].toDate(),DateTime.now())){

                      productList.add(doc['items']);
                      priceList.add(doc['totalFee']);
                      descList.add(doc['instructions']);
                      transIdList.add(doc['appointmentId']);
                      orderStatusList.add(doc['status']);
                      dateList.add(doc['appointmentDate'].toDate());
                      clientList.add(doc['client']);
                      clientLocationList.add(doc['clientLocation']);
                      smsList.add(doc['sms']);
                      currencyList.add(doc['currency']);
                      clientPhoneList.add(doc['clientPhone']);
                      paymentDueDateList.add(doc['payment_date'].toDate());
                      paidAmountList.add(doc['paidAmount']);
                      paymentMethodList.add(doc['paymentMethod']);
                      customerIdList.add(doc['customerId']);
                      paymentHistoryList.add(doc['paymentHistory']);

                      if (doc['paymentStatus'] == 'Complete'){
                        paidStatusList.add('Paid');
                        paidStatusListColor.add(Colors.red);
                        opacityList.add(0.0);
                      }else if (doc['paymentStatus'] == 'booked'){
                        paidStatusList.add('booked');
                        paidStatusListColor.add(Colors.grey);
                        opacityList.add(1.0);
                      } else {
                        paidStatusList.add('Unpaid');
                        paidStatusListColor.add(Colors.grey);
                        opacityList.add(1.0);
                      }
                      //  }

                    }
                    // Filter the transactions based on the selected date range.
                    if (_selectedDateRange == '1 week') {
                      var oneWeekAgo = DateTime.now().subtract(Duration(days: 7));
                      orders = orders.where((doc) => doc['appointmentDate'].toDate().isAfter(oneWeekAgo)).toList();
                    } else if (_selectedDateRange == '1 month') {
                      var oneMonthAgo = DateTime.now().subtract(Duration(days: 30));
                      orders = orders.where((doc) => doc['appointmentDate'].toDate().isAfter(oneMonthAgo)).toList();
                    } else if (_selectedDateRange == 'Today') {
                      var oneDayAgo = DateTime.now().subtract(Duration(days: 1));
                      orders = orders.where((doc) => doc['appointmentDate'].toDate().isAfter(oneDayAgo)).toList();
                    }
                    // print(snapshot.data?.docs.);
                    return
                      Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                              ),

                              GestureDetector(
                                onTap: (){
                                  showDialog(context: context, builder: (BuildContext context){
                                    return
                                      CupertinoAlertDialog(
                                        title: const Text('TOTAL TRANSACTIONS'),
                                        content: Text("The value of goods you have sold for $_selectedDateRange is ${CommonFunctions().formatter.format(CommonFunctions().calculateTotalPrice(priceList))}", style: kNormalTextStyle.copyWith(color: kBlack),),
                                        actions: [

                                          CupertinoDialogAction(isDestructiveAction: true,
                                              onPressed: (){
                                                // _btnController.reset();
                                                Navigator.pop(context);
                                              },
                                              child: const Text('Cancel')),


                                        ],
                                      );
                                  });

                },
                                child: Text(
                                  '${CommonFunctions().formatter.format(CommonFunctions().calculateTotalPrice(priceList))} ($_selectedDateRange)',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ),

                              PopupMenuButton<String>(
                                icon: Icon(Icons.filter_list),
                                onSelected: (String result) {
                                  setState(() {
                                    _selectedDateRange = result;
                                  });
                                },
                                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                                  PopupMenuItem<String>(
                                    value: 'All',
                                    child: Text('All'),
                                  ),
                                  PopupMenuItem<String>(
                                    value: '1 month',
                                    child: Text('Last 1 month'),
                                  ),
                                  PopupMenuItem<String>(
                                    value: '1 week',
                                    child: Text('Last 1 week'),
                                  ),
                                  PopupMenuItem<String>(
                                    value: 'Today',
                                    child: Text('Today'),
                                  ),

                                ],
                              ),
                            ],
                          ),
                        ),
                        // Add a filter with an icon for the date range selection.

                        Expanded(
                          child: ListView.builder(
                              itemCount: productList.length,
                              shrinkWrap: true,
                              primary: false,

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
                                        CommonFunctions().getDateSeparator(transactionDate),
                                        style: kNormalTextStyle.copyWith(color: kFontGreyColor, fontSize: 13),
                                      ),
                                      SizedBox(height: 10),
                                    ],
                                    GestureDetector(
                                      onTap: (){
                                        Provider.of<StyleProvider>(context, listen: false).clearInvoiceItems();
                                        for( int i = 0; i < productList[index].length; i++ ) {
                                          print( productList[index][i]['description']);
                                          Provider.of<StyleProvider>(context, listen: false).setInvoiceItems(InvoiceItem(  description: productList[index][i]['description'],name: productList[index][i]['product'], quantity: productList[index][i]['quantity'].toDouble(),  unitPrice: productList[index][i]['totalPrice']/1.0,));
                                        }
                                     //   print( Provider.of<StyleProvider>(context, listen: false).invoiceItems);


                                        showDialog(context: context, builder: (BuildContext context){
                                          return
                                            GestureDetector(
                                              onTap: (){
                                                Navigator.pop(context);
                                              },
                                              child:
                                              TransactionWidget(clientList: clientList, clientPhoneList: clientPhoneList, priceList: priceList, paidAmountList: paidAmountList,
                                                transIdList: transIdList, smsList: smsList, dateList: dateList, customerIdList: customerIdList,
                                                paymentDueDateList: paymentDueDateList, storeName: storeName, location: location, phoneNumber: phoneNumber,
                                                clientLocationList: clientLocationList, logo: logo, index: index,currency: currencyList, paymentHistory: paymentHistoryList,),
                                            );
                                        });

                                      },
                                      child: Card(
                                        margin: const EdgeInsets.fromLTRB(0.0, 8.0, 0.0, 8.0),
                                        shape: RoundedRectangleBorder(borderRadius:BorderRadius.circular(10)),
                                        shadowColor: kAppPinkColor,
                                        elevation: 0.0,
                                        child: Column(
                                          children: [

                                            ListTile(


                                              title:Row(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                children: [
                                                  priceList[index]!= paidAmountList[index]?Icon(Icons.flag_circle,color: Colors.red, size: 15,):Icon(Icons.check_circle_outline,color: kGreenThemeColor, size: 15,),
                                                  kSmallWidthSpacing,
                                                  Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    children: [
                                                      Text( "${productList[index][0]['product']}",overflow: TextOverflow.clip, style: TextStyle(fontFamily: fontFamilyMont,fontSize: 15)),
                                                      Text(clientList[index], style: kNormalTextStyle.copyWith(fontSize: 14,color: kBlack),),
                                                      paidAmountList[index]!= 0?Text("${paymentMethodList[index]}", style: TextStyle(color: kGreenThemeColor, fontSize: 12),):Container(),
                                                      Text('${DateFormat('h:mm a').format(dateList[index])}', style: kNormalTextStyle.copyWith(fontSize: 11),),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              trailing: Padding(
                                                padding: const EdgeInsets.only(right: 10, top: 20),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.end,
                                                  children: [
                                                    Text("${CommonFunctions().formatter.format(priceList[index])} ${currencyList[index]}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),),
                                                    // If price list is not equal to the paid amount
                                                    priceList[index]!= paidAmountList[index] ?
                                                    // If the amount paid is not equal to zeto
                                                    paidAmountList[index]!= 0 ?
                                                    paidAmountList[index]>= priceList[index] ?
                                                    Text("Overpaid ${CommonFunctions().formatter.format(paidAmountList[index])} ${currencyList[index]}", style: TextStyle(color: Colors.blue, fontSize: 12),):
                                                    Text("Partial ${CommonFunctions().formatter.format(paidAmountList[index])} ${currencyList[index]}", style: TextStyle(color: Colors.red, fontSize: 12),):
                                                    Text("No Payment Recieved", style: TextStyle(color: kCustomColorPink, fontSize: 12),): Text("Paid",  style: TextStyle(color: kGreenThemeColor, fontSize: 12))

                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                );

                              }
                          ),
                        ),

                        // const Text("Today's Last 4 Transactions",style: kNormalTextStyle,),
                      ],
                    );
                  }

                }

            ),
          ),
        ],
      )
  );
  }
  Widget _buildButton(BuildContext context, String title, IconData icon, Function() execute) {
    return GestureDetector(
      onTap: execute,
      child: Column(

        children: [
          TicketDots(mainColor: kBlack, circleColor: kPureWhiteColor, ),
          Row(
            children: [
              Icon(icon),
              kMediumWidthSpacing,
              Text(title, style: kNormalTextStyle.copyWith(color: kBlack, fontSize: 16),),
            ],
          ),
        ],
      ),
    );
  }
}



