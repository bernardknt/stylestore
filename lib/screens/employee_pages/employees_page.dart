// import 'dart:typed_data';
// import 'dart:html' as html;
import 'dart:io';
// Make this an html branch
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
// import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stylestore/Utilities/constants/color_constants.dart';
import 'package:stylestore/Utilities/constants/user_constants.dart';
import 'package:stylestore/screens/employee_pages/edit_employee_profile_page.dart';
import 'package:stylestore/utilities/constants/word_constants.dart';
import '../../Utilities/constants/font_constants.dart';
import '../../model/beautician_data.dart';
import '../../model/common_functions.dart';
import '../../model/styleapp_data.dart';
import '../../widgets/locked_widget.dart';
import '../../widgets/modalButton.dart';
import '../../widgets/rounded_icon_widget.dart';
import '../team_pages/employee_permissions_page.dart';
import 'biodata_page_1.dart';
import 'employee_details.dart';

class EmployeesPage extends StatefulWidget {
  static String id = "employees_page";
  const EmployeesPage({super.key});

  @override
  State<EmployeesPage> createState() => _EmployeesPageState();
}

class _EmployeesPageState extends State<EmployeesPage> {
  List<AllEmployeeData> newEmployees = [];
  String businessId = '';
  Map<String, dynamic> permissionsMap = {};
  Map<String, dynamic> videoMap = {};

  Future<List<AllEmployeeData>> retrieveEmployeeData() async {
    print("KOOOOONAAAA: ${Provider.of<StyleProvider>(context, listen: false).beauticianId}");
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('employees')
          .where('storeId', isEqualTo: Provider.of<StyleProvider>(context, listen: false).beauticianId)
          .orderBy('name', descending: false)
          .get();

      final employeeDataList = snapshot.docs
          .map((doc) => AllEmployeeData.fromFirestore(doc))
          .toList();

      return employeeDataList;
    } catch (error) {
      print('Error retrieving employee data: $error');
      return []; // Return an empty list if an error occurs
    }
  }

  TextEditingController searchController = TextEditingController();
  List<AllEmployeeData> filteredEmployees = [];

  @override
  void initState() {
    defaultInitialization();

    super.initState();
  }

  void showFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Filter Options'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('All'),
                onTap: () {
                  filterEmployeesByStatus(null); // null means no filter
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: Text('Signed In'),
                onTap: () {
                  filterEmployeesByStatus("true");
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: Text('Signed Out'),
                onTap: () {
                  filterEmployeesByStatus("false");
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: Text('Male'),
                onTap: () {
                  filterEmployeesByGender('Male');
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: Text('Female'),
                onTap: () {
                  filterEmployeesByGender('Female');
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void filterEmployees(String query) {
    setState(() {
      filteredEmployees = newEmployees
          .where((employee) =>
              employee.fullNames.toLowerCase().contains(query.toLowerCase()) ||
              employee.fullNames.toLowerCase().contains(query.toLowerCase()) ||
              employee.phone.toLowerCase().contains(query.toLowerCase()) ||
              employee.department.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }


  void filterEmployeesByStatus(String? status) {
    setState(() {
      filteredEmployees = newEmployees
          .where((employee) =>
              status == null || employee.loggedIn.values.join() == status)
          .toList();
    });
  }

  void filterEmployeesByGender(String? gender) {
    setState(() {
      filteredEmployees = newEmployees
          .where((employee) => gender == null || employee.gender == gender)
          .toList();
    });
  }

  void defaultInitialization() async {
    permissionsMap = await CommonFunctions().convertPermissionsJson();
    videoMap = await CommonFunctions().convertWalkthroughVideoJson();
    newEmployees = await retrieveEmployeeData();
    print(newEmployees);
    filteredEmployees.addAll(newEmployees);
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

// Helper method to calculate the total number of departments
  int calculateTotalDepartments() {
    // Assuming each department is unique, you can use a set to count them
    Set<String> departments = Set<String>();
    newEmployees.forEach((employee) {
      departments.add(employee.department);
    });
    return departments.length;
  }

// Helper method to calculate the total number of employees based on gender
  int calculateGenderCount({required String gender}) {
    return newEmployees.where((employee) => employee.gender == gender).length;
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
    for (var employee in filteredEmployees) {
      sheet.appendRow([
        employee.fullNames,
        employee.phone,
        employee.email,
        employee.department,
        employee.position,
        employee.gender,
        employee.maritalStatus,
        employee.nationalIdNumber,
        employee.kin,
        employee.kinNumber,
        employee.tin,
        employee.birthday.toString(),
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

        title: Row(
          // Put the title in the center
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            permissionsMap['employees'] == false ? SizedBox(): Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              // crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Team'),
                kMediumWidthSpacing,

                TextButton(
                    style: ButtonStyle(backgroundColor: CommonFunctions().convertToMaterialStateProperty(kBlueDarkColor)),
                    onPressed: (){
                  CommonFunctions().openLink(Provider.of<StyleProvider>(context, listen: false).videoMap['team']) ;
                }, child: Text(cWatchTutorial, style: kNormalTextStyle.copyWith(color: kPureWhiteColor),))
              ],
            ),
            // kMediumWidthSpacing,
            // // A Icon button that downloads the employee data
            // IconButton(
            //   icon: const Tooltip(
            //       message: 'Download Employee Data',
            //       child: Icon(
            //         Icons.download,
            //         color: kAppPinkColor,
            //       )),
            //   onPressed: () {
            //     generateExcel();
            //     // Implement download action here
            //   },
            // ),
          ],
        ),
        automaticallyImplyLeading:  MediaQuery.of(context).size.width > 600 ? false: true,
      ),
      floatingActionButton: FloatingActionButton(
        // When the user hovers over the button, show a tooltip with this text 'Edit Users Profile'
        tooltip: "Add new Employee",
        backgroundColor: kAppPinkColor,
        foregroundColor: kPureWhiteColor,
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.pushNamed(context, BioDataForm.id);
        },
      ),
      body:  permissionsMap['employees'] == false ? LockedWidget(page: "Team",):Column(
        children: [
          // Row of four cards
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                buildInfoCard(
                    title: 'Total Employees',
                    value: newEmployees.length.toString(),
                    cardColor: kGreenThemeColor,
                    cardIcon: Icons.people),
                buildInfoCard(
                    title: 'Total Departments',
                    value: calculateTotalDepartments().toString(),
                    cardColor: kAppPinkColor,
                    cardIcon: Icons.business),
                buildInfoCard(
                    title: 'Male Employees',
                    value: calculateGenderCount(gender: 'Male').toString(),
                    cardColor: Colors.blue,
                    cardIcon: Icons.male),
                buildInfoCard(
                    title: 'Female Employees',
                    value: calculateGenderCount(gender: 'Female').toString(),
                    cardColor: kAppPinkColor,
                    cardIcon: Icons.female),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Stack(
              children: [
                TextField(
                  controller: searchController,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'By Employees/ Department / Phone Number',
                    hintFadeDuration: Duration(milliseconds: 100),
                  ),
                  onChanged: filterEmployees,
                ),
                Positioned(
                  right: 0,
                  child: IconButton(
                    icon: Icon(Icons.filter_list),
                    onPressed: () {
                      showFilterDialog();
                      // Implement filter action here
                    },
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView.builder(
              itemCount: filteredEmployees.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: ListTile(
                    leading: RoundImageRing(
                      networkImageToUse: filteredEmployees[index].picture,
                      outsideRingColor: kBackgroundGreyColor,
                      radius: 48,
                    ),
                    title: Text(
                      "${filteredEmployees[index].fullNames}",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    trailing: filteredEmployees[index].loggedIn.values.join() ==
                            "true"
                        ? Column(
                            children: [
                              Icon(
                                Icons.circle,
                                color: kGreenThemeColor,
                                size: 15,
                              ),
                              Text('Signed In'),
                            ],
                          )
                        : Column(
                            children: [
                              Icon(Icons.circle,
                                  color: kAppPinkColor, size: 15),
                              Text('Signed Out'),
                            ],
                          ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Position: ${filteredEmployees[index].position}'),
                        Text(
                            'Department: ${filteredEmployees[index].department}'),

                        Text('Phone: ${filteredEmployees[index].phone}'),
                      ],
                    ),
                    onTap: () {
                      // Handle employee item tap
                      showModalBottomSheet(
                          context: context,
                          builder: (BuildContext context) {
                            return Container(
                              color: Colors.transparent,
                              child: Container(
                                decoration: BoxDecoration(
                                    color: kPureWhiteColor,
                                    borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30) )
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 20.0, bottom: 50, left: 20),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children:
                                    [
                                      buildButton(context, 'View ${filteredEmployees[index].fullNames} Details', Icons.person,
                                              () async {
                                        Navigator.pop(context);
                                        Provider.of<BeauticianData>(context, listen: false).setEmployeeDetails(filteredEmployees[index].fullNames, filteredEmployees[index].phone, filteredEmployees[index].position,CommonFunctions().convertJsonString( filteredEmployees[index].permissions),
                                            filteredEmployees[index].code, filteredEmployees[index].documentId);
                                                Provider.of<BeauticianData>(context, listen: false).setEmployeeProfile(filteredEmployees[index]);
                                                Navigator.pushNamed(context, EditProfilePage.id);
                                          }
                                      ),
                                      // buildButton(context, 'Change ${filteredEmployees[index].fullNames} Permissions', Icons.edit,
                                      //         () async {
                                      //
                                      //       Provider.of<BeauticianData>(context, listen: false).setEmployeeDetails(filteredEmployees[index].fullNames, filteredEmployees[index].phone, filteredEmployees[index].position,CommonFunctions().convertJsonString( filteredEmployees[index].permissions),
                                      //           filteredEmployees[index].code, filteredEmployees[index].documentId);
                                      //       // Navigator.pop(context);
                                      //       // Navigator.push(context, MaterialPageRoute(builder: (context)=> EmployeePermissionsPage()));
                                      //
                                      //
                                      //     }
                                      // ),

                                      buildButton(context, 'Share ${filteredEmployees[index].fullNames} Credentials', Icons.share,  () async {
                                        Share.share('Login instructions for ${filteredEmployees[index].fullNames}\n1. Start by downloading the BusinessPilot app on ios or android or via the website.\n2. On the login page, click on the "Join Business as Staff Member".\n3.Enter the phone number and code below\n4. Login.\nNumber: ${filteredEmployees[index].phone}\nCode: ${filteredEmployees[index].code}', subject: 'Login to BusinessPilot');
                                      } ),
                                    ],
                                  ),
                                ),
                              ),
                            ); });
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
