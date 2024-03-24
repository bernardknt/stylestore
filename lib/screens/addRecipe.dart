
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';
import 'package:uuid/uuid.dart';
import 'dart:math';

import '../utilities/InputFieldWidget.dart';
import '../utilities/constants/color_constants.dart';
import '../utilities/constants/user_constants.dart';
var uuid = Uuid();




class AddRecipePage extends StatefulWidget {
  static String id = 'add_recipe_page';
  @override
  _AddRecipePageState createState() => _AddRecipePageState();
}

class _AddRecipePageState extends State<AddRecipePage> {
  final _auth = FirebaseAuth.instance;
  final RoundedLoadingButtonController _btnController = RoundedLoadingButtonController();
  final _random = new Random();

  CollectionReference recipes = FirebaseFirestore.instance.collection('recipes');

  Future<void> addRecipe() {
    // Call the user's CollectionReference to add a new user
    return recipes.doc(itemId)
        .set({
      'name': productName,
      'id': itemId,
      'link': link

    })
        .then((value) => print("Ingredient Added"))
        .catchError((error) => print("Failed to add Item: $error"));
  }



  String itemId = 'rc${uuid.v1().split("-")[0]}';
  String description= '';
  String link= '';
  double changeInvalidMessageOpacity = 0.0;
  String invalidMessageDisplay = 'Invalid Number';

  String productName = '';
  int price = 0;


  //bool showSpinner = false;
  String errorMessage = 'Error Signing Up';
  double errorMessageOpacity = 0.0;


  @override
  Widget build(BuildContext context) {
    return Scaffold(

      backgroundColor: Colors.white,
      appBar: AppBar(title: Text('New Recipe'),
        automaticallyImplyLeading: true,
        centerTitle: true,
        backgroundColor: kBlueDarkColor,),
      body: Padding(
        padding: EdgeInsets.only(left: 20, right: 20, top: 0),

        child: SingleChildScrollView(
          child: Container(
            height: 550,

            child:
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Opacity(
                    opacity: changeInvalidMessageOpacity,
                    child: Text(invalidMessageDisplay, style: TextStyle(color:Colors.red , fontSize: 12),)),
                InputFieldWidget(labelText:' Recipe Name' ,hintText: 'Tomatoes Dressing', keyboardType: TextInputType.text, onTypingFunction: (value){
                  productName = value;

                },),

                InputFieldWidget(labelText: ' Link', hintText: 'Amazing Salad', keyboardType: TextInputType.text, onTypingFunction: (value){
                  link = value;
                }),


                Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: RoundedLoadingButton(
                        color: Colors.green,
                        child: Text('Add New Recipe', style: TextStyle(color: Colors.white)),
                        controller: _btnController,
                        onPressed: () async {
                          if ( productName == ''){
                            _btnController.error();
                            showDialog(context: context, builder: (BuildContext context){

                              return CupertinoAlertDialog(
                                title: Text('Oops Something is Missing'),
                                content: Text('Make sure you have filled in all the fields'),
                                actions: [CupertinoDialogAction(isDestructiveAction: true,
                                    onPressed: (){
                                      _btnController.reset();
                                      Navigator.pop(context);
                                    },
                                    child: Text('Cancel'))],
                              );
                            });
                          }else {
                            addRecipe();
                            // addItem();
                            // addItem();
                            Navigator.pop(context);
                            //Implement registration functionality.
                          }
                        },
                      ),
                    ),
                    Opacity(
                        opacity: errorMessageOpacity,
                        child: Text(errorMessage, style: TextStyle(color: Colors.red),))
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
