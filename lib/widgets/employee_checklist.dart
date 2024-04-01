


import 'package:flutter/material.dart';
import 'package:stylestore/utilities/constants/color_constants.dart';

class EmployeePreChecklist extends StatefulWidget {
  @override
  _EmployeePreChecklistState createState() => _EmployeePreChecklistState();
}

class _EmployeePreChecklistState extends State<EmployeePreChecklist> {
  Map<String, bool> checklistItems = {
    'Dressed in official uniform': false,
    'Clean the office desks and Tables': false,
    'Melt water and put in the containers': false,
    'Set up KDS system': false,

    // Add more checklist items here...
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min, // Keep dialog compact
      children: checklistItems.entries.map((entry) {
        return CheckboxListTile(
          activeColor: kBlueDarkColor,
          title: Text(entry.key),
          value: entry.value,
          onChanged: (newValue) {
            setState(() {
              checklistItems[entry.key] = newValue!;
            });
          },
        );
      }).toList(),
    );
  }
}