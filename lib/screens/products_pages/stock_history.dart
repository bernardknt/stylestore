import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:stylestore/model/common_functions.dart';

import '../../Utilities/constants/color_constants.dart';
import '../../Utilities/constants/font_constants.dart';
import '../../model/styleapp_data.dart';
// Import your StyleProvider

class StockHistoryPage extends StatefulWidget {
  static String id = 'stock_history';

  @override
  _StockHistoryPageState createState() => _StockHistoryPageState();
}

class _StockHistoryPageState extends State<StockHistoryPage> {
  DateTime? _previousDate;
  var productList = [];
  var activityList = [];
  var dateList = [];
  var createdByList = [];
  var currencyList = [];
  var listOProducts = [];
  var filteredProductList = [];
  var filteredActivityList = [];
  var filteredDateList = [];
  var filteredCreatedByList = [];
  var filteredCurrencyList = [];
  var filteredListOProducts = [];
  String selectedActivity = 'All';

  @override
  Widget build(BuildContext context) {
    var styleData = Provider.of<StyleProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: kPureWhiteColor,
      appBar: AppBar(
        title: Text(
          "Stock Timeline",
          style: kNormalTextStyle.copyWith(fontWeight: FontWeight.bold, color: kBlack),
        ),
        backgroundColor: kPureWhiteColor,
        elevation: 0,
        centerTitle: true,
      ),
      body:
      Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<String>(
              value: selectedActivity,
              items: ['All', 'Restocked', 'Updated', 'Sold'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  selectedActivity = newValue!;
                  _filterActivityList();
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('purchases')
                  .where('storeId', isEqualTo: styleData.beauticianId)
                  .orderBy('date', descending: true)
                  .limit(40)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData) {
                  return Container();
                } else {
                  _populateLists(snapshot.data?.docs);

                  return ListView.builder(
                    itemCount: filteredProductList.length,
                    itemBuilder: (context, index) {
                      var transactionDate = DateTime(
                        filteredDateList[index].year,
                        filteredDateList[index].month,
                        filteredDateList[index].day,
                      );
                      var showDateSeparator = false;
                      var dateSeparator = '';

                      if (transactionDate.difference(DateTime.now()).inDays == 0) {
                        dateSeparator = 'Today';
                      } else if (transactionDate.difference(DateTime.now()).inDays == -1) {
                        dateSeparator = 'Yesterday';
                      } else {
                        dateSeparator = '${transactionDate.day}/${transactionDate.month}/${transactionDate.year}';
                      }

                      if (_previousDate == null || transactionDate != _previousDate) {
                        showDateSeparator = true;
                        _previousDate = transactionDate;
                      }

                      Color circleColor;
                      IconData circleIcon;
                      switch (filteredActivityList[index]) {
                        case 'Updated':
                          circleColor = Colors.blue;
                          circleIcon = Icons.update;
                          break;
                        case 'Sold':
                          circleColor = Colors.green;
                          circleIcon = Iconsax.card_pos;
                          break;
                        case 'Restocked':
                          circleColor = kAppPinkColor;
                          circleIcon = Iconsax.box;
                          break;
                        default:
                          circleColor = Colors.grey;
                          circleIcon = Icons.help;
                          break;
                      }

                      return Column(
                        children: [
                          if (showDateSeparator) ...[
                            SizedBox(height: 10),
                            Text(
                              dateSeparator,
                              style: kNormalTextStyle.copyWith(color: kFontGreyColor, fontSize: 13),
                            ),
                            SizedBox(height: 10),
                          ],
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 40, // Adjust the width to move the timeline off the edge
                                child: Column(
                                  children: [
                                    if (index != 0) // Don't draw the top line for the first item
                                      Container(
                                        width: 2,
                                        height: 25,
                                        color: Colors.grey,
                                      ),
                                    Container(
                                      width: 20,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: circleColor,
                                      ),
                                      child: Icon(
                                        circleIcon,
                                        color: Colors.white,
                                        size: 12,
                                      ),
                                    ),
                                    if (index != filteredProductList.length - 1) // Don't draw the bottom line for the last item
                                      Container(
                                        width: 2,
                                        height: 25,
                                        color: Colors.grey,
                                      ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    _showDetailsModal(
                                      context,
                                      filteredActivityList[index],
                                      filteredProductList[index],
                                      filteredCreatedByList[index],
                                      filteredDateList[index],
                                      filteredCurrencyList[index],
                                    );
                                  },
                                  child: Card(
                                    margin: const EdgeInsets.fromLTRB(0, 8.0, 25.0, 8.0),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    shadowColor: kAppPinkColor,
                                    elevation: 0.0,
                                    child: Column(
                                      children: [
                                        ListTile(
                                          title: Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "${filteredProductList[index].length} Items ${filteredActivityList[index]}",
                                                    overflow: TextOverflow.clip,
                                                    style: TextStyle(
                                                      fontFamily: 'Montserrat-Medium',
                                                      fontSize: 14.0,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                  Container(
                                                    width: 200,
                                                    child: Text(
                                                      "${listOProducts[index].join(", ")}",
                                                      overflow: TextOverflow.fade,
                                                      style: TextStyle(fontFamily: 'Montserrat-Medium', fontSize: 14.0),
                                                    ),
                                                  ),
                                                  Text(
                                                    "Recorded by: ${filteredCreatedByList[index]}",
                                                    style: kNormalTextStyle.copyWith(fontSize: 12),
                                                  ),
                                                  Text(
                                                    '${DateFormat('d/MMM kk:mm a').format(filteredDateList[index])}',
                                                    style: kNormalTextStyle.copyWith(fontSize: 11),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          trailing: Text(
                                            "${filteredActivityList[index]}",
                                            overflow: TextOverflow.clip,
                                            style: TextStyle(
                                              fontFamily: 'Montserrat-Medium',
                                              fontSize: 14,
                                              color: kGreenThemeColor,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  );
                }
              },
            ),
          )
        ],
      ),
    );
  }

  void _populateLists(List<DocumentSnapshot>? docs) {
    productList = [];
    activityList = [];
    dateList = [];
    createdByList = [];
    currencyList = [];
    listOProducts = [];

    for (var doc in docs!) {
      if (doc['activity'] != "Expense") {
        productList.add(doc['items']);
        activityList.add(doc['activity']);
        currencyList.add(doc['currency']);
        dateList.add(doc['date'].toDate());
        createdByList.add(doc['requestBy']);
        List dynamicList = doc['items'];
        var array = [];
        for (var i = 0; i < doc['items'].length; ++i) {
          array.add(dynamicList[i]['product']);
        }
        listOProducts.add(array);
      }
    }

    _filterActivityList();
  }

  void _filterActivityList() {
    if (selectedActivity == 'All') {
      filteredProductList = productList;
      filteredActivityList = activityList;
      filteredDateList = dateList;
      filteredCreatedByList = createdByList;
      filteredCurrencyList = currencyList;
      filteredListOProducts = listOProducts;
    } else {
      filteredProductList = [];
      filteredActivityList = [];
      filteredDateList = [];
      filteredCreatedByList = [];
      filteredCurrencyList = [];
      filteredListOProducts = [];

      for (int i = 0; i < activityList.length; i++) {
        if (activityList[i] == selectedActivity) {
          filteredProductList.add(productList[i]);
          filteredActivityList.add(activityList[i]);
          filteredDateList.add(dateList[i]);
          filteredCreatedByList.add(createdByList[i]);
          filteredCurrencyList.add(currencyList[i]);
          filteredListOProducts.add(listOProducts[i]);
        }
      }
    }
  }
  void _showDetailsModal(BuildContext context, String activity, List items, String adder, DateTime date, String currency) {
    double totalCost = items.fold(0, (sum, item) => sum + item['totalPrice']);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Products $activity',
                style: kNormalTextStyle.copyWith(color: kBlack, fontWeight: FontWeight.bold, fontSize: 18),
              ),
              kSmallHeightSpacing,
              Text(
                '${DateFormat('d, MMM, yyy kk:mm a').format(date)}',
                style: kNormalTextStyle.copyWith(fontSize: 13),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min, // Ensures the dialog doesn't take the whole screen height
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: kAppPinkColor,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Done By $adder",
                      style: kNormalTextStyle.copyWith(color: kPureWhiteColor),
                    ),
                  ),
                ),
                kLargeHeightSpacing,
                ...items.asMap().entries.map((entry) {
                  int index = entry.key + 1;
                  var item = entry.value;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (activity != 'Updated')
                        Text(
                          '$index. ${item['product']}: ${item['quantity']} ${item['unit']} @ $currency ${CommonFunctions().formatter.format(item['totalPrice'])}',
                          style: kNormalTextStyle.copyWith(color: kBlack),
                        )
                      else
                        Text(
                          '$index. ${item['product']}: ${item['quantity']} ${item['unit']}',
                          style: kNormalTextStyle.copyWith(color: kBlack),
                        ),
                      SizedBox(height: 10),
                    ],
                  );
                }).toList(),

                if (activity != 'Updated')
                  Column(
                    children: [
                      Divider(color: kBlack),
                      Text(
                        'Total Cost: $currency ${CommonFunctions().formatter.format(totalCost)}',
                        style: kNormalTextStyle.copyWith(color: kBlack, fontWeight: FontWeight.bold),
                      ),
                      Divider(color: kBlack),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }



}