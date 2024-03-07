// import 'dart:typed_data';
// import 'dart:html' as html;
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:stylestore/Utilities/constants/color_constants.dart';
import 'package:stylestore/screens/suppliers/supplier_details.dart';
import 'package:stylestore/screens/suppliers/supplier_form.dart';
import '../../Utilities/constants/font_constants.dart';
import '../../model/common_functions.dart';
import '../../model/styleapp_data.dart';
import '../../widgets/locked_widget.dart';

class SuppliersPage extends StatefulWidget {
  static String id = "suppliers_page";
  const SuppliersPage({super.key});

  @override
  State<SuppliersPage> createState() => _SuppliersPageState();
}

class _SuppliersPageState extends State<SuppliersPage> {
  List<AllSupplierData> newSuppliers = [];
  String businessId = '';
  Map<String, dynamic> permissionsMap = {};
  Map<String, dynamic> videoMap = {};

  Future<List<AllSupplierData>> retrieveSupplierData() async {

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('suppliers')
          .where('storeId', isEqualTo: Provider.of<StyleProvider>(context, listen: false).beauticianId)
          .orderBy('name', descending: false)
          .get();

      final supplierDataList = snapshot.docs
          .map((doc) => AllSupplierData.fromFirestore(doc))
          .toList();
      return supplierDataList;
    } catch (error) {
      print('Error retrieving employee data: $error');
      return []; // Return an empty list if an error occurs
    }
  }

  void filterSuppliers(String query) {
    setState(() {
      filteredSupplier = newSuppliers
          .where((supplier) =>
      supplier.fullNames.toLowerCase().contains(query.toLowerCase()) ||
          supplier.fullNames.toLowerCase().contains(query.toLowerCase())
          || supplier.phone.toLowerCase().contains(query.toLowerCase())
          || supplier.supplies.toLowerCase().contains(query.toLowerCase())
      )
          .toList();
    });
  }

  TextEditingController searchController = TextEditingController();
  List<AllSupplierData> filteredSupplier = [];

  @override
  void initState() {
    defaultInitialization();

    super.initState();
  }

  void defaultInitialization() async {
    permissionsMap = await CommonFunctions().convertPermissionsJson();
    videoMap = await CommonFunctions().convertWalkthroughVideoJson();
    newSuppliers = await retrieveSupplierData();
    filteredSupplier.addAll(newSuppliers);
    setState(() {});
  }

// Helper method to build information card
  Widget buildInfoCard(
      {required String title,
        required String value,
        Color cardColor = kBackgroundGreyColor,
        IconData cardIcon = Icons.accessibility}) {
    return Tooltip(
      message: title,
      child: Card(
        // Add a tooltip that appears when the user holds the mouse button down over the card
        // This tooltip should show the title of the card
        color: cardColor.withOpacity(0.2),
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              kSmallHeightSpacing,
              Icon(
                cardIcon,
                color: cardColor.withOpacity(0.6),
              ),
              kSmallHeightSpacing,
              Text(
                value,
                style: TextStyle(fontSize: 18.0),
              ),
            ],
          ),
        ),
      ),
    );
  }



  void generateExcel() async {
    var excel = Excel.createExcel();
    var sheet = excel['Sheet1'];

    // Add headers for employee data
    sheet.appendRow([
      'Name',
      'Phone',
      'Email',
      'Department',
      'Position',
      'Gender',
      'Marital Status',
      'National Id Number',
      'Kin',
      'Kin Number',
      'Tin',
      'Birthday',
    ]);

    // Add employee data
    for (var employee in filteredSupplier) {
      sheet.appendRow([
        employee.fullNames,
        employee.phone,
        employee.email,
      ]);
    }

    // Save the Excel file
    final excelData = excel.encode();

    // Get the directory for storing files on the device
    final directory = await getExternalStorageDirectory();
    final filePath = '${directory?.path}/employee_data.xlsx';

    // Write the Excel data to a file
    final excelFile = File(filePath);
    await excelFile.writeAsBytes(excelData!);
  }


  // void generateExcelWeb() async {
  //   var excel = Excel.createExcel();
  //   var sheet = excel['Sheet1'];
  //
  //   // Add headers for employee data
  //   sheet.appendRow([
  //     'Name',
  //     'Phone',
  //     'Email',
  //     'Department',
  //     'Position',
  //     'Gender',
  //     'Marital Status',
  //     'National Id Number',
  //     'Kin',
  //     'Kin Number',
  //     'Tin',
  //     'Birthday',
  //   ]);
  //
  //   // Add employee data
  //   for (var employee in filteredEmployees) {
  //     sheet.appendRow([
  //       employee.fullNames,
  //       employee.phone,
  //       employee.email,
  //       employee.department,
  //       employee.position,
  //       employee.gender,
  //       employee.maritalStatus,
  //       employee.nationalIdNumber,
  //       employee.kin,
  //       employee.kinNumber,
  //       employee.tin,
  //       employee.birthday.toString(),
  //     ]);
  //   }
  //
  //   // Save the Excel file
  //   final List<int>? excelData = excel.encode();
  //
  //   // Create a blob from the bytes and create a download link
  //   final blob = html.Blob([excelData]);
  //   final blobUrl = html.Url.createObjectUrlFromBlob(blob);
  //
  //   // Create a link element and trigger the download
  //   final anchor = html.AnchorElement(href: blobUrl)
  //     ..target = 'download'
  //     ..download = 'employee_data.xlsx';
  //
  //   // Trigger the click event to start the download
  //   html.document.body?.append(anchor);
  //   anchor.click();
  //
  //   // Clean up the temporary link
  //   html.Url.revokeObjectUrl(blobUrl);
  //   anchor.remove();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

        title:
        Row(
          // Put the title in the center
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Suppliers'),
            kMediumWidthSpacing,
            // A Icon button that downloads the employee data
            IconButton(
              icon: const Tooltip(
                  message: 'Download Supplier Data',
                  child: Icon(
                    Icons.download,
                    color: kAppPinkColor,
                  )),
              onPressed: () {
                generateExcel();
                // Implement download action here
              },
            ),
          ],
        ),
        automaticallyImplyLeading:  MediaQuery.of(context).size.width > 600 ? false: true,
      ),
      floatingActionButton: FloatingActionButton(
        // When the user hovers over the button, show a tooltip with this text 'Edit Users Profile'
        tooltip: "Add new Supplier",
        backgroundColor: kAppPinkColor,
        foregroundColor: kPureWhiteColor,
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.pushNamed(context, SupplierForm.id);
        },
      ),
      body:  permissionsMap['employees'] == false ? LockedWidget(page: "Team",):Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Stack(
              children: [
                TextField(
                  controller: searchController,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'By Name/ Product / Phone Number',
                    hintFadeDuration: Duration(milliseconds: 100),
                  ),
                  onChanged: filterSuppliers,
                ),

              ],
            ),
          ),

          Expanded(
            child: ListView.builder(
              itemCount: filteredSupplier.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: ListTile(
                    title: Text(
                      "${filteredSupplier[index].fullNames}",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Supplies: ${filteredSupplier[index].supplies}'),
                        Text(
                            'Location: ${filteredSupplier[index].address}'),

                        Text('Phone: ${filteredSupplier[index].phone}'),
                      ],
                    ),
                    trailing: Container(
                      width: 120,

                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [



                        Text("Create Bill", style: kNormalTextStyle.copyWith(color:kAppPinkColor, fontWeight: FontWeight.bold),),
                        kSmallWidthSpacing,
                        Icon(Icons.money,color: kAppPinkColor, )
                      ],),
                    ),
                    onTap: () {
                      // Handle supplier item tap
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
