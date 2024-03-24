import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stylestore/Utilities/constants/color_constants.dart';
import 'package:stylestore/Utilities/constants/font_constants.dart';
import 'package:stylestore/Utilities/constants/user_constants.dart';
import 'package:stylestore/model/common_functions.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

import '../../model/purchases.dart';
import '../build_info_card.dart';

class PurchaseGraphWidget extends StatefulWidget {
  final DateTime startDate;
  final DateTime endDate;

  const PurchaseGraphWidget({Key? key, required this.startDate, required this.endDate}) : super(key: key);

  @override
  _PurchaseGraphWidgetState createState() => _PurchaseGraphWidgetState();
}


class _PurchaseGraphWidgetState extends State<PurchaseGraphWidget> {
  List<Purchase> _purchases = [];
  bool _isLoading = true;



  @override
  void initState() {
    super.initState();
    _fetchPurchases();
  }

  void _fetchPurchases() async {
    // Get purchases for the current month
    final prefs = await SharedPreferences.getInstance();
    String storeId = prefs.getString(kStoreIdConstant)??"";

    final purchasesQuery = FirebaseFirestore.instance
        .collection('purchases').where('storeId', isEqualTo: storeId)
        .where('date', isGreaterThanOrEqualTo: widget.startDate)
        .where('date', isLessThanOrEqualTo: widget.endDate);

    // .where('date', isGreaterThanOrEqualTo: DateTime(DateTime.now().year, DateTime.now().month, 1));

    purchasesQuery.snapshots().listen((snapshot) {
      setState(() {
        _purchases = snapshot.docs.map((doc) => Purchase.fromSnapshot(doc)).toList();
        _isLoading = false;
      });
    });
  }

  // 1. Highest Expense Day Value
  double getHighestExpenseValue() {
    double highestExpense = 0;
    for (final purchase in _purchases) {
      final currentExpense = _calculatePurchaseTotal(purchase);
      if (currentExpense > highestExpense) {
        highestExpense = currentExpense;
      }
    }
    return highestExpense;
  }

  // 2. Highest Expense Day Date
  DateTime getHighestExpenseDate() {
    if (_purchases.isEmpty) {
      return DateTime.now(); // Or a default value
    }

    DateTime highestExpenseDate = _purchases[0].date;
    double highestExpense = _calculatePurchaseTotal(_purchases[0]);

    for (int i = 1; i < _purchases.length; i++) {
      final currentExpense = _calculatePurchaseTotal(_purchases[i]);
      if (currentExpense > highestExpense) {
        highestExpense = currentExpense;
        highestExpenseDate = _purchases[i].date;
      }
    }
    return highestExpenseDate;
  }

