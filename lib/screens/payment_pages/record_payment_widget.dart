import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stylestore/Utilities/constants/font_constants.dart';
import 'package:stylestore/screens/payment_pages/update_payment_option.dart';
import 'package:stylestore/widgets/success_hi_five.dart';

import '../../Utilities/constants/color_constants.dart';
import '../../model/beautician_data.dart';
import '../../model/common_functions.dart';
import '../../model/styleapp_data.dart';
import '../../payment_options.dart';


class RecordPaymentWidget extends StatelessWidget {





  @override
  Widget build(BuildContext context) {
    var styleData = Provider.of<StyleProvider>(context);

    TextEditingController controller = TextEditingController(text: "${Provider.of<StyleProvider>(context).invoicedPriceToPay}");
    // Move the cursor to the end of the text
    controller.selection = TextSelection.fromPosition(
      TextPosition(offset: controller.text.length),
    );
    return Scaffold(
      backgroundColor: kPureWhiteColor,
      appBar: AppBar(
        // title: Text('How much was paid'),
          backgroundColor: kPureWhiteColor ,
          elevation: 0
      ),
      floatingActionButton: FloatingActionButton.extended(
        splashColor: kBlueDarkColor,
        // foregroundColor: Colors.black,
        backgroundColor: kAppPinkColor,
        //blendedData.saladButtonColour,
        onPressed: () {
          // incrementPaidAmount(styleData.invoiceTransactionId, styleData.invoicedPriceToPay);
          if(Provider.of<StyleProvider>(context, listen: false).invoicedPriceToPay!=0){
            showModalBottomSheet(
                context: context,
                builder: (context) {
                  return UpdatePaymentOptions();


                });
            // decreaseBillAmount(styleData.invoiceTransactionId, styleData.invoicedPriceToPay, context);

          }




        },
        // icon:  CircleAvatar(
        //     radius: 12,
        //     child: Text("${Provider.of<StyleProvider>(context).basketItems.length}", style:kNormalTextStyle.copyWith(color: kBlack) ,)),
        label: Text(
          '${Provider.of<StyleProvider>(context, listen: false).invoicedCustomer} Paying: ${CommonFunctions().formatter.format(Provider.of<StyleProvider>(context).invoicedPriceToPay)}',
          style: kNormalTextStyle.copyWith(color: kPureWhiteColor),
        ),
      ),
      floatingActionButtonLocation:
      FloatingActionButtonLocation.miniCenterFloat,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('Enter amount received for this transaction',textAlign: TextAlign.center, style: kNormalTextStyle.copyWith(fontSize: 25, color: kBlack),),
            kLargeHeightSpacing,
            kLargeHeightSpacing,
            Text('${Provider.of<StyleProvider>(context, listen: false).invoicedCustomer}',textAlign: TextAlign.center, style: kNormalTextStyle.copyWith(fontSize: 16),),
            Text('Invoiced Amount: ${CommonFunctions().formatter.format(Provider.of<StyleProvider>(context, listen: false).invoicedTotalPrice)} Ugx',textAlign: TextAlign.center, style: kNormalTextStyle.copyWith(fontSize: 16),),
            Text('Paid Amount: ${CommonFunctions().formatter.format(Provider.of<StyleProvider>(context, listen: false).invoicedPaidPrice)} Ugx',textAlign: TextAlign.center, style: kNormalTextStyle.copyWith(fontSize: 16),),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Ugx',
                  style: kNormalTextStyle.copyWith(fontSize: 18),
                ),
                kSmallWidthSpacing,

                Container(
                  width: 150,
                  child: TextField(
                    decoration: InputDecoration(
                      border: InputBorder.none,

                    ),
                    controller: controller,
                    // TextEditingController()..text ='${Provider.of<StyleProvider>(context).totalPrice}',
                    textAlign: TextAlign.start,
                    style: kNormalTextStyle.copyWith(fontSize: 30),
                    keyboardType: TextInputType.number,
                    onChanged: (value){
                      print(value);
                      if (value!= ""){
                        Provider.of<StyleProvider>(context, listen: false).setInvoicedPriceToPay(int.parse(value));
                      } else {
                        Provider.of<StyleProvider>(context, listen: false).setInvoicedPriceToPay(int.parse("0"));
                      }

                    },
                  ),
                ),
              ],
            ),

          ],
        ),
      ),
    );
  }
}
