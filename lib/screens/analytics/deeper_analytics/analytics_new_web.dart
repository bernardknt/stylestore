

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
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
