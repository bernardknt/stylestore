
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
import 'package:stylestore/utilities/constants/icon_constants.dart';

import '../../Utilities/constants/color_constants.dart';
import '../../model/beautician_data.dart';
import '../../widgets/build_info_card.dart';
import '../../widgets/customer_content.dart';
import '../../widgets/rounded_icon_widget.dart';
import 'customer_edit_page.dart';
import 'customer_transactions_web.dart';






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
  var paidAmountList = [];
  var priceList = [];
  var currencyList = [];
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
    backgroundColor: kPlainBackground,
    appBar: AppBar(
      title: Text("${Provider.of<BeauticianData>(context, listen: false).clientName}'s buying History", style: kNormalTextStyle.copyWith(color: kBlack, fontWeight: FontWeight.bold),),
      backgroundColor: kPlainBackground,
      foregroundColor: kBlack,
      centerTitle: true,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 18.0),
          child: GestureDetector(
            onTap: (){
              CommonFunctions().callPhoneNumber(Provider.of<BeauticianData>(context, listen: false).customerPhoneNumber);
            },
            child: Icon(Icons.call, color: kAppPinkColor,),
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
              paidAmountList = [];
              currencyList = [];

              var dateSeparator = '';
              var orders = snapshot.data?.docs;
              for( var doc in orders!){

                if(doc.get('instructions')=='Product' ){
                  productList.add(doc['items']);
                  priceList.add(doc['totalFee']);
                  paidAmountList.add(doc['paidAmount']);
                  descList.add(doc['instructions']);
                  transIdList.add(doc['appointmentId']);
                  currencyList.add(doc['currency']);
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
              return productList.isEmpty?Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Lottie.asset("images/empty.json", height: 100),
                    Text("No items bought by\n${Provider.of<BeauticianData>(context, listen: false).clientName}",textAlign: TextAlign.center, style: kNormalTextStyle.copyWith(color: kBlack),)
                  ],
                ),
              ):
              Column(
                children: [
                  Container(
                    width: 450,
                    color: kPlainBackground,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        GestureDetector(
                          onTap: (){
                            showModalBottomSheet(
                                isScrollControlled: true,
                                context: context,
                                builder: (context) {
                                  return Scaffold(
                                      appBar: AppBar(
                                        backgroundColor: kPureWhiteColor,
                                        automaticallyImplyLeading: false,
                                        elevation: 0,
                                      ),
                                      body:  CustomerEditPage());
                                });
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(

                              decoration: BoxDecoration(
                                  color: kPureWhiteColor,
                                  borderRadius: BorderRadius.circular(10)
                              ),
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        // RoundImageRing(radius: 80,networkImageToUse:
                                        // Provider.of<BeauticianData>(context,listen: false).customerImage
                                        //     , outsideRingColor: kBackgroundGreyColor),
                                        CircleAvatar(
                                          radius: 40,
                                          backgroundColor: kAppPinkColor.withOpacity(0.1),
                                          child:  Icon(Icons.person, size: 40,),
                                        ),
                                        kMediumWidthSpacing,
                                        kMediumWidthSpacing,
                                        Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            CustomerTag(iconToUse: Icon(Icons.person, size: 20,), value: Provider.of<BeauticianData>(context,listen: false).customerName,),
                                            kSmallHeightSpacing,
                                            CustomerTag(iconToUse: Icon(Icons.location_on, size: 20,), value: Provider.of<BeauticianData>(context,listen: false).customerLocation,),
                                            kSmallHeightSpacing,
                                            CustomerTag(iconToUse: Icon(Icons.phone, size: 20,), value: Provider.of<BeauticianData>(context,listen: false).customerPhoneNumber,),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(

                            decoration: BoxDecoration(
                                color: kPureWhiteColor,
                                borderRadius: BorderRadius.circular(10)
                            ),
                            child: Column(
                              children: [
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      buildInfoCard(title: "Total Bought", value: CommonFunctions().formatter.format(CommonFunctions().calculateTotalPrice(priceList)), cardColor: kBlueThemeColor, cardIcon: Icons.monetization_on_outlined, fontSize: 14),

                                       buildInfoCard(title: "Received Payment", value:CommonFunctions().formatter.format(CommonFunctions().calculateTotalPrice(paidAmountList)), cardColor: kGreenThemeColor,  cardIcon: Iconsax.money5, fontSize: 14),

                                      buildInfoCard(title: "Pending Payment", value:CommonFunctions().formatter.format(CommonFunctions().calculateTotalPrice(priceList)- CommonFunctions().calculateTotalPrice(paidAmountList)), cardColor: kRedColor,  cardIcon: Iconsax.stop, fontSize: 14),

                                      buildInfoCard(title: "Last Purchase", value: productList[0][0]['product'].toString(), cardColor: kBlack,  cardIcon: Icons.curtains_closed_sharp, fontSize: 14),

                                      buildInfoCard(title: "No of Orders", value: productList.length.toString(), cardColor: kYellowThemeColor,  cardIcon: Icons.check_box, fontSize: 14),

                                    ],
                                  ),
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [

                                  ],
                                ),
                                // Row(
                                //   crossAxisAlignment: CrossAxisAlignment.start,
                                //   mainAxisAlignment: MainAxisAlignment.start,
                                //   children: [
                                //
                                //     buildInfoCard(title: "Total Received", value:CommonFunctions().formatter.format(CommonFunctions().calculateTotalPrice(paidAmountList)), cardColor: kGreenThemeColor,  cardIcon: Iconsax.money5, fontSize: 14),
                                //     kSmallWidthSpacing,
                                //     buildInfoCard(title: "Pending Payment", value:CommonFunctions().formatter.format(CommonFunctions().calculateTotalPrice(priceList)- CommonFunctions().calculateTotalPrice(paidAmountList)), cardColor: kRedColor,  cardIcon: Iconsax.stop, fontSize: 14),
                                //
                                //   ],
                                // ),


                              ],
                            ),

                          ),
                        ),
                      ],
                    ),
                  ),
                  kSmallHeightSpacing,
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        decoration: BoxDecoration(
                            color: kPureWhiteColor,
                            borderRadius: BorderRadius.circular(10)
                        ),
                        child: Column(
                          children: [
                            // Padding(
                            //   padding: const EdgeInsets.all(20.0),
                            //   child: Text("Purchase History", style: kNormalTextStyle.copyWith(color: kBlack, fontWeight: FontWeight.bold) ),
                            // ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
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
                                          Padding(
                                            padding: const EdgeInsets.only(top:8.0),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                  color: kBabyPinkThemeColor.withOpacity(0.3),
                                                  borderRadius: BorderRadius.circular(10)
                                              ),

                                              child: Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: Column(
                                                  children: [

                                                    ListTile(
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

                                                          }),
                                                      leading: priceList[index] - paidAmountList[index] == 0?
                                                      kIconPaidIcon:kIconNotPaidIcon,
                                                      trailing: Padding(
                                                        padding: const EdgeInsets.only(right: 10, top: 20),
                                                        child: Text("${CommonFunctions().formatter.format(priceList[index])} ${currencyList[index]}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),),
                                                      ),
                                                    ),

                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      );

                                    }
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
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



