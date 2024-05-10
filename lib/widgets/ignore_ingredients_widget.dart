


import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stylestore/utilities/constants/color_constants.dart';

import '../model/common_functions.dart';
import '../model/styleapp_data.dart';


class IngredientsChecklist extends StatefulWidget {
  @override
  // Constructor to receive the checklist
  const IngredientsChecklist({Key? key, required this.ingredientsListItems}) : super(key: key);

  final Map<String, bool> ingredientsListItems;

  _IngredientsChecklistState createState() => _IngredientsChecklistState();
}

class _IngredientsChecklistState extends State<IngredientsChecklist> {

  Map<String, bool> selectedItems = {};
  Map<String, bool> finalListItems = {};
  var newIngredients = [];

  void defaultInitialization()async{
    finalListItems = widget.ingredientsListItems;

    if(Provider.of<StyleProvider>(context, listen: false).storeIngredients.length == 0){
      print("No Ingredients found");
      newIngredients =  await CommonFunctions().retrieveStockData(context);
      Provider.of<StyleProvider>(context, listen: false).setBusinessIngredients(newIngredients);
    } else {
      print("Customers found");
      newIngredients = Provider.of<StyleProvider>(context, listen: false).businessCustomers;
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

                      Provider.of<StyleProvider>(context, listen: false).changeIngredientsChecklistValues(finalListItems);


                    } else {
                      selectedItems[entry.key] = newValue!;
                      Provider.of<StyleProvider>(context, listen: false).changeIngredientsChecklistValues(finalListItems);
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