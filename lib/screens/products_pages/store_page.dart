import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:stylestore/model/common_functions.dart';
import 'package:stylestore/screens/products_pages/product_edit_page.dart';
import 'package:stylestore/screens/chart_pages/stock_management_page.dart';
import 'package:stylestore/screens/products_pages/search_detailed_products.dart';
import 'package:stylestore/screens/products_pages/products_upload.dart';
import 'package:stylestore/screens/products_pages/restock_page.dart';
import 'package:stylestore/screens/products_pages/stock_history.dart';
import 'package:stylestore/screens/products_pages/update_stock.dart';
import 'package:stylestore/utilities/constants/user_constants.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../../../../Utilities/constants/color_constants.dart';
import '../../../../../Utilities/constants/font_constants.dart';

import '../../controllers/adding_controller.dart';
import '../../model/beautician_data.dart';
import '../../model/excel_model.dart';
import '../../model/styleapp_data.dart';
import '../../utilities/constants/icon_constants.dart';
import '../../widgets/TicketDots.dart';
import '../../widgets/custom_popup.dart';
import '../../widgets/locked_widget.dart';
import '../../widgets/modalButton.dart';
import '../customer_pages/add_customers_page.dart';
import '../payment_pages/record_payment_widget.dart';
import '../../widgets/search_bar.dart';
import '../customer_pages/search_detailed_customer.dart';

class MerchantStorePage extends StatefulWidget {


  @override
  State<MerchantStorePage> createState() => _MerchantStorePageState();
}

class _MerchantStorePageState extends State<MerchantStorePage> {
  // VariablesXx
  // String title = 'Your';
  late YoutubePlayerController _controller;
  bool _isPlayerReady = false;

  var amountList = [];
  var quantityList = [];
  var storeIdList = [];
  var descList = [];
  var imgList = [];
  var minimumList = [];
  var nameList = [];
  var stockTakingList = [];
  var saleableList = [];
  var trackingList = [];
  var formatter = NumberFormat('#,###,000');
  String youtubeUrl = 'https://www.youtube.com/watch?v=8DhO5YOhTx4&list=RD8DhO5YOhTx4&start_radio=1&ab_channel=WilliamMcDowellMusic';

  Map<String, dynamic> permissionsMap = {};
  Map<String, dynamic> videoMap = {};

  var containerToShow = Padding(padding: EdgeInsets.all(20),
    child: Container(child: Text(
      'This Provide has no products', textAlign: TextAlign.center,
      style: kHeading2TextStyleBold,),),);

