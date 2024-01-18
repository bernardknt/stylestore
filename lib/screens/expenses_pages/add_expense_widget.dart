import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stylestore/Utilities/InputFieldWidget.dart';
import 'package:stylestore/Utilities/constants/font_constants.dart';
import 'package:stylestore/screens/payment_pages/update_payment_option.dart';
import 'package:stylestore/widgets/success_hi_five.dart';

import '../../Utilities/constants/color_constants.dart';
import '../../Utilities/constants/user_constants.dart';
import '../../model/beautician_data.dart';
import '../../model/common_functions.dart';
import '../../model/styleapp_data.dart';
import '../../payment_options.dart';
import '../../widgets/modalButton.dart';


class AddExpenseWidget extends StatefulWidget {



  @override
  State<AddExpenseWidget> createState() => _AddExpenseWidgetState();
}

class _AddExpenseWidgetState extends State<AddExpenseWidget> {
  var expenseName = "";
  var supplierName = "";
  var expenseCost = "0.0";
  var expenseQuantity = "1";
  var expenseOrderNumber = "";
  var originalBasketToPost = [];

  File? image;
  var imageUploaded = false;
  final storage = FirebaseStorage.instance;
  UploadTask? uploadTask;

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

  Future<void> uploadPhoto(String filePath, String fileName)async {
    File file = File(filePath);
    try {
      uploadTask  = storage.ref('customer/$fileName').putFile(file);
      final snapshot = await uploadTask!.whenComplete((){

      });
      final urlDownload = await snapshot.ref.getDownloadURL();
      print("KIWEEEEEEDDDEEEEEEEEEEEEEE: $urlDownload");
      CommonFunctions().uploadExpense(originalBasketToPost, context, expenseOrderNumber, urlDownload);
      // addCustomer(urlDownload);
      // Navigator.pushNamed(context, ControlPage.id);
    }  catch(e){
      print(e);
    }
  }

