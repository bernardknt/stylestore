

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:stylestore/Utilities/constants/color_constants.dart';
import 'package:stylestore/Utilities/constants/font_constants.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../widgets/graphs/purchases_graph.dart';
import 'package:intl/intl.dart';
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
  DateTime _selectedEndDay = DateTime.now().subtract(const Duration(days: 30));




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPlainBackground,
      appBar: AppBar(
        title:  Text('ANALYTICS\nFrom (${DateFormat('dd MMM yyyy').format(_selectedEndDay)}) to (${DateFormat('dd MMM yyyy').format(_selectedDay)})',textAlign: TextAlign.center,style: kNormalTextStyle.copyWith(fontWeight: FontWeight.bold,color: kBlack ),),

        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(onPressed: (){},child: Tooltip(
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

                        calendarStyle: CalendarStyle(
                            selectedTextStyle: kNormalTextStyle.copyWith()
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
                      child:  Text('Top Customers',textAlign: TextAlign.center,style: kNormalTextStyle.copyWith(fontWeight: FontWeight.bold,color: kPureWhiteColor, fontSize: 12 ),),

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
                        padding: const EdgeInsets.only(left:8.0),
                        child: Text("Top Products")
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
                    Text('Expenses',textAlign: TextAlign.center,style: kNormalTextStyle.copyWith(fontWeight: FontWeight.bold,color: kBlack ),),
                    kLargeHeightSpacing,
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                      child: Container(
                          height: 820,
                          color: kPlainBackground,
                          child: PurchaseGraphWidget(
                            key: ValueKey('graph-${_selectedDay}-${_selectedEndDay}'),
                            startDate:_selectedEndDay , endDate:_selectedDay , )),
                    ),
                  ],
                )),
            Column(
              children: [
                kLargeHeightSpacing,
                kLargeHeightSpacing,
                Text('Sales',textAlign: TextAlign.center,style: kNormalTextStyle.copyWith(fontWeight: FontWeight.bold,color: kBlack ),),

                Container(
                  width: 400,
                ),
              ],
            )
            // Expanded(
            //     child: Column(
            //       mainAxisAlignment: MainAxisAlignment.start,
            //       crossAxisAlignment: CrossAxisAlignment.center,
            //       children: [
            //         Text('Expenses',textAlign: TextAlign.center,style: kNormalTextStyle.copyWith(fontWeight: FontWeight.bold,color: kBlack ),),
            //         kLargeHeightSpacing,
            //         Padding(
            //           padding: const EdgeInsets.only(left: 8.0, right: 8.0),
            //           child: Container(
            //               height: 400,
            //               color: kPlainBackground,
            //               child: PurchaseGraphWidget(
            //                 key: ValueKey('graph-${_selectedDay}-${_selectedEndDay}'),
            //                 startDate:_selectedEndDay , endDate:_selectedDay , )),
            //         ),
            //       ],
            //     )),
          ],
        ),
      ),
    );
  }
}
