

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stylestore/model/styleapp_data.dart';
import 'package:stylestore/screens/success_page_appointments.dart';
//
import 'package:table_calendar/table_calendar.dart';
import '../../Utilities/constants/color_constants.dart';
import '../../Utilities/constants/font_constants.dart';
import '../../model/common_functions.dart';


class CalendarPage extends StatefulWidget {
  static String id = 'CalendarPage';

  const CalendarPage({Key? key}) : super(key: key);

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  @override
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  Widget build(BuildContext context) {
    var styleData = Provider.of<StyleProvider>(context, listen: false);
    return Scaffold(
        backgroundColor: kPureWhiteColor,
        appBar: AppBar(backgroundColor: kPureWhiteColor ,
          title: const Text('Expected Day to Get Paid',style: kHeadingTextStyle,),
          centerTitle: true,


        ),

        body:
        TableCalendar(

          focusedDay: _focusedDay,
          firstDay: DateTime.now().subtract(const Duration(days: 365)), // Allow a year back
          lastDay: DateTime.now().add(const Duration(days: 365)), // Allow a year in future
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          calendarFormat: CalendarFormat.month,
          headerStyle: const HeaderStyle(formatButtonVisible: false),
          // ... (Customization options, refer to the documentation)

          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });

            // Notification setup
            int notificationId = selectedDay.year + selectedDay.month + selectedDay.day;
            // CommonFunctions().scheduledNotification(
            //   //... Your notification parameters
            // );
            Provider.of<StyleProvider>(context, listen: false).setNotificationId(notificationId);
            Provider.of<StyleProvider>(context, listen:false).setPaymentDate(selectedDay);

            Navigator.pushNamed(context, SuccessPage.id);
          },
        ),
    // );
        //
        // SfCalendar(
        //
        //   showDatePickerButton: true,
        //   minDate: DateTime.now(),
        //   todayHighlightColor: kBlueDarkColorOld,
        //   todayTextStyle: kNormalTextStyleWhiteButtons,
        //
        //   onTap: (value){
        //     int notificationId = value.date!.year+value.date!.month+value.date!.day;
        //     CommonFunctions().scheduledNotification(heading: "Outstanding Payment for ${styleData.customerName} Invoice Due", body: "${styleData.customerName} payment for invoiced amount ${styleData.totalPrice} is due",
        //         year: value.date!.year, month: value.date!.month, day: value.date!.day, hour: 10, minutes:00, id: notificationId);
        //     print(notificationId);
        //     Provider.of<StyleProvider>(context, listen: false).setNotificationId(notificationId);
        //
        //
        //     DateTime selectedDateTime = DateTime(value.date!.year,value.date!.month,value.date!.day);
        //     Provider.of<StyleProvider>(context, listen:false).setPaymentDate(selectedDateTime);
        //     Navigator.pushNamed(context, SuccessPage.id);
        //
        //
        //
        //
        //   },
        //   view: CalendarView.month,
        //   initialSelectedDate: DateTime.now(),
        //   cellBorderColor: kBackgroundGreyColor,
        //   backgroundColor: kBackgroundGreyColor,
        //   selectionDecoration: BoxDecoration(
        //     borderRadius: BorderRadius.all(Radius.circular(8)),
        //     color: kAppPinkColor.withOpacity(0.5),
        //     border:
        //     Border.all(color: kGreyLightThemeColor,
        //         width: 2),
        //   ),
        //   blackoutDatesTextStyle: kNormalTextStyleDatesUnavailable,
        //   //
        // )
    );
  }
}

