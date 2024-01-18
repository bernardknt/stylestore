import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:slider_button/slider_button.dart';
import 'package:stylestore/Utilities/constants/user_constants.dart';
import 'package:stylestore/model/common_functions.dart';
import 'package:stylestore/screens/tasks_pages/add_tasks.dart';
import 'package:stylestore/widgets/dividing_line_widget.dart';

import '../../Utilities/constants/color_constants.dart';
import '../../Utilities/constants/font_constants.dart';
import '../../model/styleapp_data.dart';
import '../../utilities/showDialogFunc.dart';

class TasksWidget extends StatefulWidget {
  const TasksWidget({Key? key}) : super(key: key);

  @override
  State<TasksWidget> createState() => _TasksWidgetState();
}

class _TasksWidgetState extends State<TasksWidget> {

  var orderStatus = [];
  var colours = [];
  var location = [];
  var storeLocation = "";
  var createdBy = [];

  var idList = [];
  var fromList = [];
  var formatter = NumberFormat('#,###,000');

  var pages = ['New Orders: 0}', 'DetoxPlansPage.id', 'SaladsPage.id', 'TropicalPage.id '];
  // var orderContents = [];
  var instructions = [];
  var createdDate = [];
  var dueDate = [];
  var bookingFee = [];
  var taskList = [];
  var cardColor = [];
  var textColor = [];
  var phoneCircleColor = [];
  var names = [];
  var appointmentsToday = [];
  // var customerPhone = [];
  var statusList = [];
  var bellOpacity = [];
  List <Color> onlineStatusColour = [];
  var totalBill= [];
  var newOrderNumber = 0;
  late bool isCheckedIn;

  String businessName = 'Business';
  String userName = "";
  String employeeId = "";
  String image = '';
  String storeId = '';

