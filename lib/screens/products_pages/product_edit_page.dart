
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stylestore/model/beautician_data.dart';
import 'package:stylestore/model/common_functions.dart';
import 'package:stylestore/utilities/InputFieldWidget.dart';
import 'package:stylestore/utilities/constants/color_constants.dart';
import 'package:stylestore/utilities/constants/font_constants.dart';
import 'dart:math';

class ProductEditPage extends StatefulWidget {
  static String id = 'product_edit';

  const ProductEditPage({super.key});
  @override
  _ProductEditPageState createState() => _ProductEditPageState();
}

class _ProductEditPageState extends State<ProductEditPage> {

  final RoundedLoadingButtonController _btnController = RoundedLoadingButtonController();
  final _random = Random();
  CollectionReference stores = FirebaseFirestore.instance.collection('stores');
  DateTime now = DateTime.now();
  bool selectedTrackingValue = false;
  bool selectedSaleableValue = false;
  String barcode = "";
  void defaultInitialization(){
    selectedTrackingValue = Provider.of<BeauticianData>(context, listen: false).itemTracking;
    selectedSaleableValue = Provider.of<BeauticianData>(context, listen: false).itemSaleable;
    setState(() {
    });
  }

  Future<void> updateItem(itemId) {
    return stores.doc(itemId)
        .update({
      'amount': price,
      'description': description,
      'name': item,
      'quantity': itemQuantity,
      'minimum': itemMinimumQuantity,
      'tracking': selectedTrackingValue,
      'saleable': selectedSaleableValue,
      'barcode': barcode,
      'stockTaking': [],

    })
        .then((value) => print("Message Sent"))
        .catchError((error) => print("Failed to Update Event: $error"));
  }
  @override
  void initState() {
    // TODO: implement initState
    defaultInitialization();
  }
  String description= '';
  double changeInvalidMessageOpacity = 0.0;
  String invalidMessageDisplay = 'Invalid Number';
  String password = '';
  var item = '';
  var itemId = '';
  double itemQuantity = 0;
  double itemMinimumQuantity = 0;
  double price = 0;
  String errorMessage = 'Error Signing Up';
  double errorMessageOpacity = 0.0;


