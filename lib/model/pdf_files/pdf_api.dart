import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import '../../screens/Documents_Pages/dummy_document.dart';


class PdfHelper {
  static Future<File> saveDocument({
    required String name,
    required Document pdf,
  }) async {
    if (kIsWeb){


      // Example: Generate PDF with sample data
      final data = CustomData(name: 'Alice');
      final pdfFile = await generateDocument(PdfPageFormat.a4, data);

      // Decide what to do with the pdfFile (example: save to file system)
      final pathProvider = await getTemporaryDirectory();
      final file = File('${pathProvider.path}/sample.pdf');
      await file.writeAsBytes(pdfFile);
      return file;
    } else {
      final bytes = await pdf.save();
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$name.pdf');
      await file.writeAsBytes(bytes);
      return file;
    }

  }


  static Future openFile(File file) async {
    final url = file.path;

    // OpenFile.open(file.path);
    final result = await OpenFile.open(url);
    print(result.message);



  }
}