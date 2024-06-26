import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:line_icons/line_icons.dart';
import 'package:lottie/lottie.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stylestore/utilities/constants/user_constants.dart';
import '../Utilities/constants/color_constants.dart';
import '../Utilities/constants/font_constants.dart';
import '../controllers/responsive/responsive_page.dart';
import '../model/common_functions.dart';
import '../utilities/InputFieldWidget.dart';
import '../utilities/paymentButtons.dart';
import 'addBlog.dart';



class StoreSetup extends StatefulWidget {
  static String id = 'store_setup';

  @override
  State<StoreSetup> createState() => _StoreSetupState();
}

class _StoreSetupState extends State<StoreSetup> {
  final _auth = FirebaseAuth.instance;
  CollectionReference storeLocation = FirebaseFirestore.instance.collection('medics');
  final RoundedLoadingButtonController _btnController = RoundedLoadingButtonController();
  final storage = FirebaseStorage.instance;
  String name = '';
  String description = '';
  String businessName = '';
  String location = '';
  String type = '';
  var imageUploaded = false;
  var price = 0;
  var user = FirebaseAuth.instance.currentUser;
  String errorMessage = 'Error Signing Up';
  double errorMessageOpacity = 0.0;
  CollectionReference serviceProvided = FirebaseFirestore.instance.collection('services');
  String serviceId = 'store${uuid.v1().split("-")[0]}';
  UploadTask? uploadTask;

  //
  Future<void> uploadFile(String filePath, String fileName)async {
    File file = File(filePath);
    try {
      uploadTask  = storage.ref('store/$fileName').putFile(file);
      final snapshot = await uploadTask!.whenComplete((){

      });
      final urlDownload = await snapshot.ref.getDownloadURL();
      putStoreProfilePicture(user!.uid, urlDownload);

    }  catch(e){
      print(e);
    }
  }

  Future<void> putStoreProfilePicture(userId, image) async{
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(kImageConstant, image);
    var firestore = FirebaseFirestore.instance;
    await firestore.collection('users').doc(userId).update({
      'subscribed': false,
      'lastName': prefs.getString(kLoginPersonName),
      'firstName': prefs.getString(kLoginPersonName),
      'countryCode': prefs.getString(kCountryCode),




    });
    return storeLocation.doc(userId)
        .update({
      'image': image,
      'name': businessName,
      'location': location,
      'description': type,
      'countryCode': prefs.getString(kCountryCode),
      'restock': false,
      'realert': false,
      'report': false,
      'permissions': '{"transactions": true,"expenses": true,"customers": true,"sales": true,"store": true,"analytics": true,"messages": true,"tasks": true,"admin": true,"summary": true,"employees": true,"notifications": true,"signIn": false,"takeStock": true, "qrCode": false}'

    })
        .then((value) {
          Navigator.pushNamed(context,SuperResponsiveLayout.id);



        })
        .catchError((error) => print("Failed to add Item: $error"));
  }

  File? image;

  Future pickImage(ImageSource source)async{
    try {
      final image = await ImagePicker().pickImage(source: source);
      // await ImagePicker().pickImage(source: ImageSource.gallery);

      if (image == null){
        return ;
      }else {
        var file = File(image.path);

        final compressedImage = await CommonFunctions().compressImage(File(image.path));

        setState(() {
          imageUploaded = true;
          this.image = compressedImage;
        });
      }
    } on PlatformException catch (e) {
      print('Failed to pick image $e');

    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBlack,
      appBar: AppBar(title: Text('Setup Store', style: kNormalTextStyle.copyWith(color: kPureWhiteColor)),
        backgroundColor: kBlack,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            width: MediaQuery.of(context).size.width > 600 ? 400 : MediaQuery.of(context).size.width * 0.87,

            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Center(child:

              Column(
                children: [


                  Padding(
                    padding: const EdgeInsets.all(8.0),

                    child:

                    image != null ? Image.file(image!, height: 180,) :
                    Container(
                      width: double.infinity,
                      height: 180,
                      child:

                      // Lottie.asset('images/beauty.json'),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Iconsax.camera),
                          imageUploaded != true ? Center(child: Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Text('Set Store Logo or Image', style: kNormalTextStyle.copyWith(color: kBlack),),
                          ),) :
                          Container(),
                        ],
                      ),
                      decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(10)), color: kPureWhiteColor),

                    ),
                  ),
                  SizedBox(height: 20,),
                  Padding(
                    padding: const EdgeInsets.only(left: 20.0,right: 20.0),
                    child: paymentButtons(
                      continueFunction: () {
                        pickImage(ImageSource.gallery);



                      }, continueBuyingText: "Gallery", checkOutText: 'Camera', buyFunction: (){
                      pickImage(ImageSource.camera);
                    }, lineIconFirstButton: Icons.photo,lineIconSecondButton:  LineIcons.camera,),
                  ),
                  SizedBox(height: 30,),
                  imageUploaded != true ? Center(child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text('Set Store Logo or Image', style: kNormalTextStyle.copyWith(color: kPureWhiteColor),),
                  ),) :
                  Container(),
                  imageUploaded != true ? Container():
                      Container(
                        height: 190,
                        child: Column(
                          children: [
                            InputFieldWidget(labelText: ' Business Name', hintText: '', keyboardType: TextInputType.text, onTypingFunction: (value){
                              businessName = value;
                            },),
                            InputFieldWidget(labelText: ' Business Location', hintText: '', keyboardType: TextInputType.text, onTypingFunction: (value){
                              location = value;
                            },),

                            InputFieldWidget(labelText: ' What you deal in', hintText: '', keyboardType: TextInputType.text, onTypingFunction: (value){
                              type = value;
                            },),

                          ],
                        ),
                      ),
                  RoundedLoadingButton(
                    width: 120,
                    color: kBabyPinkThemeColor,
                    child: Text('Setup Store', style: TextStyle(color: kAppPinkColor)),
                    controller: _btnController,
                    onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();
                      if ( imageUploaded != true || type == "" || location ==""|| businessName ==""){
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

                        prefs.setString(kLocationConstant, location );
                        prefs.setString(kBusinessNameConstant, businessName );

                        print("WAFUFUZOZOZOZ location: $location, name: $businessName");

                        uploadFile("image!.path", serviceId );
                        // Navigator.pop(context);

                        //Implement registration functionality.
                      }
                    },
                  ),
                  Opacity(
                      opacity: errorMessageOpacity,
                      child: Text(errorMessage, style: TextStyle(color: Colors.red),)),
                ],
              )),
            ),
          ),
        ),
      ),
    );
  }
}
