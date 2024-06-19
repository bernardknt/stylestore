import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart'; // Add this import for date formatting
import 'package:provider/provider.dart';
import 'package:stylestore/Utilities/constants/color_constants.dart';
import 'package:stylestore/Utilities/constants/font_constants.dart';
import 'package:stylestore/model/Payments.dart';
import 'package:stylestore/model/common_functions.dart';
import 'package:stylestore/model/styleapp_data.dart';
import 'package:stylestore/utilities/constants/icon_constants.dart';

import '../../model/pdf_files/invoice.dart';
import '../../model/pdf_files/invoice_confirmation.dart';
import '../../model/pdf_files/invoice_customer.dart';
import '../../model/pdf_files/invoice_supplier.dart';
import '../../model/pdf_files/pdf_api.dart';
import '../../model/pdf_files/pdf_invoice_api.dart';
import '../MobileMoneyPages/make_custom_mobile_money_payment.dart';
import '../MobileMoneyPages/make_payment_page.dart';
import '../MobileMoneyPages/mm_payment_button_widget.dart';
import '../MobileMoneyPages/mm_payment_processing_widget.dart';

class PaymentPage extends StatefulWidget {
  final String transactionId;
  static String id = "payments_page";

  PaymentPage({required this.transactionId});

  @override
  State<PaymentPage> createState() => _PaymentPageState();

}

String countryCode = "+256";
String country = "Uganda";
String phoneNumber = "";
String transactionId = 'invoicePay${uuid.v1().split("-")[0]}';
TextEditingController phoneController = TextEditingController();

CollectionReference paymentTransactions = FirebaseFirestore.instance.collection('transactions');
Future<void> addMobileMoneyTransaction(String name,String amount, String amountToCharge, String orderId, String email,storeId, purpose, currency, context ) {

  return paymentTransactions.doc(transactionId).set({
    'name': name,
    'amount_paid': amount, // John DoeStr
    'beyonic_charge': amountToCharge,
    'collectionID':0,
    'number': '256$phoneNumber',
    'payment_status': false,
    'currency': currency,
    'storeId': storeId,// John Doe
    'date': DateTime.now(), // Stokes and Sons
    'purpose': purpose,
    'uniqueID': orderId,
    'testID': transactionId,
    'email': email,
  })
      .then((value){
    print('Nice');
  })
      .catchError((error){
    CoolAlert.show(
        lottieAsset: 'images/pourJuice.json',
        context: context,
        type: CoolAlertType.success,
        text: "Your Payment was unsuccessfully",
        title: "No Payment Made",
        confirmBtnText: 'Ok 👍',
        confirmBtnColor: kGreenJavasThemeColor,
        backgroundColor: kBlueDarkColor
    );
  });
}

