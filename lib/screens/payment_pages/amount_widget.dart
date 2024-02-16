import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stylestore/Utilities/constants/font_constants.dart';
import 'package:intl/intl.dart';
import 'package:stylestore/screens/calendar_pages/calendar.dart';
import 'package:stylestore/screens/calendar_pages/invoiced_date_calendar.dart';

import '../../Utilities/constants/color_constants.dart';
import '../../model/common_functions.dart';
import '../../model/styleapp_data.dart';
import '../../payment_options.dart';

class AmountToPayWidget extends StatelessWidget {



  @override
  Widget build(BuildContext context) {
    TextEditingController controller = TextEditingController(text: '${Provider.of<StyleProvider>(context).paidPrice}');
    //TextEditingController controller = TextEditingController(text: '0.0');
    // Move the cursor to the end of the text
    controller.selection = TextSelection.fromPosition(
      TextPosition(offset:  controller.text.length-3), // controller.text.length
    );
    return Scaffold(
      backgroundColor: kPureWhiteColor,
      appBar: AppBar(
        // title: Text('How much was paid'),
        backgroundColor: kPureWhiteColor ,
        elevation: 0
      ),
      floatingActionButton: FloatingActionButton.extended(
        splashColor: Colors.green,
        // foregroundColor: Colors.black,
        backgroundColor: kAppPinkColor,
        //blendedData.saladButtonColour,
        onPressed: () async{

          //if (Provider.of<StyleProvider>(context, listen: false).paidPrice >=  Provider.of<StyleProvider>(context, listen:false).totalPrice){
          if (Provider.of<StyleProvider>(context, listen: false).paidPrice >  0){

            showModalBottomSheet(
                context: context,
                builder: (context) {
                  return PaymentOptions();


                });
          } else {
            Provider.of<StyleProvider>(context, listen: false).paidPrice != 0 ?ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('When is the Expected Date To Get Paid Remainder?'))):ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter the Expected Payment Date')));
            Navigator.push(context, MaterialPageRoute(
                builder: (context) => CalendarPage(),
              ),
            );
          }

        },

        label: Text(
          '${Provider.of<StyleProvider>(context).customerName} Paid: ${CommonFunctions().formatter.format(Provider.of<StyleProvider>(context).paidPrice)}',
          style: kNormalTextStyle.copyWith(color: kPureWhiteColor),
        ),
      ),
      floatingActionButtonLocation:
      FloatingActionButtonLocation.miniCenterFloat,
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text('Enter amount received for this transaction',textAlign: TextAlign.center, style: kNormalTextStyle.copyWith(fontSize: 20, color: kBlack),),
            Text('(Billed Ugx ${CommonFunctions().formatter.format(Provider.of<StyleProvider>(context, listen:false).totalPrice)} to ${Provider.of<StyleProvider>(context, listen: false).customerName})',textAlign: TextAlign.center, style: kNormalTextStyle.copyWith(fontSize: 14, color: kGreenThemeColor),),
            kLargeHeightSpacing,
            kLargeHeightSpacing,
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Ugx',
                  style: kNormalTextStyle.copyWith(fontSize: 35),
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
                    textAlign: TextAlign.center,
                    // textDirection: TextDirection.rtl,
                    style: kNormalTextStyle.copyWith(fontSize: 30),
                   keyboardType: TextInputType.number,
                   onChanged: (value){
                      print(value);
                      if (value!= ""){
                       Provider.of<StyleProvider>(context, listen: false).setPaidPrice(double.parse(value));
                      } else {
                        Provider.of<StyleProvider>(context, listen: false).setPaidPrice(double.parse("0.0"));
                      }

                   },
                  ),
               ),
              ],
            ),
            TextButton(onPressed: (){
              Navigator.push(context, MaterialPageRoute(
                builder: (context) => InvoicedDateCalendarPage(),
              ),
              );

            }, child:
            Text('Invoice Date:   ${DateFormat('dd MMMM yyy k:mm').format(Provider.of<StyleProvider>(context, listen: false).invoicedDate)}', style: kNormalTextStyle.copyWith(color: Colors.blueAccent),)),
            kLargeHeightSpacing,

// Add a text box to enter a note about the transaction
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: kBackgroundGreyColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextField(
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'Add a note for this transaction (optional)',
                  hintStyle: kNormalTextStyle.copyWith(color: kFontGreyColor),
                  border: InputBorder.none,
                ),
                style: kNormalTextStyle.copyWith(color: kBlack),
                onChanged: (value){
                  Provider.of<StyleProvider>(context, listen: false).setTransactionNote(value);
                },
              ),
            ),


          ],
        ),
      ),
    );
  }
}
