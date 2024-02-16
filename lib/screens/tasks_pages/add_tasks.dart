import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:stylestore/Utilities/constants/font_constants.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../Utilities/constants/color_constants.dart';
import '../../Utilities/constants/user_constants.dart';
import '../../model/common_functions.dart';
import '../../model/styleapp_data.dart';
// ignore: depend_on_referenced_packages
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
  String? selectedEmployeeName;
  final Set<DateTime> _selectedDates = {};
  CalendarFormat _calendarFormat = CalendarFormat.month;
  List<String> employeeNames = [];

  Future<void> _fetchEmployeeNames() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('employees')
        .where("storeId", isEqualTo: storeId)
        .get();
    List<String> names =
        querySnapshot.docs.map((doc) => doc['name'] as String).toList();
    setState(() {
      employeeNames = ['Everyone', ...names];
      // selectedEmployeeName = (names.isNotEmpty ? names[0] : null)!;
    });
  }

  Future<void> uploadTask() async {
    final dateNow = new DateTime.now();
    CollectionReference userOrder =
        FirebaseFirestore.instance.collection('tasks');
    final prefs = await SharedPreferences.getInstance();
    // ignore: use_build_context_synchronously
    showDialog(
        context: context,
        builder: (context) {
          return const Center(
              child: CircularProgressIndicator(
            color: kAppPinkColor,
          ));
        });

    String orderId = '${DateTime.now()}${uuid.v1().split("-")[0]}';

    return userOrder.doc(orderId).set({
      'createdBy': prefs.getString(kLoginPersonName),
      'createdDate': dateNow,
      'dueDate':
          Provider.of<StyleProvider>(context, listen: false).invoicedDate,
      'selectedDates': _selectedDates,
      'status': false,
      'id': orderId,
      'storeId': prefs.getString(kStoreIdConstant),
      'token': prefs.getString(kToken),
      'task': taskToDo,
      'from': prefs.getString(kEmployeeId),
      'to': selectedEmployeeName,
      'toName': selectedEmployeeName
    }).then((value) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Task created and ready for action.')));

      Navigator.pop(context);
      Navigator.pop(context);

      // updateNotifyArray(token);
    }).catchError((error) => print("Failed to add user: $error"));
  }

  defaultInitilization() async {
    final prefs = await SharedPreferences.getInstance();
    storeId = prefs.getString(kStoreIdConstant) ?? "";
    taskToSend = Provider.of<StyleProvider>(context, listen: false).taskToDo;
    taskToDo = taskToSend;
    expenseOrderNumber =
        "Expense_${CommonFunctions().generateUniqueID(prefs.getString(kBusinessNameConstant)!)}";
    _fetchEmployeeNames();
    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    defaultInitilization();
    // selectedEmployeeName = 'Everyone';
  }

  @override
  Widget build(BuildContext context) {
    var styleData = Provider.of<StyleProvider>(context);

    TextEditingController controller = TextEditingController(text: taskToSend);
    TextEditingController expenseController = TextEditingController(
        text: "${Provider.of<StyleProvider>(context).expense}");

    return Scaffold(
      backgroundColor: kPureWhiteColor,
      appBar: AppBar(
          title: Text(
            'Create Task',
            textAlign: TextAlign.center,
            style: kNormalTextStyle.copyWith(
                fontSize: 18, color: kBlack, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          backgroundColor: kPureWhiteColor,
          elevation: 0),
      floatingActionButton: FloatingActionButton.extended(
        splashColor: kBlueDarkColor,
        backgroundColor: kAppPinkColor,
        onPressed: () {
          if (taskToDo != "" &&
              selectedEmployeeName != null &&
              _selectedDates.isNotEmpty) {
            uploadTask();
          } else {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Missing Value'),
                  content: Text(
                      'Please fill in all required fields.\nStatus\n* Dates: ${_selectedDates.length} entered!\n* Employee: ${selectedEmployeeName ?? 'None'} entered\n* Task: ${taskToDo == "" ? 'None' : 'Task Entered'}'),
                  actions: [
                    TextButton(
                      child: Text('OK'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              },
            );
          }
        },
        label: Text("Create Task",
            style: kNormalTextStyle.copyWith(color: kPureWhiteColor)),
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.miniCenterFloat,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 20.0),
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    "Assign Task To:",
                    style: kNormalTextStyle.copyWith(
                        color: kBlack, fontWeight: FontWeight.bold),
                  ),
                  kMediumWidthSpacing,
                  kMediumWidthSpacing,
                  DropdownButton<String>(
                    value: selectedEmployeeName,
                    onTap: () {
                      Provider.of<StyleProvider>(context, listen: false)
                          .setTaskToDo(taskToDo);
                      setState(() {});
                    },
                    onChanged: (newValue) {
                      Provider.of<StyleProvider>(context, listen: false)
                          .setTaskToDo(taskToDo);
                      setState(() {
                        selectedEmployeeName = newValue!;
                      });
                    },
                    hint: Text(
                      'Select Employee',
                    ),
                    items: employeeNames
                        .map<DropdownMenuItem<String>>((String name) {
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
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: kBackgroundGreyColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextField(
                    controller: controller,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: 'Call customer to pay invoice',
                      hintStyle:
                          kNormalTextStyle.copyWith(color: kFontGreyColor),
                      border: InputBorder.none,
                    ),
                    style: kNormalTextStyle.copyWith(color: kBlack),
                    onChanged: (value) {
                      // Provider.of<StyleProvider>(context, listen: false).setTransactionNote(value);
                      taskToDo = value;
                    },
                  ),
                ),
              ),
              Text(
                  _selectedDates.isEmpty
                      ? 'No Dates selected'
                      : 'Active for ${_selectedDates.length} Days\n${_selectedDates.map((date) => DateFormat('d MMM yyyy').format(date)).join(', ')}',
                  style: kNormalTextStyle.copyWith(color: kGreenThemeColor)),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Add a text button to select the date and time for the task to be done
                    TableCalendar(
                      selectedDayPredicate: (day) {
                        return _selectedDates.contains(day);
                      },
                      onDaySelected: (selectedDay, focusedDay) {
                        // if (selectedDay.isBefore(DateTime.now())) {
                        //   print("Not allowed");
                        //   return; // Do not allow selection of past dates
                        // }
                        if (_selectedDates.contains(selectedDay)) {
                          setState(() {
                            _selectedDates.remove(selectedDay);
                          });
                        } else {
                          setState(() {
                            _selectedDates.add(selectedDay);
                          });
                        }
                      },
                      focusedDay: DateTime.now(),
                      firstDay: DateTime.now(),
                      lastDay: DateTime.now().add(Duration(days: 365 * 2)),
                      calendarFormat: _calendarFormat,
                      onFormatChanged: (format) {
                        setState(() {
                          _calendarFormat = format;
                        });
                      },
                      startingDayOfWeek: StartingDayOfWeek.sunday,
                      daysOfWeekVisible: true,
                    ),
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
