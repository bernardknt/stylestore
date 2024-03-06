import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:stylestore/Utilities/InputFieldWidget.dart';
import 'package:stylestore/model/beautician_data.dart';
import 'package:stylestore/model/common_functions.dart';
import 'package:stylestore/model/products.dart';
import 'package:stylestore/screens/payment_pages/pos_summary.dart';
import 'package:stylestore/screens/products_pages/search_products.dart';
import 'package:stylestore/screens/products_pages/products_upload.dart';
import 'package:stylestore/screens/products_pages/update_stock.dart';
import 'package:stylestore/utilities/basket_items.dart';
import 'package:stylestore/widgets/TicketDots.dart';
import 'package:stylestore/widgets/search_bar.dart';
import 'package:stylestore/screens/customer_pages/search_customer.dart';
import 'package:stylestore/widgets/transaction_buttons.dart';
import '../../../../../Utilities/constants/color_constants.dart';
import '../../../../../Utilities/constants/font_constants.dart';
import '../../../../../Utilities/constants/user_constants.dart';
import '../../model/stock_items.dart';
import '../../model/styleapp_data.dart';
import '../../widgets/custom_popup.dart';
import '../../widgets/locked_widget.dart';
import '../barcode_page.dart';

class PosWeb extends StatefulWidget {
  static String id = 'pos_widget_web';

  final bool showBackButton;

  const PosWeb({Key? key, this.showBackButton = true}) : super(key: key);

  @override
  State<PosWeb> createState() => _PosWebState();
}

class _PosWebState extends State<PosWeb> {
  // VariablesXx
  String title = 'Your';
  String userId = 'md4348a660';

  var amountList = [];
  var barcodeList = [];
  var storeIdList = [];
  var descList = [];
  var quantityList = [];
  var imgList = [];
  var nameList = [];
  var trackingList = [];
  var minimumList = [];
  var idList = [];
  var formatter = NumberFormat('#,###,000');
  var description = "";
  var amount = 0.0;
  var quantity = 1.0;
  var isStoreEmpty = false;
  List<Product> products = [];

  List<Stock> selectedStocks = [];
  Map<String, dynamic> permissionsMap = {};
  Map<String, dynamic> videoMap = {};

  var containerToShow = Padding(
    padding: EdgeInsets.only(top: 20),
    child: Container(
      child: Text(
        'This Provide has no products',
        textAlign: TextAlign.center,
        style: kHeading2TextStyleBold,
      ),
    ),
  );
  var checkBoxValue = false;

  void defaultInitialization() async {
    permissionsMap = await CommonFunctions().convertPermissionsJson();
    videoMap = await CommonFunctions().convertWalkthroughVideoJson();
    isStoreEmpty = Provider.of<StyleProvider>(context, listen: false).isStoreEmpty;
    Provider.of<StyleProvider>(context, listen: false).resetCustomerDetails();

    setState(() {});
  }

  // Future<void> _startBarcodeScan(BuildContext context) async {
  bool isScanning = false;

