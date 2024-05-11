import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stylestore/Utilities/constants/color_constants.dart';
import 'package:stylestore/Utilities/constants/user_constants.dart';
import 'package:stylestore/screens/products_pages/products_upload.dart';
import '../../Utilities/constants/font_constants.dart';
import '../../model/beautician_data.dart';
import '../../model/common_functions.dart';
import '../../model/stock_items.dart';
import '../../model/styleapp_data.dart';
import '../../widgets/scanner_widget.dart';
import '../../widgets/subscription_ended_widget.dart';

class UpdateStockPage extends StatefulWidget {
  static String id = "update_stock";
  @override
  _UpdateStockPageState createState() => _UpdateStockPageState();

}

class _UpdateStockPageState extends State<UpdateStockPage> {
  late Stream<QuerySnapshot> _customerStream;
  TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  var basketToPost = [];
  String updateOrderNumber = "";
  var nameList = [];
  var itemIdList = [];
  var descriptionList = [];
  var quantityList = [];
  var minimumList = [];
  var barcodeList = [];
  bool isScanning = false;

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
        print("We reached this point");

        int index = barcodeList.indexOf(barcodeScanRes);
        print("The int value is : $index");

        if (index != -1) {
          CommonFunctions().playBeepSound();
          isScanning = false;

          quantityControllers[index]?.text = '0';
          // Add the selected stock to the list.
          selectedStocks.add(Stock(name: nameList[index], id: itemIdList[index], restock: 0, description: descriptionList[index]));

          showPriceAndQuantityDialogForBarScanner(index, nameList[index], itemIdList[index], descriptionList[index] );
        } else {
          isScanning = false;
          ScaffoldMessenger.of(context).showSnackBar( SnackBar(content: Text('Item is not in your Inventory')));

        }
      }
    }
  }
  void defaultInitialization()async{
    final prefs = await SharedPreferences.getInstance();
    var storeId = prefs.getString(kStoreIdConstant);
    updateOrderNumber = "UP_${CommonFunctions().generateUniqueID(prefs.getString(kBusinessNameConstant)!)}";

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


  Future<void> _showPriceAndQuantityDialog(int index, String name, id, description) async {
    double? inputPrice;
    double? inputQuantity;
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Update Quantity details for $name', textAlign: TextAlign.center, style: kNormalTextStyle.copyWith(color: kBlack, fontSize: 22),),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // TextField(
              //   keyboardType: TextInputType.number,
              //   onChanged: (value) {
              //     inputPrice = double.tryParse(value);
              //   },
              //   decoration: InputDecoration(
              //     labelText: 'Price',
              //     hintText: 'Enter the total purchase price for $name',
              //   ),
              // ),
              // SizedBox(height: 10),
              TextField(
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                onChanged: (value) {
                  inputQuantity = double.tryParse(value);
                },
                decoration: InputDecoration(
                  labelText: 'Quantity',
                  hintText: 'Enter Updated $name quantity',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (inputQuantity != null) {
                  setState(() {
                    // Stock selectedStock = Stock(
                    //   name: name,
                    //   id: id,
                    //   restock: inputQuantity!,
                    //   price: inputPrice!,
                    //   description: description
                    // );
                    // selectedStocks[index].price = inputPrice!;
                    // Check if the selected stock already exists in the list.
                    int existingIndex = selectedStocks.indexWhere((stock) => stock.id == id);
                    print("EXISTING INDEX = $existingIndex");
                    if (existingIndex != -1) {
                      // If the stock already exists, update its price and quantity.
                      // selectedStocks[existingIndex].price = inputPrice!;
                      selectedStocks[existingIndex].setRestock(inputQuantity!);
                      // quantityControllers[existingIndex]?.text = inputQuantity.toString();

                    } else {
                      // If the stock is not in the list, add it to the list.
                      // selectedStocks.add(selectedStock);
                      print("NOPE THIS RUN INSTEAD");
                    }
                    checkboxStates[index] = true;
                    quantityControllers[index]?.text = inputQuantity.toString();
                    print("HERE RUN BRO and selected stock price is  ${selectedStocks[existingIndex].name}:${selectedStocks[existingIndex].restock}");
                  });
                }
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
  Future<void> showPriceAndQuantityDialogForBarScanner(int index, String name, id, description) async {
    double? inputPrice;
    double? inputQuantity;
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Update Quantity details for $name', textAlign: TextAlign.center, style: kNormalTextStyle.copyWith(color: kBlack, fontSize: 22),),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // TextField(
              //   keyboardType: TextInputType.number,
              //   onChanged: (value) {
              //     inputPrice = double.tryParse(value);
              //   },
              //   decoration: InputDecoration(
              //     labelText: 'Price',
              //     hintText: 'Enter the total purchase price for $name',
              //   ),
              // ),
              // SizedBox(height: 10),
              TextField(
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                onChanged: (value) {
                  inputQuantity = double.tryParse(value);
                },
                decoration: InputDecoration(
                  labelText: 'Quantity',
                  hintText: 'Enter Updated $name quantity',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (inputQuantity != null) {
                  setState(() {
                    // Stock selectedStock = Stock(
                    //   name: name,
                    //   id: id,
                    //   restock: inputQuantity!,
                    //   price: inputPrice!,
                    //   description: description
                    // );
                    // selectedStocks[index].price = inputPrice!;
                    // Check if the selected stock already exists in the list.
                    int existingIndex = selectedStocks.indexWhere((stock) => stock.id == id);
                    print("EXISTING INDEX = $existingIndex");
                    if (existingIndex != -1) {
                      // If the stock already exists, update its price and quantity.
                      // selectedStocks[existingIndex].price = inputPrice!;
                      selectedStocks[existingIndex].setRestock(inputQuantity!);
                      // quantityControllers[existingIndex]?.text = inputQuantity.toString();

                    } else {
                      // If the stock is not in the list, add it to the list.
                      // selectedStocks.add(selectedStock);
                      print("NOPE THIS RUN INSTEAD");
                    }
                    checkboxStates[index] = true;
                    quantityControllers[index]?.text = inputQuantity.toString();
                    print("HERE RUN BRO and selected stock price is  ${selectedStocks[existingIndex].name}:${selectedStocks[existingIndex].restock}");
                  });
                }
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return CupertinoAlertDialog(
                      title: Text("Scan another Item?"),
                      content: Text("Would you like to scan another item?"),
                      actions: [
                        CupertinoDialogAction(
                          child: const Text(
                            "Cancel", style: TextStyle(color: kRedColor),),
                          onPressed: () {
                            Navigator.of(context).pop();// Close the dialog

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
              },
              child: Text('OK'),
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
        'totalPrice':selectedStocks[i].price
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

  Map<int, bool> checkboxStates = {}; // Map to track checkbox states.
  Map<int, TextEditingController> quantityControllers = {}; // Map to track quantity text controllers.
  List<Stock> selectedStocks = []; // List to store selected stocks.


  @override
  Widget build(BuildContext context) {
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
            // GestureDetector(
            //     onTap: (){
            //       showDialog(context: context, builder: (BuildContext context){
            //         return
            //           CupertinoAlertDialog(
            //             title: const Text('30s Video on Stock'),
            //             content: Text("This will take you to a short video on stock taking", style: kNormalTextStyle.copyWith(color: kBlack),),
            //             actions: [
            //
            //               CupertinoDialogAction(isDestructiveAction: true,
            //                   onPressed: (){
            //                     // _btnController.reset();
            //                     Navigator.pop(context);
            //                   },
            //                   child: const Text('Cancel')),
            //
            //
            //             ],
            //           );
            //       });
            //     },
            //     child: Lottie.asset("images/video.json", width: 40)),
          )
        ],
        // title: Text('Customer List'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        splashColor: Colors.green,
        backgroundColor: kAppPinkColor,
        onPressed: () {
          // Handle the "Update Stock" button press.
          _handleUpdateStockButton();

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
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [

                kLargeHeightSpacing,

                kIsWeb?Container():GestureDetector(
                  onTap: ()async{
                    if(await CommonFunctions().subscriptionActive() == false ){

                      CommonFunctions().buildSubscriptionPaymentModal(context);
                    }else {
                      _startBarcodeScan();
                    }
                  },
                  child:
                  const ScannerWidget(backgroundColor: kCustomColor,scannerColor: kBlack,)
                ),
                kSmallHeightSpacing,
                Padding(
                  padding: const EdgeInsets.only(left: 20.0, right: 20),
                  child: Row(
                    children: [
                      Text("Add |", style: kNormalTextStyle.copyWith(color: kBeigeColor),),
                      kSmallWidthSpacing,
                      kSmallWidthSpacing,
                      Text("Item", style: kNormalTextStyle.copyWith(color: kBeigeColor),),
                      Spacer(),
                      Text("Current level |", style: kNormalTextStyle.copyWith(color: kBeigeColor),),
                      kSmallWidthSpacing,
                      kSmallWidthSpacing,
                      Text("Stock", style: kNormalTextStyle.copyWith(color: kBeigeColor),),

                    ],
                  ),
                ),


                Expanded(
                  child: _searchResults.isEmpty
                      ?
                  StreamBuilder<QuerySnapshot>(
                    stream: _customerStream,
                    builder: (context, snapshot) {
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

                      if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
                        return Center(
                          child: Text('No items found.',style: kNormalTextStyle.copyWith(color: kPureWhiteColor),),
                        );
                      }
                      var stocks = snapshot.data!.docs;
                      barcodeList = [];
                      nameList = [];
                      minimumList = [];
                      quantityList = [];
                      for (var stock in stocks) {
                        barcodeList.add(stock.get('barcode'));
                        nameList.add(stock.get('name'));
                        minimumList.add(stock.get('minimum'));
                        quantityList.add(stock.get('quantity'));
                        descriptionList.add(stock.get('description'));
                        itemIdList.add(stock.get('id'));

                      }
                      return ListView.builder(
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          var item = snapshot.data!.docs[index];
                          var name = item['name'];
                          var amount = item['amount'];
                          var description = item['description'];
                          var quantity = item['quantity'];
                          var minimum = item['minimum'];

                          // Define a TextEditingController to handle the quantity input in the TextField.
                          TextEditingController quantityController = TextEditingController();

                          if (!checkboxStates.containsKey(index)) {
                            // Initialize checkbox state when the item is first shown.
                            checkboxStates[index] = false;
                          }

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
                                // Text('${CommonFunctions().formatter.format(amount)}', style: kNormalTextStyle.copyWith(color: kPureWhiteColor)),
                                Checkbox(
                                  fillColor: CommonFunctions().convertToMaterialStateProperty(kBeigeColor),
                                  checkColor: kBlack,
                                  value: checkboxStates[index], // Add your own logic here to set the value of the checkbox.
                                  onChanged: (value) {

                                    setState(() {
                                      bool newValue = value ?? false;
                                      checkboxStates[index] = newValue;
                                      // Set the default value of the TextField to 0 when the checkbox is checked.
                                      if (newValue) {
                                        _showPriceAndQuantityDialog(index, name, item.id, description );
                                        quantityControllers[index]?.text = '0';

                                        // Add the selected stock to the list.
                                        selectedStocks.add(Stock(name: name, id: item.id, restock: 0));
                                      } else {
                                        // Remove the selected stock from the list.
                                        selectedStocks.removeWhere((stock) => stock.id == item.id);
                                      }
                                    });
                                    // Add your logic to handle checkbox value change.
                                  },
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('$name', style: kNormalTextStyle.copyWith(color: kPureWhiteColor)),
                                    Text('($description)', style: kNormalTextStyle.copyWith(color: kPureWhiteColor)),
                                  ],
                                ),


                                Spacer(),
                                minimum  < quantity ? Text('$quantity ', style: kNormalTextStyle.copyWith(color: kPureWhiteColor)):Text('$quantity ', style: kNormalTextStyle.copyWith(color: Colors.red)),
                                kSmallWidthSpacing,
                                kSmallWidthSpacing,
                                kSmallWidthSpacing,
                                GestureDetector(
                                  onTap: (){
                                    if (!checkboxStates[index]!) {
                                      // Show the popup only when the TextField is disabled (checkbox is unchecked).
                                      _showPopup(context);
                                    }
                                  },
                                  child: Container(
                                    width: 60,
                                    height: 30,
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey),
                                    ),
                                    child: Center(
                                      child: TextField(

                                        enabled: checkboxStates[index], // Set the TextField's editable state based on checkbox state.
                                        controller: _getOrCreateController(index),
                                        //quantityControllers[index],
                                        textAlign: TextAlign.center,
                                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                                        style: kNormalTextStyle.copyWith(color: kPureWhiteColor),
                                        onChanged: (value) {
                                          // Update the restock value of the corresponding Stock instance in the list.
                                          double restockValue = double.tryParse(value) ?? 0;
                                          selectedStocks
                                              .firstWhere((stock) => stock.id == item.id, orElse: () => Stock(name: name, id: item.id, restock: 0))
                                              .setRestock(restockValue);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );

                    },
                  ):
                  // Text("Something exists")
                  ListView.builder(
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      var customer = _searchResults[index];
                      var name = customer['name'];
                      var amount = customer['amount'];
                      var description = customer['description'];
                      var quantity = customer['quantity'];

                      if (!checkboxStates.containsKey(index)) {
                        // Initialize checkbox state when the item is first shown.
                        checkboxStates[index] = false;
                      }

                      if (!quantityControllers.containsKey(index)) {
                        // Initialize quantity text controller when the item is first shown.
                        quantityControllers[index] = TextEditingController();
                      }

                      return GestureDetector(
                        onTap: (){
                          Navigator.pop(context);
                          //Provider.of<StyleProvider>(context, listen: false).addToServiceBasket(BasketItem(name:  name, quantity: 1, amount: amount, details: name));
                        },
                        child: ListTile(
                          title: Text(name,style: kNormalTextStyle.copyWith(color: kPureWhiteColor),),
                          subtitle: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text('${CommonFunctions().formatter.format(amount)}',style: kNormalTextStyle.copyWith(color: kPureWhiteColor),),
                              Text('$description',style: kNormalTextStyle.copyWith(color: kPureWhiteColor),),
                              Text('$quantity',style: kNormalTextStyle.copyWith(color: kPureWhiteColor),),

                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            // Positioned(
            //     bottom: 50,
            //     right: 5,
            //     child: Column(
            //       children: [
            //         GestureDetector(
            //
            //           onTap: (){
            //             Navigator.pop(context);
            //             showModalBottomSheet(
            //                 isScrollControlled: true,
            //                 context: context,
            //                 builder: (context) {
            //                   return  Scaffold(
            //                       appBar: AppBar(
            //                         automaticallyImplyLeading: false,
            //                         backgroundColor: kBlack,
            //                       ),
            //                       body: ProductUpload());
            //                 });
            //
            //           },
            //           child: Lottie.asset('images/round.json', height: 50),
            //         ),
            //         Text("Create Product",style: kNormalTextStyle.copyWith(color: kBlueDarkColor, fontSize: 10),)
            //       ],
            //     )
            //     )
          ],
        ),
      ),
    );
  }


}
