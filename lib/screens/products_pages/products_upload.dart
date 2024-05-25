import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lottie/lottie.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:stylestore/utilities/constants/user_constants.dart';
import 'package:stylestore/utilities/constants/word_constants.dart';
import 'package:stylestore/widgets/scanner_widget.dart';
import '../../Utilities/constants/color_constants.dart';
import '../../Utilities/constants/font_constants.dart';
import '../../model/common_functions.dart';
import '../../utilities/InputFieldWidget.dart';
import '../addBlog.dart';



class ProductUpload extends StatefulWidget {
  static String id = 'upload_product';

  @override
  State<ProductUpload> createState() => _ProductUploadState();
}

class _ProductUploadState extends State<ProductUpload> {
  final _auth = FirebaseAuth.instance;
  CollectionReference storeItem = FirebaseFirestore.instance.collection('stores');
  final RoundedLoadingButtonController _btnController = RoundedLoadingButtonController();
  final storage = FirebaseStorage.instance;
  String name = '';
  String barcode ="";
  String description = '';
  var imageUploaded = false;
  var price = 0;
  double quantity = 0.0;
  double minimum = 5.0;
  String errorMessage = 'Error Signing Up';
  double errorMessageOpacity = 0.0;
  CollectionReference serviceProvided = FirebaseFirestore.instance.collection('services');
  String serviceId = '';
  UploadTask? uploadTask;
  bool selectedTrackingValue = false;
  bool selectedSaleableValue = true;
  TextEditingController minimumController = TextEditingController();
  TextEditingController quantityController = TextEditingController();
  String selectedUnit = "pcs";

  //
  Future<void> uploadFile(String filePath, String fileName)async {
    File file = File(filePath);
    try {
      uploadTask  = storage.ref('test/$fileName').putFile(file);
      final snapshot = await uploadTask!.whenComplete((){

      });
      final urlDownload = await snapshot.ref.getDownloadURL();
      addStoreItem(serviceId, urlDownload);
    }  catch(e){
      print(e);
    }
  }

  Future<void> addStoreItem(itemId, image) async{
    final prefs = await SharedPreferences.getInstance();
    bool scannable = false;
    // ScaffoldMessenger.of(context).showSnackBar( SnackBar(content: Text(' $name code: $barcode')));
    if(barcode == ""){
      barcode = itemId;

    } else {
      scannable = true;
    }

    ScaffoldMessenger.of(context).showSnackBar( SnackBar(content: Text(' $name code: $barcode')));
    // Call the user's CollectionReference to add a new user
    return storeItem.doc(itemId)
        .set({
      'active': true,
      'approved': true,
      'description': CommonFunctions().removeLeadingTrailingSpaces(description), // Stokes and Sons
      'name': CommonFunctions().removeLeadingTrailingSpaces(name) ,
      'amount': price,
      'quantity': quantity,
      'unit': selectedUnit,
      'image': image,
      'id': itemId,
      'storeId': prefs.getString(kStoreIdConstant),
      'date': DateTime.now(),
      'minimum': minimum,
      'tracking': selectedTrackingValue,
      'saleable': selectedSaleableValue,
      'stockTaking': [],
      'barcode': barcode,
      'scannable': scannable,
      'ignore'  : false

    })
        .then((value) => print("Item Added"))
        .catchError((error) => print("Failed to add Item: $error"));
  }


