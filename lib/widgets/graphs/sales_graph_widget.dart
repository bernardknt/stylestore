
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stylestore/Utilities/constants/color_constants.dart';
import 'package:stylestore/Utilities/constants/font_constants.dart';
import 'package:stylestore/Utilities/constants/user_constants.dart';
import 'package:stylestore/model/common_functions.dart';
import 'package:stylestore/model/styleapp_data.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import '../../model/sales.dart';
import '../build_info_card.dart';
import '../report_widgets/best_customers_widget.dart';


class SalesGraphWidget extends StatefulWidget {
  final DateTime startDate;
  final DateTime endDate;

  const SalesGraphWidget({Key? key, required this.startDate, required this.endDate}) : super(key: key);

  @override
  _SalesGraphWidgetState createState() => _SalesGraphWidgetState();
}


class _SalesGraphWidgetState extends State<SalesGraphWidget> {
  List<Sales> _sales = [];
  bool _isLoading = true;
  Map<String, double> salesByPaymentMethod = {};
  List<MapEntry<String, double>> topCustomers = [];
  double totalPaid = 0;
  double totalUnpaid = 0;

  @override
  void initState() {
    super.initState();
    _fetchSales();
  }

  Map<String, dynamic> _createReportJson() {
    List<Map<String, dynamic>> salesData = [];
    List<Map<String, dynamic>> topCustomersData = [];

    // **1. Populate salesData:**
    for (final sale in _sales) {
      // Assuming each 'sale' has a list of items
      for (final item in sale.items) { // Notice how we introduce 'item' here
        salesData.add({
          "date": DateFormat('yyyy-MM-dd').format(sale.date),
          "totalSales": _calculateSalesTotal(sale),
          "items": [
            {
              "product": item.product,
              "quantity": item.quantity,
              "price": item.price
            }
          ]
        });
      }
    }

    // **2. Populate topCustomersData (Assuming top5Customers is available)**
    for (final customer in topCustomers) {
      topCustomersData.add({
        "name": customer.key,
        "totalSpent": customer.value
      });
    }

    return {

      "salesData": salesData,
      "topCustomers": topCustomersData,

    };
  }

  void _fetchSales() async {
    // Get purchases for the current month
    final prefs = await SharedPreferences.getInstance();
    String storeId = prefs.getString(kStoreIdConstant)??"";
    salesByPaymentMethod.clear();
    final salesQuery = FirebaseFirestore.instance
        .collection('appointments').where('sender_id', isEqualTo: storeId)
        .where('order_time', isGreaterThanOrEqualTo: widget.startDate)
        .where('order_time', isLessThanOrEqualTo: widget.endDate);


    salesQuery.snapshots().listen((snapshot) {
      setState(() {

        _sales = snapshot.docs.map((doc) => Sales.fromSnapshot(doc)).toList();
        _isLoading = false;
        _calculateTopCustomers();
        _calculateTopProducts();
        Provider.of<StyleProvider>(context, listen: false).setSalesJSON(_createReportJson());
        _createReportJson();
      });
    });
  }

  // 1. Highest Expense Day Value
  double getHighestExpenseValue() {
    double highestExpense = 0;
    for (final purchase in _sales) {
      final currentExpense = _calculateSalesTotal(purchase);
      if (currentExpense > highestExpense) {
        highestExpense = currentExpense;
      }
    }
    return highestExpense;
  }

  // 2. Highest Expense Day Date
  DateTime getHighestExpenseDate() {
    if (_sales.isEmpty) {
      return DateTime.now(); // Or a default value
    }

    DateTime highestExpenseDate = _sales[0].date;
    double highestExpense = _calculateSalesTotal(_sales[0]);

    for (int i = 1; i < _sales.length; i++) {
      final currentExpense = _calculateSalesTotal(_sales[i]);
      if (currentExpense > highestExpense) {
        highestExpense = currentExpense;
        highestExpenseDate = _sales[i].date;
      }
    }
    return highestExpenseDate;
  }

