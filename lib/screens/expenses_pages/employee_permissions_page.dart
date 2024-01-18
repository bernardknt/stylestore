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
  @override

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
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${Provider.of<BeauticianData>(context, listen: false).employeeName} Permissions Updated'))

          );});}

     catch (error) {
      print('Error updating permissions: $error');
    }
  }
  Widget build(BuildContext context) {
    var permissions = Provider.of<BeauticianData>(context).employeePermissions;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPureWhiteColor,
        elevation: 0,
        title: Text(
          '${Provider.of<BeauticianData>(context, listen: false).employeeName} Store Permissions',
          textAlign: TextAlign.center,
          style: kNormalTextStyle.copyWith(color: kBlack),
        ),
        centerTitle: true,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniCenterFloat,
      floatingActionButton: FloatingActionButton.extended(
        splashColor: kCustomColor,
        backgroundColor: kAppPinkColor,
        onPressed: () async {
          var permissions = Provider.of<BeauticianData>(context, listen: false);
          // Handle the upload/update logic here

         updateEmployeePermissions(json.encode(permissions.employeePermissions), permissions.employeeId);

        },
        label: Text(
          'Update Permissions',
          style: kNormalTextStyle.copyWith(color: kPureWhiteColor),
        ),
      ),
      body: Column(
        children: [

          Padding(
            padding: const EdgeInsets.only(left: 20.0, right: 20),
            child: Stack(
              children: [
                Card(
                  color:kAppPinkColor,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('A ✅ means ${Provider.of<BeauticianData>(context, listen: false).employeeName} has access to that feature. While a ❌ means no access to that part of the store.',textAlign: TextAlign.justify, style: kNormalTextStyle.copyWith(color: kPureWhiteColor),),
                  ),


                ),

              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: permissions.length,
              itemBuilder: (context, index) {
                final permissionKey = permissions.keys.elementAt(index);
                final permissionValue = permissions[permissionKey];

                return ListTile(
                  title: Text(capitalize(permissionKey)),
                  trailing: ToggleButtons(
                    children: [
                      Icon(Icons.check, color: permissionValue ? Colors.green : Colors.transparent),
                      Icon(Icons.close, color: !permissionValue ? Colors.red : Colors.transparent),
                    ],
                    onPressed: (int index) {
                      setState(() {
                        permissions[permissionKey] = index == 0; // Toggle the value
                        Provider.of<BeauticianData>(context, listen: false)
                            .setEmployeePermission(permissionKey, index == 0);
                      });
                      print(Provider.of<BeauticianData>(context, listen: false).employeePermissions);
                    },
                    isSelected: [permissionValue, !permissionValue],

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



// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:stylestore/Utilities/constants/color_constants.dart';
// import 'package:stylestore/Utilities/constants/font_constants.dart';
// import 'package:stylestore/model/beautician_data.dart';
//
// class EmployeePermissionsPage extends StatefulWidget {
//   @override
//   State<EmployeePermissionsPage> createState() => _EmployeePermissionsPageState();
// }
//
// class _EmployeePermissionsPageState extends State<EmployeePermissionsPage> {
//
//
//   @override
//   Widget build(BuildContext context) {
//     var permissions = Provider.of<BeauticianData>(context).employeePermissions;
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: kPureWhiteColor,
//         elevation: 0,
//         title: Text(
//           'Store Permissions\n${permissions.keys.where((element) => true).join(", ")}',
//           textAlign: TextAlign.center,
//           style: kNormalTextStyle.copyWith(color: kBlack),
//         ),
//         centerTitle: true,
//       ),
//       floatingActionButtonLocation: FloatingActionButtonLocation.miniCenterFloat,
//       floatingActionButton: FloatingActionButton.extended(
//         splashColor: Colors.green,
//         backgroundColor: kAppPinkColor,
//         onPressed: () async {
//           // Handle the upload/update logic here
//           print(permissions); // Print the updated permissions
//         },
//         label: Text(
//           'Update',
//           style: kNormalTextStyle.copyWith(color: kPureWhiteColor),
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(25.0),
//         child: ListView.builder(
//           itemCount: permissions.length,
//           itemBuilder: (context, index) {
//             final permissionKey = permissions.keys.elementAt(index);
//             bool permissionValue = permissions[permissionKey];
//             // bool usedValue = true;
//
//             return ListTile(
//               title: Text( permissionKey.toUpperCase(), style: kNormalTextStyle.copyWith(color: kBlack),),
//               subtitle:Text( Provider.of<BeauticianData>(context).employeePermissions.values.elementAt(index).toString()),
//               trailing: Radio<bool>(
//                 activeColor: kAppPinkColor,
//                 focusColor: kCustomColor,
//                 value: true,
//                 groupValue: permissionValue,
//                 onChanged: (value) {
//                   // setState(() {
//                   if(value == false) {
//                     print("YESSSSSS");
//                   } else{
//                     print("NOOOOOOO");
//                   }
//                   permissions[permissionKey] = !permissionValue;
//                    Provider.of<BeauticianData>(context, listen: false).setEmployeePermission(permissionKey, permissions[permissionKey]);
//                     print(Provider.of<BeauticianData>(context, listen: false).employeePermissions);
//                     // print(permissionValue);
//                   // });
//                 },
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }
