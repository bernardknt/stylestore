




import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import 'package:stylestore/model/common_functions.dart';
import 'package:stylestore/utilities/constants/color_constants.dart';


import '../../../Utilities/constants/font_constants.dart';
import '../../../model/best_customer.dart';

class BestCustomersPage extends StatelessWidget {
  final List<BestCustomer> bestCustomers;

  BestCustomersPage({required this.bestCustomers});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBlack,
      appBar: AppBar(
        foregroundColor: kPureWhiteColor,
        title: Text('Top 10 Customers', style: kNormalTextStyle.copyWith(color: kPureWhiteColor),),
        centerTitle: true,
        backgroundColor: kBlack,
        elevation: 0,
      ),
      body: ListView.builder(
        itemCount:  bestCustomers.length > 10 ? 10 : bestCustomers.length,
        itemBuilder: (context, index) {
          final customer = bestCustomers[index];
          return ListTile(
            tileColor: index == 0? kAppPinkColor:kBlack,
            title: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("${index+1}. ${customer.name}", style: kNormalTextStyle.copyWith(color: kPureWhiteColor),),
                index == 0?Icon(Iconsax.crown, color: kGoldColor,size: 18,):SizedBox()
              ],
            ),
            trailing: Text('${CommonFunctions().formatter.format(customer.totalPaid)}', style: kNormalTextStyle.copyWith(color: kPureWhiteColor),),
          );
        },
      ),
    );
  }
}