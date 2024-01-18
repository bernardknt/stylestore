
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stylestore/model/beautician_data.dart';
import 'package:stylestore/utilities/InputFieldWidget.dart';
import 'package:stylestore/utilities/constants/color_constants.dart';
import 'package:stylestore/utilities/constants/font_constants.dart';
import 'package:uuid/uuid.dart';
import 'dart:math';

import '../../Utilities/constants/user_constants.dart';






class CustomerEditPage extends StatefulWidget {
  static String id = 'customer_edit';
  @override
  _CustomerEditPageState createState() => _CustomerEditPageState();
}

class _CustomerEditPageState extends State<CustomerEditPage> {

  final RoundedLoadingButtonController _btnController = RoundedLoadingButtonController();
  final _random = new Random();
  CollectionReference customers = FirebaseFirestore.instance.collection('customers');
  DateTime now = DateTime.now();



  Future<void> updateItem(itemId) {
    // Call the user's CollectionReference to add a new user'
    // Map<String, dynamic> jsonMap = jsonDecode(preferences);
    // print(jsonMap);

    return customers.doc(itemId)
        .update({

      'phoneNumber': phoneNumber,
      'location': location,
      // 'description':preferences,
      'name': name,
      'info': note,

    })
        .then((value) => print("Message Sent"))
        .catchError((error) => print("Failed to Update Event: $error"));
  }
  @override
  void initState() {
    // TODO: implement initState
  }
  String preferences= '';
  String location = '';
  double changeInvalidMessageOpacity = 0.0;
  String invalidMessageDisplay = 'Invalid Number';
  String password = '';
  var name = '';
  int  itemAmount = 0;
  var itemId = '';
  int itemPrice = 0;
  String note = "";
  String phoneNumber = "";

  //bool showSpinner = false;
  String errorMessage = 'Error Signing Up';
  double errorMessageOpacity = 0.0;



  Widget build(BuildContext context) {

    var adminData = Provider.of<BeauticianData>(context);
    location = adminData.customerLocation;
    name = adminData.customerName;
    preferences = adminData.customerPreferences;
    note = adminData.customerNote;
    phoneNumber = adminData.customerPhoneNumber;
    return Scaffold(

      backgroundColor: Colors.white,
      appBar: AppBar(title: Text('Edit Customer', style: kNormalTextStyle.copyWith(color: kBlueDarkColorOld)),
        backgroundColor: Colors.white,
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child:
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Change Customer information', style: kNormalTextStyle.copyWith(color: kBlack),),
              ),
              Container(
                height: 150,
                width: 100,
                decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(10)), color: kPureWhiteColor,
                  image: DecorationImage(image:
                  //     CachedNetworkImage(imageUrl: '',),
                  CachedNetworkImageProvider(adminData.customerImage),
                      // NetworkImage(networkImageToUse),
                      fit: BoxFit.cover
                  ),
                ),

              ),
              Container(
                height: 400,
                child: Column(
                  //mainAxisAlignment: MainAxisAlignment.center,
                  //crossAxisAlignment: CrossAxisAlignment.stretch,

                  children: [
                    // SizedBox(height: 10.0,),


                    Opacity(
                        opacity: changeInvalidMessageOpacity,
                        child: Text(invalidMessageDisplay, style: TextStyle(color:Colors.red , fontSize: 12),)),



                    InputFieldWidget(labelText:'Client Name' ,hintText: 'James', keyboardType: TextInputType.text, controller: adminData.customerName, onTypingFunction: (value){
                      name = value;
                    },),
                    // SizedBox(height: 10.0,),
                    InputFieldWidget(labelText: 'Location', hintText: '', keyboardType: TextInputType.text,controller: adminData.customerLocation, onTypingFunction: (value){
                      location = value;
                    }),

                    InputFieldWidget(readOnly: true, labelText: 'Preferences (Maintain colon marks ":" and ",")', hintText: '', keyboardType: TextInputType.text,controller: adminData.customerPreferences, onTypingFunction: (value){
                      preferences = value;
                    }),

                    InputFieldWidget(labelText: 'Phone Number', hintText: '07000707070', keyboardType: TextInputType.text,controller: adminData.customerPhoneNumber.toString(), onTypingFunction: (value){
                      phoneNumber = value;
                    }),
                    // kLargeHeightSpacing,

                    InputFieldWidget(labelText: 'Note', hintText: 'Likes Sweaters', keyboardType: TextInputType.text,controller: adminData.customerNote, onTypingFunction: (value){
                      note = value;
                    }),

                    Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: RoundedLoadingButton(
                            color: kBlueDarkColorOld,
                            child: Text('Update Customer', style: TextStyle(color: Colors.white)),
                            controller: _btnController,
                            onPressed:
                                () async {
                              if ( preferences == '' || name == ''){
                                _btnController.error();
                                print("Prefs: $preferences , Name: $name, Location: $location, number: $phoneNumber, Note: $note");
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
                                // print("WARARARA ${adminData.itemId}");
                                updateItem(adminData.customerId);
                                Navigator.pop(context);

                                //Implement registration functionality.
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}
