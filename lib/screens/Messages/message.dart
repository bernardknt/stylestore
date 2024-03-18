import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:stylestore/model/beautician_data.dart';
import 'package:stylestore/model/common_functions.dart';
import 'package:stylestore/model/styleapp_data.dart';
import 'package:stylestore/screens/Messages/bulk_message.dart';
import 'package:stylestore/widgets/success_hi_five.dart';
import '../../Utilities/constants/color_constants.dart';
import '../../Utilities/constants/font_constants.dart';
import '../../utilities/constants/user_constants.dart';



class MessagesPage extends StatefulWidget {
   static String id = 'message_page';

  @override
  _MessagesPageState createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {

  late Timer _timer;
  var goalSet= "";
  var countryName = '';
  var phoneNumber = '';
  var countrySelected = false;
  var initialCountry = "";
  var countryFlag = '';
  var countryCode = "+256";
  var name = "";
  var random = Random();
 // var inspiration = "Dear Customer, Thank you for choosing Fruts Express! We appreciate your purchase and hope our product brings you joy. For any inquiries call us on 0700457826";
  var message  = "";
  var jsonMessage ="";
  var options =[];

  late TextEditingController controller;
  CollectionReference users = FirebaseFirestore.instance.collection('users');


  late TextEditingController phoneNumberController;

  void defaultInitialization() async {
    var prov = Provider.of<StyleProvider>(context, listen: false);
    final prefs = await SharedPreferences.getInstance();
    countryCode = prefs.getString(kCountryCode) ?? "+256";
    Map<String, dynamic> jsonMap = json.decode(Provider.of<StyleProvider>(context, listen: false).invoiceSms);
    if (prov.invoicedBalance > 0){
      jsonMessage = jsonMap['reminder'];
    } else {
      jsonMessage = jsonMap['thankyou'];
    }
    options = jsonMap['options'];
    // options = ['This is a test Message', 'This is another test of what us needed', 'Can I know what to do'];
    // print(options);




    controller = TextEditingController()..text = jsonMessage;
    Provider.of<BeauticianData>(context, listen: false).setTextMessage(jsonMessage);
    message = jsonMessage;
    phoneNumberController = TextEditingController()..text = CommonFunctions().formatPhoneNumber(Provider.of<StyleProvider>(context, listen: false).invoicedCustomerNumber, countryCode);
    setState(() {

    });
  }



  @override

  void initState() {
    // TODO: implement initState
    super.initState();
    defaultInitialization();

  }
  double opacityValue = 0.0;
  final String _text = 'Hello World';





  animationTimer() async{
    final prefs = await SharedPreferences.getInstance();
    _timer = Timer(const Duration(milliseconds: 1000), () {
      opacityValue = 1.0;
      setState(() {

      });

    });
  }

  @override
  void dispose() {
    // _timer.cancel(); // Cancel the timer to prevent calling setState() after dispose()
    super.dispose();
  }

  Widget build(BuildContext context) {
    // var beauticianData = Provider.of<BeauticianData>(context, listen: false);
    var beauticianDataListen = Provider.of<BeauticianData>(context);
    return Scaffold(
      backgroundColor: kPureWhiteColor,
      appBar: AppBar(
        backgroundColor: kPureWhiteColor,
        foregroundColor: kBlack,
        elevation: 0,
        title: Icon(Icons.mark_email_read_rounded, color: kAppPinkColor,),
        actions: [
          TextButton(onPressed: (){
            showDialog(context: context, builder: (BuildContext context){
              return
                GestureDetector(
                  onTap: (){
                    Navigator.pop(context);
                  },
                  child: Material(
                    color: Colors.transparent,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListView.builder(
                        itemCount: options.length,
                        itemBuilder: (BuildContext context, int index) {
                          return GestureDetector(
                            onTap: (){
                              Navigator.pop(context);
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width > 600 ? 400 : MediaQuery.of(context).size.width * 0.87,

                              // height: 250,
                              margin: EdgeInsets.symmetric(horizontal: 0.0, vertical: 10.0),
                              decoration: BoxDecoration(
                                color: kAppPinkColor.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              child: GestureDetector(
                                onTap: (){
                                  controller = TextEditingController()..text = options[index];
                                  beauticianDataListen.setTextMessage(options[index]);
                                  Navigator.pop(context);
                                  setState(() {

                                  });
                                  // Provider.of<StyleProvider>(context, listen: false).set
                                },
                                child: ListTile(
                                  title: Text(
                                    options[index],
                                    style: TextStyle(color: Colors.white, fontSize: 14),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                );

            });


          }, child: Text("Message Variations", style: kNormalTextStyle.copyWith(color: Colors.blue),))

        ],


      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: kCustomColor,
        onPressed: () {
          showModalBottomSheet(
              isScrollControlled: true,
              context: context,
              builder: (context) {
                return const Scaffold(
                    body: BulkSmsPage());
              });

        },
        label: const Text("Send Bulk Message"),


      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Center(
            child: Container(
              width: MediaQuery.of(context).size.width > 600 ? 400 : MediaQuery.of(context).size.width * 0.87,

              padding: EdgeInsets.all(20),
              child: Column(

                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,


                children: [
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Container(
                      height: 50,
                      width: double.maxFinite,
                      // height: 53,

                      decoration: BoxDecoration(
                          color: kBackgroundGreyColor,
                          border: Border.all(width: 1, color: Colors.grey),
                          borderRadius: BorderRadius.circular(10)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            width: 10,
                          ),
                          CountryCodePicker(
                            onInit: (value){
                              countryCode = value!.dialCode!;
                              countryName = value!.name!;
                              countryFlag = value!.flagUri!;

                            },
                            onChanged: (value){
                              countryCode = value.dialCode!;
                              countryName = value.name!;
                              countryFlag = value.flagUri!;

                            },
                            // Initial selection and favorite can be one of code ('IT') OR dial_code('+39')
                            initialSelection: 'UG',
                            favorite: const ['+254','+255',"US"],
                            // optional. Shows only country name and flag
                            showCountryOnly: false,
                            // optional. Shows only country name and flag when popup is closed.
                            showOnlyCountryWhenClosed: false,
                            // optional. aligns the flag and the Text left
                            alignLeft: false,
                          ),
                          Text(
                            "|",
                            style: TextStyle(fontSize: 25, color: Colors.grey),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Expanded(
                              child:

                              TextFormField(
                                controller: phoneNumberController,
                                validator: (value){
                                  List letters = List<String>.generate(
                                      value!.length,
                                          (index) => value[index]);
                                  print(letters);


                                  if (value!=null && value.length > 10){
                                    return 'Number is too long';
                                  }else if (value == "") {
                                    return 'Enter phone number';
                                  } else if (letters[0] == '0'){
                                    return 'Number cannot start with a 0';
                                  } else if (value!= null && value.length < 9){
                                    return 'Number short';

                                  }
                                  else {
                                    return null;
                                  }
                                },


                                onChanged: (value){
                                  phoneNumber = value;
                                  Provider.of<StyleProvider>(context, listen: false).setInvoicedPhoneNumber(value);
                                },
                                keyboardType: TextInputType.phone,
                                decoration: InputDecoration(

                                    border: InputBorder.none,
                                    hintText: "771234567",
                                    hintStyle: kNormalTextStyle.copyWith(color: Colors.grey[500])

                                ),
                              ))
                        ],
                      ),
                    ),
                  ),

                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.center,
                  //   crossAxisAlignment: CrossAxisAlignment.center,
                  //   children: [
                  //     // Lottie.asset('images/talk.json', height: 150, width: 150, fit: BoxFit.contain ),
                  //     Expanded(
                  //       child: Card(
                  //
                  //         color: kCustomColor,
                  //         shape: RoundedRectangleBorder(borderRadius:BorderRadius.only(topLeft: Radius.circular(10), bottomLeft: Radius.circular(10), topRight: Radius.circular(20))),
                  //         elevation: 1.0,
                  //
                  //         child: Padding(
                  //           padding: const EdgeInsets.all(8.0),
                  //           child: Center(child:
                  //           Text(beauticianDataListen.textMessage, style: TextStyle(fontWeight: FontWeight.w400),)
                  //
                  //           ),
                  //         ),
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  kSmallHeightSpacing,

                  Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children :
                      [

                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child:

                          TextField(
                            controller:controller,
                            maxLength: 160,
                            onChanged: (enteredQuestion){
                              print(enteredQuestion);
                              message = enteredQuestion;
                              beauticianDataListen.setTextMessage(enteredQuestion);
                            },
                            maxLines: null,
                            decoration: InputDecoration(
                              border:
                              //InputBorder.none,
                              OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: Colors.green, width: 2),
                              ),
                              labelText: 'Message',
                              labelStyle: kNormalTextStyleExtraSmall,
                              hintText: '',
                              hintStyle: kNormalTextStyle,

                            ),

                          ),

                        ),
                        ElevatedButton(
                            style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(kAppPinkColor)),
                            onPressed: () async{
                              phoneNumber = CommonFunctions().formatPhoneNumber(Provider.of<StyleProvider>(context, listen: false).invoicedCustomerNumber, countryCode);

                              if (message == ''|| phoneNumber.length != 9){
                                showDialog(context: context, builder: (BuildContext context){
                                  return CupertinoAlertDialog(
                                    title: message == ''?Text('No Message entered!'):phoneNumber.length != 9?Text('Phone number needs checking'):Text("Something seems wrong"),
                                    content: message == ''?Text('Ensure a message has been typed', style: kNormalTextStyle.copyWith(color: kBlack),):phoneNumber.length != 9?Text('Ensure the number is entered or complete', style: kNormalTextStyle.copyWith(color: kBlack),):Text("Something seems wrong"),
                                    actions: [CupertinoDialogAction(isDestructiveAction: true,
                                        onPressed: (){

                                          Navigator.pop(context);


                                        },
                                        child: const Text('Cancel'))],
                                  );
                                });

                              } else {
                                showDialog(context: context, builder: (BuildContext context){
                                  return
                                    Material(
                                      color: Colors.transparent,

                                      child: Stack(
                                        children: [

                                          CupertinoAlertDialog(
                                            title: const Text('SENDING MESSAGE'),
                                            content: Column(
                                              children: [
                                                Text("${beauticianDataListen.textMessage}\n_________________________\nTo: $countryCode$phoneNumber\n_________________________\n@ 40 Ugx", style: kNormalTextStyle.copyWith(color: kBlack),),

                                              ],
                                            ),
                                            actions: [

                                              CupertinoDialogAction(isDestructiveAction: true,
                                                  onPressed: (){
                                                    // _btnController.reset();
                                                    Navigator.pop(context);
                                                  },
                                                  child: const Text('Cancel')),
                                              CupertinoDialogAction(isDefaultAction: true,
                                                  onPressed: (){
                                                    // _btnController.reset();
                                                    Provider.of<BeauticianData>(context, listen: false).setLottieImage( 'images/sending.json', "Message Sent");
                                                    CommonFunctions().sendCustomerSms(beauticianDataListen.textMessage, phoneNumber, context);
                                                    CommonFunctions().uploadMessageToServer(context, phoneNumber, false, [phoneNumber], 40.0);
                                                  },
                                                  child: const Text('Send')),

                                            ],
                                          ),


                                        ],
                                      ),
                                    );
                                });
                              }




                            }, child: Container(
                          width: 140,
                              child: Row(
                                children: [
                                  Text("Send Message", style: kNormalTextStyle.copyWith(color: kPureWhiteColor),),
                                 kSmallWidthSpacing,
                                  Icon(Icons.sms, color: kPureWhiteColor,)
                                ],
                              ),
                            )
                        ),
                          ]
                  ),
                  kSmallHeightSpacing,


                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
