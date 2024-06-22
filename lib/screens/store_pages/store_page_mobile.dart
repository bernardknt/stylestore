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
import 'package:stylestore/screens/store_pages/take_stock_page.dart';
import 'package:stylestore/screens/store_pages/upload_products_ptions.dart';
import 'package:stylestore/utilities/constants/user_constants.dart';
import '../../../../../Utilities/constants/color_constants.dart';
import '../../../../../Utilities/constants/font_constants.dart';
import '../../model/beautician_data.dart';
import '../../model/excel_model.dart';
import '../../model/styleapp_data.dart';
import '../../widgets/build_info_card.dart';
import '../../widgets/locked_widget.dart';
import '../../widgets/modalButton.dart';

class StorePageMobile extends StatefulWidget {

  @override
  State<StorePageMobile> createState() => _StorePageMobileState();
}

class _StorePageMobileState extends State<StorePageMobile> {


  var formatter = NumberFormat('#,###,000');
  Map<String, dynamic> permissionsMap = {};
  Map<String, dynamic> videoMap = {};
  TextEditingController searchController = TextEditingController();
  String currency = "";
  String storeName = "";


  defaultInitialization()async{
    final prefs = await SharedPreferences.getInstance();
    storeName = CommonFunctions().getFirstWord(prefs.getString(kBusinessNameConstant)??"");
    permissionsMap = await CommonFunctions().convertPermissionsJson();
    videoMap = await CommonFunctions().convertWalkthroughVideoJson();

    await CommonFunctions().retrieveStockData(context);

    currency = prefs.getString(kCurrency)??"USD";
      setState(() {

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
    var styleData = Provider.of<StyleProvider>(context, listen: false);
    var styleDataListen = Provider.of<StyleProvider>(context, listen:true);

    var kitchenDataSet = Provider.of<BeauticianData>(context, listen: false);
    return Scaffold(
        backgroundColor: kPlainBackground,
        appBar: AppBar(
            backgroundColor: kPlainBackground,
            title: Text('$storeName Products & Inventory', style: kNormalTextStyle.copyWith(fontSize: 18, color: kBlack, fontWeight: FontWeight.bold),),
          centerTitle: true,
          elevation: 0,
            automaticallyImplyLeading: false,

        ),

        floatingActionButton:permissionsMap['store'] == false ?Container(): FloatingActionButton(
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
                                                body: UploadProductOptions());
                                          });
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

            Column(
              children: [
                Container(
                  height: 130,
                  child:
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(


                        children: [
                          kLargeHeightSpacing,
                          buildInfoCard(title: "Total Items", value: "${styleData.totalStock.length}", cardColor: kBlueThemeColor, cardIcon: Iconsax.box, fontSize: 12,
                              tapped: (){styleData.filterAllStock();}),
                          kSmallWidthSpacing,
                          buildInfoCard(title: "Tracked Items", value: "${styleData.totalStock.where((element) => element.tracking).length}", cardColor: kYellowThemeColor, cardIcon: Iconsax.watch, fontSize: 12,
                              tapped: (){styleData.filterStockByTracking();}),
                          buildInfoCard(title: "Low Stock ", value:"${styleData.totalStock.where((element) => element.quantity < 5 && element.tracking).length}", cardColor: kRedColor,  cardIcon: Icons.battery_2_bar_outlined, fontSize: 14,
                              tapped: (){styleData.filterStockByLowStock();}),
                          kSmallWidthSpacing,
                          buildInfoCard(title: "Well Stocked  ", value:"${styleData.totalStock.where((element) => element.quantity > 5 && element.tracking).length}", cardColor: kGreenThemeColor,
                              cardIcon: Icons.battery_charging_full, fontSize: 14,  tapped: (){styleData.filterStockByWellStocked();}),
                          buildInfoCard(title: "   For Sale  ", value:"${styleData.totalStock.where((element) => element.saleable).length}", cardColor: kAppPinkColor,  cardIcon: Icons.point_of_sale_rounded, fontSize: 12,
                              tapped: (){styleData.filterStockByForSale();}
                          ),
                          kSmallWidthSpacing,
                          buildInfoCard(title: "  Not for Sale  ", value:"${styleData.totalStock.where((element) => !element.saleable).length}", cardColor: kBlack, cardIcon: Iconsax.box, fontSize: 12,
                              tapped: (){styleData.filterStockByNotForSale();}
                          ),

                        ],
                      ),
                    ),
                  ),
                ),
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
                              onChanged: styleData.filterStockQuery,
                            ),
                          ),


                        ],
                      ),

                    ],
                  ),
                ),
                Expanded(
                  child:
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListView.builder(

                        itemCount: styleDataListen.filteredStock.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {

                              kitchenDataSet.changeItemDetails(
                                  styleData.filteredStock[index].name,
                                  styleData.filteredStock[index].quantity.toDouble(),
                                  styleData.filteredStock[index].description,
                                  styleData.filteredStock[index].minimum.toDouble(),
                                  styleData.filteredStock[index].documentId,
                                  styleData.filteredStock[index].amount.toDouble(),
                                  styleData.filteredStock[index].image,
                                  styleData.filteredStock[index].tracking,
                                  styleData.filteredStock[index].saleable,
                                  styleData.filteredStock[index].barcode,
                                  styleData.filteredStock[index].unit,
                                  styleData.filteredStock[index].ignore



                              );
                              Navigator.pushNamed(context, ProductEditPage.id);


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
                                                    Text(styleData.filteredStock[index].name,
                                                      overflow: TextOverflow
                                                          .ellipsis,
                                                      style: kHeadingTextStyle,),
                                                    Column(
                                                      children: [
                                                        Text(
                                                          '${formatter.format(
                                                              styleData.filteredStock[index].amount)} $currency',
                                                          style: kNormalTextStyle
                                                              .copyWith(
                                                            fontWeight: FontWeight.bold,
                                                              color: kBlack,
                                                              fontSize: 14),),
                                                        kLargeHeightSpacing,
                                                        styleData.filteredStock[index].ignore == true? Icon(CupertinoIcons.bell_slash, color: kRedColor,size: 15,):SizedBox(),


                                                      ],
                                                    ),

                                                  ],
                                                ),
                                                Text(styleData.filteredStock[index].description,
                                                    style: kNormalTextStyleSmallGrey.copyWith(fontSize: 12, fontWeight: FontWeight.w500)),
                                                kSmallHeightSpacing,
                                                Row(
                                                  children: [
                                                    Icon(Iconsax.barcode, size: 15, color: kFontGreyColor,),
                                                    kSmallWidthSpacing,
                                                    Text(styleData.filteredStock[index].barcode,
                                                        style: kNormalTextStyleSmallGrey),
                                                  ],
                                                ),
                                                kSmallHeightSpacing,
                                                styleData.filteredStock[index].tracking == true
                                                    ? styleData.filteredStock[index].quantity >=
                                                    5
                                                    ? Text(
                                                    "Qty: ${styleData.filteredStock[index].quantity
                                                        .toString()} ${styleData.filteredStock[index].unit}",
                                                    style: kNormalTextStyleSmallGrey
                                                        .copyWith(
                                                        color: kGreenThemeColor))
                                                    : Text(
                                                    "Qty: ${styleData.filteredStock[index].quantity
                                                        .toString()} ${styleData.filteredStock[index].unit}",
                                                    style: kNormalTextStyleSmallGrey
                                                        .copyWith(
                                                        color: Colors.red))
                                                    : Container(),
                                                styleData.filteredStock[index].saleable == false
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
                ),
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


