



import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stylestore/Utilities/constants/user_constants.dart';
import 'package:stylestore/model/print_service.dart';
import 'package:stylestore/model/printing/old_print_code.dart';
import 'package:stylestore/widgets/modalButton.dart';

import '../Utilities/constants/color_constants.dart';
import '../Utilities/constants/font_constants.dart';
import '../controllers/responsive/responsive_page.dart';
import '../model/beautician_data.dart';
import '../model/common_functions.dart';
import '../model/pdf_files/invoice.dart';
import '../model/pdf_files/invoice_customer.dart';
import '../model/pdf_files/invoice_supplier.dart';
import '../model/pdf_files/pdf_api.dart';
import '../model/pdf_files/pdf_invoice_api.dart';
import '../model/styleapp_data.dart';
import '../screens/Messages/message.dart';
import '../screens/customer_pages/customer_transactions.dart';
import '../screens/customer_pages/customer_transactions_web.dart';
import '../screens/edit_invoice_pages/edit_invoice.dart';
import '../screens/payment_pages/record_payment_widget.dart';

class TransactionWidget extends StatelessWidget {
  const TransactionWidget({
    super.key,
    required this.clientList,
    required this.clientPhoneList,
    required this.priceList,
    required this.currency,
    required this.paidAmountList,
    required this.transIdList,
    required this.smsList,
    required this.dateList,
    required this.customerIdList,
    required this.paymentDueDateList,
    required this.storeName,
    required this.location,
    required this.phoneNumber,
    required this.clientLocationList,
    required this.logo,
    required this.index,
    required this.paymentHistory,
  });

