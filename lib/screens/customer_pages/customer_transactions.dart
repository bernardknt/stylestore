
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

import '../../Utilities/constants/color_constants.dart';
import '../../model/beautician_data.dart';
import '../../widgets/customer_content.dart';






class CustomerTransactionsProducts extends StatefulWidget {
  static String id = 'customer_products_orders_page';

  @override
  _CustomerTransactionsProductsState createState() => _CustomerTransactionsProductsState();
}

class _CustomerTransactionsProductsState extends State<CustomerTransactionsProducts> {
  // final dateNow = new DateTime.now();
  late int price = 0;
  late int quantity = 1;
  DateTime? _previousDate;
  var formatter = NumberFormat('#,###,000');





  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print("ID IS THIS: ${Provider.of<StyleProvider>(context, listen: false).beauticianId}");

  }

  var productList = [];
  var orderStatusList = [];
  var clientList = [];
  var priceList = [];
  var descList = [];
  var transIdList = [];
  var dateList = [];
  var paidStatusList = [];
  var paidStatusListColor = [];
  List<double> opacityList = [];

  double textSize = 12.0;
  String fontFamilyMont = 'Montserrat-Medium';
  @override
  Widget build(BuildContext context) {double width = MediaQuery.of(context).size.width * 0.6;
  // var blendedData = Provider.of<BlenditData>(context);

  return Scaffold(
    appBar: AppBar(
      title: Text("${Provider.of<BeauticianData>(context, listen: false).clientName}'s buying History", style: kNormalTextStyle.copyWith(color: kPureWhiteColor),),
      backgroundColor: kAppPinkColor,
      foregroundColor: kPureWhiteColor,
      centerTitle: true,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 18.0),
          child: GestureDetector(
            onTap: (){
              CommonFunctions().callPhoneNumber(Provider.of<BeauticianData>(context, listen: false).customerPhoneNumber);
            },
            child: Icon(Icons.call, color: kPureWhiteColor,),
          ),
        )
      ],
    ),


      body:
      StreamBuilder<QuerySnapshot> (
          stream: FirebaseFirestore.instance
              .collection('appointments')
              .where('beautician_id', isEqualTo: Provider.of<StyleProvider>(context, listen: false).beauticianId)
              .where('customerId', isEqualTo: Provider.of<BeauticianData>(context, listen: false).clientId)

              .orderBy('appointmentDate',descending: true)
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

              var dateSeparator = '';
              var orders = snapshot.data?.docs;
              for( var doc in orders!){

                if(doc.get('instructions')=='Product' ){
                  productList.add(doc['items']);
                  priceList.add(doc['totalFee']);
                  descList.add(doc['instructions']);
                  transIdList.add(doc['appointmentId']);
                  orderStatusList.add(doc['status']);
                  dateList.add(doc['appointmentDate'].toDate());
                  clientList.add(doc['client']);

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
                }

              }
              // return Text('Let us understand this ${deliveryTime[3]} ', style: TextStyle(color: Colors.white, fontSize: 25),);
              return

                productList.isEmpty?Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Lottie.asset("images/empty.json", height: 100),
                      Text("No items bought by\n${Provider.of<BeauticianData>(context, listen: false).clientName}",textAlign: TextAlign.center, style: kNormalTextStyle.copyWith(color: kBlack),)
                    ],
                  ),
                ):Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text("Total: Ugx ${CommonFunctions().formatter.format(CommonFunctions().calculateTotalPrice(priceList))}", style: kNormalTextStyle.copyWith(color: kBlack) ),
                    ),
                    Expanded(
                      child: ListView.builder(
                      shrinkWrap: true,
                        itemCount: productList.length,

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
                                  style: kNormalTextStyle.copyWith( fontSize: 13),
                                ),
                                SizedBox(height: 10),
                              ],
                              Card(
                                margin: const EdgeInsets.fromLTRB(25.0, 8.0, 25.0, 8.0),
                                shape: RoundedRectangleBorder(borderRadius:BorderRadius.circular(10)),
                                shadowColor: kAppPinkColor,
                                elevation: 1.0,
                                child: Column(
                                  children: [

                                    ListTile(
                                      // leading: const Icon(Iconsax.buildings, color: kBlueDarkColorOld,size: 25,),
                                      title:
                                      ListView.builder(
                                          physics: NeverScrollableScrollPhysics(),
                                          shrinkWrap: true,
                                          itemCount: productList[index].length,
                                          itemBuilder: (context, i){
                                            return CustomerContentsWidget(
                                                orderIndex: i + 1,
                                                optionName: productList[index][i]['product'],
                                                optionValue: productList[index][i]['quantity'].toInt().toString()
                                            );

                                            // OrderedContentsWidget(
                                            //   orderIndex: i + 1,
                                            //   productDescription: '1',
                                            //   productName: items[index].keys.toList()[i],
                                            //   price:items[index].values.toList()[i]
                                            //   );
                                          }),
                                      //Text( "${productList[index][0]['description']}", style: TextStyle(fontFamily: fontFamilyMont,fontSize: textSize)),
                                      trailing: Padding(
                                        padding: const EdgeInsets.only(right: 10, top: 20),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Text("${CommonFunctions().formatter.format(priceList[index])}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),),
                                            const Text('Ugx', style: TextStyle(color: kGreenThemeColor, fontSize: 12),)
                                          ],
                                        ),
                                      ),
                                      // horizontalTitleGap: 0,Ugx


                                      // minVerticalPadding: 0,
                                    ),
                                    Stack(
                                        children: [ListTile(
                                          onTap: (){
                                          },

                                          title:Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text('${DateFormat('EE, dd, MMM, hh:mm a').format(dateList[index])}', style: kNormalTextStyle.copyWith(fontSize: 12),),
                                              Text('Client:  ${clientList[index]}', style: kNormalTextStyle.copyWith(fontSize: 13)),
                                              // Text("Payment: ${paidStatusList[index]}", style: TextStyle( color: paidStatusListColor[index], fontSize: 12),),
                                              //
                                            ],
                                          ),
                                        ),

                                        ]),

                                    //_buildDivider(),
                                  ],
                                ),
                              ),
                            ],
                          );

                        }
              ),
                    ),
                  ],
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



