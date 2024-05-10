
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:stylestore/Utilities/InputFieldWidget.dart';
import 'package:stylestore/model/beautician_data.dart';
import 'package:stylestore/model/common_functions.dart';
import 'package:stylestore/model/products.dart';
import 'package:stylestore/screens/payment_pages/pos_summary.dart';
import 'package:stylestore/screens/products_pages/products_upload.dart';
import 'package:stylestore/screens/products_pages/update_stock.dart';
import 'package:stylestore/utilities/basket_items.dart';
import 'package:stylestore/screens/customer_pages/search_customer.dart';
import 'package:stylestore/widgets/scanner_widget.dart';
import '../../../../../Utilities/constants/color_constants.dart';
import '../../../../../Utilities/constants/font_constants.dart';
import '../../../../../Utilities/constants/user_constants.dart';
import '../../model/stock_items.dart';
import '../../model/styleapp_data.dart';
import '../../widgets/custom_popup.dart';
import '../../widgets/locked_widget.dart';
import '../products_pages/stock_items.dart';

class POS extends StatefulWidget {
  static String id = 'pos_widget';

  final bool showBackButton;

  const POS({Key? key, this.showBackButton = true}) : super(key: key);

  @override
  State<POS> createState() => _POSState();
}

class _POSState extends State<POS> {
  // VariablesXx
  String title = 'Your';
  String userId = 'md4348a660';
  TextEditingController searchController = TextEditingController();
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
  List<AllStockData> filteredStock = [];
  List<AllStockData> newStock = [];
  var currency = "";

  List<Stock> selectedStocks = [];
  Map<String, dynamic> permissionsMap = {};
  Map<String, dynamic> videoMap = {};


  var checkBoxValue = false;

  void defaultInitialization() async {
    final prefs = await SharedPreferences.getInstance();
    permissionsMap = await CommonFunctions().convertPermissionsJson();
    videoMap = await CommonFunctions().convertWalkthroughVideoJson();
    currency = prefs.getString(kCurrency)??"USD";
    isStoreEmpty = Provider.of<StyleProvider>(context, listen: false).isStoreEmpty;
    newStock = await retrieveSupplierData();
    filteredStock.addAll(newStock);

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
              print("THIS Didnt run RUN");
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

  Future<List<AllStockData>> retrieveSupplierData() async {

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('stores')
          .where('storeId', isEqualTo: Provider.of<StyleProvider>(context, listen: false).beauticianId)
          .where('active', isEqualTo: true)
          .where('saleable', isEqualTo: true)
          .orderBy('name', descending: false)
          .get();

      final stockDataList = snapshot.docs
          .map((doc) => AllStockData.fromFirestore(doc))
          .toList();
      return stockDataList;
    } catch (error) {
      print('Error retrieving stock data: $error');
      return []; // Return an empty list if an error occurs
    }
  }

