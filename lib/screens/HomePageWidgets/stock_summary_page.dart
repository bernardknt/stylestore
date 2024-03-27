
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
import 'package:stylestore/widgets/TicketDots.dart';
import '../../Utilities/constants/color_constants.dart';
import '../../model/beautician_data.dart';
import '../../widgets/locked_widget.dart';
import '../products_pages/restock_page.dart';
import '../products_pages/update_stock.dart';

class StockSummaryPage extends StatefulWidget {
  static String id = 'summary';

  @override
  _StockSummaryPageState createState() => _StockSummaryPageState();
}

class _StockSummaryPageState extends State<StockSummaryPage> {
  late int price = 0;
  late int quantity = 1;
  DateTime? _previousDate;
  var storeName = "";
  var location = "";
  var phoneNumber = "";
  var formatter = NumberFormat('#,###,000');
  var dateSeparator = '';
  Map<String, dynamic> permissionsMap = {};

  void defaultInitialization()async{
    var prefs = await SharedPreferences.getInstance();
    permissionsMap = await CommonFunctions().convertPermissionsJson();
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

  var amountList = [];
  var quantityList = [];
  var storeIdList = [];
  var descList = [];
  var imgList = [];
  var minimumList = [];
  var nameList = [];
  var saleableList = [];
  var trackingList = [];





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

      body:
      permissionsMap['tasks'] == false ? LockedWidget(page: "Tasks"):StreamBuilder<QuerySnapshot> (
          stream: FirebaseFirestore.instance.collection('stores')
              .where('storeId', isEqualTo: Provider
              .of<StyleProvider>(context, listen: false)
              .beauticianId)
              .where('active', isEqualTo: true)
              .where('tracking', isEqualTo: true)
              .orderBy('name', descending: false).limit(5)
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
            if (!snapshot.hasData) {} else {
              amountList = [];
              quantityList = [];
              descList = [];
              imgList = [];
              nameList = [];
              saleableList = [];
              trackingList = [];
              minimumList = [];

              storeIdList = [];

              var appointments = snapshot.data!.docs;
              for (var appointment in appointments) {
                if (appointment.get('minimum') > appointment.get('quantity')){
                  descList.add(appointment.get('description'));
                  saleableList.add(appointment.get('saleable'));
                  trackingList.add(appointment.get('tracking'));
                  imgList.add(appointment.get('image'));
                  nameList.add(appointment.get('name'));
                  storeIdList.add(appointment.get('id'));
                  amountList.add(appointment.get('amount'));
                  quantityList.add(appointment.get('quantity'));
                  minimumList.add(appointment.get('minimum'));
                } else {

                }

              }
            }
            return Column(
              children: [
                kSmallHeightSpacing,
                nameList.length >= 0 ? Text("Out of Stock Items",style: kNormalTextStyle,):  Text("All Stock is Upto Date",style: kNormalTextStyle,),
                kSmallHeightSpacing,
                Expanded(
                  child: ListView.builder(
                      itemCount: nameList.length,
                      shrinkWrap: true,
                      primary: false,

                      itemBuilder: (context, index){
                        // }
                        return Column(

                          children: [
                            GestureDetector(
                            onTap: () async {
                          final prefs = await SharedPreferences.getInstance();
                          Provider.of<BeauticianData>(context, listen: false)
                              .setStoreId(prefs.getString(kStoreIdConstant));

                          // Navigator.pushNamed(context, ReStockPage.id);
                          showDialog(context: context,
                              barrierLabel: 'Appointment',
                              builder: (context) {
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                  child: Material(
                                    color: Colors.transparent,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Center(child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [

                                            Column(
                                              children: [
                                                GestureDetector(
                                                  onTap: () {
                                                    Navigator.pop(context);

                                                    Navigator.pushNamed(
                                                        context, UpdateStockPage.id);
                                                  },
                                                  child: CircleAvatar(
                                                      radius: 30,
                                                      backgroundColor: kCustomColor
                                                          .withOpacity(1),
                                                      child: const Icon(
                                                        Iconsax.box, color: kBlack,
                                                        size: 20,)),
                                                ),
                                                Text("Update / Check\nStock",
                                                  textAlign: TextAlign.center,
                                                  style: kNormalTextStyle.copyWith(
                                                      color: kPureWhiteColor,
                                                      fontSize: 12),)
                                              ],
                                            ),
                                            kMediumWidthSpacing,
                                            kMediumWidthSpacing,
                                            kMediumWidthSpacing,
                                            Column(
                                              children: [
                                                GestureDetector(
                                                  onTap: () {
                                                    Navigator.pop(context);
                                                    Navigator.pushNamed(
                                                        context, ReStockPage.id);
                                                  },
                                                  child: CircleAvatar(
                                                      backgroundColor: kCustomColorPink
                                                          .withOpacity(1),

                                                      radius: 30,
                                                      child: const Icon(Iconsax.tag,
                                                        color: kPureWhiteColor,
                                                        size: 20,)),
                                                ),
                                                Text("Restock / Purchase\nItems",
                                                  textAlign: TextAlign.center,
                                                  style: kNormalTextStyle.copyWith(
                                                      color: kPureWhiteColor,
                                                      fontSize: 12),)
                                              ],
                                            ),

                                          ],
                                        )),
                                        kLargeHeightSpacing,
                                        kLargeHeightSpacing,
                                        kLargeHeightSpacing,
                                        kLargeHeightSpacing,
                                        kLargeHeightSpacing,
                                        kLargeHeightSpacing,
                                        kLargeHeightSpacing,
                                        Text("Cancel",
                                          style: kNormalTextStyle.copyWith(
                                              color: kPureWhiteColor),)
                                      ],
                                    ),
                                  ),
                                );
                              }
                          );
                        },

                              child: Card(
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
                                          kSmallWidthSpacing,
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              Text( "${nameList[index]}",overflow: TextOverflow.clip, style: kNormalTextStyle.copyWith() ),
                                              Text(descList[index],overflow: TextOverflow.ellipsis, style: kNormalTextStyle.copyWith(fontSize: 14),),
                                              // Text('${DateFormat('d/MMM hh:mm a').format(dateList[index])}', style: kNormalTextStyle.copyWith(fontSize: 11),),
                                            ],
                                          ),
                                        ],
                                      ),
                                      trailing: Padding(
                                        padding: const EdgeInsets.only(right: 10, top: 20),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            Text("Qty: ${quantityList[index]}", style: kNormalTextStyle.copyWith(color: Colors.red),),
                                          ],
                                        )
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
                kSmallHeightSpacing,
                nameList.length >= 4 ? GestureDetector(onTap: (){ Navigator.pushNamed(context, UpdateStockPage.id); }, child: Text("See all Items",style: kNormalTextStyle.copyWith(color: Colors.blue),)):  Text("No Transactions Today",style: kNormalTextStyle,),
                // const Text("Today's Last 4 Transactions",style: kNormalTextStyle,),
              ],
            );
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
}



