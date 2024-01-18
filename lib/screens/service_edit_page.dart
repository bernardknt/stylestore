
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stylestore/model/beautician_data.dart';
import 'package:stylestore/utilities/constants/color_constants.dart';
import 'package:stylestore/utilities/constants/font_constants.dart';
import 'package:uuid/uuid.dart';
import 'dart:math';

import '../utilities/InputFieldWidget.dart';
import '../utilities/constants/user_constants.dart';
var uuid = Uuid();




class ServicesEditPage extends StatefulWidget {
  static String id = 'services_edit';
  @override
  _ServicesEditPageState createState() => _ServicesEditPageState();
}

class _ServicesEditPageState extends State<ServicesEditPage> {

  final RoundedLoadingButtonController _btnController = RoundedLoadingButtonController();
  final _random = new Random();
  CollectionReference services = FirebaseFirestore.instance.collection('services');
  DateTime now = DateTime.now();

  void defaultsInitiation () async{
    final prefs = await SharedPreferences.getInstance();
    String newName = prefs.getString(kBusinessNameConstant)!;
    setState(() {
      name = newName;
    });
  }

  Future<void> updateItem(itemId) {
    // Call the user's CollectionReference to add a new user

    return services.doc(itemId)
        .update({

      'min': itemMinimumQuantity,
      'info': description,
      'name': item,
      'quantity': itemQuantity,
      'date': now,
      'updatedBy': name
    })
        .then((value) => print("Message Sent"))
        .catchError((error) => print("Failed to Update Event: $error"));
  }
@override
  void initState() {
    // TODO: implement initState
    defaultsInitiation();
  }
  @override

  String communicationsId = 'cm${uuid.v1().split("-")[0]}';
  String name = ' ';
  String description= '';
  double changeInvalidMessageOpacity = 0.0;
  String invalidMessageDisplay = 'Invalid Number';
  String password = '';
  var item;
  double  itemMinimumQuantity = 0;
  var itemId;
  double itemQuantity = 0;
  var price;
  var date;

  //bool showSpinner = false;
  String errorMessage = 'Error Signing Up';
  double errorMessageOpacity = 0.0;



  Widget build(BuildContext context) {
    var adminData = Provider.of<BeauticianData>(context);
    var adminDataEdit = Provider.of<BeauticianData>(context, listen: false);
    itemMinimumQuantity = adminData.itemMinimumQuantity;
    item = adminData.item;
    description = adminData.itemDescription;
    itemQuantity = adminData.quantity;
    price = adminData.itemPrice;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text('Edit Service', style: kNormalTextStyle.copyWith(color: kBlueDarkColorOld)),
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.only(left: 20, right: 20, top: 0),

        child: Container(
          height: 400,
          // color: Colors.red,
          child: Column(
            //mainAxisAlignment: MainAxisAlignment.center,
            //crossAxisAlignment: CrossAxisAlignment.stretch,

            children: [
              // SizedBox(height: 10.0,),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Make changes to this Service information', style: kNormalTextStyle.copyWith(color: kBlack),),
              ),

              Opacity(
                  opacity: changeInvalidMessageOpacity,
                  child: Text(invalidMessageDisplay, style: TextStyle(color:Colors.red , fontSize: 12),)),
              InputFieldWidget(labelText:'Service' ,hintText: 'Hair cut', keyboardType: TextInputType.text, controller: adminData.item, onTypingFunction: (value){
                item = value;
              },),
              // SizedBox(height: 10.0,),
              InputFieldWidget(labelText: 'Description (Brief about this service)', hintText: 'A nice haircut to keep your head fresh', keyboardType: TextInputType.multiline,controller: adminData.itemDescription, onTypingFunction: (value){
                description = value;
              }),

              InputFieldWidget(labelText: 'Base Price (Minimum price for this item in Ugx)', hintText: '10000', keyboardType: TextInputType.numberWithOptions(decimal: true),controller: adminData.quantity.toString(), onTypingFunction: (value){
                itemQuantity = double.parse(value);
              }),
              // InputFieldWidget(labelText: 'Minimum Quantity (${adminData.itemUnit})', hintText: '20', keyboardType: TextInputType.number,controller: adminData.itemMinimumQuantity.toString(), onTypingFunction: (value){
              //   itemMinimumQuantity = int.parse(value);
              // }),

              Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: RoundedLoadingButton(
                      color: kBlueDarkColorOld,
                      child: Text('Update Item', style: TextStyle(color: Colors.white)),
                      controller: _btnController,
                      onPressed: () async {
                        if ( description == '' || item == ''){
                          _btnController.error();
                          print("Desc: $description , Item: $item");
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
                          updateItem(adminData.itemId);
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
      ),
    );
  }
}