  void filterStock(String query) {
    setState(() {
      filteredStock = newStock
          .where((stock) =>
      stock.name.toLowerCase().contains(query.toLowerCase()) ||
          stock.description.toLowerCase().contains(query.toLowerCase())
      )
          .toList();
    });
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

      backgroundColor: kBackgroundGreyColor,
      appBar: AppBar(
        foregroundColor: kBlack,
        backgroundColor: kPlainBackground,
        automaticallyImplyLeading: widget.showBackButton,
        elevation: 0,
        title:
        permissionsMap['sales'] == false
            ? Container()
            :
        GestureDetector(
          onTap: () async {
            final prefs = await SharedPreferences.getInstance();

            Provider.of<BeauticianData>(context, listen: false)
                .setStoreId(prefs.getString(kStoreIdConstant));
            Provider.of<StyleProvider>(context, listen: false).setStoreCurrency(currency);

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
          child: Container(
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
                    color: kPureWhiteColor, fontSize: 13),
              )),
        ),
        centerTitle: true,
        actions: [
          if (!kIsWeb)
            Padding(
              padding: const EdgeInsets.only(right: 30.0, top: 10),
              child: GestureDetector(
                  onTap: ()async{
                    if(await CommonFunctions().subscriptionActive() == false ){

                      CommonFunctions().buildSubscriptionPaymentModal(context);
                    }else {
                      _startBarcodeScan();
                    }
                  },
                  child: ScannerWidget())
            )
        ],
      ),
      floatingActionButton: permissionsMap['sales'] == false
          ? Container()
          : isStoreEmpty == true
          ? Container()
          : FloatingActionButton.extended(
        splashColor: Colors.green,
        backgroundColor: kAppPinkColor,
        onPressed: () async {
          // Provider.of<StyleProvider>(context, listen: false).setSelectedStockItems(selectedStocks);
          final prefs = await SharedPreferences.getInstance();
          Provider.of<BeauticianData>(context, listen: false)
              .setStoreId(prefs.getString(kStoreIdConstant));

          if (Provider.of<StyleProvider>(context, listen: false)
              .basketItems
              .length ==
              0) {
            CommonFunctions().AlertPopUpDialogueMain(context,
                imagePath: 'images/delivery.json',
                title: 'No Items Added',
                text: 'Add some Items');
          } else {
            if (Provider.of<StyleProvider>(context, listen: false)
                .customerName ==
                "") {
              Provider.of<StyleProvider>(context, listen: false)
                  .setSelectedStockItems(selectedStocks);
              CommonFunctions().AlertPopUpCustomers(context,
                  imagePath: 'images/leave.json',
                  title: 'No Customer Added',
                  text: 'Add a Customer',
                  cancelButtonText: "Continue",
                  selectedStocks: selectedStocks,
                  currency: currency
              );
            } else {
              Provider.of<StyleProvider>(context, listen: false)
                  .clearSelectedStockItems();
              Provider.of<StyleProvider>(context, listen: false)
                  .setSelectedStockItems(selectedStocks);
              showModalBottomSheet(
                  context: context,
                  builder: (context) {
                    return PosSummary(currency: currency,);
                  });
            }
          }
        }, icon: CircleAvatar(
            radius: 12,
            child: Text(
              "${Provider.of<StyleProvider>(context).basketItems.length}",
              style: kNormalTextStyle.copyWith(color: kBlack),
            )), label: Text(
          'Total: ${CommonFunctions().formatter.format(Provider.of<StyleProvider>(context).totalPrice)}',
          style: kNormalTextStyle.copyWith(color: kPureWhiteColor),
        ),
      ),
      floatingActionButtonLocation:
      FloatingActionButtonLocation.miniCenterFloat,
      body: permissionsMap['sales'] == false
          ? LockedWidget(page: "Point Of Sale")
          :
      Column(
        children: [
          Container(
            height: 100,
            decoration: const BoxDecoration(
              color: kPlainBackground,
              // borderRadius: BorderRadius.only(bottomRight: Radius.circular(20), bottomLeft: Radius.circular(20)
              // )
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(left: 10, right: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Provider.of<StyleProvider>(context).customerName == ""
                        ? Text(
                      'No Customer Selected',
                      style: kNormalTextStyle.copyWith(
                          color: kBlack, fontSize: 14),
                    )
                        : Text(
                      '${Provider.of<StyleProvider>(context).customerName} (${Provider.of<StyleProvider>(context).customerNumber})',
                      style: kNormalTextStyle.copyWith(
                          color: kBlack, fontSize: 16),
                    ),
                    kSmallHeightSpacing,
                    Text(
                      'Selected Items',
                      style: kNormalTextStyle.copyWith(
                          color: kAppPinkColor, fontSize: 12),
                    ),
                    Text(
                      '${Provider.of<StyleProvider>(context).basketNameItems.join(", ")}',
                      textAlign: TextAlign.center,
                      style: kNormalTextStyle.copyWith(
                          fontWeight: FontWeight.w500,
                          color: kBlack, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ),


          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child:  TextField(
                    controller: searchController,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: 'By Product Name / Id',
                      hintFadeDuration: Duration(milliseconds: 100),
                    ),
                    onChanged: filterStock,
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
          Expanded(
            child: ListView.builder(
                itemCount: filteredStock.length,
                itemBuilder: (context, index) {
                  return filteredStock.isEmpty ? CustomPopupWidget(
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
                    youtubeLink: videoMap['sales'],) :
                  GestureDetector(
                      onTap: () {
                        description = filteredStock[index].description;
                        amount = filteredStock[index].amount.toDouble();
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
                                    CrossAxisAlignment.start,

                                    children: [
                                      InputFieldWidget(
                                          readOnly:
                                          true,
                                          hintText:
                                          "",
                                          controller:
                                          filteredStock[index].name,
                                          onTypingFunction:
                                              (value) {},
                                          keyboardType:
                                          TextInputType
                                              .text,
                                          labelText:
                                          "Name 🔒"),
                                      InputFieldWidget(
                                          readOnly: false, hintText: "",
                                          controller: filteredStock[index].description,
                                          onTypingFunction:
                                              (value) {description = value;
                                          },
                                          keyboardType: TextInputType.text,
                                          labelText: "Description"),
                                      InputFieldWidget(
                                          readOnly: false, hintText: "",
                                          controller: "1",
                                          onTypingFunction:
                                              (value) {quantity = double.parse(value);
                                          },
                                          keyboardType: TextInputType.numberWithOptions(decimal: true),

                                          labelText: "Quantity"),
                                      InputFieldWidget(
                                          readOnly:
                                          false,
                                          hintText:
                                          "",
                                          controller:
                                          filteredStock[index].amount
                                              .toString(),
                                          onTypingFunction:
                                              (value) {
                                            amount = double.parse(value);
                                          },
                                          keyboardType: TextInputType.numberWithOptions(decimal: true),
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

                                              if (filteredStock[index].tracking == true) {
                                                if (quantity <= filteredStock[index].quantity) {
                                                  Provider.of<StyleProvider>(context, listen: false).addToServiceBasket(BasketItem(
                                                      name: filteredStock[index].name,
                                                      quantity: quantity,
                                                      amount: amount,
                                                      details: description,
                                                      tracking: filteredStock[index].tracking));
                                                  selectedStocks.add(Stock(
                                                      name: filteredStock[index].name,
                                                      id: filteredStock[index].documentId,
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
                                                            "The quantity available for ${filteredStock[index].name} is ${filteredStock[index].quantity}! You have tried to sell ${quantity} units!",
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
                                                    name: filteredStock[index].name,
                                                    quantity: quantity,
                                                    amount: amount,
                                                    details: description,
                                                    tracking: filteredStock[index].tracking
                                                )
                                                );
                                                Navigator.pop(
                                                    context);
                                              }
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
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          filteredStock[index].name,
                                          overflow:
                                          TextOverflow.clip,
                                          style:
                                          kHeadingTextStyle,
                                        ),
                                        filteredStock[index].tracking == false
                                            ? Container() :
                                        // If the minimum quantity at index is greater or equal to the current quantity
                                        filteredStock[index].minimum >= filteredStock[index].quantity
                                            ? Text("Qty: ${filteredStock[index].quantity.toString()}",
                                          overflow: TextOverflow.clip,
                                          style: kHeadingTextStyle.copyWith(fontSize: 12, color: Colors.red),
                                        )
                                            : Text("Qty: ${filteredStock[index].quantity.toString()}",
                                          overflow: TextOverflow.clip,
                                          style: kHeadingTextStyle.copyWith(fontSize: 12, color: kGreenThemeColor),
                                        ),
                                      ],
                                    ),
                                    Text("${currency} ${CommonFunctions().formatter.format(filteredStock[index].amount)}",
                                      style: kNormalTextStyle.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: kBlack, fontSize: 15),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        ],
                      ));
                }),
          ),




        ],
      ),
    );
  }
}
