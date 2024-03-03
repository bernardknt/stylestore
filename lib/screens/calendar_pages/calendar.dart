

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stylestore/model/styleapp_data.dart';
import 'package:stylestore/screens/success_page_appointments.dart';
// import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:intl/intl.dart';

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

  Widget build(BuildContext context) {
    var styleDataDisplay = Provider.of<StyleProvider>(context);
    var styleData = Provider.of<StyleProvider>(context, listen: false);
    //var styleDataDisplay = Provider.of<StyleProvider>(context);
    // var styleData = Provider.of<StyleProvider>(context, listen: false);
    // var styleData = Provider.of<StyleProvider>(context,listen:false);
    return Scaffold(
        backgroundColor: kBlack,
        appBar: AppBar(backgroundColor: kPureWhiteColor ,
          title: const Text('Expected Day to Get Paid',style: kHeadingTextStyle,),
          centerTitle: true,


        ),

        body: Container()
        // SfCalendar(
        //
        //   showDatePickerButton: true,
        //   minDate: DateTime.now(),
        //   todayHighlightColor: kBlueDarkColorOld,
        //   todayTextStyle: kNormalTextStyleWhiteButtons,
        //
        //   onTap: (value){
        //     //styleData.setBookingPrice(styleDataDisplay.totalPrice, false);
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
        //         //const Color.fromARGB(255, 68, 140, 255),
        //         width: 2),
        //   ),
        //   // blackoutDates:
        //   // styleDataDisplay.convertedCalendarBlackouts,
        //   // blackoutDates:  [
        //   //
        //   //   DateTime.now().add(Duration(days: 3, hours: 14) ),
        //   //   DateTime.now().add(Duration(days: 6)),
        //   //   DateTime.now().add(Duration(days: 7)),
        //   //   DateTime.now().add(Duration(days: 12)),
        //   // ],
        //   blackoutDatesTextStyle: kNormalTextStyleDatesUnavailable,
        //   //
        // )
    );
  }
}

