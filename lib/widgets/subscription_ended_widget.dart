



import 'package:flutter/material.dart';
import 'package:stylestore/controllers/subscription_controller.dart';

import '../Utilities/constants/color_constants.dart';
import '../Utilities/constants/font_constants.dart';
import '../screens/MobileMoneyPages/premium_mm_payment.dart';

class SubcriptionEndedWidget extends StatelessWidget {
  final String businessName;
  const SubcriptionEndedWidget({
    super.key, required this.businessName,


  });




  @override
  Widget build(BuildContext context) {
    return Card(
        color: kPureWhiteColor,
        shadowColor: kPureWhiteColor,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius:BorderRadius.only(topRight: Radius.circular(20), topLeft: Radius.circular(20), bottomRight: Radius.circular(20))),
        child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Container(
                width: 260,
                height: 250,
                child: Column(
                    crossAxisAlignment:CrossAxisAlignment.start ,

                    children: [
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: "Attention $businessName, this is your Captain speaking!\n\n",
                              style: TextStyle(fontWeight: FontWeight.bold),

                            ),
                            const TextSpan(
                              text: "Looks like your Business Pilot flight plan might have expired. This is a Premium feature. Also Notifications, reminders and critical features seem to be off.\nRenew now to avoid turbulence! Let us prepare for lift-off",
                            ),

                          ],
                        ),
                      ),
                      kLargeHeightSpacing,
                      //Text("Attention all passengers, this is your Captain speaking.",style: kNormalTextStyle.copyWith(fontSize: 15, color: kBlueDarkColor)),
                      TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: kAppPinkColor,
                            foregroundColor: Colors.white, // White text on blue background
                          ),
                          onPressed: (){
                            Navigator.pop(context);

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
                                      body:
                                          SubscriptionController()


                                  );
                                });
                          }, child: Text("Renew Subscription")),
                    ]
                )
            )
        )
    );
  }
}



