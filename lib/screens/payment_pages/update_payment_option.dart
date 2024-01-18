


import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stylestore/model/common_functions.dart';
import 'package:stylestore/screens/calendar_pages/calendar.dart';
import 'package:stylestore/screens/success_page_appointments.dart';

import '../../Utilities/constants/color_constants.dart';
import '../../Utilities/constants/font_constants.dart';
import '../../model/styleapp_data.dart';



class UpdatePaymentOptions extends StatefulWidget {
  const UpdatePaymentOptions({Key? key}) : super(key: key);

  @override
  State<UpdatePaymentOptions> createState() => _UpdatePaymentOptionsState();
}

class _UpdatePaymentOptionsState extends State<UpdatePaymentOptions> {
  String selectedSaleableValue = "Cash";
  @override
  Widget build(BuildContext context) {
    return
      Scaffold(
        floatingActionButton: FloatingActionButton.extended(
          splashColor: Colors.green,
          // foregroundColor: Colors.black,
          backgroundColor: kAppPinkColor,
          //blendedData.saladButtonColour,
          onPressed: () async{
            final prefs = await SharedPreferences.getInstance();
            var styleData=  Provider.of<StyleProvider>(context, listen: false);
            styleData.setPaymentMethod(selectedSaleableValue);



               CommonFunctions().decreaseBillAmount(styleData.invoiceTransactionId, styleData.invoicedPriceToPay, context);



          },

          label: Text(
            '${Provider.of<StyleProvider>(context).customerName} Paid using $selectedSaleableValue',
            style: kNormalTextStyle.copyWith(fontSize: 12, color: kPureWhiteColor),
          ),
        ),
        floatingActionButtonLocation:
        FloatingActionButtonLocation.miniCenterFloat,
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(

            // mainAxisAlignment: MainAxisAlignment.spaceAround,

            children: [

              Text('Enter Payment Method',textAlign: TextAlign.center, style: kNormalTextStyle.copyWith(fontSize: 20, color: kBlack),),
              kLargeHeightSpacing,
              kLargeHeightSpacing,
              kLargeHeightSpacing,
              kLargeHeightSpacing,
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [



                  Radio<String>(
                    fillColor:CommonFunctions().convertToMaterialStateProperty(kAppPinkColor) ,
                    value: "Cash",
                    groupValue: selectedSaleableValue,
                    onChanged: (value) {
                      setState(() {
                        selectedSaleableValue = value!;
                        print(value);
                      });
                    },
                  ),
                  Text("Cash",style: kNormalTextStyle.copyWith(fontSize: 14,color: kBlack)),
                  kSmallWidthSpacing,
                  Radio<String>(
                    fillColor:CommonFunctions().convertToMaterialStateProperty(kAppPinkColor) ,
                    value: "Mobile Money",
                    groupValue: selectedSaleableValue,
                    onChanged: (value) {
                      setState(() {
                        selectedSaleableValue = value!;
                        print(value);
                      });
                    },
                  ),
                  Text("Mobile Money",style: kNormalTextStyle.copyWith(fontSize: 14,color:kBlack)),
                  kSmallWidthSpacing,
                  Radio<String>(
                    fillColor:CommonFunctions().convertToMaterialStateProperty(kAppPinkColor) ,
                    value: "Card",
                    groupValue: selectedSaleableValue,
                    onChanged: (value) {
                      setState(() {
                        selectedSaleableValue = value!;
                        print(value);
                      });
                    },
                  ),
                  Text("Card",style: kNormalTextStyle.copyWith(fontSize: 14,color:kBlack)),

                ],
              ),
            ],
          ),
        ),
      );
  }
}
