import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:currency_picker/currency_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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
import 'package:stylestore/utilities/constants/user_constants.dart';

import '../../../../../Utilities/constants/color_constants.dart';
import '../../../../../Utilities/constants/font_constants.dart';

import '../../model/stock_items.dart';
import '../../model/styleapp_data.dart';
import '../../widgets/custom_popup.dart';
import '../../widgets/locked_widget.dart';
import '../barcode_page.dart';
import '../products_pages/stock_items.dart';

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



  // var amountList = [];
  var barcodeList = [];
  TextEditingController searchController = TextEditingController();
  var formatter = NumberFormat('#,###,000');
  var description = "";
  var amount = 0.0;
  var quantity = 1.0;
  var isStoreEmpty = false;
  bool empty = false;
  var currency = "";
  List<Product> products = [];
  List<AllStockData> filteredStock = [];
  List<AllStockData> newStock = [];


  List<Stock> selectedStocks = [];
  Map<String, dynamic> permissionsMap = {};
  Map<String, dynamic> videoMap = {};


  var checkBoxValue = false;

  void defaultInitialization() async {
    final prefs = await SharedPreferences.getInstance();
    currency = prefs.getString(kCurrency)??"USD";
    permissionsMap = await CommonFunctions().convertPermissionsJson();
    videoMap = await CommonFunctions().convertWalkthroughVideoJson();
    isStoreEmpty = Provider.of<StyleProvider>(context, listen: false).isStoreEmpty;
    newStock = await retrieveSupplierData();
    filteredStock.addAll(newStock);

    Provider.of<StyleProvider>(context, listen: false).resetCustomerDetails();
    setState(() {});
  }


  bool isScanning = false;

  void _showCurrencyPicker(BuildContext context) {
    showCurrencyPicker(
      context: context,
      showFlag: true, // Show currency flag
      showCurrencyName: true, // Show currency name
      showCurrencyCode: true, // Show currency code
      onSelect: (Currency currency) {
        setState(() {
          print(currency.code);
         // _selectedCurrencyCode = currency.code;
        });
      },
      favorite: ['USD', 'EUR', 'UGX'], // Can pre-select favorites
    );
  }
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

          if (filteredStock[index].tracking == true) {
            if (1 <= filteredStock[index].quantity) {
              print(description);

              Provider.of<StyleProvider>(context, listen: false)
                  .addToServiceBasket(BasketItem(
                  name: filteredStock[index].name,
                  quantity: 1.0,
                  amount: filteredStock[index].amount / 1.0,
                  details: filteredStock[index].description,
                  tracking: filteredStock[index].tracking));
              selectedStocks.add(Stock(
                  name: filteredStock[index].name,
                  id: filteredStock[index].documentId,
                  restock: 1,
                  price: filteredStock[index].amount / 1.0));
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
                        "The quantity available for ${filteredStock[index].amount} is ${filteredStock[index].quantity}! You have tried to sell 1 unit!",
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
          }
          else {
            Provider.of<StyleProvider>(context, listen: false)
                .addToServiceBasket(BasketItem(
                name: filteredStock[index].name,
                quantity: 1.0,
                amount: filteredStock[index].amount / 1.0,
                details: filteredStock[index].description,
                tracking: filteredStock[index].tracking));
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('TRACKING TRUE ${filteredStock[index].name} added')));
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
        }
        else {
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
      // if (snapshot.connectionState == ConnectionState.waiting) {
      //   return const Center(
      //     child: CircularProgressIndicator(color: kAppPinkColor,),
      //   );
      // }

      final stockDataList = snapshot.docs
          .map((doc) => AllStockData.fromFirestore(doc))
          .toList();
      if (stockDataList.isEmpty){
        empty = true;
      }
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
    return Scaffold(
      backgroundColor: kPlainBackground,
      appBar: AppBar(
        foregroundColor: kBlack,
        backgroundColor: kPlainBackground,
        automaticallyImplyLeading: widget.showBackButton,
        elevation: 0,
        centerTitle: true,
        title:  Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${Provider.of<StyleProvider>(context, listen: false).beauticianName} POS',
              style: kNormalTextStyle.copyWith(
                  fontWeight: FontWeight.bold,
                  color: kBlack,
                  fontSize: 20),
            ),
            kSmallWidthSpacing,
            GestureDetector(
              onTap: (){
                _showCurrencyPicker(context);
              },
              child: Container(
                decoration: BoxDecoration(

                  color: kPureWhiteColor,
                  borderRadius: BorderRadius.circular(5)

                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(currency, style: kNormalTextStyle.copyWith(fontSize: 12),),
                ),
              ),
            )
          ],
        ),
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

      body: permissionsMap['sales'] == false
          ? const LockedWidget(page: "Point Of Sale")
          :
      Row(children: [
            Expanded(
            child:
            Column(
              children: [
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
                empty ==true ? Center(
                  child: CustomPopupWidget(
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
                    youtubeLink: videoMap['sales'],),
                ):
                Expanded(
                  child: ListView.builder(
                      itemCount: filteredStock.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
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
                                                keyboardType:
                                                TextInputType.number,
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
                                          Text("$currency ${CommonFunctions().formatter.format(filteredStock[index].amount)}",
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
                  permissionsMap['sales'] == false ? Container() : GestureDetector(
                    onTap: () async {
                      final prefs =
                      await SharedPreferences.getInstance();

                      Provider.of<BeauticianData>(context, listen: false).setStoreId(prefs.getString(kStoreIdConstant));

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
                        style: kNormalTextStyle.copyWith(color: kBlack, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  SizedBox(
                      height: 200,
                      child: Image.asset(
                        "images/waiternew.png",
                        fit: BoxFit.cover,
                      )),
                  Expanded(child: PosSummary(currency: currency,))
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
