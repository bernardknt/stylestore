
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:stylestore/Utilities/constants/font_constants.dart';
import 'package:stylestore/model/common_functions.dart';
import 'package:stylestore/model/styleapp_data.dart';
import '../utilities/constants/color_constants.dart';
import '../utilities/constants/user_constants.dart';





class TransactionsOnlinePage extends StatefulWidget {
  static String id = 'online_orders_page';

  @override
  _TransactionsOnlinePageState createState() => _TransactionsOnlinePageState();
}

class _TransactionsOnlinePageState extends State<TransactionsOnlinePage> {
  // final dateNow = new DateTime.now();
  late int price = 0;
  late int quantity = 1;
  var formatter = NumberFormat('#,###,000');





  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print(Provider.of<StyleProvider>(context, listen: false).beauticianId);

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

      body:
      StreamBuilder<QuerySnapshot> (
          stream: FirebaseFirestore.instance
              .collection('appointments').where('beautician_id', isEqualTo: Provider.of<StyleProvider>(context, listen: false).beauticianId)
              .orderBy('appointmentDate',descending: true)
              .snapshots(),
          builder: (context, snapshot)
          {
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


              var orders = snapshot.data?.docs;
              for( var doc in orders!){

                if(doc.get('paymentStatus')!='offline'&& doc.get('paymentStatus')!='pending' ){
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
              return ListView.builder(
                  itemCount: productList.length,
                  itemBuilder: (context, index){
                    return Card(
                      margin: const EdgeInsets.fromLTRB(25.0, 8.0, 25.0, 8.0),
                      shape: RoundedRectangleBorder(borderRadius:BorderRadius.circular(10)),
                      shadowColor: kAppPinkColor,
                      elevation: 2.0,
                      child: Column(
                        children: [

                          ListTile(
                            leading: const Icon(Iconsax.buildings, color: kBlueDarkColorOld,size: 25,),
                            title:Text( "${productList[index][0]['description']}...", style: TextStyle(fontFamily: fontFamilyMont,fontSize: textSize)),
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
                                    Text('${DateFormat('EE, dd, MMM').format(dateList[index])}', style: kNormalTextStyle.copyWith(fontSize: 12),),
                                    Text('Client:  ${clientList[index]}', style: kNormalTextStyle.copyWith(fontSize: 13)),
                                    Text("Payment: ${paidStatusList[index]}", style: TextStyle( color: paidStatusListColor[index], fontSize: 12),),
                                  ],
                                ),
                                trailing: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text("id: ${transIdList[index]}", style: TextStyle( color: Colors.grey[500], fontSize: 12),),

                                  ],
                                ),
                              ),

                              ]),

                          //_buildDivider(),
                        ],
                      ),
                    );}
              );
            }

          }

      )
  );
  }
}