  defaultInitialization()async{
    permissionsMap = await CommonFunctions().convertPermissionsJson();
    videoMap = await CommonFunctions().convertWalkthroughVideoJson();
    setState(() {

    });
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    defaultInitialization();
    _controller = YoutubePlayerController(
      initialVideoId: YoutubePlayer.convertUrlToId(youtubeUrl)! ,
      flags: YoutubePlayerFlags(
        mute: false,
        autoPlay: false,
      ),
    );

  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery
        .of(context)
        .size
        .width * 0.6;
    var styleData = Provider.of<StyleProvider>(context, listen: false);
    var kitchenDataSet = Provider.of<BeauticianData>(context, listen: false);

    return
      Scaffold(
        appBar: AppBar(
            backgroundColor: kPureWhiteColor,
            elevation: 0,
            automaticallyImplyLeading: false,

            actions: [
              permissionsMap['takeStock'] == false ? Container():
              Row(

                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GestureDetector(
                      onTap: () async {
                        final prefs = await SharedPreferences.getInstance();
                        Provider.of<BeauticianData>(context, listen: false)
                            .setStoreId(prefs.getString(kStoreIdConstant));

                        // Navigator.pushNamed(context, ReStockPage.id);
                        showDialog(context: context,
                            // barrierLabel: 'Appointment',
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

                      child: Container(
                        // height: 10,
                        width: 100,
                        decoration: BoxDecoration(
                          color: kCustomColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(child: Text("Take Stock",
                          style: kNormalTextStyle.copyWith(
                              color: kBlack, fontSize: 16),)),
                        // color: kAirPink,
                      ),
                    ),
                  ),
                  kMediumWidthSpacing,
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, StockHistoryPage.id);
                          // ZoomDrawer.of(context)!.toggle();

                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(Iconsax.receipt, color: kAppPinkColor, size: 25,),
                            Text("History", style: kNormalTextStyle.copyWith(
                                fontSize: 12,
                                color: kBlack,
                                fontWeight: FontWeight.bold),)
                          ],
                        )),
                  ),

                ],
              ),
            ],
            // leading:
            // permissionsMap['takeStock'] == false ? Container():
            // GestureDetector(
            //     onTap: () {
            //       Navigator.pushNamed(context, StockHistoryPage.id);
            //       // ZoomDrawer.of(context)!.toggle();
            //
            //     },
            //     child: Column(
            //       mainAxisAlignment: MainAxisAlignment.center,
            //       crossAxisAlignment: CrossAxisAlignment.center,
            //       children: [
            //         Icon(Iconsax.receipt, color: kAppPinkColor, size: 25,),
            //         Text("History", style: kNormalTextStyle.copyWith(
            //             fontSize: 12,
            //             color: kBlack,
            //             fontWeight: FontWeight.bold),)
            //       ],
            //     ))
        ),

        floatingActionButtonLocation: FloatingActionButtonLocation
            .miniCenterFloat,
        floatingActionButton:permissionsMap['store'] == false ?Container(): FloatingActionButton(
            backgroundColor: kAppPinkColor,
            onPressed: () {
              // add Ingredient Here
              // Navigator.pushNamed(context, ProductUpload.id);
              showDialog(context: context, builder: (BuildContext context) {
                return
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child:
                    Material(
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
                                      // Navigator.pop(context);
                                      _uploadExcelFile();
                                    },
                                    child: CircleAvatar(
                                        radius: 30,
                                        backgroundColor: kCustomColor
                                            .withOpacity(1),
                                        child: const Icon(
                                          Iconsax.firstline, color: kBlack,
                                          size: 20,)),
                                  ),
                                  Text("Bulk Upload\nProducts",
                                    textAlign: TextAlign.center,
                                    style: kNormalTextStyle.copyWith(
                                        color: kPureWhiteColor, fontSize: 12),)
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
                                          context, ProductUpload.id);
                                      // Provider.of<StyleProvider>(context, listen: false).setInvoicedPriceToPay(priceList[index] - paidAmountList[index]);
                                      // Provider.of<StyleProvider>(context, listen: false).setInvoicedValues(priceList[index], paidAmountList[index], clientList[index], transIdList[index]);

                                      // showModalBottomSheet(
                                      //     context: context,
                                      //     isScrollControlled: true,
                                      //     builder: (context) {
                                      //       return RecordPaymentWidget();
                                      //     });


                                    },
                                    child: CircleAvatar(
                                        backgroundColor: kCustomColorPink
                                            .withOpacity(1),

                                        radius: 30,
                                        child: const Icon(
                                          Iconsax.tag, color: kPureWhiteColor,
                                          size: 20,)),
                                  ),
                                  Text("Add Product\n",
                                    style: kNormalTextStyle.copyWith(
                                        color: kPureWhiteColor, fontSize: 12),)
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
                          Text("Cancel", style: kNormalTextStyle.copyWith(
                              color: kPureWhiteColor),)
                        ],
                      ),
                    ),
                  );
              });
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(CupertinoIcons.add, color: kPureWhiteColor,),
                Text("Add", style: kNormalTextStyle.copyWith(
                    color: kPureWhiteColor, fontSize: 12),)
              ],
            )
        ),
        body: WillPopScope(
          onWillPop: () async {
            return false; // return a `Future` with false value so this route cant be popped or closed.
          },
          child: SafeArea(
            child: permissionsMap['store'] == false ? LockedWidget(page: "Store"):Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, left: 50, right: 50),
                  child:
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, left: 10, right: 10),

                    child: GestureDetector(
                        onTap: () async {
                          final prefs = await SharedPreferences.getInstance();

                          Provider.of<BeauticianData>(context, listen: false)
                              .setStoreId(prefs.getString(kStoreIdConstant));

                          showModalBottomSheet(
                              isScrollControlled: true,
                              context: context,
                              builder: (context) {
                                return ProductsDetailedSearchPage();
                              });
                        },
                        child:
                        Container(
                            padding: EdgeInsets.all(10),

                            decoration: BoxDecoration(
                              // border: OutlineInputBorder(
                              //   borderRadius: BorderRadius.all(Radius.circular(15)),
                              // ),
                              border: Border.all(width: 1, color: kFontGreyColor),
                              borderRadius: const BorderRadius.all(
                                Radius.circular(20),
                              ),

                              color: kBackgroundGreyColor,
                            ),

                            child: Row(
                              children: [
                                Icon(Icons.search, color: kFontGreyColor,),
                                kSmallWidthSpacing,
                                Text("Search Product Items",
                                  style: kNormalTextStyle,)
                              ],
                            ))
                    ),
                  ),
                ),
                Expanded(
                  child:
                  StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance.collection('stores')
                          .where('storeId', isEqualTo: Provider
                          .of<StyleProvider>(context, listen: false)
                          .beauticianId)
                          .where('active', isEqualTo: true)
                          .orderBy('saleable', descending: true)
                          .orderBy('name', descending: false)
                          .snapshots(),
                      builder: (context, snapshot) {
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
                        }

                        else {
                          amountList = [];
                          quantityList = [];
                          descList = [];
                          imgList = [];
                          nameList = [];
                          saleableList = [];
                          trackingList = [];
                          minimumList = [];
                          stockTakingList = [];

                          storeIdList = [];
                          var appointments = snapshot.data!.docs;
                          for (var appointment in appointments) {
                            descList.add(appointment.get('description'));
                            saleableList.add(appointment.get('saleable'));
                            trackingList.add(appointment.get('tracking'));
                            imgList.add(appointment.get('image'));
                            nameList.add(appointment.get('name'));
                            storeIdList.add(appointment.get('id'));
                            amountList.add(appointment.get('amount'));
                            quantityList.add(appointment.get('quantity'));
                            minimumList.add(appointment.get('minimum'));
                            stockTakingList.add(appointment.get('stockTaking'));
                          }
                        }
                        return

                          nameList.isEmpty?
                          // GestureDetector(
                          //   onTap: (){
                          //     // Navigator.pushNamed(context, ProductUpload.id);
                          //   },
                          //   child: Column(
                          //     mainAxisAlignment: MainAxisAlignment.center,
                          //     children: [
                          //       GestureDetector(
                          //           onTap: (){
                          //             showDialog(
                          //               context: context,
                          //               builder: (context) => AlertDialog(
                          //                 content: Container(
                          //                   width: MediaQuery.of(context).size.width * 0.8,
                          //                   child: YoutubePlayerBuilder(
                          //                     player: YoutubePlayer(
                          //                       controller: _controller,
                          //                       onReady: () {
                          //                         _isPlayerReady = true;
                          //                       },
                          //                     ),
                          //                     builder: (context, player) {
                          //                       return player;
                          //                     },
                          //                   ),
                          //                 ),
                          //               ),
                          //             );
                          //           },
                          //           child: Lottie.asset("images/confused.json")),
                          //       Text("No Items Here. Click here to see how to add Items", style: kNormalTextStyle.copyWith(color: Colors.blue),) ]),
                          // )
                          CustomPopupWidget(backgroundColour: kBlueDarkColor,actionButton: 'Add Items', subTitle: 'One item at a time', image: 'store.jpg', title: 'Setup a World Class Store', function:
                              () {
                            //   showModalBottomSheet(isScrollControlled: true, context: context, builder: (context) {
                            //   return Scaffold(
                            //
                            //       body: AddCustomersPage());
                            // });
                            //   }
                            Navigator.pushNamed(context, ProductUpload.id);
                          }, youtubeLink: videoMap['store']
                            ,
                          )
                              :
                          Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: ListView.builder(

                              itemCount: imgList.length,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () {
                                    // showStoreDialogFunc(context, imgList[index], nameList[index], descList[index], amountList[index]);
                                    kitchenDataSet.changeItemDetails(
                                      nameList[index],
                                      quantityList[index].toDouble(),
                                      descList[index],
                                      minimumList[index].toDouble(),
                                      storeIdList[index],
                                      amountList[index].toDouble(),
                                      imgList[index],
                                      trackingList[index],
                                      saleableList[index],);

                                    showModalBottomSheet(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return Container(
                                            color: Color(0xFF292929).withOpacity(0.6),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                  color: kPureWhiteColor,
                                                  borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30) )
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.only(top: 20.0, bottom: 50, left: 20),
                                                child: Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children:
                                                  [
                                                    buildButton(context, 'Edit ${nameList[index]}', Iconsax.pen_add,
                                                            () async {
                                                          Navigator.pop(context);
                                                          Navigator.pushNamed(context, ProductEditPage.id);


                                                        }
                                                    ),
                                                    SizedBox(height: 16.0),
                                                    buildButton(context, '${nameList[index]} Stock History', Iconsax.graph,  () async {
                                                      Navigator.pop(context);

                                                      if (stockTakingList[index].isEmpty){
                                                        showDialog(context: context, builder: (BuildContext context){
                                                          return CupertinoAlertDialog(
                                                            title: const Text('No Stock Data'),
                                                            content: Text('There is no stock data available for ${nameList[index]}', style: kNormalTextStyle.copyWith(color: kBlack),),
                                                            actions: [CupertinoDialogAction(isDestructiveAction: true,
                                                                onPressed: (){
                                                                  // _btnController.reset();
                                                                  Navigator.pop(context);

                                                                  // Navigator.pushNamed(context, SuccessPageHiFive.id);
                                                                },
                                                                child: const Text('Cancel'))],
                                                          );
                                                        });
                                                      } else {
                                                        print(storeIdList[index]);
                                                        Provider.of<StyleProvider>(context, listen: false).setStockAnalysisValues(storeIdList[index]);
                                                        Navigator.pushNamed(context, StockManagementPage.id);
                                                      }





                                                    } ),

                                                  ],
                                                ),
                                              ),
                                            ),
                                          ); });
                                    // Navigator.pushNamed(
                                    //     context, ProductEditPage.id);
                                    // THIS CODE HAS BEEN COMMENTED PUT FOR NOW


                                    // showDialog(context: context, builder: (BuildContext context){
                                    //   return
                                    //     GestureDetector(
                                    //       onTap: (){Navigator.pop(context); },
                                    //       child:
                                    //       Material(
                                    //         color: Colors.transparent,
                                    //         child: Column(
                                    //           mainAxisAlignment: MainAxisAlignment.center,
                                    //           children: [
                                    //             Center(child: Row(
                                    //               mainAxisAlignment: MainAxisAlignment.center,
                                    //               children: [
                                    //
                                    //                 Column(
                                    //                   children: [
                                    //                     GestureDetector(
                                    //                       onTap: (){
                                    //                         Navigator.pop(context);
                                    //                         if (trackingList[index]!=false){
                                    //                           showModalBottomSheet(
                                    //                               context: context,
                                    //                               isScrollControlled: true,
                                    //                               builder: (context) {
                                    //                                 return Scaffold(
                                    //                                     appBar: AppBar(
                                    //                                       backgroundColor: kBiegeThemeColor,
                                    //                                       elevation: 0,
                                    //                                       automaticallyImplyLeading: false,
                                    //                                     ),
                                    //
                                    //                                     body: StockManagementPage()
                                    //                                 );
                                    //                               });
                                    //                         }else {
                                    //                           showDialog(context: context, builder: (BuildContext context){
                                    //                             return
                                    //                               CupertinoAlertDialog(
                                    //                                 title: const Text('ITEM NOT TRACKABLE'),
                                    //                                 content: Text("This item's stock and restock values are not being tracked", style: kNormalTextStyle.copyWith(color: kBlack),),
                                    //                                 actions: [
                                    //
                                    //                                   CupertinoDialogAction(isDestructiveAction: true,
                                    //                                       onPressed: (){
                                    //                                         // _btnController.reset();
                                    //                                         Navigator.pop(context);
                                    //                                       },
                                    //                                       child: const Text('Cancel')),
                                    //
                                    //
                                    //                                 ],
                                    //                               );
                                    //                           });
                                    //                         }
                                    //
                                    //
                                    //                       },
                                    //                       child: CircleAvatar(
                                    //                           radius: 30,
                                    //                           backgroundColor: kCustomColor.withOpacity(1),
                                    //                           child: const Icon(Iconsax.firstline, color: kBlack,size: 20,)),
                                    //                     ),
                                    //                     Text("Manage Stock", style: kNormalTextStyle.copyWith(color: kPureWhiteColor, fontSize: 12),)
                                    //                   ],
                                    //                 ),
                                    //                 kMediumWidthSpacing,
                                    //                 kMediumWidthSpacing,
                                    //                 kMediumWidthSpacing,
                                    //                 Column(
                                    //                   children: [
                                    //                     GestureDetector(
                                    //                       onTap: (){
                                    //                         Navigator.pop(context);
                                    //                         Navigator.pushNamed(context, ProductEditPage.id);
                                    //                         // Provider.of<StyleProvider>(context, listen: false).setInvoicedPriceToPay(priceList[index] - paidAmountList[index]);
                                    //                         // Provider.of<StyleProvider>(context, listen: false).setInvoicedValues(priceList[index], paidAmountList[index], clientList[index], transIdList[index]);
                                    //
                                    //                         // showModalBottomSheet(
                                    //                         //     context: context,
                                    //                         //     isScrollControlled: true,
                                    //                         //     builder: (context) {
                                    //                         //       return RecordPaymentWidget();
                                    //                         //     });
                                    //
                                    //
                                    //
                                    //                       },
                                    //                       child: CircleAvatar(
                                    //                           backgroundColor: kCustomColorPink.withOpacity(1),
                                    //
                                    //                           radius: 30,
                                    //                           child: const Icon(Iconsax.tag, color: kPureWhiteColor,size: 20,)),
                                    //                     ),
                                    //                     Text("Edit Product", style: kNormalTextStyle.copyWith(color: kPureWhiteColor, fontSize: 12),)
                                    //                   ],
                                    //                 ),
                                    //
                                    //               ],
                                    //             )),
                                    //             kLargeHeightSpacing,
                                    //             kLargeHeightSpacing,
                                    //             kLargeHeightSpacing,
                                    //             kLargeHeightSpacing,
                                    //             kLargeHeightSpacing,
                                    //             kLargeHeightSpacing,
                                    //             kLargeHeightSpacing,
                                    //             Text("Cancel", style: kNormalTextStyle.copyWith(color: kPureWhiteColor),)
                                    //           ],
                                    //         ),
                                    //       ),
                                    //     );
                                    // });

                                    // COMMENTING ENDS HERE

                                  },
                                  child:
                                  Stack(
                                      children: [
                                        Card(
                                          color: kBackgroundGreyColor,
                                          shadowColor: kBackgroundGreyColor,
                                          child: Row(
                                            children: [

                                              Padding(
                                                padding: const EdgeInsets.all(
                                                    8.0),
                                                child:
                                                Column(
                                                  children: [
                                                    // SquareImage(networkImageToUse: imgList[index], outsideRingColor: kBeigeThemeColor, radius: 150,),

                                                  ],
                                                ),
                                              ),
                                              Flexible(
                                                child: Padding(
                                                  padding: EdgeInsets.all(10.0),
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment
                                                        .start,
                                                    children: [
                                                      Row(
                                                        mainAxisAlignment: MainAxisAlignment
                                                            .spaceBetween,
                                                        children: [
                                                          Text(nameList[index],
                                                            overflow: TextOverflow
                                                                .ellipsis,
                                                            style: kHeadingTextStyle,),
                                                          Text(
                                                            '${formatter.format(
                                                                amountList[index])} Ugx',
                                                            style: kNormalTextStyle
                                                                .copyWith(
                                                                color: kGreenThemeColor,
                                                                fontSize: 14),)

                                                        ],
                                                      ),
                                                      kSmallHeightSpacing,
                                                      Text(descList[index],
                                                          style: kNormalTextStyleSmallGrey),
                                                      kSmallHeightSpacing,
                                                      trackingList[index] == true
                                                          ? quantityList[index] >=
                                                          5
                                                          ? Text(
                                                          "Qty: ${quantityList[index]
                                                              .toString()}",
                                                          style: kNormalTextStyleSmallGrey
                                                              .copyWith(
                                                              color: kGreenThemeColor))
                                                          : Text(
                                                          "Qty: ${quantityList[index]
                                                              .toString()}",
                                                          style: kNormalTextStyleSmallGrey
                                                              .copyWith(
                                                              color: Colors.red))
                                                          : Container(),
                                                      saleableList[index] == false
                                                          ? Text("Not for sale",
                                                          style: kNormalTextStyleSmallGrey
                                                              .copyWith(
                                                              color: kAppPinkColor))
                                                          : Container()

                                                      // PaymentButtons(buttonColor: kNewGreenThemeColor, title: '${formatter.format(amountList[index])} Ugx', onPressedFunction: (){}, buttonHeight: 40,buttonWidth: 130,)


                                                    ],
                                                  ),),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Positioned(
                                            right: 0,
                                            top: 0,
                                            child: GestureDetector(
                                                onTap: () {
                                                  CoolAlert.show(
                                                      lottieAsset: 'images/question.json',
                                                      context: context,
                                                      type: CoolAlertType.success,
                                                      text: "Are you sure you want to remove this from your services list",
                                                      title: "Remove Item?",
                                                      confirmBtnText: 'Yes',
                                                      confirmBtnColor: Colors.red,
                                                      cancelBtnText: 'Cancel',
                                                      showCancelBtn: true,
                                                      backgroundColor: kAppPinkColor,
                                                      onConfirmBtnTap: () {
                                                        // Provider.of<BlenditData>(context, listen: false).deleteItemFromBasket(blendedData.basketItems[index]);
                                                        // FirebaseServerFunctions().removePostFavourites(docIdList[index],postId[index], userEmail);
                                                        CommonFunctions()
                                                            .removeDocumentFromServer(
                                                            storeIdList[index],
                                                            'stores');

                                                        Navigator.pop(context);
                                                      }
                                                  );
                                                },

                                                child: kIconCancel)),
                                      ]),
                                );
                              }),
                        );
                      }

                  ),
                ),
              ],
            ),
          ),
        ),
      );
  }

  showDialogFunc(context, img, title, desc, amount, id) {
    Timer _timer;


    animationTimer() {
      _timer = Timer(const Duration(milliseconds: 4000), () {
        Navigator.pop(context);
        Navigator.pop(context);
        Navigator.pop(context);
      });
    }
    int opacity = 0;
    String subscribe = '';
    Function execute;

    return
      showDialog(
          context: context, barrierLabel: 'Appointment', builder: (context) {
        return Center(

          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Material(
              elevation: 10.0,

              type: MaterialType.transparency,
              child: SingleChildScrollView(
                child: Container(

                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white
                  ),
                  padding: const EdgeInsets.only(left: 15, right: 15, top: 15),
                  width: MediaQuery
                      .of(context)
                      .size
                      .width,
                  //height: 400,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(25),
                        child: FadeInImage.assetNetwork(
                          placeholder: 'images/loading.gif',
                          image: img,
                          width: 200,
                          height: 200,),
                      ),
                      kSmallHeightSpacing,
                      Text(title,
                          style: const TextStyle(fontSize: 25, color: Colors
                              .grey,
                              fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center),
                      kSmallHeightSpacing,

                      Text(desc,
                        style: kNormalTextStyleSmallGrey,
                        textAlign: TextAlign.center,),
                      SizedBox(height: 10,),

                    ],),


                ),
              ),


            ),
          ),
        );
      });
  }

  List<ExcelDataRow> dataList = [];

  void _uploadExcelFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: [
          'xls',
          'xlsx'
        ]); // , allowedExtensions: ['xls','xlsx']
    if (result != null) {
      setState(() {
        dataList.clear();
      });

      File excelFile = File(result.files.single.path!);
      try {
        List<ExcelDataRow> uploadedDataList = await readExcelData(excelFile);

        setState(() {
          dataList.addAll(uploadedDataList);
        });

        await uploadDataToFirebase(uploadedDataList);
      } catch (e){
        _showErrorDialog("Wrong Excel document Format used.");
      }
    }
  }


  Future<List<ExcelDataRow>> readExcelData(File excelFile) async {
    var bytes = excelFile.readAsBytesSync();
    var excel = Excel.decodeBytes(bytes);

    // Assume the first sheet in the Excel file contains the data.
    var sheet = excel.tables[excel.tables.keys.first];

    List<ExcelDataRow> dataList = [];
    for (var row in sheet!.rows) {
      // Skip the header row (assuming it's the first row)
      if (row[0]!.value == 'Name') continue;

      ExcelDataRow rowData = ExcelDataRow(
        name: _parseStringValue(row[0]?.value),
        description: _parseStringValue(row[1]?.value),
        amount: _parseDoubleValue(row[2]?.value),
        saleable: _parseBoolValue(row[3]?.value),
        tracking: _parseBoolValue(row[4]?.value),
        quantity: _parseIntValue(row[5]?.value),
        minimum: _parseIntValue(row[6]?.value),
      );

      dataList.add(rowData);
    }
    return dataList;
  }

  String _parseStringValue(dynamic value) {
    return value is SharedString ? value.toString() : value?.toString() ?? '';
  }

  double _parseDoubleValue(dynamic value) {
    if (value is SharedString) {
      return double.tryParse(value.toString()) ?? 0.0;
    } else if (value is double) {
      return value;
    } else {
      return 0.0;
    }
  }


  int _parseIntValue(dynamic value) {
    if (value is SharedString) {
      return int.tryParse(value.toString()) ?? 0;
    } else if (value is int) {
      return value;
    } else {
      return 0;
    }
  }

  bool _parseBoolValue(dynamic value) {
    if (value is SharedString) {
      return value.toString().toLowerCase() == 'true';
    } else if (value is bool) {
      return value;
    } else {
      return false;
    }
  }


  Future<void> uploadDataToFirebase(List<ExcelDataRow> dataList) async {
    Navigator.pop(context);
    try {
      // showDialog(context: context, builder: (context) {
      //   return Center(
      //       child:
      //       Column(
      //         mainAxisSize: MainAxisSize.min,
      //         children: [
      //           CircularProgressIndicator(color: kAppPinkColor,),
      //           kSmallHeightSpacing,
      //           DefaultTextStyle(
      //             style: kNormalTextStyle.copyWith(color: kPureWhiteColor),
      //             child: Text("Updating products to your store",
      //               textAlign: TextAlign.center,),
      //           )
      //           // Text("Loading Contacts", style: kNormalTextStyle.copyWith(color: kPureWhiteColor),)
      //         ],
      //       ));
      // });
      final prefs = await SharedPreferences.getInstance();

      CollectionReference dataCollection = FirebaseFirestore.instance
          .collection(
          'stores');

      // Upload each row of data to Firestore as a separate document
      dataList.forEach((rowData) {
        var newDocumentRef = dataCollection
            .doc(); // Firestore generates a unique ID
        newDocumentRef.set({
          'active': true,
          'id': newDocumentRef.id, // Add the unique ID as the 'id' field
          'name': rowData.name,
          'description': rowData.description,
          'amount': rowData.amount,
          'saleable': rowData.saleable,
          'tracking': rowData.tracking,
          'quantity': rowData.quantity,
          'minimum': rowData.minimum,
          'image': "https://mcusercontent.com/f78a91485e657cda2c219f659/images/14f4afc4-ffaf-4bb1-3384-b23499cf0df7.png",
          'storeId': prefs.getString(kStoreIdConstant),
          'stockTaking': []
        });
      });

    ScaffoldMessenger.of(context).showSnackBar( SnackBar(content: Text('Items added Successfully')));

    } catch (e) {
      _showErrorDialog("$e");
    }
  }
  void _showErrorDialog(String errorMessage) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text('Error'),
          content: Text(errorMessage),
          actions: [
            CupertinoDialogAction(
              child: Text('OK'),
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }





}
