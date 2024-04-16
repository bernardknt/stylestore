import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lottie/lottie.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:stylestore/utilities/constants/user_constants.dart';
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
  var quantity = 0;
  var minimum = 5;
  String errorMessage = 'Error Signing Up';
  double errorMessageOpacity = 0.0;
  CollectionReference serviceProvided = FirebaseFirestore.instance.collection('services');
  String serviceId = 'sp${uuid.v1().split("-")[0]}';
  UploadTask? uploadTask;
  bool selectedTrackingValue = false;
  bool selectedSaleableValue = true;

  //
  Future<void> uploadFile(String filePath, String fileName)async {
    File file = File(filePath);
    try {
      uploadTask  = storage.ref('test/$fileName').putFile(file);
      final snapshot = await uploadTask!.whenComplete((){

      });
      final urlDownload = await snapshot.ref.getDownloadURL();
      print("KIWEEEEEEDDDEEEEEEEEEEEEEE: $urlDownload");
      addStoreItem(serviceId, urlDownload);
      // Navigator.pushNamed(context, ControlPage.id);
    }  catch(e){
      print(e);
    }
  }

  Future<void> addStoreItem(itemId, image) async{
    final prefs = await SharedPreferences.getInstance();
    bool scannable = false;
    ScaffoldMessenger.of(context).showSnackBar( SnackBar(content: Text(' $name code: $barcode')));
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
      'description': description, // Stokes and Sons
      'name': name,
      'amount': price,
      'quantity': quantity,
      'image': image,
      'id': itemId,
      'storeId': prefs.getString(kStoreIdConstant),
      'date': DateTime.now(),
      'minimum': minimum,
      'tracking': selectedTrackingValue,
      'saleable': selectedSaleableValue,
      'stockTaking': [],
      'barcode': barcode,
      'scannable': scannable

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
              children: [

                Padding(
                  padding: const EdgeInsets.all(8.0),

                  child:

                  image != null ? Image.file(image!, height: 180,) : Container(
                    width: double.infinity,
                    height: 180,
                    child: Lottie.asset('images/beauty.json'),
                    decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(10)), color: kPureWhiteColor),

                  ),
                ),

                SizedBox(height: 30,),
                Container(
                  height: selectedTrackingValue == false ? 350 :450,

                  child: imageUploaded == true ? Center(child: Text('Upload Product Image', style: kNormalTextStyle.copyWith(color: kPureWhiteColor),),) :Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    // crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [


                      InputFieldWidget(fontColor: kPureWhiteColor, labelText:' Product / Item Name' ,labelTextColor: kBeigeColor, hintText: '',hintTextColor: kFaintGrey, controller: name,keyboardType: TextInputType.text, onTypingFunction: (value){
                        name = value;

                      },),
                      InputFieldWidget(fontColor: kPureWhiteColor, labelText:' Description' ,labelTextColor: kBeigeColor, hintText: '', keyboardType: TextInputType.text, controller: description, onTypingFunction: (value){
                        description = value;

                      },),
                      InputFieldWidget(fontColor: kPureWhiteColor, labelText: ' Amount(Price)',labelTextColor: kBeigeColor,  hintText: '10000', keyboardType: TextInputType.number, controller: price.toString(), onTypingFunction: (value){
                        price = int.parse(value);
                      }),
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
                            child: Text("Do you Need to Track Stock Levels of this Product?", style: kNormalTextStyle.copyWith(color: kPureWhiteColor),),
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

                      selectedTrackingValue == true ? InputFieldWidget(labelText: ' Quantity (Current Stock)',labelTextColor: kBeigeColor,  hintText: '10', keyboardType: TextInputType.number, onTypingFunction: (value){
                        quantity = int.parse(value);
                      }):Container(),
                      selectedTrackingValue == true ? InputFieldWidget(labelText: ' Minimum Quantity (Minimum Stock)',labelTextColor: kBeigeColor,  hintText: '2', keyboardType: TextInputType.number, onTypingFunction: (value){
                        minimum = int.parse(value);
                      }):Container(),

                    ],
                  ),

                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    RoundedLoadingButton(
                      width: 120,
                      color: kBabyPinkThemeColor,
                      child: Text('Create Product', style: TextStyle(color: kAppPinkColor)),
                      controller: _btnController,
                      onPressed: () async {
                        if ( name == '' || price == 0){
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

                          if(image?.path != null ){
                            uploadFile(image!.path, serviceId );
                          } else {
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


                      },
                      child: Container(
                        height: 45,
                        width: 45,
                        decoration: BoxDecoration(
                            color: kCustomColor,
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            boxShadow: [BoxShadow(color: kFaintGrey.withOpacity(0.5), spreadRadius: 2,blurRadius: 2 )]

                        ),
                        child: Icon(Iconsax.scan),
                      ),
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
