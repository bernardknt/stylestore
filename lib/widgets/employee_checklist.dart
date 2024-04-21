


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stylestore/Utilities/constants/user_constants.dart';
import 'package:stylestore/model/styleapp_data.dart';
import 'package:stylestore/utilities/constants/color_constants.dart';


class EmployeePreChecklist extends StatefulWidget {
  @override
  _EmployeePreChecklistState createState() => _EmployeePreChecklistState();
}

class _EmployeePreChecklistState extends State<EmployeePreChecklist> {
  Map<String, bool> checklistItems = {
  };
  Map<String, bool> selectedItems = {};


  Future<Map<String, bool>?> getChecklistAsMap(String documentId) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    DocumentReference docRef = firestore.collection('employees').doc(documentId);

    try {

      DocumentSnapshot document = await docRef.get();
      if (document.exists) {
        List? checklist = document.get('checklist');

        // Check if the checklist field is indeed a list
        if (checklist is List) {
          return checklist.asMap().map((index, item) => MapEntry(item.toString(), false));
        } else {
          print('Checklist field is not a list');
          return null;
        }
      } else {
        print('Document with ID $documentId does not exist');
        return null;
      }
    } catch (e) {
      print('Error retrieving checklist: $e');
      return null;
    }
  }


  defaultInitialization() async {
    final prefs = await SharedPreferences.getInstance();
    String? employeeId = prefs.getString(kEmployeeId);

    if (employeeId != null) {
      showDialog(context: context, builder: ( context) {
        return const Center(
            child:
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: kAppPinkColor,),
              ],
            ));
      }
      );
      Map<String, bool>? result = await getChecklistAsMap(employeeId);
      setState(() {

        if (result != null) {
          checklistItems = result;
          Provider.of<StyleProvider>(context, listen: false).setEmployeeChecklistValues(result);
          Navigator.pop(context);
          if(checklistItems.isEmpty){
            Navigator.pop(context);
          }
        } else {

          // Handle error (e.g., show a message to the user)
        }
      });
    } else {
      // Handle the case where employee ID is not found
    }
  }
  @override
  initState() {
    defaultInitialization();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min, // Keep dialog compact
        children: checklistItems.entries.map((entry) {
          return
            CheckboxListTile(
            activeColor: kBlueDarkColor,
            title: Text(entry.key),
            value: entry.value,
            onChanged: (newValue) {
              setState(() {
                checklistItems[entry.key] = newValue!;
                if (newValue!) {
                  // Provider.of<StyleProvider>(context, listen: false).changeChecklistValues(checklistValue)
                  selectedItems[entry.key] = newValue!;
                  Provider.of<StyleProvider>(context, listen: false).changeEmployeeChecklistValues(checklistItems);
      
      
                } else {
                  selectedItems[entry.key] = newValue!;
                  print(selectedItems);
                }
      
              });
            },
          );
        }).toList(),
      ),
    );
  }
}