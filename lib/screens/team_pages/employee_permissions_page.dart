import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:stylestore/Utilities/constants/color_constants.dart';
import 'package:stylestore/Utilities/constants/font_constants.dart';
import 'package:stylestore/model/beautician_data.dart';

class EmployeePermissionsPage extends StatefulWidget {
  @override
  State<EmployeePermissionsPage> createState() => _EmployeePermissionsPageState();
}

class _EmployeePermissionsPageState extends State<EmployeePermissionsPage> {
  String capitalize(String text) {
    return text.substring(0, 1).toUpperCase() + text.substring(1);
  }

  Future<void> updateEmployeePermissions(String permissions, String employeeId) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      await firestore.collection('employees').doc(employeeId).update({
        'permissions': permissions,
      }).whenComplete(() {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            '${Provider.of<BeauticianData>(context, listen: false).employeeName} Permissions Updated',
          ),
        ));
      });
    } catch (error) {
      print('Error updating permissions: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    var permissions = Provider.of<BeauticianData>(context).employeePermissions;

    return Scaffold(
      backgroundColor: kPlainBackground,
      appBar: AppBar(
        backgroundColor: kPureWhiteColor,
        automaticallyImplyLeading: false,
        elevation: 0,
        title: Text(
          '${Provider.of<BeauticianData>(context, listen: false).employeeName} Access Permissions',
          style: kNormalTextStyle.copyWith(color: kBlack),
        ),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: kAppPinkColor,
        onPressed: () async {
          var permissions = Provider.of<BeauticianData>(context, listen: false);
          updateEmployeePermissions(
            json.encode(permissions.employeePermissions),
            permissions.employeeId,
          );
        },
        label: Text(
          'Update',
          style: kNormalTextStyle.copyWith(color: kPureWhiteColor),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: Padding(
        padding: MediaQuery.of(context).size.width < 600
            ? EdgeInsets.symmetric(horizontal: 16.0)
            : EdgeInsets.symmetric(horizontal: 80.0),
        child: Column(
          children: [
            SizedBox(height: 20),
            Card(
              color: kBlueDarkColor,
              margin: EdgeInsets.symmetric(vertical: 10),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  '✅ means ${Provider.of<BeauticianData>(context, listen: false).employeeName} has access to that section.\n❌ means no access to that section.',
                  style: kNormalTextStyle.copyWith(color: kPureWhiteColor),
                  textAlign: TextAlign.justify,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: permissions.length,
                itemBuilder: (context, index) {
                  final permissionKey = permissions.keys.elementAt(index);
                  final permissionValue = permissions[permissionKey];

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Card(
                      color: kPureWhiteColor,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ListTile(
                        title: Text(capitalize(permissionKey)),
                        trailing: Padding(
                          padding: const EdgeInsets.all(3.0),
                          child: ToggleButtons(
                            borderRadius: BorderRadius.circular(8),
                            selectedBorderColor: kAppPinkColor,
                            selectedColor: Colors.green,
                            fillColor: kAppPinkColor.withOpacity(0.1),
                            children: [
                              Icon(Icons.check, color: permissionValue ? Colors.green : Colors.grey),
                              Icon(Icons.close, color: !permissionValue ? Colors.red : Colors.grey),
                            ],
                            onPressed: (int index) {
                              setState(() {
                                permissions[permissionKey] = index == 0;
                                Provider.of<BeauticianData>(context, listen: false)
                                    .setEmployeePermission(permissionKey, index == 0);
                              });
                            },
                            isSelected: [permissionValue, !permissionValue],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// import 'dart:convert';
//
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:iconsax/iconsax.dart';
// import 'package:provider/provider.dart';
// import 'package:stylestore/Utilities/constants/color_constants.dart';
// import 'package:stylestore/Utilities/constants/font_constants.dart';
// import 'package:stylestore/model/beautician_data.dart';
//
// class EmployeePermissionsPage extends StatefulWidget {
//   @override
//   State<EmployeePermissionsPage> createState() =>
//       _EmployeePermissionsPageState();
// }
//
// class _EmployeePermissionsPageState extends State<EmployeePermissionsPage> {
//   @override
//   String capitalize(String text) {
//     return text.substring(0, 1).toUpperCase() + text.substring(1);
//   }
//
//   Future<void> updateEmployeePermissions(
//       String permissions, String employeeId) async {
//     FirebaseFirestore firestore = FirebaseFirestore.instance;
//
//     try {
//       await firestore.collection('employees').doc(employeeId).update({
//         'permissions': permissions,
//       }).whenComplete(() {
//         Navigator.pop(context);
//         ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//             content: Text(
//                 '${Provider.of<BeauticianData>(context, listen: false).employeeName} Permissions Updated')));
//       });
//     } catch (error) {
//       print('Error updating permissions: $error');
//     }
//   }
//
//   Widget build(BuildContext context) {
//     var permissions = Provider.of<BeauticianData>(context).employeePermissions;
//
//     return Scaffold(
//       backgroundColor: kPlainBackground,
//       appBar: AppBar(
//         automaticallyImplyLeading: false,
//         backgroundColor: kPureWhiteColor,
//         elevation: 0,
//         title: Text(
//           '${Provider.of<BeauticianData>(context, listen: false).employeeName} Access Permissions',
//           textAlign: TextAlign.center,
//           style: kNormalTextStyle.copyWith(color: kBlack),
//         ),
//         centerTitle: true,
//       ),
//       floatingActionButtonLocation:
//           FloatingActionButtonLocation.miniCenterFloat,
//       floatingActionButton: FloatingActionButton.extended(
//         splashColor: kCustomColor,
//         backgroundColor: kAppPinkColor,
//         onPressed: () async {
//           var permissions = Provider.of<BeauticianData>(context, listen: false);
//           // Handle the upload/update logic here
//
//           updateEmployeePermissions(
//               json.encode(permissions.employeePermissions),
//               permissions.employeeId);
//         },
//         label: Text(
//           'Update Permissions',
//           style: kNormalTextStyle.copyWith(color: kPureWhiteColor),
//         ),
//       ),
//       body: Column(
//         children: [
//           Stack(
//             children: [
//               Card(
//                 color: kAppPinkColor,
//                 child: Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: Text(
//                     'A ✅ means ${Provider.of<BeauticianData>(context, listen: false).employeeName} has access to that feature. While a ❌ means no access to that part of the store.',
//                     textAlign: TextAlign.justify,
//                     style: kNormalTextStyle.copyWith(color: kPureWhiteColor),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           Expanded(
//             child: Padding(
//               padding: MediaQuery.of(context).size.width < 600?EdgeInsets.only(left: 0, right:0) :EdgeInsets.only(left: 80.0, right: 80),
//               child: ListView.builder(
//                 itemCount: permissions.length,
//                 itemBuilder: (context, index) {
//                   final permissionKey = permissions.keys.elementAt(index);
//                   final permissionValue = permissions[permissionKey];
//
//                   return Padding(
//                     padding: const EdgeInsets.only(bottom: 1.0),
//                     child: ListTile(
//                       // Make the colour of the tile grey
//                       tileColor: kPureWhiteColor,
//
//                       title: Text(capitalize(permissionKey)),
//                       trailing: ToggleButtons(
//                         children: [
//                           Icon(Icons.check,
//                               color: permissionValue
//                                   ? Colors.green
//                                   : Colors.transparent),
//                           Icon(Icons.close,
//                               color: !permissionValue
//                                   ? Colors.red
//                                   : Colors.transparent),
//                         ],
//                         onPressed: (int index) {
//                           setState(() {
//                             permissions[permissionKey] =
//                                 index == 0; // Toggle the value
//                             Provider.of<BeauticianData>(context, listen: false)
//                                 .setEmployeePermission(permissionKey, index == 0);
//                           });
//                           print(Provider.of<BeauticianData>(context, listen: false)
//                               .employeePermissions);
//                         },
//                         isSelected: [permissionValue, !permissionValue],
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
