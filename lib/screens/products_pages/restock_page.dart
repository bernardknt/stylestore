import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stylestore/Utilities/constants/color_constants.dart';
import 'package:stylestore/Utilities/constants/user_constants.dart';
import 'package:stylestore/model/purchase_pdf_files/purchase.dart';
import 'package:stylestore/screens/products_pages/products_upload.dart';
import 'package:stylestore/screens/products_pages/stock_items.dart';
import 'package:stylestore/screens/suppliers/supplier_form.dart';
import '../../Utilities/constants/font_constants.dart';
import '../../model/beautician_data.dart';
import '../../model/common_functions.dart';
import '../../model/purchase_pdf_files/pdf_purchase_api.dart';
import '../../model/purchase_pdf_files/purchase_api.dart';
import '../../model/purchase_pdf_files/purchase_customer.dart';
import '../../model/purchase_pdf_files/purchase_supplier.dart';
import '../../model/stock_items.dart';
import '../../model/styleapp_data.dart';
import '../../utilities/constants/word_constants.dart';
import '../../widgets/scanner_widget.dart';
import '../../widgets/subscription_ended_widget.dart';

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
  String currency= "";
  String businessPhoneNumber = "";
  String userName = "";
  Color mainColor = kBlack;
  bool isScanning = false;
  var nameList = [];
  var itemIdList = [];
  var descriptionList = [];
  var quantityList = [];
  var minimumList = [];
  // List<AllStockData> filteredStock = [];
  List<AllStockData> newStock = [];




  TextEditingController searchController = TextEditingController();
  List <StockItem>  shoppingList = [];

  List<String> supplierDisplayNames = [];
  List<String> supplierIds = ["default"];
  List<String> supplierRealNames = ["Supplier"];
  String? selectedSupplierDisplayName;
  String? selectedSupplierId;
  String? selectedSupplierRealName;





  // void filterStock(String query) {
  //   setState(() {
  //
  //         Provider.of<StyleProvider>(context, listen: false).filteredStock
  //         .where((stock) =>
  //     stock.name.toLowerCase().contains(query.toLowerCase()) ||
  //         stock.description.toLowerCase().contains(query.toLowerCase())
  //     ).toList();
  //   });
  // }


  void defaultInitialization()async{
    final prefs = await SharedPreferences.getInstance();
    purchaseOrderNumber = "PO_${CommonFunctions().generateUniqueID(prefs.getString(kBusinessNameConstant)!)}";
    location = prefs.getString(kLocationConstant)!;
    userName = prefs.getString(kLoginPersonName)!;
    businessName = prefs.getString(kBusinessNameConstant)!;
    businessPhoneNumber = prefs.getString(kPhoneNumberConstant)!;
    currency = Provider.of<StyleProvider>(context, listen: false).storeCurrency;
    newStock = await CommonFunctions().retrieveStockTrackedData(context);
    // filteredStock.addAll(newStock);
    Provider.of<StyleProvider>(context, listen: false).setSupplierButton(false);
    CommonFunctions().fetchSupplierNames(context);
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
      print("Here is barcodeRes: $barcodeScanRes");
      if (barcodeScanRes != '-1') {

        var barcodeItem = newStock.firstWhere((item) => item.getByBarcode(barcodeScanRes) != null);
        print("We reached this point: ${barcodeItem}");
        if (barcodeItem != null) {

          CommonFunctions().playBeepSound();

          isScanning = false;
          selectedStocks.add(Stock(name: barcodeItem.name, id: barcodeItem.documentId, restock: 0, description:barcodeItem.description));
         // showPriceAndQuantityDialogForBarScanner(1, barcodeItem.name, barcodeItem.documentId);
          Provider.of<StyleProvider>(context, listen: false).setSelectedUnit(barcodeItem.unit);
          showPriceAndQuantityDialogForBarScanner(barcodeItem.name, barcodeItem.documentId, barcodeItem.description);

        } else
        {

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


  Future<void> _showPriceAndQuantityDialog( String name, id, unit, description) async {
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
                    print(inputPrice);
                  },
                  decoration: InputDecoration(
                    labelText: 'Price (Total Amount)',
                    hintText: 'Total for purchasing $name',
                  ),
                ),
                SizedBox(height: 10),
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
                          labelText: 'Quantity Bought',
                          hintText: 'Enter the quantity bought',
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
                  print(Provider.of<StyleProvider>(context, listen: false).selectedUnit);
                  if (inputPrice != null && inputQuantity != null) {
                    print("THE PRICE IS $inputPrice, Quantity: $inputQuantity");
                    setState(() {

                      selectedStocks.add(Stock(price: inputPrice!, name: name, id: id, restock: inputQuantity!, description:description, unit: Provider.of<StyleProvider>(context, listen: false).selectedUnit, quality: selectedQuality!.name));
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
            title: Text('Purchase Details for $name', textAlign: TextAlign.center, style: kNormalTextStyle.copyWith(color: kBlack, fontSize: 22),),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  onChanged: (value) {
                    inputPrice = double.tryParse(value);
                    print(inputPrice);
                  },
                  decoration: InputDecoration(
                    labelText: 'Price (Total Amount)',
                    hintText: 'Total for purchasing $name',
                  ),
                ),
                SizedBox(height: 10),
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
                          labelText: 'Quantity Bought',
                          hintText: 'Enter the quantity bought',
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
                  print(Provider.of<StyleProvider>(context, listen: false).selectedUnit);
                  if (inputPrice != null && inputQuantity != null) {
                    print("THE PRICE IS $inputPrice, Quantity: $inputQuantity");
                    setState(() {

                      selectedStocks.add(Stock(price: inputPrice!, name: name, id: id, restock: inputQuantity!, description:description, unit: Provider.of<StyleProvider>(context, listen: false).selectedUnit, quality: selectedQuality!.name));
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

  void _handleUpdateStockButton() {
    for(var i = 0; i < selectedStocks.length; i ++){
      print("${selectedStocks[i].name}: ${selectedStocks[i].restock}");
      basketToPost.add( {
        'product' : selectedStocks[i].name,
        'description':selectedStocks[i].description,
        'quantity': selectedStocks[i].restock,
        'totalPrice':selectedStocks[i].price,
        'quality': selectedStocks[i].quality,
        'unit': selectedStocks[i].unit,
      }
      );
    }
    CommonFunctions().uploadRestockedItems(selectedStocks, basketToPost,context, purchaseOrderNumber, currency);
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
    var styleDataListen = Provider.of<StyleProvider>(context, listen: true);
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
                        automaticallyImplyLeading: true,
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

                            Text("Select Supplier", style: kNormalTextStyle.copyWith(color: kBlack)),
                            kLargeHeightSpacing,
                            Row(
                              children: [
                                Expanded(
                                  flex: 4,
                                  child: DropdownSearch<String>(
                                    items: Provider.of<StyleProvider>(context, listen: true).supplierDisplayNames,

                                    popupProps:
                                    const PopupProps.menu(
                                      showSearchBox: true,
                                      showSelectedItems: true, // Show selected items at the top
                                      searchFieldProps: TextFieldProps(
                                        autofocus: true, // Focus the search field when popup opens
                                        decoration: InputDecoration(
                                          hintText: 'Search...',
                                          prefixIcon: Icon(Icons.search),
                                        ),

                                      ),

                                    ),
                                    dropdownDecoratorProps:  DropDownDecoratorProps(
                                      dropdownSearchDecoration: InputDecoration(
                                        labelText: "Select Supplier",
                                        hintText: "Supplier for goods",
                                      ),
                                    ),
                                    onChanged: (newValue) {
                                      setState(() {
                                        Provider.of<StyleProvider>(context, listen: false).setSupplierButton(true);
                                        selectedSupplierDisplayName = newValue!;
                                        int position = Provider.of<StyleProvider>(context, listen: false).supplierDisplayNames.indexOf(newValue);
                                        print("The index is $position");
                                        selectedSupplierRealName = Provider.of<StyleProvider>(context, listen: false).supplierRealNames[position];
                                        selectedSupplierId = Provider.of<StyleProvider>(context, listen: false).supplierIds[position];
                                        print("KOKOKOKOK $selectedSupplierRealName: $selectedSupplierId");
                                      });
                                    },
                                    filterFn: (item, query) {
                                      return item.toLowerCase().contains(query!.toLowerCase());
                                    },
                                  ),
                                ),
                                Expanded(
                                    flex: 2,
                                    child:
                                    TextButton(
                                      onPressed: (){
                                        Navigator.pushNamed(context, SupplierForm.id);
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                            color: kCustomColor,
                                            borderRadius: BorderRadius.circular(10)
                                        ),

                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Center(child: Text("+ Supplier", style: kNormalTextStyle.copyWith(color: kBlack),)),
                                        ),
                                      ),
                                    )
                                )
                              ],
                            ),

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
                                Provider.of<StyleProvider>(context, listen: false).setSupplierValues(selectedSupplierId, selectedSupplierRealName);

                                _handleUpdateStockButton();
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
          }else{
            CommonFunctions().showErrorDialog("No Items added", context);
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

                      selectedStocks.isNotEmpty?
                      Padding(
                        padding: const EdgeInsets.all(15.0),
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
                                        type: 'PURCHASE ORDER',
                                        salutation: 'Purchase Order',
                                        totalStatement: "Total"),
                                    paid: Receipt( amount: 30000)

                                );
                                CommonFunctions().showSuccessNotification("Loading Purchase Order", context);

                                // showDialog(context: context, builder: ( context) {return const Center(child: CircularProgressIndicator(color: kAppPinkColor,));});
                                final pdfFile = await PdfPurchasePdfHelper.generate(shoppingList, "LPO_"+ purchaseOrderNumber);
                                print(pdfFile.path);

                                PdfPurchaseHelper.openFile(pdfFile);




                              }, child: Text("Purchase Details", style: kNormalTextStyle.copyWith(color: kPureWhiteColor),),),
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
                                onTap: ()
                                {

                                  if(!styleDataListen.selectedStock.contains(styleData.filteredStock[index].name)){
                                    Provider.of<StyleProvider>(context, listen: false).setSelectedUnit(styleData.filteredStock[index].unit);
                                    _showPriceAndQuantityDialog(styleData.filteredStock[index].name, styleData.filteredStock[index].documentId, styleData.filteredStock[index].unit,
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
                                    styleDataListen.selectedStock.contains(styleData.filteredStock[index].name)?Icon(Icons.check_box_outlined):Icon(Icons.check_box_outline_blank_outlined),
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
                              kSmallWidthSpacing,
                              kSmallWidthSpacing,
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
                                    print("Else run");
                                    // selectedStocks.remove(value)
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
                                         Text(selectedStocks[ selectedStocks.indexWhere((stock) => stock.name == styleData.filteredStock[index].name)].restock.toString()):
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
    );
  }
}


enum Quality { good, bad, ok }