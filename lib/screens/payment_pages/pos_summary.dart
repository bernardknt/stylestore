

import 'dart:math';

import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stylestore/Utilities/constants/font_constants.dart';
import 'package:stylestore/model/common_functions.dart';
import 'package:stylestore/model/styleapp_data.dart';
import 'package:uuid/uuid.dart';
import '../../Utilities/constants/color_constants.dart';
import '../../Utilities/constants/user_constants.dart';
import '../../model/beautician_data.dart';
import '../../model/stock_items.dart';
import '../customer_pages/search_customer.dart';
import 'amount_widget.dart';





class PosSummary extends StatelessWidget {

  DateTime date = DateTime.now();
  var uuid = Uuid();
  final Iterable<Duration> pauses = [
    const Duration(milliseconds: 300),
    const Duration(milliseconds: 500),
  ];

  @override
  Widget build(BuildContext context) {
    var styleData = Provider.of<StyleProvider>(context);
    return Container(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [kBlueDarkColor, kAppPinkColor] ),
            borderRadius: BorderRadius.only(topRight: Radius.circular(20),  topLeft: Radius.circular(20)),
            color: Colors.green
        ),

        padding: EdgeInsets.all(20),
        child: Stack(
            children : [
              styleData.basketNameItems.isEmpty?Container(
                child: Center(child: Text("Order Details Appear Here", style: kNormalTextStyle.copyWith(color: kPureWhiteColor),),),
              ):Positioned(
                  bottom: -10,
                  right: 0,
                  left: 0,

                  child:
                  Center(
                    child: TextButton.icon(onPressed: ()async{
                      // Navigator.pushNamed(context, CheckoutPage.id);
                      //print(date);
                    },
                      style: TextButton.styleFrom(
                        //elevation: ,
                          shadowColor: kBlueDarkColorOld,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18)
                          ),
                          backgroundColor: const Color(0x00F2efe4)),icon: Icon(LineIcons.moneyBill, color: kPureWhiteColor,),
                      label: Text('Total Bill: ${CommonFunctions().formatter.format(styleData.totalPrice)}', style: kNormalTextStyle.copyWith(color: kPureWhiteColor) )),
                  )),
              Positioned(
                child: ListView.builder(
                    itemCount: styleData.basketItems.length,
                    itemBuilder: (context, index){
                      return ListTile(
                        leading: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("${index + 1}. ${styleData.basketNameItems[index]} x ${styleData.basketItems[index].quantity.toStringAsFixed(0)}", style: kNormalTextStyle.copyWith(color: kPureWhiteColor)),
                            Text("${styleData.storeCurrency} ${CommonFunctions().formatter.format(styleData.basketItemsPrices[index])}", style: kNormalTextStyle.copyWith(color: kPureWhiteColor, fontSize: 10)),
                          ],
                        ),
                        title:
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [

                            Text("${styleData.storeCurrency} ${CommonFunctions().formatter.format(styleData.basketItemsPrices[index] * styleData.basketItems[index].quantity)}",overflow: TextOverflow.ellipsis, style: kNormalTextStyle.copyWith(color: kPureWhiteColor, fontSize: 12)),
                          ],
                        ),
                        trailing: Checkbox(
                          activeColor: Colors.white,
                          checkColor: Color(0xFF0d1206),
                          shape: CircleBorder(),
                          onChanged: (bool? value) {
                            if (styleData.basketItems[index].tracking == true){

                              Stock? foundStock = styleData.selectedStockItems.firstWhere((stock) => stock.name == styleData.basketItems[index].name);
                              styleData.removeSelectedStockItems(foundStock);
                              print("REMOVED TRACKED STOCK");
                            }
                            styleData.deleteItemFromBasket(styleData.basketItems[index], styleData.basketItems[index].quantity, index);
                            // If the item selected for removal is true then we must get the SelectedQuantity item where the name is equal to the name in the basket it item

                                //.deleteJuiceIngredient(styleData.selectedJuiceIngredients[index]);
                          }, value: true,),
                      );
                    }),
              ),
              styleData.basketNameItems.isEmpty? Container(): Positioned(
                  bottom: 30,
                  left: 0,
                  right: 0,

                  child:
                  Center(
                    child: TextButton.icon(onPressed: ()async{
                      final prefs = await SharedPreferences.getInstance();
                      prefs.setString(kOrderId, CommonFunctions().generateUniqueID(prefs.getString(kBusinessNameConstant)!));
                      Provider.of<StyleProvider>(context, listen: false).setAppointmentTimeDate(date, date);
                      Provider.of<StyleProvider>(context, listen: false).setInvoicedTimeDate(DateTime.now());
                      Provider.of<StyleProvider>(context, listen: false).setInstructionsInfo('Product');
                      Provider.of<StyleProvider>(context, listen: false).setPaymentStatus('Product');
                      Provider.of<StyleProvider>(context, listen: false).setPaidPrice(styleData.totalPrice);
                      Provider.of<BeauticianData>(context, listen: false)
                          .setStoreId(prefs.getString(kStoreIdConstant));
                      if (Provider.of<StyleProvider>(context, listen: false).customerName == ""){

                        CoolAlert.show(
                            width: MediaQuery.of(context).size.width > 600 ? 400 : MediaQuery.of(context).size.width * 0.8,
                            lottieAsset: 'images/leave.json',
                            context: context,
                            type: CoolAlertType.success,
                            text: 'No Customer Added',
                            title:'Add a Customer',
                            confirmBtnText: 'Add',
                            cancelBtnText: "Continue with Customer",
                            cancelBtnTextStyle: kNormalTextStyle,
                            confirmBtnTextStyle: kNormalTextStyle.copyWith(color: kPureWhiteColor),
                            showCancelBtn: true,
                            confirmBtnColor: Colors.green,
                            backgroundColor: kBlueDarkColor,
                            onCancelBtnTap: (){
                              Provider.of<StyleProvider>(context, listen: false).clearSelectedStockItems();
                              Navigator.pop(context);
                              Provider.of<StyleProvider>(context, listen: false).setCustomerNameOnly("Customer");
                              showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  builder: (context) {
                                    return Scaffold(
                                        appBar: AppBar(
                                          automaticallyImplyLeading: false,
                                          backgroundColor: kPureWhiteColor,
                                          elevation: 0,
                                        ),

                                        body: AmountToPayWidget());
                                  });
                            },
                            onConfirmBtnTap: (){
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
                                        body: CustomerSearchPage());
                                  });


                            }
                        );
                      } else {


                        if (kIsWeb) {

                        } else {
                          Navigator.pop(context);
                        }


                        showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            builder: (context) {
                              return Scaffold(
                                  appBar: AppBar(
                                    automaticallyImplyLeading: false,
                                    backgroundColor: kPureWhiteColor,
                                    elevation: 0,
                                  ),

                                  body: AmountToPayWidget());
                            });
                      }// Vibration.vibrate();
                    },
                      style: TextButton.styleFrom(
                        //elevation: ,
                          shadowColor: kBlueDarkColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18)
                          ),
                          backgroundColor: Color(0xFFF2efe4)),icon: Icon(LineIcons.receipt, color: kBlueDarkColorOld,),
                      label: Text('Record', style: TextStyle(fontWeight: FontWeight.bold,
                          color: kBlueDarkColor), ), ),
                  )),
              // Color(0xFFF2efe4)

            ]
        ),
      ),
    );
  }
}

