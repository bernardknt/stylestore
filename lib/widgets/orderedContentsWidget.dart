
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stylestore/Utilities/constants/color_constants.dart';



class OrderedContentsWidget extends StatelessWidget {

  OrderedContentsWidget({required this.orderIndex, required this.quantity, required this.productDescription, required this.productName, this.note = 'None'});

  final String productName;
  final String productDescription;
  final int quantity;
  final int orderIndex;
  final String note;

  @override
  Widget build(BuildContext context) {
    var numberOfFollowers = productDescription.length;
    return Container(
      //width: double.infinity,

      padding: EdgeInsets.all(0),
      margin: EdgeInsets.only(top: 16, left:16, right: 16),
      decoration: BoxDecoration(
        color: kPureWhiteColor, borderRadius: BorderRadius.circular(18), //Color(0xFF212121)
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          //mainAxisSize: MainAxisSize.min,
          children: [

            RichText(
              text: TextSpan(
                text: 'Order $orderIndex: ',
                style: DefaultTextStyle.of(context).style,
                children: <TextSpan>[
                  TextSpan(
                      text: '$productName x $quantity',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: '\nDetails: $productDescription'),
                  // TextSpan(
                  //     text: '\nStatus: $note',
                  //     style: TextStyle()),
                ],
              ),
            ),

          //paymentButtons(continueFunction: (){}, continueBuyingText: 'Missing Ingredients', checkOutText: 'Done', buyFunction: (){})
          ],
        ),
      ),
    );
  }
}