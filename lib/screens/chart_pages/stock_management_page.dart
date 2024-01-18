



import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stylestore/Utilities/constants/color_constants.dart';
import 'package:intl/intl.dart';
import 'package:stylestore/model/styleapp_data.dart';

import '../../Utilities/constants/font_constants.dart';
import '../../model/beautician_data.dart';
import 'line_chart_widget.dart';

class StockManagementPage extends StatefulWidget {
  static String id = "Stock_Management";

  @override
  State<StockManagementPage> createState() => _StockManagementPageState();
}

class _StockManagementPageState extends State<StockManagementPage> {


  Map<String, dynamic> splitStringWithLetterAndDoubleNumber(String input) {
    String letter = input.substring(0, 1);
    double number = double.parse(input.substring(1));

    return {'letter': letter, 'number': number};
  }

  List<String> formatDateTimeList(List<DateTime> dateTimeList) {
    return dateTimeList.map((dateTime) {
      return DateFormat('M/d h:mma').format(dateTime);
    }).toList();
  }

  // List<String> createScaleArray(List<double> inputArray) {
  //   // Step 1: Ensure the inputArray has at least 6 elements by adding 0s if needed
  //   // if (inputArray.length < 6) {
  //   //   int zerosToAdd = 6 - inputArray.length;
  //   //   inputArray.addAll(List<double>.filled(zerosToAdd, 0.0));
  //   // }
  //   print("inputArray: $inputArray");
  //
  //   // Step 2: Find the maximum value in the input array
  //   double maxValue = inputArray.reduce((value, element) => value > element ? value : element);
  //
  //   // Step 3: Calculate the target value (at least 40% higher than the maximum value)
  //   double targetValue = (maxValue * 1.4);
  //
  //   // Step 4: Determine the step size and round to the nearest tens
  //   double stepSize = (((targetValue / 5) ) ~/ 10) * 10.0;
  //
  //   // Step 5: Create the scale array with 6 elements, evenly spaced from 0 to the target value
  //   List<String> scale = List.generate(6, (index) => (index * stepSize).toStringAsFixed(0));
  //
  //   return scale;
  // }

  List<String> createScaleArray(List<double> inputArray) {
    // Step 1: Find the maximum value in the input array

    double maxValue = inputArray.reduce((value, element) => value > element ? value : element);

    // Step 2: Calculate the target value (at least 40% higher than the maximum value)
    double targetValue = (maxValue * 1.4);

    // Step 3: Determine the step size
    double stepSize = (targetValue / 4);

    // Step 4: Create the scale array with 5 elements, evenly spaced from 0 to the target value
   // List<String> scale = List.generate(5, (index) => (index * stepSize).toStringAsFixed(1));

    List <String> scale = ["5", "10" ,"15", "20", "25", "30"];

    return scale;
  }

  List<String> formatDateTimeList2(List<DateTime> dateTimeList) {
    if (dateTimeList.length >= 7) {
      return dateTimeList
          .map((dateTime) => DateFormat('dd/ha').format(dateTime))
          .toList();
    } else {
      List<String> formattedDates = [];
      DateTime lastDateTime = dateTimeList.last;

      for (int i = 0; i < 7; i++) {
        if (i < dateTimeList.length) {
          formattedDates.add(DateFormat('dd/ha').format(dateTimeList[i]));
        } else {
          lastDateTime = lastDateTime.add(Duration(hours: 24));
          formattedDates.add(DateFormat('dd/ha').format(lastDateTime));
        }
      }

      return formattedDates;
    }
  }

  void separateChartData(List<dynamic> chartData) {

    List<double> numbersArray = [];
    List<String> actionArray = [];
    List<DateTime> datesArray = [];

    for ( var data in chartData) {
      String newData = data.toString();
      List splitData = newData.split('?');
      print("POPOPOP: $splitData");
      print("POPOPOP: ${splitData.length}");

      if (splitData.length == 2) {
        Map<String, dynamic> result = splitStringWithLetterAndDoubleNumber(splitData[0]);
        print("Letter: ${result['letter']}");
        print("Double Number: ${result['number']}");
        double? number = result['number'];
        String? action = result['letter'];
        DateTime? date = DateTime.tryParse(splitData[1]);

        if (number != null && action != null) {
          numbersArray.add(number);
          actionArray.add(action);
        }

        if (date != null) {
          datesArray.add(date);
        }
      }
    }
    stockNumbers = numbersArray;
     stockDates = formatDateTimeList2(datesArray);
     stockAction = datesArray;
     scalesList = createScaleArray(stockNumbers);

    // Print the separated arrays

    print('Numbers Array: $numbersArray');
    print('Scales Array: $scalesList');
    print('Dates Array: ${stockDates[1]}');

  }
  List<double> createArrayForMinimumStockLine(double number) {
    List<double> array = List.filled(7, number);
    return array;
  }

  @override
  final CollectionReference dataCollection = FirebaseFirestore.instance.collection('stores');
  String uniqueIdentifier = "code for the product";
  List<double> stockNumbers = [];
  List <String> stockDates = [];
  List stockAction = [];

  List  minimumStockNumbers = [40,40, 40, 40, 40,40, 40];
  List<String>  scalesList = [];


  Widget build(BuildContext context) {
    return Scaffold(
       backgroundColor: kBeigeThemeColor, // Set background color to navy blue
      appBar: AppBar(
        backgroundColor: kBeigeThemeColor,
        elevation: 0,
        title: Text("${Provider.of<BeauticianData>(context, listen: false).item} Stock"),
        centerTitle: true,

      ),


      body: SafeArea(
          child:

          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [

                  // kLargeHeightSpacing,
                  // kLargeHeightSpacing,

                  FutureBuilder<QuerySnapshot>(
                    future: dataCollection.where('id', isEqualTo: Provider.of<StyleProvider>(context, listen: false).stockId).limit(7).get(),
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

                      List chartData = snapshot.data!.docs.map((doc) {
                        // pointsNumbers = doc["dailyTasks"];
                        minimumStockNumbers = createArrayForMinimumStockLine(doc['minimum'].toDouble()) ;


                        return doc['stockTaking'] ;
                      }).toList();

                      separateChartData(chartData[0]);


                      return Container(
                          height: 200,
                          child:
                          // Text(chartData[0].toString(), style: kNormalTextStyle.copyWith(color: kPureWhiteColor),)
                          LineChartWidget(
                            graphValues: List.generate(stockNumbers.length, (index) {
                              return

                                FlSpot(index.toDouble(), stockNumbers[index].toDouble());
                            },
                            ),
                            targetValues:
                            List.generate(minimumStockNumbers.length, (index) {
                              return

                                FlSpot(index.toDouble(), minimumStockNumbers[index].toDouble());
                            },
                            ),
                            targetDays: stockDates,
                            scale: scalesList,
                          )
                      );
                    },
                  ),
                  kLargeHeightSpacing,
                  ElevatedButton(
                      style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(kAppPinkColor)),
                      onPressed: (){}, child: Text("Create Report", style: kNormalTextStyle.copyWith(color: kPureWhiteColor),))

                ],
              ),
            ),
          )
      ),
    );
  }
}
