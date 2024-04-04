


import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stylestore/Utilities/constants/font_constants.dart';
import 'package:stylestore/Utilities/constants/user_constants.dart';
import 'package:stylestore/model/common_functions.dart';
import 'package:stylestore/model/styleapp_data.dart';
import 'package:stylestore/screens/expenses_pages/add_expense_widget.dart';
import 'package:stylestore/screens/team_pages/add_employee_page.dart';
import 'package:stylestore/widgets/TicketDots.dart';
import '../../Utilities/InputFieldWidget.dart';
import '../../Utilities/constants/color_constants.dart';
import '../../model/beautician_data.dart';
import '../../widgets/custom_popup.dart';
import '../../widgets/locked_widget.dart';
import '../../widgets/modalButton.dart';
import '../customer_pages/add_customers_page.dart';
import 'employee_permissions_page.dart';
import '../payment_pages/record_payment_widget.dart';
import '../products_pages/restock_page.dart';


class TeamPage extends StatefulWidget {
  static String id = 'team_page';

  @override
  _TeamPageState createState() => _TeamPageState();
}

class _TeamPageState extends State<TeamPage> {
  late int price = 0;
  late int quantity = 1;
  DateTime? _previousDate;
  var storeName = "";
  var location = "";
  var phoneNumber = "";
  var detailValue = "";
  var detailName = "";
  var formatter = NumberFormat('#,###,000');
  Map<String, dynamic> permissionsMap = {};
  Map<String, dynamic> videoMap = {};

  void defaultInitialization()async{
    var prefs = await SharedPreferences.getInstance();
    permissionsMap = await CommonFunctions().convertPermissionsJson();
    videoMap = await CommonFunctions().convertWalkthroughVideoJson();
    storeName = prefs.getString(kBusinessNameConstant)!;
    location = prefs.getString(kLocationConstant)!;
    phoneNumber = prefs.getString(kPhoneNumberConstant)!;
    setState(() {
    });
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    defaultInitialization();
    print(Provider.of<StyleProvider>(context, listen: false).beauticianId);

  }

