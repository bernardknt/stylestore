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
import '../employee_pages/employee_details.dart';

class AddTasksWidget extends StatefulWidget {
  @override
  State<AddTasksWidget> createState() => _AddTasksWidgetState();
}

class _AddTasksWidgetState extends State<AddTasksWidget> {
  var taskToDo = "";
  TextEditingController controller = TextEditingController(text: "");
  var supplierName = "";
  var storeId = "";
  var taskToSend = "";
  var expenseQuantity = "1";
  var expenseOrderNumber = "";
  var originalBasketToPost = [];
  String? selectedEmployeeName;
  List<DateTime> _selectedDates = [];
  List<DateTime> _selectedTime = [];
  late TextEditingController _textFieldController;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  List<String> employeeNames = [];
  List<AllEmployeeData> employeeListRetrieved = [];
  List<String> selectedEmployeeNames = [];
  List<String> selectedEmployeeTokens = [];
  List<String> selectedEmployeePhone = [];
  List<String> selectedEmployeeEmail= [];

  Future<List<AllEmployeeData>> retrieveEmployeeData() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('employees')
          .where('storeId', isEqualTo: Provider.of<StyleProvider>(context, listen: false).beauticianId)
          .orderBy('name', descending: false)
          .get();

      final employeeDataList = snapshot.docs
          .map((doc) => AllEmployeeData.fromFirestore(doc))
          .toList();
      return employeeDataList;
    } catch (error) {
      return [];
    }
  }


  Future<void> _showTimePicker(BuildContext context, DateTime day) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(DateTime.now().add(Duration(minutes: 30))),
    );

    if (pickedTime != null) {
      setState(() {
        _selectedTime.add(DateTime(
            day.year,
            day.month,
            day.day,
            pickedTime.hour,
            pickedTime.minute
        ));
        print(_selectedTime);
      });
    }
  }



  String _formatTime(DateTime time) {
    return DateFormat('hh:mm a').format(time);
  }

  Future<void> uploadTask() async {
    final dateNow = new DateTime.now();
    CollectionReference userOrder =
        FirebaseFirestore.instance.collection('tasks');
    final prefs = await SharedPreferences.getInstance();

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
      'dueDate': Provider.of<StyleProvider>(context, listen: false).invoicedDate,
      'selectedDates': _selectedTime,
      'completed': List.filled(_selectedDates.length, false),
      'track':List.filled(_selectedDates.length, "do"),
      'executedAt': List.filled(_selectedDates.length, DateTime.now()),
      'finishedAt': List.filled(_selectedDates.length, DateTime.now()),
      'executedBy': List.filled(_selectedDates.length, "Blank"),
      'finishedBy': List.filled(_selectedDates.length, "Blank"),
      'status': false,
      'id': orderId,
      'storeId': prefs.getString(kStoreIdConstant),
      'token': prefs.getString(kToken),
      'task': taskToDo,
      'from': prefs.getString(kEmployeeId),
      'to': selectedEmployeeNames,
      'toName': selectedEmployeeNames,
      'toEmail': selectedEmployeeEmail,
      'toPhone': selectedEmployeePhone,
      'toId': selectedEmployeeTokens
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
    _textFieldController = TextEditingController();

    taskToDo = taskToSend;
    controller.text = taskToDo;
    employeeListRetrieved = await retrieveEmployeeData();
    expenseOrderNumber = "Expense_${CommonFunctions().generateUniqueID(prefs.getString(kBusinessNameConstant)!)}";


    setState(() {});
  }

  @override
  void dispose() {
    _textFieldController.dispose();
    super.dispose();
  }


  void _showEmployeeDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder( // Introduce StatefulBuilder
          builder: (context, setStateForModal) { // Get a setState for the modal
            return
              AlertDialog(
              title: const Text("Assign Task To"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: employeeListRetrieved.map((name) {
                  return CheckboxListTile(
                    title: Text(name.fullNames),
                    value: selectedEmployeeNames.contains(name.fullNames),
                    onChanged: (bool? newValue) {
                      setState(() {
                        if (newValue!) {
                          selectedEmployeeNames.add(name.fullNames);
                          selectedEmployeeTokens.add(name.token);
                          selectedEmployeeEmail.add(name.email);
                          selectedEmployeePhone.add(name.phone);
                        } else {
                          selectedEmployeeNames.remove(name.fullNames);
                          selectedEmployeeTokens.add(name.token);
                          selectedEmployeeEmail.add(name.email);
                          selectedEmployeePhone.add(name.phone);


                        }
                      });
                      setStateForModal(() {}); // Force modal rebuild
                    },

                  );
                }).toList(),
              ),
                        actions: [
                          TextButton(
                            child: Text("Cancel"),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          ElevatedButton(
                            child: Text("Assign"),
                            onPressed: () {
                              _textFieldController.text = selectedEmployeeNames.join(", ");
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
              // ... rest of your AlertDialog code ...
            );
          },
        );
      },
    );
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    defaultInitilization();
    _textFieldController = TextEditingController();

  }

  @override
  Widget build(BuildContext context) {




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
              selectedEmployeeNames.isNotEmpty &&
              _selectedTime.isNotEmpty) {
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
                  Expanded( // Makes TextField take available space
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: TextField(
                        controller: _textFieldController,
                        readOnly: true, // Make the text field read-only
                        onTap: _showEmployeeDialog,
                        decoration: InputDecoration(
                            hintText: "Select Employees",
                            suffixIcon: Icon(Icons.arrow_drop_down) // Add a dropdown icon
                        ),
                      ),
                    ),
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
                        if (_selectedDates.contains(selectedDay)) {

                          setState(() {int indexToRemove = _selectedDates.indexOf(selectedDay);
                          _selectedDates.remove(selectedDay);
                          _selectedTime.removeAt(indexToRemove);



                          });
                        } else {
                          setState(() {
                            _showTimePicker(context, selectedDay);
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
