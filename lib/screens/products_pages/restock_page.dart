import 'package:dropdown_search/dropdown_search.dart';
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
import 'package:stylestore/model/purchase_pdf_files/purchase.dart';
import 'package:stylestore/screens/products_pages/products_upload.dart';
import 'package:stylestore/screens/products_pages/stock_items.dart';
import 'package:stylestore/widgets/supplier_widget.dart';
import '../../Utilities/constants/font_constants.dart';
import '../../model/beautician_data.dart';
import '../../model/common_functions.dart';
import '../../model/purchase_pdf_files/pdf_purchase_api.dart';
import '../../model/purchase_pdf_files/purchase_api.dart';
import '../../model/purchase_pdf_files/purchase_customer.dart';
import '../../model/purchase_pdf_files/purchase_supplier.dart';
import '../../model/stock_items.dart';
import '../../model/styleapp_data.dart';
import '../expenses_pages/add_expense_widget.dart';

class ReStockPage extends StatefulWidget {
  static String id = "take_stock";
  @override
  _ReStockPageState createState() => _ReStockPageState();

}

class _ReStockPageState extends State<ReStockPage> {
  late Stream<QuerySnapshot> _customerStream;
  TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  List<Map<String, dynamic>> _allItems = [];
  var basketToPost = [];
  var barcodeList = [];
  String purchaseOrderNumber = "";
  String location = "";
  String businessName = "";
  String businessPhoneNumber = "";
  String userName = "";
  Color mainColor = kBlack;
  bool isScanning = false;
  var nameList = [];
  var itemIdList = [];
  var descriptionList = [];
  var quantityList = [];
  var minimumList = [];
  List<AllStockData> filteredStock = [];
  List<AllStockData> newStock = [];




  TextEditingController searchController = TextEditingController();
  List <StockItem>  shoppingList = [];

  List<String> supplierDisplayNames = [];
  List<String> supplierIds = ["default"];
  List<String> supplierRealNames = ["Supplier"];
  String? selectedSupplierDisplayName;
  String? selectedSupplierId;
  String? selectedSupplierRealName;

