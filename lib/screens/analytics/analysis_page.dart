import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_circular_progress_bar/simple_circular_progress_bar.dart';
import 'package:stylestore/Utilities/constants/color_constants.dart';
import 'package:intl/intl.dart';
import 'package:stylestore/controllers/transactions_controller.dart';

import 'package:stylestore/model/analysis_data.dart';
import 'package:stylestore/model/best_customer.dart';
import 'package:stylestore/model/common_functions.dart';
import 'package:stylestore/screens/analytics/deeper_analytics/days_ranking.dart';
import 'package:stylestore/screens/analytics/deeper_analytics/product_ranking.dart';
import 'package:stylestore/screens/analytics/report_ai_page.dart';
import 'package:stylestore/screens/chart_pages/line_chart_widget.dart';
import 'package:stylestore/screens/analytics/deeper_analytics/customer_ranking.dart';
import 'package:stylestore/screens/transactions_pages/new_transactions_page.dart';
import 'package:stylestore/widgets/locked_widget.dart';
import '../../../Utilities/constants/font_constants.dart';
import '../../model/product_items_model.dart';
import '../../utilities/constants/user_constants.dart';
import '../chart_pages/bar_chart_widget.dart';
import '../expenses_pages/expenses.dart';
import 'intro_to_analysis.dart';
import 'loading_analysis_page.dart';


class AnalysisPage extends StatefulWidget {
  static String id = "Analysis_Management";

  @override
  State<AnalysisPage> createState() => _AnalysisPageState();
}

class _AnalysisPageState extends State<AnalysisPage> {



  List<String> formatDateTimeList(List<DateTime> dateTimeList) {
    return dateTimeList.map((dateTime) {
      return DateFormat('M/d h:mma').format(dateTime);
    }).toList();
  }



