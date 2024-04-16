import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:stylestore/model/common_functions.dart';
import 'package:stylestore/screens/products_pages/product_edit_page.dart';
import 'package:stylestore/screens/chart_pages/stock_management_page.dart';
import 'package:stylestore/screens/products_pages/products_upload.dart';
import 'package:stylestore/screens/products_pages/restock_page.dart';
import 'package:stylestore/screens/products_pages/stock_history.dart';
import 'package:stylestore/screens/products_pages/stock_items.dart';
import 'package:stylestore/screens/products_pages/update_stock.dart';
import 'package:stylestore/utilities/constants/user_constants.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../../../../Utilities/constants/color_constants.dart';
import '../../../../../Utilities/constants/font_constants.dart';
import '../../model/beautician_data.dart';
import '../../model/excel_model.dart';
import '../../model/styleapp_data.dart';
import '../../widgets/build_info_card.dart';
import '../../widgets/locked_widget.dart';
import '../../widgets/modalButton.dart';

class StorePageWeb extends StatefulWidget {

  @override
  State<StorePageWeb> createState() => _StorePageWebState();
}

class _StorePageWebState extends State<StorePageWeb> {


  var formatter = NumberFormat('#,###,000');
  Map<String, dynamic> permissionsMap = {};
  Map<String, dynamic> videoMap = {};
  TextEditingController searchController = TextEditingController();
  List<AllStockData> filteredStock = [];
  List<AllStockData> newStock = [];
  List<AllStockData> totalStock = [];
  String currency = "";

  defaultInitialization()async{
    permissionsMap = await CommonFunctions().convertPermissionsJson();
    videoMap = await CommonFunctions().convertWalkthroughVideoJson();
    newStock = await retrieveSupplierData();
    totalStock.addAll(newStock);
    filteredStock.addAll(newStock);
    currency = Provider.of<StyleProvider>(context, listen: false).storeCurrency;
    setState(() {

    });
  }

  Future<List<AllStockData>> retrieveSupplierData() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('stores')
          .where('storeId', isEqualTo: Provider.of<StyleProvider>(context, listen: false).beauticianId)
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


  void filterStockByLowStock() {
    setState(() {
      filteredStock = newStock
          .where((element) => element.quantity < 5 && element.tracking)
          .toList();
    });
  }
  void filterStockByForSale() {
    setState(() {
      filteredStock = newStock
          .where((element) => element.saleable)
          .toList();
    });
  }

  void filterStockByNotForSale() {
    setState(() {
      filteredStock = newStock
          .where((element) => !element.saleable)
          .toList();
    });
  }
  void filterStockByWellStocked() {
    setState(() {
      filteredStock = newStock
          .where((element) => element.quantity > 5 && element.tracking)
          .toList();
    });
  }

  void filterStockByTracking() {
    setState(() {
      filteredStock = newStock
          .where((element) => element.tracking)
          .toList();
    });
  }

