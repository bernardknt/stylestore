


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
import 'package:stylestore/screens/expenses_pages/add_expense_widget.dart';
import 'package:stylestore/screens/expenses_pages/edit_expense.dart';
import 'package:stylestore/widgets/TicketDots.dart';
import '../../Utilities/InputFieldWidget.dart';
import '../../Utilities/constants/color_constants.dart';
import '../../model/beautician_data.dart';
import '../../widgets/custom_popup.dart';
import '../../widgets/locked_widget.dart';
import '../customer_pages/add_customers_page.dart';
import '../payment_pages/record_payment_widget.dart';
import '../products_pages/products_upload.dart';
import '../products_pages/restock_page.dart';


class ExpensesPage extends StatefulWidget {
  static String id = 'expenses';

  @override
  _ExpensesPageState createState() => _ExpensesPageState();
}

class _ExpensesPageState extends State<ExpensesPage> {
  late int price = 0;
  late int quantity = 1;
  DateTime? _previousDate;
  var storeName = "";
  var location = "";
  var phoneNumber = "";
  var detailValue = "";
  var detailName = "";
  var formatter = NumberFormat('#,###,000');
  Map<String, dynamic> permissionsMap = {};
  Map<String, dynamic> videoMap = {};

  void defaultInitialization()async{
    var prefs = await SharedPreferences.getInstance();
    permissionsMap = await CommonFunctions().convertPermissionsJson();
    videoMap = await CommonFunctions().convertWalkthroughVideoJson();
    storeName = prefs.getString(kBusinessNameConstant)!;
    location = prefs.getString(kLocationConstant)!;
    phoneNumber = prefs.getString(kPhoneNumberConstant)!;
    setState(() {
    });
  }
  Future<void> updatePurchasesWithSupplierId() async {
    // Get a reference to the 'purchases' collection
    CollectionReference purchasesCollection = FirebaseFirestore.instance.collection('purchases');

    // Get all documents in the 'purchases' collection
    QuerySnapshot querySnapshot = await purchasesCollection.get();

    // Loop through each document
    for (var doc in querySnapshot.docs) {
      // Update the document with the 'supplierId' field
      await doc.reference.update({
        'paid':true
      });
    }
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
  var supplierList = [];
  var paidList = [];
  var listOfProducts = [];
  var listOfPriceOfProducts = [];

  var priceOfProducts = [];
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
        title: Text("Expenses", style: kNormalTextStyle.copyWith(fontWeight: FontWeight.bold, color: kBlack),),
        backgroundColor: kPureWhiteColor,
        elevation: 0,
        centerTitle: true,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniCenterFloat,
      floatingActionButton: permissionsMap['expenses'] == false ?Container(): FloatingActionButton(

          backgroundColor: kAppPinkColor,
          onPressed: (){
            // add Ingredient Here
            // updatePurchasesWithSupplierId();

            Provider.of<StyleProvider>(context, listen: false).resetCustomerUploadItem();
            // Navigator.pushNamed(context, AddCustomersPage.id);
            showDialog(context: context, builder: (BuildContext context){
              return
                GestureDetector(
                  onTap: (){
                    Navigator.pop(context);
                  },
                  child:
                  Material(
                    color: Colors.transparent,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("ADD A NEW EXPENSE", textAlign: TextAlign.center,style: kNormalTextStyle.copyWith(fontSize:14,color: kPureWhiteColor, fontWeight: FontWeight.bold),),
                        kLargeHeightSpacing,
                        kLargeHeightSpacing,
                        kLargeHeightSpacing,
                        kLargeHeightSpacing,
                        kLargeHeightSpacing,
                        Center(child:

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [

                            Column(
                              children: [
                                GestureDetector(
                                  onTap: () async{
                                    final prefs = await SharedPreferences.getInstance();

                                    Provider.of<BeauticianData>(context, listen: false).setStoreId(prefs.getString(kStoreIdConstant));
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
                            kMediumWidthSpacing,
                            kMediumWidthSpacing,
                            kMediumWidthSpacing,

                            Column(
                              children: [
                                GestureDetector(
                                  onTap: (){
                                    Navigator.pop(context);

                                    showModalBottomSheet(
                                        context: context,
                                        isScrollControlled: true,
                                        builder: (context) {
                                          return Scaffold(
                                              appBar: AppBar(
                                                automaticallyImplyLeading: false,
                                                backgroundColor: kPureWhiteColor,
                                                elevation: 0,
                                              ),
                                              body: AddExpenseWidget());
                                        });


                                  },
                                  child: CircleAvatar(
                                      radius: 30,
                                      backgroundColor: kCustomColor.withOpacity(1),
                                      child: const Icon(Iconsax.calculator, color: kBlack,size: 30,)),
                                ),
                                Text("Add Expense\nManually",textAlign: TextAlign.center, style: kNormalTextStyle.copyWith(color: kPureWhiteColor, fontSize: 12),)
                              ],
                            ),

                          ],
                        )),
                      ],
                    ),
                  ),
                );
            });
          },
          child: Icon(CupertinoIcons.add, color: kPureWhiteColor,)
      ),


      body: permissionsMap['expenses'] == false ? LockedWidget(page: "Expenses",): StreamBuilder<QuerySnapshot> (
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
              return const Center(
                child: CircularProgressIndicator(color: kAppPinkColor,),
              );
            }
            if (!snapshot.hasData) {
              return Container(
                color: Colors.white,
              );
            }else{

              productList = [];
              activityList = [];
              transIdList = [];
              dateList = [];
              createdByList = [];
              listOfPriceOfProducts = [];
              supplierList = [];
              paidList  = [];



              var dateSeparator = '';
              var orders = snapshot.data?.docs;
              for( var doc in orders!){

                // if( isSameDay(doc['appointmentDate'].toDate(),DateTime.now())){
                if (doc['activity']== 'Restocked'||doc['activity'] == 'Expense') {
                  productList.add(doc['items']);
                  transIdList.add(doc['id']);
                  supplierList.add(doc['supplier']);
                  paidList .add(doc['paid']);
                  dateList.add(doc['date'].toDate());
                  createdByList.add(doc['requestBy']);
                  List dynamicList = doc['items'];

                  if(doc['activity'] == "Restocked") {
                    activityList.add("Purchased");
                  } else {
                    activityList.add(doc['activity']);
                  }
                  var array = [];
                  List<double> prices = [];
                  for (var i = 0; i < doc['items'].length; ++i){


                    // print("${dynamicList[i]['product']}");
                    array.add(dynamicList[i]['product']) ;
                    prices.add(dynamicList[i]['totalPrice']/1.0) ;
                    listOfPriceOfProducts.add(dynamicList[i]['totalPrice']) ;


                  }
                  listOfProducts.add(array);
                  priceOfProducts.add(CommonFunctions().sumArrayElements(prices));
                  print("${listOfProducts}");
                }


              }

              return
                productList.isEmpty?

                CustomPopupWidget(backgroundColour: kBlueDarkColor,actionButton: 'Add Expense', subTitle: 'No matter how small', image: 'expense.jpg', title: 'Track Every Expense', function:
                    () {

                      showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (context) {
                            return Scaffold(
                                appBar: AppBar(
                                  automaticallyImplyLeading: false,
                                  backgroundColor: kPureWhiteColor,
                                  elevation: 0,
                                ),
                                body: AddExpenseWidget());
                          });
                }, youtubeLink: videoMap['expenses']
                  ,
                ):
                Column(
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
                              GestureDetector(
                                onTap: (){
                                  Provider.of<StyleProvider>(context, listen: false).setInvoicedValues(priceOfProducts[index][index].toDouble(), priceOfProducts[index][index].toDouble(),createdByList[index], transIdList[index], [], "", dateList[index],  priceOfProducts[index].toDouble() - priceOfProducts[index].toDouble(), transIdList[index]);


                                  showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      builder: (context) {
                                        return Scaffold(
                                            appBar: AppBar(
                                              automaticallyImplyLeading: false,
                                              backgroundColor: kPureWhiteColor,
                                              elevation: 0,
                                            ),
                                            body: EditExpensePage());
                                      });
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
                                            // priceList[index]!= paidAmountList[index]?Icon(Icons.flag_circle,color: Colors.red, size: 15,):Container(),
                                            kSmallWidthSpacing,

                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisAlignment: MainAxisAlignment.start,

                                              children: [
                                                Text( "${productList[index].length} Items ${activityList[index]}",overflow: TextOverflow.clip, style: TextStyle(fontFamily: fontFamilyMont,fontSize: textSize, fontWeight: FontWeight.bold)),
                                                Container(
                                                    width: 200,
                                                    child: Text( "${listOfProducts[index].join(", ")}",overflow: TextOverflow.fade, style: TextStyle(fontFamily: fontFamilyMont,fontSize: textSize))),
                                                //Text( "${listOfItems[index]}",overflow: TextOverflow.clip, style: TextStyle(fontFamily: fontFamilyMont,fontSize: textSize)),
                                                Text("Supplier:${supplierList[index]}", style: kNormalTextStyle.copyWith(fontSize: 12),),
                                                Text("Done by:${createdByList[index]}", style: kNormalTextStyle.copyWith(fontSize: 12),),
                                                Text('${DateFormat('d/MMM kk:mm a').format(dateList[index])}', style: kNormalTextStyle.copyWith(fontSize: 11),),
                                              ],
                                            ),
                                          ],
                                        ),
                                        trailing:
                                        Column(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Text( "Ugx ${CommonFunctions().formatter.format(priceOfProducts[index])}",overflow: TextOverflow.clip, style: TextStyle(fontFamily: fontFamilyMont,fontSize: 14, color: kGreenThemeColor)),
                                            paidList[index] == true? TextButton(onPressed: (){}, child: Text("Pay")):Container()

                                          ],
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



