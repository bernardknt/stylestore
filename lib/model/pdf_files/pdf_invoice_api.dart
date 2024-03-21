import 'dart:io';
// import 'dart:js';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:stylestore/model/common_functions.dart';
import 'package:stylestore/model/pdf_files/pdf_api.dart';
import '../../screens/Documents_Pages/dummy_document.dart';
import 'invoice.dart';
import 'invoice_customer.dart';
import 'invoice_supplier.dart';
import 'invoice_utils.dart';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'dart:html' as html;
import 'dart:convert';
// import 'package:js/js.dart';



class PdfInvoicePdfHelper {

// Function to download and save the logo image
  Future<Uint8List> _fetchLogoBytes(String imageUrl) async {
    final response = await http.get(Uri.parse(imageUrl));
    if (response.statusCode == 200) {
      final Uint8List bytes = response.bodyBytes;
      final String dir = (await getTemporaryDirectory()).path;
      final String path = '$dir/logo.png';
      File(path).writeAsBytesSync(bytes);
      return bytes;
    }
    throw Exception('Failed to fetch logo image');
  }

static testWebPdf ()async{
   final data = CustomData(name: 'Alice');
   final pdfFile = await generateDocument(PdfPageFormat.a4, data);

   // Decide what to do with the pdfFile (example: save to file system)
   final pathProvider = await getTemporaryDirectory();
   final file = File('${pathProvider.path}/sample.pdf');
   await file.writeAsBytes(pdfFile);
  }

  static Future<File> generate(Invoice invoice, String pdfFileName, String logo) async {


    final pdf = Document();
    final imagePng = (await rootBundle.load("images/paid.png")).buffer.asUint8List();
    final Uint8List logoBytes = await CommonFunctions().fetchLogoBytes(logo);

    // final response = await http.get(Uri.parse(logo));


    pdf.addPage(MultiPage(
      build: (context) => [
        // Image(MemoryImage(response.bodyBytes)),


        pw.Image(MemoryImage(logoBytes), height: 70, alignment: Alignment.centerRight),


        buildHeader(invoice),
        SizedBox(height: 2 * PdfPageFormat.cm),
        buildTitle(invoice),
        buildInvoice(invoice),
        Divider(),
        pw.Stack(children: [
          buildTotal(invoice),
          pw.Positioned(bottom: 0,
              left:0,
              child: invoice.paid.amount > 0 && invoice.template.type == "RECEIPT"?
              pw.Image(MemoryImage(imagePng), height: 100, alignment: Alignment.centerRight)
                  : pw.Container()

          )

        ]),


      ],

      footer: (context) => buildFooter(invoice),
    ));
    return PdfHelper.saveDocument(name: pdfFileName, pdf: pdf);
  }