  void filterAllStock() {
    setState(() {
      filteredStock = newStock.toList();
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

    var kitchenDataSet = Provider.of<BeauticianData>(context, listen: false);
    return Scaffold(
      backgroundColor: kPlainBackground,
      appBar: AppBar(
        backgroundColor: kPlainBackground,
        title: Text('Store and Inventory', style: kNormalTextStyle.copyWith(fontSize: 18, color: kBlack, fontWeight: FontWeight.bold),),
        elevation: 0,
        automaticallyImplyLeading: false,
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation
          .miniCenterFloat,
      floatingActionButton:permissionsMap['store'] == false ?
      Container(): FloatingActionButton(
          backgroundColor: kAppPinkColor,
          onPressed: () {
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
      body: PopScope(
        canPop: false,
        child: SafeArea(
          child: permissionsMap['store'] == false ? LockedWidget(page: "Store"):

          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child:
                      Stack(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child:
                                TextField(
                                  controller: searchController,
                                  decoration: const InputDecoration(
                                    prefixIcon: Icon(Icons.search),
                                    hintText: 'By Product Name / Id',
                                    hintFadeDuration: Duration(milliseconds: 100),
                                  ),
                                  onChanged: filterStock,
                                ),
                              ),
                              permissionsMap['takeStock'] == false ? Container():
                              Row(

                                children: [
                                  GestureDetector(
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
                                      height: 45,
                                      width: 100,
                                      decoration: BoxDecoration(
                                        color: kBlack,
                                        borderRadius: BorderRadius.circular(10),
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,  // Start of the gradient
                                          end: Alignment.bottomRight, // End of the gradient
                                          colors: [kAppPinkColor, kBlueDarkColor],
                                        ),),
                                      child: Center(child: Text("Take Stock",
                                        style: kNormalTextStyle.copyWith(
                                            color: kPureWhiteColor),)),
                                      // color: kAirPink,
                                    ),
                                  ),
                                  kMediumWidthSpacing,
                                  GestureDetector(
                                      onTap: () {
                                        Navigator.pushNamed(context, StockHistoryPage.id);


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

                                ],
                              ),

                            ],
                          ),

                        ],
                      ),
                    ),
                    Expanded(
                      child:
                      ListView.builder(

                          itemCount: filteredStock.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {

                                kitchenDataSet.changeItemDetails(
                                  filteredStock[index].name,
                                  filteredStock[index].quantity.toDouble(),
                                  filteredStock[index].description,
                                  filteredStock[index].minimum.toDouble(),
                                  filteredStock[index].documentId,
                                  filteredStock[index].amount.toDouble(),
                                  filteredStock[index].image,
                                  filteredStock[index].tracking,
                                  filteredStock[index].saleable,);

                                showModalBottomSheet(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return Container(
                                        color: Colors.transparent,
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
                                                buildButton(context, 'Edit ${filteredStock[index].name}', Iconsax.pen_add,
                                                        () async {
                                                      Navigator.pop(context);
                                                      Navigator.pushNamed(context, ProductEditPage.id);


                                                    }
                                                ),
                                                SizedBox(height: 16.0),
                                                buildButton(context, '${filteredStock[index].name} Stock History', Iconsax.graph,  () async {
                                                  Navigator.pop(context);

                                                  if (filteredStock[index].stockTaking.isEmpty){
                                                    showDialog(context: context, builder: (BuildContext context){
                                                      return CupertinoAlertDialog(
                                                        title: const Text('No Stock Data'),
                                                        content: Text('There is no stock data available for ${filteredStock[index].name}', style: kNormalTextStyle.copyWith(color: kBlack),),
                                                        actions: [CupertinoDialogAction(isDestructiveAction: true,
                                                            onPressed: (){
                                                              // _btnController.reset();
                                                              Navigator.pop(context);

                                                            },
                                                            child: const Text('Cancel'))],
                                                      );
                                                    });
                                                  } else {
                                                    print(filteredStock[index].storeId);
                                                    Provider.of<StyleProvider>(context, listen: false).setStockAnalysisValues(filteredStock[index].storeId);
                                                    Navigator.pushNamed(context, StockManagementPage.id);
                                                  }

                                                } ),

                                              ],
                                            ),
                                          ),
                                        ),
                                      ); });

                              },
                              child:
                              Stack(
                                  children: [
                                    Card(
                                      color: kPureWhiteColor,
                                      shadowColor: kBackgroundGreyColor,
                                      child: Row(
                                        children: [

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
                                                      Text(filteredStock[index].name,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: kHeadingTextStyle,),
                                                      Text(
                                                        '${formatter.format(
                                                            filteredStock[index].amount)} $currency',
                                                        style: kNormalTextStyle
                                                            .copyWith(
                                                            fontWeight: FontWeight.bold,
                                                            color: kBlack,
                                                            fontSize: 14),)

                                                    ],
                                                  ),
                                                  kSmallHeightSpacing,
                                                  Text(filteredStock[index].description,
                                                      style: kNormalTextStyleSmallGrey),
                                                  kSmallHeightSpacing,
                                                  filteredStock[index].tracking == true
                                                      ? filteredStock[index].quantity >= 5
                                                      ? Text(
                                                      "Qty: ${filteredStock[index].quantity
                                                          .toString()}",
                                                      style: kNormalTextStyleSmallGrey
                                                          .copyWith(
                                                          color: kGreenThemeColor))
                                                      : Text(
                                                      "Qty: ${filteredStock[index].quantity
                                                          .toString()}",
                                                      style: kNormalTextStyleSmallGrey
                                                          .copyWith(
                                                          color: Colors.red))
                                                      : Container(),
                                                  filteredStock[index].saleable == false
                                                      ? Text("Not for sale",
                                                      style: kNormalTextStyleSmallGrey
                                                          .copyWith(
                                                          color: kAppPinkColor))
                                                      : Container()
                                                ],
                                              ),),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ]),
                            );
                          }),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  width: 300,
                  decoration: BoxDecoration(
                      color: kPureWhiteColor,
                      borderRadius: BorderRadius.circular(10)
                  ),
                  child: Column(


                    children: [
                      kLargeHeightSpacing,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          buildInfoCard(title: "Total Items", value: "${totalStock.length}", cardColor: kBlueThemeColor, cardIcon: Iconsax.box, fontSize: 14,
                              tapped: (){filterAllStock();}),
                          kSmallWidthSpacing,
                          buildInfoCard(title: "Tracked Items", value: "${totalStock.where((element) => element.tracking).length}", cardColor: kYellowThemeColor, cardIcon: Iconsax.watch, fontSize: 14,
                              tapped: (){filterStockByTracking();}),

                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          buildInfoCard(title: "Low Stock ", value:"${totalStock.where((element) => element.quantity < 5 && element.tracking).length}", cardColor: kRedColor,  cardIcon: Icons.battery_2_bar_outlined, fontSize: 14,
                              tapped: (){filterStockByLowStock();}),
                          kSmallWidthSpacing,
                          buildInfoCard(title: "Well Stocked  ", value:"${totalStock.where((element) => element.quantity > 5 && element.tracking).length}", cardColor: kGreenThemeColor,
                              cardIcon: Icons.battery_charging_full, fontSize: 14,  tapped: (){filterStockByWellStocked();}),


                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [

                          buildInfoCard(title: "   For Sale  ", value:"${totalStock.where((element) => element.saleable).length}", cardColor: kAppPinkColor,  cardIcon: Icons.point_of_sale_rounded, fontSize: 14,
                              tapped: (){filterStockByForSale();}
                          ),
                          kSmallWidthSpacing,
                          buildInfoCard(title: "  Not for Sale  ", value:"${totalStock.where((element) => !element.saleable).length}", cardColor: kBlack, cardIcon: Iconsax.box, fontSize: 14,
                              tapped: (){filterStockByNotForSale();}
                          ),

                        ],
                      ),

                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
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