  Future<void> fetchSupplierNames() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('suppliers')
        .where("storeId", isEqualTo: Provider.of<BeauticianData>(context, listen: false).storeId)
        .get();
    List<String> supplierData = querySnapshot.docs.map((doc) {
      String name = doc['name'] as String;
      String supplies = doc['supplies'] as String;
      supplierIds.add(doc.id);
      supplierRealNames.add(doc['name']);
      return "$name ($supplies)";
    }).toList();
    setState(() {
      supplierDisplayNames = ["Supplier",...supplierData];
    });
  }

  Future<List<AllStockData>> retrieveStockData() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('stores')
          .where('storeId', isEqualTo: Provider.of<StyleProvider>(context, listen: false).beauticianId)
          .where('tracking', isEqualTo: true)
          .orderBy('name', descending: false)
          .get();
      final stockDataList = snapshot.docs
          .map((doc) => AllStockData.fromFirestore(doc))
          .toList();
      return stockDataList;
    } catch (error) {
      print('Error retrieving stock data: $error');
      return [];
    }
  }

  void filterStock(String query) {
    setState(() {
      filteredStock = newStock
          .where((stock) =>
      stock.name.toLowerCase().contains(query.toLowerCase()) ||
          stock.description.toLowerCase().contains(query.toLowerCase())
      ).toList();
    });
  }


  void defaultInitialization()async{
    final prefs = await SharedPreferences.getInstance();
    purchaseOrderNumber = "PO_${CommonFunctions().generateUniqueID(prefs.getString(kBusinessNameConstant)!)}";
    location = prefs.getString(kLocationConstant)!;
    userName = prefs.getString(kLoginPersonName)!;
    businessName = prefs.getString(kBusinessNameConstant)!;
    businessPhoneNumber = prefs.getString(kPhoneNumberConstant)!;
    newStock = await retrieveStockData();
    filteredStock.addAll(newStock);
    Provider.of<StyleProvider>(context, listen: false).setSupplierButton(false);
    fetchSupplierNames();
  }
  TextEditingController _getOrCreateController(int index) {
    if (!quantityControllers.containsKey(index)) {
      quantityControllers[index] = TextEditingController();
    }
    return quantityControllers[index]!;
  }
  // Helper function to show the popup.
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
      if (barcodeScanRes != '-1') {
        int index = barcodeList.indexOf(barcodeScanRes);

        if (index != -1) {
          CommonFunctions().playBeepSound();
          isScanning = false;
          print(index);
          print(nameList);
          quantityControllers[index]?.text = '0';
          // Add the selected stock to the list.
          selectedStocks.add(Stock(name: nameList[index], id: itemIdList[index], restock: 0, description: descriptionList[index], quality: 'Ok'));
          print(selectedStocks);

          showPriceAndQuantityDialogForBarScanner(index, nameList[index], itemIdList[index], descriptionList[index] );

        } else {
          isScanning = false;
          ScaffoldMessenger.of(context).showSnackBar( SnackBar(content: Text('Item is not in your Inventory')));
          // Navigator.pop(context);
        }
      }
    }
  }
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


  Future<void> _showPriceAndQuantityDialog(int index, String name, id, description, AllStockData stockItem) async {
    double? inputPrice;
    double? inputQuantity;
    await
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return
          AlertDialog(
          title: Text('Purchase Details for $name', textAlign: TextAlign.center, style: kNormalTextStyle.copyWith(color: kBlack, fontSize: 22),),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                onChanged: (value) {
                  inputPrice = double.tryParse(value);
                },
                decoration: InputDecoration(
                  labelText: 'Price (Total Amount)',
                  hintText: 'Total for purchasing $name',
                ),
              ),
              SizedBox(height: 10),
              TextField(
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                onChanged: (value) {
                  inputQuantity = double.tryParse(value);
                },
                decoration: InputDecoration(
                  labelText: 'Quantity Bought',
                  hintText: 'Enter the quantity bought',
                ),
              ),
              DropdownButtonFormField<Quality>(
                value: selectedQuality,  // Current selected value
                decoration: InputDecoration(
                  labelText: 'Quality',
                  labelStyle: TextStyle(fontSize: 14)
                ),
                items: Quality.values.map((quality) {
                  return DropdownMenuItem(
                    value: quality,
                    child: Text(quality.name[0].toString().toUpperCase() + quality.name.substring(1).toString()), // Customize display
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    selectedQuality = newValue;
                  });
                },
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
                if (inputPrice != null && inputQuantity != null) {
                  setState(() {
                    int existingIndex = selectedStocks.indexWhere((stock) => stock.id == id);
                    print("EXISTING INDEX = $existingIndex");
                    if (existingIndex != -1) {
                      selectedStocks[existingIndex].price = inputPrice!;
                      selectedStocks[existingIndex].quality = selectedQuality!.name;
                      print(selectedQuality.toString());
                      selectedStocks[existingIndex].setRestock(inputQuantity!);
                      Provider.of<StyleProvider>(context, listen: false).addSelectedStockList(name);

                    } else {
                      // If the stock is not in the list, add it to the list.

                      print("NOPE THIS RUN INSTEAD");
                    }
                    checkboxStates[index] = true;
                    quantityControllers[index]?.text = inputQuantity.toString();
                    print("HERE RUN BRO and selected stock price is  ${selectedStocks[existingIndex].name}:${selectedStocks[existingIndex].restock}");
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
  Future<void> showPriceAndQuantityDialogForBarScanner(int index, String name, id, description) async {
    double? inputPrice;
    double? inputQuantity;
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Purchase Details for $name', textAlign: TextAlign.center, style: kNormalTextStyle.copyWith(color: kBlack, fontSize: 22),),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                onChanged: (value) {
                  inputPrice = double.tryParse(value);
                },
                decoration: InputDecoration(
                  labelText: 'Price (Total Amount)',
                  hintText: 'Total for purchasing $name',
                ),
              ),
              SizedBox(height: 10),
              TextField(
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                onChanged: (value) {
                  inputQuantity = double.tryParse(value);
                },
                decoration: InputDecoration(
                  labelText: 'Quantity Bought',
                  hintText: 'Enter the quantity bought',
                ),
              ),

              DropdownButtonFormField<Quality>(
                value: selectedQuality,  // Current selected value
                decoration: InputDecoration(
                    labelText: 'Quality',
                    labelStyle: TextStyle(fontSize: 14)
                ),
                items: Quality.values.map((quality) {
                  return DropdownMenuItem(
                    value: quality,
                    child: Text(quality.name[0].toString().toUpperCase() + quality.name.substring(1).toString()), // Customize display
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    selectedQuality = newValue;
                  });
                },
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
                if (inputPrice != null && inputQuantity != null) {
                  setState(() {
                    int existingIndex = selectedStocks.indexWhere((stock) => stock.id == id);
                    print("EXISTING INDEX = $existingIndex");
                    if (existingIndex != -1) {
                      // If the stock already exists, update its price and quantity.
                      selectedStocks[existingIndex].price = inputPrice!;
                      selectedStocks[existingIndex].quality = selectedQuality!.name;
                      print(selectedQuality.toString());
                      selectedStocks[existingIndex].setRestock(inputQuantity!);


                    } else {

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
        'totalPrice':selectedStocks[i].price,
        'quality': selectedStocks[i].quality
      }
      );
    }
    CommonFunctions().uploadRestockedItems(selectedStocks, basketToPost,context, purchaseOrderNumber);
  }


  @override
  void initState() {
    super.initState();
    defaultInitialization();
    _customerStream = FirebaseFirestore.instance.collection('stores').where('active', isEqualTo: true)
        .where('storeId', isEqualTo:Provider.of<BeauticianData>(context, listen: false).storeId).where('tracking', isEqualTo: true)
        .orderBy('name',descending: false).snapshots();
  }
  Map<int, bool> checkboxStates = {}; // Map to track checkbox states.
  Map<int, TextEditingController> quantityControllers = {}; // Map to track quantity text controllers.
  List<Stock> selectedStocks = []; // List to store selected stocks.
  Quality? selectedQuality = Quality.ok;  // Default value as OK



  @override
  Widget build(BuildContext context) {
    var styleData = Provider.of<StyleProvider>(context, listen: true);
    return Scaffold(
      backgroundColor: kPureWhiteColor,
      appBar: AppBar(
        foregroundColor: kPureWhiteColor,
        title: Text("Restock", style: kHeading3TextStyleBold.copyWith(fontSize: 16, color: kPureWhiteColor),),
        centerTitle: true,
        elevation: 0,
        backgroundColor: kAppPinkColor,
        // title: Text('Customer List'),
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
      ),
      floatingActionButton: FloatingActionButton.extended(
        splashColor: kCustomColor,
        // foregroundColor: Colors.black,
        backgroundColor: kAppPinkColor,
        onPressed: () {
          // Handle the "Update Stock" button press.
          if (selectedStocks.isNotEmpty){
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
                      body:
                      Container(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min, // Important for BottomSheet
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [

                            Text("Select Supplier", style: Theme.of(context).textTheme.headline6),
                            SizedBox(height: 10),
                            DropdownSearch<String>(

                                items: supplierDisplayNames,
                                dropdownDecoratorProps: DropDownDecoratorProps(
                                  dropdownSearchDecoration: InputDecoration(
                                    labelText: "Select Supplier",
                                    hintText: "Supplier for goods",
                                  ),
                                ),

                                popupProps: PopupProps.menu(
                                  showSelectedItems: true, // Show selected items at the top
                                ),

                                onChanged: (newValue) {
                                  setState(() {
                                    Provider.of<StyleProvider>(context, listen: false).setSupplierButton(true);
                                    selectedSupplierDisplayName = newValue!;
                                    int position = supplierDisplayNames.indexOf(newValue);
                                    selectedSupplierRealName = supplierRealNames[position];
                                    selectedSupplierId = supplierIds[position];
                                    print("$selectedSupplierRealName: $selectedSupplierId");
                                  });
                                },
                                filterFn: (item, query) {
                                  return item.toLowerCase().contains(query!.toLowerCase());
                                }
                            ),
                            kLargeHeightSpacing,
                            kLargeHeightSpacing,
                            kLargeHeightSpacing,
                            kLargeHeightSpacing,
                            // Display the button conditionally
                            Provider.of<StyleProvider>(context, listen: true).supplierButton == false
                                ?SizedBox.shrink():
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kAppPinkColor, // Set the background color
                              ),
                              onPressed: () {
                                Navigator.pop(context); // Close the sheet
                                // Execute your function
                                _handleUpdateStockButton();
                                Provider.of<StyleProvider>(context, listen: false).setSupplierValues(selectedSupplierId, selectedSupplierRealName);
                              },
                              child: Text('Upload Stock', style: kNormalTextStyle.copyWith(color: kPureWhiteColor),),
                            )
                            // : SizedBox.shrink(),
                          ],
                        ),
                      )
                  );
                });
            // _handleUpdateStockButton();
          }
        },
        icon:  CircleAvatar(
            radius: 12,
            child: Text("${selectedStocks.length}", style:kNormalTextStyle.copyWith(color: kBlack) ,)),
        label: Text(
          'Restock Items',
          style: kNormalTextStyle.copyWith(color: kPureWhiteColor),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniCenterFloat,
      body:
      SafeArea(
        child:
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 15.0, top: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  kIsWeb?Container():GestureDetector(
                    onTap: (){
                      _startBarcodeScan();
                    },
                    child:
                    Container(
                      height: 60,
                      width: 60,
                      decoration: BoxDecoration(
                          color: kCustomColor,
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          boxShadow: [BoxShadow(color: kFaintGrey.withOpacity(0.5), spreadRadius: 2,blurRadius: 2 )]

                      ),
                      child: Icon(Iconsax.scan, size: 40,color: kBlueDarkColor,),
                    ),),

                  selectedStocks.length != 0?
                  Padding(
                    padding: const EdgeInsets.only(right: 15.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          style: ButtonStyle(backgroundColor: CommonFunctions().convertToMaterialStateProperty(kGreenThemeColor)),
                          onPressed: () async {
                            List<StockItem> StockItems = [];
                            for (var i = 0; i < selectedStocks.length; i++ ){
                              StockItems.add(StockItem(description: selectedStocks[i].name, quantity: selectedStocks[i].restock, unitPrice:selectedStocks[i].price));
                            }

                            final shoppingList = PurchaseOrder(
                                supplier: Supplier(
                                  name: businessName,
                                  address: location,
                                  phoneNumber: businessPhoneNumber,
                                  paymentInfo: businessPhoneNumber,

                                ),
                                customer: Customer(
                                  name: userName,
                                  address: location,
                                  phone: businessPhoneNumber,
                                ),
                                info: InvoiceInfo(
                                  date: DateTime.now(),
                                  dueDate: DateTime.now(),
                                  description: '',
                                  number: purchaseOrderNumber,
                                ),
                                items: StockItems,
                                template: StockTemplate(
                                    type: 'SHOPPING LIST',
                                    salutation: 'Purchase List',
                                    totalStatement: "Total"),
                                paid: Receipt( amount: 30000)

                            );

                            showDialog(context: context, builder: ( context) {return const Center(child: CircularProgressIndicator(color: kAppPinkColor,));});
                            final pdfFile = await PdfPurchasePdfHelper
                                .generate(shoppingList, "Shopping_"+ purchaseOrderNumber);
                            Navigator.pop(context);
                            PdfPurchaseHelper.openFile(
                                pdfFile);




                          }, child: Text("Shopping List", style: kNormalTextStyle.copyWith(color: kPureWhiteColor),),),
                      ],
                    ),
                  ):
                  Container()
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
                      prefixIcon: Icon(Icons.search),
                      hintText: 'By Product Name / Id',
                      hintFadeDuration: Duration(milliseconds: 100),
                    ),
                    onChanged: filterStock,
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
                  Spacer(),
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
                  itemCount: filteredStock.length,
                  itemBuilder: (context, index) {

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

                          GestureDetector(
                            onTap: (){

                              if(!styleData.selectedStock.contains(filteredStock[index].name)){
                                _showPriceAndQuantityDialog(index, filteredStock[index].name, filteredStock[index].documentId,filteredStock[index].description, filteredStock[index] );
                                quantityControllers[index]?.text = '0';
                                selectedStocks.add(Stock(name: filteredStock[index].name, id: filteredStock[index].documentId, restock: 0, description:filteredStock[index].description));

                              }
                            },
                            child: Row(
                              children: [
                                styleData.selectedStock.contains(filteredStock[index].name)?Icon(Icons.check_box_outlined):Icon(Icons.check_box_outline_blank_outlined),
                                kMediumWidthSpacing,
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('${filteredStock[index].name}', style: kNormalTextStyle.copyWith(color: mainColor)),
                                    Text('${filteredStock[index].description}', style: kNormalTextStyle.copyWith()),
                                  ],
                                ),
                              ],
                            ),
                          ),



                          Spacer(),
                          filteredStock[index].minimum  < filteredStock[index].quantity ? Text('${filteredStock[index].quantity} ', style: kNormalTextStyle.copyWith(color: mainColor)):Text('${filteredStock[index].quantity} ', style: kNormalTextStyle.copyWith(color: Colors.red)),
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
                                  style: kNormalTextStyle.copyWith(color: mainColor),
                                  onChanged: (value) {
                                    // Update the restock value of the corresponding Stock instance in the list.
                                    double restockValue = double.tryParse(value) ?? 0;
                                    selectedStocks
                                        .firstWhere((stock) => stock.id == filteredStock[index].documentId, orElse: () => Stock(name:filteredStock[index].name, id: filteredStock[index].documentId, restock: 0, description: filteredStock[index].description))
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
                )


            ),
          ],
        ),
      ),
    );
  }
}
enum Quality { good, bad, ok }