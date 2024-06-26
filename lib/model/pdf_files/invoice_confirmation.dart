import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stylestore/model/common_functions.dart';
import 'package:stylestore/model/pdf_files/invoice_supplier.dart';
import 'package:stylestore/model/pdf_files/pdf_api.dart';
import 'package:stylestore/model/pdf_files/pdf_invoice_api.dart';
import '../../Utilities/constants/color_constants.dart';
import '../../Utilities/constants/font_constants.dart';

import '../../model/styleapp_data.dart';
import '../../screens/MobileMoneyPages/mm_payment_button_widget.dart';


import '../Payments.dart';
import 'invoice.dart';
import 'invoice_customer.dart';

class InvoiceConfirmation extends StatefulWidget {
  static String id = 'invoice_confirmation_payment_page';
  final Payments product;

  InvoiceConfirmation({required this.product});

  @override
  _InvoiceConfirmationState createState() => _InvoiceConfirmationState();
}

class _InvoiceConfirmationState extends State<InvoiceConfirmation> {
  bool receiptButtonDisplayed = false;

  Stream<DocumentSnapshot> _paymentStatusStream(String orderId) {
    return FirebaseFirestore.instance
        .collection('transactions')
        .doc(orderId)
        .snapshots();
  }

  void _setDisplayReceiptButton(BuildContext context) {
    // Use a post frame callback to update the state after the build method is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!receiptButtonDisplayed) {
        setState(() {
          receiptButtonDisplayed = true;
        });
        Provider.of<StyleProvider>(context, listen: false)
            .setDisplayReceiptButton(true);
      }
    });
  }

  defaultInitialization(){

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                kIsWeb
                    ? Icon(
                  Iconsax.money,
                  size: 30,
                  color: kAppPinkColor,
                )
                    : Lottie.asset('images/mailtime.json',
                    height: 150, width: 150, fit: BoxFit.cover),
                kSmallHeightSpacing,
                Center(
                    child: Provider.of<StyleProvider>(context).displayInvoiceReceiptButton ==
                        true?Text("Congratulations"):Text(
                        Provider.of<StyleProvider>(context)
                            .pendingPaymentStatement,
                        textAlign: TextAlign.center,
                        style: kNormalTextStyle)),
                kSmallHeightSpacing,
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('transactions')
                      .where('payment_status', isEqualTo: true)
                      .where('uniqueID',
                      isEqualTo: Provider.of<StyleProvider>(context)
                          .orderId)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return kIsWeb
                          ? Icon(Iconsax.activity1)
                          : Lottie.asset('images/loading.json',
                          height: 50, width: 150);
                    } else if (!snapshot.hasData) {
                      return kIsWeb
                          ? Icon(Iconsax.activity1)
                          : Lottie.asset('images/loading.json',
                          height: 50, width: 150);
                    } else if (snapshot.hasData) {
                      var orders = snapshot.data?.docs;
                      if (orders?.length == 0) {
                        return Column(
                          children: [
                            Text(
                              "Waiting for Payment Confirmation",
                              textAlign: TextAlign.center,
                              style: kNormalTextStyle.copyWith(
                                  color: kBlack, fontSize: 26),
                            ),
                            Icon(Icons.downloading,
                                size: 50, color: Colors.red),
                          ],
                        );
                      } else {
                        if (!receiptButtonDisplayed) {
                          _setDisplayReceiptButton(context);
                        }
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Payment Received",
                              textAlign: TextAlign.center,
                              style: kNormalTextStyle.copyWith(
                                  color: kBlack, fontSize: 26),
                            ),
                            Icon(Icons.check_circle,
                                size: 100, color: Colors.green),
                          ],
                        );
                      }
                    } else {
                      return Text("Please check your internet Connection", textAlign: TextAlign.center,);
                    }
                  },
                ),
                kLargeHeightSpacing,
                kLargeHeightSpacing,
                kLargeHeightSpacing,
                Provider.of<StyleProvider>(context).displayInvoiceReceiptButton ==
                    true
                    ?
                MobileMoneyPaymentButton(
                  firstButtonFunction: () async{
                    final invoice = Invoice(
                        supplier: Supplier(
                          name: widget.product.storeName,//storeName,
                          address: widget.product.storeLocation,//location,
                          phoneNumber:widget.product.storePhone,//phoneNumber,
                          paymentInfo: widget.product.storePhone,//phoneNumber,
                        ),
                        customer: Customer(
                          name: widget.product.client,//clientList[index],
                          address: widget.product.clientLocation,//clientLocationList[index],
                          phone: widget.product.clientPhone,// clientPhoneList[index],
                        ),
                        info: InvoiceInfo(
                          date: DateTime.now(),
                          dueDate: DateTime.now(),
                          description: '',
                          number: widget.product.id,
                        ),
                        items:
                        widget.product.items.map<InvoiceItem>((item) {
                          return InvoiceItem(
                            name: item['product'],
                            quantity: item['quantity'],
                            unitPrice: item['totalPrice'],
                          );
                        }).toList(),

                        // [InvoiceItem(name: "Books", quantity: 10, unitPrice: 1000)]

                        template: InvoiceTemplate(type: 'RECEIPT', salutation: 'TO', totalStatement: "Total Amount Due", currency: widget.product.currency),
                        paid: Receipt(amount: widget.product.totalFee / 1.0));

                    if(kIsWeb){

                      final pdfFile = await PdfInvoicePdfHelper.generateAndDownloadPdfForWeb(invoice, "receipt_${widget.product.id}", "https://mcusercontent.com/f78a91485e657cda2c219f659/images/7e5d9ad3-e663-11d4-bb3e-96678f9428ec.png");

                    }else{
                      CommonFunctions().showSuccessNotification("Generating Receipt", context);
                      final pdfFile = await PdfInvoicePdfHelper.generatePdfForMobileDevices(invoice, "receipt_${widget.product.id}", "logo");

                      PdfHelper.openFile(pdfFile);
                    }
                  },
                  firstButtonText: 'Download Receipt',
                  buttonTextColor: kPureWhiteColor,
                  lineIconFirstButton: Iconsax.receipt,
                )
                    : Text("...Complete Payment..."),
                kLargeHeightSpacing,
                TextButton(onPressed: (){
                  Navigator.pop(context);
                  // Navigator.pushNamed(context, '/#payment/${widget.product.id}');
                }, child: Text("Go Back"))
              ],
            ),
          ),
        ),
      ),
    );
  }
}