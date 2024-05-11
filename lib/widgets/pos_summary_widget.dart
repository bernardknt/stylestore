import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Utilities/constants/color_constants.dart';
import '../Utilities/constants/font_constants.dart';
import '../model/common_functions.dart';
import '../model/styleapp_data.dart';
import '../utilities/basket_items.dart';

Widget buildItemRow(context, BasketItem item, currency,fontColor, index) {
  // TextEditingController controller = TextEditingController()..text = item.quantity.toString();
  TextEditingController controller = TextEditingController(text: item.quantity.toString())..selection = TextSelection.collapsed(offset: 1);
  return Row(
    children: [

      Expanded(child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(item.name, style: kNormalTextStyle.copyWith(color: fontColor),),
          Text("@ $currency ${CommonFunctions().formatter.format(item.amount)}", style: kNormalTextStyle.copyWith(color: fontColor, fontSize: 8),),
        ],
      )),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.0),
        child: SizedBox(
          width: 30.0,
          child: TextField(
            controller: controller,
            style: kNormalTextStyle.copyWith(color: fontColor),
            // selectionEnabled: false,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: "Qty",
            ),
            onChanged: (value) {
              item.quantity = double.tryParse(value) ?? 0;
              Provider.of<StyleProvider>(context, listen: false).updateBasketItemQuantity( index, double.tryParse(value) ?? 0); // Call updateQuantity function



            },
          ),
        ),
      ),
      Row(
        children: [
          Text("$currency", style: kNormalTextStyle.copyWith(color:fontColor, fontSize: 8),),
          kSmallWidthSpacing,// Update price based on quantity),
          Text("${CommonFunctions().formatter.format(item.amount * item.quantity)}", style: kNormalTextStyle.copyWith(color: fontColor),),
          IconButton(
            icon: Icon(Icons.delete, color: fontColor,),
            onPressed: () => Provider.of<StyleProvider>(context, listen: false).removeBasketItem(index),
          ),// Update price based on quantity),
        ],
      ),
    ],
  );
}