  static Future<void> generateAndDownloadPdf(Invoice invoice, String pdfFileName, String logo) async {


    final pdf = Document();
    final imagePng = (await rootBundle.load("images/paid.png")).buffer.asUint8List();
    //final Uint8List logoBytes = await CommonFunctions().fetchLogoBytes(logo);
    final Uint8List logoBytes = (await rootBundle.load("images/okola_logo.png")).buffer.asUint8List();


    // ... (Rest of your PDF generation logic) ...
    pdf.addPage(MultiPage(
      build: (context) => [
        Image(MemoryImage(logoBytes), height: 70, alignment: Alignment.centerRight),
        buildHeader(invoice), // Your header building logic
        SizedBox(height: 2 * PdfPageFormat.cm),
        buildTitle(invoice), // Your title building logic
        buildInvoice(invoice), // Your invoice details building logic
        Divider(),
        Stack(children: [
          buildTotal(invoice), // Your total building logic
          Positioned(bottom: 0,
              left:0,
              child: invoice.paid.amount > 0 && invoice.template.type == "RECEIPT"?
              Image(MemoryImage(imagePng), height: 100, alignment: Alignment.centerRight)
                  : Container()

          )

        ]),
      ],
      footer: (context) => buildFooter(invoice), // Your footer building logic
    ));

    // Generate PDF data in-memory
    final pdfData = await pdf.save();

    // Create a Blob for download
    final blob = html.Blob([pdfData], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement()
      ..href = url
      ..style.display = 'none'
      ..download = pdfFileName;
    html.document.body!.children.add(anchor);

    // Trigger download
    anchor.click();

    // Cleanup
    html.document.body!.children.remove(anchor);
    html.Url.revokeObjectUrl(url);
  }

  // static Future<void> webPDFdownload ()async{
  //   // Here you'd need logic to generate the PDF data as bytes
  //   // Let's assume you have it in a variable called 'pdfData'
  //   final blob = html.Blob([pdfData]);
  //   final url = html.Url.createObjectUrlFromBlob(blob);
  //   final anchor = html.document.createElement('a') as html.AnchorElement
  //     ..href = url
  //     ..style.display = 'none'
  //     ..download = 'generated_document.pdf';
  //   html.document.body!.children.add(anchor);
  //
  //   // Download starts automatically
  //   anchor.click();
  //
  //   // Cleanup
  //   html.document.body!.children.remove(anchor);
  //   html.Url.revokeObjectUrl(url);
  // }

  static Future<void >buildWebPdf (Invoice invoice, String logoUrl, String invoiceNumber, String type)async{
    // final url = Uri.parse('https://us-central1-doctor-booking-aa868.cloudfunctions.net/generatePDF'); // Replace with your function URL
    // try {
    //   final response = await http.post(url, body: {
    //     'invoiceData': jsonEncode(invoice.toJson()), // Serialize your invoice object
    //     'imageUrl': logoUrl,
    //     'invoiceNumber': invoiceNumber,
    //     'type': type
    //   });
    //   if (response.statusCode == 200) {
    //     print("HURAAAY a response was received");
    //     // Handle the PDF file (response.bodyBytes) - example: download it
    //     // Remember to uncomment dart.js
    //    // context.callMethod('download', [response.bodyBytes, '$invoiceNumber.pdf']);
    //     @JS('download')
    //     void download(dynamic data, String filename){
    //     }
    //   } else {
    //     // Handle PDF generation error
    //   }
    // }catch(error) {
    //   print("THIS IS THE ERROR: $error");
    // }
  }

  static Widget buildHeader(Invoice invoice) => Column(


    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(height: 1 * PdfPageFormat.cm),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          buildSupplierAddress(invoice.supplier),

        ],
      ),
      SizedBox(height: 1 * PdfPageFormat.cm),
      Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          buildCustomerAddress(invoice.customer, invoice.template),
          buildInvoiceInfo(invoice.info),
        ],
      ),
    ],
  );

  static Widget buildCustomerAddress(Customer customer, InvoiceTemplate template) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(template.salutation), // BILL TO
      Text(customer.name, style: TextStyle(fontWeight: FontWeight.bold)),
      Text(customer.address),
      Text(customer.phone),
    ],
  );

  static Widget buildInvoiceInfo(InvoiceInfo info) {
    final paymentTerms = '${info.dueDate.difference(info.date).inDays} days';
    final titles = <String>[
      'Invoice Number:',
      'Invoice Date:',
      'Payment Terms:',
      'Due Date:'
    ];
    final data = <String>[
      info.number,
      Utils.formatDate(info.date),
      paymentTerms,
      Utils.formatDate(info.dueDate),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(titles.length, (index) {
        final title = titles[index];
        final value = data[index];

        return buildText(title: title, value: value, width: 200);
      }),
    );
  }

  static Widget buildSupplierAddress(Supplier supplier) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(supplier.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
      SizedBox(height: 1 * PdfPageFormat.mm),
      Text(supplier.address),
      Text(supplier.phoneNumber),
    ],
  );

  static Widget buildTitle(Invoice invoice) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        invoice.template.type, // INVOICE
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
      SizedBox(height: 0.8 * PdfPageFormat.cm),
      Text(invoice.info.description),
      SizedBox(height: 0.8 * PdfPageFormat.cm),
    ],
  );

  static Widget buildInvoice(Invoice invoice) {
    final headers = [
      'Item',
      'Details',
      'Quantity',
      'Price',
      // 'VAT',
      'Amount'
    ];
    final data = invoice.items.map((item) {
      // final total = item.unitPrice * item.quantity * (1 + item.vat);
      final total = item.unitPrice * item.quantity ;

      return [
        item.name,
        item.name,
        // item.formatDate(item.date),
        '${item.quantity.toStringAsFixed(0)}',
        '${item.unitPrice}',
        // '${item.vat} %',
        'Ugx ${total.toStringAsFixed(0)}',
      ];
    }).toList();

    return Table.fromTextArray(
      headers: headers,
      data: data,
      border: null,
      headerStyle: TextStyle(fontWeight: FontWeight.bold),
      headerDecoration: const BoxDecoration(color: PdfColors.grey300),
      cellHeight: 30,
      cellAlignments: {
        0: Alignment.centerLeft,
        1: Alignment.centerRight,
        2: Alignment.centerRight,
        3: Alignment.centerRight,
        4: Alignment.centerRight,
        5: Alignment.centerRight,
      },
    );
  }

  static Widget buildTotal(Invoice invoice) {
    final receiptAmount = invoice.paid.amount;
    // final netTotal = invoice.items
    //     .map((item) => (item.unitPrice * item.quantity))
    //     .fold<double>(0.0, (previousValue, item) => (previousValue as double) + item)  - receiptAmount;

    // final netTotal = invoice.items
    //     .map((item) => (item.unitPrice * item.quantity) - receiptAmount)
    //     .fold(0.0, (previousValue, item) => (previousValue ?? 0.0) + item);
    final netTotal = invoice.items
        .map((item) => (item.unitPrice * item.quantity) )
        .reduce((item1, item2) => item1 + item2) - receiptAmount;
    // final billTotal = invoice.items
    //     .map((item) => (item.unitPrice * item.quantity))
    //     .fold<double>(0.0, (previousValue, item) => (previousValue as double) + item);

    final billTotal = invoice.items
        .map((item) => item.unitPrice * item.quantity)
        .reduce((item1, item2) => item1 + item2);

    // final vatPercent = invoice.items.first.vat;
    // final vat = netTotal * vatPercent;
    // final total = netTotal + vat;
    final total = netTotal;

    return
      receiptAmount != 0.0 ?
      Container(
      alignment: Alignment.centerRight,
      child: Row(
        children: [
          Spacer(flex: 6),
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildText(
                  title: 'Total',
                  value: Utils.formatPrice(billTotal),
                  unite: true,
                ),
                Divider(),
                buildText(
                  title: invoice.template.totalStatement,
                  titleStyle: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  value: Utils.formatPrice(total),
                  unite: true,
                ),
                SizedBox(height: 2 * PdfPageFormat.mm),
                Container(height: 1, color: PdfColors.grey400),
                SizedBox(height: 0.5 * PdfPageFormat.mm),
                Container(height: 1, color: PdfColors.grey400),
              ],
            ),
          ),
        ],
      ),
    ):
      Container(
        alignment: Alignment.centerRight,
        child: Row(
          children: [
            Spacer(flex: 6),
            Expanded(
              flex: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildText(
                    title: 'Total',
                    value: Utils.formatPrice(netTotal),
                    unite: true,
                  ),
                  // pw.SizedBox(height: 10),
                  // buildText(
                  //   title: 'Paid',
                  //   value: Utils.formatPrice(netTotal),
                  //   unite: true,
                  // ),
                  // buildText(
                  //   title: 'Vat ${vatPercent * 100} %',
                  //   value: Utils.formatPrice(vat),
                  //   unite: true,
                  // ),
                  Divider(),
                  buildText(
                    title: invoice.template.totalStatement,
                    titleStyle: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    value: Utils.formatPrice(total),
                    unite: true,
                  ),
                  SizedBox(height: 2 * PdfPageFormat.mm),
                  Container(height: 1, color: PdfColors.grey400),
                  SizedBox(height: 0.5 * PdfPageFormat.mm),
                  Container(height: 1, color: PdfColors.grey400),
                ],
              ),
            ),
          ],
        ),
      );
  }

  static Widget buildFooter(Invoice invoice) => Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Divider(),
      SizedBox(height: 2 * PdfPageFormat.mm),
      buildSimpleText(title: 'Address', value: invoice.supplier.address),
      SizedBox(height: 1 * PdfPageFormat.mm),
      buildSimpleText(title: 'Payment', value: invoice.supplier.paymentInfo),
    ],
  );

  static buildSimpleText({
    required String title,
    required String value,
  }) {
    final style = TextStyle(fontWeight: FontWeight.bold);

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        Text(title, style: style),
        SizedBox(width: 2 * PdfPageFormat.mm),
        Text(value),
      ],
    );
  }

  static buildText({
    required String title,
    required String value,
    double width = double.infinity,
    TextStyle? titleStyle,
    bool unite = false,
  }) {
    final style = titleStyle ?? TextStyle(fontWeight: FontWeight.bold);

    return Container(
      width: width,
      child: Row(
        children: [
          Expanded(child: Text(title, style: style)),
          Text(value, style: unite ? style : null),
        ],
      ),
    );
  }
}