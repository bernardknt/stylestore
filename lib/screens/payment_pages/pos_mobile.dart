
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
import 'package:stylestore/screens/store_pages/store_page_mobile.dart';
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
import '../../widgets/pos_summary_widget.dart';
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
  var minimumList = [];
  String storeName = "";
  var idList = [];
  var formatter = NumberFormat('#,###,000');
  var description = "";
  var amount = 0.0;
  var quantity = 1.0;
  var isStoreEmpty = false;
  List<Product> products = [];

  var currency = "";
  //
  // List<Stock> selectedStocks = [];
  Map<String, dynamic> permissionsMap = {};
  Map<String, dynamic> videoMap = {};


  var checkBoxValue = false;

  void defaultInitialization() async {
    final prefs = await SharedPreferences.getInstance();
    permissionsMap = await CommonFunctions().convertPermissionsJson();
    storeName = await CommonFunctions().getBusinessInitials();
    videoMap = await CommonFunctions().convertWalkthroughVideoJson();
    currency = prefs.getString(kCurrency)??"USD";
    isStoreEmpty = Provider.of<StyleProvider>(context, listen: false).isStoreEmpty;
    await CommonFunctions().retrieveSalableStockData(context);


    setState(() {});
  }




  bool isScanning = false;
  Future<void> startBarcodeScan() async {
    var selectedStocksOriginal  = Provider.of<StyleProvider>(context, listen: false);
    var styleData  = Provider.of<StyleProvider>(context, listen: false);
    isScanning = true;
    while (isScanning) {
      isScanning = false;
      String barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
        "#FF0000", // Custom red color for the scanner
        "Cancel", // Button text for cancelling the scan
        true, // Show flash icon
        ScanMode.BARCODE,
      );

      if (barcodeScanRes != '-1') {
        isScanning = false;
         try {
          var barcodeItem = styleData.filteredStock.firstWhere((item) => item.getByBarcode(barcodeScanRes) != null);
          if (barcodeItem != null)
          {
            if(barcodeItem.tracking == true){
              print(barcodeItem.quantity);
              if (1<=barcodeItem.quantity){
                Provider.of<StyleProvider>(context, listen: false).addToServiceBasket(BasketItem(
                    name: barcodeItem.name, quantity: 1.0,
                    amount: barcodeItem.amount / 1.0,
                    details: barcodeItem.description,
                    tracking: barcodeItem.tracking));
                selectedStocksOriginal.addToOriginalSelectedStock(Stock(name: barcodeItem.name, id: barcodeItem.documentId, restock: 1, price: barcodeItem.amount / 1.0));
                CommonFunctions().playBeepSound();
                showDialog(context: context, builder: ( context) {return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [CircularProgressIndicator(color: kAppPinkColor,),
                        kSmallHeightSpacing,
                        DefaultTextStyle(
                          style: kNormalTextStyle.copyWith(color: kPureWhiteColor),
                          child: Text("${barcodeItem.name} Added", textAlign: TextAlign.center,),
                        )
                        // Text("Loading Contacts", style: kNormalTextStyle.copyWith(color: kPureWhiteColor),)
                      ],));});
                await Future.delayed(const Duration(seconds: 1));
                Navigator.pop(context);
                startBarcodeScan();

              }
              else {

                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return CupertinoAlertDialog(
                        title: const Text('OUT OF STOCK'),
                        content: Text(
                          "The quantity available for ${barcodeItem.name} is ${barcodeItem.quantity}! You have tried to sell 1 unit!",
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
              Provider.of<StyleProvider>(context, listen: false).addToServiceBasket(BasketItem(
                  name: barcodeItem.name, quantity: 1.0,
                  amount: barcodeItem.amount / 1.0,
                  details: barcodeItem.description,
                  tracking: barcodeItem.tracking));
              selectedStocksOriginal.addToOriginalSelectedStock(Stock(name: barcodeItem.name, id: barcodeItem.documentId, restock: 1, price: barcodeItem.amount / 1.0));
              CommonFunctions().playBeepSound();
              showDialog(context: context, builder: ( context) {return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [CircularProgressIndicator(color: kAppPinkColor,),
                      kSmallHeightSpacing,
                      DefaultTextStyle(
                        style: kNormalTextStyle.copyWith(color: kPureWhiteColor),
                        child: Text("${barcodeItem.name} Added", textAlign: TextAlign.center,),
                      )
                      // Text("Loading Contacts", style: kNormalTextStyle.copyWith(color: kPureWhiteColor),)
                    ],));});
              await Future.delayed(const Duration(seconds: 1));
              Navigator.pop(context);
              startBarcodeScan();
            }

            print("${barcodeItem.name} ${barcodeItem.tracking} Item Exists");
          } else{

          }
          // Use barcodeItem here
        } on StateError catch (e) {
          // Handle the case where no element is found (e.g., show a message)
          print("Item does not Exist");
          isScanning = false;
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Item is not in your Inventory')));
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return CupertinoAlertDialog(
                title: Text("ITEM BARCODE NOT FOUND?"),
                content: Text("This could mean either the item is not in the inventory or is not set 'For Sale'\nWould you like to add this item to the inventory?"),
                actions: [
                  CupertinoDialogAction(
                    child: const Text(
                      "Cancel", style: TextStyle(color: kRedColor),),
                    onPressed: () {
                      Navigator.of(context).pop();// Close the dialog

                    },
                  ),
                  CupertinoDialogAction(
                    child: const Text("Add to Inventory"),
                    onPressed: () {
                      Navigator.of(context).pop();
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
                                body: StorePageMobile());
                          });



                    },
                  ),
                ],
              );
            },
          );
        }

      }
      else{


      }
    }
  }


  void _showCurrencyPicker(BuildContext context) {
    showCurrencyPicker(
      context: context,
      showFlag: true, // Show currency flag
      showCurrencyName: true, // Show currency name
      showCurrencyCode: true, // Show currency code
      onSelect: (Currency currency) async{
        final prefs = await SharedPreferences.getInstance();
        prefs.setString(kCurrency, currency.code);
        Provider.of<StyleProvider>(context, listen: false).setStoreCurrency(currency.code);

        setState((){

        });
      },
      favorite: ['USD', 'EUR', 'UGX', 'KES'], // Can pre-select favorites
    );
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    defaultInitialization();
  }

  @override
  Widget build(BuildContext context) {
    var styleDataListen = Provider.of<StyleProvider>(context);
    var styleData = Provider.of<StyleProvider>(context, listen: false);
    var selectedStocksOriginal  = Provider.of<StyleProvider>(context, listen: false);
    return Scaffold(

      backgroundColor: kBackgroundGreyColor,
      appBar: AppBar(
        foregroundColor: kBlack,
        backgroundColor: kPlainBackground,
        automaticallyImplyLeading: widget.showBackButton,
        elevation: 0,
        title:permissionsMap['sales'] == false
            ? Container(): Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${storeName} POS',
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
                  child: Text( currency, style: kNormalTextStyle.copyWith(fontSize: 12),),
                ),
              ),
            )
          ],
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
                        startBarcodeScan();
                      }
                    },
                    child: const ScannerWidget(backgroundColor: kGreenThemeColor,))
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

          if (Provider.of<StyleProvider>(context, listen: false).basketItems.length == 0) {
            CommonFunctions().AlertPopUpDialogueMain(context,
                imagePath: 'images/delivery.json',
                title: 'No Items Added',
                text: 'Add some Items');
          } else {
            if (Provider.of<StyleProvider>(context, listen: false)
                .customerName ==
                "") {
              Provider.of<StyleProvider>(context, listen: false)
                  .setSelectedStockItems(selectedStocksOriginal.originalSelectedStock);
              CommonFunctions().AlertPopUpCustomers(context,
                  imagePath: 'images/leave.json',
                  title: 'No Customer Added',
                  text: 'Add a Customer',
                  cancelButtonText: "Continue",
                  selectedStocks: selectedStocksOriginal.originalSelectedStock,
                  currency: currency
              );
            } else {
              Provider.of<StyleProvider>(context, listen: false)
                  .clearSelectedStockItems();
              Provider.of<StyleProvider>(context, listen: false)
                  .setSelectedStockItems(selectedStocksOriginal.originalSelectedStock);
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
                padding:EdgeInsets.only(left: 10, right: 10, bottom: 10),
                child:
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [permissionsMap['sales'] == false
                      ? Container()
                      : GestureDetector(
                    onTap: () async {
                      final prefs = await SharedPreferences.getInstance();

                      Provider.of<BeauticianData>(context, listen: false).setStoreId(prefs.getString(kStoreIdConstant));
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
                                body:
                                CustomerSearchPage());
                          });
                    },
                    child: Container(
                      height: 100,
                      width: 100,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: kBackgroundGreyColor
                      ),
                      child: Provider.of<StyleProvider>(context).customerName == ""
                          ? Center(
                        child: Text(
                          'No Customer Selected',textAlign: TextAlign.center,
                          style: kNormalTextStyle.copyWith(
                              color: kBlack, fontSize: 12),
                        ),
                      )
                          : Center(
                        child: Padding(
                          padding: const EdgeInsets.all(3.0),
                          child: Text(
                            '${Provider.of<StyleProvider>(context).customerName} (${Provider.of<StyleProvider>(context).customerNumber})',textAlign: TextAlign.center,
                            style: kNormalTextStyle.copyWith(
                                color: kBlack, fontSize: 12),
                          ),
                        ),
                      ),
                    ),
                  ),

                    kMediumWidthSpacing,
                    kMediumWidthSpacing,
                    Expanded(
                      child: SizedBox(
                        height: 100,

                        child: ListView.builder(itemCount: styleDataListen.basketItems.length,
                          itemBuilder: (context, index) {
                            return buildItemRow(context, styleDataListen.basketItems[index],currency, kBlack,index);},),
                      ),
                    )

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
                    onChanged: styleData.filterStockQuery,
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
                itemCount: styleDataListen.filteredStock.length,
                itemBuilder: (context, index) {

                  return styleData.filteredStock.isEmpty ?
                  //Text("It is working")
                  CustomPopupWidget(
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
                                appBar: AppBar(automaticallyImplyLeading:
                                false, backgroundColor: kBlack,
                                ),
                                body: ProductUpload());
                          });
                    },
                    youtubeLink: videoMap['sales'],)
                      : GestureDetector(
                      onTap: () {
                        description = styleData.filteredStock[index].description;
                        amount = styleData.filteredStock[index].amount.toDouble();
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
                                          styleData.filteredStock[index].name,
                                          onTypingFunction:
                                              (value) {},
                                          keyboardType:
                                          TextInputType
                                              .text,
                                          labelText:
                                          "Name 🔒"),
                                      InputFieldWidget(
                                          readOnly: false, hintText: "",
                                          controller: styleData.filteredStock[index].description,
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
                                          styleData.filteredStock[index].amount
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

                                              if (styleData.filteredStock[index].tracking == true) {
                                                if (quantity <= styleData.filteredStock[index].quantity) {
                                                  Provider.of<StyleProvider>(context, listen: false).addToServiceBasket(BasketItem(
                                                      name: styleData.filteredStock[index].name,
                                                      quantity: quantity,
                                                      amount: amount,
                                                      details: description,
                                                      tracking: styleData.filteredStock[index].tracking));
                                                  selectedStocksOriginal.addToOriginalSelectedStock(Stock(
                                                      name: styleData.filteredStock[index].name,
                                                      id: styleData.filteredStock[index].documentId,
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
                                                            "The quantity available for ${styleData.filteredStock[index].name} is ${styleData.filteredStock[index].quantity}! You have tried to sell ${quantity} units!",
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
                                                    name: styleData.filteredStock[index].name,
                                                    quantity: quantity,
                                                    amount: amount,
                                                    details: description,
                                                    tracking: styleData.filteredStock[index].tracking
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
                                          styleData.filteredStock[index].name,
                                          overflow:
                                          TextOverflow.clip,
                                          style:
                                          kHeadingTextStyle,
                                        ),
                                        Text(styleData.filteredStock[index].description,
                                            style: kNormalTextStyleSmallGrey.copyWith(fontSize: 12, fontWeight: FontWeight.w500)),
                                        Row(
                                          children: [
                                            Icon(Iconsax.barcode, size: 15, color: kFontGreyColor,),
                                            kSmallWidthSpacing,
                                            Text(styleData.filteredStock[index].barcode,
                                                style: kNormalTextStyleSmallGrey),
                                          ],
                                        ),
                                        styleData.filteredStock[index].tracking == false
                                            ? Container() :
                                        // If the minimum quantity at index is greater or equal to the current quantity
                                        styleData.filteredStock[index].minimum >= styleData.filteredStock[index].quantity
                                            ? Text("Qty: ${styleData.filteredStock[index].quantity.toString()}",
                                          overflow: TextOverflow.clip,
                                          style: kHeadingTextStyle.copyWith(fontSize: 12, color: Colors.red),
                                        )
                                            : Text("Qty: ${styleData.filteredStock[index].quantity.toString()}",
                                          overflow: TextOverflow.clip,
                                          style: kHeadingTextStyle.copyWith(fontSize: 12, color: kGreenThemeColor),
                                        ),
                                      ],
                                    ),
                                    Text("${currency} ${CommonFunctions().formatter.format(styleData.filteredStock[index].amount)}",
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
