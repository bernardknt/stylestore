import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stylestore/Utilities/constants/color_constants.dart';
import 'package:stylestore/Utilities/constants/font_constants.dart';
import 'package:stylestore/Utilities/constants/user_constants.dart';
import 'package:stylestore/screens/MobileMoneyPages/mobile_money_page.dart';
import 'package:stylestore/widgets/credit_card.dart';

import '../model/styleapp_data.dart';

class WalletsPage extends StatelessWidget {
  static String id = 'wallets_page';
  TextEditingController moneyController = TextEditingController();

  void _showDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final moneyController = TextEditingController();
        final reasonController = TextEditingController();

        return AlertDialog(
          title: Text("Enter Details"), // Updated title
          content: Column(
            mainAxisSize: MainAxisSize.min, // To make the dialog content shrink
            children: [
              TextFormField(
                controller: moneyController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: "Amount"),
              ),
              SizedBox(height: 10), // Add spacing between fields
              TextFormField(
                controller: reasonController,
                decoration: InputDecoration(labelText: "Reason"),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                            final prefs = await SharedPreferences.getInstance();
                            prefs.setDouble(kBillValue, double.parse(moneyController.text));
                            Provider.of<StyleProvider>(context, listen: false).setBookingPrice(double.parse(moneyController.text));
                            prefs.setString(kPhoneNumberConstant, "70123456");

                            prefs.setString(kOrderId, "${DateTime.now()}");
                            Navigator.of(context).pop();
                            Navigator.pushNamed(context, MobileMoneyPage.id);
              },
              child: Text("Submit"),
            ),
          ],
        );
      },
    );

    // showDialog(
    //   context: context,
    //   builder: (BuildContext context) {
    //     return AlertDialog(
    //       title: Text("Enter Amount"),
    //       content: TextFormField(
    //         controller: moneyController,
    //         keyboardType: TextInputType.number,
    //         decoration: InputDecoration(labelText: "Amount"),
    //       ),
    //       actions: <Widget>[
    //         TextButton(
    //           onPressed: () {
    //             Navigator.of(context).pop();
    //           },
    //           child: Text("Cancel"),
    //         ),
    //         TextButton(
    //           onPressed: () async{
    //             final prefs = await SharedPreferences.getInstance();
    //             prefs.setDouble(kBillValue, double.parse(moneyController.text));
    //             Provider.of<StyleProvider>(context, listen: false).setBookingPrice(double.parse(moneyController.text));
    //             prefs.setString(kPhoneNumberConstant, "70123456");
    //             prefs.setString(kOrderId, "${DateTime.now()}");
    //             Navigator.of(context).pop();
    //             Navigator.pushNamed(context, MobileMoneyPage.id);
    //           },
    //           child: Text("Submit"),
    //         ),
    //       ],
    //     );
    //   },
    // );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPlainBackground,
      // appBar: AppBar(
      //   title: Text('Wallet Dashboard'),
      // ),
      body: Column(
        children: [
          kLargeHeightSpacing,


          GestureDetector(
            onTap: () {

              _showDialog(context);

            },


              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(

                    width: 400,
                    child: DebitCard(cardNumber: Provider.of<StyleProvider>(context, listen: false).beauticianId, cardHolderName: "FRUTS EXPRESS", expiryDate: "500,000", bankName: 'Centenary Bank')),
              )),
          Row(
            children: [

              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: kBlueDarkColor,
                    ),
                    child: ListTile(
                      // leading: Icon(Icons.arrow_downward, color: kPureWhiteColor),
                      title: Column(
                        children: [
                          Icon(Icons.arrow_upward, color: kPureWhiteColor),
                          Text('Deposit', style: kNormalTextStyle.copyWith(color: kPureWhiteColor, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      onTap: () {
                        // Handle withdraw action
                        _showDialog(context);
                      },
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: kBlack,
                    ),
                    child: ListTile(
                      // leading: Icon(Icons.arrow_downward, color: kPureWhiteColor)
                      title: Column(
                        children: [
                          Icon(Icons.arrow_downward, color: kPureWhiteColor),
                          Text('Withdraw', style: kNormalTextStyle.copyWith(color: kPureWhiteColor, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      onTap: () {
                        // Handle withdraw action
                      },
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(

                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: kPureWhiteColor,
                    ),
                    child: ListTile(
                      // leading: Icon(Icons.payment, color: kBlack),
                      title: Column(
                        children: [
                          Icon(Icons.payment, color: kBlack),
                          Text('Pay Out', style: kNormalTextStyle.copyWith(color: kBlack),),
                        ],
                      ),
                      onTap: () {
                        // Handle make payment action
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 16),
          Text(
            'Last Transactions',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              children: [
                // Replace with transaction items
                // Example:
                Card(
                  child: ListTile(
                    leading: Icon(Icons.shopping_cart),
                    title: Text('Deposits and Withdraws'),
                    subtitle: Text('\$50.00'),
                  ),
                ),
                Card(
                  child: ListTile(
                    leading: Icon(Icons.restaurant),
                    title: Text('Payments'),
                    subtitle: Text('\$30.00'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
