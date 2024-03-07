import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cool_alert/cool_alert.dart';
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
import 'package:stylestore/screens/products_pages/search_detailed_products.dart';
import 'package:stylestore/screens/products_pages/products_upload.dart';
import 'package:stylestore/screens/products_pages/restock_page.dart';
import 'package:stylestore/screens/products_pages/stock_history.dart';
import 'package:stylestore/screens/products_pages/stock_items.dart';
import 'package:stylestore/screens/products_pages/update_stock.dart';
import 'package:stylestore/utilities/constants/user_constants.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../../../../Utilities/constants/color_constants.dart';
import '../../../../../Utilities/constants/font_constants.dart';
import 'package:flutter/src/painting/box_border.dart' as boxBorder;
import '../../model/beautician_data.dart';
import '../../model/excel_model.dart';
import '../../model/styleapp_data.dart';
import '../../utilities/constants/icon_constants.dart';
import '../../widgets/custom_popup.dart';
import '../../widgets/locked_widget.dart';
import '../../widgets/modalButton.dart';
class MerchantStorePage extends StatefulWidget {


  @override
  State<MerchantStorePage> createState() => _MerchantStorePageState();
}

class _MerchantStorePageState extends State<MerchantStorePage> {

  late YoutubePlayerController _controller;


  var formatter = NumberFormat('#,###,000');
  String youtubeUrl = 'https://www.youtube.com/watch?v=8DhO5YOhTx4&list=RD8DhO5YOhTx4&start_radio=1&ab_channel=WilliamMcDowellMusic';

  Map<String, dynamic> permissionsMap = {};
  Map<String, dynamic> videoMap = {};
  TextEditingController searchController = TextEditingController();
  List<AllStockData> filteredStock = [];
  List<AllStockData> newStock = [];

  defaultInitialization()async{
    permissionsMap = await CommonFunctions().convertPermissionsJson();
    videoMap = await CommonFunctions().convertWalkthroughVideoJson();
    newStock = await retrieveSupplierData();
    filteredStock.addAll(newStock);

    print(newStock);
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
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    defaultInitialization();

  }

  @override
  Widget build(BuildContext context) {

    var kitchenDataSet = Provider.of<BeauticianData>(context, listen: false);

    return
      Scaffold(
        appBar: AppBar(
            backgroundColor: kPureWhiteColor,
            elevation: 0,
            automaticallyImplyLeading: false,
        ),

        floatingActionButtonLocation: FloatingActionButtonLocation
            .miniCenterFloat,
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
                                      // Navigator.pop(context);
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
        body: WillPopScope(
          onWillPop: () async {
            return false; // return a `Future` with false value so this route cant be popped or closed.
          },
          child: SafeArea(
            child: permissionsMap['store'] == false ? LockedWidget(page: "Store"):Column(
              children: [

                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Stack(
                    children: [
                      TextField(
                        controller: searchController,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.search),
                          hintText: 'By Name/ Product / Phone Number',
                          hintFadeDuration: Duration(milliseconds: 100),
                        ),
                        onChanged: filterStock,
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
                            // showStoreDialogFunc(context, imgList[index], nameList[index], descList[index], amountList[index]);
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

                                                          // Navigator.pushNamed(context, SuccessPageHiFive.id);
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
                                  color: kBackgroundGreyColor,
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
                                                        filteredStock[index].amount)} Ugx',
                                                    style: kNormalTextStyle
                                                        .copyWith(
                                                        color: kGreenThemeColor,
                                                        fontSize: 14),)

                                                ],
                                              ),
                                              kSmallHeightSpacing,
                                              Text(filteredStock[index].description,
                                                  style: kNormalTextStyleSmallGrey),
                                              kSmallHeightSpacing,
                                              filteredStock[index].tracking == true
                                                  ? filteredStock[index].quantity >=
                                                  5
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
                                Positioned(
                                    right: 0,
                                    top: 0,
                                    child: GestureDetector(
                                        onTap: () {
                                          CoolAlert.show(
                                              lottieAsset: 'images/question.json',
                                              context: context,
                                              type: CoolAlertType.success,
                                              text: "Are you sure you want to remove this from your services list",
                                              title: "Remove Item?",
                                              confirmBtnText: 'Yes',
                                              confirmBtnColor: Colors.red,
                                              cancelBtnText: 'Cancel',
                                              showCancelBtn: true,
                                              backgroundColor: kAppPinkColor,
                                              onConfirmBtnTap: () {
                                                CommonFunctions()
                                                    .removeDocumentFromServer(
                                                    filteredStock[index].storeId,
                                                    'stores');

                                                Navigator.pop(context);
                                              }
                                          );
                                        },

                                        child: kIconCancel)),
                              ]),
                        );
                      }),
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
      // showDialog(context: context, builder: (context) {
      //   return Center(
      //       child:
      //       Column(
      //         mainAxisSize: MainAxisSize.min,
      //         children: [
      //           CircularProgressIndicator(color: kAppPinkColor,),
      //           kSmallHeightSpacing,
      //           DefaultTextStyle(
      //             style: kNormalTextStyle.copyWith(color: kPureWhiteColor),
      //             child: Text("Updating products to your store",
      //               textAlign: TextAlign.center,),
      //           )
      //           // Text("Loading Contacts", style: kNormalTextStyle.copyWith(color: kPureWhiteColor),)
      //         ],
      //       ));
      // });
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