  final List clientList;
  final List clientPhoneList;
  final List priceList;
  final List paidAmountList;
  final List transIdList;
  final List smsList;
  final List dateList;
  final List customerIdList;
  final List paymentDueDateList;
  final List currency;
  final List paymentHistory;
  final String storeName;
  final String location;
  final int index;
  final String phoneNumber;
  final List clientLocationList;
  final String logo;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Column(
        mainAxisAlignment:
        MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: (){
              if (phoneNumber[index]!="0"){
                CommonFunctions().callPhoneNumber(phoneNumber[index]);
              }

            },
            child: SizedBox(
              width: 230,
              child: Card(
                child: Padding(
                  padding:
                  const EdgeInsets
                      .all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // phoneNumber[index]!="0"?Icon(Iconsax.call, size: 20,):Container(),
                      kSmallWidthSpacing,
                      Text(
                        "${clientList[index]}\n${clientPhoneList[index]}",
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign
                            .center,
                        style: kNormalTextStyle
                            .copyWith(
                            color:
                            kBlack),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          kLargeHeightSpacing,
          kLargeHeightSpacing,
          kLargeHeightSpacing,
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  GestureDetector(
                    onTap: () async{
                      final prefs = await SharedPreferences.getInstance();
                      String currency = prefs.getString(kCurrency)??"USD";
                      Provider.of<StyleProvider>(context, listen: false).setStoreCurrency(currency);
                      Provider.of<StyleProvider>(
                          context,
                          listen:
                          false)
                          .setInvoicedPriceToPay(priceList[index]
                          .toDouble() -
                          paidAmountList[index].toDouble());
                      Provider.of<StyleProvider>(context, listen: false).setInvoicedValues(
                          priceList[index].toDouble(),
                          paidAmountList[index].toDouble(),
                          clientList[index],
                          transIdList[index],
                          smsList[index],
                          clientPhoneList[index],
                          dateList[index],
                          priceList[index].toDouble() - paidAmountList[index].toDouble(),
                          customerIdList[index]);
                      Navigator.pop(
                          context);
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
                                body:
                                RecordPaymentWidget());
                          });
                    },
                    child:
                    CircleAvatar(
                        backgroundColor:
                        kGreenThemeColor.withOpacity(
                            1),
                        radius:
                        30,
                        child:
                        const Icon(
                          Iconsax.money,
                          color:
                          kPureWhiteColor,
                          size:
                          20,
                        )),
                  ),
                  Text(
                    "Record Payment",
                    style: kNormalTextStyle
                        .copyWith(
                        color:
                        kPureWhiteColor,
                        fontSize:
                        12),
                  )
                ],
              ),
              kMediumWidthSpacing,
              kMediumWidthSpacing,
              kMediumWidthSpacing,
              Column(
                children: [
                  GestureDetector(
                    onTap:
                        () async {
                      final date =
                      dateList[
                      index];
                      final dueDate =
                      paymentDueDateList[index];

                      showModalBottomSheet(
                          context:
                          context,
                          builder:
                              (BuildContext
                          context) {
                            return Container(
                              color:
                              Colors.transparent,
                              child:
                              Container(
                                decoration:
                                BoxDecoration(color: kPureWhiteColor, borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30))),
                                child:
                                Padding(
                                  padding: const EdgeInsets.only(top: 20.0, bottom: 50, left: 20),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      paidAmountList[index] > 0.0
                                          //priceList[index]
                                          ? buildButton(context, 'Receipt', Iconsax.receipt, () async {
                                        Navigator.pop(context);
                                        Navigator.pop(context);
                                        final invoice = Invoice(
                                            supplier: Supplier(
                                              name: storeName,
                                              address: location,
                                              phoneNumber: phoneNumber,
                                              paymentInfo: phoneNumber,
                                            ),
                                            customer: Customer(
                                              name: clientList[index],
                                              address: clientLocationList[index],
                                              phone: clientPhoneList[index],
                                            ),
                                            info: InvoiceInfo(
                                              date: date,
                                              dueDate: dueDate,
                                              description: '',
                                              number: '${transIdList[index]}',
                                            ),
                                            items: Provider.of<StyleProvider>(context, listen: false).invoiceItems,
                                            template: InvoiceTemplate(type: 'RECEIPT', salutation: 'TO', totalStatement: "Total Amount Due", currency: currency[index]),
                                            paid: Receipt(amount: paidAmountList[index] / 1.0));

                                        if(kIsWeb){

                                          final pdfFile = await PdfInvoicePdfHelper.generateAndDownloadPdf(invoice, "receipt_${transIdList[index]}", logo);


                                        }else{
                                          final pdfFile = await PdfInvoicePdfHelper.generate(invoice, "receipt_${transIdList[index]}", logo);
                                          PdfHelper.openFile(pdfFile);
                                        }
                                      })
                                          : Container(),
                                      kSmallHeightSpacing,
                                      paidAmountList[index] >= priceList[index]? kLargeHeightSpacing:
                                      buildButton(context, 'Quotation', Iconsax.paperclip, () async {
                                        Navigator.pop(context);
                                        Navigator.pop(context);

                                        final invoice = Invoice(
                                            supplier: Supplier(
                                              name: storeName,
                                              address: location,
                                              phoneNumber: phoneNumber,
                                              paymentInfo: phoneNumber,
                                            ),
                                            customer: Customer(
                                              name: clientList[index],
                                              address: clientLocationList[index],
                                              phone: clientPhoneList[index],
                                            ),
                                            info: InvoiceInfo(
                                              date: date,
                                              dueDate: dueDate,
                                              description: '',
                                              number: '${transIdList[index]}',
                                            ),
                                            items: Provider.of<StyleProvider>(context, listen: false).invoiceItems,
                                            template: InvoiceTemplate(type: 'QUOTATION', salutation: 'Quotation to', totalStatement: "Total Amount", currency: currency[index]),
                                            paid: Receipt(amount: paidAmountList[index] / 1.0));
                                        if(kIsWeb){

                                          final pdfFile = await PdfInvoicePdfHelper.generateAndDownloadPdf(invoice, "quotation_${transIdList[index]}", logo);

                                        }else{
                                          final pdfFile = await PdfInvoicePdfHelper.generate(invoice, "quotation_${transIdList[index]}", logo);
                                          PdfHelper.openFile(pdfFile);
                                        }

                                      }),
                                      kSmallHeightSpacing,
                                      buildButton(context, 'Invoice', Iconsax.printer, () async {
                                        Navigator.pop(context);
                                        Navigator.pop(context);

                                        final invoice = Invoice(
                                            supplier: Supplier(
                                              name: storeName,
                                              address: location,
                                              phoneNumber: phoneNumber,
                                              paymentInfo: phoneNumber,
                                            ),
                                            customer: Customer(
                                              name: clientList[index],
                                              address: clientLocationList[index],
                                              phone: clientPhoneList[index],
                                            ),
                                            info: InvoiceInfo(
                                              date: date,
                                              dueDate: dueDate,
                                              description: '',
                                              number: '${transIdList[index]}',
                                            ),
                                            items: Provider.of<StyleProvider>(context, listen: false).invoiceItems,
                                            template: InvoiceTemplate(type: 'INVOICE', salutation: 'BILL TO', totalStatement: "Total Amount Due", currency: currency[index]),
                                            paid: Receipt(amount: paidAmountList[index] / 1.0));
                                        if(kIsWeb){

                                          final pdfFile = await PdfInvoicePdfHelper.generateAndDownloadPdf(invoice, "invoice_${transIdList[index]}", logo);

                                        }else{
                                          final pdfFile = await PdfInvoicePdfHelper.generate(invoice, "invoice_${transIdList[index]}", logo);
                                          PdfHelper.openFile(pdfFile);
                                        }

                                      }),





                                    ],
                                  ),
                                ),
                              ),
                            );
                          });
                    },
                    child: CircleAvatar(
                        radius:
                        30,
                        backgroundColor:
                        kCustomColor.withOpacity(
                            1),
                        child:
                        const Icon(
                          Iconsax
                              .printer,
                          color:
                          kBlack,
                          size:
                          20,
                        )),
                  ),
                  Text(
                    "Invoice/ Receipt",
                    style: kNormalTextStyle
                        .copyWith(
                        color:
                        kPureWhiteColor,
                        fontSize:
                        12),
                  )
                ],
              ),
            ],
          ),
          kLargeHeightSpacing,
          kLargeHeightSpacing,
          kLargeHeightSpacing,
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      // Provider.of<StyleProvider>(
                      //     context,
                      //     listen: false).setInvoicedPriceToPay(priceList[index].toDouble() - paidAmountList[index].toDouble());
                      // Provider.of<StyleProvider>(context, listen: false).setInvoicedValues(
                      //     priceList[index].toDouble(), paidAmountList[index].toDouble(), clientList[index],
                      //     transIdList[index], smsList[index], clientPhoneList[index], dateList[index],
                      //     priceList[index].toDouble() - paidAmountList[index].toDouble(),
                      //     customerIdList[index]);

                      // Navigator.pop(context);
                      // Provider.of<BeauticianData>(context, listen: false).setCustomerDetails(clientList[index], phoneNumber[index], [],'{}', "", "", transIdList[index]);
                      // Provider.of<BeauticianData>(context, listen: false).setClientName(clientList[index], transIdList[index]);

                      Provider.of<BeauticianData>(context, listen: false).setCustomerDetails(clientList[index], clientPhoneList[index], '','{}', 'photo',
                          clientLocationList[index], customerIdList[index]);
                      Provider.of<BeauticianData>(context, listen: false).setClientName(clientList[index], customerIdList[index]);

                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SuperResponsiveLayout(mobileBody: CustomerTransactionsProducts(), desktopBody: CustomerTransactionsWeb())),
                      );
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(builder: (context) => SuperResponsiveLayout(mobileBody: CustomerTransactionsProducts(), desktopBody: CustomerTransactionsWeb())),
                      // );
                    },
                    child:
                    CircleAvatar(
                        backgroundColor:
                        kCustomColorPink.withOpacity(
                            1),
                        radius:
                        30,
                        child:
                        const Icon(
                          Iconsax.chart,
                          color:
                          kPureWhiteColor,
                          size:
                          20,
                        )),
                  ),
                  Text(
                    "Buying History",
                    style: kNormalTextStyle
                        .copyWith(
                        color:
                        kPureWhiteColor,
                        fontSize:
                        12),
                  )
                ],
              ),
              kMediumWidthSpacing,
              kMediumWidthSpacing,
              kMediumWidthSpacing,
              Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Provider.of<StyleProvider>(context, listen: false).setInvoicedPriceToPay(priceList[index]
                              .toDouble() -
                              paidAmountList[index].toDouble());
                          Provider.of<StyleProvider>(context, listen: false).setInvoicedValues(
                              priceList[index].toDouble(),
                              paidAmountList[index].toDouble(),
                              clientList[index],
                              transIdList[index],
                              smsList[index],
                              clientPhoneList[index],
                              dateList[index],
                              priceList[index].toDouble() - paidAmountList[index].toDouble(),
                              customerIdList[index]);
                          Navigator.pop(context);

                          showModalBottomSheet(context: context,
                              isScrollControlled: true,
                              builder:
                                  (context) {return Scaffold(
                                  appBar:
                                  AppBar(
                                    automaticallyImplyLeading: false,
                                    elevation: 0,
                                    backgroundColor:
                                    kPureWhiteColor,
                                  ),
                                  body:
                                  MessagesPage());
                              });
                        },
                        child: CircleAvatar(
                            backgroundColor:
                            kBiegeThemeColor
                                .withOpacity(
                                1),
                            radius: 30,
                            child:
                            const Icon(
                              Iconsax
                                  .message,
                              color: kBlack,
                              size: 20,
                            )),
                      ),
                      paidAmountList[
                      index] >= priceList[index] ? Text("Send Thank You",
                        style: kNormalTextStyle
                            .copyWith(
                            color:
                            kPureWhiteColor,
                            fontSize:
                            12),
                      )
                          : Text(
                        "Send Reminder",
                        style: kNormalTextStyle
                            .copyWith(
                            color:
                            kPureWhiteColor,
                            fontSize:
                            12),
                      )
                    ],
                  ),
            ],
          ),
          kLargeHeightSpacing,
          kLargeHeightSpacing,
          kLargeHeightSpacing,
          kLargeHeightSpacing,
          kLargeHeightSpacing,
          kLargeHeightSpacing,
          kLargeHeightSpacing,
          kLargeHeightSpacing,
          TextButton(
              onPressed: () {
                Provider.of<StyleProvider>(context, listen: false).setInvoicedValues(
                    priceList[index]
                        .toDouble(), paidAmountList[index]
                        .toDouble(),
                    clientList[index], transIdList[index], smsList[index],
                    clientPhoneList[index], dateList[index], priceList[index].toDouble() -
                    paidAmountList[index].toDouble(),
                    customerIdList[index]);

                Navigator.pop(context);

                Navigator.push(context, MaterialPageRoute(builder:
                            (context) =>
                            EditInvoicePage()));
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                      backgroundColor: kPureWhiteColor,
                      child: Icon(CupertinoIcons.pencil, color: kBlack,)),
                  kMediumWidthSpacing,
                  Text(
                      "Edit Transaction",
                      style: kNormalTextStyle.copyWith(color: kPureWhiteColor, fontWeight: FontWeight.bold)),
                ],
              )),
          // kLargeHeightSpacing,
          // TextButton(onPressed: (){
          //
          //   PrintService().printNew(context);
          //
          //   // Navigator.pushNamed(context, BluetoothPage.id);
          //
          // }, child: Text("Print", style: kNormalTextStyle.copyWith(color: kPureWhiteColor),))
        ],
      ),
    );
  }
}