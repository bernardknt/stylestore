


import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:uuid/uuid.dart';

import '../../Utilities/constants/color_constants.dart';
import '../../model/styleapp_data.dart';
import '../../utilities/basket_items.dart';
import '../../utilities/constants/font_constants.dart';
import '../../utilities/constants/user_constants.dart';

class CalendarPageOld extends StatefulWidget {
  static String id = 'CalendarPage';

  const CalendarPageOld({Key? key}) : super(key: key);

  @override
  State<CalendarPageOld> createState() => _CalendarPageOldState();
}

class _CalendarPageOldState extends State<CalendarPageOld> {

  void defaultsInitiation()async{
    final prefs = await SharedPreferences.getInstance();
    //providerLocation = Provider.of<StyleProvider>(context).beauticianLocation;x
    prefs.setString(kOrderId, 'OL${date.day}'+'${uuid.v1().split("-")[0]}'+'${uuid.v4().split("-")[0]}'+'${date.month}');

  }

  DateTime date = DateTime.now();
  var uuid = Uuid();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    defaultsInitiation();
    List<BasketItem> products = Provider.of<StyleProvider>(context, listen: false).basketItems;

  }

  @override

  Widget build(BuildContext context) {
    var styleDataDisplay = Provider.of<StyleProvider>(context);
    var styleData = Provider.of<StyleProvider>(context, listen: false);
    // var styleData = Provider.of<StyleProvider>(context,listen:false);
    return Scaffold(
        appBar: AppBar(backgroundColor: kPureWhiteColor ,
          title: const Text('Appointment Date & Time',style: kHeadingTextStyle,),

        ),

        body: Container()
        // SfCalendar(
        //   showDatePickerButton: true,
        //   minDate: DateTime.now(),
        //   todayHighlightColor: kBlueDarkColorOld,
        //   todayTextStyle: kNormalTextStyleWhiteButtons,
        //
        //   onTap: (value){
        //
        //     styleData.setBookingPrice(styleDataDisplay.totalPrice);
        //
        //
        //     //
        //     // DatePicker.showTimePicker(context,
        //     //     currentTime: DateTime(2022,12,9,10,00),
        //     //     showSecondsColumn: false,
        //     //     // theme: DatePickerTheme(itemHeight: 50, itemStyle: kHeadingTextStyle),
        //     //
        //     //     //showTitleActions: t,
        //     //
        //     //     onConfirm: (time){
        //     //       // deliveryTime = date;
        //     //      Provider.of<StyleProvider>(context, listen: false).setAppointmentTimeDate(value.date, time);
        //     //       Navigator.pushNamed(context, SuccessPage.id);
        //     //
        //     //
        //     //
        //     //      // Navigator.pushNamed(context, SummaryPage.id);
        //     //
        //     //
        //     //
        //     //     });
        //
        //
        //   },
        //   view: CalendarView.month,
        //   initialSelectedDate: DateTime.now(),
        //   cellBorderColor: kBackgroundGreyColor,
        //   backgroundColor: kBackgroundGreyColor,
        //   selectionDecoration: BoxDecoration(
        //     borderRadius: BorderRadius.all(Radius.circular(8)),
        //     color: Colors.pink.withOpacity(0.5),
        //     border:
        //     Border.all(color: kGreyLightThemeColor,
        //         //const Color.fromARGB(255, 68, 140, 255),
        //         width: 2),
        //   ),
        //   blackoutDates:
        //   styleDataDisplay.convertedCalendarBlackouts,
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

