
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';
import 'package:uuid/uuid.dart';
import 'dart:math';

import '../utilities/InputFieldWidget.dart';
var uuid = Uuid();

class InputProductPage extends StatefulWidget {
  static String id = 'add_product';
  @override
  _InputProductPageState createState() => _InputProductPageState();
}

class _InputProductPageState extends State<InputProductPage> {
  final _auth = FirebaseAuth.instance;
  final RoundedLoadingButtonController _btnController = RoundedLoadingButtonController();
  final _random = new Random();
  CollectionReference items = FirebaseFirestore.instance.collection('items');
  CollectionReference ingredients = FirebaseFirestore.instance.collection('ingredients');

  Future<void> addItem() {
    // Call the user's CollectionReference to add a new user
    return items.doc(itemId)
        .set({
      'category': 'plans', // John Doe
      'description': description, // Stokes and Sons
      'name': productName,
      'price': price,
      'quantity': 10,
      'image': images[_random.nextInt(images.length)],
      'id': itemId,
      'promote': false,
      'min': 0
    })
        .then((value) => print("Item Added"))
        .catchError((error) => print("Failed to add Item: $error"));
  }
  Future<void> addIngredient() {
    // Call the user's CollectionReference to add a new user
    return ingredients.doc(itemId)
        .set({
      'category': 'vegetables', // John Doe
      // 'description': description, // Stokes and Sons
      'name': productName,
      // 'price': price,
      'quantity': 10,
      'info':'',
      'unit': unit,
      // 'image': images[_random.nextInt(images.length)],
      'id': itemId,
      'min': 0,
      'supervisor': 'Bernard',
      'supplier': 'None',
      'supplierContact': ""

    })
        .then((value) => print("Ingredient Added"))
        .catchError((error) => print("Failed to add Item: $error"));
  }

  @override
  var images = ['https://bit.ly/3ealgAb', 'https://bit.ly/3kllKHh',
    'https://bit.ly/3ievsbQ',
    'https://bit.ly/3ealgAb'];
  String itemId = 'vg${uuid.v1().split("-")[0]}';
  String description= '';
  String unit= '';
  double changeInvalidMessageOpacity = 0.0;
  String invalidMessageDisplay = 'Invalid Number';
  String password = '';
  String productName = '';
  int price = 0;


  //bool showSpinner = false;
  String errorMessage = 'Error Signing Up';
  double errorMessageOpacity = 0.0;
  String countryCode= ' ';


  Widget build(BuildContext context) {
    return Scaffold(

      backgroundColor: Colors.white,
      // appBar: AppBar(title: Text('Create Ingredient'),
      //   automaticallyImplyLeading: false,
      //   centerTitle: true,
      //   backgroundColor: Colors.black,),
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
                InputFieldWidget(labelText:' Item Name' ,hintText: 'Chicken Salad', keyboardType: TextInputType.text, onTypingFunction: (value){
                  productName = value;

                },),
                InputFieldWidget(labelText: ' Price', hintText: '20000', keyboardType: TextInputType.number,  onTypingFunction: (value){

                  price = int.parse(value);
                }),
                // SizedBox(height: 10.0,),
                InputFieldWidget(labelText: ' Description', hintText: 'Amazing Salad', keyboardType: TextInputType.text, onTypingFunction: (value){
                  description = value;
                }),



                Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: RoundedLoadingButton(
                        color: Colors.green,
                        child: Text('Add New Product', style: TextStyle(color: Colors.white)),
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
                            // addIngredient();
                            addItem();
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
