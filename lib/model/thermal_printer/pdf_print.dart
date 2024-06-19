import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:stylestore/model/pdf_files/pdf_api.dart';
import 'dart:io';
import 'dart:typed_data';

import '../pdf_files/invoice.dart';

class PdfThermalReceiptHelper {
  static Future<File> generateThermalReceipt(Invoice invoice, String pdfFileName, String logo) async {
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

    final pdf = pw.Document();
    final imagePng = (await rootBundle.load("images/paid.png")).buffer.asUint8List();
    final Uint8List logoBytes = await _fetchLogoBytes(logo);

    pdf.addPage(pw.Page(
      pageFormat: PdfPageFormat(80 * PdfPageFormat.mm, double.infinity,
          marginAll: 5 * PdfPageFormat.mm),
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Image(pw.MemoryImage(logoBytes), height: 40, alignment: pw.Alignment.center),
          pw.SizedBox(height: 2 * PdfPageFormat.mm),
          buildHeader(invoice),
          pw.SizedBox(height: 2 * PdfPageFormat.mm),
          buildTitle(invoice),
          buildInvoice(invoice),
          pw.Divider(),
          buildTotal(invoice),
          pw.SizedBox(height: 2 * PdfPageFormat.mm),
          buildFooter(invoice),
        ],
      ),
    ));

    return PdfHelper.saveDocument(name: pdfFileName, pdf: pdf);
  }

  static pw.Widget buildHeader(Invoice invoice) => pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text(invoice.supplier.name, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
      pw.Text(invoice.supplier.address),
      pw.Text(invoice.supplier.phoneNumber),
      pw.SizedBox(height: 2 * PdfPageFormat.mm),
      pw.Text("Bill To:", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
      pw.Text(invoice.customer.name),
      pw.Text(invoice.customer.address),
      pw.Text(invoice.customer.phone),
    ],
  );

  static pw.Widget buildTitle(Invoice invoice) => pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text(invoice.template.type, style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
      pw.SizedBox(height: 1 * PdfPageFormat.mm),
      pw.Text(invoice.info.description),
    ],
  );

  static pw.Widget buildInvoice(Invoice invoice) {
    final headers = ['Item', 'Qty', 'Price', 'Total'];
    final data = invoice.items.map((item) {
      final total = item.unitPrice * item.quantity;
      return [item.name, '${item.quantity}', '${item.unitPrice}', '${total}'];
    }).toList();

    return pw.Table.fromTextArray(
      headers: headers,
      data: data,
      border: pw.TableBorder.all(color: PdfColors.grey),
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8),
      cellStyle: pw.TextStyle(fontSize: 8),
      headerDecoration: pw.BoxDecoration(color: PdfColors.grey300),
      cellHeight: 20,
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.centerRight,
        2: pw.Alignment.centerRight,
        3: pw.Alignment.centerRight,
      },
    );
  }

  static pw.Widget buildTotal(Invoice invoice) {
    final receivedAmount = invoice.paid.amount;
    final netTotal = invoice.items.map((item) => (item.unitPrice * item.quantity)).reduce((item1, item2) => item1 + item2) - receivedAmount;
    final total = netTotal;

    return pw.Container(
      alignment: pw.Alignment.centerRight,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          buildText(title: 'Total', value: "${invoice.template.currency} ${total}"),
          pw.SizedBox(height: 2 * PdfPageFormat.mm),
          buildText(title: 'Amount Paid', value: "${invoice.template.currency} ${receivedAmount}"),
          pw.Divider(),
          buildText(title: invoice.template.totalStatement, value: "${invoice.template.currency} ${total}"),
        ],
      ),
    );
  }

  static pw.Widget buildFooter(Invoice invoice) => pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.center,
    children: [
      pw.Divider(),
      pw.SizedBox(height: 2 * PdfPageFormat.mm),
      buildSimpleText(title: 'Address', value: invoice.supplier.address),
      pw.SizedBox(height: 1 * PdfPageFormat.mm),
      buildSimpleText(title: 'Payment Details', value: invoice.supplier.paymentInfo),
    ],
  );

  static pw.Widget buildSimpleText({required String title, required String value}) {
    return pw.Row(
      mainAxisSize: pw.MainAxisSize.min,
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        pw.Text(title, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(width: 2 * PdfPageFormat.mm),
        pw.Text(value),
      ],
    );
  }

  static pw.Widget buildText({required String title, required String value}) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(title, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        pw.Text(value),
      ],
    );
  }
}