  List<double> moneyValueOfArray = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0];

  List<double> weekMoneyValueOfArray = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0];
  List<int> timesValue = [0, 0, 0, 0, 0, 0, 0];
  String mostOrderedProductName = "";
  List<BestCustomer> bestClients = [];
  List<ProductItems> bestProducts = [];
  Map<String, dynamic> mostOrderedProduct = {'name': '', 'quantity': 0.0, 'total': 0.0};
  Map<String, dynamic> bestCustomer = {'name': '', 'quantity': 0.0, 'total': 0.0};
  final HttpsCallable callableCreateStoreAnalysis = FirebaseFunctions.instance.httpsCallable('createStoreAnalysis');


  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
  bool isSameMonth(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month;
    // &&
        // date1.day == date2.day;
  }
  bool isSameWeek(DateTime date1, DateTime date2) {
    if (date1.year == date2.year) {
      int dayOfYear1 = date1.difference(DateTime(date1.year, 1, 1)).inDays;
      int dayOfYear2 = date2.difference(DateTime(date2.year, 1, 1)).inDays;

      int weekNumber1 = (dayOfYear1 / 7).ceil();
      int weekNumber2 = (dayOfYear2 / 7).ceil();

      return weekNumber1 == weekNumber2;
    }

    return false;
  }







  List<String> createScaleArray(List<double> inputArray) {
    // Step 1: Find the maximum value in the input array
    if (inputArray.isEmpty){
      return [
        "0.0",
        "0.0",
        "0.0",
        "0.0",
        "0.0",
        "0.0",
        "0.0",
        "0.0",
      ];

    }

    double maxValue = inputArray.reduce((value, element) => value > element ? value : element);

    // Step 2: Calculate the target value (at least 40% higher than the maximum value)
    double targetValue = (maxValue * 1.4);

    // Step 3: Determine the step size
    double stepSize = (targetValue / 4);

    // Step 4: Create the scale array with 5 elements, evenly spaced from 0 to the target value
    List<String> scale = List.generate(6, (index) => (index * stepSize).toStringAsFixed(1));

    // List <String> scale = ["5", "10" ,"15", "20", "25", "30"];

    return scale;
  }

  List<String> formatDateTimeList2(List<DateTime> dateTimeList) {
    if (dateTimeList.length >= 7) {
      return dateTimeList
          .map((dateTime) => DateFormat('ha').format(dateTime))
          .toList();
    } else {
      List<String> formattedDates = [];
      DateTime lastDateTime = dateTimeList.last;

      for (int i = 0; i < 7; i++) {
        if (i < dateTimeList.length) {
          formattedDates.add(DateFormat('ha').format(dateTimeList[i]));
        } else {
          lastDateTime = lastDateTime.add(Duration(hours: 24));
          formattedDates.add(DateFormat('ha').format(lastDateTime));
        }
      }

      return formattedDates;
    }
  }

  void incrementMoneyForEachDay(DateTime dateTime, double amount) {
    int dayOfWeek = dateTime.weekday;
    int hour = dateTime.hour;

    if (hour >= 6 && hour < 8) {
      timesValue[0] += 1;
    } else if (hour >= 9 && hour < 12) {
      timesValue[1] += 1;
    } else if (hour >= 13 && hour < 15) {
      timesValue[2] += 1;
    } else if (hour >= 16 && hour < 18) {
      timesValue[3] += 1;
    } else if (hour >= 19 && hour <= 23) {
      timesValue[4] += 1;
    } else if (hour >= 0 && hour < 3) {
      timesValue[5] += 1;
    } else if (hour >= 3 && hour < 5) {
      timesValue[6] += 1;
    }

    // Increment the corresponding array element based on the day of the week
    switch (dayOfWeek) {
      case DateTime.monday:
        moneyValueOfArray[0] += amount;
        break;
      case DateTime.tuesday:
        moneyValueOfArray[1] += amount;
        break;
      case DateTime.wednesday:
        moneyValueOfArray[2] += amount;
        break;
      case DateTime.thursday:
        moneyValueOfArray[3] += amount;
        break;
      case DateTime.friday:
        moneyValueOfArray[4] += amount;
        break;
      case DateTime.saturday:
        moneyValueOfArray[5] += amount;
        break;
      case DateTime.sunday:
        moneyValueOfArray[6] += amount;
        break;
    }

  }

  void incrementMoneyForEachDayOfWeek(DateTime dateTime, double amount) {
    int dayOfWeek = dateTime.weekday;
    int hour = dateTime.hour;

    if (hour >= 6 && hour < 8) {
      timesValue[0] += 1;
    } else if (hour >= 9 && hour < 12) {
      timesValue[1] += 1;
    } else if (hour >= 13 && hour < 15) {
      timesValue[2] += 1;
    } else if (hour >= 16 && hour < 18) {
      timesValue[3] += 1;
    } else if (hour >= 19 && hour <= 23) {
      timesValue[4] += 1;
    } else if (hour >= 0 && hour < 3) {
      timesValue[5] += 1;
    } else if (hour >= 3 && hour < 5) {
      timesValue[6] += 1;
    }

    // Increment the corresponding array element based on the day of the week
    switch (dayOfWeek) {
      case DateTime.monday:
        weekMoneyValueOfArray[0] += amount;
        break;
      case DateTime.tuesday:
        weekMoneyValueOfArray[1] += amount;
        break;
      case DateTime.wednesday:
        weekMoneyValueOfArray[2] += amount;
        break;
      case DateTime.thursday:
        weekMoneyValueOfArray[3] += amount;
        break;
      case DateTime.friday:
        weekMoneyValueOfArray[4] += amount;
        break;
      case DateTime.saturday:
        weekMoneyValueOfArray[5] += amount;
        break;
      case DateTime.sunday:
        weekMoneyValueOfArray[6] += amount;
        break;
    }

  }
  String createReportJson() {
    // Create a list to hold the JSON objects for each element in transactionData
    List<Map<String, dynamic>> jsonDataList = [];

    for (var data in transactionData) {

      print(data.purchase);
      Map<String, dynamic> jsonData = {
        'items':data.purchase,
        'date': data.date,
        'total': data.total,
        'client': data.client,
      };

      jsonDataList.add(jsonData);
    }

    // Convert the list of JSON objects to a JSON string
    String jsonString = jsonEncode(jsonDataList);

    // Print the JSON string (for demonstration purposes)
    print(jsonString+ "Done");

    return jsonString ;

    // You can now save the JSON string to a file or send it to a server as required.
    // For example, you could save it to a file using the 'path_provider' package.
  }

  String createMonthReportJson() {
    // Create a list to hold the JSON objects for each element in transactionData
    List<Map<String, dynamic>> jsonDataList = [];

    for (var data in transactionMonthData) {

      print(data.purchase);
      Map<String, dynamic> jsonData = {
        'items':data.purchase,
        'date': data.date,
        'total': data.total,
        'client': data.client,
      };

      jsonDataList.add(jsonData);
    }

    // Convert the list of JSON objects to a JSON string
    String jsonString = jsonEncode(jsonDataList);

    // Print the JSON string (for demonstration purposes)
    print(jsonString+ "Done");

    return jsonString ;

    // You can now save the JSON string to a file or send it to a server as required.
    // For example, you could save it to a file using the 'path_provider' package.
  }



  void updateMostOrderedProduct(List<ProductItems> orders) {
    if (orders.isEmpty) {
      setState(() {
        // mostOrderedProduct = {};
        mostOrderedProduct = {
          'name': "No Info",
          'quantity': 0.0,
          'cumulativeValue': 0.0,
        };
      });
      return;
    }

    Map<String, double> quantityMap = {};

    // Calculate the cumulative quantity for each product
    for (var order in orders) {
      String productName = order.name;
      double quantity = order.quantity ?? 0; // Provide a default value of 0 if quantity is null

      quantityMap[productName] = (quantityMap[productName] ?? 0) + quantity;
    }

    // Find the most ordered product
    String mostOrderedProductName = "";
    double maxQuantity = 0;

    quantityMap.forEach((productName, quantity) {
      if (quantity > maxQuantity) {
        mostOrderedProductName = productName;
        maxQuantity = quantity;
      }
    });

    // Calculate the cumulative value of the most ordered product
    double cumulativeValue = 0;
    for (var order in orders) {
      if (order.name == mostOrderedProductName) {
        double quantity = order.quantity?.toDouble() ?? 0.0; // Provide a default value of 0.0 if quantity is null
        double price = order.total?.toDouble() ?? 0.0; // Provide a default value of 0.0 if price is null

        cumulativeValue += quantity * price;
      }
    }


      mostOrderedProduct = {
        'name': mostOrderedProductName,
        'quantity': maxQuantity,
        'cumulativeValue': cumulativeValue,
      };

  }

  List<ProductItems> findBestProducts(List<ProductItems> orders) {
    if (orders.isEmpty) {
      return [];
    }

    Map<String, double> cumulativePayments = {};

    // Calculate the cumulative value paid by each client
    for (var order in orders) {
      String clientName = order.name;
      double totalPaid = order.total;
      double quantity = order.quantity;

      double cumulativeValue = totalPaid;

      cumulativePayments[clientName] = (cumulativePayments[clientName] ?? 0) + cumulativeValue;
    }

    // Create a list of Customer objects from the cumulativePayments map
    List<ProductItems> products = cumulativePayments.entries.map((entry) {
      return ProductItems(entry.key, entry.value, 0.0); // Set quantity as needed
    }).toList();

    // Sort the list of customers based on cumulative payment in descending order
    products.sort((a, b) => b.total.compareTo(a.total));

    return products;
  }

  void findBestClient(List<BestCustomer> orders) {
    if (orders.isEmpty) {
      return ;
    }

    Map<String, double> cumulativePayments = {};

    // Calculate the cumulative value paid by each client
    for (var order in orders) {
      String clientName = order.name;
      double totalPaid = order.totalPaid;
      double quantity = order.quantity;

      double cumulativeValue = totalPaid;

      cumulativePayments[clientName] = (cumulativePayments[clientName] ?? 0) + cumulativeValue;
    }

    // Find the client with the highest cumulative value
    String bestClientName = '';
    double maxCumulativeValue = 0;

    cumulativePayments.forEach((clientName, cumulativeValue) {
      if (cumulativeValue > maxCumulativeValue) {
        bestClientName = clientName;
        maxCumulativeValue = cumulativeValue;
      }
    });

  bestCustomer = {'name': bestClientName, 'quantity': 0.0, 'total': maxCumulativeValue};
  }

  List<BestCustomer> findBestClients(List<BestCustomer> orders) {
    if (orders.isEmpty) {
      return [];
    }

    Map<String, double> cumulativePayments = {};

    // Calculate the cumulative value paid by each client
    for (var order in orders) {
      String clientName = order.name;
      double totalPaid = order.totalPaid;
      double quantity = order.quantity;

      double cumulativeValue = totalPaid;

      cumulativePayments[clientName] = (cumulativePayments[clientName] ?? 0) + cumulativeValue;
    }

    // Create a list of Customer objects from the cumulativePayments map
    List<BestCustomer> customers = cumulativePayments.entries.map((entry) {
      return BestCustomer(entry.key, entry.value, 0.0); // Set quantity as needed
    }).toList();

    // Sort the list of customers based on cumulative payment in descending order
    customers.sort((a, b) => b.totalPaid.compareTo(a.totalPaid));

    return customers;
  }




  @override
  final CollectionReference appointmentsCollection = FirebaseFirestore.instance.collection('appointments');
  final CollectionReference dataCollection = FirebaseFirestore.instance.collection('purchases');
  String uniqueIdentifier = "code for the product";
  String storeName = "storeName";
  String storeId = "storeId";
  List<double> stockNumbers = [];
  List<double> salesNumbers = [];
  double totalSalesToday = 0.0;
  double totalExpenseToday = 0.0;
  List<AnalysisData>  transactionData = [];
  List<AnalysisData>  transactionMonthData = [];
  List<AnalysisData>  transactionWeekData = [];
  List<ProductItems>  originalProductsData = [];
  List<BestCustomer>  originalCustomerData = [];
  List <String> stockDates = [];
  List <String> salesDates = [];
  List stockAction = [];
  bool analysisMode = false;

  List  minimumStockNumbers = [100,100, 100, 100, 100,100, 100];
  List<String>  scalesList = [];
  List<String>  timestampScalesList = ["6- 8am","9- 12pm",'1- 3pm','4- 6pm','7- 11pm','00- 3am','3- 5am' ];
  List<String>  salesScalesList = [];
  Map<String, dynamic> permissionsMap = {};

  void defaultsInitiation()async{

    final prefs = await SharedPreferences.getInstance();
    permissionsMap = await CommonFunctions().convertPermissionsJson();
    storeName = prefs.getString(kBusinessNameConstant)!;
    storeId = prefs.getString(kStoreIdConstant)!;
    bool newUser = prefs.getBool(kStartAnayltics) ?? false;
    analysisMode =  prefs.getBool(kAnalysisMode) ?? false;
    print(prefs.getBool(kStartAnayltics));
    if(newUser == false) {
      Navigator.push(context, MaterialPageRoute(builder: (context)=> AnalysisIntroPage()));
    }

    setState(() {

    });

  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    defaultsInitiation();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBlack, // Set background color to navy blue
      appBar: AppBar(
        backgroundColor: kBlack,
        foregroundColor: kPureWhiteColor,
        elevation: 0,
        title: Text("$storeName Analysis", style: kNormalTextStyle.copyWith(color: kPureWhiteColor),),
        centerTitle: true,
        // automaticallyImplyLeading:  totalSalesToday == 0.0 ? false: true,
        leading: analysisMode == true ? GestureDetector(
            onTap: ()async{
              final prefs = await SharedPreferences.getInstance();
              prefs.setBool(kAnalysisMode, false);
              Navigator.pop(context);
            },
            child: Icon(Icons.arrow_back)): Container(),

      ),


      body: SafeArea(
          child:

          WillPopScope(
            onWillPop: () async {
              return false; // return a `Future` with false value so this route cant be popped or closed.
            },
            child: permissionsMap['analytics'] == false ?LockedWidget(page: "Analytics"):SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,

                  children: [





                    FutureBuilder<QuerySnapshot>(
                      future: appointmentsCollection.where('sender_id', isEqualTo: storeId)//.limit(7)
                          .get(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return const Center(
                            child: Text('Error fetching data'),
                          );
                        }

                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(

                            ),
                          );
                        }
                        if(!snapshot.hasData){
                          return Container();
                        }else{
                          salesNumbers = [];

                          var sales = snapshot.data?.docs;
                          for( var doc in sales!){

                            List<double> prices = [];
                            List<String> purchases = [];
                            List<String> lastMonthPurchases = [];
                            List<String> lastWeekPurchases = [];

                            List dynamicList = doc['items'];


                            for (var i = 0; i < doc['items'].length; ++i){


                              // print("${dynamicList[i]['product']}");

                              prices.add(dynamicList[i]['totalPrice']/1.0) ;
                              purchases.add(dynamicList[i]['product']) ;
                              originalProductsData.add(ProductItems(dynamicList[i]['product'], dynamicList[i]['totalPrice']/1.0, dynamicList[i]['quantity']/1.0));
                              if (isSameMonth(doc['appointmentDate'].toDate(), DateTime.now())){
                                lastMonthPurchases.add(dynamicList[i]['product']);
                              }
                            }
                            // listOProducts.add(array);
                            originalCustomerData.add(BestCustomer(doc['client'], doc['totalFee']/1.0, doc['items'].length /1.0));
                            salesNumbers.add(CommonFunctions().sumArrayElements(prices));
                            transactionData.add(AnalysisData(purchases.join(", "), DateFormat('EEEE, d MMMM, yyyy, hh:mm a').format(doc['appointmentDate'].toDate()) , CommonFunctions().sumArrayElements(prices).toString(), doc['client']));

                           // originalData.add(AnalysisData(doc["items"], DateFormat('EEEE, MMMM, yyyy, hh:mm a').format(doc['appointmentDate'].toDate()) , CommonFunctions().sumArrayElements(prices).toString(), doc['client']));
                            incrementMoneyForEachDay(doc['appointmentDate'].toDate(), CommonFunctions().sumArrayElements(prices));
                            if (isSameDay(doc['appointmentDate'].toDate(), DateTime.now())){
                              totalSalesToday += doc['totalFee'];
                            }
                            if (isSameWeek(doc['appointmentDate'].toDate(), DateTime.now())){
                              incrementMoneyForEachDayOfWeek(doc['appointmentDate'].toDate(), CommonFunctions().sumArrayElements(prices));
                              transactionWeekData.add(AnalysisData(lastWeekPurchases.join(", "), DateFormat('EEEE, d MMMM, yyyy, hh:mm a').format(doc['appointmentDate'].toDate()) , CommonFunctions().sumArrayElements(prices).toString(), doc['client']));
                            }
                            if (isSameMonth(doc['appointmentDate'].toDate(), DateTime.now())){
                              transactionMonthData.add(AnalysisData(lastMonthPurchases.join(", "), DateFormat('EEEE, d MMMM, yyyy, hh:mm a').format(doc['appointmentDate'].toDate()) , CommonFunctions().sumArrayElements(prices).toString(), doc['client']));
                            }


                          }
                        }
                        findBestClient(originalCustomerData);
                        bestClients = findBestClients(originalCustomerData);
                        bestProducts = findBestProducts(originalProductsData);
                        if(originalProductsData.isNotEmpty){
                          updateMostOrderedProduct(originalProductsData);
                        }

                        return
                          Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  topIcons(Iconsax.cup, bestCustomer['name'], "Best Customer", "is the best Customer for the period set", "See Customer Ranking", (){
                                    // for (var customer in bestClients) {
                                    //   print('${customer.name}: ${customer.totalPaid}');
                                    // }
                                    Navigator.pop(context);
                                    showModalBottomSheet(
                                        isScrollControlled: true,
                                        context: context,
                                        builder: (context) {
                                          return Scaffold(

                                              appBar: AppBar(
                                                backgroundColor: kBlack,
                                                automaticallyImplyLeading: false,
                                                elevation: 0,
                                              ),
                                              body:
                                              BestCustomersPage(bestCustomers: bestClients)
                                          );
                                        });
                                  },),
                                  topIcons(Iconsax.box, mostOrderedProduct['name'], "Best Performing Product", "is the best product with ${mostOrderedProduct['quantity'].toInt()} units being sold.", "See Products Ranking", (){
                                    // for (var customer in bestClients) {
                                    //   print('${customer.name}: ${customer.totalPaid}');
                                    // }
                                    Navigator.pop(context);
                                    showModalBottomSheet(
                                        isScrollControlled: true,
                                        context: context,
                                        builder: (context) {
                                          return Scaffold(

                                              appBar: AppBar(
                                                backgroundColor: kBlack,
                                                automaticallyImplyLeading: false,
                                                elevation: 0,
                                              ),
                                              body:
                                              BestProductPage(bestProducts: bestProducts)
                                          );
                                        });
                                  },),
                                  topIcons(Iconsax.calendar,  CommonFunctions().getDayFromIndex(CommonFunctions().findIndexOfHighestValue(moneyValueOfArray)), "Best Day", "is the most productive day. With sales worth Ugx ${CommonFunctions().formatter.format(moneyValueOfArray[CommonFunctions().findIndexOfHighestValue(moneyValueOfArray)])}", "Days Ranking", (){
                                    // for (var customer in bestClients) {
                                    //   print('${customer.name}: ${customer.totalPaid}');
                                    // }
                                    List<int> orderedIndices = CommonFunctions().orderDaysByDescendingValue(moneyValueOfArray);
                                    List<String> daysCorrespondingToIndices = orderedIndices.map((index) => CommonFunctions().getDayFromIndex(index)).toList();

                                    Navigator.pop(context);
                                    showModalBottomSheet(
                                        isScrollControlled: true,
                                        context: context,
                                        builder: (context) {
                                          return Scaffold(

                                              appBar: AppBar(
                                                backgroundColor: kBlack,
                                                automaticallyImplyLeading: false,
                                                elevation: 0,
                                              ),
                                              body:
                                              BestDaysPage(bestDays: daysCorrespondingToIndices, amounts: moneyValueOfArray,)
                                          );
                                        });
                                  },),
                                ],),
                              kLargeHeightSpacing,
                              kLargeHeightSpacing,
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Column(
                                    children: [
                                      Text("Today's Sales", style: kNormalTextStyle.copyWith(color: kPureWhiteColor, fontSize: 16),),
                                      kLargeHeightSpacing,
                                      GestureDetector(
                                        onTap: (){
                                          Navigator.pushNamed(context, TransactionsController.id);
                                        },
                                        child: Stack(
                                          children: [
                                            SimpleCircularProgressBar(
                                              backColor: kBlueDarkColor,
                                              maxValue: 1000000,
                                              size: 100,
                                              progressColors: [kCustomColor, kAppPinkColor ],
                                              progressStrokeWidth: 10,
                                              backStrokeWidth: 20,
                                              // valueNotifier: ValueNotifier(Provider.of<AiProvider>(context, listen: false).progressPoints * 1.0),
                                              valueNotifier: ValueNotifier(totalSalesToday),
                                            ),
                                            Positioned(
                                                left: 35,
                                                bottom: 40,
                                                child: Text("${CommonFunctions().formatter.format(totalSalesToday)}\nUGX",textAlign: TextAlign.center, style: kNormalTextStyle.copyWith(color: kPureWhiteColor, fontSize: 11),))
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  kMediumWidthSpacing,
                                  kMediumWidthSpacing,
                                  kMediumWidthSpacing,
                                  Column(
                                    children: [
                                      Text("Today's Expenses", style: kNormalTextStyle.copyWith(color: kPureWhiteColor, fontSize: 16),),
                                      kLargeHeightSpacing,
                                      FutureBuilder<QuerySnapshot>(
                                        future: dataCollection.where("storeId", isEqualTo: storeId ).get(),
                                        builder: (context, snapshot) {
                                          if (snapshot.hasError) {
                                            return const Center(
                                              child: Text('Error fetching data'),
                                            );
                                          }

                                          if (snapshot.connectionState == ConnectionState.waiting) {
                                            return const Center(
                                              child: CircularProgressIndicator(

                                              ),
                                            );
                                          }
                                          var orders = snapshot.data?.docs;
                                          for( var doc in orders!){

                                            List<double> prices = [];
                                            if (doc['activity']== 'Restocked'||doc['activity'] == 'Expense') {
                                              if( isSameDay(doc['date'].toDate(),DateTime.now())){
                                                for (var i = 0; i < doc['items'].length; ++i){


                                                  // print("${dynamicList[i]['product']}");

                                                  prices.add(doc['items'][i]['totalPrice']) ;

                                                }

                                                totalExpenseToday += CommonFunctions().sumArrayElements(prices);

                                              }
                                            }


                                          }




                                          return GestureDetector(
                                            onTap: (){
                                              Navigator.pushNamed(context, ExpensesPage.id);
                                            },
                                            child: Stack(
                                              children: [
                                                SimpleCircularProgressBar(
                                                  backColor: kBlueDarkColor,
                                                  maxValue: 1000000,
                                                  size: 100,
                                                  progressColors: [ kAppPinkColor, kCustomColor, ],
                                                  progressStrokeWidth: 10,
                                                  backStrokeWidth: 20,
                                                  // valueNotifier: ValueNotifier(Provider.of<AiProvider>(context, listen: false).progressPoints * 1.0),
                                                  valueNotifier: ValueNotifier(totalExpenseToday),
                                                ),
                                                Positioned(
                                                    left: 35,
                                                    bottom: 40,
                                                    child: Text("${CommonFunctions().formatter.format(totalExpenseToday)}\nUGX",textAlign: TextAlign.center, style: kNormalTextStyle.copyWith(color: kPureWhiteColor, fontSize: 11),))
                                              ],
                                            ),
                                          );

                                        },
                                      ),

                                    ],
                                  ),
                                ],
                              ),

                              kLargeHeightSpacing,
                              Card(
                                elevation: 1,
                                color: kCustomColor,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      ListTile(
                                        title: Text("Cash", style: kNormalTextStyle.copyWith(color: kBlack, fontSize: 14),),
                                        trailing: Text("Ugx 90,000", style: kNormalTextStyle.copyWith(color: kBlack, fontSize: 14),
                                        ),),
                                      ListTile(
                                        title: Text("Mobile Money", style: kNormalTextStyle.copyWith(color: kBlack, fontSize: 14),),
                                        trailing: Text("Ugx 90,000", style: kNormalTextStyle.copyWith(color: kBlack, fontSize: 14),
                                        ),),
                                      ListTile(
                                        title: Text("Credit", style: kNormalTextStyle.copyWith(color: kBlack, fontSize: 14),),
                                        trailing: Text("Ugx 90,000", style: kNormalTextStyle.copyWith(color: kBlack, fontSize: 14),
                                        ),),

                                    ],
                                  ),
                                ),
                              ),

                              kLargeHeightSpacing,
                              SizedBox(
                                  height: 200,
                                  child:
                                  // Text(chartData[0].toString(), style: kNormalTextStyle.copyWith(color: kPureWhiteColor),)
                                  BarChartWidget(
                                    graphValues: weekMoneyValueOfArray,
                                    targetValues:
                                    List.generate(minimumStockNumbers.length, (index) {
                                      return

                                        FlSpot(index.toDouble(), minimumStockNumbers[index].toDouble());
                                    },
                                    ),
                                    targetDays: stockDates,
                                    scale:  createScaleArray(salesNumbers), title: 'Sales for this Week',
                                  )
                              ),
                              kLargeHeightSpacing,
                              kLargeHeightSpacing,
                              SizedBox(
                                  height: 200,
                                  child:
                                  // Text(chartData[0].toString(), style: kNormalTextStyle.copyWith(color: kPureWhiteColor),)
                                  BarChartWidget(
                                    graphValues: moneyValueOfArray,
                                    targetValues:
                                    List.generate(minimumStockNumbers.length, (index) {
                                      return

                                        FlSpot(index.toDouble(), minimumStockNumbers[index].toDouble());
                                    },
                                    ),
                                    targetDays: stockDates,
                                    scale: createScaleArray(salesNumbers), title: 'Overall Sales By Day',
                                  )
                              ),
                              kLargeHeightSpacing,
                              kLargeHeightSpacing,
                              SizedBox(
                                  height: 100,
                                  child:
                                  // Text(chartData[0].toString(), style: kNormalTextStyle.copyWith(color: kPureWhiteColor),)
                                  LineChartWidget(
                                    graphValues: List.generate(timesValue.length, (index) {
                                      return

                                        FlSpot(index.toDouble(), timesValue[index].toDouble());
                                    },
                                    ),
                                    targetValues:
                                    List.generate(minimumStockNumbers.length, (index) {
                                      return

                                        FlSpot(index.toDouble(), minimumStockNumbers[index].toDouble());
                                    },
                                    ),
                                    targetDays: timestampScalesList,
                                    scale: timestampScalesList,
                                  )
                              )

                            ],
                          );
                      },
                    ),
                    kLargeHeightSpacing,

                    kLargeHeightSpacing,
                    ElevatedButton(
                        style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(kAppPinkColor)),
                        onPressed: () async{
                       //   Share.share(createReportJson(), subject: 'Check this out from Kola');
                         // Share.share(createMonthReportJson(), subject: 'Check this out from Kola');
                          try {
                            dynamic serverCallableVariable = await callableCreateStoreAnalysis.call(<String, dynamic>{
                              'business': storeName,
                              'storeId': storeId,
                              'info': createMonthReportJson(),
                            }).whenComplete(() =>  Navigator.push(context,
                                MaterialPageRoute(builder: (context)=> LoadingAnalysisPage())
                            ));
                            // Handle the serverCallableVariable if the request is successful
                            // For example, you can print the response or use it as needed.
                          } catch (error) {
                            print('Error message: ${error.toString()}');
                            // Handle the error here or propagate it further if needed.
                          }

                        }, child: Text("Create Report", style: kNormalTextStyle.copyWith(color: kPureWhiteColor),))

                  ],
                ),
              ),
            ),
          )
      ),
    );
  }

  Padding topIcons(IconData icon, String data, String heading, String body, String rankingTitle, void Function() onTap) {
    return Padding(
      padding: const EdgeInsets.only(left: 15.0, right: 15),
      child: Column(
        children: [
          GestureDetector(
            onTap:
                (){

              showDialog(context: context, builder: (BuildContext context){
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,


                  children: [
                    GestureDetector(
                      onTap: onTap,
                      child: Container(
                        decoration: BoxDecoration(
                          color: kCustomColor,
                            borderRadius: BorderRadius.all(Radius.circular(10))),
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Text(rankingTitle, style: kNormalTextStyle.copyWith(color: kBlack, fontSize: 15),),
                        ),
                      ),
                    ),
                    CupertinoAlertDialog(
                      title:Text(heading),
                      content: Text("$data $body"),
                      actions: [
                        CupertinoDialogAction(isDestructiveAction: true,
                            onPressed: (){
                              // _btnController.reset();
                              Navigator.pop(context);

                              // Navigator.pushNamed(context, SuccessPageHiFive.id);
                            },

                            child: const Text('Cancel')
                        ),
                      ],
                    ),
                  ],
                );
              });

            },
            child: Container(

              width: 60 ,
              height: 60,
              decoration: BoxDecoration(
                  shape: BoxShape.circle ,
                  gradient:  LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [kBlueDarkColor,kAppPinkColor] ),
                  border: Border.all(
                      color: kAppPinkColor,
                      width: 2
                  )
              ),
              child: Padding(
                padding: const EdgeInsets.all(3.0),
                child: Container(
                  width: 65,
                  height:  65,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 30,color: kPureWhiteColor,),

                ),
              ),
            ),
          ),
          Text(data, style: kNormalTextStyle.copyWith(color: kPureWhiteColor, fontSize: 12),)
        ],
      ),
    );
  }
}