class _PaymentPageState extends State<PaymentPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPlainBackground,

      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('appointments').doc(widget.transactionId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text('Invoice not found'));
          }

          final product = Payments.fromFirestore(snapshot.data!);
          phoneController.text = CommonFunctions().processPhoneNumber(product.clientPhone, "+256");
          double balance = product.totalFee - product.paidAmount;

          return balance != 0
              ? SingleChildScrollView(
            child: Center(
              child: Container(
                width: 500,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: kPureWhiteColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Text(
                                product.storeName,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              kSmallHeightSpacing,
                              CircleAvatar(
                                radius: 30,
                                child: Icon(kIconTransaction),
                              ),
                              kSmallHeightSpacing,
                              Text(
                                'Bill To',
                                style: kNormalTextStyle,
                              ),
                              kSmallHeightSpacing,
                              Text(
                                product.client,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              kSmallHeightSpacing,
                              product.history.length == 0
                                  ? SizedBox()
                                  : Text(
                                "(Invoiced: ${product.currency} ${CommonFunctions().formatter.format(product.totalFee)} | Paid: ${product.currency} ${CommonFunctions().formatter.format(product.totalFee - balance)})",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              kSmallHeightSpacing,
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: kPlainBackground,
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        '${product.currency}',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  kMediumWidthSpacing,
                                  Text(
                                    '${CommonFunctions().formatter.format(balance)}',
                                    style: TextStyle(
                                      fontSize: 40,
                                      fontWeight: FontWeight.bold,
                                      color: kGreenThemeColor,
                                    ),
                                  ),
                                ],
                              ),
                              kLargeHeightSpacing,
                              Text(
                                'Payment for Invoice ${product.id}',
                                style: kNormalTextStyle,
                              ),
                              kLargeHeightSpacing,
                              Container(
                                decoration: BoxDecoration(
                                  color: kPlainBackground,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: ListView.builder(
                                  shrinkWrap: true, // This is necessary to make ListView work within SingleChildScrollView
                                  physics: NeverScrollableScrollPhysics(), // Disable scrolling for ListView as SingleChildScrollView will handle it
                                  itemCount: product.items.length,
                                  itemBuilder: (context, index) {
                                    final item = product.items[index];
                                    return ListTile(
                                      title: Text(
                                        '${item['product']} x ${item['quantity']}',
                                        style: kNormalTextStyle.copyWith(
                                          color: kBlack,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      trailing: Text(
                                        '${product.currency} ${CommonFunctions().formatter.format(item['totalPrice'] * item['quantity'])}',
                                        style: kNormalTextStyle.copyWith(
                                          color: kBlack,
                                          fontSize: 12,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              kSmallHeightSpacing,
                              product.history.length == 0
                                  ? SizedBox()
                                  : Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    "Payment History",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: kFontGreyColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  ListView.builder(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemCount: product.history.length,
                                    itemBuilder: (context, index) {
                                      final historyItem = product.history[index];
                                      final parts = historyItem.split(RegExp(r'[?:]'));
                                      final amount = parts[0];
                                      final method = parts[1];
                                      final dateTime = DateTime.parse(parts[2]);
                                      final formattedDate = DateFormat('MMMM d, yyyy').format(dateTime);
                                      final formattedTime = DateFormat('HH:mm').format(dateTime);
                                      return ListTile(
                                        title: Text(
                                          '${index + 1}. ${product.currency} ${CommonFunctions().formatter.format(double.parse(amount))} paid using $method on $formattedDate at $formattedTime',
                                          style: kNormalTextStyle.copyWith(
                                            // color: kBlack,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                              kLargeHeightSpacing,
                              Padding(
                                padding: const EdgeInsets.only(left: 50, right: 50, top: 10, bottom: 8),
                                child: Container(
                                  height: 53,
                                  decoration: BoxDecoration(
                                    border: Border.all(width: 1, color: kBlack),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Container(
                                        height: 50,
                                        width: 70,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Center(
                                          child: Text(
                                            "+256",
                                            style: kNormalTextStyle.copyWith(color: kBlack, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                      Text(
                                        "|",
                                        style: TextStyle(fontSize: 25, color: kAppPinkColor),
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Expanded(
                                        child: TextFormField(
                                          controller: phoneController,
                                          style: kNormalTextStyle.copyWith(color: kBlack),
                                          validator: (value) {
                                            List letters = List<String>.generate(value!.length, (index) => value[index]);
                                            print(letters);

                                            if (value != null && value.length > 10) {
                                              return 'Number is too long';
                                            } else if (value == "") {
                                              return 'Enter phone number';
                                            } else if (letters[0] == '0') {
                                              return 'Number cannot start with a 0';
                                            } else if (value != null && value.length < 9) {
                                              return 'Number short';
                                            } else {
                                              return null;
                                            }
                                          },
                                          onChanged: (value) {
                                            phoneNumber = value;
                                          },
                                          keyboardType: TextInputType.phone,
                                          decoration: InputDecoration(
                                            border: InputBorder.none,
                                            hintText: "77000000",
                                            hintStyle: kNormalTextStyle.copyWith(color: Colors.grey[500]),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              kLargeHeightSpacing,
                              ElevatedButton(
                                onPressed: () async{
                                  String orderId = product.id + transactionId;
                                  // Navigator.pushNamed(context, InvoiceConfirmation.id);
                                  Navigator.push(context, MaterialPageRoute(builder: (context)=> InvoiceConfirmation(product: product)));
                                  Provider.of<StyleProvider>(context, listen: false).setOrderId(orderId);
                                  showModalBottomSheet(context: context, builder: (context) => Container(
                                    padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                                    child: PaymentProcessing(),
                                  ));
                                  String number = '256$phoneNumber';
                                  String amountToCharge = (balance*1.01).toString();
                                  dynamic resp = await CommonFunctions().callableBeyonicPayment.call(<String, dynamic>{
                                    'number': number,
                                    'amount':amountToCharge,
                                    'transId': transactionId
                                    // orderId
                                  });


                                  addMobileMoneyTransaction(product.client, balance.toString(), amountToCharge, orderId, product.id, product.storeId,"Invoice Payment",product.currency, context);
                                },
                                child: Text(
                                  'Pay ${product.currency} ${CommonFunctions().formatter.format(balance)}',
                                  style: kNormalTextStyle.copyWith(color: kPureWhiteColor),
                                ),
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(horizontal: 80, vertical: 16),
                                  backgroundColor: kAppPinkColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                              kLargeHeightSpacing,
                              Opacity(
                                opacity: 0.5,
                                child: Image.asset("images/airtelMtn.png", height: 60, width: 60),
                              ),
                              Text(
                                "Powered by Business Pilot",
                                style: kNormalTextStyle.copyWith(fontWeight: FontWeight.w400, fontSize: 10),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ):Center(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  height: 400,
                  width: 300,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 30,
                        child: Icon(kIconTransaction),
                      ),
                      kSmallHeightSpacing,
                      Text(product.storeName, style: kNormalTextStyle.copyWith(fontSize: 15, color: kBlack, fontWeight: FontWeight.bold),),
                      kLargeHeightSpacing,
                      Text(product.client, style: kNormalTextStyle.copyWith(fontSize: 30, color: kBlack),),
                      kSmallHeightSpacing,
                      Text("This invoice is fully paid", style: kNormalTextStyle.copyWith(fontSize: 16),),
                      kLargeHeightSpacing,
                      Icon(Icons.check_circle,
                          size: 100, color: Colors.green),
                      kLargeHeightSpacing,
                      MobileMoneyPaymentButton(
                        firstButtonFunction: () async{
                          final invoice = Invoice(
                              supplier: Supplier(
                                name: product.storeName,//storeName,
                                address: product.storeLocation,//location,
                                phoneNumber:product.storePhone,//phoneNumber,
                                paymentInfo: product.storePhone,//phoneNumber,
                              ),
                              customer: Customer(
                                name: product.client,//clientList[index],
                                address: product.clientLocation,//clientLocationList[index],
                                phone: product.clientPhone,// clientPhoneList[index],
                              ),
                              info: InvoiceInfo(
                                date: DateTime.now(),
                                dueDate: DateTime.now(),
                                description: '',
                                number: product.id,
                              ),
                              items:
                              product.items.map<InvoiceItem>((item) {
                                return InvoiceItem(
                                  name: item['product'],
                                  quantity: item['quantity'],
                                  unitPrice: item['totalPrice'],
                                );
                              }).toList(),

                              // [InvoiceItem(name: "Books", quantity: 10, unitPrice: 1000)]

                              template: InvoiceTemplate(type: 'RECEIPT', salutation: 'TO', totalStatement: "Total Amount Due", currency: product.currency),
                              paid: Receipt(amount: product.totalFee / 1.0));

                          if(kIsWeb){

                            final pdfFile = await PdfInvoicePdfHelper.generateAndDownloadPdfForWeb(invoice, "receipt_${product.id}", "https://mcusercontent.com/f78a91485e657cda2c219f659/images/7e5d9ad3-e663-11d4-bb3e-96678f9428ec.png");

                          }else{
                            CommonFunctions().showSuccessNotification("Generating Receipt", context);
                            final pdfFile = await PdfInvoicePdfHelper.generatePdfForMobileDevices(invoice, "receipt_${product.id}", "logo");

                            PdfHelper.openFile(pdfFile);
                          }
                        },
                        firstButtonText: 'Download Receipt',
                        buttonTextColor: kPureWhiteColor,
                        lineIconFirstButton: Iconsax.receipt,
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}