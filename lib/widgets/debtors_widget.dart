


import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stylestore/utilities/constants/color_constants.dart';

import '../model/common_functions.dart';
import '../model/styleapp_data.dart';


class DebtorsChecklist extends StatefulWidget {
  @override
  // Constructor to receive the checklist
  const DebtorsChecklist({Key? key, required this.checklistItems}) : super(key: key);

  final Map<String, bool> checklistItems;

  _DebtorsChecklistState createState() => _DebtorsChecklistState();
}

class _DebtorsChecklistState extends State<DebtorsChecklist> {

  Map<String, bool> selectedItems = {};
  Map<String, bool> finalListItems = {};
  var newCustomers = [];

  void defaultInitialization()async{
    finalListItems = widget.checklistItems;

    if(Provider.of<StyleProvider>(context, listen: false).businessCustomers.length == 0){
      print("No Customers found");
      newCustomers = await CommonFunctions().retrieveCustomerData(context);
      Provider.of<StyleProvider>(context, listen: false).setBusinessCustomers(newCustomers);
    } else {
      print("Customers found");
      newCustomers = Provider.of<StyleProvider>(context, listen: false).businessCustomers;
    }
    setState(() {

    });
  }




  @override
  initState() {
    super.initState();
    defaultInitialization();
  }

  @override
  Widget build(BuildContext context) {

    return SingleChildScrollView(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min, // Keep dialog compact
          children: finalListItems.entries.map((entry) {
            return
              CheckboxListTile(
                activeColor: kBlueDarkColor,
                title: Text(entry.key),
                value: entry.value,
                onChanged: (newValue) {
                  setState(() {
                    finalListItems[entry.key] = newValue!;
                    if (newValue!) {

                      selectedItems[entry.key] = newValue!;

                     Provider.of<StyleProvider>(context, listen: false).changeDebtorChecklistValues(finalListItems);


                    } else {
                      selectedItems[entry.key] = newValue!;
                      Provider.of<StyleProvider>(context, listen: false).changeDebtorChecklistValues(finalListItems);
                    }

                  });
                },
              );
          }).toList(),
        ),
      ),
    );
  }
}