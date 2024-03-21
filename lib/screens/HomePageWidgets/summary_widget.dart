// import 'dart:html';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:iconsax/iconsax.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:pdf/pdf.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
// import 'dart:typed_data';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:flutter/services.dart' show rootBundle;

import 'package:shared_preferences/shared_preferences.dart';
import 'package:stylestore/Utilities/constants/font_constants.dart';
import 'package:stylestore/controllers/transactions_controller.dart';
import 'package:stylestore/screens/Documents_Pages/dummy_document.dart';
import 'package:stylestore/screens/edit_invoice_pages/edit_invoice.dart';
import 'package:stylestore/model/common_functions.dart';
import 'package:stylestore/model/styleapp_data.dart';
import 'package:stylestore/screens/Messages/message.dart';
import 'package:stylestore/utilities/constants/user_constants.dart';
import 'package:stylestore/utilities/constants/word_constants.dart';
import 'package:stylestore/widgets/TicketDots.dart';
import 'package:stylestore/screens/payment_pages/record_payment_widget.dart';
import '../../Utilities/constants/color_constants.dart';
import '../../model/pdf_files/invoice.dart';
import '../../model/pdf_files/invoice_customer.dart';
import '../../model/pdf_files/invoice_supplier.dart';
import '../../model/pdf_files/pdf_api.dart';
import '../../model/pdf_files/pdf_invoice_api.dart';
import '../../widgets/locked_widget.dart';
import '../../widgets/modalButton.dart';

class SummaryPage extends StatefulWidget {
  static String id = 'summary';

  @override
  _SummaryPageState createState() => _SummaryPageState();
}

class _SummaryPageState extends State<SummaryPage> {
  late int price = 0;
  late int quantity = 1;
  DateTime? _previousDate;
  var storeName = "";
  var location = "";
  var phoneNumber = "";
  var formatter = NumberFormat('#,###,000');
  var dateSeparator = '';
  var logo = '';
  Map<String, dynamic> permissionsMap = {};

  void defaultInitialization() async {
    var prefs = await SharedPreferences.getInstance();

    permissionsMap = await CommonFunctions().convertPermissionsJson();
    storeName = prefs.getString(kBusinessNameConstant)!;
    location = prefs.getString(kLocationConstant)!;
    phoneNumber = prefs.getString(kPhoneNumberConstant)!;
    logo = prefs.getString(kImageConstant)!;
    print(permissionsMap);

    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    defaultInitialization();
    print(Provider.of<StyleProvider>(context, listen: false).beauticianId);
  }

