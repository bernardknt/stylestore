
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'constants/color_constants.dart';
import 'constants/user_constants.dart';


class ItemCard extends StatelessWidget {
  const ItemCard({ required this.titleList,

    required this.index,
    required this.priceList

  });

  final List<int> priceList;
  final int index;
  final List<String> titleList;


  @override

  Widget build(BuildContext context) {
    var formatter = NumberFormat('#,###,000');
    return Card(
      child: Row(
        children: [

          Padding(padding: EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titleList[index],
                  maxLines: 3,
                  style: TextStyle(fontSize: 14,
                      color: kBlueDarkColor,
                      fontWeight: FontWeight.bold),),
                SizedBox(height: 10,),
                Container(
                  width: 100,
                  child: Text('descList[index]',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey[500],
                    ),),
                ),
                SizedBox(height: 10,),
                Text('Ugx ${formatter.format(priceList[index])}',
                  maxLines: 3,
                  style: TextStyle(fontSize: 12,
                      color: Colors.green,
                      fontWeight: FontWeight.bold),),
              ],
            ),),
        ],
      ),
    );
  }
}

