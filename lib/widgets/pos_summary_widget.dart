import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Utilities/constants/color_constants.dart';
import '../Utilities/constants/font_constants.dart';
import '../Utilities/constants/user_constants.dart';
import '../model/beautician_data.dart';
import '../model/common_functions.dart';
import '../model/styleapp_data.dart';
import '../screens/products_pages/update_stock.dart';
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
              double trueValue = double.tryParse(value) ?? 0;
              if (item.tracking == false ){
                Provider.of<StyleProvider>(context, listen: false).updateBasketItemQuantity( index, double.tryParse(value) ?? 0, item.tracking); // Call updateQuantity function


              } else {
                if(trueValue >  item.quantity){
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return CupertinoAlertDialog(
                          title: const Text('Quantity Too High'),
                          content: Text(
                            "The quantity available for ${item.name} is ${item.quantity}!",
                            style: kNormalTextStyle.copyWith(color: kBlack),
                          ),
                          actions: [
                            CupertinoDialogAction(
                                isDestructiveAction: true,
                                onPressed: () {
                                  // _btnController.reset();
                                  Navigator.pop(context);
                                },
                                child: const Text('Cancel')),
                            CupertinoDialogAction(
                                isDefaultAction: true,
                                onPressed: () async {
                                  final prefs = await SharedPreferences.getInstance();
                                  Provider.of<BeauticianData>(context, listen: false).setStoreId(prefs.getString(kStoreIdConstant));


                                  Navigator.pop(context);
                                  Navigator.pushNamed(context, UpdateStockPage.id);
                                },
                                child: const Text('Update Stock')),
                          ],
                        );
                      });
                } else {
                  Provider.of<StyleProvider>(context, listen: false).updateBasketItemQuantity( index, double.tryParse(value) ?? 0, item.tracking); // Call updateQuantity function

                }

              }


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