

import 'dart:io';

import 'package:excel/excel.dart';

// ...

class ExcelDataRow {
  final String name;
  final String description;
  final double amount;
  final bool saleable;
  final bool tracking;
  final int quantity;
  final int minimum;

  ExcelDataRow({
    required this.name,
    required this.description,
    required this.amount,
    required this.saleable,
    required this.tracking,
    required this.quantity,
    required this.minimum,
  });

  Map<String, dynamic> toMap() {
    return {
      'Name': name,
      'Description': description,
      'Amount': amount,
      'Saleable': saleable,
      'Tracking': tracking,
      'Quantity': quantity,
      'Minimum': minimum,
    };
  }
}

Future<List<ExcelDataRow>> readExcelData(File excelFile) async {
  var bytes = excelFile.readAsBytesSync();
  var excel = Excel.decodeBytes(bytes);

  // Assume the first sheet in the Excel file contains the data.
  var sheet = excel.tables[excel.tables.keys.first];

  List<ExcelDataRow> dataList = [];
  for (var row in sheet!.rows) {
    // Skip the header row (assuming it's the first row)
    if (row[0]?.value == 'Name') continue;

    ExcelDataRow rowData = ExcelDataRow(
      name: row[0]?.value,
      description: row[1]?.value,
      amount: double.tryParse(row[2]?.value) ?? 0.0,
      saleable: row[3]?.value.toLowerCase() == 'true',
      tracking: row[4]?.value.toLowerCase() == 'true',
      quantity: int.tryParse(row[5]?.value) ?? 0,
      minimum: int.tryParse(row[6]?.value) ?? 0,
    );

    dataList.add(rowData);
  }
  return dataList;
}
