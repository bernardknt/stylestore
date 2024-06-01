


import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stylestore/Utilities/constants/font_constants.dart';
import 'package:stylestore/Utilities/constants/user_constants.dart';
import 'package:stylestore/model/styleapp_data.dart';
import 'package:stylestore/widgets/TicketDots.dart';
import '../../Utilities/constants/color_constants.dart';


class StockHistoryPage extends StatefulWidget {
  static String id = 'stock_history';

  @override
  _StockHistoryPageState createState() => _StockHistoryPageState();
}

class _StockHistoryPageState extends State<StockHistoryPage> {
  late int price = 0;
  late int quantity = 1;
  DateTime? _previousDate;
  var storeName = "";
  var location = "";
  var phoneNumber = "";
  var formatter = NumberFormat('#,###,000');

  void defaultInitialization()async{
    var prefs = await SharedPreferences.getInstance();
    storeName = prefs.getString(kBusinessNameConstant)!;
    location = prefs.getString(kLocationConstant)!;
    phoneNumber = prefs.getString(kPhoneNumberConstant)!;
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
  var activityList = [];
  var createdByList = [];
  var listOProducts = [];
  var transIdList = [];
  var dateList = [];
  var paidStatusList = [];
  var paidStatusListColor = [];
  List<double> opacityList = [];

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  double textSize = 14.0;
  String fontFamilyMont = 'Montserrat-Medium';
  @override
  Widget build(BuildContext context) {double width = MediaQuery.of(context).size.width * 0.6;
  var styleData = Provider.of<StyleProvider>(context, listen: false);

  return Scaffold(
      backgroundColor: kPureWhiteColor,
      appBar: AppBar(
        title: Text("Stock History", style: kNormalTextStyle.copyWith(fontWeight: FontWeight.bold, color: kBlack),),
        backgroundColor: kPureWhiteColor,
        elevation: 0,
        centerTitle: true,
      ),


      body:
      StreamBuilder<QuerySnapshot> (
          stream: FirebaseFirestore.instance
              .collection('purchases').where('storeId', isEqualTo:
          Provider.of<StyleProvider>(context, listen: false).beauticianId

          )
              .orderBy('date',descending: true).limit(40)
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
              activityList = [];
              transIdList = [];
              dateList = [];
              createdByList = [];



              var dateSeparator = '';
              var orders = snapshot.data?.docs;
              for( var doc in orders!){

                // if( isSameDay(doc['appointmentDate'].toDate(),DateTime.now())){
                if(doc['activity']!="Expense") {
                  productList.add(doc['items']);
                  transIdList.add(doc['id']);
                  activityList.add(doc['activity']);
                  dateList.add(doc['date'].toDate());
                  createdByList.add(doc['requestBy']);
                  List dynamicList = doc['items'];
                  var array = [];
                  for (var i = 0; i < doc['items'].length; ++i){


                    // print("${dynamicList[i]['product']}");
                    array.add(dynamicList[i]['product']) ;
                  }
                  listOProducts.add(array);
                  print("${listOProducts}");
                }


              }

              return Column(
                children: [
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
                                  _getDateSeparator(transactionDate),
                                  style: kNormalTextStyle.copyWith(color: kFontGreyColor, fontSize: 13),
                                ),
                                SizedBox(height: 10),
                              ],
                              Card(
                                  margin: const EdgeInsets.fromLTRB(25.0, 8.0, 25.0, 8.0),
                                  shape: RoundedRectangleBorder(borderRadius:BorderRadius.circular(10)),
                                  shadowColor: kAppPinkColor,
                                  elevation: 0.0,
                                  child: Column(
                                    children: [

                                      ListTile(


                                        title:Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            // priceList[index]!= paidAmountList[index]?Icon(Icons.flag_circle,color: Colors.red, size: 15,):Container(),
                                            kSmallWidthSpacing,

                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisAlignment: MainAxisAlignment.start,

                                              children: [
                                                Text( "${productList[index].length} Items ${activityList[index]}",overflow: TextOverflow.clip, style: TextStyle(fontFamily: fontFamilyMont,fontSize: textSize, fontWeight: FontWeight.bold)),
                                                Container(
                                                    width: 200,
                                                    child:
                                                    Text( "${listOProducts[index].join(", ")}",overflow: TextOverflow.fade, style: TextStyle(fontFamily: fontFamilyMont,fontSize: textSize))),
                                                //Text( "${listOfItems[index]}",overflow: TextOverflow.clip, style: TextStyle(fontFamily: fontFamilyMont,fontSize: textSize)),
                                                Text("Recorded by: ${createdByList[index]}", style: kNormalTextStyle.copyWith(fontSize: 12),),
                                                Text('${DateFormat('d/MMM hh:mm a').format(dateList[index])}', style: kNormalTextStyle.copyWith(fontSize: 11),),
                                              ],
                                            ),
                                          ],
                                        ),
                                        trailing: Text( "${activityList[index]}",overflow: TextOverflow.clip, style: TextStyle(fontFamily: fontFamilyMont,fontSize: 14, color: kGreenThemeColor)),
                                      ),
                                    ],
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