  void defaultInitialization()async {
    final prefs = await SharedPreferences.getInstance();
    storeId = prefs.getString(kStoreIdConstant)??"";
    userName = prefs.getString(kLoginPersonName)??"";
    employeeId = prefs.getString(kEmployeeId)??"";

    setState(() {

    });
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    defaultInitialization();

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPureWhiteColor,

      floatingActionButton:
      Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: FloatingActionButton.extended(
          splashColor: kCustomColor,
          // foregroundColor: Colors.black,
          backgroundColor: kAppPinkColor,
          //blendedData.saladButtonColour,
          onPressed: () async {
            Provider.of<StyleProvider>(context, listen: false).setTaskToDo("");
            showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (context) {
                  return Scaffold(
                      appBar: AppBar(
                        automaticallyImplyLeading: false,
                        backgroundColor: kPureWhiteColor,
                        elevation: 0,
                      ),
                      body: AddTasksWidget());
                });
          },






          // icon: Icon(Icons.toggle_off_outlined, color: kPureWhiteColor,) ,
          label: Text(
            'Add Task',
            style: kNormalTextStyle.copyWith(color: kPureWhiteColor),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('tasks')
                .where('storeId', isEqualTo: storeId)
                .orderBy('createdDate',descending: true)
                .snapshots(),
            builder: (context, snapshot)
            {
              if(!snapshot.hasData){
                return Container();
              }else{
                createdBy = [];
                location = [];
                idList = [];
                orderStatus = [];
                createdDate = [];
                dueDate = [];
                taskList = [];
                instructions = [];
                totalBill= [];
                statusList= [];
                onlineStatusColour= [];
                bellOpacity = [];
                cardColor = [];
                textColor = [];
                phoneCircleColor = [];
                bookingFee = [];
                fromList = [];

                var orders = snapshot.data?.docs;
                for( var order in orders!){
                  if(order.get('status')!= true){

                    if (order.get('to')== "Everyone" || order.get('to') ==  userName || order.get('from') == employeeId){
                      DateTime appointmentDateTime = order.get('dueDate').toDate();
                      createdBy.add(order.get('createdBy'));
                      idList.add(order.get('id'));
                      fromList.add(order.get('from'));
                      orderStatus.add(order.get('status'));
                      createdDate.add(order.get('createdDate')
                          .toDate());
                      dueDate.add(order.get('dueDate')
                          .toDate());
                      taskList.add(order.get('task'));
                      statusList.add(order.get("toName"));


                      if (appointmentDateTime.day == DateTime
                          .now().day && appointmentDateTime.month == DateTime.now().month) {
                        bellOpacity.add(1.0);
                        onlineStatusColour.add(kGreenThemeColor);
                        appointmentsToday.add(order.get('toName'));
                        cardColor.add(kBlueDarkColorOld);
                        phoneCircleColor.add(kAppPinkColor);
                        textColor.add(kPureWhiteColor);
                      } else {
                        bellOpacity.add(0.0);
                        onlineStatusColour.add(kAppPinkColor);
                        cardColor.add(kCustomColor.withOpacity(0.3));
                        phoneCircleColor.add(kBlueDarkColorOld);
                        textColor.add(kBlack);
                      }

                    }

                  }
                }
                // return Text('Let us understand this ${deliveryTime[3]} ', style: TextStyle(color: Colors.white, fontSize: 25),);
                return idList.length == 0 ?
                Container(
                  child: Center(child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Iconsax.designtools5, color: kAppPinkColor,),
                      Text("Your Tasks will appear here", style: kNormalTextStyle,),
                    ],
                  )),
                )
                // Center(child: Text("Nothing"),)
                  :
                  StaggeredGridView.countBuilder(
                      crossAxisCount: 2,
                      itemCount: idList.length,
                      crossAxisSpacing: 10,
                      // physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true ,
                      itemBuilder: (context, index){
                        return Stack(
                            children: [
                              GestureDetector(
                                onTap: (){
                                //  Provider.of<BeauticianData>(context, listen: false).changeOrderDetails(createdBy[index], location[index], idList[index], createdDate[index], taskList[index], orderContents[index], orderStatus[index], customerPhone[index], totalBill[index].toDouble(), bookingFee[index].toDouble(), dueDate[index]);
                                //  showDialogFunc(context, orderStatus[index], location[index], createdBy[index], idList[index], orderContents[index], taskList[index], createdDate[index] );
                                showDialog(context: context, builder: (BuildContext context){
                                return GestureDetector(
                                    onTap: (){
                                      Navigator.pop(context);
                                    },
                                    child: Material(
                                      color: Colors.transparent,
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [

                                        Padding(
                                          padding: const EdgeInsets.all(15.0),
                                          child: Container(
                                           
                                              
                                              decoration: BoxDecoration(
                                                color:  kBiegeThemeColor,
                                                borderRadius: BorderRadius.all(Radius.circular(10))
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: Text('${taskList[index]}',textAlign: TextAlign.center, style: kNormalTextStyleDark.copyWith(color: kBlack, fontSize: 20),),
                                              )),
                                        ),
                                            kLargeHeightSpacing,
                                            kLargeHeightSpacing,
                                            kLargeHeightSpacing,
                                            SliderButton(

                                              action: () {
                                                // changeOrderStatus();
                                                 Navigator.pop(context);
                                                 CommonFunctions().updateDocumentFromServer(idList[index], "tasks", "status", true);
                                                // print(time);
                                                // Navigator.pushNamed(context, AppointmentSummary.id);
                                              },
                                              ///Put label over here
                                              label: Text(
                                                "Mark Task as Done",
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 17),
                                              ),
                                              icon: Icon(Iconsax.tick_circle,color: kPureWhiteColor,size: 30,),

                                              //Put BoxShadow here
                                              boxShadow: BoxShadow(
                                                color: Colors.black,
                                                blurRadius: 4,
                                              ),


                                              width: 250,
                                              radius: 100,
                                              buttonColor: kAppPinkColor,
                                              backgroundColor: kBiegeThemeColor,
                                              highlightedColor: Colors.black,
                                              baseColor: kAppPinkColor,
                                            ),
                                          ],
                                        )));
                                });

                                },
                                child: Container(
                                  margin: EdgeInsets.only(top: 10, right: 0, left: 0, bottom: 3),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: cardColor[index],
                                  ),
                                  child: Column(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(10),
                                        //height: 170,
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            fromList[index]== employeeId?
                                            Text('Sent By You', style: kNormalTextStyleDark.copyWith(color: kRedColor),):
                                            Text('By: ${createdBy[index]}', style: kNormalTextStyleDark.copyWith(color: textColor[index]),),
                                            // DividingLine(),
                                            Text('${taskList[index]}', style: kNormalTextStyleDark.copyWith(color: textColor[index]),),

                                            // DividingLine(),
                                            Text('Due: ${DateFormat('dd-MMM-yyyy ').format(dueDate[index])}',style: kNormalTextStyleDark.copyWith(color: textColor[index]),),
                                                // '${DateFormat('dd-MMM-yyyy ').format(dueDate[index])
                                          //  }
                                           // ', style: kNormalTextStyleDark.copyWith(color: textColor[index]),),
                                            fromList[index]== employeeId? Text(statusList[index], style: kNormalTextStyleDark.copyWith(color: textColor[index]),): SizedBox(),


                                            // Text('Bill : ${formatter.format(bookingFee[index])} Ugx', style: kNormalTextStyleDark.copyWith(color: textColor[index]),),
                                            kLargeHeightSpacing,
                                            kLargeHeightSpacing


                                          ],),
                                      ),

                                    ],
                                  ),
                                ),
                              ),
                              // Positioned(
                              //   top: 0,
                              //   right: 0,
                              //   child:GestureDetector(
                              //     onTap:(){
                              //
                              //
                              //     },
                              //     child:CircleAvatar(
                              //       radius: 15,
                              //       child: Icon(CupertinoIcons.phone, color: kPureWhiteColor,),
                              //       backgroundColor: phoneCircleColor[index],
                              //     ),
                              //   ),
                              //
                              // ),
                              Positioned(
                                left: 10,
                                bottom: 10,


                                child: Opacity(
                                  opacity: 1,
                                  child: Container(


                                    decoration:  BoxDecoration(
                                        color: onlineStatusColour[index],
                                        borderRadius: BorderRadius.all(Radius.circular(6))
                                    ),
                                    child:  Padding(
                                      padding: EdgeInsets.all(3.0),
                                      child: Row(
                                        children: [
                                          Text(statusList[index], style: kNormalTextStyleWhitePendingLabel.copyWith(fontSize: 10),),
                                          // Lottie.asset('images/new_order.json',height: 20)
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 12,
                                bottom: 5,


                                child: Opacity(
                                  opacity: bellOpacity[index],
                                  child: Lottie.asset('images/ring.json', height: 30),
                                ),
                              ),
                            ]
                        );
                      }, staggeredTileBuilder: (index)=> StaggeredTile.fit(1));
              }
            }
        ),
      ),
    );
  }
}