  // 3. Total Expenses for the Selected Period
  double getTotalExpenses() {
    double totalExpenses = 0;
    for (final purchase in _sales) {
      totalExpenses += _calculateSalesTotal(purchase);
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
    List<PaymentData> paymentChartData = salesByPaymentMethod.entries.map((entry) =>
        PaymentData(entry.key, entry.value)
    ).toList();

    return
      Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: const LinearGradient( // Gradient fill
                colors: [kAppPinkColor, kBlueDarkColor],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.0, 1.0]
            ),
            color: kGreenThemeColor
        ),
        child: Column(
          children: [
            kLargeHeightSpacing,

            CommonFunctions().differenceInDays(widget.startDate, widget.endDate) == 1 ?Text("Sales (For ${CommonFunctions().differenceInDays(widget.startDate, widget.endDate)} day)",textAlign: TextAlign.center,style: kNormalTextStyle.copyWith(fontWeight: FontWeight.bold,color: kPureWhiteColor, ),):
            Text("Sales (For ${CommonFunctions().differenceInDays(widget.startDate, widget.endDate)} days)",textAlign: TextAlign.center,style: kNormalTextStyle.copyWith(fontWeight: FontWeight.bold,color: kPureWhiteColor, ),),
            kLargeHeightSpacing,
            kSmallHeightSpacing,
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  buildInfoCard(fontColor: kPureWhiteColor,title: "Total Sales", value: CommonFunctions().formatter.format(getTotalExpenses()), cardColor: kYellowThemeColor, fontSize: 12,
                      tapped: (){}),
                  kSmallWidthSpacing,
                  buildInfoCard(fontColor: kPureWhiteColor,title: "Best Day", value: "${DateFormat('dd, MMM, yyyy').format(getHighestExpenseDate())}", cardColor: kYellowThemeColor, fontSize: 12,
                      tapped: (){}),
                  kSmallWidthSpacing,
                  buildInfoCard(fontColor: kPureWhiteColor, title: "Highest Value Sale", value: CommonFunctions().formatter.format(getHighestExpenseValue()), cardColor: kYellowThemeColor, fontSize: 12,
                      tapped: (){}),
                ],
              ),
            ),
            kSmallHeightSpacing,
            Text("Daily Sales",textAlign: TextAlign.center,style: kNormalTextStyle.copyWith(fontWeight: FontWeight.bold,color: kPureWhiteColor, ),),

            kSmallHeightSpacing,
            SfCartesianChart(
              primaryXAxis: DateTimeAxis(
                dateFormat: DateFormat.MMMd(),
                majorGridLines: const MajorGridLines(width: 0),
                labelStyle: const TextStyle(color: kPureWhiteColor), //// Customize date format if needed
              ),
              primaryYAxis: NumericAxis(
                numberFormat: NumberFormat.compact(), // Formats like 1M, 10M, etc.
                majorGridLines: const MajorGridLines(width: 0),
                labelStyle: const TextStyle(color: kPureWhiteColor), //
              ),
              tooltipBehavior: TooltipBehavior(enable: true,  header: "Day's Sales"),
              series:

              <CartesianSeries<TimeSeriesSales, DateTime>>[
                ColumnSeries<TimeSeriesSales, DateTime>(
                  enableTooltip: true,
                  borderGradient: const LinearGradient( // Gradient fill
                colors: [kCustomColor, kGreenThemeColor],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.0, 1.0],

            ),

                  // color: kAppPinkColor,
                  gradient: const LinearGradient( // Gradient fill
                      colors: [kCustomColor, kGreenThemeColor],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: [0.0, 1.0],

                  ),
                  dataSource: data,
                  xValueMapper: (TimeSeriesSales sales, _) => sales.time,
                  yValueMapper: (TimeSeriesSales sales, _) => sales.sales,
                )
              ],
            ),

            kSmallHeightSpacing,

            Text("Cumulative Sales",textAlign: TextAlign.center,style: kNormalTextStyle.copyWith(fontWeight: FontWeight.bold,color: kPureWhiteColor
              , ),),
            kSmallHeightSpacing,
            SfCartesianChart(
              primaryXAxis: DateTimeAxis(
                dateFormat: DateFormat.MMMd(),
                majorGridLines: const MajorGridLines(width: 0),
                labelStyle: const TextStyle(color: kPureWhiteColor), ////// Customize date format if needed
              ),
              primaryYAxis: NumericAxis(
                numberFormat: NumberFormat.compact(), // Formats like 1M, 10M, etc.
                majorGridLines: const MajorGridLines(width: 0),
                labelStyle: const TextStyle(color: kPureWhiteColor), //
              ),
              tooltipBehavior: TooltipBehavior(enable: true,  header: 'Total Sales'),
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
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  buildInfoCard(fontColor: kPureWhiteColor, title: "Paid Invoices", value: CommonFunctions().formatter.format(totalPaid), cardColor: Colors.green, fontSize: 12,
                      tapped: (){}),
                  kSmallWidthSpacing,
                  buildInfoCard(fontColor:kPureWhiteColor,title: "Unpaid Invoices", value: CommonFunctions().formatter.format(totalUnpaid), cardColor: Colors.red,fontSize: 12,
                      tapped: (){}),
                ],
              ),
            ),

            kSmallHeightSpacing,

            Text("Payment Method",textAlign: TextAlign.center,style: kNormalTextStyle.copyWith(fontWeight: FontWeight.bold,color: kPureWhiteColor),),
            Text("(Only Paid Invoices)",textAlign: TextAlign.center,style: kNormalTextStyle.copyWith(fontWeight: FontWeight.bold,color: kPureWhiteColor, fontSize: 10),),

            SfCircularChart(
                legend: Legend(
                  isVisible: true,
                  textStyle: kNormalTextStyle.copyWith(color: kPureWhiteColor)
                ), // Optional: Add a legend
                tooltipBehavior: TooltipBehavior(enable: true),
                series: <PieSeries<PaymentData, String>>[
                  PieSeries<PaymentData, String>(
                      dataSource: paymentChartData,
                      xValueMapper: (PaymentData data, _) => data.paymentMethod,
                      yValueMapper: (PaymentData data, _) => data.amount,
                    dataLabelMapper: (PaymentData data, _) => CommonFunctions().formatter.format(data.amount),
                      dataLabelSettings: const DataLabelSettings(isVisible: true) ,
                    // Display values
                  )
                ]
            ),

           // buildTopCustomersList()


          ],
        ),
      );
  }


  List<TimeSeriesSales> _prepareGraphData() {
    // 1. Group purchases by day
    Map<DateTime, double> dailySales = {};
    Map<String, double> customerSpending = {};


    for (var sale in _sales) {

      DateTime dateKey = DateTime(sale.date.year, sale.date.month, sale.date.day);
      dailySales[dateKey] = (dailySales[dateKey] ?? 0) + _calculateSalesTotal(sale);
      // Here are the calculations for the top Customers
      customerSpending[sale.client] = (customerSpending[sale.client] ?? 0) + sale.totalFee;


      // End of calculations for top Customers
      if (sale.paidAmount > 0) { // Filter by paidAmount
        String method = sale.paymentMethod;
        salesByPaymentMethod[method] = (salesByPaymentMethod[method] ?? 0) + sale.paidAmount; // Use paidAmount
      }
      totalPaid += sale.paidAmount;
      totalUnpaid += sale.totalFee - sale.paidAmount;


      // top5Customers = sortedCustomers.take(10).toList();
    }

    // 2. Convert to TimeSeriesSales
    return dailySales.entries.map((entry) =>
        TimeSeriesSales(entry.key, entry.value)
    ).toList();
  }

  void _calculateTopCustomers() {
    Map<String, double> customerSpending = {};

    // Iterate through sales data
    for (final sale in _sales) {
      String customerName = sale.client; // Assuming 'client' holds customer name
      customerSpending[customerName] =
          (customerSpending[customerName] ?? 0) + sale.totalFee; // Accumulate spending
    }

    // Convert to list & Sort
    var sortedCustomers = customerSpending.entries.toList();
    sortedCustomers.sort((e1, e2) => e2.value.compareTo(e1.value));

    // Get top 5 (adjust as needed)
    topCustomers= sortedCustomers;
    List<MapEntry<String, double>> top5Customers = sortedCustomers.take(10).toList();
    Provider.of<StyleProvider>(context, listen: false).setBestCustomerResults(top5Customers);
  }

  void _calculateTopProducts() {
    Map<String, double> productSales = {}; // Product name -> Quantity sold

    for (final sale in _sales) {
      for (final item in sale.items) {
        String productName = item.product;
        productSales[productName] = (productSales[productName] ?? 0) + item.quantity;
      }
    }

    // Sort by quantities sold (descending)
    var sortedProducts = productSales.entries.toList();
    sortedProducts.sort((e1, e2) => e2.value.compareTo(e1.value));

    // Take the desired number of top products
    int numTopProducts = 5; // Adjust as needed
    List<MapEntry<String, double>> topProducts = sortedProducts.take(numTopProducts).toList();

    // Update a state variable in your widget
    Provider.of<StyleProvider>(context, listen: false).setBestProductsResults(topProducts);
  }

  List<TimeSeriesSales> _prepareCumulativeGraphData() {
    double cumulativeTotal = 0;
    Map<DateTime, double> cumulativeSales = {};
    for (var purchase in _sales) {
      DateTime dateKey = DateTime(purchase.date.year, purchase.date.month, purchase.date.day);
      cumulativeTotal += _calculateSalesTotal(purchase);
      cumulativeSales[dateKey] = cumulativeTotal;
    }
    // 2. Convert to TimeSeriesSales
    return cumulativeSales.entries.map((entry) =>
        TimeSeriesSales(entry.key, entry.value)
    ).toList();
  }

  // Helper to calculate total price of a single purchase
  double _calculateSalesTotal(Sales sale) {
    double total = 0;
    for (var item in sale.items) {
      total += item.price;
    }

    return total;
  }
}

class TimeSeriesSales {
  final DateTime time;
  final double sales;

  TimeSeriesSales(this.time, this.sales);
}

class PaymentData {
  final String paymentMethod;
  final double amount;

  PaymentData(this.paymentMethod, this.amount);
}