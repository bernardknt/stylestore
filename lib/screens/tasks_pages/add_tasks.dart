

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:stylestore/Utilities/constants/font_constants.dart';
import '../../Utilities/constants/color_constants.dart';
import '../../Utilities/constants/user_constants.dart';
import '../../model/common_functions.dart';
import '../../model/styleapp_data.dart';
import 'package:intl/intl.dart';
import '../MobileMoneyPages/mobile_money_page.dart';
import '../calendar_pages/invoiced_date_calendar.dart';


class AddTasksWidget extends StatefulWidget {



  @override
  State<AddTasksWidget> createState() => _AddTasksWidgetState();
}

class _AddTasksWidgetState extends State<AddTasksWidget> {
  var taskToDo = "";

  var supplierName = "";
  var storeId = "";
  var taskToSend = "";
  var expenseQuantity = "1";
  var expenseOrderNumber = "";
  var originalBasketToPost = [];
  String selectedEmployeeName = 'Everyone';

  List<String> employeeNames = [];


  Future<void> _fetchEmployeeNames() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('employees').where("storeId", isEqualTo: storeId).get();
    List<String> names = querySnapshot.docs.map((doc) => doc['name'] as String).toList();
    setState(() {
      employeeNames = ['Everyone', ...names];
      selectedEmployeeName = (names.isNotEmpty ? names[0] : null)!;
    });
  }
  Future<void> uploadTask ()async {
    final dateNow = new DateTime.now();
    CollectionReference userOrder = FirebaseFirestore.instance.collection('tasks');
    final prefs =  await SharedPreferences.getInstance();
    showDialog(context: context,
        builder: ( context) {
          return const Center(child: CircularProgressIndicator(color: kAppPinkColor,));});

    String orderId = '${DateTime.now()}${uuid.v1().split("-")[0]}';

    return userOrder.doc(orderId)
        .set({
      'createdBy': prefs.getString(kLoginPersonName),
      'createdDate': dateNow,
      'dueDate':Provider.of<StyleProvider>(context, listen: false).invoicedDate,
      'status':false,
      'id': orderId,
      'storeId': prefs.getString(kStoreIdConstant),
      'token': prefs.getString(kToken),
      'task': taskToDo,
      'from': prefs.getString(kEmployeeId),
      'to': selectedEmployeeName,
      'toName': selectedEmployeeName

    })
        .then((value) {
      ScaffoldMessenger.of(context).showSnackBar( SnackBar(content: Text('Task created and ready for action.')));

      Navigator.pop(context);
      Navigator.pop(context);


      // updateNotifyArray(token);

    } )
        .catchError((error) => print("Failed to add user: $error"));
  }


  defaultInitilization()async {
    final prefs = await SharedPreferences.getInstance();
    storeId = prefs.getString(kStoreIdConstant)?? "";
    taskToSend = Provider.of<StyleProvider>(context, listen: false).taskToDo;
    taskToDo = taskToSend;
    expenseOrderNumber = "Expense_${CommonFunctions().generateUniqueID(prefs.getString(kBusinessNameConstant)!)}";
    _fetchEmployeeNames();
    setState(() {

    });
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    defaultInitilization();
    selectedEmployeeName = 'Everyone';

  }
  @override
  Widget build(BuildContext context) {
    var styleData = Provider.of<StyleProvider>(context);

    TextEditingController controller = TextEditingController(text: taskToSend);
    TextEditingController expenseController = TextEditingController(text: "${Provider.of<StyleProvider>(context).expense}");
    // Move the cursor to the end of the text
    // controller.selection = TextSelection.fromPosition(
    //   TextPosition(offset: controller.text.length),
    // );
    return Scaffold(
      backgroundColor: kPureWhiteColor,
      appBar: AppBar(
          title:  Text('Create Task',textAlign: TextAlign.center, style: kNormalTextStyle.copyWith(fontSize: 18, color: kBlack),),
          centerTitle: true,
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
          if(taskToDo!="" && selectedEmployeeName != null){
            uploadTask();



          }

        },
        // icon:  CircleAvatar(
        //     radius: 12,
        //     child: Text("${Provider.of<StyleProvider>(context).basketItems.length}", style:kNormalTextStyle.copyWith(color: kBlack) ,)),
        label:Text("Create Task", style: kNormalTextStyle.copyWith(color: kPureWhiteColor)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniCenterFloat,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 20.0),
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text("Assign Task To:",style: kNormalTextStyle.copyWith(color: kBlack),),
                  kSmallWidthSpacing,
                  DropdownButton<String>(
                    value: selectedEmployeeName,
                    onTap: (){
                      Provider.of<StyleProvider>(context, listen: false).setTaskToDo(taskToDo);
                      setState(() {

                      });
                    },

                    onChanged: (newValue) {
                      Provider.of<StyleProvider>(context, listen: false).setTaskToDo(taskToDo);
                      setState(() {

                        selectedEmployeeName = newValue!;
                      });
                    },

                    items: employeeNames.map<DropdownMenuItem<String>>((String name) {
                      return DropdownMenuItem<String>(
                        value: name,
                        child: Text(name),
                      );
                    }).toList(),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child:

                TextField(
                  controller:controller,
                  // maxLength: 200,
                  onChanged: (enteredQuestion){

                    taskToDo = enteredQuestion;
                    // beauticianDataListen.setTextMessage(enteredQuestion);
                  },
                  maxLines: null,
                  decoration: InputDecoration(
                    border:
                    //InputBorder.none,
                    OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.green, width: 2),
                    ),
                    labelText: 'Task',
                    labelStyle: kNormalTextStyleExtraSmall,
                    hintText: 'Call customer to pay invoice',
                    hintStyle: kNormalTextStyle,

                  ),

                ),

              ),
              Padding(
                padding: const EdgeInsets.all(15.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Row(
                  //   children: [
                  //     Text("Assign Task To:",style: kNormalTextStyle.copyWith(color: kBlack),),
                  //     kSmallWidthSpacing,
                  //     DropdownButton<String>(
                  //       value: selectedEmployeeName,
                  //       onTap: (){
                  //         Provider.of<StyleProvider>(context, listen: false).setTaskToDo(taskToDo);
                  //         setState(() {
                  //
                  //         });
                  //       },
                  //
                  //       onChanged: (newValue) {
                  //         Provider.of<StyleProvider>(context, listen: false).setTaskToDo(taskToDo);
                  //         setState(() {
                  //
                  //           selectedEmployeeName = newValue!;
                  //         });
                  //       },
                  //
                  //       items: employeeNames.map<DropdownMenuItem<String>>((String name) {
                  //         return DropdownMenuItem<String>(
                  //           value: name,
                  //           child: Text(name),
                  //         );
                  //       }).toList(),
                  //     ),
                  //   ],
                  // ),

                  TextButton
                    (
                      onPressed: (){
                        Navigator.push(context, MaterialPageRoute(
                          builder: (context) => InvoicedDateCalendarPage(),
                        ),
                        );

                      }, child:
                  Text('Task Due Date: ${DateFormat('dd MMMM yyy k:mm').format(Provider.of<StyleProvider>(context, listen: false).invoicedDate) }'
                    // '${DateFormat('dd MMMM yyy k:mm').format(Provider.of<StyleProvider>(context, listen: false).invoicedDate)
                    , style: kNormalTextStyle.copyWith(color: Colors.blueAccent),)),
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

