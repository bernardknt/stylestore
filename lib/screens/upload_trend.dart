import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:line_icons/line_icons.dart';
import 'package:lottie/lottie.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stylestore/utilities/constants/user_constants.dart';
import '../Utilities/constants/color_constants.dart';
import '../Utilities/constants/font_constants.dart';
import '../utilities/InputFieldWidget.dart';
import '../utilities/paymentButtons.dart';
import 'addBlog.dart';



class UploadTrendPage extends StatefulWidget {
  static String id = 'upload_trend';

  @override
  State<UploadTrendPage> createState() => _UploadTrendPageState();
}

class _UploadTrendPageState extends State<UploadTrendPage> {
  final _auth = FirebaseAuth.instance;
  CollectionReference storeItem = FirebaseFirestore.instance.collection('stores');
  CollectionReference trends = FirebaseFirestore.instance.collection('trends');
  final RoundedLoadingButtonController _btnController = RoundedLoadingButtonController();
  final storage = FirebaseStorage.instance;
  String name = '';
  String description = '';
  var price = 0;
  var imageUploaded = false;
  String errorMessage = 'Error Signing Up';
  double errorMessageOpacity = 0.0;
  CollectionReference serviceProvided = FirebaseFirestore.instance.collection('services');
  String serviceId = 'trend${uuid.v1().split("-")[0]}';
  UploadTask? uploadTask;

  //
  Future<void> uploadFile(String filePath, String fileName)async {
    File file = File(filePath);
    try {
      uploadTask  = storage.ref('test/$fileName').putFile(file);
      final snapshot = await uploadTask!.whenComplete((){
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Trend Uploaded')));

      });
      final urlDownload = await snapshot.ref.getDownloadURL();
      print("KIWEEEEEEDDDEEEEEEEEEEEEEE: $urlDownload");
      addTrend(serviceId, urlDownload);

      // Navigator.pushNamed(context, ControlPage.id);
    }  catch(e){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error Uploading: $e')));
    }
  }


  Future<void> addTrend(trendsId, image) async {
    // Call the user's CollectionReference to add a new user
    final prefs = await SharedPreferences.getInstance();
    return trends.doc(trendsId)
        .set({
      'active': true, // John Doe
      'approved': false,
      'images': image,
      'categoryName': description,
      'close': 19,
      'comments': [],
      'cord': [],
      'date': DateTime.now(),
      'doesMobile': false,
      'favourites': [],
      'id' : trendsId,
      'likers': [],
      'likes': 0,
      'location': prefs.getString(kLocationConstant),
      'open': 7,
      'phone': prefs.getString(kPhoneNumberConstant),
      'price': price,
      'sender': prefs.getString(kBusinessNameConstant),
      'title': name,
      'transport': price,
      'beautician_id': prefs.getString(kStoreIdConstant)





      // Stokes and Sons

    })
        .then((value) => Navigator.pop(context))
        .catchError((error) => print("Failed to send Communication: $error"));
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

        final sizeImageBeforeCompression = file.lengthSync() / 1024;
        print("BEFORE COMPRESSION: ${sizeImageBeforeCompression}kb");

        setState(() {
          imageUploaded = true;
          this.image = file;
        });
      }
    } on PlatformException catch (e) {
      print('Failed to pick image $e');

    }



    //
    // File? compressedImage = await testCompressAndGetFile(file);
    // final sizeImageAfterCompression = compressedImage?.lengthSync();
    // print("AFTER COMPRESSION: ${sizeImageAfterCompression!/1024}kb");
    // testCompressAndGetFile(File(image.path), 'img/img.jpg');

    // Provider.of<BeauticianData>(context, listen: false).setImageUploadData(image.path, image.name);
    // Navigator.pushNamed(context, QuoteStatusPage.id);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBlack,
      appBar: AppBar(title: Text('Add Trend', style: kNormalTextStyle.copyWith(color: kPureWhiteColor)),
        backgroundColor: kBlack,
        leading: GestureDetector(
            onTap: (){Navigator.pop(context);},
            child: Icon(Icons.arrow_back, color: kPureWhiteColor,)),
      ),
      body:
      SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Center(child:

          Column(
            children: [

              Padding(
                padding: const EdgeInsets.all(8.0),

                child:

                image != null ? Image.file(image!, height: 180,) : Container(
                  width: double.infinity,
                  height: 180,
                  child: Lottie.asset('images/woman.json'),
                  decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(10)), color: kBabyPinkThemeColor),

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
              Container(
                height: 190,
                child:

                imageUploaded != true ?
                Center(child: Text('Upload Trend Image', style: kNormalTextStyle.copyWith(color: kPureWhiteColor),),) : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  // crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [


                    InputFieldWidget(labelText:' Trend Name' ,labelTextColor: kBeigeColor, hintText: 'Rolling Crotchet Hair',hintTextColor: kFaintGrey, keyboardType: TextInputType.text, onTypingFunction: (value){
                      name = value;

                    },),
                    InputFieldWidget(labelText:' Description' ,labelTextColor: kBeigeColor, hintText: 'Get the glam Look', keyboardType: TextInputType.text, onTypingFunction: (value){
                      description = value;

                    },),
                    InputFieldWidget(labelText: ' Amount',labelTextColor: kBeigeColor,  hintText: '10000', keyboardType: TextInputType.number, onTypingFunction: (value){
                      price = int.parse(value);
                    }),
                  ],
                ),

              ),
              RoundedLoadingButton(
                width: 120,
                color: kBabyPinkThemeColor,
                child: Text('Post Trend', style: TextStyle(color: kAppPinkColor)),
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

                    uploadFile(image!.path, serviceId );


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
    );
  }
}
