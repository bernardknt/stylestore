

import 'dart:convert';
import 'dart:io';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:csv/csv.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_storage_web/firebase_storage_web.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:stylestore/Utilities/constants/color_constants.dart';
import 'package:stylestore/Utilities/constants/font_constants.dart';
import 'package:stylestore/widgets/report_widgets/best_customers_widget.dart';
import 'package:stylestore/widgets/report_widgets/best_products_widget.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../model/styleapp_data.dart';
import '../../../widgets/graphs/purchases_graph.dart';
import 'package:intl/intl.dart';

import '../../../widgets/graphs/sales_graph_widget.dart';
class AnalyticsNewWeb extends StatefulWidget {
  const AnalyticsNewWeb({super.key});

  @override
  State<AnalyticsNewWeb> createState() => _AnalyticsNewWebState();
}

class _AnalyticsNewWebState extends State<AnalyticsNewWeb> {
  final CollectionReference appointmentsCollection = FirebaseFirestore.instance.collection('appointments');
  final CollectionReference dataCollection = FirebaseFirestore.instance.collection('purchases');
  String storeId = "storeId";
  DateTime _selectedDay = DateTime.now();
  DateTime _selectedEndDay = DateTime.now().subtract(const Duration(days: 1));




  Future<void> createCSV(Map<String, dynamic> reportData) async {
    List<List<dynamic>> rows = [];

    // Sales Data Header
    rows.add([
      "Date",
      "Total Sales",
      "Product",
      "Quantity",
      "Price"
    ]);

    // Sales Data Rows
    for (var sale in reportData["salesData"]) {
      for (var item in sale["items"]) {
        rows.add([
          sale["date"],
          sale["totalSales"],
          item["product"],
          item["quantity"],
          item["price"]
        ]);
      }
    }

    // Separator Row (Optional)
    rows.add([]);

    // Expense Data Header
    rows.add([
      "Date",
      "Total Expense",
      "Product",
      "Quantity",
      "Price",
      "Quality"
    ]);

    // Expense Data Rows
    for (var expense in reportData["expenseData"]) {
      for (var item in expense["items"]) {
        rows.add([
          expense["date"],
          expense["totalExpense"],
          item["product"],
          item["quantity"],
          item["price"],
          item["quality"]
        ]);
      }
    }

    // Top Customers Data Rows
    for (var customer in reportData["topCustomers"]) {
      rows.add([customer["name"], customer["totalSpent"]]);
    }
    String csvData = const ListToCsvConverter().convert(rows);

    // Temporary file creation
    final directory = await getTemporaryDirectory();
    final tempFile = File('${directory.path}/temp_report.csv');
    await tempFile.writeAsString(csvData);

    // Firebase Storage Upload
    // In-Memory CSV (No file creation)
    ListToCsvConverter().convert(rows);

    // Firebase Storage Upload for Web
    // final storage = FirebaseStorage.instanceFor(app: firebase.app()); // Assuming Firebase initialized
    // final storageRef = storage.ref('reports/sales_report.csv');
    //
    // try {
    //   // Upload as base64 encoded string
    //   await storageRef.putString(csvData, format: PutStringFormat.base64);
    //   print('CSV uploaded successfully!');
    // } on FirebaseException catch (e) {
    //   print('Upload failed: $e');
    // }

    // // File Saving (Optional)
    // final directory = await getApplicationDocumentsDirectory();
    // final file = File('${directory.path}/sales_and_expenses_report.csv');
    // await file.writeAsString(csvData);
  }