  defaultInitilization()async {
    final prefs = await SharedPreferences.getInstance();
    expenseOrderNumber = "Expense_${CommonFunctions().generateUniqueID(prefs.getString(kBusinessNameConstant)!)}";
    setState(() {

    });
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    defaultInitilization();
  }
  @override
  Widget build(BuildContext context) {
    var styleData = Provider.of<StyleProvider>(context);

    TextEditingController controller = TextEditingController(text: expenseCost);
    TextEditingController expenseController = TextEditingController(text: "${Provider.of<StyleProvider>(context).expense}");
    // Move the cursor to the end of the text
    controller.selection = TextSelection.fromPosition(
      TextPosition(offset: controller.text.length),
    );
    return Scaffold(
      backgroundColor: kPureWhiteColor,
      appBar: AppBar(
        title:  Text('Enter Expense Details',textAlign: TextAlign.center, style: kNormalTextStyle.copyWith(fontSize: 18, color: kBlack),),
          backgroundColor: kPureWhiteColor ,
          elevation: 0
      ),
      floatingActionButton: FloatingActionButton.extended(
        splashColor: kBlueDarkColor,
        // foregroundColor: Colors.black,
        backgroundColor: kAppPinkColor,
        //blendedData.saladButtonColour,
        onPressed: () {
          // incrementPaidAmount(styleData.invoiceTransactionId, styleData.invoicedPriceToPay);
          if(expenseName!=""&&expenseCost!="0.0"){

            var basketToPost = [
              {
                'product': expenseName,
                'description': "",
                'quantity': double.tryParse(expenseQuantity) ?? 0,
                'totalPrice': double.tryParse(expenseCost) ?? 0
              }

            ];
            originalBasketToPost = basketToPost;
            image == null ? CommonFunctions().uploadExpense(basketToPost, context, expenseOrderNumber, "") : uploadPhoto(image!.path, expenseOrderNumber);
            // CommonFunctions().uploadExpense(basketToPost, context, expenseOrderNumber);
          }

        },
        // icon:  CircleAvatar(
        //     radius: 12,
        //     child: Text("${Provider.of<StyleProvider>(context).basketItems.length}", style:kNormalTextStyle.copyWith(color: kBlack) ,)),
        label: expenseName != ""?Text(
          '$expenseName worth Ugx $expenseCost',
          style: kNormalTextStyle.copyWith(color: kPureWhiteColor),
        ):Text("Enter Expense", style: kNormalTextStyle.copyWith(color: kPureWhiteColor)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniCenterFloat,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 20.0),
          child: Container(
            height: 450,
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
              //  Text('Enter Expense Details',textAlign: TextAlign.center, style: kNormalTextStyle.copyWith(fontSize: 25, color: kBlack),),
                kLargeHeightSpacing,
                Padding(
                  padding: const EdgeInsets.only(left:20.0),
                  child: Row(
                    // mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Ugx',
                        style: kNormalTextStyle.copyWith(fontSize: 18),
                      ),
                      kSmallWidthSpacing,

                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            border: InputBorder.none,

                          ),
                          controller: controller,
                          // TextEditingController()..text ='${Provider.of<StyleProvider>(context).totalPrice}',
                          textAlign: TextAlign.start,
                          style: kNormalTextStyle.copyWith(fontSize: 50),
                          keyboardType: TextInputType.number,
                          onChanged: (value){
                            expenseCost = value;
                            // print(value);
                            // if (value!= ""){
                            //   expenseCost = value;
                            //   // Provider.of<StyleProvider>(context, listen: false).setInvoicedPriceToPay(int.parse(value));
                            // } else {
                            //  // Provider.of<StyleProvider>(context, listen: false).setInvoicedPriceToPay(int.parse("0"));
                            // }

                          },
                        ),
                      ),
                    ],
                  ),
                ),
                kLargeHeightSpacing,
                InputFieldWidget(controller: expenseName,labelText:' Expense Name' ,hintText: 'Transport', keyboardType: TextInputType.text, onTypingFunction: (value){
                  expenseName = value ;

                },),
                kLargeHeightSpacing,
                InputFieldWidget(controller: expenseQuantity,labelText:' Expense Quantity' ,hintText: '', keyboardType: TextInputType.number, onTypingFunction: (value){
                  expenseQuantity = value ;

                },),
                kLargeHeightSpacing,
                InputFieldWidget(controller: expenseName,labelText:' Supplier' ,hintText: 'House of Plastics', keyboardType: TextInputType.text, onTypingFunction: (value){
                  supplierName = value ;

                },),
                kSmallHeightSpacing,

                image != null ?
                Image.file(image!, height: 150,) :
                GestureDetector(
                  onTap: (){

                    showModalBottomSheet(
                        context: context,
                        builder: (BuildContext context) {
                          return Container(
                            color: Color(0xFF292929).withOpacity(0.6),
                            child: Container(
                              decoration: BoxDecoration(
                                  color: kPureWhiteColor,
                                  borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30) )
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(top: 20.0, bottom: 50, left: 20),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children:
                                  [
                                    buildButton(context, 'Select from Gallery', Iconsax.gallery,
                                            () async {
                                          Navigator.pop(context);
                                          pickImage(ImageSource.gallery);


                                        }
                                    ),
                                    SizedBox(height: 16.0),
                                    buildButton(context, 'Select from Camera', Iconsax.camera,  () async {
                                      Navigator.pop(context);
                                      pickImage(ImageSource.camera);
                                    } ),
                                  ],
                                ),
                              ),
                            ),
                          ); });
                  },
                  child: Container(
                    width: 150,
                    height: 150,
                    // Lottie.asset('images/scan.json'),
                    decoration: BoxDecoration(

                        border: Border.all(color: kFontGreyColor),

                        borderRadius: const BorderRadius.all(Radius.circular(0)),
                        color: kBlack),
                    child:
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Icon(Icons.photo_camera_front_outlined, color: kBlack,size: 30,),
                        Text("Add Receipt\nOr Payment proof",textAlign: TextAlign.center, style: kNormalTextStyle.copyWith(color: kPureWhiteColor, fontWeight: FontWeight.w500, fontSize: 14,),),
                      ],
                    ),


                  ),
                ),
                // Container(
               //     height: 50,
               //     child: InputFieldWidget(hintText: "Transport", onTypingFunction:(value){}, keyboardType: TextInputType.text, labelText: " Expense")),
             //  Text('${Provider.of<StyleProvider>(context, listen: false).invoicedCustomer}',textAlign: TextAlign.center, style: kNormalTextStyle.copyWith(fontSize: 16),),
               // Text('Invoiced Amount: ${CommonFunctions().formatter.format(Provider.of<StyleProvider>(context, listen: false).invoicedTotalPrice)} Ugx',textAlign: TextAlign.center, style: kNormalTextStyle.copyWith(fontSize: 16),),
             //   Text('Paid Amount: ${CommonFunctions().formatter.format(Provider.of<StyleProvider>(context, listen: false).invoicedPaidPrice)} Ugx',textAlign: TextAlign.center, style: kNormalTextStyle.copyWith(fontSize: 16),),


              ],
            ),
          ),
        ),
      ),
    );
  }
}
