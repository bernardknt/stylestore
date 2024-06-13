import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stylestore/Utilities/constants/color_constants.dart';
import 'package:stylestore/Utilities/constants/user_constants.dart';
import 'package:stylestore/screens/products_pages/products_upload.dart';
import 'package:stylestore/screens/products_pages/stock_items.dart';
import '../../Utilities/constants/font_constants.dart';
import '../../model/beautician_data.dart';
import '../../model/common_functions.dart';
import '../../model/stock_items.dart';
import '../../model/styleapp_data.dart';
import '../../utilities/constants/word_constants.dart';
import '../../widgets/scanner_widget.dart';
import '../store_pages/store_page_mobile.dart';


class UpdateStockPage extends StatefulWidget {
  static String id = "update_stock";
  @override
  _UpdateStockPageState createState() => _UpdateStockPageState();

}

class _UpdateStockPageState extends State<UpdateStockPage> {
  late Stream<QuerySnapshot> _customerStream;
  TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  var basketToPost = [];
  String updateOrderNumber = "";
  var nameList = [];
  var itemIdList = [];
  var descriptionList = [];
  var quantityList = [];
  var minimumList = [];
  var barcodeList = [];
  Color mainColor = kPureWhiteColor;
  bool isScanning = false;
  List<AllStockData> newStock = [];

