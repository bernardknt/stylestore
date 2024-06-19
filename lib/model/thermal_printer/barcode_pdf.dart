import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'dart:typed_data';

import '../../screens/products_pages/stock_items.dart';

class PdfBarcodeGenerator {
  static Future<File> generateBarcodePdf(List<AllStockData> stockDataList, String pdfFileName) async {
    final pdf = pw.Document();

    pdf.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.all(20),
      build: (context) => [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: stockDataList.map((stockData) => buildBarcodeItem(stockData)).toList(),
        ),
      ],
    ));

    return PdfHelper.saveDocument(name: pdfFileName, pdf: pdf);
  }

  static pw.Widget buildBarcodeItem(AllStockData stockData) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(stockData.name, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 5),
        pw.BarcodeWidget(
          barcode: pw.Barcode.code128(),
          data: stockData.barcode,
          width: 200,
          height: 80,
          drawText: false,
        ),
        pw.SizedBox(height: 10),
      ],
    );
  }
}

class PdfHelper {
  static Future<File> saveDocument({
    required String name,
    required pw.Document pdf,
  }) async {
    final bytes = await pdf.save();
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$name');

    await file.writeAsBytes(bytes);
    return file;
  }
}



Future<List<AllStockData>> fetchStockDataList() async {
  // Replace with your logic to fetch data from Firestore
  final snapshot = await FirebaseFirestore.instance.collection('stockData').get();
  return snapshot.docs.map((doc) => AllStockData.fromFirestore(doc)).toList();
}