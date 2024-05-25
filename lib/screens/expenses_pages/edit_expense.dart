import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:stylestore/Utilities/constants/font_constants.dart';
import 'package:stylestore/model/common_functions.dart';
import 'package:stylestore/model/pdf_files/invoice.dart';
import 'package:stylestore/model/styleapp_data.dart';
import 'package:stylestore/screens/calendar_pages/edit_invoice_calendar.dart';
import 'package:stylestore/utilities/constants/color_constants.dart';

import '../../Utilities/constants/user_constants.dart';
import '../../model/beautician_data.dart';
import '../customer_pages/search_customer.dart';
import '../products_pages/search_products.dart';



class EditExpensePage extends StatelessWidget {
  @override
  final RoundedLoadingButtonController _btnController = RoundedLoadingButtonController();
  String id = "";

  Widget build(BuildContext context) {
    var styleData = Provider.of<StyleProvider>(context);
    id = styleData.expenseTransactionId;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPureWhiteColor,
        title: Text('Edit Expense', style: kNormalTextStyle.copyWith(color: kBlack),),
        centerTitle: true,
        elevation: 0,
        actions: [
          TextButton(onPressed: (){
            showDialog(context: context, builder: (BuildContext context){
              return CupertinoAlertDialog(
                title:Text('Delete Expense? '),
                content: Text('Are you Sure you want to delete ${styleData.expenseTransactionId} expense?\nThis is permanent!'),
                actions: [
                  CupertinoDialogAction(isDestructiveAction: true,
                      onPressed: (){
                        // _btnController.reset();
                        print("Purchases deleted");
                        CommonFunctions().deleteFirestoreDocument("purchases", styleData.expenseTransactionId, context);


                        // Navigator.pushNamed(context, SuccessPageHiFive.id);
                      },

                      child: const Text('Cancel')
                  ),
                  CupertinoDialogAction(isDefaultAction: true,
                    onPressed: (){
                      // _btnController.reset();
                      CommonFunctions().removeDocumentFromServer(styleData.expenseTransactionId, "purhases").whenComplete(()
                      {
                        Navigator.pop(context);
                        Navigator.pop(context);
                      });


                      // Navigator.pushNamed(context, SuccessPageHiFive.id);
                    }, child: Text('Delete'),)
                ],
              );
            });


          }, child: Text("Delete Expense", style: kNormalTextStyle.copyWith(color: Colors.red),))
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: (){
                  _showInputDialog(context, styleData.expenseTransactionId);
                },
                child: Card(
                  elevation: 0,
                  color: kAppPinkColor.withOpacity(0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    // side: BorderSide(color: Colors.red, width: 1.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        styleData.expensePaid == 0.0 ?Text(
                            'Paid',
                            style: kNormalTextStyle.copyWith( color: kGreenThemeColor)): styleData.expensePaid == false? Text(
                          'Unpaid',
                          style: kNormalTextStyle.copyWith( color: kRedColor),):Container(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Expense Number: ${styleData.expenseTransactionId}',
                              style: kNormalTextStyle.copyWith(fontWeight: FontWeight.bold, color: kBlack),
                            ),
                            Icon(Icons.edit)
                          ],
                        )
                        // TextField(
                        //   decoration: InputDecoration(
                        //     hintText: styleData.invoicedCustomer,
                        //     border: InputBorder.none,
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                ),
              ),
              kLargeHeightSpacing,
              textHeading('Supplier'),
              kSmallHeightSpacing,
              buttonContainer(styleData.expenseSupplier, Icons.arrow_forward_ios, context,
                      () async{
                    final prefs = await SharedPreferences.getInstance();
                    Provider.of<BeauticianData>(context, listen: false).setStoreId(prefs.getString(kStoreIdConstant));

                    showModalBottomSheet(
                        isScrollControlled: true,
                        context: context,
                        builder: (context) {
                          return Container();

                        });
                  }
              ),
              kSmallHeightSpacing,
              _buildDivider(),
              kLargeHeightSpacing,
              textHeading('Expense Date'),

              kSmallHeightSpacing,
              _buildDivider(),
              kLargeHeightSpacing,
              buttonContainer('${DateFormat('d MMM yyy').format(Provider.of<StyleProvider>(context).expenseDate)}', Icons.calendar_month, context,
                      () async{
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
                              body: EditInvoiceCalendarPage());
                        });
                    // Navigator.pushNamed(context, routeName)EditInvoiceCalendarPage();
                  }),
              // kLargeHeightSpacing,
              // buttonContainer('${DateFormat('d MMM yyy').format(styleData.invoicedDate)}', Icons.arrow_forward_ios),
              kLargeHeightSpacing,
              textHeading('Items'),
              kSmallHeightSpacing,
              _buildDivider(),
              kLargeHeightSpacing,
              Card(
                margin: const EdgeInsets.fromLTRB(25.0, 8.0, 25.0, 8.0),
                shape: RoundedRectangleBorder(borderRadius:BorderRadius.circular(10)),
                shadowColor: kAppPinkColor,
                elevation: 3,
                child:     ListView.builder(
                    itemCount: Provider.of<StyleProvider>(context, listen: false).expenseItems.length,
                    shrinkWrap: true,
                    primary: false,
                    physics: NeverScrollableScrollPhysics(),

                    itemBuilder: (context, index){
                      return Column(
                        children: [
                          GestureDetector(
                            onTap:(){
                              showDialog(context: context, builder: (BuildContext context){
                                return CupertinoAlertDialog(
                                  title:Text('Delete Item '),
                                  content: Text('Are you Sure you want to delete ${styleData.expenseItems[index].name}\n'),
                                  actions: [
                                    CupertinoDialogAction(isDestructiveAction: true,
                                        onPressed: (){
                                          // _btnController.reset();
                                          Navigator.pop(context);

                                          // Navigator.pushNamed(context, SuccessPageHiFive.id);
                                        },

                                        child: const Text('Cancel')
                                    ),
                                    CupertinoDialogAction(isDefaultAction: true,
                                      onPressed: (){
                                   //     Provider.of<StyleProvider>(context, listen: false).removeSelectedInvoicedItem(InvoiceItem(name: styleData.invoiceItems[index].name, quantity: styleData.invoiceItems[index].quantity, unitPrice: styleData.invoiceItems[index].unitPrice));

                                        Navigator.pop(context);

                                      }, child: Text('Delete'),)
                                  ],
                                );
                              });
                            },
                            child: ListTile(
                              // leading: Icon(Icons.phone, color: kGreenThemeColor,),
                              title:Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text( "${styleData.expenseItems[index].product}", style: TextStyle(fontWeight:FontWeight.bold,fontFamily: 'Montserrat-Medium',fontSize: 13)),
                                  Text( "${styleData.expenseItems[index].totalPrice}", style: TextStyle(fontFamily: 'Montserrat-Medium',fontSize: 12)),
                                  Text( "${styleData.expenseItems[index].quantity}", style: TextStyle(fontFamily: 'Montserrat-Medium',fontSize: 12)),
                                ],
                              ),
                              trailing: Container(
                                // color: kAppPinkColor,
                                width: 130,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  // crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text( "UGX ${CommonFunctions().formatter.format(styleData.invoiceItems[index].quantity * styleData.invoiceItems[index].unitPrice)}", style: kNormalTextStyle.copyWith(color: kBlack, fontSize: 14, fontWeight: FontWeight.bold)),
                                    Icon(Icons.keyboard_arrow_right),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          _buildDivider(),
                        ],
                      );

                    }

                ),
              ),
              kSmallHeightSpacing,
              GestureDetector(
                onTap: () async {
                  final prefs = await SharedPreferences.getInstance();

                  Provider.of<BeauticianData>(context, listen: false).setStoreId(prefs.getString(kStoreIdConstant));

                  showModalBottomSheet(
                      isScrollControlled: true,
                      context: context,
                      builder: (context) {
                        return Container();
                          // Scaffold(
                          //   appBar: AppBar(
                          //     backgroundColor: kPureWhiteColor,
                          //     automaticallyImplyLeading: false,
                          //     elevation: 0,
                          //   ),
                          //   body: EditInvoiceProductSearch());
                      });
                },
                child: Center(
                  child: Container(
                    width: 200,
                    height: 50,
                    decoration: BoxDecoration(
                      color: kPureWhiteColor,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: kAppPinkColor,
                        width: 1,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Add Item", style: kNormalTextStyle.copyWith(color: kBlueDarkColor),),
                          kMediumWidthSpacing,
                          Icon(Iconsax.tag, size: 20,color: kAppPinkColor,)
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              kLargeHeightSpacing,
              _buildDivider(),
              kLargeHeightSpacing,
              kLargeHeightSpacing,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  textHeading('Total'),
                  textHeading("UGX ${CommonFunctions().formatter.format(styleData.expenseTotalPrice)}")
                ],
              ),

              kSmallHeightSpacing,
              _buildDivider(),
              kLargeHeightSpacing,
              RoundedLoadingButton(
                color: kAppPinkColor,
                child: Text('Update Expense', style: TextStyle(color: Colors.white)),
                controller: _btnController,
                onPressed: () async {
                  var items = [];
                  for(var i = 0; i < Provider.of<StyleProvider>(context, listen: false).invoiceItems.length; i ++){
                    items.add( {
                      'product' : (Provider.of<StyleProvider>(context, listen: false).invoiceItems[i].name),
                      'description':(Provider.of<StyleProvider>(context, listen: false).invoiceItems[i].description),
                      'quantity': (Provider.of<StyleProvider>(context, listen: false).invoiceItems[i].quantity),
                      'totalPrice':(Provider.of<StyleProvider>(context, listen: false).invoiceItems[i].unitPrice)
                    }
                    );
                  }

                  CommonFunctions().updateInvoiceData(styleData.invoiceTransactionId, items, id, styleData.invoicedCustomer,styleData.invoicedExpenseNumber, styleData.customerId, styleData.invoicedDate, styleData.invoicedTotalPrice, context);

                },
              ),

              // Add more widgets for items as needed
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showInputDialog(BuildContext context, String labelText) async {
    String newValue = labelText;
    await showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text('Edit Expense Number'),
          content: CupertinoTextField(
            controller: TextEditingController()..text = labelText,
            onChanged: (value) {
              newValue = value;
            },
            placeholder: 'Enter $labelText',
          ),
          actions: [
            CupertinoDialogAction(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            CupertinoDialogAction(
              child: Text('Save'),
              onPressed: () {
                // You can handle saving the new value here
                id = newValue;
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  Text textHeading(text) {
    return Text(
        text,
        style: kNormalTextStyle.copyWith(color: kBlack, fontWeight: FontWeight.bold)
    );
  }

  buttonContainer(text,icon, context, page ) {

    return GestureDetector(
      onTap: page,
      child: Container(
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(
          color: kPureWhiteColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: kBlueDarkColor,
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(text, style: kNormalTextStyle.copyWith(color: kBlueDarkColor),),
              Icon(icon, size: 20,color: kFaintGrey,)
            ],
          ),
        ),
      ),
    );
  }
  Container _buildDivider(){
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, ),
      width: double.infinity,
      height: 1.0,
      color: Colors.grey[300],

    );
  }
}
