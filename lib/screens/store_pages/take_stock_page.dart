import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Utilities/constants/color_constants.dart';
import '../../Utilities/constants/font_constants.dart';
import '../../Utilities/constants/user_constants.dart';
import '../../model/beautician_data.dart';
import '../../model/common_functions.dart';
import '../../model/styleapp_data.dart';
import '../products_pages/restock_page.dart';
import '../products_pages/stock_history.dart';
import '../products_pages/update_stock.dart';

class TakeStockWidget extends StatelessWidget {
  final bool mainPage;
  const TakeStockWidget({

    super.key,  this.mainPage = false,
  });

  @override
  Widget build(BuildContext context) {
    if (mainPage == true){
      CommonFunctions().retrieveSuppliesData(context);
    }

    return Scaffold(
      backgroundColor: kBlack,
      appBar: AppBar(
        backgroundColor: kBlack,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, StockHistoryPage.id);


                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Iconsax.receipt, color: kPureWhiteColor, size: 25,),
                    Text("History", style: kNormalTextStyle.copyWith(
                        fontSize: 12,
                        color: kPureWhiteColor,
                        fontWeight: FontWeight.bold),)
                  ],
                )),
          ),
        ],
      ),
      body: Material(
        color: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                Column(
                  children: [
                    GestureDetector(
                      onTap: () async{
                        final prefs = await SharedPreferences.getInstance();
                        String storeId = prefs.getString(kStoreIdConstant)??"";
                        Provider.of<BeauticianData>(context, listen: false).setStoreId(storeId);
                        if(mainPage == false){
                          Navigator.pop(context);
                        }
                        Navigator.pushNamed(
                            context, UpdateStockPage.id);
                      },
                      child: CircleAvatar(
                          radius: 30,
                          backgroundColor: kCustomColor
                              .withOpacity(1),
                          child: const Icon(
                            Iconsax.box, color: kBlack,
                            size: 20,)),
                    ),
                    Text("Update / Check\nStock",
                      textAlign: TextAlign.center,
                      style: kNormalTextStyle.copyWith(
                          color: kPureWhiteColor,
                          fontSize: 12),)
                  ],
                ),
                kMediumWidthSpacing,
                kMediumWidthSpacing,
                kMediumWidthSpacing,
                Column(
                  children: [
                    GestureDetector(
                      onTap: () async{
                        final prefs = await SharedPreferences.getInstance();
                        String storeId = prefs.getString(kStoreIdConstant)??"";
                        Provider.of<BeauticianData>(context, listen: false).setStoreId(storeId);
                        Provider.of<StyleProvider>(context, listen: false).resetSelectedStockBasket ();
                        if(mainPage == false){
                          Navigator.pop(context);
                        }

                        Navigator.pushNamed(
                            context, ReStockPage.id);
                      },
                      child: CircleAvatar(
                          backgroundColor: kCustomColorPink
                              .withOpacity(1),

                          radius: 30,
                          child: const Icon(Iconsax.tag,
                            color: kPureWhiteColor,
                            size: 20,)),
                    ),
                    Text("Restock / Purchase\nItems",
                      textAlign: TextAlign.center,
                      style: kNormalTextStyle.copyWith(
                          color: kPureWhiteColor,
                          fontSize: 12),)
                  ],
                ),

              ],
            )),
            kLargeHeightSpacing,
            kLargeHeightSpacing,
            kLargeHeightSpacing,
            Opacity(
                opacity: 0.3,
                child: Image.asset('images/air2.jpg',height: 150,)),
            kLargeHeightSpacing,
            kLargeHeightSpacing,
            kLargeHeightSpacing,
            kLargeHeightSpacing,
            kLargeHeightSpacing,
            mainPage == false ? Text("Cancel", style: kNormalTextStyle.copyWith(color: kPureWhiteColor),): SizedBox()
          ],
        ),
      ),
    );
  }
}