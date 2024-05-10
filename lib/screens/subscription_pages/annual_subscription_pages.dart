
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stylestore/model/common_functions.dart';
import 'package:stylestore/screens/payment_pages/subscription_mobile_money_payment.dart';
import 'package:stylestore/utilities/constants/icon_constants.dart';
import '../../Utilities/constants/color_constants.dart';
import '../../Utilities/constants/font_constants.dart';
import '../../model/offerings.dart';
import '../../model/styleapp_data.dart';
import '../../utilities/constants/user_constants.dart';
import '../../widgets/cancel_button_widget.dart';
import '../MobileMoneyPages/mm_payment_button_widget.dart';




class PremiumAnnualSubscriptionsPage extends StatefulWidget {
  static String id = 'premium_annual_page';

  const PremiumAnnualSubscriptionsPage({Key? key}) : super(key: key);


  @override
  _PremiumAnnualSubscriptionsPageState createState() => _PremiumAnnualSubscriptionsPageState();
}

class _PremiumAnnualSubscriptionsPageState extends State<PremiumAnnualSubscriptionsPage> {
  void defaultsInitiation () async{
    final prefs = await SharedPreferences.getInstance();
    Provider.of<StyleProvider>(context, listen: false).resetSubscriptionToBuy();
    currency = prefs.getString(kCurrency)??"USD";
    setState(() {


    });
  }

  int selectedOffering = 0; // Keeps track of selected option (0, 1, or 2)

  List<Offering> offerings = [
    Offering(title: 'Business Class', price: 499000, isSelected: false, benefits: ["Autopilot Business Notifications", "Barcode Scanning of Products", "Unlimited Products", "Up to 5 Employees", "Full Business Analytics"], duration: 365, ),
    Offering(title: 'First Class', price: 999000, isSelected: false, benefits: ["Everything in Premium", "Up to 10 Employees", "Custom Reports"], duration: 365, popular: true),
    Offering(title: 'VIP Class', price: 1499000, isSelected: false, benefits: ["Everything in Premium", "Location Tracking of Employees", "Up to 20 Employees"], duration: 365),
  ];


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    defaultsInitiation();
  }
  // VARIABLE DECLARATIONS


  String currency = 'UGX';
  String name = '';

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,

      body: SingleChildScrollView(
        child: Center(
          child: Container(
            // width: MediaQuery.of(context).size.width > 600 ? 400 : MediaQuery.of(context).size.width * 0.87,

            color: Colors.white,
            // padding: EdgeInsets.all(60),
            child: Center(
              child: Column(

                children: [
                  kLargeHeightSpacing,
                  Text("Select a Package", style: kNormalTextStyle.copyWith(fontSize: 18, fontWeight: FontWeight.bold),),
                  kSmallHeightSpacing,
                  Container(
                    decoration: BoxDecoration(
                      color: kGoldColor,
                      borderRadius: BorderRadius.circular(10)
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text("SAVE 15%", style: kNormalTextStyle.copyWith(fontSize: 16, fontWeight: FontWeight.bold, color: kBlack),),
                    ),
                  ),
                  kSmallHeightSpacing,

                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [

                        ...offerings.map((offering) => Padding(padding: EdgeInsets.all(10),
                            child: buildOfferingCard(offering))).toList(),
                      ],
                    ),
                  ),
                  kLargeHeightSpacing,
                  Provider.of<StyleProvider>(context, listen: true).subscriptionPackageToBuy == ""?Container():
                  MobileMoneyPaymentButton(buttonTextColor:Colors.white,buttonColor: kAppPinkColor,lineIconFirstButton: LineIcons.paypal,
                      firstButtonFunction: ()async{
                        showModalBottomSheet(
                            isScrollControlled: true,
                            context: context,
                            builder: (context) {
                              return Scaffold(
                                  appBar: AppBar(
                                    elevation: 0,
                                    backgroundColor: kPureWhiteColor,
                                    automaticallyImplyLeading: false,
                                  ),
                                  body: SubscriptionMobileMoneyPage());
                            });

                      }, firstButtonText: 'Select ${Provider.of<StyleProvider>(context, listen: true).subscriptionPackageToBuy}'),
                  kSmallHeightSpacing,
                  CancelButtonWidget()

                ],
              ),
            ),

          ),
        ),
      ),

    );
  }
  Widget buildOfferingCard(Offering offering) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: offering.isSelected ? kCustomColor : Colors.grey[200],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              for (var i = 0; i < offerings.length; i++) {
                offerings[i].isSelected = (i == offerings.indexOf(offering));

              }
              Provider.of<StyleProvider>(context, listen: false).setSubscriptionPackageToBuy(offering.title, offering.price, offering.duration, currency);
            });
          },
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  offering.title,
                  style: kNormalTextStyle.copyWith(
                    // fontSize: 16.0,
                    color: offering.isSelected ? kBlack:kFontGreyColor,
                    fontWeight: offering.isSelected ? FontWeight.bold : null,
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                      color: offering.isSelected ? kPureWhiteColor:Colors.transparent,
                      borderRadius: BorderRadius.circular(10)
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 4.0, bottom: 4, left: 8, right: 8),
                    child: Row(
                      children: [
                        Text(currency, style: TextStyle(
                          fontSize: 14.0,
                          fontWeight: offering.isSelected ? FontWeight.bold : null,
                        ),),
                        kSmallWidthSpacing,
                        Text(
                          CommonFunctions().formatter.format(offering.price),
                          style: TextStyle(
                            fontSize: 30.0,
                            fontWeight: offering.isSelected ? FontWeight.bold : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Divider(),
                SizedBox(
                  width: 150,
                  height: 200,
                  child: ListView.builder(
                      itemCount: offering.benefits.length,
                      itemBuilder: (context, index){
                        return
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Row(children: [
                              Icon(Icons.check, size: 10, color: kAppPinkColor,),
                              kSmallWidthSpacing,
                              kSmallWidthSpacing,
                              Expanded(child: Text(offering.benefits[index], style: kNormalTextStyle.copyWith(color: kBlack),)),
                            ],),
                          );

                      }),
                ),
                offering.popular==false? Container():Row(
                  // mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Stack(
                      children: [

                        Container(
                          decoration: BoxDecoration(
                              color: kGoldColor,
                              borderRadius: BorderRadius.circular(8)
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8.0, right: 8, top: 4, bottom: 4),
                            child: Text("Popular", style: kNormalTextStyle.copyWith(color: kBlack, fontSize: 12, fontWeight: FontWeight.bold),),
                          ),

                        ),
                        Positioned(
                            right: 0,
                            top: 2,
                            child:   kIconCrown
                        )
                      ],
                    ),
                  ],
                ),

                // Ro

              ],
            ),
          ),
        ),
      ),
    );
  }
}


