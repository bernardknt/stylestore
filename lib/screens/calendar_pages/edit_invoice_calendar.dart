import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../Utilities/constants/color_constants.dart';
import '../../model/styleapp_data.dart';
import '../../utilities/constants/font_constants.dart';

class EditInvoiceCalendarPage extends StatefulWidget {
  static String id = 'EditInvoiceCalendarPage';

  const EditInvoiceCalendarPage({Key? key}) : super(key: key);

  @override
  State<EditInvoiceCalendarPage> createState() => _EditInvoiceCalendarPageState();
}

class _EditInvoiceCalendarPageState extends State<EditInvoiceCalendarPage> {
  DateTime selectedDate = DateTime.now();
  CalendarFormat calendarFormat = CalendarFormat.month;

  @override
  void initState() {
    super.initState();
    selectedDate = Provider.of<StyleProvider>(context, listen: false).invoicedDate ?? DateTime.now();
  }

  Future<void> _showTimePicker(BuildContext context, DateTime day) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(DateTime.now()),
    );

    if (pickedTime != null) {
      setState(() {
        selectedDate = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, pickedTime.hour, pickedTime.minute);
        Provider.of<StyleProvider>(context, listen: false).setInvoicedTimeDate(selectedDate);
        Navigator.pop(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPureWhiteColor,
        title: const Text('Enter Invoice Date', style: kHeadingTextStyle),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TableCalendar<void>(
              firstDay: DateTime(DateTime.now().year - 1), // Allow selection a year back
              lastDay: DateTime(DateTime.now().year + 1), // Allow selection a year forward
              focusedDay: selectedDate,
              calendarFormat: calendarFormat,
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  selectedDate = selectedDay;
                  _showTimePicker(context, selectedDay);
                });
              },
              onFormatChanged: (format) {
                setState(() {
                  calendarFormat = format;
                });
              },
              startingDayOfWeek: StartingDayOfWeek.sunday, // Adjust if needed
              daysOfWeekVisible: true,
              selectedDayPredicate: (day) => isSameDay(selectedDate, day),

            ),

          ],
        ),
      ),
    );
  }
}



//
//
//
// import 'package:flutter/material.dart';
// import '../../Utilities/constants/color_constants.dart';
// import '../../utilities/constants/font_constants.dart';
// class EditInvoiceCalendarPage extends StatefulWidget {
//   static String id = 'EditInvoiceCalendarPage';
//
//   const EditInvoiceCalendarPage({Key? key}) : super(key: key);
//
//   @override
//   State<EditInvoiceCalendarPage> createState() => _EditInvoiceCalendarPageState();
// }
//
// class _EditInvoiceCalendarPageState extends State<EditInvoiceCalendarPage> {
//
//
//
//   DateTime date = DateTime.now();
//
//
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//   }
//
//   @override
//
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(backgroundColor: kPureWhiteColor ,
//           title: const Text('Enter Invoice Date',style: kHeadingTextStyle,),
//           centerTitle: true,
//
//         ),
//
//         body:
//         SfCalendar(
//           showDatePickerButton: true,
//           todayHighlightColor: kBlueDarkColorOld,
//           todayTextStyle: kNormalTextStyleWhiteButtons,
//           onTap: (value){
//
//             Provider.of<StyleProvider>(context, listen: false).setInvoicedTimeDate(value.date);
//             Navigator.pop(context);
//           },
//           view: CalendarView.month,
//           initialSelectedDate: Provider.of<StyleProvider>(context).invoicedDate,
//           cellBorderColor: kBackgroundGreyColor,
//           backgroundColor: kBackgroundGreyColor,
//           selectionDecoration: BoxDecoration(
//             borderRadius: BorderRadius.all(Radius.circular(8)),
//             color: Colors.pink.withOpacity(0.5),
//             border:
//             Border.all(color: kGreyLightThemeColor,
//                 //const Color.fromARGB(255, 68, 140, 255),
//                 width: 2),
//           ),
//         )
//     );
//   }
// }
//
