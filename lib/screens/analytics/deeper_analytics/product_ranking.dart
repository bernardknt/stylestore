




import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import 'package:stylestore/model/common_functions.dart';
import 'package:stylestore/utilities/constants/color_constants.dart';


import '../../../Utilities/constants/font_constants.dart';
import '../../../model/best_customer.dart';
import '../../../model/product_items_model.dart';

class BestProductPage extends StatelessWidget {
  final List<ProductItems> bestProducts;

  BestProductPage({required this.bestProducts});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBlack,
      appBar: AppBar(
        foregroundColor: kPureWhiteColor,
        title: Text('Top 10 Products', style: kNormalTextStyle.copyWith(color: kPureWhiteColor),),
        centerTitle: true,
        backgroundColor: kBlack,
        elevation: 0,
      ),
      body: ListView.builder(
        itemCount:  bestProducts.length > 10 ? 10 : bestProducts.length,
        itemBuilder: (context, index) {
          final customer = bestProducts[index];
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
            trailing: Text('${CommonFunctions().formatter.format(customer.total)}', style: kNormalTextStyle.copyWith(color: kPureWhiteColor),),
          );
        },
      ),
    );
  }
}