  @override
  Widget build(BuildContext context) {
    var adminData = Provider.of<BeauticianData>(context);

    item = adminData.item;
    description = adminData.itemDescription;
    itemQuantity = adminData.quantity;
    price = adminData.price;
    itemMinimumQuantity = adminData.itemMinimumQuantity;
    return Scaffold(

      backgroundColor: Colors.white,
      appBar: AppBar(
        // centerTitle: false,
        // title: Text('Edit Product', style: kNormalTextStyle.copyWith(color: kBlueDarkColorOld)),
        backgroundColor: Colors.white,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerTop,
      floatingActionButton:
      GestureDetector(
        onTap: ()async {
          // ScaffoldMessenger.of(context).showSnackBar( SnackBar(content: Text('Add Barcode to $item')));
          barcode = await CommonFunctions().startBarcodeScan(context,itemId, item);

          // Get.snackbar('Add Barcode to $item', '👍',
          //   snackPosition: SnackPosition.TOP,
          //   backgroundColor: kCustomColor,
          //   colorText: kBlack,
          //   icon: Icon(Iconsax.smileys, color: kAppPinkColor,),
          // );
        },
        child: Container(
          height: 60,
          width: 60,
          decoration: BoxDecoration(
            color: kCustomColor,
            borderRadius: BorderRadius.all(Radius.circular(10)),
            boxShadow: [BoxShadow(color: kFaintGrey.withOpacity(0.5), spreadRadius: 2,blurRadius: 2 )]

          ),
          child: Icon(Iconsax.scan),
        ),
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child:
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 30.0, left: 8.0, right: 8.0, bottom: 8.0),
                child: Text('Change Product information', style: kNormalTextStyle.copyWith(color: kBlack),),
              ),
              Container(
                height: 150,
                width: 150,
                decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(10)), color: kPureWhiteColor,
                  image: DecorationImage(image:

                  CachedNetworkImageProvider(adminData.itemImage),

                      fit: BoxFit.cover
                  ),
                ),

              ),
              kSmallHeightSpacing,
              SizedBox(
                height:selectedTrackingValue == true ?500: 400,
                child: Column(

                  children: [


                    InputFieldWidget(labelText:'Product Name' ,hintText: 'Hair Lotion', keyboardType: TextInputType.text, controller: adminData.item, onTypingFunction: (value){
                      item = value;
                    },),
                    // SizedBox(height: 10.0,),
                    InputFieldWidget(labelText: 'Description (Brief about this service)', hintText: 'Great for the skin', keyboardType: TextInputType.multiline,controller: adminData.itemDescription, onTypingFunction: (value){
                      description = value;
                    }),

                    InputFieldWidget(labelText: 'Price', hintText: '10000', keyboardType: TextInputType.number,controller: adminData.price.toString(), onTypingFunction: (value){
                      price = double.parse(value);
                    }),
                    // kLargeHeightSpacing
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 20.0),
                          child: Text("Do you Sell this item or it is used by not sold?", style: kNormalTextStyle.copyWith(color: kBlack),),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [



                        Radio<bool>(
                          fillColor:CommonFunctions().convertToMaterialStateProperty(kAppPinkColor) ,
                          value: true,
                          groupValue: selectedSaleableValue,
                          onChanged: (value) {
                            setState(() {
                              selectedSaleableValue = value!;
                              print(value);
                            });
                          },
                        ),
                        Text("Sale",style: kNormalTextStyle.copyWith(color: kBlack)),
                        SizedBox(width: 16),
                        Radio<bool>(
                          fillColor:CommonFunctions().convertToMaterialStateProperty(kAppPinkColor) ,
                          value: false,
                          groupValue: selectedSaleableValue,
                          onChanged: (value) {
                            setState(() {
                              selectedSaleableValue = value!;
                              print(value);
                            });
                          },
                        ),
                        Text('Not for Sale',style: kNormalTextStyle.copyWith(color: kBlack)),

                      ],
                    ),
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 20.0),
                          child: Text("Track Stock Levels of this Product?", style: kNormalTextStyle.copyWith(color: kBlack),),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [



                        Radio<bool>(
                          fillColor:CommonFunctions().convertToMaterialStateProperty(kAppPinkColor) ,
                          value: true,
                          groupValue: selectedTrackingValue,
                          onChanged: (value) {
                            setState(() {
                              selectedTrackingValue = value!;
                              print(value);
                            });
                          },
                        ),
                        Text('Track',style: kNormalTextStyle.copyWith(color: kBlack)),
                        SizedBox(width: 16),
                        Radio<bool>(
                          fillColor:CommonFunctions().convertToMaterialStateProperty(kAppPinkColor) ,
                          value: false,
                          groupValue: selectedTrackingValue,
                          onChanged: (value) {
                            setState(() {
                              selectedTrackingValue = value!;
                              print(value);
                            });
                          },
                        ),
                        Text("Don't Track",style: kNormalTextStyle.copyWith(color: kBlack)),

                      ],
                    ),

                  selectedTrackingValue == true ?
                    InputFieldWidget(readOnly: true, labelText: 'Quantity ', hintText: '20', keyboardType: TextInputType.numberWithOptions(decimal: true),controller: adminData.quantity.toString(), onTypingFunction: (value){
                      itemQuantity = double.parse(value);
                    }) : Container(),
                    selectedTrackingValue == true ?
                    InputFieldWidget(labelText: 'Minimum Quantity', hintText: '20', keyboardType: TextInputType.numberWithOptions(decimal: true),controller: adminData.itemMinimumQuantity.toString(), onTypingFunction: (value){
                      itemMinimumQuantity = double.parse(value);
                    }) : Container(),

                    Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: RoundedLoadingButton(
                            color: kBlueDarkColorOld,
                            child: Text('Update Item', style: TextStyle(color: Colors.white)),
                            controller: _btnController,
                            onPressed:
                                () async {
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

            ],
          ),
        ),
      ),
    );
  }
}