  var productList = [];
  var orderStatusList = [];
  var clientList = [];
  var smsList = [];
  var customerIdList = [];
  var clientLocationList = [];
  var clientPhoneList = [];
  var paymentDueDateList = [];
  var priceList = [];
  var paidAmountList = [];
  var descList = [];
  var transIdList = [];
  var dateList = [];
  var paidStatusList = [];
  var paidStatusListColor = [];
  List<double> opacityList = [];

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  double textSize = 15.0;
  String fontFamilyMont = 'Montserrat-Medium';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: kPureWhiteColor,
        body: permissionsMap['summary'] == false
            ? LockedWidget(page: "Summary")
            : StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('appointments')
                    .where('beautician_id',
                        isEqualTo:
                            Provider.of<StyleProvider>(context, listen: false)
                                .beauticianId)
                    .orderBy('appointmentDate', descending: true)
                    .limit(4)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (!snapshot.hasData) {
                    return Container();
                  } else {
                    productList = [];
                    orderStatusList = [];
                    priceList = [];
                    descList = [];
                    transIdList = [];
                    dateList = [];
                    paidStatusList = [];
                    paidStatusListColor = [];
                    opacityList = [];
                    clientList = [];
                    clientLocationList = [];
                    paymentDueDateList = [];
                    paidAmountList = [];
                    clientPhoneList = [];
                    smsList = [];
                    customerIdList = [];

                    var orders = snapshot.data?.docs;
                    for (var doc in orders!) {
                      productList.add(doc['items']);
                      priceList.add(doc['totalFee']);
                      descList.add(doc['instructions']);
                      transIdList.add(doc['appointmentId']);
                      orderStatusList.add(doc['status']);
                      dateList.add(doc['appointmentDate'].toDate());
                      clientList.add(doc['client']);
                      clientLocationList.add(doc['clientLocation']);
                      smsList.add(doc['sms']);
                      clientPhoneList.add(doc['clientPhone']);
                      paymentDueDateList.add(doc['payment_date'].toDate());
                      paidAmountList.add(doc['paidAmount']);
                      // Here is where the customer id error is
                      customerIdList.add("doc['customerId']");

                      if (doc['paymentStatus'] == 'Complete') {
                        paidStatusList.add('Paid');
                        paidStatusListColor.add(Colors.red);
                        opacityList.add(0.0);
                      } else if (doc['paymentStatus'] == 'booked') {
                        paidStatusList.add('booked');
                        paidStatusListColor.add(Colors.grey);
                        opacityList.add(1.0);
                      } else {
                        paidStatusList.add('Unpaid');
                        paidStatusListColor.add(Colors.grey);
                        opacityList.add(1.0);
                      }
                      //  }
                    }

                    return Column(
                      children: [
                        kSmallHeightSpacing,
                        productList.length >= 0
                            ? Text(
                                "Last 4 Transactions",
                                style: kNormalTextStyle,
                              )
                            : Text(
                                "No Transactions Today",
                                style: kNormalTextStyle,
                              ),
                        kSmallHeightSpacing,
                        Expanded(
                          child: ListView.builder(
                              itemCount: productList.length,
                              shrinkWrap: true,
                              primary: false,
                              physics: !kIsWeb?NeverScrollableScrollPhysics():ScrollPhysics(),

                              itemBuilder: (context, index) {

                                return GestureDetector(
                                  onTap: () {
                                    Provider.of<StyleProvider>(context,
                                            listen: false)
                                        .clearInvoiceItems();
                                    for (int i = 0;
                                        i < productList[index].length;
                                        i++) {
                                      Provider.of<StyleProvider>(context,
                                              listen: false)
                                          .setInvoiceItems(InvoiceItem(
                                              name: productList[index][i]
                                                  ['product'],
                                              quantity: productList[index]
                                                      [i]['quantity']
                                                  .toDouble(),
                                              unitPrice: productList[index]
                                                      [i]['totalPrice'] /
                                                  1.0,
                                              description:
                                                  productList[index][i]
                                                      ['description']));
                                    }
                                    print(Provider.of<StyleProvider>(
                                            context,
                                            listen: false)
                                        .invoiceItems);

                                    showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return GestureDetector(
                                            onTap: () {
                                              Navigator.pop(context);
                                            },
                                            child: Material(
                                              color: Colors.transparent,
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .center,
                                                children: [
                                                  Card(
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets
                                                              .all(8.0),
                                                      child: Text(
                                                        "${clientList[index]}\n${clientPhoneList[index]}",
                                                        textAlign: TextAlign
                                                            .center,
                                                        style: kNormalTextStyle
                                                            .copyWith(
                                                                color:
                                                                    kBlack),
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
                                                                      paidAmountList[index]
                                                                          .toDouble());
                                                              Provider.of<StyleProvider>(context, listen: false).setInvoicedValues(
                                                                  priceList[
                                                                          index]
                                                                      .toDouble(),
                                                                  paidAmountList[
                                                                          index]
                                                                      .toDouble(),
                                                                  clientList[
                                                                      index],
                                                                  transIdList[
                                                                      index],
                                                                  smsList[
                                                                      index],
                                                                  clientPhoneList[
                                                                      index],
                                                                  dateList[
                                                                      index],
                                                                  priceList[index]
                                                                          .toDouble() -
                                                                      paidAmountList[index]
                                                                          .toDouble(),
                                                                  customerIdList[
                                                                      index]);
                                                              Navigator.pop(
                                                                  context);
                                                              showModalBottomSheet(
                                                                  context:
                                                                      context,
                                                                  isScrollControlled:
                                                                      true,
                                                                  builder:
                                                                      (context) {
                                                                    return Scaffold(
                                                                        appBar:
                                                                            AppBar(
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
                                                                      Iconsax
                                                                          .chart,
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
                                                                  paymentDueDateList[
                                                                      index];

                                                              showModalBottomSheet(
                                                                  context:
                                                                      context,
                                                                  builder:
                                                                      (BuildContext
                                                                          context) {
                                                                    return Container(
                                                                      color:
                                                                          Color(0xFF292929).withOpacity(0.9),
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
                                                                              const SizedBox(height: 16.0),
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
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    );
                                                                  });
                                                            },
                                                            child:
                                                                CircleAvatar(
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
                                                                  index] >=
                                                              priceList[
                                                                  index]
                                                          ? Text(
                                                              "Send Thank You",
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
                                                                .toDouble(),
                                                            paidAmountList[
                                                                    index]
                                                                .toDouble(),
                                                            clientList[
                                                                index],
                                                            transIdList[
                                                                index],
                                                            smsList[index],
                                                            clientPhoneList[
                                                                index],
                                                            dateList[index],
                                                            priceList[index]
                                                                    .toDouble() -
                                                                paidAmountList[
                                                                        index]
                                                                    .toDouble(),
                                                            customerIdList[
                                                                index]);

                                                        Navigator.pop(
                                                            context);

                                                        Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        EditInvoicePage()));
                                                      },
                                                      child: Text(
                                                          "Edit this Transaction",
                                                          style: kNormalTextStyle.copyWith(
                                                              color:
                                                                  kPureWhiteColor,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold)))
                                                ],
                                              ),
                                            ),
                                          );
                                        });
                                  },
                                  child: Card(
                                    margin: const EdgeInsets.fromLTRB(
                                        0.0, 8.0, 0.0, 8.0),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    shadowColor: kAppPinkColor,
                                    elevation: 0.0,
                                    child: Column(
                                      children: [
                                        ListTile(
                                          title: Row(
                                            children: [
                                              priceList[index] !=
                                                      paidAmountList[index]
                                                  ? Icon(
                                                      Icons.flag_circle,
                                                      color: Colors.red,
                                                      size: 15,
                                                    )
                                                  : Icon(
                                                      Icons
                                                          .check_circle_outline,
                                                      color:
                                                          kGreenThemeColor,
                                                      size: 15,
                                                    ),
                                              kSmallWidthSpacing,
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment
                                                        .start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  // priceList[index]!= paidAmountList[index]?Icon(Icons.flag_circle,color: Colors.red, size: 15,):Container(),
                                                  kSmallWidthSpacing,
                                                  Text(
                                                      "${productList[index][0]['product']}",
                                                      overflow:
                                                          TextOverflow.clip,
                                                      style: TextStyle(
                                                          fontFamily:
                                                              fontFamilyMont,
                                                          fontSize: 14)),
                                                  Text(
                                                    clientList[index],
                                                    overflow:
                                                        TextOverflow.fade,
                                                    style: kNormalTextStyle
                                                        .copyWith(
                                                            fontSize: 14,
                                                            color: kBlack),
                                                  ),
                                                  Text(
                                                    '${DateFormat('d/MMM k:mm').format(dateList[index])}',
                                                    style: kNormalTextStyle
                                                        .copyWith(
                                                            fontSize: 12),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          trailing: Padding(
                                            padding: const EdgeInsets.only(
                                                right: 10, top: 10),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                Text(
                                                  "${CommonFunctions().formatter.format(priceList[index])} Ugx",
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 12),
                                                ),
                                                // If price list is not equal to the paid amount
                                                priceList[index] !=
                                                        paidAmountList[
                                                            index]
                                                    ?
                                                    // If the amount paid is not equal to zeto
                                                    paidAmountList[index] !=
                                                            0
                                                        ? paidAmountList[
                                                                    index] >=
                                                                priceList[
                                                                    index]
                                                            ? Text(
                                                                "Overpaid ${CommonFunctions().formatter.format(paidAmountList[index])} Ugx",
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .blue,
                                                                    fontSize:
                                                                        12),
                                                              )
                                                            : Text(
                                                                "${cPartialPayment.tr} ${CommonFunctions().formatter.format(paidAmountList[index])} Ugx",
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .red,
                                                                    fontSize:
                                                                        12),
                                                              )
                                                        : Text(
                                                            cNoPaymentReceived.tr,
                                                            style: TextStyle(
                                                                color:
                                                                    kCustomColorPink,
                                                                fontSize:
                                                                    12),
                                                          )
                                                    : Text(cPaymentReceived,
                                                        style: TextStyle(
                                                            color:
                                                                kGreenThemeColor,
                                                            fontSize: 10))
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                        ),
                        // kSmallHeightSpacing,
                        productList.length >= 4
                            ? GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(
                                      context, TransactionsController.id);
                                },
                                child: Text(
                                  cSeeAllTransactions,
                                  style: kNormalTextStyle.copyWith(
                                      color: Colors.blue),
                                ))
                            : Text(
                                "No Transactions Today",
                                style: kNormalTextStyle,
                              ),
                        // const Text("Today's Last 4 Transactions",style: kNormalTextStyle,),
                      ],
                    );
                  }
                }));
  }

  Widget _buildButton(
      BuildContext context, String title, IconData icon, Function() execute) {
    return GestureDetector(
      onTap: execute,
      child: Column(
        children: [
          TicketDots(
            mainColor: kBlack,
            circleColor: kPureWhiteColor,
          ),
          Row(
            children: [
              Icon(icon),
              kMediumWidthSpacing,
              Text(
                title,
                style: kNormalTextStyle.copyWith(color: kBlack, fontSize: 16),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
