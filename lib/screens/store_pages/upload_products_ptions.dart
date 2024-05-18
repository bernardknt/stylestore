import 'dart:io';

import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:stylestore/Utilities/constants/color_constants.dart';
import 'package:stylestore/Utilities/constants/font_constants.dart';
import 'package:stylestore/model/common_functions.dart';
import '../../model/excel_model.dart';
import '../../widgets/procedure_widget.dart';


class UploadProductOptions extends StatefulWidget {
  @override
  State<UploadProductOptions> createState() => _UploadProductOptionsState();
}

class _UploadProductOptionsState extends State<UploadProductOptions> {
  void downloadTemplate() {
    CommonFunctions().downloadTemplate();
  }
  List<ExcelDataRow> dataList = [];
  void uploadDocument()async {
    // Function to execute when Upload Document card is selected
    print('Uploading Document...');
    // Add your logic here
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: [
          'xls',
          'xlsx'
        ]); // , allowedExtensions: ['xls','xlsx']
    if (result != null) {
      setState(() {
        dataList.clear();
      });
      print("Data Cleared");
      if (kIsWeb){
        print("kIs Web");
        Uint8List excelBytes = result.files.single.bytes!;

        try {

          List<ExcelDataRow> uploadedDataList = await readExcelDataFromBytes(excelBytes);
          setState(() {
            dataList.addAll(uploadedDataList);
          });


          await CommonFunctions().uploadExcelDataToFirebase(uploadedDataList, context);
        } catch (e){
          CommonFunctions().showErrorDialog("Wrong Excel document Format used.", context);
        }
      }else
      {
        File excelFile = File(result.files.single.path!);

        try {
          List<ExcelDataRow> uploadedDataList = await readExcelData(excelFile);

          setState(() {
            dataList.addAll(uploadedDataList);
          });

          await CommonFunctions().uploadExcelDataToFirebase(uploadedDataList, context);
        } catch (e){
          CommonFunctions().showErrorDialog("Wrong Excel document Format used.", context);
        }
      }

    }
  }

  // Future<List<ExcelDataRow>> readExcelDataFromBytes(Uint8List bytes) async {
  //   Excel excel = Excel.decodeBytes(bytes);
  //
  //   // Assuming your logic to read data from Excel and convert it to a list of data rows
  //   List<ExcelDataRow> dataRows = [];
  //
  //   for (var table in excel.tables.keys) {
  //     for (var row in excel.tables[table]!.rows) {
  //       // Process each row and create ExcelDataRow objects
  //       // Example: dataRows.add(ExcelDataRow(row[0].toString(), row[1].toString(), ...));
  //     }
  //   }
  //
  //   return dataRows;
  // }
  Future<List<ExcelDataRow>> readExcelDataFromBytes(Uint8List bytes) async {
    Excel excel = Excel.decodeBytes(bytes);

    // Assuming the headers are known and in the first row (row index 0)
    final List<String> expectedHeaders = ['Name', 'Description', 'Amount', 'Saleable', 'Tracking', 'Quantity', 'Minimum'];

    List<ExcelDataRow> dataList = [];

    for (var table in excel.tables.keys) {
      var sheet = excel.tables[table];
      var headers = sheet?.rows.first.map((cell) => cell?.value.toString().trim()).toList();

      if (!listEquals(headers, expectedHeaders)) {
        throw Exception("Invalid Excel format. Headers don't match the expected format.");
      }

      for (var row in sheet!.rows.skip(1)) {
        String name = row[0]?.value.toString() ?? '';
        String description = row[1]?.value.toString() ?? '';
        double amount = (row[2]?.value ?? 0).toDouble();
        bool saleable = (row[3]?.value.toString().toLowerCase() == 'true');
        bool tracking = row[4]?.value.toString().toLowerCase() == 'true';
        int quantity = (row[5]?.value ?? 0).toInt();
        int minimum = (row[6]?.value ?? 0).toInt();

        ExcelDataRow excelDataRow = ExcelDataRow(
          name: name,
          description: description,
          amount: amount,
          saleable: saleable,
          tracking: tracking,
          quantity: quantity,
          minimum: minimum,
        );

        dataList.add(excelDataRow);
      }
    }

    return dataList;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        foregroundColor: kBlack,
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Select an Option',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OptionCard(
                  icon: Iconsax.document5,
                  label: 'Download\nTemplate',
                  onPressed: downloadTemplate,
                ),
                kMediumWidthSpacing,
                Text("Or", style: kNormalTextStyle,),
                kMediumWidthSpacing,

                OptionCard(
                  icon: Iconsax.document_upload,
                  label: 'Upload\nDocument',
                  onPressed: uploadDocument,
                ),
              ],
            ),
            SizedBox(height: 24.0),
            Text("Procedure", style: kNormalTextStyle.copyWith(fontSize: 20,fontWeight: FontWeight.w900, color: kBlack),),
            Expanded(
              child: ListView(
                children: [
                  ProcedureStep(stepNumber: 1, description: 'Download the template document'),
                  ProcedureStep(stepNumber: 2, description: 'Fill in the stock details in the fields'),
                  ProcedureStep(stepNumber: 3, description: 'Save the document'),
                  ProcedureStep(stepNumber: 4, description: 'Select and upload the saved document'),
                ],
              ),
            ),
            TextButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(kCustomColor), // Button color (green)
                padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                  EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
                ),
              ),
              onPressed: () {
                // Function to execute when Watch Video button is pressed
                print('Watching Video...');
                // Add your logic here
              },
              child: Text(
                'Or Watch Video',
                style: kNormalTextStyle.copyWith(color: kBlack),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OptionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const OptionCard({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Card(
        elevation: 3.0,
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 25.0,
                color: kAppPinkColor,
              ),
              SizedBox(height: 8.0),
              Text(
                label,
                style: kNormalTextStyle.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

