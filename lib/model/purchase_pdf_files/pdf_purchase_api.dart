import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/widgets.dart';
import 'package:stylestore/model/common_functions.dart';
import 'package:stylestore/model/pdf_files/pdf_api.dart';
import 'purchase.dart';
import 'purchase_customer.dart';
import 'purchase_supplier.dart';
import 'purchase_utils.dart';
// import 'dart:html' as html;

class PdfPurchasePdfHelper {


  static Future<File> generate(PurchaseOrder invoice, String pdfFileName, String currency) async {
    final pdf = Document();

    pdf.addPage(MultiPage(
      build: (context) => [
        buildHeader(invoice),
        SizedBox(height: 3 * PdfPageFormat.cm),
        buildTitle(invoice),
        buildInvoice(invoice, currency),
        Divider(),
        buildTotal(invoice, currency),
      ],
      footer: (context) => buildFooter(invoice),
    ));

    return PdfHelper.saveDocument(name: pdfFileName, pdf: pdf);
  }

  static Future<void> generateAndDownloadPurhcasePdfForWeb(PurchaseOrder invoice, String pdfFileName, String currency) async {


    final pdf = Document();



    // ... (Rest of your PDF generation logic) ...
    pdf.addPage(MultiPage(
      build: (context) => [
        buildHeader(invoice),
        SizedBox(height: 3 * PdfPageFormat.cm),
        buildTitle(invoice),
        buildInvoice(invoice, currency),
        Divider(),
        buildTotal(invoice, currency),
      ],
      footer: (context) => buildFooter(invoice),
    ));

    // Generate PDF data in-memory
    final pdfData = await pdf.save();

    // Create a Blob for download
    // final blob = html.Blob([pdfData], 'application/pdf');
    // final url = html.Url.createObjectUrlFromBlob(blob);
    // final anchor = html.AnchorElement()
    //   ..href = url
    //   ..style.display = 'none'
    //   ..download = pdfFileName;
    // html.document.body!.children.add(anchor);
    //
    // // Trigger download
    // anchor.click();
    //
    // // Cleanup
    // html.document.body!.children.remove(anchor);
    // html.Url.revokeObjectUrl(url);
  }


  static Widget buildHeader(PurchaseOrder invoice) => Column(

    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(height: 1 * PdfPageFormat.cm),

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

  static Widget buildCustomerAddress(Customer customer, StockTemplate template) => Column(
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
      'PO Number:',
      'Order Date:',
      'Execution:',
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

  static Widget buildTitle(PurchaseOrder invoice) => Column(
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

  static Widget buildInvoice(PurchaseOrder invoice, String currency) {
    final headers = [
      'Description',
      'Quantity',
      'Unit Cost',
      'Cost',
      'Amount'
    ];
    final data = invoice.items.map((item) {
      // final total = item.unitPrice * item.quantity * (1 + item.vat);
      final total = item.unitPrice;

      return [
        item.description,
        '${item.quantity}',
        '${(item.unitPrice/ item.quantity).toStringAsFixed(1)}',
        '${currency} ${(CommonFunctions().formatter.format(total))}',
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
        // 4: Alignment.centerRight,
        5: Alignment.centerRight,
      },
    );
  }

  static Widget buildTotal(PurchaseOrder invoice, String currency) {
    final receiptAmount = invoice.paid.amount;

    final netTotal = invoice.items
        .map((item) => (item.unitPrice) )
        .reduce((item1, item2) => item1 + item2);

    final billTotal = invoice.items
        .map((item) => item.unitPrice)
        .reduce((item1, item2) => item1 + item2);
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
                  value: "$currency ${Utils.formatPrice(billTotal)}",
                  unite: true,
                ),
                Divider(),
                buildText(
                  title: invoice.template.totalStatement,
                  titleStyle: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  value: "$currency ${Utils.formatPrice(total)}",
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
                    title: 'Sub total',
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

  static Widget buildFooter(PurchaseOrder invoice) => Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Divider(),
      SizedBox(height: 2 * PdfPageFormat.mm),
      buildSimpleText(title: 'Address', value: invoice.supplier.address),
      SizedBox(height: 1 * PdfPageFormat.mm),
      buildSimpleText(title: 'Number', value: invoice.supplier.paymentInfo),
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