  Future<void> _startBarcodeScan() async {
    isScanning = true;
    while(isScanning) {
      isScanning = false;

      String barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
        "#FF0000", // Custom red color for the scanner
        "Cancel", // Button text for cancelling the scan
        true, // Show flash icon
        ScanMode.BARCODE, // Specify the scan mode (BARCODE, QR)
      );
      print("Here is barcodeRes: $barcodeScanRes");
      if (barcodeScanRes != '-1') {
        try{
          var barcodeItem = newStock.firstWhere((item) => item.getByBarcode(barcodeScanRes) != null);
          print("We reached this point: ${barcodeItem}");
          if (barcodeItem != null) {

            CommonFunctions().playBeepSound();

            isScanning = false;
         //   selectedStocks.add(Stock(name: barcodeItem.name, id: barcodeItem.documentId, restock: 0, description:barcodeItem.description));
            Provider.of<StyleProvider>(context, listen: false).setSelectedUnit(barcodeItem.unit);
            showPriceAndQuantityDialogForBarScanner(barcodeItem.name, barcodeItem.documentId, barcodeItem.description);

          } else
          {

            isScanning = false;
            ScaffoldMessenger.of(context).showSnackBar( SnackBar(content: Text('Item is not in your Inventory')));
            // Navigator.pop(context);
          }
        }on StateError catch (e)
        {
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
                content: Text("This could mean either the item is not in the inventory or is not set 'Trackable'\nWould you like to add this item to the inventory, or change its property to Trackable?"),
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
                                backgroundColor: kPlainBackground,
                                foregroundColor: kBlack,
                                automaticallyImplyLeading: false,
                              ),
                              body: Scaffold(
                                  appBar: AppBar(
                                    elevation: 0,
                                    title: Text("Drag down to Go Back"),
                                    centerTitle: true,
                                    backgroundColor: kPureWhiteColor,
                                    foregroundColor: kBlack,
                                    automaticallyImplyLeading: false,
                                  ),
                                  body: StorePageMobile()),
                            );
                          });



                    },
                  ),
                ],
              );
            },
          );
        }
      }
    }
  }
  // Future<void> _startBarcodeScan() async {
  //   isScanning = true;
  //   while(isScanning) {
  //     isScanning = false;
  //
  //     String barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
  //       "#FF0000", // Custom red color for the scanner
  //       "Cancel", // Button text for cancelling the scan
  //       true, // Show flash icon
  //       ScanMode.BARCODE, // Specify the scan mode (BARCODE, QR)
  //     );
  //     print("Here is barcodeRes: $barcodeScanRes");
  //     if (barcodeScanRes != '-1') {
  //       print("We reached this point");
  //
  //       int index = barcodeList.indexOf(barcodeScanRes);
  //       print("The int value is : $index");
  //
  //       if (index != -1) {
  //         CommonFunctions().playBeepSound();
  //         isScanning = false;
  //
  //         quantityControllers[index]?.text = '0';
  //         // Add the selected stock to the list.
  //         selectedStocks.add(Stock(name: nameList[index], id: itemIdList[index], restock: 0, description: descriptionList[index]));
  //
  //         showPriceAndQuantityDialogForBarScanner(nameList[index], itemIdList[index], descriptionList[index] );
  //       } else {
  //         isScanning = false;
  //         ScaffoldMessenger.of(context).showSnackBar( SnackBar(content: Text('Item is not in your Inventory')));
  //
  //       }
  //     }
  //   }
  // }
  void defaultInitialization()async{
    final prefs = await SharedPreferences.getInstance();
    var storeId = prefs.getString(kStoreIdConstant);
    updateOrderNumber = "UP_${CommonFunctions().generateUniqueID(prefs.getString(kBusinessNameConstant)!)}";
    newStock = await CommonFunctions().retrieveStockTrackedData(context);

  }
  TextEditingController _getOrCreateController(int index) {
    if (!quantityControllers.containsKey(index)) {
      quantityControllers[index] = TextEditingController();
    }
    return quantityControllers[index]!;
  }
  // Helper function to show the popup.
  void _showPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Please check this item first.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showPriceAndQuantityDialog( String name, id, unit, description) async {
    double? inputPrice;
    double? inputQuantity;

    await
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return
          AlertDialog(
            title: Text('Update for $name', textAlign: TextAlign.center, style: kNormalTextStyle.copyWith(color: kBlack,fontWeight: FontWeight.bold, fontSize: 16),),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      flex: 4,
                      child: TextField(
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                        onChanged: (value) {
                          inputQuantity = double.tryParse(value);
                        },
                        decoration: InputDecoration(
                          labelText: 'Quantity',
                          hintText: 'Available quantity',
                        ),
                      ),
                    ),
                    kSmallWidthSpacing,
                    Expanded(
                      flex: 2,
                      child: Container(
                        height: 45,
                        // width: 30,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: kBackgroundGreyColor,

                        ),
                        child:

                        Padding(
                          padding: const EdgeInsets.only(left: 20.0),
                          child: DropdownButton<String>(
                            style: kNormalTextStyle.copyWith(color: kBlack),
                            icon: Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Icon(Icons.scale, color: kFontGreyColor,),
                            ),
                            dropdownColor: kBackgroundGreyColor,
                            iconSize: 14,
                            value: Provider.of<StyleProvider>(context, listen: true).selectedUnit, // The currently selected department
                            items: unitList
                                .map((units) => DropdownMenuItem(
                              value: units,
                              child: Text(units,),
                            ))
                                .toList(),
                            onChanged: (newItem) => setState(() => Provider.of<StyleProvider>(context, listen: false).setSelectedUnit(newItem)), // Update the selected department when a new one is chosen
                            hint: Text(
                              'Select Unit', style: kNormalTextStyle.copyWith(color: kPureWhiteColor),), // Placeholder text before a department is selected
                          ),
                        ),
                        //Center(child: Text(unit)),
                      ),
                    )
                  ],
                ),

              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Cancel', style: kNormalTextStyle.copyWith(color: kFontGreyColor),),
              ),
              TextButton(
                onPressed: () {
                  print(Provider.of<StyleProvider>(context, listen: false).selectedUnit);
                  if (inputQuantity != null) {

                    setState(() {

                      selectedStocks.add(Stock(price: 0.0, name: name, id: id, restock: inputQuantity!, description:description, unit: Provider.of<StyleProvider>(context, listen: false).selectedUnit, quality: "ok"));
                      Provider.of<StyleProvider>(context, listen: false).addSelectedStockList(name);

                    });
                  }
                  setState(() {

                  });
                  Navigator.pop(context);
                },
                child: Text('OK', style: kNormalTextStyle.copyWith(color: kGreenThemeColor, fontSize: 16),),
              ),
            ],
          );
      },
    );
  }

  Future<void> showPriceAndQuantityDialogForBarScanner( String name, id, description) async {
    double? inputPrice;
    double? inputQuantity;

    await
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return
          AlertDialog(
            title: Text('Update for $name', textAlign: TextAlign.center, style: kNormalTextStyle.copyWith(color: kBlack,fontWeight: FontWeight.bold, fontSize: 16),),
            content: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  flex: 4,
                  child: TextField(
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    onChanged: (value) {
                      inputQuantity = double.tryParse(value);
                    },
                    decoration: InputDecoration(
                      labelText: 'Quantity',
                      hintText: 'Enter available quantity',
                    ),
                  ),
                ),
                kSmallWidthSpacing,
                Expanded(
                  flex: 2,
                  child:
                  Container(
                    // height: 45,
                    // width: 30,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: kBackgroundGreyColor,

                    ),
                    child:

                    Padding(
                      padding: const EdgeInsets.only(left: 20.0),
                      child:
                      DropdownButton<String>(
                        style: kNormalTextStyle.copyWith(color: kBlack),
                        icon: Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Icon(Icons.scale, color: kFontGreyColor,),
                        ),
                        dropdownColor: kBackgroundGreyColor,
                        iconSize: 12,
                        value: Provider.of<StyleProvider>(context, listen: true).selectedUnit, // The currently selected department
                        items: unitList
                            .map((units) => DropdownMenuItem(
                          value: units,
                          child: Text(units,),
                        ))
                            .toList(),
                        onChanged: (newItem) => setState(() => Provider.of<StyleProvider>(context, listen: false).setSelectedUnit(newItem)), // Update the selected department when a new one is chosen
                        hint: Text(
                          'Select Unit', style: kNormalTextStyle.copyWith(color: kPureWhiteColor),), // Placeholder text before a department is selected
                      ),
                    ),
                    //Center(child: Text(unit)),
                  ),
                )
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Cancel', style: kNormalTextStyle.copyWith(color: kFontGreyColor),),
              ),
              TextButton(
                onPressed: ()async {
                  print(Provider.of<StyleProvider>(context, listen: false).selectedUnit);
                  if (inputQuantity != null) {

                    setState(() {
                      selectedStocks.add(Stock(price: 0.0, name: name, id: id, restock: inputQuantity!, description:description, unit: Provider.of<StyleProvider>(context, listen: false).selectedUnit, quality: "ok"));
                      Provider.of<StyleProvider>(context, listen: false).addSelectedStockList(name);

                    });
                  }
                  setState(() {

                  });
                  Navigator.pop(context);
                  await Future.delayed(const Duration(seconds: 1));

                  _startBarcodeScan();
                },
                child: Text('OK', style: kNormalTextStyle.copyWith(color: kGreenThemeColor, fontSize: 16),),
              ),
            ],
          );
      },
    );
  }


  void _handleUpdateStockButton() {

    for(var i = 0; i < selectedStocks.length; i ++){
      print("${selectedStocks[i].name}: ${selectedStocks[i].restock}");
      basketToPost.add( {
        'product' : selectedStocks[i].name,
        'description':selectedStocks[i].description,
        'quantity': selectedStocks[i].restock,
        'totalPrice':selectedStocks[i].price,
        'unit': selectedStocks[i].unit
      }
      );
    }
    CommonFunctions().uploadUpdatedStockItems(selectedStocks, context, basketToPost,updateOrderNumber );

  }

  @override
  void initState() {
    super.initState();
    defaultInitialization();
    _customerStream = FirebaseFirestore.instance.collection('stores').where('active', isEqualTo: true)
        .where('storeId',

       isEqualTo:Provider.of<BeauticianData>(context, listen: false).storeId
    )
        .where('tracking', isEqualTo: true)
        .orderBy('name',descending: false).snapshots();
  }

  // Map<int, bool> checkboxStates = {}; // Map to track checkbox states.
  Map<int, TextEditingController> quantityControllers = {}; // Map to track quantity text controllers.
  List<Stock> selectedStocks = []; // List to store selected stocks.


  @override
  Widget build(BuildContext context) {
    var styleDataListen = Provider.of<StyleProvider>(context, listen: true);
    var styleData = Provider.of<StyleProvider>(context, listen: true);
    return Scaffold(
      backgroundColor: kBlack,
      appBar: AppBar(
        foregroundColor: kPureWhiteColor,
        title: Text("Check/Update Items", style: kHeading3TextStyleBold.copyWith(fontSize: 16, color: kPureWhiteColor),),
        centerTitle: true,
        elevation: 0,
        backgroundColor: kAppPinkColor,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child:
            Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: Row(
                children: [
                  TextButton(
                    style: ButtonStyle(backgroundColor: CommonFunctions().convertToMaterialStateProperty(kBlack)),
                    onPressed: () async {

                      Navigator.pushNamed(context, ProductUpload.id);


                    }, child: Text("+ Product", style: kNormalTextStyle.copyWith(color: kPureWhiteColor),),),
                ],
              ),
            ),
          )
        ],
        // title: Text('Customer List'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        splashColor: Colors.green,
        backgroundColor: kAppPinkColor,
        onPressed: () {
          // Handle the "Update Stock" button press.
          if(selectedStocks.length == 0){
            CommonFunctions().showErrorDialog("No Items have been Updated!\nPlease update some items First", context);
          }else {
            _handleUpdateStockButton();
          }


        },
        icon:  CircleAvatar(
            radius: 12,
            child: Text("${selectedStocks.length}", style:kNormalTextStyle.copyWith(color: kBlack) ,)),
        label: Text(
          'Update Stock',
          style: kNormalTextStyle.copyWith(color: kPureWhiteColor),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniCenterFloat,
      body:
      SafeArea(
        child:
        Center(
          child: Container(
            width: MediaQuery.of(context).size.width > 600 ? 400 : MediaQuery.of(context).size.width * 0.8,

            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 15.0, top: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      kIsWeb?Container():GestureDetector(
                        onTap: ()async{
                          if(await CommonFunctions().subscriptionActive() == false ){

                            CommonFunctions().buildSubscriptionPaymentModal(context);
                          }else {
                            _startBarcodeScan();
                          }
                        },
                        child:
                        const ScannerWidget(),),
                    ],
                  ),
                ),
                kSmallHeightSpacing,
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Stack(
                    children: [
                      TextField(
                        controller: searchController,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.search, color: kPureWhiteColor,),
                          hintText: 'By Product Name / Id',
                          hintFadeDuration: Duration(milliseconds: 100),
                        ),
                        style: kNormalTextStyle.copyWith(color: kPureWhiteColor),
                        onChanged: styleData.filterStockQuery,
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(left: 20.0, right: 20),
                  child: Row(
                    children: [
                      Text("Add |", style: kNormalTextStyle.copyWith(color: mainColor),),
                      kSmallWidthSpacing,
                      kSmallWidthSpacing,
                      Text("Item", style: kNormalTextStyle.copyWith(color:mainColor),),
                      const Spacer(),
                      Text("Current level |", style: kNormalTextStyle.copyWith(color: mainColor),),
                      kSmallWidthSpacing,
                      kSmallWidthSpacing,
                      Text("Stock", style: kNormalTextStyle.copyWith(color: mainColor),),

                    ],
                  ),
                ),

                Expanded(
                    child:

                    ListView.builder(
                      itemCount: styleDataListen.filteredStock.length,
                      itemBuilder: (context, index) {




                        if (!quantityControllers.containsKey(index)) {
                          // Initialize quantity text controller when the item is first shown.
                          quantityControllers[index] = TextEditingController();
                        }

                        return ListTile(
                          // title: Text(name, style: kNormalTextStyle.copyWith(color: kPureWhiteColor)),
                          subtitle: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [

                              GestureDetector(
                                onTap: ()
                                {

                                  if(!styleDataListen.selectedStock.contains(styleData.filteredStock[index].name)){
                                    Provider.of<StyleProvider>(context, listen: false).setSelectedUnit(styleData.filteredStock[index].unit);
                                    _showPriceAndQuantityDialog(styleData.filteredStock[index].name , styleData.filteredStock[index].documentId, styleData.filteredStock[index].unit,
                                      styleData.filteredStock[index].description,
                                    );
                                    quantityControllers[index]?.text = '0';
                                    //selectedStocks.add(Stock(name: filteredStock[index].name, id: filteredStock[index].documentId, restock: 0, description:filteredStock[index].description));
                                  }else {
                                    Provider.of<StyleProvider>(context, listen: false).removeSelectedStockList(styleData.filteredStock[index].name);
                                    selectedStocks.removeWhere((stock) => stock.name == styleData.filteredStock[index].name);
                                    // selectedStocks.add(Stock(name: name, id: id, restock: inputQuantity!, description:description, unit: Provider.of<StyleProvider>(context, listen: false).selectedUnit, quality: selectedQuality!.name));

                                    setState(() {

                                    });
                                  }
                                },
                                child: Row(
                                  children: [
                                    styleDataListen.selectedStock.contains(styleData.filteredStock[index].name)?Icon(Icons.check_box_outlined, color: kBeigeColor,):Icon(Icons.check_box_outline_blank_outlined, color: kPlainBackground,),
                                    kMediumWidthSpacing,
                                    Container(
                                      width: 140,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('${styleData.filteredStock[index].name}',overflow: TextOverflow.ellipsis, style: kNormalTextStyle.copyWith(color: mainColor)),
                                          Text('${styleData.filteredStock[index].description}',overflow: TextOverflow.ellipsis, style: kNormalTextStyle.copyWith()),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),



                              Spacer(),
                              styleData.filteredStock[index].minimum  < styleData.filteredStock[index].quantity ? Text('${styleData.filteredStock[index].quantity} ', style: kNormalTextStyle.copyWith(color: mainColor)):Text('${styleData.filteredStock[index].quantity} ', style: kNormalTextStyle.copyWith(color: Colors.red)),
                              kSmallWidthSpacing,
                              // kSmallWidthSpacing,
                              // kSmallWidthSpacing,
                              GestureDetector(
                                onTap: ()
                                {

                                  if(!styleDataListen.selectedStock.contains(styleData.filteredStock[index].name)){
                                    Provider.of<StyleProvider>(context, listen: false).setSelectedUnit(styleData.filteredStock[index].unit);
                                    _showPriceAndQuantityDialog(
                                      styleData.filteredStock[index].name,
                                      styleData.filteredStock[index].documentId,
                                      styleData.filteredStock[index].unit,
                                      styleData.filteredStock[index].description,
                                    );
                                    quantityControllers[index]?.text = '0';
                                    // selectedStocks.add(Stock(name: filteredStock[index].name, id: filteredStock[index].documentId, restock: 0, description:filteredStock[index].description));
                                  }else {

                                    selectedStocks.removeWhere((stock) => stock.name == styleData.filteredStock[index].name);
                                  }
                                },
                                child: Container(
                                  width: 60,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                  ),
                                  child: Center(
                                    child: Container(
                                        height: 70,
                                        width:120,
                                        decoration: BoxDecoration(
                                            border: Border.all(color: kBlack)
                                        ),
                                        child: Center(
                                          child:
                                          //Text("1"))
                                          styleDataListen.selectedStock.contains(styleData.filteredStock[index].name)?
                                          Text(selectedStocks[ selectedStocks.indexWhere((stock) => stock.name == styleData.filteredStock[index].name)].restock.toString(), style: kNormalTextStyle.copyWith(color: kBeigeColor),):
                                          Container(),)
                                    ),

                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    )
                ),
              ],
            ),
          ),
        ),
      ),
      // SafeArea(
      //   child: Stack(
      //     children: [
      //       Column(
      //         children: [
      //
      //           kLargeHeightSpacing,
      //
      //           kIsWeb?Container():GestureDetector(
      //             onTap: ()async{
      //               if(await CommonFunctions().subscriptionActive() == false ){
      //
      //                 CommonFunctions().buildSubscriptionPaymentModal(context);
      //               }else {
      //                 _startBarcodeScan();
      //               }
      //             },
      //             child:
      //             const ScannerWidget(backgroundColor: kCustomColor,scannerColor: kBlack,)
      //           ),
      //           kSmallHeightSpacing,
      //           Padding(
      //             padding: const EdgeInsets.only(left: 20.0, right: 20),
      //             child: Row(
      //               children: [
      //                 Text("Add |", style: kNormalTextStyle.copyWith(color: kBeigeColor),),
      //                 kSmallWidthSpacing,
      //                 kSmallWidthSpacing,
      //                 Text("Item", style: kNormalTextStyle.copyWith(color: kBeigeColor),),
      //                 Spacer(),
      //                 Text("Current level |", style: kNormalTextStyle.copyWith(color: kBeigeColor),),
      //                 kSmallWidthSpacing,
      //                 kSmallWidthSpacing,
      //                 Text("Stock", style: kNormalTextStyle.copyWith(color: kBeigeColor),),
      //
      //               ],
      //             ),
      //           ),
      //           Expanded(
      //             child: _searchResults.isEmpty
      //                 ?
      //             StreamBuilder<QuerySnapshot>(
      //               stream: _customerStream,
      //               builder: (context, snapshot) {
      //                 if (snapshot.hasError) {
      //                   return Center(
      //                     child: Text('Error: ${snapshot.error}'),
      //                   );
      //                 }
      //
      //                 if (snapshot.connectionState == ConnectionState.waiting) {
      //                   return Center(
      //                     child: CircularProgressIndicator(),
      //                   );
      //                 }
      //
      //                 if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
      //                   return Center(
      //                     child: Text('No items found.',style: kNormalTextStyle.copyWith(color: kPureWhiteColor),),
      //                   );
      //                 }
      //                 var stocks = snapshot.data!.docs;
      //                 barcodeList = [];
      //                 nameList = [];
      //                 minimumList = [];
      //                 quantityList = [];
      //                 for (var stock in stocks) {
      //                   barcodeList.add(stock.get('barcode'));
      //                   nameList.add(stock.get('name'));
      //                   minimumList.add(stock.get('minimum'));
      //                   quantityList.add(stock.get('quantity'));
      //                   descriptionList.add(stock.get('description'));
      //                   itemIdList.add(stock.get('id'));
      //
      //                 }
      //                 return ListView.builder(
      //                   itemCount: snapshot.data!.docs.length,
      //                   itemBuilder: (context, index) {
      //                     var item = snapshot.data!.docs[index];
      //                     var name = item['name'];
      //                     var amount = item['amount'];
      //                     var description = item['description'];
      //                     var quantity = item['quantity'];
      //                     var minimum = item['minimum'];
      //
      //                     // Define a TextEditingController to handle the quantity input in the TextField.
      //                     TextEditingController quantityController = TextEditingController();
      //
      //                     if (!checkboxStates.containsKey(index)) {
      //                       // Initialize checkbox state when the item is first shown.
      //                       checkboxStates[index] = false;
      //                     }
      //
      //                     if (!quantityControllers.containsKey(index)) {
      //                       // Initialize quantity text controller when the item is first shown.
      //                       quantityControllers[index] = TextEditingController();
      //                     }
      //
      //                     return ListTile(
      //                       // title: Text(name, style: kNormalTextStyle.copyWith(color: kPureWhiteColor)),
      //                       subtitle: Row(
      //                         crossAxisAlignment: CrossAxisAlignment.center,
      //                         mainAxisAlignment: MainAxisAlignment.start,
      //                         children: [
      //                           // Text('${CommonFunctions().formatter.format(amount)}', style: kNormalTextStyle.copyWith(color: kPureWhiteColor)),
      //                           Checkbox(
      //                             fillColor: CommonFunctions().convertToMaterialStateProperty(kBeigeColor),
      //                             checkColor: kBlack,
      //                             value: checkboxStates[index], // Add your own logic here to set the value of the checkbox.
      //                             onChanged: (value) {
      //
      //                               setState(() {
      //                                 bool newValue = value ?? false;
      //                                 checkboxStates[index] = newValue;
      //                                 // Set the default value of the TextField to 0 when the checkbox is checked.
      //                                 if (newValue) {
      //                                   _showPriceAndQuantityDialog(index, name, item.id, description );
      //                                   quantityControllers[index]?.text = '0';
      //
      //                                   // Add the selected stock to the list.
      //                                   selectedStocks.add(Stock(name: name, id: item.id, restock: 0));
      //                                 } else {
      //                                   // Remove the selected stock from the list.
      //                                   selectedStocks.removeWhere((stock) => stock.id == item.id);
      //                                 }
      //                               });
      //                               // Add your logic to handle checkbox value change.
      //                             },
      //                           ),
      //                           Column(
      //                             crossAxisAlignment: CrossAxisAlignment.start,
      //                             children: [
      //                               Text('$name', style: kNormalTextStyle.copyWith(color: kPureWhiteColor)),
      //                               Text('($description)', style: kNormalTextStyle.copyWith(color: kPureWhiteColor)),
      //                             ],
      //                           ),
      //
      //
      //                           Spacer(),
      //                           minimum  < quantity ? Text('$quantity ', style: kNormalTextStyle.copyWith(color: kPureWhiteColor)):Text('$quantity ', style: kNormalTextStyle.copyWith(color: Colors.red)),
      //                           kSmallWidthSpacing,
      //                           kSmallWidthSpacing,
      //                           kSmallWidthSpacing,
      //                           GestureDetector(
      //                             onTap: (){
      //                               if (!checkboxStates[index]!) {
      //                                 // Show the popup only when the TextField is disabled (checkbox is unchecked).
      //                                 _showPopup(context);
      //                               }
      //                             },
      //                             child: Container(
      //                               width: 60,
      //                               height: 30,
      //                               decoration: BoxDecoration(
      //                                 border: Border.all(color: Colors.grey),
      //                               ),
      //                               child: Center(
      //                                 child: TextField(
      //
      //                                   enabled: checkboxStates[index], // Set the TextField's editable state based on checkbox state.
      //                                   controller: _getOrCreateController(index),
      //                                   //quantityControllers[index],
      //                                   textAlign: TextAlign.center,
      //                                   keyboardType: TextInputType.numberWithOptions(decimal: true),
      //                                   style: kNormalTextStyle.copyWith(color: kPureWhiteColor),
      //                                   onChanged: (value) {
      //                                     // Update the restock value of the corresponding Stock instance in the list.
      //                                     double restockValue = double.tryParse(value) ?? 0;
      //                                     selectedStocks
      //                                         .firstWhere((stock) => stock.id == item.id, orElse: () => Stock(name: name, id: item.id, restock: 0))
      //                                         .setRestock(restockValue);
      //                                   },
      //                                 ),
      //                               ),
      //                             ),
      //                           ),
      //                         ],
      //                       ),
      //                     );
      //                   },
      //                 );
      //
      //               },
      //             ):
      //             // Text("Something exists")
      //             ListView.builder(
      //               itemCount: _searchResults.length,
      //               itemBuilder: (context, index) {
      //                 var customer = _searchResults[index];
      //                 var name = customer['name'];
      //                 var amount = customer['amount'];
      //                 var description = customer['description'];
      //                 var quantity = customer['quantity'];
      //
      //                 if (!checkboxStates.containsKey(index)) {
      //                   // Initialize checkbox state when the item is first shown.
      //                   checkboxStates[index] = false;
      //                 }
      //
      //                 if (!quantityControllers.containsKey(index)) {
      //                   // Initialize quantity text controller when the item is first shown.
      //                   quantityControllers[index] = TextEditingController();
      //                 }
      //
      //                 return GestureDetector(
      //                   onTap: (){
      //                     Navigator.pop(context);
      //                     //Provider.of<StyleProvider>(context, listen: false).addToServiceBasket(BasketItem(name:  name, quantity: 1, amount: amount, details: name));
      //                   },
      //                   child: ListTile(
      //                     title: Text(name,style: kNormalTextStyle.copyWith(color: kPureWhiteColor),),
      //                     subtitle: Column(
      //                       mainAxisAlignment: MainAxisAlignment.start,
      //                       children: [
      //                         Text('${CommonFunctions().formatter.format(amount)}',style: kNormalTextStyle.copyWith(color: kPureWhiteColor),),
      //                         Text('$description',style: kNormalTextStyle.copyWith(color: kPureWhiteColor),),
      //                         Text('$quantity',style: kNormalTextStyle.copyWith(color: kPureWhiteColor),),
      //
      //                       ],
      //                     ),
      //                   ),
      //                 );
      //               },
      //             ),
      //           ),
      //         ],
      //       ),
      //     ],
      //   ),
      // ),
    );
  }


}
