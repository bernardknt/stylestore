
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'dart:math';

import '../utilities/InputFieldWidget.dart';
import '../utilities/constants/user_constants.dart';
var uuid = Uuid();




class AddBlogPage extends StatefulWidget {
  static String id = 'add_blog_page';
  @override
  _AddBlogPageState createState() => _AddBlogPageState();
}




class _AddBlogPageState extends State<AddBlogPage> {
  final _auth = FirebaseAuth.instance;
  final RoundedLoadingButtonController _btnController = RoundedLoadingButtonController();
  final _random = new Random();
  CollectionReference blogs = FirebaseFirestore.instance.collection('blogs');
  // CollectionReference ingredients = FirebaseFirestore.instance.collection('ingredients');
  String sharedBy = ' ';
  String blogLabel = ' ';
  String imageUrl= ' ';
  String webUrl = ' ';


  Future<void> addBlog() async{
    final prefs = await SharedPreferences.getInstance();
    DateTime now = DateTime.now();

    // Call the user's CollectionReference to add a new user
    return blogs.doc(blogsId)
        .set({
      'blog': description, // John Doe
      'comments': [], // Stokes and Sons
      'heading': blogHeading,
      'id': blogsId,
      'label': blogLabel,
      'image': images[_random.nextInt(images.length)],
      'likers': [],
      'likes': 0,
      'promote': true,
      'sender': sharedBy,
      'senderId': prefs.getString(kEmailConstant),
      'time': now,
      'url': webUrl,

    })
        .then((value) => print("Item Added"))
        .catchError((error) => print("Failed to add Item: $error"));
  }





  var images = ['https://bit.ly/3ealgAb', 'https://bit.ly/3kllKHh',
    'https://bit.ly/3ievsbQ',
    'https://bit.ly/3ealgAb'];
  String blogsId = 'vg${uuid.v1().split("-")[0]}';
  String description= '';
  String unit= '';
  double changeInvalidMessageOpacity = 0.0;
  String invalidMessageDisplay = 'Invalid Number';
  String password = '';
  String blogHeading = '';
  int price = 0;


  //bool showSpinner = false;
  String errorMessage = 'Error Signing Up';
  double errorMessageOpacity = 0.0;
  String countryCode = ' ';



  @override

  Widget build(BuildContext context) {
    return Scaffold(

      backgroundColor: Colors.white,
      appBar: AppBar(title: Text('Create Blog'),
        // automaticallyImplyLeading: false,
        centerTitle: true,
        backgroundColor: Colors.black,),
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
                InputFieldWidget(labelText:' Blog Heading' ,hintText: 'Why are some people happy fat', keyboardType: TextInputType.text, onTypingFunction: (value){
                  blogHeading = value;

                },),
                // InputFieldWidget(labelText: ' Price', hintText: '20000', keyboardType: TextInputType.number,  onTypingFunction: (value){
                //
                //   price = int.parse(value);
                // }),
                // SizedBox(height: 10.0,),
                InputFieldWidget(labelText: ' Short Description', hintText: 'Many people find it easy to live life on the fast lane. Here is why', keyboardType: TextInputType.text, onTypingFunction: (value){
                  description = value;
                }),
                InputFieldWidget(labelText: ' Shared By', hintText: 'Blendit Doctor', keyboardType: TextInputType.text, onTypingFunction: (value){
                  sharedBy = value;
                }),
                InputFieldWidget(labelText: ' Sender', hintText: 'Weight Loss', keyboardType: TextInputType.text, onTypingFunction: (value){
                  blogLabel = value;
                }),

                // SizedBox(height: 8.0,),
                InputFieldWidget(labelText: ' Image Link', hintText: 'www.blendit.com', keyboardType: TextInputType.text, onTypingFunction: (value){
                  imageUrl = value;
                }),
                InputFieldWidget(labelText: ' Web Link', hintText: 'www.blendit.com', keyboardType: TextInputType.text, onTypingFunction: (value){
                  webUrl = value;
                }),



                Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: RoundedLoadingButton(
                        color: Colors.green,
                        child: Text('Add New Blog', style: TextStyle(color: Colors.white)),
                        controller: _btnController,
                        onPressed: () async {
                          if ( blogHeading == ''||blogLabel == ""|| description ==""||imageUrl == ""|| webUrl ==""||sharedBy ==""){
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
                            addBlog();
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