  // 3. Total Expenses for the Selected Period
  double getTotalExpenses() {
    double totalExpenses = 0;
    for (final purchase in _purchases) {
      totalExpenses += _calculatePurchaseTotal(purchase);
    }
    return totalExpenses ;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPlainBackground,

      body: Center(
        child: _isLoading
            ? CircularProgressIndicator()
            : _buildGraph(),
      ),
    );
  }

  Widget _buildGraph() {
    final data = _prepareGraphData();
    final _cumulativeData = _prepareCumulativeGraphData();
    return
      Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: kPureWhiteColor
        ),
        child: Column(
          children: [
            Text("Summary",textAlign: TextAlign.center,style: kNormalTextStyle.copyWith(fontWeight: FontWeight.bold,color: kBlack, ),),

            kSmallHeightSpacing,
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  buildInfoCard(title: "Total Expenses", value: CommonFunctions().formatter.format(getTotalExpenses()), cardColor: kBlueThemeColor, fontSize: 12,
                      tapped: (){}),
                  kSmallWidthSpacing,
                  buildInfoCard(title: "Highest Day", value: "${DateFormat('dd, MMM, yyyy').format(getHighestExpenseDate())}", cardColor: kBlueThemeColor, fontSize: 12,
                      tapped: (){}),
                  kSmallWidthSpacing,
                  buildInfoCard(title: "Highest Expense", value: CommonFunctions().formatter.format(getHighestExpenseValue()), cardColor: kBlueThemeColor, fontSize: 12,
                      tapped: (){}),
                ],
              ),
            ),
            kSmallHeightSpacing,
            Text("Daily Expenses",textAlign: TextAlign.center,style: kNormalTextStyle.copyWith(fontWeight: FontWeight.bold,color: kBlack, ),),

            kSmallHeightSpacing,
            SfCartesianChart(
            primaryXAxis: DateTimeAxis(
              dateFormat: DateFormat.MMMd(),
              majorGridLines: const MajorGridLines(width: 0), //// Customize date format if needed
            ),
            primaryYAxis: NumericAxis(
              numberFormat: NumberFormat.compact(), // Formats like 1M, 10M, etc.
              majorGridLines: const MajorGridLines(width: 0), //
            ),
            tooltipBehavior: TooltipBehavior(enable: true,  header: 'Total Purchases'),
            series:
            // <CartesianSeries<TimeSeriesSales, DateTime>>[
            //   LineSeries<TimeSeriesSales, DateTime>(
            //     enableTooltip: true,
            //
            //     // Enable tooltips
            //     // markerSettings: const MarkerSettings(isVisible: true),
            //     dataSource: data,
            //     xValueMapper: (TimeSeriesSales sales, _) => sales.time,
            //     yValueMapper: (TimeSeriesSales sales, _) => sales.sales,
            //   )
            // ],
            <CartesianSeries<TimeSeriesSales, DateTime>>[
              ColumnSeries<TimeSeriesSales, DateTime>(
                enableTooltip: true,
                // color: kAppPinkColor,
                gradient: const LinearGradient( // Gradient fill
                    colors: [kAppPinkColor, kBlueDarkColor],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [0.0, 1.0]
                ),

                // Enable tooltips
                // markerSettings: const MarkerSettings(isVisible: true),
                dataSource: data,
                xValueMapper: (TimeSeriesSales sales, _) => sales.time,
                yValueMapper: (TimeSeriesSales sales, _) => sales.sales,
              )
            ],
                ),

            kSmallHeightSpacing,

            Text("Cumulative Expenses",textAlign: TextAlign.center,style: kNormalTextStyle.copyWith(fontWeight: FontWeight.bold,color: kBlack, ),),
            kSmallHeightSpacing,
            SfCartesianChart(
              primaryXAxis: DateTimeAxis(
                dateFormat: DateFormat.MMMd(),
                majorGridLines: const MajorGridLines(width: 0), //// Customize date format if needed
              ),
              primaryYAxis: NumericAxis(
                numberFormat: NumberFormat.compact(), // Formats like 1M, 10M, etc.
                majorGridLines: const MajorGridLines(width: 0), //
              ),
              tooltipBehavior: TooltipBehavior(enable: true,  header: 'Total Purchases'),
              series:
              <CartesianSeries<TimeSeriesSales, DateTime>>[
                LineSeries<TimeSeriesSales, DateTime>(
                  enableTooltip: true,

                  // Enable tooltips
                  // markerSettings: const MarkerSettings(isVisible: true),
                  dataSource: _cumulativeData,
                  xValueMapper: (TimeSeriesSales sales, _) => sales.time,
                  yValueMapper: (TimeSeriesSales sales, _) => sales.sales,
                )
              ],

            ),


          ],
        ),
      );
  }

  List<TimeSeriesSales> _prepareGraphData() {
    // 1. Group purchases by day
    Map<DateTime, double> dailySales = {};
    for (var purchase in _purchases) {
      DateTime dateKey = DateTime(purchase.date.year, purchase.date.month, purchase.date.day);
      dailySales[dateKey] = (dailySales[dateKey] ?? 0) + _calculatePurchaseTotal(purchase);
    }

    // 2. Convert to TimeSeriesSales
    return dailySales.entries.map((entry) =>
        TimeSeriesSales(entry.key, entry.value)
    ).toList();
  }

  List<TimeSeriesSales> _prepareCumulativeGraphData() {
    double cumulativeTotal = 0;
    Map<DateTime, double> cumulativeSales = {};
    for (var purchase in _purchases) {
      DateTime dateKey = DateTime(purchase.date.year, purchase.date.month, purchase.date.day);
      cumulativeTotal += _calculatePurchaseTotal(purchase);
      cumulativeSales[dateKey] = cumulativeTotal;
    }
    // 2. Convert to TimeSeriesSales
    return cumulativeSales.entries.map((entry) =>
        TimeSeriesSales(entry.key, entry.value)
    ).toList();
  }

  // Helper to calculate total price of a single purchase
  double _calculatePurchaseTotal(Purchase purchase) {
    double total = 0;
    for (var item in purchase.items) {
      total += item.price;
    }
    print("${purchase.date} with ${purchase.items.length} items: $total");
    return total;
  }
}

class TimeSeriesSales {
  final DateTime time;
  final double sales;

  TimeSeriesSales(this.time, this.sales);
}