  Future<void> _startBarcodeScan() async {
    isScanning = true;
    while (isScanning) {
      isScanning = false;
      String barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
        "#FF0000", // Custom red color for the scanner
        "Cancel", // Button text for cancelling the scan
        true, // Show flash icon
        ScanMode.BARCODE, // Specify the scan mode (BARCODE, QR)
      );

      if (barcodeScanRes != '-1') {
        int index = barcodeList.indexOf(barcodeScanRes);
        if (index != -1) {
          CommonFunctions().playBeepSound();
          isScanning = false;

          if (trackingList[index] == true) {
            if (1 <= quantityList[index]) {
              print(description);

              Provider.of<StyleProvider>(context, listen: false)
                  .addToServiceBasket(BasketItem(
                      name: nameList[index],
                      quantity: 1.0,
                      amount: amountList[index] / 1.0,
                      details: descList[index],
                      tracking: trackingList[index]));
              selectedStocks.add(Stock(
                  name: nameList[index],
                  id: idList[index],
                  restock: 1,
                  price: amountList[index] / 1.0));
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return CupertinoAlertDialog(
                    title: Text("Scan another Item?"),
                    content: Text("Would you like to scan another item?"),
                    actions: [
                      CupertinoDialogAction(
                        child: const Text(
                          "Cancel",
                          style: TextStyle(color: kRedColor),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop(); // Close the dialog
                        },
                      ),
                      CupertinoDialogAction(
                        child: const Text("Scan Another"),
                        onPressed: () {
                          Navigator.of(context).pop(); // Close the dialog
                          _startBarcodeScan();
                        },
                      ),
                    ],
                  );
                },
              );
              // Navigator.pop(context);
            } else {
              // Navigator.pop(context);
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return CupertinoAlertDialog(
                      title: const Text('Quantity Too High'),
                      content: Text(
                        "The quantity available for ${nameList[index]} is ${quantityList[index]}! You have tried to sell 1 unit!",
                        style: kNormalTextStyle.copyWith(color: kBlack),
                      ),
                      actions: [
                        CupertinoDialogAction(
                            isDestructiveAction: true,
                            onPressed: () {
                              // _btnController.reset();
                              Navigator.pop(context);
                            },
                            child: const Text('Cancel')),
                        CupertinoDialogAction(
                            isDefaultAction: true,
                            onPressed: () async {
                              final prefs =
                                  await SharedPreferences.getInstance();
                              Provider.of<BeauticianData>(context,
                                      listen: false)
                                  .setStoreId(
                                      prefs.getString(kStoreIdConstant));

                              Navigator.pop(context);
                              Navigator.pop(context);
                              Navigator.pushNamed(context, UpdateStockPage.id);
                            },
                            child: const Text('Update Stock')),
                      ],
                    );
                  });
            }
          } else {
            Provider.of<StyleProvider>(context, listen: false)
                .addToServiceBasket(BasketItem(
                    name: nameList[index],
                    quantity: 1.0,
                    amount: amountList[index] / 1.0,
                    details: descList[index],
                    tracking: trackingList[index]));
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('TRACKING TRUE ${nameList[index]} added')));
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return CupertinoAlertDialog(
                  title: Text("Scan another Item?"),
                  content: Text("Would you like to scan another item?"),
                  actions: [
                    CupertinoDialogAction(
                      child: const Text(
                        "Cancel",
                        style: TextStyle(color: kRedColor),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop(); // Close the dialog
                      },
                    ),
                    CupertinoDialogAction(
                      child: const Text("Scan Another"),
                      onPressed: () {
                        Navigator.of(context).pop(); // Close the dialog
                        _startBarcodeScan();
                      },
                    ),
                  ],
                );
              },
            );
          }
        } else {
          isScanning = false;
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Item is not in your Inventory')));
          // Navigator.pop(context);
        }
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    defaultInitialization();
  }

  @override
  Widget build(BuildContext context) {
    var styleData = Provider.of<StyleProvider>(context);
    return Scaffold(
      backgroundColor: kPlainBackground,
      appBar: AppBar(
        foregroundColor: kBlack,
        backgroundColor: kPlainBackground,
        automaticallyImplyLeading: widget.showBackButton,
        elevation: 0,
        centerTitle: true,
        actions: [
          if (!kIsWeb)
            Padding(
              padding: const EdgeInsets.only(right: 30.0, top: 10),
              child: GestureDetector(
                  onTap: () {
                    _startBarcodeScan();
                  },
                  child: Icon(
                    Iconsax.scan,
                    size: 40,
                  )),
            )
        ],
      ),
      // floatingActionButton: permissionsMap['sales'] == false ? Container() : isStoreEmpty == true ? Container() : FloatingActionButton.extended(
      //   splashColor: Colors.green,
      //
      //   backgroundColor: kAppPinkColor,
      //   //blendedData.saladButtonColour,
      //   onPressed: () async {
      //     // Provider.of<StyleProvider>(context, listen: false).setSelectedStockItems(selectedStocks);
      //     final prefs = await SharedPreferences.getInstance();
      //     Provider.of<BeauticianData>(context, listen: false)
      //         .setStoreId(prefs.getString(kStoreIdConstant));
      //
      //     if (Provider.of<StyleProvider>(context, listen: false)
      //         .basketItems
      //         .length ==
      //         0) {
      //       CommonFunctions().AlertPopUpDialogueMain(context,
      //           imagePath: 'images/delivery.json',
      //           title: 'No Items Added',
      //           text: 'Add some Items');
      //     } else {
      //       if (Provider.of<StyleProvider>(context, listen: false)
      //           .customerName ==
      //           "") {
      //         Provider.of<StyleProvider>(context, listen: false)
      //             .setSelectedStockItems(selectedStocks);
      //         CommonFunctions().AlertPopUpCustomers(context,
      //             imagePath: 'images/leave.json',
      //             title: 'No Customer Added',
      //             text: 'Add a Customer',
      //             cancelButtonText: "Continue",
      //             selectedStocks: selectedStocks);
      //       } else {
      //         Provider.of<StyleProvider>(context, listen: false)
      //             .clearSelectedStockItems();
      //         Provider.of<StyleProvider>(context, listen: false)
      //             .setSelectedStockItems(selectedStocks);
      //         showModalBottomSheet(
      //             context: context,
      //             builder: (context) {
      //               return PosSummary();
      //             });
      //       }
      //     }
      //   },
      //   icon: CircleAvatar(
      //       radius: 12,
      //       child: Text(
      //         "${Provider.of<StyleProvider>(context).basketItems.length}",
      //         style: kNormalTextStyle.copyWith(color: kBlack),
      //       )),
      //   label: Text(
      //     'Total: ${CommonFunctions().formatter.format(Provider.of<StyleProvider>(context).totalPrice)}',
      //     style: kNormalTextStyle.copyWith(color: kPureWhiteColor),
      //   ),
      // ),
      // floatingActionButtonLocation:
      // FloatingActionButtonLocation.miniCenterFloat,
      body: permissionsMap['sales'] == false
          ? LockedWidget(page: "Point Of Sale")
          : Row(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      Container(
                        height: 100,
                        decoration: const BoxDecoration(
                          color: kPlainBackground,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10, right: 10),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${Provider.of<StyleProvider>(context, listen: false).beauticianName} POS',
                                style: kNormalTextStyle.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: kBlack,
                                    fontSize: 20),
                              )

                              // Text('${Provider.of<StyleProvider>(context).basketNameItems}',textAlign: TextAlign.center, style: kNormalTextStyle.copyWith(color: kPureWhiteColor ,fontSize: 12),),
                            ],
                          ),
                        ),
                      ),

                      Positioned(
                        top: 70,
                        left: 0,
                        right: 50,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () async {
                                    final prefs =
                                        await SharedPreferences.getInstance();

                                    Provider.of<BeauticianData>(context,
                                            listen: false)
                                        .setStoreId(
                                            prefs.getString(kStoreIdConstant));
                                    Provider.of<BeauticianData>(context,
                                            listen: false)
                                        .setProductItems(products);

                                    showModalBottomSheet(
                                        isScrollControlled: true,
                                        context: context,
                                        builder: (context) {
                                          return Scaffold(
                                              appBar: AppBar(
                                                backgroundColor:
                                                    kPureWhiteColor,
                                                automaticallyImplyLeading:
                                                    false,
                                              ),
                                              body: ProductsSearchPage());
                                        });
                                  },
                                  child: Container(
                                      padding: EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        // border: OutlineInputBorder(
                                        //   borderRadius: BorderRadius.all(Radius.circular(15)),
                                        // ),
                                        border: Border.all(
                                            width: 0.5, color: kFontGreyColor),
                                        borderRadius: const BorderRadius.all(
                                          Radius.circular(10),
                                        ),

                                        color: kBackgroundGreyColor,
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.search,
                                            color: kFontGreyColor,
                                          ),
                                          kSmallWidthSpacing,
                                          Text(
                                            "Search Items",
                                            style: kNormalTextStyle,
                                          )
                                        ],
                                      )),
                                ),
                              ),
                              kSmallWidthSpacing,
                              GestureDetector(
                                  onTap: () {
                                    showModalBottomSheet(
                                        isScrollControlled: true,
                                        context: context,
                                        builder: (context) {
                                          return Scaffold(
                                              appBar: AppBar(
                                                automaticallyImplyLeading:
                                                    false,
                                                backgroundColor: kBlack,
                                              ),
                                              body: ProductUpload());
                                        });
                                  },
                                  child: Tooltip(
                                      message: "Add a new Product",
                                      child: Icon(
                                        Iconsax.box,
                                        size: 40,
                                        color: kAppPinkColor,
                                      )))
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 150.0),
                        child: StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('stores')
                                .where('storeId',
                                    isEqualTo: styleData.beauticianId)
                                .where('active', isEqualTo: true)
                                .where('saleable', isEqualTo: true)
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return Center(
                                  child: CircularProgressIndicator(
                                    color: kBlueDarkColor,
                                  ),
                                );
                              } else {
                                amountList = [];
                                descList = [];
                                imgList = [];
                                nameList = [];
                                trackingList = [];
                                idList = [];
                                minimumList = [];
                                barcodeList = [];
                                storeIdList = [];

                                var appointments = snapshot.data!.docs;

                                for (var appointment in appointments) {
                                  Product product = Product.fromMap(appointment
                                      .data() as Map<String, dynamic>);
                                  products.add(product);

                                  // Add the product's properties to the existing lists
                                  descList.add(product.description);
                                  imgList.add(product.image);
                                  nameList.add(product.name);
                                  storeIdList.add(product.storeId);
                                  quantityList.add(product.quantity);
                                  trackingList.add(product.tracking);
                                  idList.add(product.id);
                                  minimumList.add(product.minimum);
                                  amountList.add(product.amount);
                                  barcodeList.add(product.barcode);
                                }
                              }

                              return descList.isEmpty
                                  ? CustomPopupWidget(
                                      backgroundColour: kBlueDarkColor,
                                      actionButton: 'Create Product',
                                      subTitle: 'Add Products: Tap and sell',
                                      image: 'tap.jpg',
                                      title: 'Sell like a Pro',
                                      function: () {
                                        showModalBottomSheet(
                                            isScrollControlled: true,
                                            context: context,
                                            builder: (context) {
                                              return Scaffold(
                                                  appBar: AppBar(
                                                    automaticallyImplyLeading:
                                                        false,
                                                    backgroundColor: kBlack,
                                                  ),
                                                  body: ProductUpload());
                                            });
                                      },
                                      youtubeLink: videoMap['sales'],
                                    )
                                  : Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: ListView.builder(
                                          itemCount: imgList.length,
                                          itemBuilder: (context, index) {
                                            return GestureDetector(
                                                onTap: () {
                                                  description = descList[index];
                                                  amount = amountList[index]
                                                      .toDouble();
                                                  quantity = 1.0;
                                                  showDialog(
                                                      context: context,
                                                      builder: (BuildContext
                                                          context) {
                                                        return AlertDialog(
                                                          content: SizedBox(
                                                            height: 350,
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              // mainAxisSize: MainAxisSize.min,
                                                              children: [
                                                                InputFieldWidget(
                                                                    readOnly:
                                                                        true,
                                                                    hintText:
                                                                        "",
                                                                    controller:
                                                                        nameList[
                                                                            index],
                                                                    onTypingFunction:
                                                                        (value) {},
                                                                    keyboardType:
                                                                        TextInputType
                                                                            .text,
                                                                    labelText:
                                                                        "Name 🔒"),
                                                                InputFieldWidget(
                                                                    readOnly:
                                                                        false,
                                                                    hintText:
                                                                        "",
                                                                    controller:
                                                                        descList[
                                                                            index],
                                                                    onTypingFunction:
                                                                        (value) {
                                                                      description =
                                                                          value;
                                                                    },
                                                                    keyboardType:
                                                                        TextInputType
                                                                            .text,
                                                                    labelText:
                                                                        "Description"),
                                                                InputFieldWidget(
                                                                    readOnly:
                                                                        false,
                                                                    hintText:
                                                                        "",
                                                                    controller:
                                                                        "1",
                                                                    onTypingFunction:
                                                                        (value) {
                                                                      quantity =
                                                                          double.parse(
                                                                              value);
                                                                    },
                                                                    keyboardType:
                                                                        TextInputType
                                                                            .number,
                                                                    labelText:
                                                                        "Quantity"),
                                                                InputFieldWidget(
                                                                    readOnly:
                                                                        false,
                                                                    hintText:
                                                                        "",
                                                                    controller:
                                                                        amountList[index]
                                                                            .toString(),
                                                                    onTypingFunction:
                                                                        (value) {
                                                                      amount = double
                                                                          .parse(
                                                                              value);
                                                                    },
                                                                    keyboardType:
                                                                        TextInputType
                                                                            .number,
                                                                    labelText:
                                                                        "Price"),
                                                                Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceEvenly,
                                                                  children: [
                                                                    ElevatedButton(
                                                                      onPressed:
                                                                          () {
                                                                        Navigator.pop(
                                                                            context);
                                                                      },
                                                                      style: ElevatedButton
                                                                          .styleFrom(
                                                                        shape:
                                                                            RoundedRectangleBorder(
                                                                          borderRadius:
                                                                              BorderRadius.circular(10),
                                                                        ),
                                                                        backgroundColor:
                                                                            kFontGreyColor,
                                                                      ),
                                                                      child:
                                                                          Text(
                                                                        'Cancel',
                                                                        style: kNormalTextStyle.copyWith(
                                                                            color:
                                                                                kPureWhiteColor),
                                                                      ),
                                                                    ),
                                                                    ElevatedButton(
                                                                      onPressed:
                                                                          () {
                                                                        print(
                                                                            quantity);

                                                                        if (trackingList[index] ==
                                                                            true) {
                                                                          if (quantity <=
                                                                              quantityList[index]) {
                                                                            Provider.of<StyleProvider>(context, listen: false).addToServiceBasket(BasketItem(
                                                                                name: nameList[index],
                                                                                quantity: quantity,
                                                                                amount: amount,
                                                                                details: description,
                                                                                tracking: trackingList[index]));
                                                                            selectedStocks.add(Stock(
                                                                                name: nameList[index],
                                                                                id: idList[index],
                                                                                restock: quantity,
                                                                                price: amount / 1.0));
                                                                            Navigator.pop(context);
                                                                          } else {
                                                                            Navigator.pop(context);
                                                                            showDialog(
                                                                                context: context,
                                                                                builder: (BuildContext context) {
                                                                                  return CupertinoAlertDialog(
                                                                                    title: const Text('Quantity Too High'),
                                                                                    content: Text(
                                                                                      "The quantity available for ${nameList[index]} is ${quantityList[index]}! You have tried to sell ${quantity} units!",
                                                                                      style: kNormalTextStyle.copyWith(color: kBlack),
                                                                                    ),
                                                                                    actions: [
                                                                                      CupertinoDialogAction(
                                                                                          isDestructiveAction: true,
                                                                                          onPressed: () {
                                                                                            // _btnController.reset();
                                                                                            Navigator.pop(context);
                                                                                          },
                                                                                          child: const Text('Cancel')),
                                                                                      CupertinoDialogAction(
                                                                                          isDefaultAction: true,
                                                                                          onPressed: () async {
                                                                                            final prefs = await SharedPreferences.getInstance();
                                                                                            Provider.of<BeauticianData>(context, listen: false).setStoreId(prefs.getString(kStoreIdConstant));

                                                                                            Navigator.pop(context);
                                                                                            Navigator.pop(context);
                                                                                            Navigator.pushNamed(context, UpdateStockPage.id);
                                                                                          },
                                                                                          child: const Text('Update Stock')),
                                                                                    ],
                                                                                  );
                                                                                });
                                                                          }
                                                                        } else {
                                                                          Provider.of<StyleProvider>(context, listen: false).addToServiceBasket(BasketItem(
                                                                              name: nameList[index],
                                                                              quantity: quantity,
                                                                              amount: amount,
                                                                              details: description,
                                                                              tracking: trackingList[index]));
                                                                          Navigator.pop(
                                                                              context);
                                                                        }
                                                                        print(
                                                                            "THIS IS AT POS STAGE $selectedStocks with quantity to reduce ${selectedStocks[0].restock}");
                                                                      },
                                                                      style: ElevatedButton
                                                                          .styleFrom(
                                                                        shape:
                                                                            RoundedRectangleBorder(
                                                                          borderRadius:
                                                                              BorderRadius.circular(10),
                                                                        ),
                                                                        backgroundColor:
                                                                            kCustomColorPink,
                                                                      ),
                                                                      child:
                                                                          Text(
                                                                        'Add Product',
                                                                        style: kNormalTextStyle.copyWith(
                                                                            color:
                                                                                kPureWhiteColor),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                          ),

                                                        );
                                                      });
                                                },
                                                child: Column(
                                                  children: [
                                                    Card(
                                                      child: SizedBox(
                                                        height: 100,
                                                        child: ListTile(
                                                          title: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              Column(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Text(
                                                                    nameList[
                                                                        index],
                                                                    overflow:
                                                                        TextOverflow
                                                                            .clip,
                                                                    style:
                                                                        kHeadingTextStyle,
                                                                  ),
                                                                  trackingList[
                                                                              index] ==
                                                                          false
                                                                      ? Container()
                                                                      :
                                                                      // If the minimum quantity at index is greater or equal to the current quantity
                                                                      minimumList[index] >=
                                                                              quantityList[index]
                                                                          ? Text(
                                                                              "Qty: ${quantityList[index].toString()}",
                                                                              overflow: TextOverflow.clip,
                                                                              style: kHeadingTextStyle.copyWith(fontSize: 12, color: Colors.red),
                                                                            )
                                                                          : Text(
                                                                              "Qty: ${quantityList[index].toString()}",
                                                                              overflow: TextOverflow.clip,
                                                                              style: kHeadingTextStyle.copyWith(fontSize: 12, color: kGreenThemeColor),
                                                                            ),
                                                                ],
                                                              ),
                                                              Text(
                                                                "Ugx ${CommonFunctions().formatter.format(amountList[index])}",
                                                                style: kNormalTextStyle.copyWith(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color:
                                                                        kBlack,
                                                                    fontSize:
                                                                        15),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                ));
                                          }),
                                    );
                            }),
                      ),
                      // isStoreEmpty == true
                      //     ? Container()
                      //     : Positioned(
                      //     bottom: 50,
                      //     right: 5,
                      //     child: Column(
                      //       children: [
                      //         GestureDetector(
                      //           onTap: () {
                      //             showModalBottomSheet(
                      //                 isScrollControlled: true,
                      //                 context: context,
                      //                 builder: (context) {
                      //                   return Scaffold(
                      //                       appBar: AppBar(
                      //                         automaticallyImplyLeading: false,
                      //                         backgroundColor: kBlack,
                      //                       ),
                      //                       body: ProductUpload());
                      //                 });
                      //           },
                      //           child:
                      //           Lottie.asset('images/round.json', height: 50),
                      //         ),
                      //         Text(
                      //           "Create Product",
                      //           style: kNormalTextStyle.copyWith(
                      //               color: kBlueDarkColor, fontSize: 10),
                      //         )
                      //       ],
                      //     ))
                    ],
                  ),
                ),
                kMediumWidthSpacing,
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Container(
                    width: 380,
                    decoration: BoxDecoration(
                      color: kBackgroundGreyColor,
                    ),
                    child: Column(
                      children: [
                        permissionsMap['sales'] == false
                            ? Container()
                            : GestureDetector(
                                onTap: () async {
                                  final prefs =
                                      await SharedPreferences.getInstance();

                                  Provider.of<BeauticianData>(context,
                                          listen: false)
                                      .setStoreId(
                                          prefs.getString(kStoreIdConstant));

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
                                            body: CustomerSearchPage());
                                      });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Provider.of<StyleProvider>(context)
                                              .customerName ==
                                          ""
                                      ? Container(
                                          padding: EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(5),
                                            ),
                                            color: kAppPinkColor,
                                          ),
                                          child: Text(
                                            '+ Add Customer',
                                            style: kNormalTextStyle.copyWith(
                                                color: kPureWhiteColor,
                                                fontSize: 13),
                                          ))
                                      : Text(
                                          '${Provider.of<StyleProvider>(context).customerName} (${Provider.of<StyleProvider>(context).customerNumber})',
                                          style: kNormalTextStyle.copyWith(
                                              color: kBlack, fontSize: 12, fontWeight: FontWeight.w600),
                                        ),
                                ),
                              ),
                        SizedBox(
                            height: 200,
                            child: Image.asset(
                              "images/waiternew.png",
                              fit: BoxFit.cover,
                            )),
                        Expanded(child: PosSummary())
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