  var nameList = [];
  var roleList = [];
  var permissionsList = [];
  var phoneNumberList = [];
  List<Map<String, dynamic>> signedInList = [];
  var codeList = [];
  var employeeIdList = [];
  var statusList = [];
  var checkList = [];
  var paidStatusList = [];
  var paidStatusListColor = [];
  List<double> opacityList = [];

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  double textSize = 14.0;
  String fontFamilyMont = 'Montserrat-Medium';
  @override
  Widget build(BuildContext context) {double width = MediaQuery.of(context).size.width * 0.6;
  var styleData = Provider.of<StyleProvider>(context, listen: false);

  return Scaffold(
      backgroundColor: kPureWhiteColor,
      appBar: AppBar(
        title: Text("Team", style: kNormalTextStyle.copyWith(fontWeight: FontWeight.bold, color: kBlack),),
        backgroundColor: kPureWhiteColor,
        elevation: 0,
        centerTitle: true,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniCenterFloat,
      floatingActionButton: permissionsMap['employees'] == false ?Container(): FloatingActionButton(
          backgroundColor: kAppPinkColor,
          onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context)=> AddEmployeePage()));
          },
          child: Icon(CupertinoIcons.add, color: kPureWhiteColor,)
      ),


      body: permissionsMap['employees'] == false ? LockedWidget(page: "Team",): StreamBuilder<QuerySnapshot> (
          stream: FirebaseFirestore.instance
              .collection('employees').where('storeId', isEqualTo:
          Provider.of<StyleProvider>(context, listen: false).beauticianId)
              .snapshots(), builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(color:kAppPinkColor,),
              );
            }
            if(!snapshot.hasData){
              return Container();
            }else{

              nameList = [];
              roleList = [];
              employeeIdList = [];
              statusList = [];
              permissionsList = [];
              signedInList = [];
              var orders = snapshot.data?.docs;
              for( var doc in orders!){
                nameList.add(doc['name']);
                employeeIdList.add(doc['id']);
                roleList.add(doc['role']);
                statusList.add(doc['active']);
                checkList.add(doc['checklist']);
                permissionsList.add(doc['permissions']);
                codeList.add(doc['code']);
                phoneNumberList.add(doc['phoneNumber']);
                signedInList.add(doc['signedIn']);
                print(signedInList[0].values.join(""));
              }

              return
                nameList.isEmpty ?
                CustomPopupWidget(backgroundColour: kBlueDarkColor,actionButton: 'Add Staff', subTitle: 'Manange your Team Together', image: 'team.jpg', title: 'Coordinate Your Team', function:
                    () {

                      Navigator.push(context, MaterialPageRoute(builder: (context)=> AddEmployeePage()));
                }, youtubeLink: videoMap['team']
                  ,
                ):
                Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                        itemCount: nameList.length,
                        shrinkWrap: true,
                        primary: false,

                        itemBuilder: (context, index){

                          return Column(


                            children: [

                              GestureDetector(
                                onTap: (){
                                  showModalBottomSheet(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return Container(
                                          color: Colors.transparent,
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
                                                  buildButton(context, 'Change ${nameList[index]} Permissions', Iconsax.edit,
                                                          () async {
                                                        Provider.of<BeauticianData>(context, listen: false).setEmployeeDetails(nameList[index], phoneNumberList[index], roleList[index],CommonFunctions().convertJsonString( permissionsList[index]), codeList[index], employeeIdList[index]);
                                                        Navigator.pop(context);
                                                        Navigator.push(context, MaterialPageRoute(builder: (context)=> EmployeePermissionsPage()));
                                                      }
                                                  ),
                                                  kLargeHeightSpacing,
                                                  buildButton(context, 'Share ${nameList[index]} Credentials', Iconsax.share,  () async {
                                                    Share.share('Login instructions for ${nameList[index]}\n1. Start by downloading the Businesspilot  app on ios or android.\n2. On the login page, click on the "Join Business as Staff Member".\n3.Enter the phone number and code below\n4. Login.\nNumber: ${phoneNumberList[index]}\nCode: ${codeList[index]}', subject: 'Login to Kola');
                                                  } ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      }
                                      );
                                  },
                                child: Card(
                                  margin: const EdgeInsets.fromLTRB(25.0, 8.0, 25.0, 8.0),
                                  shape: RoundedRectangleBorder(borderRadius:BorderRadius.circular(10)),
                                  shadowColor: kAppPinkColor,
                                  elevation: 0.0,
                                  child: Column(
                                    children: [

                                      ListTile(
                                        title:Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            // priceList[index]!= paidAmountList[index]?Icon(Icons.flag_circle,color: Colors.red, size: 15,):Container(),
                                            kSmallWidthSpacing,

                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisAlignment: MainAxisAlignment.start,

                                              children: [
                                                Text( "${nameList[index]} ",overflow: TextOverflow.clip, style: TextStyle(fontFamily: fontFamilyMont,fontSize: textSize, fontWeight: FontWeight.bold)),
                                                Text("Position: ${roleList[index]}", style: kNormalTextStyle.copyWith(fontSize: 14),),
                                                Text(phoneNumberList[index], style: kNormalTextStyle.copyWith(fontSize: 12),),

                                              ],
                                            ),
                                          ],
                                        ),
                                        trailing: signedInList[index].values.join() == "true"?
                                        Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Icon(Icons.circle,size: 15, color: kGreenThemeColor,),
                                            Text("Signed In", style: kNormalTextStyle.copyWith(fontSize: 12),),
                                            Text(signedInList[index].keys.join(''), style: kNormalTextStyle.copyWith(fontSize: 12),)

                                          ],
                                        ):Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Icon(Icons.circle,size: 15, color: kRedColor,),
                                            Text("Signed Out", style: kNormalTextStyle.copyWith(fontSize: 12),),
                                            Text(signedInList[index].keys.join(''), style: kNormalTextStyle.copyWith(fontSize: 12),)
                                          ],
                                        )

                                        //Text( "Active\n${statusList[index]} ",overflow: TextOverflow.clip, style: TextStyle(fontFamily: fontFamilyMont,fontSize: 14, color: statusList[index] == true? kGreenThemeColor: kRedColor)),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        }
                    ),
                  ),
                  // const Text("Today's Last 4 Transactions",style: kNormalTextStyle,),
                ],
              );
            }
          }
      )
  );
  }
  Widget _buildButton(BuildContext context, String title, IconData icon, Function() execute) {
    return GestureDetector(
      onTap: execute,
      child: Column(

        children: [
          TicketDots(mainColor: kBlack, circleColor: kPureWhiteColor, ),
          Row(
            children: [
              Icon(icon),
              kMediumWidthSpacing,
              Text(title, style: kNormalTextStyle.copyWith(color: kBlack, fontSize: 16),),
            ],
          ),
        ],
      ),
    );
  }
  String _getDateSeparator(DateTime date) {
    if (date.difference(DateTime.now()).inDays == 0) {
      return 'Today';
    } else if (date.difference(DateTime.now()).inDays == -1) {
      return 'Yesterday';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}



