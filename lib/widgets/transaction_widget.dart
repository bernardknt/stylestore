



import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:stylestore/widgets/modalButton.dart';

import '../Utilities/constants/color_constants.dart';
import '../Utilities/constants/font_constants.dart';
import '../model/common_functions.dart';
import '../model/pdf_files/invoice.dart';
import '../model/pdf_files/invoice_customer.dart';
import '../model/pdf_files/invoice_supplier.dart';
import '../model/pdf_files/pdf_api.dart';
import '../model/pdf_files/pdf_invoice_api.dart';
import '../model/styleapp_data.dart';
import '../screens/Messages/message.dart';
import '../screens/edit_invoice_pages/edit_invoice.dart';
import '../screens/payment_pages/record_payment_widget.dart';

class TransactionWidget extends StatelessWidget {
  const TransactionWidget({
    super.key,
    required this.clientList,
    required this.clientPhoneList,
    required this.priceList,
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
              print("This is${phoneNumber[index]}number");
              if (phoneNumber[index]!="0"){
                CommonFunctions().callPhoneNumber(phoneNumber[index]);
              }

            },
            child: SizedBox(
              width: 180,
              child: Card(
                child: Padding(
                  padding:
                  const EdgeInsets
                      .all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      phoneNumber[index]!="0"?Icon(Iconsax.call, size: 20,):Container(),
                      kSmallWidthSpacing,
                      Text(
                        "${clientList[index]}\n${clientPhoneList[index]}",
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
          Center(
              child: Row(
                mainAxisAlignment:
                MainAxisAlignment
                    .center,
                children: [
                  Column(
                    children: [
                      GestureDetector(
                        onTap: () {
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
                                          paidAmountList[index] >= priceList[index]
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
                                                template: InvoiceTemplate(type: 'RECEIPT', salutation: 'TO', totalStatement: "Total Amount Due"),
                                                paid: Receipt(amount: paidAmountList[index] / 1.0));

                                            if(kIsWeb){
                                              print("WEB PDF PRINT ACTIVATED") ;


                                              //final pdfFileWeb = await PdfInvoicePdfHelper.buildWebPdf(invoice, logo, "receipt_${transIdList[index]}", "RECEIPT");
                                              final pdfFile = await PdfInvoicePdfHelper.generateAndDownloadPdf(invoice, "receipt_${transIdList[index]}", logo);




                                            }else{
                                              final pdfFile = await PdfInvoicePdfHelper.generate(invoice, "receipt_${transIdList[index]}", logo);
                                              PdfHelper.openFile(pdfFile);
                                            }
                                          })
                                              : Container(),
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
                                                template: InvoiceTemplate(type: 'Price Qoutation', salutation: 'Quotation to', totalStatement: "Total Amount"),
                                                paid: Receipt(amount: paidAmountList[index] / 1.0));
                                            if(kIsWeb){

                                              final pdfFile = await PdfInvoicePdfHelper.generateAndDownloadPdf(invoice, "quotation_${transIdList[index]}", logo);

                                            }else{
                                              final pdfFile = await PdfInvoicePdfHelper.generate(invoice, "quotation_${transIdList[index]}", logo);
                                              PdfHelper.openFile(pdfFile);
                                            }

                                          }),
                                          kLargeHeightSpacing,
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
                                                template: InvoiceTemplate(type: 'INVOICE', salutation: 'BILL TO', totalStatement: "Total Amount Due"),
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
              )),
          kLargeHeightSpacing,
          kLargeHeightSpacing,
          kLargeHeightSpacing,
          Center(
              child: Column(
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
              )),
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
              child: Text(
                  "Edit this Transaction",
                  style: kNormalTextStyle.copyWith(color: kPureWhiteColor, fontWeight: FontWeight.bold)))
        ],
      ),
    );
  }
}