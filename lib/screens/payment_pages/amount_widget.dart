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


class AmountToPayWidget extends StatefulWidget {
  const AmountToPayWidget({Key? key}) : super(key: key); // Add a key

  @override
  _AmountToPayWidgetState createState() => _AmountToPayWidgetState();
}

class _AmountToPayWidgetState extends State<AmountToPayWidget> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.text =
       // CommonFunctions().formatter.format(
            Provider.of<StyleProvider>(context, listen: false).paidPrice.toString();
       // );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var styleDataListen = Provider.of<StyleProvider>(context, listen: false);
    var styleData = Provider.of<StyleProvider>(context, listen: true);
    return Consumer<StyleProvider>( // Use Consumer for targeted rebuilds
      builder: (context, styleProvider, child) {
        return Scaffold(

          backgroundColor: kPureWhiteColor,
          appBar: AppBar(
            // title: Text('How much was paid'),
              backgroundColor: kPureWhiteColor ,
              elevation: 0
          ),
          floatingActionButton: FloatingActionButton.extended(
            splashColor: Colors.green,
            backgroundColor: kAppPinkColor,

            onPressed: () async{

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
              '${Provider.of<StyleProvider>(context).customerName} Paid: ${CommonFunctions().formatter.format(Provider.of<StyleProvider>(context, listen: true).paidPrice)}',
              style: kNormalTextStyle.copyWith(color: kPureWhiteColor),
            ),
          ),
          floatingActionButtonLocation:
          FloatingActionButtonLocation.miniCenterFloat,

          body: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                Text('Enter amount received for this transaction',textAlign: TextAlign.center, style: kNormalTextStyle.copyWith(fontSize: 20, color: kBlack),),
                Text('(Billed ${styleData.storeCurrency} ${CommonFunctions().formatter.format(Provider.of<StyleProvider>(context, listen:false).totalPrice)} to ${Provider.of<StyleProvider>(context, listen: false).customerName})',textAlign: TextAlign.center, style: kNormalTextStyle.copyWith(fontSize: 14, color: kGreenThemeColor),),
                kLargeHeightSpacing,
                kLargeHeightSpacing,
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                   Text('${styleData.storeCurrency}', style: kNormalTextStyle.copyWith(fontSize: 35)),
                    kSmallWidthSpacing,
                    Container(
                      width: 150,
                      child: TextField(
                        controller: _controller,
                        decoration: const InputDecoration(border: InputBorder.none),
                        textAlign: TextAlign.center,
                        style: kNormalTextStyle.copyWith(fontSize: 30),
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                        onChanged: (value) {
                          if (value.isNotEmpty) {
                            final newValue = value.replaceAll(",", ".");
                            styleProvider.setPaidPrice(double.parse(newValue));
                          } else {
                            styleProvider.setPaidPrice(0.0);
                          }
                        },
                      ),
                    ),
                  ],
                ),
                TextButton(onPressed: (){
                  Navigator.push(context, MaterialPageRoute(
                    builder: (context) => NewInvoicedDateCalendarPage(),
                  ),
                  );

                }, child:
                Container(
                  decoration: BoxDecoration(
                    color: kCustomColorPurple,
                    borderRadius: BorderRadius.circular(10)
                  ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('Invoice Date:   ${DateFormat('dd MMMM yyy k:mm a').format(Provider.of<StyleProvider>(context, listen: false).invoicedDate)}', style: kNormalTextStyle.copyWith(color: Colors.blueAccent),),
                    ))),
                kLargeHeightSpacing,
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
      },
    );
  }
}