  File? image;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBlack,
      appBar: AppBar(title: Text('Add a Product / Item', style: kNormalTextStyle.copyWith(color: kPureWhiteColor)),
        backgroundColor: kBlack,
        leading: GestureDetector(
            onTap: (){Navigator.pop(context);},
            child: Icon(Icons.arrow_back, color: kPureWhiteColor,)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: GestureDetector(
                onTap: (){
                  showDialog(context: context, builder: (BuildContext context){
                    return
                      CupertinoAlertDialog(
                        title: const Text('30s Video on Adding products'),
                        content: Text("This will take you to a short video on stock taking", style: kNormalTextStyle.copyWith(color: kBlack),),
                        actions: [

                          CupertinoDialogAction(isDestructiveAction: true,
                              onPressed: (){
                                // _btnController.reset();
                                Navigator.pop(context);
                              },
                              child: const Text('Cancel')),


                        ],
                      );
                  });
                },
                child: Lottie.asset("images/video2.json", width: 40)),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Center(child:

          Container(
            width: MediaQuery.of(context).size.width > 600 ? 400 : MediaQuery.of(context).size.width * 1.5,

            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Padding(
                  padding: const EdgeInsets.all(8.0),

                  child:

                  image != null ? Image.file(image!, height: 180,) : Container(
                    width: double.infinity,
                    height: 180,
                    child: !kIsWeb?Lottie.asset("images/beauty.json", width: 40):Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Iconsax.box, size: 50,),
                        kLargeHeightSpacing, 
                        Text("Add Product")
                      ],
                    ),
                    decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(10)), color: kPureWhiteColor),

                  ),
                ),

                SizedBox(height: 30,),
                Container(
                  height: selectedTrackingValue == false ? 350 :450,

                  child: imageUploaded == true ? Center(child: Text('Upload Product Image', style: kNormalTextStyle.copyWith(color: kPureWhiteColor),),) :Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [


                      InputFieldWidget(
                        fontColor: kPureWhiteColor,
                        labelText: 'Product / Item Name',
                        labelTextColor: kPureWhiteColor,
                        hintText: '',
                        hintTextColor: kFaintGrey,
                        controller: name,
                        keyboardType: TextInputType.text,
                        onTypingFunction: (value) {
                          name = value;
                        },
                      ),
                      InputFieldWidget(fontColor: kPureWhiteColor, labelText:' Description' ,labelTextColor: kBeigeColor, hintText: '', keyboardType: TextInputType.text, controller: description, onTypingFunction: (value){
                        description = value;

                      },),

                      InputFieldWidget(fontColor: kPureWhiteColor, labelText: ' Amount(Price)',labelTextColor: kBeigeColor,  hintText: '10,000', keyboardType: TextInputType.number, controller: price.toString(), onTypingFunction: (value){
                        price = int.parse(value);
                      }),
                      Padding(
                        padding: const EdgeInsets.only(left: 20.0),
                        child: Text("Unit of Measurement", style: kNormalTextStyle.copyWith(color: Colors.grey, fontSize: 12),),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20.0),
                        child: DropdownButton<String>(
                          style: kNormalTextStyle.copyWith(color: kPureWhiteColor),
                          icon: Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Icon(Icons.scale, color: kBeigeColor,),
                          ),
                          dropdownColor: kBlueDarkColor,
                          iconSize: 14,
                          value: selectedUnit, // The currently selected department
                          items: unitList
                              .map((units) => DropdownMenuItem(
                            value: units,
                            child: Text(units,),
                          ))
                              .toList(),
                          onChanged: (newItem) => setState(() => selectedUnit = newItem!), // Update the selected department when a new one is chosen
                          hint: Text(
                              'Select Unit', style: kNormalTextStyle.copyWith(color: kPureWhiteColor),), // Placeholder text before a department is selected
                        ),
                      ),
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 20.0),
                            child: Text("Do you Sell this item or it is used but not sold?", style: kNormalTextStyle.copyWith(color: kPureWhiteColor),),
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
                          Text("Sale",style: kNormalTextStyle.copyWith(color: kPureWhiteColor)),
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
                          Text('Not for Sale',style: kNormalTextStyle.copyWith(color: kPureWhiteColor)),

                        ],
                      ),

                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 20.0),
                            child: Text("Do you Track Stock Levels of this Product?", style: kNormalTextStyle.copyWith(color: kPureWhiteColor),),
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
                          Text('Track',style: kNormalTextStyle.copyWith(color: kPureWhiteColor)),
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
                          Text("Don't Track",style: kNormalTextStyle.copyWith(color: kPureWhiteColor)),

                        ],
                      ),

                      selectedTrackingValue == true ? InputFieldWidget(fontColor: kPureWhiteColor,controller: quantity.toString(),labelText: ' Quantity (Current Stock)',labelTextColor: kBeigeColor,  hintText: '10', keyboardType: TextInputType.number, onTypingFunction: (value){
                        quantity = double.parse(value);
                      }):Container(),
                      selectedTrackingValue == true ? InputFieldWidget(
                          labelText: ' Minimum Quantity (Minimum Stock)',
                          labelTextColor: kBeigeColor,  hintText: '2',
                          keyboardType: TextInputType.number,
                          controller:minimum.toString(),
                          fontColor: kPureWhiteColor,
                          onTypingFunction: (value){
                            minimum = double.parse(value);
                      }):Container(),

                    ],
                  ),

                ),
                barcode ==""?Container():Padding(
                  padding: const EdgeInsets.only(left:18.0, top: 8, bottom: 8),
                  child: Row(
                    children: [
                      Text("Barcode Number: $barcode", style: kNormalTextStyle.copyWith(color: kGreenThemeColor, fontWeight: FontWeight.w600),),
                      kMediumWidthSpacing,
                      Icon(Iconsax.barcode, color: kAppPinkColor,)
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    RoundedLoadingButton(
                      width: 120,
                      color: kBabyPinkThemeColor,
                      child: Text('Create Product', style: TextStyle(color: barcode!=""?kGreenThemeColor:kAppPinkColor)),
                      controller: _btnController,
                      onPressed: () async {
                        if ( name == '' || price == 0){
                          print(name);
                          print(price);

                          _btnController.error();
                          showDialog(context: context, builder: (BuildContext context){
                            return
                              CupertinoAlertDialog(
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
                          String initials = await CommonFunctions().getBusinessInitials();
                          if(image?.path != null ){

                            serviceId = '$initials${uuid.v1().split("-")[0]}';
                            uploadFile(image!.path, serviceId );
                          } else {
                            serviceId = '$initials${uuid.v1().split("-")[0]}';
                            addStoreItem(serviceId, "https://mcusercontent.com/f78a91485e657cda2c219f659/images/14f4afc4-ffaf-4bb1-3384-b23499cf0df7.png");
                          }

                          Navigator.pop(context);

                          //Implement registration functionality.
                        }
                      },
                    ),
                    kMediumWidthSpacing,
                    GestureDetector(
                      onTap: ()async {

                        barcode = await CommonFunctions().startBarcodeScan(context,"", name);
                        setState(() {
                          
                        });



                      },
                      child:
                        ScannerWidget(backgroundColor: kBlack,scannerColor: barcode == ""?kPureWhiteColor:kGreenThemeColor,)
                      // Container(
                      //   height: 45,
                      //   width: 45,
                      //   decoration: BoxDecoration(
                      //       color: kCustomColor,
                      //       borderRadius: BorderRadius.all(Radius.circular(10)),
                      //       boxShadow: [BoxShadow(color: kFaintGrey.withOpacity(0.5), spreadRadius: 2,blurRadius: 2 )]
                      //
                      //   ),
                      //   child: Icon(Iconsax.scan),
                      // ),
                    ),

                  ],
                ),
                Opacity(
                    opacity: errorMessageOpacity,
                    child: Text(errorMessage, style: TextStyle(color: Colors.red),)),
              ],
            ),
          )),
        ),
      ),
    );
  }
}