  Future<void> sendDataToCloudFunction(Map<String, dynamic> reportData) async {
    try {
      final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
        'generateCSV', // Replace 'generateCSV' with your function name
      );
      print("********************BEFORE ENCODING***********************************");
      print(reportData);
      print("*********************AFTER ENCODING*****************************");
      final jsonString = jsonEncode(reportData);
      print(jsonString);
      // dynamic serverCallableVariable = await callableSmsCustomer.call(<String, dynamic>{
      //   "message" : message,
      //   "number" : number,
      //
      // })
      dynamic response = await callable.call(<String, dynamic>{
        'body': jsonString

      });


      // Successful response (Assuming your function returns a message)
      print('Cloud Function response: ${response.data}');

    } on FirebaseFunctionsException catch (e) {
      print('Caught FirebaseFunctionsException: ${e.message}');
    } catch (e) {
      print('Caught generic error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    var styleData = Provider.of<StyleProvider>(context, listen: false);
    var styleDataListen = Provider.of<StyleProvider>(context, listen: true);
    return Scaffold(
      backgroundColor: kPlainBackground,
      appBar: AppBar(
        title:  Text('ANALYTICS\nFrom (${DateFormat('dd MMM yyyy').format(_selectedEndDay)}) to (${DateFormat('dd MMM yyyy').format(_selectedDay)})',textAlign: TextAlign.center,style: kNormalTextStyle.copyWith(fontWeight: FontWeight.bold,color: kBlack ),),

        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(onPressed: (){
        styleData.setBusinessJSON(styleDataListen.salesReportJSON, styleDataListen.purchasesReportJSON);
        print(styleData.businessReportJSON);
        sendDataToCloudFunction(styleData.businessReportJSON);
        // createCSV(styleData.businessReportJSON);
      },child: Tooltip(
          message: "Generate Report",
          child: Icon(Iconsax.document,color: kPureWhiteColor,)),backgroundColor: kAppPinkColor,),
      body: SingleChildScrollView(
        child:
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            kLargeHeightSpacing,
            Padding(
              padding: const EdgeInsets.only(left: 8, right: 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [

                  kLargeHeightSpacing,
                  Text('Select Date',textAlign: TextAlign.center,style: kNormalTextStyle.copyWith(fontWeight: FontWeight.bold,color: kBlack ),),
                  kLargeHeightSpacing,
                  Container(
                    width: 300,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: kPureWhiteColor.withOpacity(0.7)
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left:8.0),
                      child: TableCalendar(
                        calendarBuilders: CalendarBuilders(
                          defaultBuilder: (context, day, focusedDay) {
                            // Apply styling based on selected dates
                            if (_selectedDay == day) {
                              return Container(
                                decoration: const BoxDecoration(
                                  color: Colors.green, // Highlight start date with green
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(day.day.toString()),
                                ),
                              );
                            } else if (_selectedEndDay == day) {
                              return Container(
                                decoration: const BoxDecoration(
                                  color: Colors.red, // Highlight end date with red
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(day.day.toString()),
                                ),
                              );
                            } else {
                              // Default cell style for other dates
                              return Container(
                                child: Center(
                                  child: Text(day.day.toString()),
                                ),
                              );
                            }
                          },
                        ),
                        calendarStyle: CalendarStyle(
                            selectedTextStyle: kNormalTextStyle.copyWith(),
                          markerSize: 10
                        ),
                        rangeSelectionMode: RangeSelectionMode.toggledOn, // Enable range selection
                        rangeStartDay: _selectedEndDay,  // Start of the range
                        rangeEndDay:_selectedDay , // End of the range
                        focusedDay: _selectedEndDay, // Keep the end date in focus
                        onRangeSelected: (start, end, focusedDay) {
                          setState(() {
                            _selectedEndDay= start ?? _selectedEndDay;
                            _selectedDay  = end ??  _selectedDay;
                          });
                        },
                        firstDay: DateTime.utc(2020, 10, 16),
                        lastDay: DateTime.now(),
                      ),

                    ),
                  ),
                  kLargeHeightSpacing,
                  Text('Customers',textAlign: TextAlign.center,style: kNormalTextStyle.copyWith(fontWeight: FontWeight.bold,color: kBlack ),),
                  kLargeHeightSpacing,
                  Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: kBlueDarkColor
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child:  SingleChildScrollView(
                        child: Column(
                          children: [
                            Text('Top Customers(By Sale Value)',textAlign: TextAlign.center,style: kNormalTextStyle.copyWith(fontWeight: FontWeight.bold,color: kGreenThemeColor, fontSize: 12,  ),),
                            bestCustomersWidget(Provider.of<StyleProvider>(context, listen: true).bestCustomerResults, 5)
                          ],
                        ),
                      ),

                    ),
                  ),
                  kLargeHeightSpacing,
                  Text('Products',textAlign: TextAlign.center,style: kNormalTextStyle.copyWith(fontWeight: FontWeight.bold,color: kBlack ),),
                  kLargeHeightSpacing,
                  Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: kPureWhiteColor
                    ),
                    child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Text('Top Products(By Frequency)',textAlign: TextAlign.center,style: kNormalTextStyle.copyWith(fontWeight: FontWeight.bold,color: kGreenThemeColor, fontSize: 12,  ),),

                            bestProductsWidget(Provider.of<StyleProvider>(context, listen: true).bestProductResults,)

                          ],
                        )
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    kLargeHeightSpacing,
                    Text('',textAlign: TextAlign.center,style: kNormalTextStyle.copyWith(fontWeight: FontWeight.bold,color: kBlack ),),
                    kLargeHeightSpacing,
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 10),
                      child: Container(
                          height: 1300,
                          color: kPlainBackground,
                          child: SalesGraphWidget(
                            key: ValueKey('graph-sales${_selectedDay}-${_selectedEndDay}'),
                            startDate:_selectedEndDay , endDate:_selectedDay , )),
                    ),
                  ],
                )),
            Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    kLargeHeightSpacing,
                    Text('',textAlign: TextAlign.center,style: kNormalTextStyle.copyWith(fontWeight: FontWeight.bold,color: kBlack ),),
                    kLargeHeightSpacing,
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                      child: Container(
                          height: 850,
                          color: kPlainBackground,
                          child: PurchaseGraphWidget(
                            key: ValueKey('graph-${_selectedDay}-${_selectedEndDay}'),
                            startDate:_selectedEndDay , endDate:_selectedDay , )),
                    ),
                  ],
                )),



          ],
        ),
      ),
    );
  }
}
